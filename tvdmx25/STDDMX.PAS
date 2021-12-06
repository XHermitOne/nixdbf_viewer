
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	StdDMX	 --Standard tvDMX Interface Unit	}
{	tvDMX	 --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,93	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Unit StdDMX;

{$B-,D+,O+,R-,X+,V- }

interface

uses  Objects, Drivers, Views, Dialogs, App, MsgBox,
      RSet, tvGizma, DmxGizma, tvDMX;

const	CDmxEditDlg	= #19#20#06#06#01#02; { similar to CInputLine }
			 {  |  |  |  |	|  | }
  {  1 normal fields -------+  |  |  |	|  | }
  {  2 normal selected field --+  |  |	|  | }
  {  3 read-only selected field --+  |	|  | }
  {  4 locked field -----------------+	|  | }
  {  5 delimiter -----------------------+  | }
  {  6 border -----------------------------+ }

type
    PDmxEditDlg	 = ^TDmxEditDlg;  { tvDMX editor for dialog boxes }
    PInputFields = ^TInputFields; { line-editor for dialog boxes }
    PValidFields = ^TValidFields; { validating line-editor }
    PDmxViewer	 = ^TDmxViewer;   { tvDMX data scroller window }
    PDmxWindow	 = ^TDmxWindow;   { tvDMX data editor window  }


    TDmxEditDlg	 =  OBJECT(TDmxEditor)
      function	GetPalette : PPalette;  VIRTUAL;
    end;


    TInputFields =  OBJECT(TDmxEditDlg)
	StdEnter	: boolean;
      constructor Init(InfoStr: string; var Bounds: TRect);
      procedure InitData(var AData );  VIRTUAL;
      procedure DoneData;  VIRTUAL;
      procedure LoadData(var S: TStream);  VIRTUAL;
      procedure StoreData(var S: TStream);  VIRTUAL;
      function	DataSize : word;  VIRTUAL;
      procedure GetData(var Rec );  VIRTUAL;
      procedure SetData(var Rec );  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure SetState(AState: word; Enable: boolean);  VIRTUAL;
      procedure SetUpField;  VIRTUAL;
    end;


    TValidFields  =  OBJECT(TInputFields)
	VLo,VHi 	: integer;
      constructor Init(InfoStr: string; var Bounds: TRect; ALo,AHi: integer);
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      function	Valid(Command: word) : boolean;  VIRTUAL;
    end;


    TDmxViewer	 =  OBJECT(TLtdWindow)
	DMX	: PDmxEditor;
      constructor Init(var Bounds: TRect;  ATitle: TTitleStr;  ANumber: integer;
			ATemplate: string;  var AData;  BSize: longint;
			var ALabels: string);
      constructor Load(var S: TStream);
      procedure InitDMX(ATemplate: string;  var AData;
			ALabels, ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
      function	NewDmxLabels(var ALabels ) : PDmxLink;	VIRTUAL;
      procedure Store(var S: TStream);
      function	Valid(Command: word) : boolean;  VIRTUAL;
    end;


    TDmxWindow	 =  OBJECT(TDmxViewer)
      constructor Init(var Bounds: TRect;  ATitle: TTitleStr;  ANumber: integer;
			ATemplate: string;  var AData;  BSize: longint;
			var ALabels: string;	IndLen	: integer);
      procedure InitDMX(ATemplate: string;  var AData;
			ALabels, ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
      function	NewRecInd(Len: integer) : PDmxLink;  VIRTUAL;
    end;



  procedure GetBlob(Num: integer; var Blob: pointer; var Len: integer);


  function  InsertField(Dialog: PDialog;  Col,Row: integer;
			Fmt: boolean;  ALabel,ATemplate: string) : PInputFields;

  function  ValidField(Dialog: PDialog;	Col,Row, ALo,AHi: integer;
			Fmt: boolean;  ALabel,ATemplate: string) : PValidFields;

  procedure RegisterStdDMX;


const
    RDmxEditDlg	:  TStreamRec =(
	ObjType:  rnDmxEditDlg;
	VmtLink:  ofs(TypeOf(TDmxEditDlg)^);
	Load:	  @TDmxEditDlg.Load;
	Store:	  @TDmxEditDlg.Store
      );

    RInputFields :  TStreamRec =(
	ObjType:  rnInputFields;
	VmtLink:  ofs(TypeOf(TInputFields)^);
	Load:	  @TInputFields.Load;
	Store:	  @TInputFields.Store
      );

    RValidFields :  TStreamRec =(
	ObjType:  rnValidFields;
	VmtLink:  ofs(TypeOf(TValidFields)^);
	Load:	  @TValidFields.Load;
	Store:	  @TValidFields.Store
      );

    RDmxViewer	:  TStreamRec =(
	ObjType:  rnDmxViewer;
	VmtLink:  ofs(TypeOf(TDmxViewer)^);
	Load:	  @TDmxViewer.Load;
	Store:	  @TDmxViewer.Store
      );

    RDmxWindow	:  TStreamRec =(
	ObjType:  rnDmxWindow;
	VmtLink:  ofs(TypeOf(TDmxWindow)^);
	Load:	  @TDmxWindow.Load;
	Store:	  @TDmxWindow.Store
      );


implementation

  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure GetBlob(Num: integer; var Blob: pointer; var Len: integer);
var  P : PDmxEditor;
begin
  Blob := nil;
  Len  := 0;
  P := Message(DeskTop, evCommand, cmDMX_RollCall, nil);
  If (P <> nil) then P^.GetBlob(Num, Blob, Len);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  InsertField(Dialog: PDialog;  Col,Row: integer;
		      Fmt: boolean;  ALabel,ATemplate: string) : PInputFields;
var  i	: integer;
     R	: TRect;
     B	: PInputFields;
begin
  With Dialog^ do
    begin
    i  := succ(CStrLen(ALabel));
    R.Assign(Col, Row, Col + DmxStrLen(ATemplate), succ(Row));
    If (ALabel <> '') then
      begin
      If Fmt then R.Move(1, 1) else R.Move(i, 0);
      end;
    B  := New(PInputFields, Init(ATemplate, R));
    Insert(B);
    If (ALabel <> '') then
      begin
      R.Assign(Col, Row, Col + i, succ(Row));
      Insert(New(PLabel, Init(R, ALabel, B)));
      end;
    end;
  InsertField := B;
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  ValidField(Dialog: PDialog;	Col,Row, ALo,AHi: integer;
		     Fmt: boolean;  ALabel,ATemplate: string) : PValidFields;
var  i	: integer;
     R	: TRect;
     B	: PValidFields;
begin
  With Dialog^ do
    begin
    i := succ(CStrLen(ALabel));
    R.Assign(Col, Row, Col + DmxStrLen(ATemplate), succ(Row));
    If (ALabel <> '') then
      begin
      If Fmt then R.Move(1, 1) else R.Move(i, 0);
      end;
    B := New(PValidFields, Init(ATemplate, R, ALo,AHi));
    Insert(B);
    If (ALabel <> '') then
      begin
      R.Assign(Col, Row, Col + i, succ(Row));
      Insert(New(PLabel, Init(R, ALabel, B)));
      end;
    end;
  ValidField := B;
end;


  { ออ TValidFields ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TValidFields.Init(InfoStr: string; var Bounds: TRect;  ALo,AHi: integer);
begin
  TInputFields.Init(InfoStr, Bounds);
  VLo := ALo;
  VHi := AHi;
end;


procedure TValidFields.HandleEvent(var Event: TEvent);
begin
  If (Event.What <> evKeyDown) or (Event.CharCode in[#0..#31,'0'..'9']) then
    TInputFields.HandleEvent(Event);
end;


function  TValidFields.Valid(Command: word) : boolean;
var  i	   : integer;
     Range : array[0..1] of longint;
     S	   : string;
     R	   : TRect;
begin
  If (Command = cmValid) or (Command = cmCancel) or
    ((integer(WorkingData^) >= VLo) and (integer(WorkingData^) <= VHi)) then
    TInputFields.Valid(Command)
   else
    begin
    Range[0] := VLo;
    Range[1] := VHi;
    If (TypeOf(Prev^) = TypeOf(TLabel)) and (PLabel(Prev)^.Link = @Self) and
       (PLabel(Prev)^.Text <> nil) and (PLabel(Prev)^.Text^ <> '') then
      begin
      S := PLabel(Prev)^.Text^;
      For i := length(S) downto 1 do
	If (S[i] = '~') or ((i = length(S)) and (S[i] in[' ',':'])) then
	  Delete(S,i,1);
      end
     else
      S := 'Selection';
    R.Assign(0, 0, 50, 9);
    R.Move((Desktop^.Size.X - R.B.X) div 2,(Desktop^.Size.Y - R.B.Y) div 2);
    MessageBoxRect(R, S + ' is out of valid range:'^M^M^C'%d to %d', @Range, mfError + mfOKButton);
    Valid := FALSE;
    Select;
    end;
end;


  { ออ TDmxEditDlg ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TDmxEditDlg.GetPalette : PPalette;
const  A : string[length(CDmxEditDlg)] = CDmxEditDlg;
begin
  GetPalette := @A
end;


  { ออ TInputFields ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TInputFields.Init(InfoStr: string;  var Bounds: TRect);
var  S	  : string;
     void : integer;
begin
    { init with no data }
  S := ^A + InfoStr;
  TDmxEditDlg.Init(S, void, 0, Bounds, nil,nil, nil,nil);
  GrowMode := gfGrowHiX;
  Options  := Options or ofFirstClick;
  StdEnter := TRUE;
end;


procedure TInputFields.InitData(var AData );
{ allocates memory for the data }
begin
  DataBlockSize := Size.Y * RecordSize;  { correct improper size }
  GetMem(WorkingData, DataBlockSize);
  fillchar(WorkingData^, DataBlockSize, 0);
  TDmxEditDlg.InitData(WorkingData^);
end;


procedure TInputFields.DoneData;
begin
  TDmxEditDlg.DoneData;
  FreeMem(WorkingData, DataBlockSize);
end;


procedure TInputFields.LoadData(var S: TStream);
begin
  S.Read(StdEnter, sizeof(StdEnter));
  S.Read(DataBlockSize, sizeof(DataBlockSize));
  GetMem(WorkingData,  DataBlockSize);
  S.Read(WorkingData^, DataBlockSize);
end;


procedure TInputFields.StoreData(var S: TStream);
begin
  S.Write(StdEnter, sizeof(StdEnter));
  S.Write(DataBlockSize, sizeof(DataBlockSize));
  S.Write(WorkingData^, DataBlockSize);
end;


function  TInputFields.DataSize : word;
begin
  DataSize := LongRec(DataBlockSize).Lo
end;


procedure TInputFields.GetData(var Rec );
var  Len : word;
begin
  Len  := DataSize;
  If (Len > 0) and (WorkingData <> nil) then Move(WorkingData^, Rec, Len);
end;


procedure TInputFields.SetData(var Rec );
var  Len : word;
begin
  Len  := DataSize;
  If (Len > 0) and (WorkingData <> nil) then Move(Rec, WorkingData^, Len);
  DrawView;
end;


const  Initing : boolean = FALSE;


procedure TInputFields.HandleEvent(var Event: TEvent);
    function  AtEndField : boolean;
    var  F : pDMXfieldrec;
    begin
      F := CurrentField;
      Repeat
	F := F^.Next;
      Until (F = nil) or ((F^.fieldsize > 0) and (F^.access and accSkip = 0));
      AtEndField := (F = nil);
    end;
begin
  With Event do
    If (What = evKeyboard) then
      begin
      If (KeyCode = kbEnter) and StdEnter and AtEndField then
	begin
	TScroller.HandleEvent(Event);
	Exit;
	end
       else
	begin
	If ((KeyCode = kbPgUp) or (KeyCode = kbUp)) and (CurrentRecord = 0) then
	  KeyCode := kbShiftTab;
	If ((KeyCode = kbPgDn) or (KeyCode = kbDown)
	  or ((KeyCode = kbEnter) and AtEndField))
	  and (succ(CurrentRecord) = Limit.Y)
	 then
	  KeyCode := kbTab;
	end;
      end
    else
    If (What = evBroadcast) and (Command = cmDMX_RollCall) and Initing and
       (InfoPtr <> @Self) then
      begin
      StdEnter := FALSE;
      end;
  TDmxEditDlg.HandleEvent(Event);
end;


procedure TInputFields.SetState(AState: word; Enable: boolean);
var  cmd    : word;
     voidXY : TPoint;
begin
  If (AState and sfFocused <> 0) and not Enable then JustAltered := FALSE;
  TDmxEditDlg.SetState(AState, Enable);
  If Enable and (AState and sfFocused <> 0) then
    begin
    cmd  := cmDMX_Home;
    ProcessCommand(cmd, voidXY);
    end
  else
  If Enable and (AState and sfExposed <> 0) then
    begin
    If (Owner <> nil) then
      begin
      Initing := TRUE;
      Message(Owner, evBroadcast, cmDMX_RollCall, @Self);
      Initing := FALSE;
      end;
    end;
end;


procedure TInputFields.SetUpField;
begin
  TDmxEditDlg.SetUpField;
  If (CurrentField <> nil) and
     (upcase(CurrentField^.typecode) in[fldSTR, fldSTRNUM, fldCHAR, fldCHARNUM])
   then
    FirstKey := FALSE;
end;


  { ออ TDmxViewer ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxViewer.Init(var Bounds	   : TRect;
				ATitle     : TTitleStr;
				ANumber    : integer;
				ATemplate  : string;
			    var AData;
				BSize	   : longint;
			    var ALabels    : string);
const  NilWin	: array[0..1] of Longint = (0,0);
begin
  TLtdWindow.Init(Bounds, TRect(NilWin), ATitle, ANumber);
  InitDMX(ATemplate, AData, NewDmxLabels(ALabels), nil, BSize);
  Options := Options or ofTileable;
end;


constructor TDmxViewer.Load(var S: TStream);
begin
  TLtdWindow.Load(S);
  GetSubViewPtr(S, DMX);
end;


procedure TDmxViewer.InitDMX(ATemplate: string;
			      var AData;
			      ALabels,ARecInd: PDmxLink;
			      BSize: longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If (ALabels <> nil) then Inc(R.A.Y, ALabels^.Size.Y);
  Insert(New(PDmxScroller, Init(ATemplate, AData, BSize, R, ALabels,
				   StandardScrollBar(sbHorizontal),
				   StandardScrollBar(sbVertical))));
end;


function  TDmxViewer.NewDmxLabels(var ALabels ) : PDmxLink;
begin
  If (@ALabels = nil) or (string(ALabels) = '') then
    NewDmxLabels := nil
   else
    NewDmxLabels := New(PDmxLabels, InitInsert(@Self, @ALabels));
end;


procedure TDmxViewer.Store(var S: TStream);
begin
  TLtdWindow.Store(S);
  PutSubViewPtr(S, DMX);
end;


function  TDmxViewer.Valid(Command: word) : boolean;
var  Len : integer;
     V	 : boolean;
begin
  V := TLtdWindow.Valid(Command);
  If V and (Command = cmValid) then
    begin
    If (DMX = nil) then DMX := Message(@Self, evCommand, cmDMX_RollCall, nil);
    If (DMX <> nil) and (DMX^.Labels <> nil) then
      begin
      If (Limit.A.Y > 0) then Limit.A.Y := succ(Size.Y - DMX^.Size.Y);
      Limit.B.X	:= PDmxLabels(DMX^.Labels)^.Len + (Size.X - DMX^.Size.X);
      Len	:= length(GetTitle(MaxViewWidth)) + 12;
      If (Len > ScreenWidth) then Len := ScreenWidth;
      If (Len > Limit.B.X) then Limit.B.X := Len;
      If (Limit.B.X < MinWinSize.X) then Limit.B.X := MinWinSize.X;
      end;
    end;
  Valid := V;
end;


  { ออ TDmxWindow ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxWindow.Init(var Bounds	   : TRect;
				ATitle     : TTitleStr;
				ANumber    : integer;
				ATemplate  : string;
			    var AData;
				BSize	   : longint;
			    var ALabels    : string;
				IndLen     : integer);
const  NilWin	: array[0..1] of Longint = (0,0);
begin
  TLtdWindow.Init(Bounds, TRect(NilWin), ATitle, ANumber);
  InitDMX(ATemplate, AData, NewDmxLabels(ALabels), NewRecInd(IndLen), BSize);
  Options := Options or ofTileable;
end;


procedure TDmxWindow.InitDMX(ATemplate: string;  var AData;
			     ALabels, ARecInd: PDmxLink;
			     BSize: longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If (ALabels <> nil) then Inc(R.A.Y, ALabels^.Size.Y);
  Insert(New(PDmxEditor, Init(ATemplate, AData, BSize, R,
				ALabels, ARecInd,
				StandardScrollBar(sbHorizontal),
				StandardScrollBar(sbVertical))));
end;


function  TDmxWindow.NewRecInd(Len: integer) : PDmxLink;
begin
  If (Len <= 0) then
    NewRecInd := nil
   else
    NewRecInd := New(PDmxRecInd, InitInsert(@Self, Len));
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure RegisterStdDMX;
begin
  RegisterType(RDmxEditDlg);
  RegisterType(RInputFields);
  RegisterType(RDmxViewer);
  RegisterType(RDmxWindow);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }



End.
