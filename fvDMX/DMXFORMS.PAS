
{=======================================================}
{							}
{	DMXFORMS  --Form Editing Unit			}
{	tvDMX	  --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1994  Randolph Beck		}
{			    P.O. Box  56-0487		}
{			    Orlando, FL 32856		}
{			    CIS:  72361,753		}
{							}
{=======================================================}

Unit DMXFORMS;

//{$B-,D+,O+,R-,V-,X+ }
{$mode Delphi}{$H+}
//{$mode objfpc}{$H+}

interface

uses
  Objects,
  Drivers,
  Memory,
  Views,
  Dialogs,
  Menus,
  App,
  RSet,
  DmxGizma,
  tvDMX,
  Avail;

const
    { additional buttons and options for EntryBox }
    mfHelpButton	= $0001;
    mfViewOnly		= $0002;
    mfDefault		= $0004;

    { EntryBox defaults }
    hcEntryBox		: word	  = 0;
  {$IFDEF VER60 }
    dpEntryBox		: integer = 1;
  {$ELSE }
    dpEntryBox		: integer = dpGrayDialog;
  {$ENDIF }

    FormButtons: array[0..4] of string[8] =
       ('~Y~es',
	'~N~o',
	'O~K~',
	'Cancel',
	'~H~elp');

    CDmxDlgForm		= #26#12#10#10#01#02;
    CDmxDlgFormOff	= #01#12#10#10#01#02;
			 {  |  |  |  |	|  |  }
  {  1 normal fields -------+  |  |  |	|  |  }
  {  2 normal selected field --+  |  |	|  |  }
  {  3 read-only selected field --+  |	|  |  }
  {  4 locked field -----------------+	|  |  }
  {  5 delimiter -----------------------+  |  }
  {  6 border -----------------------------+  }

type
    PFldPtrArray	= ^TFldPtrArray;
    TFldPtrArray	=  array[0..8195] of pDMXfieldrec;


    PDmxForm		= ^TDmxForm;
    TDmxForm		=  OBJECT(TDmxEditor)
	InScrl		: boolean;
	NumRows		: integer;
	DMXfields	: PFldPtrArray;
      constructor Init(ATemplates : PSItem;  AInScroll : boolean;
			var AData;  var Bounds : TRect;  ALabels,ARecInd : PDmxLink;
			AHScrollBar,AVScrollBar : PScrollBar);
      function	DataAt(RecNum : integer) : pointer;  VIRTUAL;
      procedure DoneStruct;   VIRTUAL;
      procedure Draw;	      VIRTUAL;
      procedure HandleEvent(var Event : TEvent);  VIRTUAL;
      procedure InitStruct(var ATemplate );  VIRTUAL;
      procedure LoadStruct(var S : TStream);  VIRTUAL;
      procedure SetupField;   VIRTUAL;
      procedure SetupRecord;  VIRTUAL;
      procedure StoreStruct(var S : TStream);  VIRTUAL;
      private
	FirstDataRow	: integer;
	PrevRec		: integer;
    end;


    PDmxDlgForm		= ^TDmxDlgForm;
    TDmxDlgForm		=  OBJECT(TDmxForm)
      constructor Init(ATemplates : PSItem;
			var Bounds : TRect;
			AHScrollBar,AVScrollBar : PScrollBar);
      //function	DataSize : word;  VIRTUAL;
      function	DataSize : Sw_Word;  VIRTUAL;
      procedure DoneData;  VIRTUAL;
      procedure GetData(var Rec );	VIRTUAL;
      function	GetPalette : PPalette;	VIRTUAL;
      procedure InitData(var AData );	VIRTUAL;
      procedure SetData(var Rec );	VIRTUAL;
      function  Valid(Command: word) : boolean;  VIRTUAL;
    end;


  procedure MakeEntryBox(ADialog: PDialog; DMX: PDmxDlgForm;
			 AOptions: word; AForm: PSItem);

  function  EntryBox(Title: string; AData: pointer; AOptions: word; AForm: PSItem) : word;

  procedure RegisterDMXFORMS;


const
    RDmxForm	:  TStreamRec =(
	ObjType:  rnDmxForm;
	VmtLink:  ofs(TypeOf(TDmxForm)^);
	Load:	  @TDmxForm.Load;
	Store:	  @TDmxForm.Store
      );

    RDmxDlgForm	:  TStreamRec =(
	ObjType:  rnDmxDlgForm;
	VmtLink:  ofs(TypeOf(TDmxDlgForm)^);
	Load:	  @TDmxDlgForm.Load;
	Store:	  @TDmxDlgForm.Store
      );


