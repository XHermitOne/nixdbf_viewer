
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	tvDMXBUF  --Buffered Data Editing Unit		}
{	tvDMX	  --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Unit tvDMXBUF;

{$B-,D+,R-,O+,X+,V- }

interface

uses
    Objects, Drivers, Views, Dialogs, App, MsgBox,
    RSet, DmxGizma, tvDMX, StdDMX;

const
    EmptySlot	=  -1;

type
    PSlot	= ^TSlot;
    TSlot	=  RECORD
	Data	: pointer;
	RowNum	: longint;
    end;


    PRowSlots	= ^TRowSlots;
    TRowSlots	=  array[0..99] of TSlot;


    PDmxEditBuf     = ^TDmxEditBuf;
    PDmxStreamBuf   = ^TDmxStreamBuf;
    PDmxExpBuf	    = ^TDmxExpBuf;
    PDmxExpRecInd   = ^TDmxExpRecInd;
    PDmxBufWin	    = ^TDmxBufWin;
    PDmxExpBufWin   = ^TDmxExpBufWin;
    PDmxEditRecBuf  = ^TDmxEditRecBuf;


    TDmxEditBuf   =  OBJECT(TDmxEditor)
	Expandable	:  boolean;
	Appending	:  boolean;
	NumSlots	:  integer;
	KeyFields	:  set of byte;
	KeyAltered	:  boolean;
	StepMode	:  boolean;
      constructor Load(var S: TStream);
      function  BufValid : boolean;  VIRTUAL;
      function	DataAt(RecNum: integer)  : pointer;  VIRTUAL;
      procedure DeleteRec;  VIRTUAL;
      procedure DoneStruct;  VIRTUAL;
      function	ErrorFunc : boolean;  VIRTUAL;
      procedure EvaluateField;	VIRTUAL;
      procedure EvaluateRecord;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure InitStruct(var ATemplate );  VIRTUAL;
      procedure LoadStruct(var S: TStream);  VIRTUAL;
      procedure MakeSlots;
      function	ReadRec(var RecData ) : boolean;  VIRTUAL;
      function	RecordLimit : longint;	VIRTUAL;
      procedure ResetSize;
      procedure ResetSlots;
      function	SeekRec(RecNum: longint) : boolean;  VIRTUAL;
      function	SeekEnd : boolean;  VIRTUAL;
      procedure SetState(AState: word; Enable: boolean);  VIRTUAL;
      procedure SetUpRecord;  VIRTUAL;
      procedure Store(var S: TStream);
      function	Valid(Command: word) : boolean;  VIRTUAL;
      function	WriteRec(var RecData ) : boolean;  VIRTUAL;
      procedure ZeroizeField(Whole: boolean; Field: pDMXfieldrec);  VIRTUAL;
      procedure ZeroizeRecord;	VIRTUAL;
      private
	RowSlot		:  PRowSlots;
	NewRecord	:  boolean;  { indicates this is a new record }
    end;


    TDmxStreamBuf =  OBJECT(TDmxEditBuf)
	Prefix		:  pointer;
	PrefixSize	:  integer;
      function	ErrorFunc : boolean;  VIRTUAL;
      procedure LoadStruct(var S: TStream);  VIRTUAL;
      function	ReadRec(var RecData ) : boolean;  VIRTUAL;
      function	RecordLimit : longint;	VIRTUAL;
      function	SeekEnd : boolean;  VIRTUAL;
      function	SeekRec(RecNum: longint) : boolean;  VIRTUAL;
      procedure StoreStruct(var S: TStream);  VIRTUAL;
      function	WriteRec(var RecData ) : boolean;  VIRTUAL;
    end;


    TDmxExpBuf	  =  OBJECT(TDmxStreamBuf)
      procedure InitData(var AData );  VIRTUAL;
    end;


    TDmxExpRecInd =  OBJECT(TDmxRecInd)
      procedure Draw;  VIRTUAL;
    end;


    TDmxBufWin	  =  OBJECT(TDmxWindow)
      procedure InitDMX(ATemplate: string;  var AData;
			ALabels,ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
    end;


    TDmxExpBufWin =  OBJECT(TDmxWindow)
      procedure InitDMX(ATemplate: string;  var AData;
			ALabels,ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
      function	NewRecInd(Len: integer)  : PDmxLink;  VIRTUAL;
    end;


    TDmxEditRecBuf  =  OBJECT(TDmxEditBuf)
	RecPosition	: longint;
      function	AppendRec(var RecData ) : boolean;  VIRTUAL;
      function	FirstRec : boolean;  VIRTUAL;
      procedure InitData(var AData );  VIRTUAL;
      function	LastRec : boolean;  VIRTUAL;
      function	NextRec : boolean;  VIRTUAL;
      function	PrevRec : boolean;  VIRTUAL;
      function	SeekEnd : boolean;  VIRTUAL;
      function	SeekRec(RecNum: longint) : boolean;  VIRTUAL;
      function	UpdateRec(var RecData ) : boolean;  VIRTUAL;
      function	WriteRec(var RecData ) : boolean;  VIRTUAL;
    end;


  procedure RegisterTVDMXBUF;


const
    RDmxStreamBuf	:  TStreamRec =(
	ObjType:   rnDmxStreamBuf;
	VmtLink:   ofs(TypeOf(TDmxStreamBuf)^);
	Load:	   @TDmxStreamBuf.Load;
	Store:	   @TDmxStreamBuf.Store
      );

    RDmxExpBuf		:  TStreamRec =(
	ObjType:   rnDmxExpBuf;
	VmtLink:   ofs(TypeOf(TDmxExpBuf)^);
	Load:	   @TDmxExpBuf.Load;
	Store:	   @TDmxExpBuf.Store
      );

    RDmxExpRecInd	:  TStreamRec =(
	ObjType:   rnDmxExpRecInd;
	VmtLink:   ofs(TypeOf(TDmxExpRecInd)^);
	Load:	   @TDmxExpRecInd.Load;
	Store:	   @TDmxExpRecInd.Store
      );

    RDmxBufWin		:  TStreamRec =(
	ObjType:   rnDmxBufWin;
	VmtLink:   ofs(TypeOf(TDmxBufWin)^);
	Load:	   @TDmxBufWin.Load;
	Store:	   @TDmxBufWin.Store
      );

    RDmxExpBufWin	:  TStreamRec =(
	ObjType:   rnDmxExpBufWin;
	VmtLink:   ofs(TypeOf(TDmxExpBufWin)^);
	Load:	   @TDmxExpBufWin.Load;
	Store:	   @TDmxExpBufWin.Store
      );


implementation

  { ออ TDmxEditBuf อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxEditBuf.Load(var S : TStream);
begin
  TDmxEditor.Load(S);
  S.Read(KeyFields,  sizeof(KeyFields));
  S.Read(Expandable, sizeof(Expandable));
  S.Read(StepMode,   sizeof(StepMode));
end;


function  TDmxEditBuf.BufValid : boolean;
begin
  BufValid := TRUE
end;


function  TDmxEditBuf.DataAt(RecNum: integer) : pointer;
var  Slot	: integer;
     LRecNum	: longint;
    function  SeekOK : boolean;
    begin
      If Expandable and (LRecNum >= RecordLimit) then
	begin
	NewRecord := TRUE;
	SeekOK	  := TRUE;
	end
       else
	SeekOK := SeekRec(LRecNum);
    end;
begin
  If (not InitValid) or (NumSlots = 0) or (RecordSize = 0) then
    begin
    Locked := TRUE;
    DataAt := nil;
    Exit;
    end;
  LRecNum := RecNum;
  LRecNum := LRecNum + BaseRecord;
  Slot	:= LRecNum mod NumSlots;
  NewRecord := FALSE;
  If (RowSlot^[Slot].RowNum <> LRecNum) then
    begin
    FillChar(RowSlot^[Slot].Data^, RecordSize, 0);
    RowSlot^[Slot].RowNum := LRecNum;
    Repeat
    Until (SeekOK and (NewRecord or ReadRec(RowSlot^[Slot].Data^)))
	or ErrorFunc;
    end;
  DataAt := RowSlot^[Slot].Data;
end;


procedure TDmxEditBuf.DeleteRec;
{ pseudo-abstract virtual method to delete the record }
begin
  { override this method completely if you are removing a row too }
  Appending := FALSE;
  RecordAltered := TRUE;
end;


procedure TDmxEditBuf.DoneStruct;
var i : integer;
begin
  If (RowSlot <> nil) then
    begin
    For i := 0 to pred(NumSlots) do
      If (RowSlot^[i].Data <> nil) then FreeMem(RowSlot^[i].Data, RecordSize);
    FreeMem(RowSlot, NumSlots * sizeof(TSlot));
    RowSlot  := nil;
    NumSlots := 0;
    end;
  TDmxEditor.DoneStruct;
end;


function  TDmxEditBuf.ErrorFunc : boolean;
{ pseudo-abstract method to handle access errors }
begin
 { This method should take care of the error
   and return TRUE if the error can be ignored
   or FALSE if the operation should be repeated. }

  ErrorFunc := (SystemError(14, 0) = 1);
end;


procedure TDmxEditBuf.EvaluateField;
begin
  If FieldAltered and (CurrentField^.fieldnum in KeyFields) then KeyAltered := TRUE;
  TDmxEditor.EvaluateField;
end;


procedure TDmxEditBuf.EvaluateRecord;
var  L : longint;
    function  DoWrite : boolean;
    begin
      DoWrite := WriteRec(RowSlot^[CurrentRecord mod NumSlots].Data^);
    end;
begin
  If RecordAltered then
    begin
    RecordAltered := FALSE;
    If Appending then
      begin
      Repeat until (SeekEnd and DoWrite) or ErrorFunc;
      ResetSize;
      Appending := FALSE;
      end
    else
    If StepMode then
      begin
      Repeat until DoWrite or ErrorFunc;
      end
     else
      begin
      L := CurrentRecord;
      L := L + BaseRecord;
      Repeat until (SeekRec(L) and DoWrite) or ErrorFunc;
      end;
    end;
  TDmxEditor.EvaluateRecord;
  If KeyAltered or not BufValid then
    begin
    KeyAltered := FALSE;
    ResetSlots;
    DrawView;
    Message(Owner, evBroadcast, cmDMX_DrawData, WorkingData);
    end;
end;


procedure TDmxEditBuf.HandleEvent(var Event: TEvent);
var  RS,FS : boolean;
begin
  With Event do
    If (What and evMessage <> 0) and (NumSlots > 0) and
	(((Command = cmDMX_DrawData) and (WorkingData = InfoPtr))
       or
	 ((Command = cmDMX_Draw)
	and (InfoPtr <> @Self)
	and (PDmxScroller(InfoPtr)^.WorkingData = WorkingData)))
     then
      begin
      If Vidis then Exit;
      RS := RecordSelected;
      FS := FieldSelected;
      If RS then
	begin
	If FS then EvaluateField;
	EvaluateRecord;
	end;
      ResetSlots;
      end
     else
      RS := FALSE;
  TDmxEditor.HandleEvent(Event);
  If RS then
    begin
    SetupRecord;
    If FS then SetupField;
    end;
end;


procedure TDmxEditBuf.InitStruct(var ATemplate );
begin
  TDmxEditor.InitStruct(ATemplate);
  MakeSlots;
end;


procedure TDmxEditBuf.LoadStruct(var S: TStream);
begin
  TDmxEditor.LoadStruct(S);
  MakeSlots;
end;


procedure TDmxEditBuf.MakeSlots;
var i  : integer;
begin
  If InitValid and (RecordSize > 0) then
    begin
    NumSlots := ScreenHeight;
    If (HiResScreen and (NumSlots < 30)) then NumSlots := 46;
    If (NumSlots < Size.Y) then NumSlots := Size.Y;
    GetMem(RowSlot, NumSlots * sizeof(TSlot));
    fillchar(RowSlot^, NumSlots * sizeof(TSlot), 0);
    For i := 0 to pred(NumSlots) do
      begin
      If ((MaxAvail shr 4) > RecordSize) then
	begin
	RowSlot^[i].RowNum := EmptySlot;
	GetMem(RowSlot^[i].Data, RecordSize);
	end
       else
	InitValid := FALSE;
      end;
    end;
end;


function  TDmxEditBuf.ReadRec(var RecData ) : boolean;
{ abstract virtual method to read a record }
begin
  Abstract;
 { This method should read a record and return TRUE if there is no error. }
end;


function  TDmxEditBuf.RecordLimit : longint;
{ pseudo-abstract method returns the maximum number of records available }
var  L : longint;
begin
  L := TDmxEditor.RecordLimit;
  If Expandable and (L > 0) then Dec(L);
  RecordLimit := L;
end;


procedure TDmxEditBuf.ResetSize;
var  Recs,RecSize : longint;
     A		  : string;
begin
  Recs := RecordLimit;
  If (Recs > 32766) then Recs := 32766;
  If Expandable and (Recs < 32766) then Inc(Recs);
  If (Recs < 0) then Recs := 0;
  RecSize := RecordSize;
  If (Recs * RecSize <> DataBlockSize) then
    begin
    DataBlockSize := Recs * RecSize;
    SetLimit(Limit.X, Recs);
    If (succ(CurrentRecord) > Recs) then CurrentRecord := Recs - 1;
    ResetSlots;
    end;
end;


procedure TDmxEditBuf.ResetSlots;
var  i : integer;
begin
  If (NumSlots > 0) then
    For i := 0 to pred(NumSlots) do RowSlot^[i].RowNum := EmptySlot;
end;


function  TDmxEditBuf.SeekEnd : boolean;
{ pseudo-abstract method used for expandable databases }
begin
 { This method should seek to the end of the database, and
   return TRUE if there is no error.  Many database tools
   will just require that you clear its record buffer.
   The default here is to seek to the limit using method SeekRec().
  }
  SeekRec(RecordLimit);
  SeekEnd := TRUE;
end;


function  TDmxEditBuf.SeekRec(RecNum: longint) : boolean;
{ abstract virtual method to seek to the record position }
begin
  Abstract;
 { This method should seek to the given record
   number, and return TRUE if there is no error.
  }
end;


procedure TDmxEditBuf.SetState(AState: word; Enable: boolean);
begin
  If Enable and (AState and sfActive <> 0) and (not RecordSelected) and
     Expandable and (CurrentField <> nil) then
    ResetSize;
  TDmxEditor.SetState(AState, Enable);
end;


procedure TDmxEditBuf.SetUpRecord;
begin
  If (NumSlots > 0) then
    RowSlot^[CurrentRecord mod NumSlots].RowNum := EmptySlot;
  TDmxEditor.SetUpRecord;
  RedrawRecord := TRUE;
  Appending    := NewRecord;
end;


procedure TDmxEditBuf.Store(var S: TStream);
begin
  TDmxEditor.Store(S);
  S.Write(KeyFields,  sizeof(KeyFields));
  S.Write(Expandable, sizeof(Expandable));
  S.Write(StepMode,   sizeof(StepMode));
end;


function  TDmxEditBuf.WriteRec(var RecData ) : boolean;
{ abstract virtual method to write a record }
begin
  Abstract;
 { This method should write a record and return TRUE if there is no error. }
end;


function TDmxEditBuf.Valid(Command: word) : boolean;
begin
  If (Command = cmDMX_ZeroizeRecord) and (not RecordSelected) then
    Valid := FALSE
   else
    Valid := TDmxEditor.Valid(Command);
end;


procedure TDmxEditBuf.ZeroizeField(Whole: boolean; Field: pDMXfieldrec);
begin
  TDmxEditor.ZeroizeField(Whole, Field);
  If (Field <> nil) and (Field^.fieldnum in KeyFields) then KeyAltered := TRUE;
end;


procedure TDmxEditBuf.ZeroizeRecord;
var  FS	: boolean;
begin
  If not RecordSelected then Exit;
  TDmxEditor.ZeroizeRecord;
  If Appending then
    begin
    RecordAltered := FALSE;
    FieldAltered  := FALSE;
    If FieldSelected then
      begin
      EvaluateField;
      SetupField;
      end;
    end
   else
    begin
    FS := FieldSelected;
    If FS then EvaluateField;
    Appending := TRUE;
    RecordAltered := FALSE;
    FieldAltered  := FALSE;
    KeyAltered := TRUE;
    DeleteRec;
    EvaluateRecord;
    ResetSize;
    DrawView;
    SetupRecord;
    If FS then SetupField;
    end;
end;


  { ออ TDmxStreamBuf อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TDmxStreamBuf.ErrorFunc : boolean;
{ virtual method to handle stream errors }
begin
  ErrorFunc := TDmxEditBuf.ErrorFunc;
  PStream(WorkingData)^.Reset;
end;


procedure TDmxStreamBuf.LoadStruct(var S: TStream);
begin
  TDmxEditBuf.LoadStruct(S);
  S.Read(PrefixSize, sizeof(PrefixSize));
  Prefix := nil;
end;


function  TDmxStreamBuf.ReadRec(var RecData ) : boolean;
begin
  With PStream(WorkingData)^ do
    begin
    If (Status <> stOk) then Reset;
    Read(RecData, RecordSize);
    ReadRec := (Status = stOk);
    end;
end;


function  TDmxStreamBuf.RecordLimit : longint;
var L : longint;
begin
  If (RecordSize = 0) then
    RecordLimit := 0
   else
    begin
    L := (PStream(WorkingData)^.GetSize - PrefixSize) div RecordSize;
    RecordLimit := L;
    end;
end;


function  TDmxStreamBuf.SeekEnd : boolean;
var  L : longint;
begin
  L := RecordLimit;
  PStream(WorkingData)^.Seek(PrefixSize + (L * RecordSize));
  SeekEnd := (PStream(WorkingData)^.Status = stOk);
end;


function  TDmxStreamBuf.SeekRec(RecNum: longint) : boolean;
var  L,L2,RSize : longint;
begin
  PStream(WorkingData)^.Reset;
  L := RecNum;
  RSize := RecordSize;
  L := L * RSize;
  L2 := PrefixSize;
  L := L + L2;
  PStream(WorkingData)^.Seek(L);
  SeekRec := (PStream(WorkingData)^.Status = stOk);
end;


procedure TDmxStreamBuf.StoreStruct(var S: TStream);
begin
  TDmxEditBuf.StoreStruct(S);
  S.Write(PrefixSize, sizeof(PrefixSize));
end;


function  TDmxStreamBuf.WriteRec(var RecData ) : boolean;
begin
  With PStream(WorkingData)^ do
    begin
    If (Status <> stOk) then Reset;
    Write(RecData, RecordSize);
    WriteRec := (Status = stOk);
    end;
end;


  { ออ TDmxExpRecInd อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxExpRecInd.Draw;
var  i	  : integer;
     A,E  : string[80];
     B	  : TDrawBuffer;
     C	  : word;
begin
  If (Link = nil) then
    TView.Draw
   else
    begin
    C := GetColor(6);
    MoveChar(B, 'อ', C, Size.X);
    Str(succ(Link^.CurrentRecord):1, A);
    i := Link^.Limit.Y;
    If PDmxEditBuf(Link)^.Expandable then
      begin
      Dec(i);
      If Link^.CurrentRecord = pred(Link^.Limit.Y) then A := 'Add';
      end;
    Str(i:1, E);
    A := A + '/' + E;
    If length(A) > Size.X then A[0] := chr(length(A) - succ(length(E)));
    If length(A) > Size.X then
      MoveChar(B, showOVERFLOW, C, Size.X)
     else
      begin
      If length(A) < Size.X then A := A + ' ';
      If length(A) < Size.X then A := ' ' + A;
      MoveStr(B[succ((Size.X) - length(A)) shr 1], A, C);
      end;
    WriteBuf(0, 0, Size.X, 1, B);
    end;
end;


  { ออ TDmxExpBuf ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxExpBuf.InitData(var AData );
begin
  TDmxStreamBuf.InitData(AData);
  PrefixSize	:= DataBlockSize;
  Expandable	:= TRUE;
  ResetSize;
end;


  { ออ TDmxBufWin ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxBufWin.InitDMX(ATemplate: string;  var AData;
			     ALabels,ARecInd: PDmxLink;  BSize: longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If (ALabels <> nil) then Inc(R.A.Y, ALabels^.Size.Y);

  Insert(New(PDmxStreamBuf, Init(ATemplate, AData, BSize, R,
				ALabels, ARecInd,
				StandardScrollBar(sbHorizontal+ sbHandleKeyboard),
				StandardScrollBar(sbVertical  + sbHandleKeyboard))));

end;


  { ออ TDmxExpBufWin อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxExpBufWin.InitDMX(ATemplate: string;  var AData;
				ALabels,ARecInd: PDmxLink;  BSize: longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  Inc(R.A.Y, 2);

  DMX := New(PDmxExpBuf, Init(ATemplate, AData, BSize, R,
				ALabels, ARecInd,
				StandardScrollBar(sbHorizontal+ sbHandleKeyboard),
				StandardScrollBar(sbVertical  + sbHandleKeyboard)));

end;


function  TDmxExpBufWin.NewRecInd(Len: integer) : PDmxLink;
begin
  If Len <= 0 then
    NewRecInd := nil
   else
    NewRecInd := New(PDmxExpRecInd, InitInsert(@Self, Len));
end;


  { ออ TDmxEditRecBuf ออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TDmxEditRecBuf.AppendRec(var RecData ) : boolean;
{ abstract virtual method to write a record }
begin
  Abstract;
 { This method must append a record and return TRUE if there is no error. }
end;


function  TDmxEditRecBuf.FirstRec : boolean;
{ pseudo-abstract method to seek to the first record position }
begin
 { This method should be overridden to seek directly to the
   first record, and it should return TRUE if there is no error.
   The default method just repeats PrevRec() until it receives
   an error.
  }
  Repeat until not PrevRec;
  FirstRec := TRUE;
end;


procedure TDmxEditRecBuf.InitData(var AData );
begin
  TDmxEditBuf.InitData(AData);
  StepMode := TRUE;
end;


function  TDmxEditRecBuf.LastRec : boolean;
{ abstract virtual method to seek to the last record position }
begin
  Abstract;
 { This method must be overridden to seek to the last record
   position, and it should return TRUE if there is no error.
  }
end;


function  TDmxEditRecBuf.NextRec : boolean;
{ abstract virtual method to seek to the next record position }
begin
  Abstract;
 { This method must be overridden to seek to the next record
   position, and it should return TRUE if there is no error.
  }
end;


function  TDmxEditRecBuf.PrevRec : boolean;
{ abstract virtual method to seek to the previous record position }
begin
 { This method must be overridden to seek to the previous record
   position, and it should return TRUE if there is no error.
  }
end;


function  TDmxEditRecBuf.SeekEnd : boolean;
begin
  SeekEnd := TRUE;
end;


function  TDmxEditRecBuf.SeekRec(RecNum: longint) : boolean;
{ uses FirstRec(), LastRec(), NextRec() and PrevRec() to seek to a record }
var  B	    : boolean;
     EndNum : longint;
    function  LastRecord : boolean;
    begin
      If (RecordSize = 0) then
	begin
	EndNum := 0;
	LastRecord := FALSE;
	end
       else
	begin
	EndNum := (DataBlockSize div RecordSize) - 1;
	If Expandable then Dec(EndNum);
	LastRecord := (RecNum = EndNum);
	end;
    end;
begin
  B := TRUE;
  If (RecNum = 0) then
    begin
    B := FirstRec;
    RecPosition := 0;
    end
   else
    If LastRecord then
      begin
      B := LastRec;
      RecPosition := EndNum;
      end
     else
      begin
      While (RecPosition < RecNum) and B do
	begin
	B := NextRec;
	If B then Inc(RecPosition);
	end;
      While (RecPosition > RecNum) and B do
	begin
	B := PrevRec;
	If B then Dec(RecPosition);
	end;
      end;
  SeekRec := B;
end;


function  TDmxEditRecBuf.UpdateRec(var RecData ) : boolean;
{ abstract virtual method to update the current record }
begin
  Abstract;
 { This method must write a record and return TRUE if there is no error. }
end;


function  TDmxEditRecBuf.WriteRec(var RecData ) : boolean;
{ virtual method to write a record }
begin
  If Appending then
    begin
    KeyAltered := (KeyFields <>[]);
    WriteRec := AppendRec(RecData);
    end
   else
    WriteRec := UpdateRec(RecData);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure RegisterTVDMXBUF;
begin
  RegisterType(RDmxStreamBuf);
  RegisterType(RDmxExpBuf);
  RegisterType(RDmxExpRecInd);
  RegisterType(RDmxBufWin);
  RegisterType(RDmxExpBufWin);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }



End.
