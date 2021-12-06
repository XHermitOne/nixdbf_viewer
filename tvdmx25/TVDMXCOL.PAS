
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	tvDMXCOL  --Collection Data Editing Unit	}
{	tvDMX	  --data editing project		}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Unit tvDMXCOL;

{$B-,O+,R-,V-,X+ }

interface

uses
    Objects, Drivers, Memory, Views, App, MsgBox,
    RSet, DmxGizma, tvDMX, StdDMX;

type
    PDmxCollectView	= ^TDmxCollectView;
    PDmxCollector	= ^TDmxCollector;
    PDmxCollectViewWin	= ^TDmxCollectViewWin;
    PDmxCollectorWin	= ^TDmxCollectorWin;


    TDmxCollectView	=  OBJECT(TDmxScroller)
      constructor Init(ATemplate : string;  var AData;
			var Bounds : TRect;  ALabels : PView;
			AHScrollBar,AVScrollBar : PScrollBar);
      function	DataAt(RecNum : integer) : pointer;  VIRTUAL;
      procedure InitData(var AData );  VIRTUAL;
      function	RecordLimit : longint;	VIRTUAL;
      procedure SetState(AState : word; Enable : boolean);  VIRTUAL;
    end;


    TDmxCollector	=  OBJECT(TDmxEditor)
	Expandable	: boolean;
	NewDataRec	: pointer;
	MaxCount	: integer;
	MemWarning	: boolean;
      function	DataAt(RecNum : integer) : pointer;  VIRTUAL;
      procedure DoneData;  VIRTUAL;
      procedure EvaluateRecord;  VIRTUAL;
      procedure HandleEvent(var Event : TEvent);  VIRTUAL;
      procedure InitData(var AData );  VIRTUAL;
      procedure InitNewDataRec;
      procedure LoadStruct(var S : TStream);  VIRTUAL;
      function	RecordLimit : longint;	VIRTUAL;
      procedure SetState(AState : word; Enable : boolean);  VIRTUAL;
      procedure SetupRecord;  VIRTUAL;
      procedure StoreStruct(var S : TStream);  VIRTUAL;
      function	Valid(Command : word) : boolean;  VIRTUAL;
      procedure ZeroizeRecord;	VIRTUAL;
    end;


    TDmxCollectViewWin	=  OBJECT(TDmxViewer)
      constructor Init(var Bounds : TRect;  ATitle : TTitleStr;
			ANumber : integer;  ATemplate : string;
			ACollection : PCollection;  var ALabels : string);
      procedure InitDMX(ATemplate  : string;  var AData;
			 ALabels, ARecInd  : PDmxLink;
			 BSize	: longint);  VIRTUAL;
    end;


    TDmxCollectorWin	=  OBJECT(TDmxWindow)
      constructor Init(var Bounds : TRect;
			ATitle	  : TTitleStr;	ANumber  : integer;
			ATemplate : string;  ACollection : PCollection;
			BSize	  : integer; var ALabels : string; IndLen : integer);
      procedure InitDMX(ATemplate  : string;  var AData;
			 ALabels, ARecInd  : PDmxLink;
			 BSize	: longint);  VIRTUAL;
    end;


  function  fldObjectVMT(Obj : PObject) : string;
    { template prefix to generate a VMT identifier
      for collections of TObject derivatives
     }

  procedure ResetCollection(Collection : PCollection);
    { adjust the size of the database }


  procedure RegisterTVDMXCOL;


const
    RDmxCollectView	:  TStreamRec =(
	ObjType:   rnDmxCollectView;
	VmtLink:   ofs(TypeOf(TDmxCollectView)^);
	Load:	   @TDmxCollectView.Load;
	Store:	   @TDmxCollectView.Store
      );

    RDmxCollector	:  TStreamRec =(
	ObjType:   rnDmxCollector;
	VmtLink:   ofs(TypeOf(TDmxCollector)^);
	Load:	   @TDmxCollector.Load;
	Store:	   @TDmxCollector.Store
      );

    RDmxCollectViewWin	:  TStreamRec =(
	ObjType:   rnDmxCollectViewWin;
	VmtLink:   ofs(TypeOf(TDmxCollectViewWin)^);
	Load:	   @TDmxCollectViewWin.Load;
	Store:	   @TDmxCollectViewWin.Store
      );

    RDmxCollectorWin	:  TStreamRec =(
	ObjType:   rnDmxCollectorWin;
	VmtLink:   ofs(TypeOf(TDmxCollectorWin)^);
	Load:	   @TDmxCollectorWin.Load;
	Store:	   @TDmxCollectorWin.Store
      );