implementation

  { ====================================================================== }


procedure MakeEntryBox(ADialog: PDialog; DMX: PDmxDlgForm;
			AOptions: word;  AForm: PSItem);
const
    BtnWidth = 10;
    Commands: array[0..4] of word = (cmYes, cmNo, cmOK, cmCancel, cmHelp);
var
    i,W,X,Y,BtnCount	: integer;
    BtnList		: array[0..5] of PButton;
    S			: string;
    R			: TRect;
    Line		: PSItem;
    b,XBar,YBar		: boolean;
    LMargin		: integer;

    function  HScrollBar : PScrollBar;
    begin
      If XBar then
	HScrollBar := ADialog^.StandardScrollBar(sbHorizontal + sbHandleKeyboard)
       else
	HScrollBar := nil;
    end;

    function  VScrollBar : PScrollBar;
    var  R:   TRect;
	 Bar: PScrollBar;
    begin
      If YBar then
	begin
	Bar := ADialog^.StandardScrollBar(sbVertical + sbHandleKeyboard);
	If (BtnCount > 0) then
	  begin
	  Bar^.GetBounds(R);
	  Dec(R.B.Y, 4);
	  Bar^.Locate(R);
	  end;
	VScrollBar := Bar;
	end
       else
	VScrollBar := nil;
    end;

    procedure AssignBtn(BtnNum: integer);
    var bf: byte;
    begin
      BtnList[BtnCount] := New(PButton, Init(R, FormButtons[BtnNum], Commands[BtnNum], bfNormal));
      If (AOptions and mfDefault <> 0) and (Commands[BtnNum] = cmOK) then
	BtnList[BtnCount]^.AmDefault := TRUE;
      Inc(X, BtnWidth + 2);
      Inc(BtnCount);
    end;

begin
  If (ADialog = nil) or (AForm = nil) then Exit;
  X := -2;
  BtnCount := 0;
  R.Assign(0, 0, BtnWidth, 2);
  For i := 0 to 3 do If (AOptions and ($0100 shl i) <> 0) then AssignBtn(i);
  If (AOptions and mfHelpButton <> 0) then AssignBtn(4);
  W := BtnCount * (BtnWidth + 2) + 2;
  If (W+2 < MinWinSize.X) then W := MinWinSize.X - 2;
  Y := 0;
  Line := AForm;
  b := FALSE;
  While (Line <> nil) do
    begin
    If (Line^.Value <> nil) then
      begin
      i := DmxStrLen(Line^.Value^);
      If (W < i) then
        begin
        W := i;
        b := TRUE;
        end;
      end;
    Inc(Y);
    Line := Line^.Next;
    end;
  If b then LMargin := 1 else
    begin
    LMargin := succ(W - MaxItemStrLen(AForm)) div 2;
    If (LMargin < 1) then LMargin := 1;
    end;
  R.Assign(0,0, W+2, Y+2);
  If (BtnCount > 0) then Inc(Y, 2);
  If (BtnCount > 0) then Inc(R.B.Y, 4);
  XBar := (R.B.X > DeskTop^.Size.X);
  If XBar then R.B.X := DeskTop^.Size.X;
  YBar := (R.B.Y > DeskTop^.Size.Y);
  If YBar then R.B.Y := DeskTop^.Size.Y;
  ADialog^.Locate(R);
  With ADialog^ do
    begin
    Options := Options or ofCentered;
    Palette := dpEntryBox;
    HelpCtx := hcEntryBox;
    R.Grow(-1,-1);
    If (BtnCount > 0) then Dec(R.B.Y, 4);
    R.A.X := LMargin;

    {New(DMX, Init(AForm, R, HScrollBar,VScrollBar));}
    DMX^.HScrollBar := HScrollBar;
    DMX^.VScrollBar := VScrollBar;
    Move(AForm, S[1], sizeof(PSItem));
    //S[0] := #4;
    SetLength(S, 4);
    DMX^.InitStruct(S);
    If not LowMemory and (DMX^.RecordSize > 0) then
      begin
      GetMem(DMX^.WorkingData, DMX^.RecordSize);
      FillChar(DMX^.WorkingData^, DMX^.RecordSize, 0);
      end;
    DMX^.SetLimit(DMX^.Limit.X, DMX^.NumRows);
    DMX^.Locate(R);

    DisposeSItems(AForm);
    If YBar then DMX^.Options := DMX^.Options or ofFramed;
    If (AOptions and mfViewOnly <> 0) or (DMX^.DataBlockSize <= 0) then
      begin
      DMX^.Locked := TRUE;
      If (DMX^.HScrollBar = nil) and (DMX^.VScrollBar = nil) then
	DMX^.Options := DMX^.Options and not ofSelectable;
      end;
    Insert(DMX);
    X := (Size.X - X) shr 1;
    For i := 0 to pred(BtnCount) do
      begin
      Insert(BtnList[i]);
      BtnList[i]^.MoveTo(X, Size.Y - 3);
      Inc(X, BtnList[i]^.Size.X + 2);
      end;
    SelectNext(FALSE);
    end;
