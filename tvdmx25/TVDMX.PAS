
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	tvDMX	--data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,93	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Unit tvDMX;

{$B-,D+,O+,R-,V-,X+ }

interface

uses  Objects, Drivers, Views, Dialogs, App, RSet, DmxGizma;

var
    DrawingRecNum  :  integer;

type
    PDmxLink	   = ^TDmxLink;
    PDmxLabels	   = ^TDmxLabels;
    PDmxExtLabels  = ^TDmxExtLabels;
    PDmxFLabels    = ^TDmxFLabels;
    PDmxMLabels    = ^TDmxMLabels;
    PDmxScroller   = ^TDmxScroller;
    PDmxRecInd	   = ^TDmxRecInd;
    PDmxEditor	   = ^TDmxEditor;


    TDmxLink	=  OBJECT(TView)
	Link	: PDmxScroller;
      constructor Init(var Bounds: TRect);
      constructor Load(var S: TStream);
      function	GetPalette : PPalette;	VIRTUAL;
      procedure Insert(AOwner: PGroup);
      procedure Store(var S: TStream);
      procedure SetState(AState: word;  Enable: boolean);  VIRTUAL;
    end;


    TDmxExtLabels  =  OBJECT(TDmxLink)
	Len	: integer;
	Data	: PCharArray;
	Heaped	: boolean;
	DblBar	: boolean;
      constructor Init(ALen: integer; AData: PCharArray; var Bounds: TRect);
      constructor InitInsert(AOwner: PGroup; ALen: integer; AData: PCharArray);
      destructor  Done;  VIRTUAL;
      constructor Load(var S: TStream);
      procedure Store(var S: TStream);
      procedure Draw;  VIRTUAL;
      procedure DrawRuler(Upper, AtLimit: boolean);
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure SetState(AState: word;  Enable: boolean);  VIRTUAL;
    end;


    TDmxLabels	=  OBJECT(TDmxExtLabels)
      constructor Init(DataStr: pstring; var Bounds: TRect);
      constructor InitInsert(AOwner: PGroup;  DataStr: pstring);
    end;


    TDmxFLabels  =  OBJECT(TDmxExtLabels)
      constructor Init(LabelStr: string;  var Bounds: TRect);
      constructor InitInsert(AOwner: PGroup;  LabelStr: string);
    end;


    TDmxMLabels  =  OBJECT(TDmxExtLabels)
      constructor Init(Labels: PSItem;  var Bounds: TRect);
      constructor InitInsert(AOwner: PGroup;  Labels: PSItem);
    end;


    TDmxScroller =  OBJECT(TScroller)
	Labels		: PDmxLink;
	WorkingData	: pointer;
	ActualRecordNum	: longint;
	DataBlockSize	: longint;
	BaseRecord	: longint;
	CurrentRecord	: integer;
	CurrentField	: pDMXfieldrec;
	DMXfield1	: pDMXfieldrec;
	LeftField	: pDMXfieldrec;
	TotalFields	: integer;
	RecordSize	: integer;
	Locked		: boolean;
	InitValid	: boolean;
      constructor Init(ATemplate: string; var AData; BSize: longint;
		var Bounds: TRect;  ALabels: PView;  AHScrollBar,AVScrollBar: PScrollBar);
      procedure   InitStruct(var ATemplate );  VIRTUAL;
      procedure   InitData(var AData );  VIRTUAL;
      destructor  Done;  VIRTUAL;
      constructor Load(var S: TStream);
      procedure Store(var S: TStream);
      procedure ChangeBounds(var Bounds: TRect);  VIRTUAL;
      function	DataAt(RecNum: integer) : pointer;  VIRTUAL;
      procedure DoneData;  VIRTUAL;
      procedure DoneStruct;  VIRTUAL;
      procedure Draw;  VIRTUAL;
      procedure DrawRecord(Y: integer;  var DataRecord );
      procedure FieldText(var S: string;  var Color: word;
			  Field: pDMXfieldrec;  var DataRec );  VIRTUAL;
      procedure GetData(var Rec );  VIRTUAL;
      function	GetPalette  : PPalette;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure LoadData(var S: TStream);  VIRTUAL;
      procedure LoadStruct(var S: TStream);  VIRTUAL;
      function	RecNumStr(RecNum: integer) : string;  VIRTUAL;
      function	RecordLimit : longint;	VIRTUAL;
      procedure ScrollDraw;  VIRTUAL;
      procedure SetData(var Rec );  VIRTUAL;
      procedure SetState(AState: word;  Enable: boolean);  VIRTUAL;
      procedure StoreData(var S: TStream);  VIRTUAL;
      procedure StoreStruct(var S: TStream);  VIRTUAL;
      function	Valid(Command: word) : boolean;  VIRTUAL;
      procedure WrongKeypressed(var Event: TEvent);  VIRTUAL;
      private
	InBuffer	: boolean;
	DDelta,DSize	: TPoint;
	FirstRow	: integer;
    end;


    TDmxRecInd	 =  OBJECT(TDmxLink)
      constructor Init(var Bounds: TRect;  Len: integer);
      constructor InitInsert(AOwner: PGroup; Len: integer);
      procedure Draw;  VIRTUAL;
      procedure SetState(AState: word; Enable: boolean);  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
    end;


    TDmxEditor	 =  OBJECT(TDmxScroller)
	RecInd		: PDmxLink;
	FieldData	: pointer;
	RecordData	: pointer;
	CurPos		: integer;
	Vidis		: boolean;
	DoubleValid	: boolean;
	FirstKey	: boolean;
	RedrawRecord	: boolean;
	DrawingField	: boolean;
	FieldAltered	: boolean;
	RecordAltered	: boolean;
	JustAltered	: boolean;
	DataAltered	: boolean;
	FieldSelected	: boolean;
	RecordSelected	: boolean;
	RecWasLocked	: boolean;
	LockChecked	: boolean;
	ShowFmt		: showset;
      constructor Init(ATemplate: string;  var AData; BSize: longint;
			var Bounds: TRect;  ALabels,ARecInd: PDmxLink;
			AHScrollBar,AVScrollBar: PScrollBar);
      constructor Load(var S: TStream);
      destructor  Done;  VIRTUAL;
      procedure Store(var S: TStream);
      procedure ChangeBounds(var Bounds: TRect);  VIRTUAL;
      procedure ChangeMade;
      function	CheckRecLock : boolean;
      procedure ClearRecLock;
      procedure Draw;  VIRTUAL;
      procedure DrawField(var Field: pDMXfieldrec);
      procedure EvaluateField;	VIRTUAL;
      procedure EvaluateRecord;  VIRTUAL;
      procedure GetBlob(Num: integer; var Blob: pointer; var Len: integer);
      procedure GotoPos(AFieldNum,ARecNum: integer);
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure ProcessCommand(var Command: word;  XY: TPoint);
      procedure ProcessKey(var Event: TEvent);
      procedure ProcessMouse(var Event: TEvent);
      procedure ResetRecLock;  VIRTUAL;
      procedure ScrollDraw;  VIRTUAL;
      function	SetRecLock : boolean;  VIRTUAL;
      procedure SetState(AState: word;  Enable: boolean);  VIRTUAL;
      procedure SetUpField;  VIRTUAL;
      procedure SetUpRecord;  VIRTUAL;
      function	Valid(Command: word) : boolean;  VIRTUAL;
      procedure ZeroizeField(Whole: boolean; Field: pDMXfieldrec);  VIRTUAL;
      procedure ZeroizeRecord;	VIRTUAL;
      private
	FirstPos	: integer;
      procedure ProcessEnter(var Event: TEvent);
    end;


const
    RDmxExtLabels :  TStreamRec = (
	ObjType:  rnDmxExtLabels;
	VmtLink:  ofs(TypeOf(TDmxExtLabels)^);
	Load:	  @TDmxExtLabels.Load;
	Store:	  @TDmxExtLabels.Store
      );

    RDmxLabels	:  TStreamRec = (
	ObjType:  rnDmxLabels;
	VmtLink:  ofs(TypeOf(TDmxLabels)^);
	Load:	  @TDmxLabels.Load;
	Store:	  @TDmxLabels.Store
      );

    RDmxFLabels	:  TStreamRec = (
	ObjType:  rnDmxFLabels;
	VmtLink:  ofs(TypeOf(TDmxFLabels)^);
	Load:	  @TDmxFLabels.Load;
	Store:	  @TDmxFLabels.Store
      );

    RDmxMLabels	:  TStreamRec = (
	ObjType:  rnDmxMLabels;
	VmtLink:  ofs(TypeOf(TDmxMLabels)^);
	Load:	  @TDmxMLabels.Load;
	Store:	  @TDmxMLabels.Store
      );

    RDmxRecInd	:  TStreamRec = (
	ObjType:  rnDmxRecInd;
	VmtLink:  ofs(TypeOf(TDmxRecInd)^);
	Load:	  @TDmxRecInd.Load;
	Store:	  @TDmxRecInd.Store
      );

    RDmxScroller :  TStreamRec = (
	ObjType:  rnDmxScroller;
	VmtLink:  ofs(TypeOf(TDmxScroller)^);
	Load:	  @TDmxScroller.Load;
	Store:	  @TDmxScroller.Store
      );

    RDmxEditor	:  TStreamRec = (
	ObjType:  rnDmxEditor;
	VmtLink:  ofs(TypeOf(TDmxEditor)^);
	Load:	  @TDmxEditor.Load;
	Store:	  @TDmxEditor.Store
      );


  procedure RegisterTVDMX;


implementation

const	NewestDMX	: PDmxScroller	= nil;
	NowScrolling	: boolean	= FALSE;