implementation

  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  fldObjectVMT(Obj : PObject) : string;
begin
  fldObjectVMT := ^H^F^F'c'^V + pchar(Obj)^ + #0^H^F^F'c'^V + pstring(Obj)^[1] + #0;
  Dispose(Obj, Done);
end;


procedure ResetCollection(Collection : PCollection);
{ adjust the size of the database }
begin
  Repeat
  Until (Message(DeskTop, evBroadcast, cmDMX_Reset, Collection) = nil)
     or (Collection^.Count > 0);
  Message(DeskTop, evCommand, cmDMX_Reset, Collection);
end;


  { ออ TDmxCollectView อออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxCollectView.Init(ATemplate	: string;  var AData;
				  var Bounds	: TRect;
				  ALabels	: PView;
				  AHScrollBar,AVScrollBar : PScrollBar);
begin
  TDmxScroller.Init(ATemplate, AData, 0, Bounds, ALabels, AHScrollBar, AVScrollBar);
end;


function  TDmxCollectView.DataAt(RecNum : integer) : pointer;
begin
  If (PCollection(WorkingData)^.Count <= RecNum) then
    DataAt := nil
   else
    DataAt := PCollection(WorkingData)^.At(RecNum);
end;


procedure TDmxCollectView.InitData(var AData );
var  RecSize,RecCount	: longint;
begin
  TDmxScroller.InitData(AData);
  RecSize  := RecordSize;
  RecCount := PCollection(WorkingData)^.Count;
  DataBlockSize := RecSize * RecCount;
end;


function  TDmxCollectView.RecordLimit : longint;
begin
  RecordLimit := PCollection(WorkingData)^.Count
end;


procedure TDmxCollectView.SetState(AState : word; Enable : boolean);
var  RecSize,RecCount	: longint;
begin
  If Enable and (AState = sfFocused) then
    begin
    RecSize  := RecordSize;
    RecCount := PCollection(WorkingData)^.Count;
    DataBlockSize := RecSize * RecCount;
    end;
  TDmxScroller.SetState(AState, Enable);
end;


  { ออ TDmxCollector อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TDmxCollector.DataAt(RecNum : integer) : pointer;
{ this method is called whenever it must retrieve a record,
  whether it is for display purposes or for editing }
begin
  If (PCollection(WorkingData)^.Count <= RecNum) then
    DataAt  := NewDataRec
   else
    DataAt  := PCollection(WorkingData)^.At(RecNum);
end;


procedure TDmxCollector.DoneData;
{ this method is called during termination }
begin
  TDmxEditor.DoneData;
  If (NewDataRec <> nil) then FreeMem(NewDataRec, RecordSize);
end;


procedure TDmxCollector.EvaluateRecord;
{ called after each record is edited }
var  P : pointer;
begin
  TDmxEditor.EvaluateRecord;
  If RecordAltered then
    begin
    { If this is an old record, then we can assume that this is the
      one we were editing.  Otherwise, we need to make a new one. }
    If (PCollection(WorkingData)^.Count <= CurrentRecord) then
      begin
      { place the record into the collection }
      P := NewDataRec;
      PCollection(WorkingData)^.Insert(NewDataRec);

      { create a new record for NewDataRec }
      GetMem(NewDataRec, RecordSize);
      RecordData := NewDataRec;
      TDmxEditor.ZeroizeRecord;
      RecordData := P;
      If ((MaxCount = 0) or (PCollection(WorkingData)^.Count < MaxCount))
	 and (CurrentRecord < MaxCollectionSize) then
	begin
	If ((MemAvail shr 4) > LowMemSize) then
	  begin
	  { increase the size of the database }
	  DataBlockSize := DataBlockSize + RecordSize;
	  SetLimit(Limit.X, DataBlockSize div RecordSize);
	  Expandable := TRUE;
	  end
	 else
	  begin
	  Expandable := FALSE;
	  If not MemWarning then
	    begin
	    MessageBox('Too little memory to expand collection.', nil, mfError + mfOKCancel);
	    MemWarning := TRUE;
	    end;
	  end;
	end;
      end;
    end;
end;


procedure TDmxCollector.HandleEvent(var Event : TEvent);
var  L : longint;
    procedure InsertRec;
    var  P: pointer;
    begin
      EvaluateField;
      EvaluateRecord;
      If ((MaxCount = 0) or (PCollection(WorkingData)^.Count < MaxCount))
	 and (Limit.Y < MaxCollectionSize) then
	begin
	If ((MemAvail shr 4) > LowMemSize) then
	  begin
	  GetMem(RecordData, RecordSize);
	  TDmxEditor.ZeroizeRecord;  { this initializes the new record }
	  PCollection(WorkingData)^.AtInsert(CurrentRecord, RecordData);
	  DataBlockSize := DataBlockSize + RecordSize;
	  SetLimit(Limit.X, Limit.Y+1);
	  DrawView;
	  Expandable := TRUE;
	  end
	 else
	  begin
	  Expandable := FALSE;
	  If not MemWarning then
	    begin
	    MessageBox('Too little memory to expand collection.', nil, mfError + mfOKCancel);
	    MemWarning := TRUE;
	    end;
	  end;
	end;
      SetupRecord;
      SetupField;
    end;
begin
  If (Event.What and evMessage <> 0) and (Event.Command = cmDMX_Reset) and
     (Event.InfoPtr = WorkingData) then
    begin
    DataBlockSize := RecordSize;
    L := PCollection(WorkingData)^.Count;
    DataBlockSize := DataBlockSize * L;
    If (MaxCount = 0) or (PCollection(WorkingData)^.Count < MaxCount) then
      DataBlockSize := DataBlockSize + RecordSize;
    If (DataBlockSize <= 0) and (Owner <> nil) and
       ((State and sfFocused = 0) or (Event.What = evCommand)) then
      begin
      Event.What := evCommand;
      Event.Command := cmClose;
      Event.InfoPtr := Owner;
      end
     else
      begin
      If RecordSelected then
	begin
	FieldAltered  := FALSE;
	RecordAltered := FALSE;
	EvaluateField;
	EvaluateRecord;
	If (CurrentRecord >= (DataBlockSize div RecordSize)) and
	   (DataBlockSize > 0) then
	  CurrentRecord := pred(DataBlockSize div RecordSize);
	SetupRecord;
	SetupField;
	end;
      SetLimit(Limit.X, DataBlockSize div RecordSize);
      DrawView;
      If (Event.What = evCommand) then ClearEvent(Event);
      end;
    end
   else
    begin
    TDmxEditor.HandleEvent(Event);
    If (Event.What = evCommand) and (Event.Command = cmDMX_InsertRec) then
      InsertRec
    else
    If (Event.What = evKeyDown) and (Event.Command = kbCtrlN) then
      Message(Application, evCommand, cmDMX_InsertRec, @Self)
    else
      Exit;
    ClearEvent(Event);
    end;
end;


procedure TDmxCollector.InitData(var AData );
{ this method is called during initialization }
var  RecSize,RecCount	: longint;
begin
  TDmxEditor.InitData(AData);

  { Note that the given database size is used for max record count. }
  Move(DataBlockSize, MaxCount, 2);

  RecSize  := RecordSize;
  RecCount := PCollection(WorkingData)^.Count;
  DataBlockSize := RecSize * RecCount;
  If (MaxCount = 0) or (RecCount < MaxCount) then
    begin
    DataBlockSize := DataBlockSize + RecordSize;
    Expandable := TRUE;
    end;

  InitNewDataRec;
end;


procedure TDmxCollector.InitNewDataRec;
{ initialize a temporary data object for new records }
begin
  If (RecordSize > 0) then
    begin
    GetMem(NewDataRec, RecordSize);
    RecordData		:= NewDataRec;
    TDmxEditor.ZeroizeRecord;
    RecordAltered	:= FALSE;
    FieldAltered	:= FALSE;
    end
   else
    NewDataRec	:= nil;
end;


procedure TDmxCollector.LoadStruct(var S : TStream);
begin
  TDmxEditor.LoadStruct(S);
  S.Read(MaxCount, sizeof(MaxCount));
  InitNewDataRec;
end;


function  TDmxCollector.RecordLimit : longint;
begin
  RecordLimit := PCollection(WorkingData)^.Count
end;


procedure TDmxCollector.SetState(AState : word; Enable : boolean);
{ resets the DataBlockSize if the collection's limit has changed }
var  RecSize,RecCount	: longint;
begin
  RecSize  := RecordSize;
  RecCount := PCollection(WorkingData)^.Count;
  If Enable and (AState = sfFocused) and
    (DataBlockSize <> RecSize * succ(RecCount)) then
    begin
    DataBlockSize := RecSize * RecCount;
    If (MaxCount = 0) or (RecCount < MaxCount) then
      begin
      DataBlockSize := DataBlockSize + RecordSize;
      Expandable := TRUE;
      end
     else
      Expandable := FALSE;
    end;
  TDmxEditor.SetState(AState, Enable);
end;


procedure TDmxCollector.SetupRecord;
{ called before each record is edited }
var  P	   : pointer;
     DA,JA : boolean;
begin
  TDmxEditor.SetupRecord;
  If (PCollection(WorkingData)^.Count <= CurrentRecord) then
    begin
    DA := DataAltered;
    JA := JustAltered;
    TDmxEditor.ZeroizeRecord;
    RecordAltered := FALSE;
    FieldAltered := FALSE;
    DataAltered := DA;
    JustAltered := JA;
    Expandable	:= TRUE;
    end;
end;


procedure TDmxCollector.StoreStruct(var S : TStream);
begin
  TDmxEditor.StoreStruct(S);
  S.Write(MaxCount, sizeof(MaxCount));
end;


function  TDmxCollector.Valid(Command : word) : boolean;
var  V : boolean;
begin
  V := TDmxEditor.Valid(Command);
  If V and (Command = cmValid) and
     ((WorkingData = nil) or (DataBlockSize < RecordSize) or (RecordSize <= 0)) then
    begin
    MessageBox('No data available.', nil, mfError or mfOKButton);
    Valid := FALSE;
    end
  else
  If V and (Command = cmDMX_ZeroizeRecord) and (not RecordSelected) then
    Valid := FALSE
  else
    Valid := V;
end;


procedure TDmxCollector.ZeroizeRecord;
var  RS : boolean;
     E	: TEvent;
begin
  If Locked then Exit;
  RS := RecordSelected;
  If RS then
    begin
    EvaluateField;
    EvaluateRecord;
    end;
  If (PCollection(WorkingData)^.Count > CurrentRecord) then
    begin
    PCollection(WorkingData)^.AtFree(CurrentRecord);
    { adjust the size of the database }
    Repeat
    Until (Message(DeskTop, evBroadcast, cmDMX_Reset, WorkingData) = nil)
       or (DataBlockSize > 0);
    If (DataBlockSize = 0) then
      begin
      E.What := evCommand;
      E.Command := cmClose;
      E.InfoPtr := Owner;
      PutEvent(E);
      end;
    end;
  If RS then
    begin
    SetupRecord;
    SetupField;
    end;
end;


  { ออ TDmxCollectViewWin ออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxCollectViewWin.Init(var Bounds	: TRect;
		ATitle	  : TTitleStr;	ANumber  : integer;
		ATemplate : string;  ACollection : PCollection;
		var ALabels : string);
begin
  TDmxViewer.Init(Bounds, ATitle, ANumber, ATemplate,
		   ACollection^, 0, ALabels);
end;


procedure TDmxCollectViewWin.InitDMX(ATemplate	: string;  var AData;
				ALabels, ARecInd : PDmxLink;
				BSize  : longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If ALabels <> nil then Inc(R.A.Y, ALabels^.Size.Y);
  Insert(New(PDmxCollectView, Init(ATemplate, AData, R, ALabels,
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical))));
end;


  { ออ TDmxCollectorWin ออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxCollectorWin.Init(var Bounds	: TRect;
		ATitle	  : TTitleStr;	ANumber  : integer;
		ATemplate : string;  ACollection : PCollection;
		BSize	  : integer; var ALabels : string; IndLen : integer);
begin
  TDmxWindow.Init(Bounds, ATitle, ANumber, ATemplate,
		  ACollection^, BSize, ALabels, IndLen);
end;


procedure TDmxCollectorWin.InitDMX(ATemplate  : string;  var AData;
			ALabels, ARecInd : PDmxLink;  BSize  : longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If ALabels <> nil then Inc(R.A.Y, ALabels^.Size.Y);
  Insert(New(PDmxCollector, Init(ATemplate, AData, BSize, R,
		ALabels, ARecInd,
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical))));
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure RegisterTVDMXCOL;
begin
  RegisterType(RDmxCollectView);
  RegisterType(RDmxCollector);
  RegisterType(RDmxCollectViewWin);
  RegisterType(RDmxCollectorWin);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


End.