end;


function  EntryBox(Title: string; AData: pointer; AOptions: word; AForm: PSItem) : word;
var  Dialog  : PDialog;
     R	     : TRect;
     Command : word;
begin
  R.Assign(0,0,0,0);
  Dialog := New(PDialog, Init(R, Title));
  MakeEntryBox(Dialog, New(PDmxDlgForm, Init(nil,R,nil,nil)), AOptions, AForm);
  If (Application^.ValidView(Dialog) = nil) then
    EntryBox := cmCancel
   else
    begin
  {$IFDEF VER60 }
    If (AData <> nil) then Dialog^.SetData(AData^);
    Command := DeskTop^.ExecView(Dialog);
    If (Command <> cmCancel) and (AData <> nil) then Dialog^.GetData(AData^);
    Dispose(Dialog, Done);
    EntryBox := Command;
  {$ELSE }
    EntryBox := Application^.ExecuteDialog(Dialog, AData);
  {$ENDIF }
    end;
end;


  { == TDmxForm ========================================================== }


constructor TDmxForm.Init(ATemplates : PSItem;	AInScroll : boolean;
			var AData;  var Bounds : TRect;  ALabels,ARecInd : PDmxLink;
			AHScrollBar,AVScrollBar : PScrollBar);
var  S : string[sizeof(PSItem) + 1];
begin
  Move(ATemplates, S[1], sizeof(PSItem));
  S[0] := #4;
  TDmxEditor.Init(S, AData, 0, Bounds, ALabels, ARecInd, AHScrollBar, AVScrollBar);
  InScrl := AInScroll;
end;


procedure TDmxForm.LoadStruct(var S : TStream);
var  i : integer;
begin
  S.Read(InScrl,  sizeof(InScrl));
  S.Read(NumRows, sizeof(NumRows));
  S.Read(FirstDataRow, sizeof(FirstDataRow));
  If (NumRows > 0) then
    begin
    GetMem(DMXfields,(NumRows * 4) + 200);
    For i := 0 to pred(NumRows) do
      begin
      TDmxEditor.LoadStruct(S);
      DMXfields^[i] := DMXfield1;
      end;
    end;
  PrevRec := -1;
end;


function  TDmxForm.DataAt(RecNum : integer) : pointer;
begin
  DMXfield1 := DMXfields^[RecNum];
  DataAt := WorkingData;
end;


procedure TDmxForm.DoneStruct;
var  Items,P : PSItem;
     i,Lim   : integer;
begin
  If (DMXfields = nil) then Exit;
  i := NumRows;
  While (i > 0) do
    begin
    DMXfield1 := DMXfields^[pred(i)];
    If (DMXfield1 <> nil) then TDmxEditor.DoneStruct;
    Dec(i);
    end;
  FreeMem(DMXfields,(NumRows * 4) + 200);
  NumRows := 0;
  Limit.X := 0;
  DataBlockSize := 0;
  RecordSize := 0;
end;


procedure TDmxForm.Draw;
begin
  TDmxScroller.Draw;
  DMXfield1 := DMXfields^[CurrentRecord];
  If FieldSelected and (showanyway in ShowFmt) and (CurrentField <> nil) then
    DrawField(CurrentField);
end;


procedure TDmxForm.HandleEvent(var Event : TEvent);
var  i,j	: word;
     RS,FS	: boolean;
     MousePlace	: TPoint;
     PrevFld	: pDMXfieldrec;
     E		: TEvent;
     CurRec,Direction,WasY	: integer;