var	FirstField	: pDMXfieldrec;
	Clusters	: array [0..127] of RECORD
		fnum	:  byte;
		value	:  byte;
		ofs	:  word;
	end;



  { ออ TDmxLink ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxLink.Init(var Bounds: TRect);
begin
  TView.Init(Bounds);
  GrowMode  := gfGrowLoY or gfGrowHiY;
  EventMask := evMessage or evMouseDown;
  NewestDMX := Link;
end;


constructor TDmxLink.Load(var S: TStream);
begin
  TView.Load(S);
  GetPeerViewPtr(S, Link);
end;


function  TDmxLink.GetPalette : PPalette;
const  P : string[length(cDMX)] = cDMX;
begin
  GetPalette := @P
end;


procedure TDmxLink.Insert(AOwner: PGroup);
begin
  If (AOwner <> nil) then AOwner^.Insert(@Self);
end;


procedure TDmxLink.SetState(AState: word; Enable: boolean);
begin
  TView.SetState(AState, Enable);
  If Enable and (AState and sfExposed <> 0) then
    begin
    If (Link = nil) then Link := Message(Owner, evCommand, cmDMX_RollCall, @Self);
    If (Link <> nil) and (Link^.State and sfExposed = 0) then
      begin
      Link^.PutInFrontOf(@Self);
      Link^.SetState(sfExposed, TRUE);
      end;
    end;
end;


procedure TDmxLink.Store(var S: TStream);
begin
  TView.Store(S);
  PutPeerViewPtr(S, Link);
end;


  { ออ TDmxExtLabels อออออออออออออออออออออออออออออออออออออออออออออออออออออ }

const  Clicked : PDmxLink = nil;


constructor TDmxExtLabels.Init(ALen: integer; AData: PCharArray; var Bounds: TRect);
begin
  TDmxLink.Init(Bounds);
  Data	:= AData;
  Len	:= ALen;
end;


constructor TDmxExtLabels.InitInsert(AOwner: PGroup; ALen: integer; AData: PCharArray);
var  R : TRect;
begin
  AOwner^.GetExtent(R);
  Inc(R.A.Y);
  R.B.Y  := R.A.Y + 2;
  R.Grow(-1, 0);
  TDmxLink.Init(R);
  Data := AData;
  Len  := ALen;
  Insert(AOwner);
end;


destructor TDmxExtLabels.Done;
begin
  If Heaped and (Data <> nil) and (Len > 0) then FreeMem(Data, Len);
  TDmxLink.Done;
end;


constructor TDmxExtLabels.Load(var S: TStream);
begin
  TDmxLink.Load(S);
  S.Read(Len, sizeof(Len));
  If Len > 0 then
    begin
    GetMem(Data, Len);
    S.Read(Data^, Len);
    Heaped := TRUE;
    end
   else
    Data := nil;
  S.Read(DblBar,  sizeof(DblBar));
end;


procedure TDmxExtLabels.Store(var S: TStream);
begin
  TDmxLink.Store(S);
  S.Write(Len, sizeof(Len));
  If Len > 0 then S.Write(Data^, Len);
  S.Write(DblBar,  sizeof(DblBar));
end;


procedure TDmxExtLabels.Draw;
var  i	: integer;
     A	: string;
     B	: TDrawBuffer;
begin
  If (Link = nil) or (Link^.Delta.X >= Len) then
    fillchar(A[1], Size.X, ' ')
   else
    begin
    Move(Data^[Link^.Delta.X], A[1], Size.X);
    If (Link^.Delta.X + Size.X > Len) then
      fillchar(A[succ(Len - Link^.Delta.X)],(Size.X + Link^.Delta.X - Len), ' ');
    end;
  A[0] := chr(lo(Size.X));
  MoveStr(B, A, GetColor(1));
  If (Link^.Origin.Y <= Origin.Y) then i := pred(Size.Y) else i := 0;
  WriteLine(0, i, Size.X, 1, B);
  If (Size.Y > 1) then DrawRuler((i = 0), DblBar);
end;


procedure TDmxExtLabels.DrawRuler(Upper, AtLimit: boolean);
const
  LtArr		=  17;
  RtArr		=  16;
  Markers	: string[10] = 'ฤอยัาหมฯะส';
var
  Color		: word;
  i,X,width	: integer;
  Mk		: integer;
  frontcut	: integer;
  fieldrec	: pDMXfieldrec;
  A		: string;
  B		: TDrawBuffer;
begin
  If (longint(Size) = 0) or (Link = nil) or (Link^.DMXfield1 = nil) then Exit;
  fieldrec  := Link^.LeftField;
  If (fieldrec = nil) or (fieldrec^.screentab > Link^.Delta.X) then
    fieldrec := Link^.DMXfield1;
  If (fieldrec^.Next <> nil) then
    While (fieldrec^.Next^.screentab <= Link^.Delta.X) and
	  (fieldrec^.Next <> nil)
     do
      fieldrec := fieldrec^.Next;
  frontcut  := Link^.Delta.X - fieldrec^.screentab;
  If frontcut < 0 then frontcut := 0;
  X := 0;
  If (Clicked = @Self) then Color := GetColor(6) else Color := GetColor(5);
  If AtLimit then Mk := 2 else Mk := 1;
  MoveChar(B, Markers[Mk], Color, Size.X);
  Inc(Mk, 2);
  If not Upper then Inc(Mk, 4);
  If (Clicked <> @Self) then While (X < Size.X) do
    begin
    With fieldrec^ do
      begin
      If (access and accHidden = 0) then
	begin
	If access and accDelimiter <> 0 then
	  begin
	  If fieldrec^.typecode = 'บ' then char(B[X]) := Markers[Mk + 2]
	   else If fieldrec^.typecode = 'ณ' then char(B[X]) := Markers[Mk];
	  Inc(X);
	  end
	 else
	  begin
	  X := X + shownwid - frontcut;
	  end;
	frontcut := 0;
	end;
      end;
    fieldrec := fieldrec^.Next;
    If (fieldrec = nil) and (Size.X > X) then X := Size.X;
    end;
  If Upper then i := pred(Size.Y) else i := 0;
  WriteLine(0, i, Size.X, succ(i), B);
end;


procedure TDmxExtLabels.HandleEvent(var Event: TEvent);
var  dX,dY  : integer;
     Cmd    : word;
     db	    : boolean;
begin
  TDmxLink.HandleEvent(Event);
  With Event do
    If (What and evMouseDown <> 0) then
      begin
      If (Link = nil) then Exit;
      If (Link^.State and sfSelected = 0) then
	Link^.Select
       else
	begin
	Repeat
	  Clicked := @Self;
	  db := DblBar;
	  DblBar := TRUE;
	  DrawView;
	  If (Link^.Origin.Y <= Origin.Y) then Cmd := cmDMX_Down else Cmd := cmDMX_Up;
	  Message(Link, evCommand, Cmd, @Self);
	  Application^.Idle;
	  Clicked := nil;
	  DblBar := db;
	  DrawView;
	Until not MouseEvent(Event, evMouseDown or evMouseAuto);
	end;
      ClearEvent(Event);
      end
    else
    If (What and evMessage <> 0) then
      begin
      If (Command = cmDMX_ScrollBarChanged) then
	begin
	If (InfoPtr = Link) then DrawView;
	end
      else
      If (Command = cmDMX_FixSize) and (Size.X > Len)
	and (Link <> nil) and (Link^.Labels = @Self) then
	begin
	dX := (Owner^.Size.X - Size.X) + Len;
	dY :=  Owner^.Size.Y;
	Owner^.GrowTo(dX, dY);
	end;
      end;
end;


procedure TDmxExtLabels.SetState(AState: word; Enable: boolean);
var  L : longint;
begin
  TDmxLink.SetState(AState, Enable);
  If Enable and (AState and sfExposed <> 0) and (Link <> nil) then
    begin
    If (Link^.Origin.Y <= Origin.Y) then
      GrowMode := gfGrowHiX or gfGrowLoY or gfGrowHiY
     else
      GrowMode := gfGrowHiX;
    end;
end;


  { ออ TDmxLabels ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxLabels.Init(DataStr: pstring;	var Bounds: TRect);
begin
  TDmxLink.Init(Bounds);
  Move(DataStr, Data, sizeof(Data));
  Len := length(DataStr^);
  Inc(PtrRec(Data).Ofs);
end;


constructor TDmxLabels.InitInsert(AOwner: PGroup;  DataStr: pstring);
var  R : TRect;
begin
  AOwner^.GetExtent(R);
  Inc(R.A.Y);
  R.B.Y := R.A.Y + 2;
  R.Grow(-1, 0);
  TDmxLink.Init(R);
  Move(DataStr, Data, sizeof(Data));
  Len := length(DataStr^);
  Inc(PtrRec(Data).Ofs);
  Insert(AOwner);
end;


  { ออ TDmxFLabels อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxFLabels.Init(LabelStr: string;  var Bounds: TRect);
begin
  TDmxLink.Init(Bounds);
  Len := length(LabelStr);
  If (Len > 0) then
    begin
    GetMem(Data, Len);
    Move(LabelStr[1], Data^, Len);
    Heaped := TRUE;
    end;
end;


constructor TDmxFLabels.InitInsert(AOwner: PGroup;  LabelStr: string);
var  R : TRect;
begin
  AOwner^.GetExtent(R);
  Inc(R.A.Y);
  R.B.Y := R.A.Y + 2;
  R.Grow(-1, 0);
  TDmxFLabels.Init(LabelStr, R);
  Insert(AOwner);
end;


  { ออ TDmxMLabels อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxMLabels.Init(Labels: PSItem;  var Bounds: TRect);
var  i : integer;
begin
  TDmxLink.Init(Bounds);
  Len := SItemsLen(Labels);
  If (Len > 0) then
    begin
    GetMem(Data, Len);
    i := 0;
    While (Labels <> nil) do
      begin
      If (Labels^.Value <> nil) then
	begin
	Move(Labels^.Value^[1], Data^[i], length(Labels^.Value^));
	Inc(i, length(Labels^.Value^));
	end;
      Labels := Labels^.Next;
      end;
    Heaped := TRUE;
    end;
end;


constructor TDmxMLabels.InitInsert(AOwner: PGroup;  Labels: PSItem);
var  R : TRect;
begin
  AOwner^.GetExtent(R);
  Inc(R.A.Y);
  R.B.Y := R.A.Y + 2;
  R.Grow(-1, 0);
  TDmxMLabels.Init(Labels, R);
  Insert(AOwner);
end;


  { ออ TDmxScroller ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxScroller.Init(ATemplate: string;  var AData;
			      BSize: longint;  var Bounds: TRect;
			      ALabels: PView;
			      AHScrollBar,AVScrollBar: PScrollBar);
var  L : longint;
begin
  TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  FillChar(Clusters, sizeof(Clusters), 0);
  NewestDMX	:= @Self;
  Labels	:= PDmxLink(ALabels);
  If Labels <> nil then Labels^.Link := @Self;
  InitValid	:= TRUE;
  DataBlockSize	:= BSize;
  WorkingData	:= @AData;
  Limit.X	:= 0;
  InitStruct(ATemplate);
  InitData(AData);
  If (RecordSize > 0) then
    begin
    L := RecordSize;
    L := DataBlockSize div L;
    SetLimit(Limit.X, L);
    end;
  LeftField := DMXfield1;
  GrowMode  := gfGrowHiX or gfGrowHiY;
end;


destructor TDmxScroller.Done;
begin
  If (NewestDMX = @Self) then NewestDMX := nil;
  DoneData;
  DoneStruct;
  TScroller.Done;
end;


constructor TDmxScroller.Load(var S: TStream);
begin
  TScroller.Load(S);
  InitValid := TRUE;
  GetPeerViewPtr(S, Labels);
  S.Read(TotalFields, sizeof(TotalFields));
  S.Read(RecordSize,  sizeof(RecordSize));
  S.Read(ActualRecordNum, sizeof(ActualRecordNum));
  S.Read(CurrentRecord, sizeof(CurrentRecord));
  S.Read(BaseRecord,	sizeof(BaseRecord));
  S.Read(DataBlockSize, sizeof(DataBlockSize));
  InBuffer  := FALSE;
  LoadData(S);
  LoadStruct(S);
end;


procedure TDmxScroller.Store(var S: TStream);
begin
  TScroller.Store(S);
  PutPeerViewPtr(S, Labels);
  S.Write(TotalFields, sizeof(TotalFields));
  S.Write(RecordSize,  sizeof(RecordSize));
  S.Write(ActualRecordNum, sizeof(ActualRecordNum));
  S.Write(CurrentRecord, sizeof(CurrentRecord));
  S.Write(BaseRecord,	 sizeof(BaseRecord));
  S.Write(DataBlockSize, sizeof(DataBlockSize));
  StoreData(S);
  StoreStruct(S);
end;


procedure TDmxScroller.ChangeBounds(var Bounds: TRect);
begin
  InBuffer := FALSE;
  TScroller.ChangeBounds(Bounds);
end;


function  TDmxScroller.DataAt(RecNum: integer) : pointer;
begin
  DataAt := ptr(PtrRec(WorkingData).Seg, PtrRec(WorkingData).Ofs + RecNum * RecordSize);
end;


procedure TDmxScroller.DoneData;
begin
end;


procedure TDmxScroller.DoneStruct;
var  P : pDMXfieldrec;
begin
  While (DMXfield1 <> nil) do
    begin
    P := DMXfield1^.Next;
    If DMXfield1^.template <> nil then
      begin
      If (upcase(DMXfield1^.typecode) = fldENUM) then
	DisposeSItems(PSItem(DMXfield1^.template))
       else
	DisposeStr(DMXfield1^.template);
      end;
    Dispose(DMXfield1);
    DMXfield1 := P;
    end;
  LeftField	:= nil;
end;


var  EmptyRecord : byte;


procedure TDmxScroller.Draw;
var
  i,rows,Y,owid  :  integer;
  A   :  string;
  B   :  TDrawBuffer;
  Buf : ^TDrawBuffer;
begin
  HideCursor;
  rows := Size.Y;
  Y    := -1;
  FirstField := nil;
  If (Owner^.Buffer <> nil) and InBuffer then
    begin
    If (Delta.X = DDelta.X) and (abs(Delta.Y - DDelta.Y) = 1) and
       (Size.Y > 1) and (longint(Size) = longint(DSize))
     then  { use part of the owner's buffer if this is a 1 line scroll }
      begin
      owid := Owner^.Size.X shl 1;
      longint(Buf) := longint(Owner^.Buffer) + ((Origin.Y * owid) + (Origin.X shl 1));
      If (Delta.Y > DDelta.Y) then  { Down }
	begin
	For i := 0 to(Size.Y - 2) do
	  begin
	  ptrrec(Buf).ofs := ptrrec(Buf).ofs + owid;
	  WriteBuf(0, i, Size.X, 1, Buf^);
	  end;
	Y := Size.Y - 2;
	end
       else  { Up }
	begin
	ptrrec(Buf).ofs := ptrrec(Buf).ofs + ((Size.Y - 2) * owid);
	For i := (Size.Y - 1) downto 1 do
	  begin
	  WriteBuf(0, i, Size.X, 1, Buf^);
	  ptrrec(Buf).ofs := ptrrec(Buf).ofs - owid;
	  end;
	Rows := 1;
	end;
      end;
    end;
  If rows > 0 then
    begin
    While (Y < pred(rows)) do
      begin
      Inc(Y);
      DrawingRecNum := Y + Delta.Y;
      If Y + Delta.Y < Limit.Y then
	DrawRecord(Y, DataAt(DrawingRecNum)^)
       else
	DrawRecord(Y, EmptyRecord);
      end;
    end;
  DDelta   := Delta;
  DSize    := Size;
  InBuffer := (Owner^.Buffer <> nil);
  If NowScrolling then
    begin
    Message(Owner, evBroadcast, cmDMX_ScrollBarChanged, @Self);
    NowScrolling := FALSE;
    end;
end;


procedure TDmxScroller.DrawRecord(Y: integer;	var DataRecord );
var Color		: word;
    ColorA, ColorB	: word;
    I,X, width		: integer;
    frontcut		: integer;
    fieldrec		: pDMXfieldrec;
    A			: string;
    B			: TDrawBuffer;
begin
  If (FirstField <> DMXfield1) then
    begin
    FirstField := DMXfield1;
    LeftField  := DMXfield1;
    While (LeftField^.Next <> nil) and
	  (LeftField^.Next^.screentab <= Delta.X)
     do
      LeftField := LeftField^.Next;
    end;
  If (LeftField = nil) then Exit;
  fieldrec := LeftField;
  frontcut := Delta.X - fieldrec^.screentab;
  X	   := 0;
  ColorA   := GetColor(1);
  ColorB   := GetColor(5);
  While (X < Size.X) do
    begin
    With fieldrec^ do
      begin
      If (access and accHidden = 0) then
	begin
	If access and accDelimiter <> 0 then
	  begin
	  A	:= typecode;
	  Color := ColorB;
	  end
	 else
	  begin
	  If (@DataRecord = @EmptyRecord) then
	    begin
	    A[0] := chr(fieldrec^.shownwid);
	    fillchar(A[1], fieldrec^.shownwid, ' ');
	    end
	   else
	    A	:= FieldString(fieldrec,[], DataRecord);
	  If fieldsize > 0 then Color := ColorA else Color := ColorB;
	  FieldText(A, Color, fieldrec, DataRecord);
	  If length(A) > shownwid then A[0] := chr(shownwid);
	  If frontcut > 0 then Delete(A, 1, frontcut);
	  end;
	frontcut := 0;
	MoveStr(B[X], A, Color);
	X  := X + length(A);
	end;
      end;
    fieldrec := fieldrec^.Next;
    If (fieldrec = nil) and (Size.X > X) then
      begin
      MoveChar(B[X], ' ', ColorB, Size.X - X);
      X  := Size.X;
      end;
    end;
  WriteLine(0, Y, Size.X, 1, B);
end;


procedure TDmxScroller.FieldText(var S: string;  var Color: word;
				 Field: pDMXfieldrec;  var DataRec );
begin
end;


procedure TDmxScroller.GetData(var Rec );
begin
  pointer(Rec) := WorkingData
end;


function  TDmxScroller.GetPalette : PPalette;
const  P : string[length(cDMX)] = cDMX;
begin
  GetPalette := @P
end;


procedure TDmxScroller.HandleEvent(var Event: TEvent);
var  WasHere : boolean;
begin
  TScroller.HandleEvent(Event);
  With Event do
    If (What and evMessage <> 0) then
      begin
      WasHere := TRUE;
      If (Command = cmDMX_RollCall) then
	begin
	If (InfoPtr <> nil) and (InfoPtr <> @Self) then
	  Message(InfoPtr, evCommand, cmDMX_Ack, @Self);
	end
      else
      If (((Command = cmDMX_DrawData) and (WorkingData = InfoPtr)) or
	  ((Command = cmDMX_Draw) and
	  ((InfoPtr = nil) or (PDmxScroller(InfoPtr)^.WorkingData = WorkingData) or (What = evCommand))))
      then DrawView
      else
      If not Locked and (((Command = cmDMX_LockData) and (WorkingData = InfoPtr)) or
	((Command = cmDMX_Lock) and
	((InfoPtr = nil) or (PDmxScroller(InfoPtr)^.WorkingData = WorkingData) or (What = evCommand))))
      then Locked := TRUE
      else
      If Locked and (((Command = cmDMX_UnlockData) and (WorkingData = InfoPtr)) or
	((Command = cmDMX_Unlock) and
	((InfoPtr = nil) or (PDmxScroller(InfoPtr)^.WorkingData = WorkingData) or (What = evCommand))))
      then Locked := FALSE
      else
	WasHere := FALSE;
      If WasHere and (What = evCommand) then ClearEvent(Event);
      end;
end;


procedure TDmxScroller.InitData(var AData );
begin
  WorkingData := @AData;
end;


procedure TDmxScroller.InitStruct(var ATemplate );
var
  SameFieldNum	:  boolean;
  WasSameNum	:  boolean;
  NoFieldNum	:  boolean;
  NoFieldAdv	:  boolean;
  AllZeroes	:  boolean;
  C		:  char;
  DoDecimal	:  integer;
  Rex,X		:  pDMXfieldrec;
  templx	:  string;

  procedure NewRecord;
  var i,j : integer;
      A   : pstring;
  begin
    If not InitValid then Exit;
    With Rex^ do
      begin
      If DoDecimal > 0 then Rex^.decimals := pred(DoDecimal);
      DoDecimal := 0;
      If (fieldsize = 0) then
	access := access or accSkip
       else
	If not NoFieldAdv then
	  begin
	  If not NoFieldNum then
	    If SameFieldNum then
	      fieldnum := succ(TotalFields)
	     else
	      If TRUE or (access and accHidden = 0) or WasSameNum then
		begin
		Inc(TotalFields);
		fieldnum := TotalFields;
		end;
	  datatab    := RecordSize;
	  RecordSize := RecordSize + fieldsize;
	  end;
      screentab  := Limit.X;
      If (typecode = fldBOOLEAN) and (truelen = 0) then showzeroes := FALSE;
      If (upcase(typecode) = fldENUM) then
	begin
	columnwid := truelen;
	end
       else
	begin
	If (columnwid = 0) then columnwid := length(templx);
	If (length(templx) > 0) or (template <> nil) then
	  begin
	  If (MaxAvail > length(templx)) then
	    template  := NewStr(templx)
	   else
	    InitValid := FALSE;
	  end
	 else
	  begin
	  If (typecode <> #0) and (access and accHidden = 0) then Inc(Limit.X);
	  end;
	end;
      If (shownwid = 0) then shownwid := columnwid;
      If access and accHidden = 0 then Limit.X := Limit.X + shownwid;
      end;
    templx := '';
    If (MaxAvail > sizeof(Rex^)) then
      begin
      New(Rex^.Next);
      X   := Rex;
      Rex := Rex^.Next;
      fillchar(Rex^, sizeof(Rex^), 0);
      Rex^.Prev := X;
      Rex^.Next := nil;
      Rex^.showzeroes := AllZeroes;
      end
     else
      InitValid := FALSE;
    WasSameNum := FALSE;
    NoFieldNum := FALSE;
    NoFieldAdv := FALSE;
  end;

  procedure TranslateStruct(dataformat: pstring);
  var  df   : pstring;
       i,j  : integer;
       TS   : PSItem;
  begin
    SameFieldNum := FALSE;
    WasSameNum	 := FALSE;
    NoFieldNum	 := FALSE;
    NoFieldAdv	 := FALSE;
    DoDecimal :=  0;
    i := 1;
    While (i <= length(dataformat^)) do
      begin
      C := upcase(dataformat^[i]);
      Case C of
	fldSTR, fldSTRNUM:
	  With Rex^ do
	    begin
	    templx   := templx + #0;
	    typecode := dataformat^[i];
	    Inc(truelen);
	    If fieldsize > 0 then
	      Inc(fieldsize)
	     else
	      begin
	      fieldsize :=  2;
	      fillvalue := ' ';
	      end;
	    end;
	fldCHAR, fldCHARVAL, fldCHARNUM:
	  With Rex^ do
	    begin
	    templx    := templx + #0;
	    typecode  := dataformat^[i];
	    Inc(truelen);
	    Inc(fieldsize);
	    fillvalue := ' ';
	    If DoDecimal > 0 then Inc(DoDecimal);
	    end;
	fldBYTE, fldSHORTINT, fldBOOLEAN:
	  With Rex^ do
	    begin
	    templx    := templx + #0;
	    If upcase(C) <> fldSHORTINT then C := upcase(C);
	    typecode  := dataformat^[i];
	    Inc(truelen);
	    fieldsize := sizeof(BYTE);
	    fillvalue := #0;
	    end;
	^X :
	  With Rex^ do
	    begin
	    typecode  := fldBOOLEAN;
	    truelen   := 0;
	    fieldsize := sizeof(BOOLEAN);
	    fillvalue := #0;
	    end;
	fldZEROMOD:  { 'Z' }
	  With Rex^ do
	    begin
	    If (typecode = #0) or (typecode = fldCHARVAL) then Inc(fieldsize);
	    templx := templx + #1;
	    Inc(truelen);
	    If DoDecimal > 0 then Inc(DoDecimal);
	    end;
	fldWORD, fldINTEGER:
	  With Rex^ do
	    begin
	    templx    := templx + #0;
	    typecode  := dataformat^[i];
	    Inc(truelen);
	    fieldsize := sizeof(INTEGER);
	    fillvalue := #0;
	    end;
	fldLONGINT:
	  With Rex^ do
	    begin
	    templx    := templx + #0;
	    typecode  := dataformat^[i];
	    Inc(truelen);
	    fieldsize := sizeof(LONGINT);
	    fillvalue := #0;
	    end;
	fldHEXVALUE:
	  With Rex^ do
	    begin
	    templx    := templx + #0;
	    typecode  := dataformat^[i];
	    Inc(truelen);
	    fieldsize := succ(truelen) shr 1;
	    fillvalue := #0;
	    end;
	fldREALNUM:
	  With Rex^ do
	    begin
	    templx    := templx + #0;
	    typecode  := dataformat^[i];
	    Inc(truelen);
	    fieldsize := sizeof(TREALNUM);
	    fillvalue := #0;
	    If DoDecimal > 0 then Inc(DoDecimal);
	    end;
	fldENUM:
	  begin
	  If (templx <> '') then NewRecord;
	  Move(dataformat^[succ(i)], Rex^.template, sizeof(Rex^.template));
	  Rex^.typecode	  := fldENUM;
	  Rex^.truelen	  := MaxItemStrLen(PSItem(Rex^.template));
	  Rex^.fieldsize  := sizeof(BYTE);
	  Rex^.showzeroes := boolean(dataformat^[i+5]);
	  Rex^.access	  := byte(dataformat^[i+6]);
	  Rex^.fillvalue  := dataformat^[i+7];
	  Inc(i, sizeof(DmxIDstr) - 2);
	  NewRecord;
	  end;
	fldCLUSTER:
	  begin
	  Rex^.typecode  := dataformat^[i];
	  Rex^.fieldsize := SizeOfFldCluster;
	  Inc(i);
	  j := ord(dataformat^[i]);
	  If (Clusters[j].fnum = 0) then
	    begin
	    Clusters[j].fnum := succ(TotalFields);
	    Clusters[j].ofs  := RecordSize;
	    end
	   else
	    begin
	    Inc(Clusters[j].value);
	    Rex^.fieldnum := Clusters[j].fnum;
	    Rex^.decimals := Clusters[j].value;
	    Rex^.datatab  := Clusters[j].ofs;
	    NoFieldNum := TRUE;
	    NoFieldAdv := TRUE;
	    end;
	  Rex^.fieldnum := Clusters[j].fnum;
	  templx := templx + #0;
	  Inc(Rex^.truelen);
	  end;
	fldBLOB:
	  begin
	  If (templx <> '') then NewRecord;
	  Rex^.typecode	 := fldBLOB;
	  Move(dataformat^[succ(i)], Rex^.fieldsize, sizeof(Rex^.fieldsize));
	  Move(dataformat^[i+1], Rex^.fieldsize, sizeof(Rex^.fieldsize));
	  Rex^.access	 := byte(dataformat^[i+6]) or accHidden;
	  Rex^.fillvalue := dataformat^[i+7];
	  Inc(i, sizeof(DmxIDstr) - 2);
	  NewRecord;
	  end;
	#27:  { [Esc] }
	  begin
	  Inc(i);
	  If (templx <> '') then NewRecord;
	  Case dataformat^[i] of
	    fldXFIELDNUM:
	      begin
	      TotalFields := ord(dataformat^[succ(i)]) - 1;
	      Inc(i);
	      end;
	    fldXSPACES, fldXTABTO:
	      begin
	      If (dataformat^[i] = fldXSPACES) then
		Rex^.truelen := ord(dataformat^[i+2])
	       else
		If (ord(dataformat^[i+2]) > Limit.X) then
		  Rex^.truelen := Limit.X - ord(dataformat^[i+2]);
	      If (Rex^.truelen > 0) then
		begin
		Rex^.typecode  := #27;
		Rex^.fillvalue := dataformat^[i+1];
		Rex^.shownwid  := Rex^.truelen;
		Inc(i, 3);
		NewRecord;
		end;
	      end;
	    end;
	  end;
	fldAPPEND:
	  begin
	  If (templx <> '') then NewRecord;
	  Move(dataformat^[succ(i)], df, sizeof(df));
	  TranslateStruct(df);
	  Inc(i, sizeof(DmxIDstr) - 2);
	  end;
	fldSITEMS:
	  begin
	  If (templx <> '') then NewRecord;
	  Move(dataformat^[succ(i)], TS, sizeof(TS));
	  While (TS <> nil) do
	    begin
	    If (TS^.Value <> nil) then TranslateStruct(TS^.Value);
	    TS := TS^.Next;
	    end;
	  Inc(i, sizeof(DmxIDstr) - 2);
	  end;
	')','.':
	  With Rex^ do
	    begin
	    templx := templx + C;
	    If (upcase(Rex^.typecode) = fldCHARVAL) then
	      begin
	      If (C = ')') then Inc(truelen);
	      Inc(fieldsize);
	      end;
	    If (C = '.') then
	      begin
	      If (upcase(typecode) = fldREALNUM) or
		 (upcase(typecode) = fldCHARVAL) then
		DoDecimal := 1;
	      end
	     else
	      parenthesis := TRUE;
	    end;
	'~':
	  begin
	  Inc(i);
	  While (dataformat^[i] <> '~') and (i <= length(dataformat^)) do
	    begin
	    C := dataformat^[i];
	    If C = #0 then C := ' ';
	    If C = #1 then C := #2;
	    templx := templx + C;
	    Inc(i);
	    end;
	  end;
	#0,'\','|','ณ','บ':
	  begin
	  If (templx <> '') then NewRecord;
	  If C <> #0 then
	    begin
	    If C = '|' then C := 'ณ' else If C = '\' then C := ' ';
	    Rex^.access    := Rex^.access or accDelimiter;
	    Rex^.typecode  := C;
	    NewRecord;
	    end;
	  end;
	^A:
	  begin
	  AllZeroes	:= not AllZeroes;
	  Rex^.showzeroes := AllZeroes;
	  end;
	^C:
	  begin
	  Inc(i);
	  Rex^.access := Rex^.access or ord(dataformat^[i]);
	  end;
	^D:
	  begin
	  If (templx <> '') then NewRecord;
	  Inc(i);
	  C := dataformat^[i];
	  Rex^.access	 := Rex^.access or accDelimiter;
	  Rex^.typecode  := C;
	  NewRecord;
	  end;
	^F:
	  begin
	  If (i < length(dataformat^)) and (dataformat^[i+1] = ^F) then
	    begin
	    NoFieldNum := TRUE;
	    Inc(i);
	    end
	   else
	    begin
	    WasSameNum	 := SameFieldNum;
	    SameFieldNum := not SameFieldNum;
	    end;
	  end;
	^H:   With Rex^ do access := access or accHidden;
	^P:   With Rex^ do
		begin
		Inc(i);
		RecordSize := RecordSize + shortint(dataformat^[i]);
		end;
	^R:   With Rex^ do access := access or accReadOnly;
	^S:   With Rex^ do access := access or accSkip;
	^U:   With Rex^ do
		begin
		Inc(i);
		upperlimit := byte(dataformat^[i]);
		end;
	^V:   With Rex^ do
		begin
		Inc(i);
		fillvalue := dataformat^[i];
		end;
	^Z:   Rex^.showzeroes := TRUE;
	fldCONTRACTION:   With Rex^ do shownwid := length(templx);
       else
	  begin
	  templx := templx + dataformat^[i];
	  end;
	end;  { case of C }
      Inc(i);
      end;
  end;

begin
  If (@ATemplate = nil) then Exit;
  AllZeroes := FALSE;
  templx    := '';
  New(Rex);
  fillchar(Rex^, sizeof(Rex^), 0);
  Rex^.Next := nil;
  Rex^.Prev := nil;
  Rex^.showzeroes := AllZeroes;
  X := nil;
  If DMXfield1 = nil then
    DMXfield1 := Rex
   else
    begin
    X := DMXfield1;
    While X^.Next <> nil do X := X^.Next;
    X^.Next := Rex;
    Rex^.Prev := X;
    end;
  TranslateStruct(@ATemplate);
  SameFieldNum := FALSE;
  If templx <> '' then NewRecord;
  If (Rex = DMXfield1) then DMXfield1 := nil;
  Dispose(Rex);
  If (X <> nil) then X^.Next := nil;
  If DMXfield1 <> nil then DMXfield1^.Prev := X;
end;


procedure TDmxScroller.LoadData(var S: TStream);
begin
end;


procedure TDmxScroller.LoadStruct(var S: TStream);
var n	 : integer;
    P,Px : pDMXfieldrec;
begin
  DMXfield1 := nil;
  S.Read(n, sizeof(n));
  Px := nil;
  While (n > 0) do
    begin
    GetMem(P, sizeof(P^));
    S.Read(P^, sizeof(P^));
    If (P^.template <> nil) then
      begin
      If upcase(P^.typecode) = fldENUM then
	P^.template := pstring(ReadSItems(S))
       else
	P^.template := S.ReadStr;
      end;
    If DMXfield1 = nil then DMXfield1 := P;
    If Px <> nil then Px^.Next := P;
    P^.Prev := Px;
    P^.Next := nil;
    Px	    := P;
    Dec(n);
    end;
  LeftField := DMXfield1;
  If DMXfield1 <> nil then DMXfield1^.Prev := P;
end;


function  TDmxScroller.RecNumStr(RecNum: integer) : string;
var  S : string;
begin
  If (RecNum >= RecordLimit) then
    RecNumStr := '      '
   else
    begin
    Str(succ(RecNum):5, S);
    RecNumStr := S + ' ';
    end;
end;


function  TDmxScroller.RecordLimit : longint;
var  RecSize: longint;
begin
  RecSize := RecordSize;
  If (RecordSize > 0) then
    RecordLimit := (DataBlockSize div RecSize)
   else
    RecordLimit := 0;
end;


procedure TDmxScroller.ScrollDraw;
begin
  NowScrolling := ((HScrollBar <> nil) and (HScrollBar^.Value <> Delta.X)) or
		  ((VScrollBar <> nil) and (VScrollBar^.Value <> Delta.Y));
  TScroller.ScrollDraw;
end;


procedure TDmxScroller.SetData(var Rec );
begin
  WorkingData := pointer(Rec)
end;


procedure TDmxScroller.SetState(AState: word; Enable: boolean);
var  L1,L2 : longint;
begin
  If (AState and sfActive <> 0) then
    begin
    If Enable then
      begin
      If (RecordSize > 0) then
	begin
	L1 := RecordSize;
	L2 := L1 * Limit.Y;
	L1 := DataBlockSize - (DataBlockSize mod L1);
	If (L1 <> L2) then
	  begin
	  L1 := RecordSize;
	  L1 := DataBlockSize div L1;
	  If (Limit.Y <> L1) then SetLimit(Limit.X, L1);
	  end;
	end;
      end;
    end;
  If (AState and sfFocused <> 0) and (Application <> nil) then
    begin
    If Enable then
      TScroller.SetState(sfCursorIns, Application^.GetState(sfCursorIns))
     else
      Application^.SetState(sfCursorIns, GetState(sfCursorIns));
    end;
  TScroller.SetState(AState, Enable);
end;


procedure TDmxScroller.StoreData(var S: TStream);
begin
end;


procedure TDmxScroller.StoreStruct(var S: TStream);
var  n : integer;
     P : pDMXfieldrec;
begin
  n  := 0;
  P  := DMXfield1;
  While (P <> nil) do
    begin
    Inc(n);
    P := P^.Next;
    end;
  S.Write(n, sizeof(n));
  P := DMXfield1;
  While (P <> nil) do
    begin
    S.Write(P^, sizeof(P^));
    If (P^.template <> nil) then
      begin
      If upcase(P^.typecode) = fldENUM then
	WriteSItems(S, PSItem(P^.template))
       else
	S.WriteStr(P^.template);
      end;
    P := P^.Next;
    end;
end;


function  TDmxScroller.Valid(Command: word) : boolean;
var  V : boolean;
begin
  V := TScroller.Valid(Command);
  If (Command = cmValid) then V := V and InitValid;
  Valid := V;
end;


procedure TDmxScroller.WrongKeypressed(var Event: TEvent);
begin
  Message(Application, evCommand, cmDMX_WrongKey, @Self);
end;


  { ออ TDmxRecInd ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxRecInd.Init(var Bounds: TRect;  Len: integer);
begin
  TDmxLink.Init(Bounds);
  GrowMode  := gfGrowLoY or gfGrowHiY;
end;


constructor TDmxRecInd.InitInsert(AOwner: PGroup; Len: integer);
var  R : TRect;
begin
  AOwner^.GetExtent(R);
  Inc(R.A.X);
  R.A.Y  := pred(R.B.Y);
  R.Grow(-1, 0);
  If (R.B.X - R.A.X > Len) then R.B.X := R.A.X + Len;
  R.B.Y  := succ(R.A.Y);
  TDmxLink.Init(R);
  GrowMode  := gfGrowLoY or gfGrowHiY;
  Insert(AOwner);
end;


procedure TDmxRecInd.Draw;
var  A	: string;
     B	: TDrawBuffer;
     C	: word;
begin
  C := GetColor(6);
  MoveChar(B, 'อ', C, Size.X);
  Str(succ(Link^.CurrentRecord):1, A);
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


procedure TDmxRecInd.HandleEvent(var Event: TEvent);
begin
  TDmxLink.HandleEvent(Event);
  With Event do
    begin
    If (What and evMouseDown <> 0) then
      begin
      Message(Application, evCommand, cmDMX_RecIndClicked, @Self);
      ClearEvent(Event);
      end;
    end;
end;


procedure TDmxRecInd.SetState(AState: word;  Enable: boolean);
begin
  If (AState and (sfActive or sfDragging) <> 0) then
    TDmxLink.SetState(sfVisible, Enable xor (AState and sfDragging <> 0));
  TDmxLink.SetState(AState, Enable);
end;


  { ออ TDmxEditor อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxEditor.Init(ATemplate: string;  var AData;  BSize: longint;
			    var Bounds: TRect;  ALabels,ARecInd: PDmxLink;
			    AHScrollBar,AVScrollBar: PScrollBar);
var  inbounds  : TRect;
begin
  TDmxScroller.Init(ATemplate, AData, BSize, Bounds, ALabels, AHScrollBar, AVScrollBar);
  CurrentField := DMXfield1;
  While (CurrentField <> nil) and
	(CurrentField^.access and (accHidden or accSkip or accDelimiter) <> 0)
   do
    CurrentField := CurrentField^.Next;
  CurrentRecord  := 0;
  RecInd := ARecInd;
  If RecInd <> nil then
    begin
    RecInd^.Link := @Self;
    If (HScrollBar <> nil) then
      begin
      HScrollBar^.GetBounds(inbounds);
      inbounds.A.X := inbounds.A.X + RecInd^.Size.X + 1;
      HScrollBar^.Locate(inbounds);
      end;
    end;
end;


constructor TDmxEditor.Load(var S: TStream);
var  i,n : integer;
begin
  TDmxScroller.Load(S);
  GetPeerViewPtr(S, RecInd);
  CurrentField := DMXfield1;
  S.Read(n, sizeof(n));
  i := 0;
  While (i <> n) and (CurrentField <> nil) do
    begin
    CurrentField := CurrentField^.Next;
    Inc(i);
    end;
  If CurrentField = nil then CurrentField := DMXfield1;
  S.Read(Locked, sizeof(Locked));
end;


destructor TDmxEditor.Done;
begin
  If FieldSelected and (CurrentField <> nil) then EvaluateField;
  If RecordSelected then EvaluateRecord;
  TDmxScroller.Done;
end;


procedure TDmxEditor.Store(var S: TStream);
var n  : integer;
    df : pDMXfieldrec;
begin
  TDmxScroller.Store(S);
  PutPeerViewPtr(S, RecInd);
  df := DMXfield1;
  n  := 0;
  While (df <> CurrentField) do
    begin
    df := df^.Next;
    Inc(n);
    end;
  S.Write(n, sizeof(n));
  S.Write(Locked, sizeof(Locked));
end;


procedure TDmxEditor.ChangeBounds(var Bounds: TRect);
var  i,j	: integer;
     ReScroll	: boolean;
     RS,FS	: boolean;
     xy		: TPoint;
begin
  RS := RecordSelected;
  FS := FieldSelected;
  If FS then EvaluateField;
  If RS then EvaluateRecord;
  TDmxScroller.ChangeBounds(Bounds);
  ReScroll := FALSE;
  If CurrentField <> nil then With CurrentField^ do
    If (template <> nil) then
      begin
      xy := Delta;
      If (Size.X - (screentab - Delta.X) < 0) or
	 (Size.X <= shownwid) then
	begin
	xy.X  := screentab + shownwid - Size.X;
	If (Size.X <= shownwid) then xy.X := screentab else If (xy.X > 0) then Inc(xy.X);
	ReScroll := TRUE;
	end
       else
	If (Size.X - (screentab + shownwid - Delta.X) < 0) then
	  begin
	  xy.X	:= screentab + shownwid - Size.X;
	  ReScroll := TRUE;
	  end;
      end;
    If (Size.Y - (CurrentRecord - Delta.Y) <= 0) then
      begin
      xy.Y := succ(CurrentRecord - Size.Y);
      If xy.Y < 0 then xy.Y := 0;
      ReScroll := TRUE;
      end;
  If ReScroll then ScrollTo(xy.X, xy.Y);
  If RS then SetupRecord;
  If FS then SetupField;
end;


procedure TDmxEditor.ChangeMade;
begin
  FieldAltered	:= TRUE;
  RecordAltered := TRUE;
  JustAltered	:= TRUE;
  DataAltered	:= TRUE;
end;


function  TDmxEditor.CheckRecLock : boolean;
begin
  If not LockChecked then
    begin
    RecWasLocked := not SetRecLock;
    LockChecked  := TRUE;
    end;
  CheckRecLock := not RecWasLocked;
end;


procedure TDmxEditor.ClearRecLock;
begin
  If LockChecked then
    begin
    If not RecWasLocked then ResetRecLock;
    LockChecked := FALSE;
    end;
  RecWasLocked := FALSE;
end;


procedure TDmxEditor.Draw;
begin
  If (Owner <> nil) then
    begin
    Owner^.Lock;
    TDmxScroller.Draw;
    If (FieldSelected and (showanyway in ShowFmt)) or
       (RecordSelected and (showCurrentField in ShowFmt)
	and (CurrentRecord < Limit.Y))
     then
      DrawField(CurrentField);
    Owner^.Unlock;
    end;
end;


procedure TDmxEditor.DrawField(var Field: pDMXfieldrec);
const
  rpoint = #16;
  lpoint = #17;
var
  Color  : word;
  i,j,k  : integer;
  x1,x2  : integer;
  Len	 : integer;
  front  : boolean;
  hyde	 : boolean;
  S	 : string;
  B	 : TDrawBuffer;
begin
  If (Field = nil) then Exit;
  DrawingRecNum := CurrentRecord;
  If RedrawRecord then
    begin
    If (RecordData <> nil) then DrawRecord(CurrentRecord-Delta.Y, RecordData^);
    RedrawRecord := FALSE;
    end;
  DrawingField := (showanyway in ShowFmt) or (showCurrentField in ShowFmt);
  hyde := TRUE;
  With Field^ do If (truelen > 0) or ((template <> nil) and (shownwid > 0)) then
    begin
    If (access and (accHidden or accDelimiter) = 0) then
      begin
      If (showanyway in ShowFmt) then CurrentCurPos := CurPos;
      S  := FieldString(Field, ShowFmt, RecordData^);
      x1 := screentab - Delta.X;
      x2 := x1 + length(S);
      If x1 < 0 then
	begin
	x1 := 0;
	front := FALSE;
	end
       else
	front := TRUE;
      If x2 - x1 > shownwid then x2 := x1 + shownwid;
      If x2 > Size.X then x2 := Size.X;
      Len  := x2 - x1;
      If Len > 0 then
	begin
	If not (showregular in ShowFmt) and FieldSelected then
	  begin
	  If (access and accReadOnly <> 0) then
	    Color := GetColor(3)
	   else
	    If Locked or RecWasLocked then
	      Color := GetColor(4)
	     else
	      begin
	      hyde := FALSE;
	      Color := GetColor(2);
	      end;
	  If hyde and (Color = GetColor(1)) then Color := Color or $80;
	  FieldText(S, Color, Field, RecordData^);
	  j := 0;
	  k := 0;
	  If (fieldsize > 0) then
	    begin
	    If (upcase(typecode) = fldENUM) then
	      begin
	      For i := length(S) downto 1 do If (S[i] <> ' ') then k := i;
	      end
	     else
	      For i := 1 to length(S) do
		If (ord(template^[i]) and $FE = 0) then
		  begin
		  If (CurPos >= j) then k := i;
		  Inc(j);
		  end;
	    end;
	  If k > 0 then
	    begin
	    If CurPos = 0 then FirstPos := 0;
	    If (CurPos = truelen) and (length(S) > Len) then
	      FirstPos := length(S) - Len;
	    If length(S) <= Len then
	      begin
	      FirstPos := 0;
	      end
	     else
	      begin
	      If pred(k) <= FirstPos then
		begin
		FirstPos := pred(k);
		If FirstPos > 0 then
		  begin
		  Delete(S, 1,FirstPos);
		  k := k - FirstPos;
		  end;
		end
	       else
		begin
		j := 0;
		If FirstPos > 0 then
		  begin
		  Delete(S, 1,FirstPos);
		  k := k - FirstPos;
		  j := FirstPos;
		  end;
		If length(S) > Len then
		  begin
		  If k > Len then
		    begin
		    i := k - Len;
		    FirstPos := i + j;
		    If i > 0 then Delete(S, 1, i);
		    k := k - i;
		    end;
		  end;
		end;
	      end;
	    If Len > 3 then
	      begin
	      If (k = Len) and (length(S) > Len) then
		begin
		Delete(S, 1,1);
		Inc(FirstPos);
		Dec(k);
		end;
	      If (FirstPos > 0) then
		begin
		If k > 1 then S[1] := lpoint
		 else
		  begin
		  System.Insert(lpoint, S, 1);
		  Inc(k);
		  Inc(FirstPos);
		  end;
		end;
	      If length(S) > Len then S[Len] := rpoint;
	      end;
	    SetCursor(pred(k) + x1, CurrentRecord - Delta.Y);
	    end;
	  end
	 else
	  begin
	  If DrawingField and RecordSelected and not FieldSelected and
	     (showCurrentField in ShowFmt) and (CurrentField = Field) then
	    Color := GetColor(6)
	   else
	    Color := GetColor(1);
	  FieldText(S, Color, Field, RecordData^);
	  If (length(S) > Len) and not front then Delete(S, 1, length(S) - Len);
	  end;
	MoveStr(B, S, Color);
	i := CurrentRecord - Delta.Y;
	WriteLine(x1, i, Len, 1, B);
	end;
      end;
    end;
  If hyde or (k = 0) then HideCursor else ShowCursor;
  DrawingField := FALSE;
end;


procedure TDmxEditor.EvaluateField;
begin
  If FieldAltered then Message(Owner, evBroadcast, cmDMX_FieldAltered, @Self);
  FieldSelected := FALSE;
  ShowFmt   := ShowFmt + [showregular] - [shownegative] - [showanyway];
  DrawField(CurrentField);
  ShowFmt   := ShowFmt - [showregular];
end;


procedure TDmxEditor.EvaluateRecord;
begin
  ClearRecLock;
  RecordSelected := FALSE;
  DrawRecord(CurrentRecord - Delta.Y, RecordData^);
end;


procedure TDmxEditor.GetBlob(Num: integer; var Blob: pointer; var Len: integer);
var  i	 : integer;
     Fld : pDMXfieldrec;
begin
  Blob := nil;
  Len  := 0;
  If (Num <= 0) then Exit;
  i    := 0;
  Fld  := DMXfield1;
  While (i < Num) do
    begin
    While (Fld <> nil) and (Fld^.typecode <> fldBLOB) do Fld := Fld^.Next;
    Inc(i);
    end;
  If (Fld <> nil) then
    begin
    Blob := RecordData;
    Inc(word(Blob), Fld^.datatab);
    Len  := Fld^.fieldsize;
    end;
end;


procedure TDmxEditor.GotoPos(AFieldNum,ARecNum: integer);
var X,Y	  : integer;
    RS,FS : boolean;
    F	  : pDMXfieldrec;
begin
  RS := RecordSelected;
  If RS then
    begin
    FS := FieldSelected;
    If FS then EvaluateField;
    If (CurrentRecord = ARecNum) then RS := FALSE;
    If RS then EvaluateRecord;
    end
   else
    FS := FALSE;
  CurrentRecord := ARecNum;
  If not RecordSelected then
    begin
    Y := CurrentRecord - (Size.Y shr 1);
    If (Y < 0) then Y := 0;
    end
   else
    Y := Delta.Y;
  F := DMXfield1;
  While (F <> nil) and (F^.fieldnum <> AFieldNum) do F := F^.Next;
  If (F = nil) or (AFieldNum = 0) then
    X := Delta.X
   else
    begin
    X := F^.screentab;
    CurrentField := F;
    end;
  If (X > Limit.X) then X := Limit.X;
  If (Y > Limit.Y) then Y := Limit.Y;
  ScrollTo(X, Y);
  If RS then SetupRecord;
  If FS then SetupField;
end;


procedure TDmxEditor.HandleEvent(var Event: TEvent);
var  XY	: TPoint;
     Cmd: word;
     RS,FS : boolean;
    function  OK4Command : boolean;
    begin
      With Event do
	OK4Command := (What = evCommand) or (InfoPtr = nil) or
	  ((PDmxScroller(InfoPtr)^.WorkingData = WorkingData));
    end;
begin
  RS := FALSE;
  FS := FALSE;
  With Event do
    begin
    If not GetState(sfDragging) then
      begin
      If (What = evKeyDown) and (CharCode in [^M,^T,^Y]) then
	begin
	Case CharCode of
	  ^M:	Cmd := cmDMX_Enter;
	  ^Y:	Cmd := cmDMX_ZeroizeRecord;
	 else	Cmd := cmDMX_ZeroizeField;
	  end;
	Message(TopView, evCommand, Cmd, @Self);
	ClearEvent(Event);
	end;
      Case What of
	evNothing:   begin end;
	evMouseDown: ProcessMouse(Event);
	evKeyDown:
	    If (KeyCode <> kbEsc) and (Size.Y > 0) and (What = evKeyDown) then
	      ProcessKey(Event);
	evCommand:
	    If (Command = cmDMX_DoubleClick) and (InfoPtr = @Self) then
	      begin
	      Case upcase(CurrentField^.typecode) of
		fldBOOLEAN:  Message(@Self, evKeyDown, ord('_'), @Self);
		fldENUM:     Message(@Self, evKeyDown, kbGrayPlus, @Self);
		end;
	      end
	    else
	    If (Command >= cmDMX_ZeroizeField) and (Command <= cmDMX_Bottom)
		and Valid(Command)
	    then
	      begin
	      If Command = cmDMX_Enter then ProcessEnter(Event);
	      If (Command <> 0) then
		begin
		Move(InfoPtr, XY, sizeof(XY));
		ProcessCommand(Command, XY);
		end;
	      If (Command = 0) then ClearEvent(Event);
	      end;
	end;
      end;
    If (What and evMessage <> 0) then
      If ((Command = cmDMX_DrawData) and (WorkingData = InfoPtr)) or
	 ((Command = cmDMX_LockData) and (WorkingData = InfoPtr)) or
	 ((Command = cmDMX_UnlockData) and (WorkingData = InfoPtr)) or
	 ((Command = cmDMX_Draw) and OK4Command) or
	 ((Command = cmDMX_Lock) and OK4Command) or
	 ((Command = cmDMX_Unlock) and OK4Command)
       then
	begin
	RS := RecordSelected;
	If RS then
	  begin
	  FS := FieldSelected;
	  If FS then EvaluateField;
	  EvaluateRecord;
	  end;
	end;
    end;
  If (Event.What <> evNothing) then
    begin
    If (Event.What = evKeyDown) and ((Size.X <= 0) or (Size.Y <= 0)) then
      TView.HandleEvent(Event) else TDmxScroller.HandleEvent(Event);
    end;
  If RS then
    begin
    SetupRecord;
    If FS then SetupField;
    end;
end;


procedure TDmxEditor.ProcessCommand(var Command: word;  XY: TPoint);
var
  i,j	: word;
  xx,yy : integer;
  DoIt	: integer;
  F	: pDMXfieldrec;
  RS,FS,Chg : boolean;

    procedure DoHome;
    begin
      F := DMXfield1;
      If F <> nil then
	begin
	While (F^.access and (accHidden or accSkip or accDelimiter) <> 0)
	  and (F^.Next <> nil)
	 do
	  F := F^.Next;
	CurrentField := F;
	end;
      If CurrentField <> nil then With CurrentField^ do
	begin
	xx := 0;
	If (screentab + shownwid - 1 > Size.X) then xx := screentab;
	end;
    end;

begin
  RS	:= RecordSelected;
  FS	:= FieldSelected;
  If (Command = cmDMX_ZeroizeField) then
    begin
    If FS then Chg := TRUE else Exit;
    end
   else
    Chg	:= FALSE;
  DoIt	:=  0;
  xx	:= Delta.X;
  yy	:= Delta.Y;
  If (Command >= cmDMX_Enter) and (Command <= cmDMX_Bottom) then
    begin
    If FS then EvaluateField;
    DoIt  :=  1;
    If (Command > cmDMX_goto) then
      begin
      If RS then EvaluateRecord;
      DoIt  :=	2;
      end;
    end;
  If ReDrawRecord then
    begin
    DrawingRecNum := CurrentRecord;
    DrawRecord(CurrentRecord - Delta.Y, RecordData^);
    ReDrawRecord := FALSE;
    end;

  Case Command of

    cmDMX_ZeroizeField:
	begin
	If FieldSelected then
	  begin
	  EvaluateField;
	  SetupField;
	  end;
	ZeroizeField(TRUE, CurrentField);
	end;

    cmDMX_ZeroizeRecord:
	begin
	If FieldSelected then
	  begin
	  EvaluateField;
	  SetupField;
	  end;
	ZeroizeRecord;
	end;

    cmDMX_Left:
	If CurrentField <> DMXfield1 then
	  begin
	  F := CurrentField^.Prev;
	  While (F <> nil) and (F^.access and (accHidden or accSkip or accDelimiter) <> 0)
	   do
	    begin
	    If F = DMXfield1 then F := nil else F := F^.Prev;
	    end;
	  If F <> nil then CurrentField := F;
	  If CurrentField <> nil then With CurrentField^ do
	    begin
	    If (screentab < xx) then
	      begin
	      xx := screentab;
	      If (xx > 0) and (Size.X > shownwid) then Dec(xx);
	      end;
	    end;
	  end;

    cmDMX_Right:
	begin
	F := CurrentField^.Next;
	While (F <> nil) and (F^.access and (accHidden or accSkip or accDelimiter) <> 0)
	 do F := F^.Next;
	If F <> nil then CurrentField := F;
	If CurrentField <> nil then With CurrentField^ do
	  begin
	  If (screentab + shownwid - 1 > xx + pred(Size.X)) then
	    begin
	    xx := screentab + shownwid - Size.X;
	    If (xx < Limit.X) and (Size.X > shownwid) then Inc(xx);
	    end;
	  end;
	end;

    cmDMX_Home:  DoHome;

    cmDMX_End:
	begin
	F := CurrentField;
	If F <> nil then
	  begin
	  While (F^.Next <> nil) do F := F^.Next;
	  While (F^.access and (accHidden or accSkip or accDelimiter) <> 0)
	    and (F^.Prev <> nil)
	   do
	    F := F^.Prev;
	  CurrentField := F;
	  xx := Limit.X;
	  With CurrentField^ do
	    If (screentab < xx) then
	      begin
	      xx := screentab;
	      If (xx > 0) and (Size.X > shownwid) then Dec(xx);
	      end;
	  end;
	end;

    cmDMX_goto:
	begin
	F := CurrentField;
	DoubleValid := FALSE;
	If F <> nil then
	  begin
	  While (F <> nil) and ((F^.access and accHidden <> 0) or (F^.screentab < XY.x))
	     and (F^.Next <> nil)
	   do F := F^.Next;
	  If (F <> nil) then
	    begin
	    While (F <> nil) and ((F^.access and accHidden <> 0) or (F^.screentab > XY.x))
	     do F := F^.Prev;
	    DoubleValid := (F^.fieldsize <> 0);
	    If (XY.x > Delta.X + (Size.X shr 1)) then
	      begin
	      While (F <> nil) and (F^.fieldsize = 0) do F := F^.Next;
	      end
	     else
	      While (F <> nil) and (F <> DMXfield1) and (F^.fieldsize = 0) do
		F := F^.Prev;
	    If (F <> nil) and (F^.access and (accDelimiter or accSkip) = 0) then
	      begin
	      With F^ do
		begin
		If (screentab < xx) then
		  begin
		  xx := screentab;
		  If (xx > 0) and (Size.X > shownwid) then Dec(xx);
		  end
		 else
		  begin
		  If (screentab + shownwid - 1 > xx + pred(Size.X)) then
		    begin
		    xx := screentab + shownwid - Size.X;
		    If (xx < Limit.X) and (Size.X > shownwid) then Inc(xx);
		    end;
		  end;
		end;
	      If (CurrentRecord = XY.y) then
		CurrentField := F
	       else
		begin
		If RS then EvaluateRecord;
		DoIt  :=  2;
		If ReDrawRecord then
		  begin
		  DrawingRecNum := CurrentRecord;
		  DrawRecord(CurrentRecord - Delta.Y, RecordData^);
		  ReDrawRecord := FALSE;
		  end;
		CurrentField  :=  F;
		CurrentRecord := XY.y;
		If CurrentRecord >= Limit.Y then CurrentRecord := pred(Limit.Y);
		end;
	      end
	     else DoubleValid := FALSE;
	    end;
	  end;
	end;

    cmDMX_NextRow:
	begin
	If succ(CurrentRecord) < Limit.Y then
	  begin
	  Inc(CurrentRecord);
	  If yy + Size.Y <= CurrentRecord then
	    yy := CurrentRecord - Size.Y + 1;
	  If yy < 0 then yy := 0;
	  end;
	DoHome;
	end;

    cmDMX_Up:
	begin
	If CurrentRecord > 0 then
	  begin
	  Dec(CurrentRecord);
	  If yy > CurrentRecord then yy := CurrentRecord;
	  end;
	end;

    cmDMX_Down:
	begin
	If succ(CurrentRecord) < Limit.Y then
	  begin
	  Inc(CurrentRecord);
	  If yy + Size.Y <= CurrentRecord then
	    yy := CurrentRecord - Size.Y + 1;
	  If yy < 0 then yy := 0;
	  end;
	end;

    cmDMX_PgUp:
	begin
	CurrentRecord := CurrentRecord - Size.Y + 1;
	If CurrentRecord < 0 then CurrentRecord := 0;
	yy := FirstRow - Size.Y + 1;
	If yy < 0 then
	  begin
	  yy := 0;
	  CurrentRecord := 0;
	  end;
	end;

    cmDMX_PgDn:
	begin
	CurrentRecord := CurrentRecord + Size.Y - 1;
	If CurrentRecord >= Limit.Y then
	  CurrentRecord := pred(Limit.Y);
	If CurrentRecord < 0 then CurrentRecord := 0;
	yy := FirstRow + Size.Y - 1;
	If yy < 0 then
	  begin
	  yy := 0;
	  CurrentRecord := 0;
	  end;
	If yy > Limit.Y + Size.Y - 1 then yy := Limit.Y + Size.Y - 1;
	end;

    cmDMX_ScreenTop:  CurrentRecord := Delta.Y;

    cmDMX_ScreenBottom:
	begin
	CurrentRecord := Delta.Y + Size.Y - 1;
	If CurrentRecord > Limit.Y then CurrentRecord := pred(Limit.Y);
	end;

    cmDMX_Top:
	begin
	CurrentRecord := 0;
	yy := 0;
	end;

    cmDMX_Bottom:
	begin
	CurrentRecord := pred(Limit.Y);
	If CurrentRecord < 0 then CurrentRecord := 0;
	yy := pred(Limit.Y);
	end;

   else begin  end;

    end;

  If DoIt <> 0 then
    begin
    If (xx <> Delta.X) or (yy <> Delta.Y) then ScrollTo(xx, yy);
    FirstRow := Delta.Y;
    Command := 0;
    If (DoIt > 1) and RS then SetUpRecord;
    If (DoIt > 0) and FS then SetUpField;
    end;
  If Chg then ChangeMade;
  If ReDrawRecord then
    begin
    DrawingRecNum := CurrentRecord;
    DrawField(CurrentField);
    end;
end;


procedure TDmxEditor.ProcessEnter(var Event: TEvent);

    function  NextFieldExists : boolean;
    var  F : pDMXfieldrec;
    begin
      F := CurrentField^.Next;
      While (F <> nil) and
	    (F^.access and (accHidden or accSkip or accDelimiter) <> 0)
       do  F := F^.Next;
      NextFieldExists := (F <> nil);
    end;

begin
  If NextFieldExists then
    Event.Command := cmDMX_Right
   else
    begin
    Event.What := evCommand;
    Event.Command := cmDMX_NextRow;
    HandleEvent(Event);
    ClearEvent(Event);
    end;
end;


procedure TDmxEditor.ProcessKey(var Event: TEvent);
var i,j,k : integer;
    inx   : integer;
    TC	  : char;
    Go	  : boolean;
    InsOn : boolean;
    A	  : string[80];
    DFld  : pDMXfieldrec;

  procedure QuitField(Command: word);
  begin
    Event.What	  := evCommand;
    Event.Command := Command;
    HandleEvent(Event);
    Event.KeyCode := kbNoKey;
    ClearEvent(Event);
  end;

  procedure SetBoolean(B: boolean);
  begin
    pboolean(FieldData)^ := B;
    ChangeMade;
    DrawField(CurrentField);
    If not (Event.CharCode in [^G,^H,'_']) then QuitField(cmDMX_Enter);
  end;

  procedure ToggleCluster(N: integer);
  var  L: longint;
       z: integer;

      function  GetCluster : boolean;
      begin
	With CurrentField^ do
	  If (typecode >= 'a') then
	    GetCluster := (decimals = L)
	   else
	    GetCluster := odd(L shr decimals);
      end;

      procedure SetCluster(On: boolean);
      var  i : integer;
      begin
	With CurrentField^ do
	  begin
	  If (typecode >= 'a') then
	    L := decimals
	   else
	    begin
	    If On then
	      L := L or (1 shl decimals)
	     else
	      L := pword(FieldData)^ and not (1 shl decimals);
	    end;
	  end;
      end;

  begin
    L := 0;
    If (sizeof(L) <= CurrentField^.fieldsize) then
      z := sizeof(L)
     else
      z := CurrentField^.fieldsize;
    Move(FieldData^, L, z);
    Case N of
       1:  SetCluster(TRUE);
      -1:  SetCluster(FALSE);
     else  SetCluster(not GetCluster);
      end;
    Move(L, FieldData^, z);
    ChangeMade;
    If (CurrentField^.typecode >= 'a') and (Owner <> nil) then
      DrawView
     else
      DrawField(CurrentField);
  end;

  function  HexByte(Number: byte) : string;
  const bts  : array[0..15] of char = '0123456789ABCDEF';
  begin
    HexByte := bts[(Number shr 4) and $0F] + bts[Number and $0F]
  end;

  function  EffectField(HEX: boolean;	Min,Max: longint) : boolean;
  var i,j	: integer;
      FirstChar : integer;
      b		: boolean;
      R		: real;
  begin
    b := FALSE;
    If not ((Event.CharCode in [^G,^H,'.','-','_','0'..'9']) or
	   (HEX and (upcase(Event.CharCode) in ['A'..'F'])))
	or (CurrentField^.access and accReadOnly <> 0)
	or (Locked) or (not CheckRecLock)
     then
      begin
      WrongKeypressed(Event);
      end
     else
      If A <> '' then With CurrentField^ do
	begin
	If (upperlimit <> 0) and (Max > upperlimit) then Max := upperlimit;
	If (decimals > 0) then i := succ(truelen) else i := truelen;
	If not HEX and (length(A) > i) then
	  begin
	  A[0] := chr(i);
	  fillchar(A[1], length(A), '0');
	  If length(A) - decimals > 2 then
	    fillchar(A[1], length(A) - decimals - 2, ' ');
	  If decimals > 0 then A[length(A) - decimals] := '.';
	  end;
	If typecode in ['A'..'Z'] then Min := 0;
	FirstChar := pos('.', A);
	If FirstChar > 0 then Dec(FirstChar) else FirstChar := length(A);
	If CurPos < pred(FirstChar) then CurPos := pred(FirstChar);
	Case Event.CharCode of
	  ^G,
	  ^H  :
	      begin
	      If CurPos = pred(FirstChar) then
		begin
		If (FirstChar < length(A)) then
		  fillchar(A[FirstChar + 2], length(A) - succ(FirstChar), '0');
		If FirstChar > 1 then
		  begin
		  Move(A[1], A[2], pred(FirstChar));
		  If HEX then A[1] := '0' else A[1] := ' ';
		  If A[FirstChar] = '-' then
		    begin
		    A[FirstChar] := '0';
		    ShowFmt := ShowFmt - [shownegative];
		    end;
		  end
		 else
		  begin
		  A[1] := '0';
		  end;
		end
	       else
		begin
		A[succ(CurPos)] := '0';
		Dec(CurPos);
		If CurPos = FirstChar then Dec(CurPos);
		end;
	      b := FALSE;
	      For i := 1 to length(A) do If A[i] > '0' then b := TRUE;
	      If not b then ShowFmt := ShowFmt - [shownegative];
	      b := TRUE;
	      If (A[FirstChar] = ' ') then A[FirstChar] := '0';
	      end;
	  '.' :
	      begin
	      If FirstChar < length(A) then
		begin
		CurPos := FirstChar;
		fillchar(A[FirstChar + 2], length(A) - succ(FirstChar), '0');
		b := TRUE;
		end
	       else WrongKeypressed(Event);
	      end;
	  '-','_' :
	      begin
	      If (Min <> 0) and (A[1] = ' ') and
		 (FirstChar > 1) and (pos('-', A) = 0) then
		begin
		i := pred(FirstChar);
		ShowFmt := ShowFmt + [shownegative];
		While (A[i] <> ' ') do Dec(i);
		A[i] := '-';
		b := TRUE;
		end
	       else WrongKeypressed(Event);
	      end;
	 else begin
	      If (shownegative in ShowFmt) and (pos('-',A) = 0) then
		begin
		If A[1] = ' ' then
		  begin
		  i := FirstChar;
		  While (A[i] <> ' ') do Dec(i);
		  If i <> 0 then A[i] := '-';
		  end;
		end;
	      If CurPos = pred(FirstChar) then
		begin
		If A[1] in [' ','0'] then
		  begin
		  If (FirstChar > 1) and not ((A[FirstChar] = '0') and (A[pred(FirstChar)] in ['-',' ']))
		   then Move(A[2], A[1], pred(FirstChar));
		  A[FirstChar] := Event.CharCode;
		  b := TRUE;
		  end;
		end
	       else
		begin
		A[succ(CurPos) + 1] := Event.CharCode;
		If pred(length(A)) > CurPos then Inc(CurPos);
		b := TRUE;
		end;
	      If (Max > 0) then
		begin
		Val(A, R, i);
		If (i <> 0) or (R > Max) or (R < Min) then b := FALSE;
		end
	       else
		begin
		If (TC = fldCHARVAL) and parenthesis and (A[1] > '-') then b := FALSE;
		end;
	      If not b then WrongKeypressed(Event);
	      end;
	  end;
	end;
    If b then
      begin
      ChangeMade;
      end;
    EffectField := b;
  end;

  procedure EditEnumField;
  var  i,j  : integer;
       Pick : PSItem;
       C    : char;

      function	MaxItems : integer;
      var  i	 : integer;
	   Items : PSItem;
      begin
	Items := PSItem(CurrentField^.template);
	i := 0;
	While (Items^.Next <> nil) do
	  begin
	  Items := Items^.Next;
	  inc(i);
	  end;
	MaxItems := i;
      end;

  begin
    If (CurrentField^.access and accReadOnly <> 0)
      or Locked or not CheckRecLock then
      begin
      WrongKeypressed(Event);
      end
     else
      begin
      Event.CharCode := upcase(Event.CharCode);
      Case Event.CharCode of
	^M:   QuitField(cmDMX_Enter);
	'A'..'Z':
	  begin
	  Pick := PSItem(CurrentField^.template);
	  j    := 0;
	  While (Pick <> nil) do
	    begin
	    i :=  1;
	    C := #0;
	    While (Pick^.Value <> nil) and (i < length(Pick^.Value^)) and (C = #0) do
	      begin
	      If (Pick^.Value^[i] in ['A'..'Z']) then C := upcase(Pick^.Value^[i]);
	      Inc(i);
	      end;
	    If (C = Event.CharCode) then
	      begin
	      pbyte(FieldData)^ := j;
	      ChangeMade;
	      Pick := nil;
	      end
	     else
	      begin
	      Inc(j);
	      Pick := Pick^.Next;
	      end;
	    end;
	  end;
	'+','*',' ':
	  begin
	  Inc(pbyte(FieldData)^);
	  If (pbyte(FieldData)^ > MaxItems) then pbyte(FieldData)^ := 0;
	  ChangeMade;
	  end;
	^G, ^H,'-':
	  begin
	  If (pbyte(FieldData)^ = 0) then
	    pbyte(FieldData)^ := MaxItems else Dec(pbyte(FieldData)^);
	  ChangeMade;
	  end;
       else WrongKeypressed(Event);
	end;
      end;
  end;

  function  AnotherView(View: PView) : boolean;  far;
  begin
    AnotherView := (View^.Options and ofSelectable <> 0) and (View <> @Self);
  end;

begin
  If (DataBlockSize < RecordSize) or (RecordSize <= 0) then Exit;
  If (Event.KeyCode = kbTab) or (Event.KeyCode = kbShiftTab) then
    begin
    If (Owner^.FirstThat(@AnotherView) = nil) then
      begin
      If (Event.KeyCode = kbTab) then QuitField(cmDMX_Right) else QuitField(cmDMX_Left);
      end;
    Exit;
    end;
  If Locked or RecWasLocked or (CurrentField^.access and accReadOnly <> 0) then FirstKey := TRUE;
  InsOn		:= not GetState(sfCursorIns);
  Go		:= TRUE;
  If CurrentField = nil then CurrentField := DMXfield1;
  If (Event.What = evKeyDown) then
    begin
    If (Event.KeyCode = kbShiftEnter) then Exit;
    If (Event.KeyCode = kbShiftIns) then Event.CharCode := '0';
    If (Event.KeyCode = kbShiftDel) then Event.CharCode := '.';
    With CurrentField^ do
      begin
      TC := upcase(typecode);
      If (Event.KeyCode = kbEsc) or (Event.KeyCode = kbEnter) then
	begin
	QuitField(cmDMX_Enter);
	end
       else
	begin
	Event.KeyCode := CtrlToArrow(Event.KeyCode);
	If (FirstKey and InsOn) or
	   (Locked or (CurrentField^.access and accReadOnly <> 0)) then
	  begin
	  If Event.KeyCode = kbRight then Event.KeyCode := kbCtrlRight
	  else
	  If Event.KeyCode = kbLeft  then Event.KeyCode := kbCtrlLeft;
	  end
	 else
	  If (TC in [fldSTR,fldSTRNUM,fldCHAR,fldCHARNUM]) then
	    begin
	    If Event.KeyCode = kbRight then Event.CharCode := ^D else
	    If Event.KeyCode = kbLeft  then Event.CharCode := ^S;
	    end;
	If (Event.KeyCode = kbDel) then Event.CharCode := ^G;
	If (Event.CharCode <> #0) then
	  begin
	  If FirstKey
	    and (upcase(Event.CharCode) in ['-','.','0'..'9','A'..'F'])
	    and (access and accReadOnly = 0)
	   then
	    begin
	    If (TC in [fldBYTE, fldSHORTINT, fldWORD, fldINTEGER,
		       fldLONGINT, fldCHARVAL, fldREALNUM, fldHEXVALUE])
	     then ZeroizeField(FALSE, CurrentField);
	    end;
	  Case TC of
	    fldSTR,
	    fldSTRNUM,
	    fldCHAR,
	    fldCHARNUM:
	      begin
	      If typecode < 'a' then Event.CharCode := upcase(Event.CharCode);
	      If ((TC in [fldSTRNUM, fldCHARNUM]) and
		 not (Event.CharCode in [#0..'9'])) or Locked
		  or (access and accReadOnly <> 0)
		  or not CheckRecLock then
		begin
		WrongKeypressed(Event);
		Go  := FALSE;
		end
	       else
		begin
		If TC in [fldSTR, fldSTRNUM] then inx := 1 else inx := 0;
		Case Event.CharCode of
		  ^G,	{ kbDel }
		  ^H:	{ kbBack }
		    begin
		    If Event.CharCode = ^H then
		      begin
		      If CurPos = 0 then Go := FALSE else Dec(CurPos);
		      end;
		    If Go then
		      begin
		      If (inx > 0) and (length(pstring(FieldData)^) <= CurPos) then Go := FALSE;
		      If Go then
			begin
			ChangeMade;
			If (fieldsize - CurPos - inx > 1) then
			  Move(pstring(FieldData)^[CurPos + inx + 1],
				pstring(FieldData)^[CurPos + inx], fieldsize - CurPos - inx - 1);
			pstring(FieldData)^[pred(fieldsize)] := fillvalue;
			If (inx <> 0) and (pbyte(FieldData)^ > 0) then Dec(pstring(FieldData)^[0]);
			end;
		      end;
		    end;
		  ^D:	{ kbRight }
		    If CurPos < fieldsize - inx - 1 then Inc(CurPos) else QuitField(cmDMX_Right);
		  ^S:	{ kbLeft }
		    begin
		    If (CurPos > 0) then Dec(CurPos) else QuitField(cmDMX_Left);
		    end;
		  ^A..^Z:  { prevent ctrl-characters from being entered }
		    begin
		    end;
	       else begin
		    If inx = 0 then i := fieldsize else i := pbyte(FieldData)^;
		    If InsOn then
		      begin
		      If (fieldsize = succ(inx)) then pstring(FieldData)^[inx] := fillvalue;
		      If (ord(pstring(FieldData)^[pred(fieldsize)]) and $DF = 0)
			  or
			 ((inx = 1) and (length(pstring(FieldData)^) < pred(fieldsize)))
		       then
			begin
			ChangeMade;
			If (inx <> 0) then
			  begin
			  If (CurPos > i) then
			    begin
			    fillchar(pstring(FieldData)^[succ(i)], CurPos-i, fillvalue);
			    pbyte(FieldData)^ := succ(CurPos);
			    end
			   else
			    Inc(pbyte(FieldData)^);
			  end;
			If succ(CurPos) + inx < fieldsize then
			  Move(pstring(FieldData)^[CurPos + inx],
				pstring(FieldData)^[CurPos + inx + 1],
				fieldsize - CurPos - inx - 1);
			pstring(FieldData)^[CurPos + inx] := Event.CharCode;
			end
		       else
			begin
			WrongKeypressed(Event);
			Go := FALSE;
			end;
		      end
		     else
		      begin
		      ChangeMade;
		      If (inx <> 0) and (CurPos >= i) then
			begin
			fillchar(pstring(FieldData)^[succ(i)],
				  CurPos - i, fillvalue);
			pbyte(FieldData)^ := succ(CurPos);
			end;
		      pstring(FieldData)^[CurPos + inx] := Event.CharCode;
		      end;
		    If CurPos < fieldsize - inx - 1 then
		      begin
		      If Go then Inc(CurPos);
		      end
		     else QuitField(cmDMX_Right);
		    end;
		  end;	{ case of CharCode }
		If (CurPos < FirstPos) then FirstPos := CurPos;
		end;
	      end;

	    fldCHARVAL:
	      begin
	      Move(FieldData^, A[1], fieldsize);
	      A[0] := chr(fieldsize);
	      j := 0;
	      For i := 1 to fieldsize do
		begin
		If (ord(A[i]) and not $20 = 0) then A[i] := ' ' else
		If (A[i] in ['-', '.', '0'..'9']) then j := 1;
		end;
	      If j = 0 then
		begin
		fillchar(A[1], fieldsize, '0');
		If fieldsize - decimals > 2 then fillchar(A[1], fieldsize - decimals - 2, ' ');
		If decimals > 0 then A[fieldsize - decimals] := '.';
		end;
	      If EffectField(FALSE, -1, 0) then
		begin
		i := 1;
		While (i < length(A)) and (A[i] <= '.') do
		  begin
		  If (A[succ(i)] <> '.') then A[i] := CurrentField^.fillvalue;
		  Inc(i);
		  end;
		Move(A[1], FieldData^, fieldsize);
		end;
	      end;

	    fldBYTE:
	      begin
	      Str(pbyte(FieldData)^:truelen, A);
	      If EffectField(FALSE, 0,255) then Val(A,pbyte(FieldData)^,i);
	      end;

	    fldSHORTINT:
	      begin
	      Str(pshortint(FieldData)^:truelen, A);
	      If EffectField(FALSE, -128,127) then Val(A,pshortint(FieldData)^,i);
	      end;

	    fldWORD:
	      begin
	      Str(pword(FieldData)^:truelen, A);
	      If EffectField(FALSE, 0,65535) then Val(A,pword(FieldData)^,i);
	      end;

	    fldINTEGER:
	      begin
	      Str(pinteger(FieldData)^:truelen, A);
	      If EffectField(FALSE, -1 - MaxInt, MaxInt) then Val(A,pinteger(FieldData)^,i);
	      end;

	    fldLONGINT:
	      begin
	      Str(plongint(FieldData)^:truelen, A);
	      If EffectField(FALSE, -1 - MaxLongInt, MaxLongInt) then
		Val(A,plongint(FieldData)^,i);
	      end;

	    fldREALNUM:
	      begin
	      If decimals > 0 then i := 1 else i := 0;
	      Str(prealnum(FieldData)^:truelen + i:decimals, A);
	      If EffectField(FALSE, -1, 0) then Val(A,prealnum(FieldData)^,i);
	      end;

	    fldENUM:
	      begin
	      EditEnumField;
	      end;

	    fldBOOLEAN:
	      begin
	      If (access and accReadOnly <> 0) or Locked or not CheckRecLock then
		begin
		WrongKeypressed(Event);
		end
	       else
		begin
		Event.CharCode := upcase(Event.CharCode);
		If (Event.CharCode >= '_') then
		  begin
		  If pboolean(FieldData)^ then Event.CharCode := ^G
		  end
		else
		If (Event.CharCode >= ' ') then
		  begin
		  If pboolean(FieldData)^ then
		    Event.CharCode := '-' else Event.CharCode := '+';
		  end;
		Case Event.CharCode of
		  '_',
		  '+':	SetBoolean(TRUE);
		  ^G,^H,
		  '-':	SetBoolean(FALSE);
		 else	WrongKeypressed(Event);
		  end;
		end;
	      end;

	    fldCLUSTER:
	      begin
	      If (access and accReadOnly <> 0) or Locked or not CheckRecLock then
		begin
		WrongKeypressed(Event);
		end
	       else
		begin
		Event.CharCode := upcase(Event.CharCode);
		Case Event.CharCode of
		  '+':	ToggleCluster(1);
		  ^G,^H,
		  '-':	ToggleCluster(-1);
		 else	ToggleCluster(0);
		  end;
		end;
	      end;

	    fldHEXVALUE:
	      begin
	      Event.CharCode := upcase(Event.CharCode);
	      If Event.CharCode in [^G,^H, '0'..'9', 'A'..'F'] then
		begin
		A  := '';
		For i := 1 to fieldsize do A := hexbyte(ord(pstring(FieldData)^[pred(i)])) + A;
		If (length(A) > truelen) then Delete(A, 1,1);
		If EffectField(TRUE, 0, 0) then
		  begin
		  If odd(length(A)) then A[0] := '0' else Move(A[1], A[0], length(A));
		  For i := 0 to pred(fieldsize) do
		    begin
		    j := ord(A[i shl 1]);
		    k := ord(A[succ(i shl 1)]);
		    If j > ord('9') then Dec(j, 7);
		    If k > ord('9') then Dec(k, 7);
		    pstring(FieldData)^[pred(fieldsize) - i] := chr(((j and 15) shl 4) or (k and 15));
		    end;
		  end;
		end
	       else
		WrongKeypressed(Event);
	      end;
	    end;
	  end;
	If Event.What <> evNothing then FirstKey := FALSE;
	end;
      end;
    end;
  If (Event.What = evKeyDown) and (Event.CharCode <> #0) then
    begin
    DrawField(CurrentField);
    ClearEvent(Event);
    end
   else
    begin
    Go := TRUE;
    Case Event.ScanCode of
      hi(kbIns):	If InsOn then BlockCursor else NormalCursor;
      hi(kbCtrlEnd):	QuitField(cmDMX_ScreenBottom);
      hi(kbCtrlHome):	QuitField(cmDMX_ScreenTop);
      hi(kbCtrlLeft),
      hi(kbLeft):	QuitField(cmDMX_Left);
      hi(kbShiftTab):
	  begin
	  TScroller.HandleEvent(Event);
	  If GetState(sfFocused) then QuitField(cmDMX_Left) else QuitField(cmDMX_Enter);
	  end;
      hi(kbCtrlPgDn):	QuitField(cmDMX_Bottom);
      hi(kbCtrlPgUp):	QuitField(cmDMX_Top);
      hi(kbCtrlRight),
      hi(kbRight):	QuitField(cmDMX_Right);
      hi(kbEnd):	QuitField(cmDMX_End);
      hi(kbHome):	QuitField(cmDMX_Home);
      hi(kbPgDn):	QuitField(cmDMX_PgDn);
      hi(kbPgUp):	QuitField(cmDMX_PgUp);
      hi(kbUp):		QuitField(cmDMX_Up);
      hi(kbDown):	QuitField(cmDMX_Down);
     else		Go := FALSE;
      end;
    If Go then ClearEvent(Event);
    end;
end;


procedure TDmxEditor.ProcessMouse(var Event: TEvent);
var  i,j	: word;
     X		: boolean;
     MousePlace	: TPoint;
     E		: TEvent;
begin
  With Event do
    If (What = evMouseDown) and MouseInView(Where) then
      begin
      X  := TRUE;
      If (State and sfFocused = 0) then
	begin
	If (Options and (ofFirstClick or ofSelectable) = ofSelectable) or
	   (State and sfActive = 0) then
	  Exit;
	Select;
	X := FALSE;
	If (State and sfFocused = 0) then Exit;
	end;
      MakeLocal(Where, MousePlace);
      MousePlace.X := MousePlace.X + Delta.X;
      MousePlace.Y := MousePlace.Y + Delta.Y;
      Message(@Self, evCommand, cmDMX_goto, pointer(MousePlace));
      If X then
	begin
	If DoubleValid then
	  begin
	  If (CurrentField <> nil) and
	     (upcase(CurrentField^.typecode) = fldCLUSTER)
	   then
	    Message(@Self, evKeyDown, $2020, @Self);
	  If Double then
	    begin
	    With E do
	      begin
	      What := evCommand;
	      Command := cmDMX_DoubleClick;
	      InfoPtr := @Self;
	      end;
	    PutEvent(E);
	    end;
	  end;
	{else
	  WrongKeypressed(Event); }
	end;
      If (Options and ofFirstClick = 0) or not DoubleValid then ClearEvent(Event);
      end;
end;


procedure TDmxEditor.ResetRecLock;
begin
end;


procedure TDmxEditor.ScrollDraw;
var  RS,FS: boolean;
begin
  FS := FieldSelected;
  RS := RecordSelected;
  If (VScrollBar <> nil) and (VScrollBar^.Value <> Delta.Y) then
    begin
    If not Valid(cmDMX_Up) then
      begin
      RS := FALSE;
      VScrollBar^.Value := Delta.Y;
      VScrollBar^.DrawView;
      end;
    If FS then EvaluateField;
    If RS then EvaluateRecord;
    end
   else
    RS := FALSE;
  TDmxScroller.ScrollDraw;
  If RS then
    begin
    If (CurrentRecord >= Delta.Y + Size.Y) then CurrentRecord := Delta.Y + pred(Size.Y)
    else
    If (CurrentRecord < Delta.Y) then CurrentRecord := Delta.Y;
    SetupRecord;
    If FS then SetupField;
    end;
end;


function  TDmxEditor.SetRecLock : boolean;
begin
  SetRecLock := TRUE;
end;


procedure TDmxEditor.SetState(AState: word; Enable: boolean);

    procedure HoldState(On,F: boolean);
    begin
      If On then
	begin
	JustAltered := FALSE;
	{ verify CurrentRecord within valid range and select record/field }
	If not RecordSelected then
	  begin
	  If (DataBlockSize > 0) and (RecordSize > 0) and
	     (DataBlockSize div RecordSize < CurrentRecord)
	   then CurrentRecord := DataBlockSize div RecordSize;
	  RedrawRecord := TRUE;
	  Draw;
	  SetUpRecord;
	  end;
	If F and not FieldSelected then SetUpField;
	TDmxScroller.SetState(AState, Enable);
	end
       else
	begin
	TDmxScroller.SetState(AState, Enable);
	{ deselect record/field and redisplay other windows }
	If FieldSelected then EvaluateField;
	If RecordSelected then EvaluateRecord;
	Message(DeskTop, evBroadcast, cmDMX_Draw, @Self);
	end;
    end;

begin
  If not Vidis or not RecordSelected then
    begin
    If (AState and sfActive <> 0) then
      begin
      HoldState(Enable, ((AState or State) and sfSelected <> 0));
      Exit;
      end
    else
    If RecordSelected and (AState and sfSelected <> 0) then
      begin
      If Enable and not FieldSelected then SetupField
      else
      If not Enable and FieldSelected then EvaluateField;
      end;
    end;
  If (AState and sfDragging <> 0) and (RecordSelected = Enable) then
    HoldState(not Enable, (State and sfSelected <> 0))
  else
  TDmxScroller.SetState(AState, Enable);
end;


procedure TDmxEditor.SetUpField;
begin
  RedrawRecord	:= TRUE;
  FieldSelected := TRUE;
  FieldAltered	:= FALSE;
  FieldData := ptr(seg(RecordData^), ofs(RecordData^) + CurrentField^.datatab);
  FirstKey  := TRUE;
  If (showCurrentField in ShowFmt) then
    ShowFmt := [showanyway, showCurrentField]
   else
    ShowFmt := [showanyway];
  CurPos   :=	0;
  FirstPos :=	0;
  With CurrentField^ do
    If upcase(typecode) in [fldCHARVAL, fldBYTE, fldSHORTINT, fldWORD,
			    fldINTEGER, fldLONGINT, fldREALNUM, fldHEXVALUE]
     then
      begin
      CurPos := pred(truelen - decimals);
      If CurPos < 0 then CurPos := 0;
      end
     else
      If (upcase(typecode) = fldENUM) then CurPos := -1;
  If (State and sfVisible <> 0) then DrawField(CurrentField);
  If (RecInd <> nil) then RecInd^.DrawView;
end;


procedure TDmxEditor.SetUpRecord;
var  F : pDMXfieldrec;
begin
  F := DMXfield1;
  ActualRecordNum := CurrentRecord;
  ActualRecordNum := BaseRecord + ActualRecordNum;
  RecordData	 := DataAt(CurrentRecord);
  RecordAltered	 := FALSE;
  FieldAltered	 := FALSE;
  RecordSelected := TRUE;
  ClearRecLock;
  Message(Owner, evBroadcast, cmDMX_SetupRecord, @Self);
  If (showCurrentField in ShowFmt) and (CurrentField <> nil) and (DMXfield1 = F) then
    begin
    FieldData := ptr(seg(RecordData^), ofs(RecordData^) + CurrentField^.datatab);
    DrawField(CurrentField);
    end;
end;


function  TDmxEditor.Valid(Command: word) : boolean;
    function RO : boolean;
    var  field : pDMXfieldrec;
    begin
      If (Command = cmDMX_ZeroizeField) then
	RO := (CurrentField = nil) or (CurrentField^.access and accReadOnly <> 0)
       else
	begin
	RO := FALSE;
	field := DMXfield1;
	While (field <> nil) do
	  begin
	  If (field^.access and accReadOnly <> 0) then RO := TRUE;
	  field := field^.Next;
	  end;
	end;
    end;
begin
  If ((Command = cmDMX_ZeroizeRecord) or (Command = cmDMX_ZeroizeField))
     and (Locked or RO)
   then
    Valid := FALSE
   else
    Valid := TDmxScroller.Valid(Command);
end;

const ClearingRec : boolean = FALSE;

procedure TDmxEditor.ZeroizeField(Whole: boolean;  Field: pDMXfieldrec);
var  FData : pointer;
     fn    : integer;
     cltr  : boolean;
begin
  If (RecordData = nil) or (Field = nil) or Locked then Exit;
  If CheckRecLock then
    begin
    cltr := FALSE;
    fn := Field^.fieldnum;
    If Whole and (fn <> 0) then Field := DMXfield1;
    While Field <> nil do
      begin
      If Field^.fieldnum = fn then
	begin
	With Field^ do
	  If (access and accReadOnly = 0) and (fieldsize > 0) then
	    begin
	    FData := ptr(seg(RecordData^), ofs(RecordData^) + datatab);
	    If (Field^.typecode <> fldCLUSTER) then fillchar(FData^, fieldsize, fillvalue);
	    Case upcase(typecode) of
	      fldSTR,
	      fldSTRNUM:	pstring(FData)^[0] := #0;
	      fldCHARVAL:
		begin
		fillchar(FData^, fieldsize, '0');
		If fieldsize - decimals > 2 then fillchar(FData^, fieldsize - decimals - 2, ' ');
		If decimals > 0 then pstring(FData)^[fieldsize - decimals - 1] := '.';
		end;
	      fldCLUSTER:
		begin
		If (Field^.typecode = fldCLUSTER) then
		  word(FData^) := word(FData^) and not (1 shl Field^.decimals);
		cltr := TRUE;
		end;
	      end;
	    ChangeMade;
	    end;
	end;
      If Whole and (fn <> 0) then Field := Field^.Next else Field := nil;
      end;
    FirstKey := TRUE;
    If Cltr then
      begin
      If not ClearingRec then DrawView;
      ClearingRec := FALSE;
      end;
    RedrawRecord := TRUE;
    end;
end;


procedure TDmxEditor.ZeroizeRecord;
var  field : pDMXfieldrec;
begin
  If CheckRecLock then
    begin
    ClearingRec := TRUE;
    field := DMXfield1;
    If (RecordData <> nil) then
      While (field <> nil) do
	begin
	ZeroizeField(FALSE, field);
	field := field^.Next;
	end;
    If not ClearingRec then DrawView;
    ClearingRec := FALSE;
    end;
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure RegisterTVDMX;
begin
  RegisterType(RDmxExtLabels);
  RegisterType(RDmxLabels);
  RegisterType(RDmxFLabels);
  RegisterType(RDmxMLabels);
  RegisterType(RDmxRecInd);
  RegisterType(RDmxScroller);
  RegisterType(RDmxEditor);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


End.