begin
  CurRec  := CurrentRecord;
  Direction := 0;
  PrevFld := CurrentField;
  WasY	  := Delta.Y;
  With Event do
    If (Event.What = evMouseDown) and GetState(sfFocused) and
       (MouseInView(Where)) then
      begin
      RS := RecordSelected;
      FS := FieldSelected;
      If FS then EvaluateField;
      If RS then EvaluateRecord;
      MakeLocal(Where, MousePlace);
      MousePlace.X := MousePlace.X + Delta.X;
      MousePlace.Y := MousePlace.Y + Delta.Y;
      i := cmDMX_goto;
      DMXfield1 := DMXfields^[MousePlace.Y];
      PrevFld	:= CurrentField;
      CurrentField := DMXfield1;
      If (MousePlace.Y < Limit.Y) then
	ProcessCommand(i, MousePlace)
       else
	DoubleValid := FALSE;
      If DoubleValid then
	begin
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
	end
       else
	begin
	{WrongKeypressed(Event);}
	CurrentField := PrevFld;
	end;
      ClearEvent(Event);
      If RS then SetupRecord;
      If FS then SetupField;
      If DoubleValid and (CurrentField <> nil) and
	 (upcase(CurrentField^.typecode) = fldCLUSTER)
       then
	Message(@Self, evKeyDown, $2020, @Self);
      end
     else
      begin
      Case What of
	evCommand,evBroadcast:
	  begin
	  Case Command of
	    cmDMX_Up,	cmDMX_PgUp:	Direction := -2;
	    cmDMX_Down, cmDMX_PgDn:	Direction :=  2;
	    cmDMX_Enter:		Direction :=  1;
	    cmDMX_Draw, cmDMX_DrawData:
		begin
		DrawView;
		If (What = evCommand) then ClearEvent(Event);
		end;
	    end;
	  end;
	end;
      TDmxEditor.HandleEvent(Event);
      If (Direction <> 0) and (CurrentRecord = CurRec) and
	 (State and sfSelected <> 0) and (Owner <> nil) and
	 (Delta.Y = WasY) and
	 ((abs(Direction) > 1) or (CurrentField = PrevFld))
       then
	begin
	If (Direction = 1) then Message(Owner, evBroadcast, cmDefault, @Self);
	Owner^.SelectNext(Direction < 0);
	end;
      end;
end;


procedure TDmxForm.InitStruct(var ATemplate );
var  Items	: PSItem;
     i,Lim	: integer;
     AllZ	: boolean;
     S		: string;
begin
  Move(string(ATemplate)[1], Items, sizeof(Items));
  If (Items = nil) then Exit;
  FirstDataRow := -1;
  AllZ := (Items^.Value <> nil) and (Items^.Value^[1] = ^A);
  Repeat
    Inc(NumRows);
    Items := Items^.Next;
  Until (Items = nil);
  Move(string(ATemplate)[1], Items, sizeof(Items));
  GetMem(DMXfields,(NumRows * 4) + 200);
  i := 0;
  Lim := 0;
  While (Items <> nil) and (not LowMemory) do
    begin
    Limit.X := 0;
    DMXfield1 := nil;
    If (Items^.Value = nil) or (Items^.Value^ = '') or (Items^.Value^ = ^A) then
      S := ' '
     else
      S := Items^.Value^;
    If AllZ and (length(S) < pred(sizeof(S))) then Insert(^A, S, 1);
    TDmxEditor.InitStruct(S);
    If (FirstDataRow < 0) and (RecordSize > 0) then
      begin
      CurrentField := DMXfield1;
      While (CurrentField <> nil) and ((CurrentField^.fieldsize = 0)
	 or (CurrentField^.access and (accHidden or accSkip) <> 0)) do
	CurrentField := CurrentField^.Next;
      If (CurrentField <> nil) then FirstDataRow := i;
      end;
    If (Lim < Limit.X) then Lim := Limit.X;
    DMXfields^[i] := DMXfield1;
    Inc(i);
    Items := Items^.Next;
    end;
  Limit.X := Lim;
  DataBlockSize := RecordSize;
  DataBlockSize := DataBlockSize * NumRows;
  If (FirstDataRow >= 0) then CurrentRecord := FirstDataRow;
  DMXfield1 := DMXfields^[CurrentRecord];
  PrevRec := -1;
end;


procedure TDmxForm.SetUpField;
begin
  TDmxEditor.SetUpField;
  If InScrl and (CurrentField <> nil) and
     (upcase(CurrentField^.typecode) in[fldSTR, fldSTRNUM, fldCHAR, fldCHARNUM])
   then
    FirstKey := FALSE;
end;


procedure TDmxForm.SetupRecord;
var  i,n : integer;
     cmd : word;
     cf,was : pDMXfieldrec;
begin
  was := CurrentField;
  If (CurrentField = nil) then n := 0 else n := CurrentField^.screentab;
  DMXfield1 := DMXfields^[CurrentRecord];
  CurrentField := DMXfield1;
  If (DMXfield1 <> nil) then
    begin
    While (CurrentField <> nil) and ((CurrentField^.fieldsize = 0) or
	  (CurrentField^.access and (accHidden or accSkip) <> 0)) do
      CurrentField := CurrentField^.Next;
    If (CurrentField = nil) then
      begin
      If (CurrentRecord = 0) then PrevRec := -1;
      If (CurrentRecord = pred(Limit.Y)) then PrevRec := Limit.Y;
      If (PrevRec > CurrentRecord) then cmd := cmDMX_Up else cmd := cmDMX_Down;
      CurrentField := was;
      Message(@Self, evCommand, cmd, @Self);
      TDmxForm.SetupRecord;
      Exit;
      end
     else
      begin
      cf := CurrentField;
      While (cf <> nil) and (cf^.screentab <= n) do
	begin
	If (cf^.fieldsize > 0) and (cf^.access and (accHidden or accSkip) = 0)
	 then CurrentField := cf;
	cf := cf^.Next;
	end;
      n := Delta.X;
      If (n + CurrentField^.screentab + CurrentField^.shownwid > Size.X) then
	n := CurrentField^.screentab + CurrentField^.shownwid - Size.X;
      If (n > CurrentField^.screentab) then n := CurrentField^.screentab;
      If (n <> Delta.X) then ScrollTo(n, Delta.Y);
      end;
    end;
  TDmxEditor.SetupRecord;
  PrevRec := CurrentRecord;
end;


procedure TDmxForm.StoreStruct(var S : TStream);
var  i : integer;
begin
  S.Write(InScrl,  sizeof(InScrl));
  S.Write(NumRows, sizeof(NumRows));
  S.Write(FirstDataRow, sizeof(FirstDataRow));
  If (NumRows > 0) then
    For i := 0 to pred(NumRows) do
      begin
      DMXfield1 := DMXfields^[i];
      TDmxEditor.StoreStruct(S);
      end;
  PrevRec := -1;
end;


  { == TDmxDlgForm ======================================================= }


constructor TDmxDlgForm.Init(ATemplates : PSItem;
			var Bounds : TRect;
			AHScrollBar,AVScrollBar : PScrollBar);
begin
  //TDmxForm.Init(ATemplates, TRUE, Mem[0:0], Bounds, nil,nil, AHScrollBar, AVScrollBar);
  TDmxForm.Init(ATemplates, TRUE, Avail.Mem[0], Bounds, nil, nil, AHScrollBar, AVScrollBar);
  Options := Options or ofFirstClick;
end;


//function  TDmxDlgForm.DataSize : word;
function  TDmxDlgForm.DataSize : Sw_Word;
begin
  DataSize := RecordSize;
end;


procedure TDmxDlgForm.DoneData;
begin
  If (WorkingData <> nil) and (RecordSize > 0) then
    FreeMem(WorkingData, RecordSize);
end;


procedure TDmxDlgForm.GetData(var Rec );
begin
  Move(WorkingData^, Rec, DataSize);
end;


function  TDmxDlgForm.GetPalette : PPalette;
const  P1 : string[length(CDmxDlgForm)] = CDmxDlgForm;
       P2 : string[length(CDmxDlgForm)] = CDmxDlgFormOff;
begin
  If (Options and ofSelectable <> 0) then
    GetPalette := @P1
   else
    GetPalette := @P2;
end;


procedure TDmxDlgForm.InitData(var AData );
begin
  If not LowMemory and (RecordSize > 0) then
    begin
    GetMem(WorkingData, RecordSize);
    FillChar(WorkingData^, RecordSize, 0);
    end;
end;


procedure TDmxDlgForm.SetData(var Rec );
begin
  Move(Rec, WorkingData^, DataSize);
end;


function  TDmxDlgForm.Valid(Command: word) : boolean;
var  V	: boolean;
begin
  Valid := inherited Valid(Command) and
	  ((Command <> cmValid) or (WorkingData <> nil));
end;


  { ====================================================================== }


procedure RegisterDMXFORMS;
begin
  RegisterType(RDmxForm);
  RegisterType(RDmxDlgForm);
end;


  { ====================================================================== }


End.
