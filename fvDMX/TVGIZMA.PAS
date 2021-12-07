
{=======================================================}
{							}
{	tvGIZMA   --Turbo Vision Accessories		}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{=======================================================}

Unit tvGIZMA;

//{$B-,O+,R-,V-,X+ }
{$mode Delphi}{$H+}
//{$mode objfpc}{$H+}

interface

uses
    Dos,
    Crt,
    Objects,
    Drivers,
    Memory,
    Dialogs,
    Menus,
    HistList,
    Views,
    App,
    MsgBox,
    RSet,
    DmxGizma;

const
    BeepOn	   : boolean = TRUE;	{ allows beeping from cmBeep event }
    PreserveScreen : boolean = TRUE;	{ restore screen after done }

    SoundIndOn		= ' ON';	{ On & Off must be the same length }
    SoundIndOff		= 'OFF';

type
    PAppA		= ^TAppA;
    PLtdFrame		= ^TLtdFrame;
    PLtdWindow		= ^TLtdWindow;
    PTimeView		= ^TTimeView;
    PUserScreen		= ^TUserScreen;


    TAppA		=  OBJECT(TApplication)
	Clock		: PTimeView;
	SoundInd	: pstring;
	VideoInd	: pstring;
      constructor Init;
      destructor  Done;  VIRTUAL;
      procedure EventError(var Event: TEvent);  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure Idle;  VIRTUAL;
      procedure InitClock;  VIRTUAL;
      function  LoadConfigFile(FName: FNameStr; Header: pstring) : boolean;
      function	NewSoundItem(AHelpCtx: word; ANext: PMenuItem) : PMenuItem;
      function	NewVideoItem(AHelpCtx: word; ANext: PMenuItem) : PMenuItem;
      procedure OutOfMemory;  VIRTUAL;
      procedure ReadConfigData(var S: TStream);  VIRTUAL;
      procedure SaveConfigFile(FName: FNameStr; Header: pstring);
      procedure WriteConfigData(var S: TStream);  VIRTUAL;
      procedure WriteShellMsg;  VIRTUAL;
    end;


    TLtdFrame		=  OBJECT(TFrame)
      procedure Draw;  VIRTUAL;
    end;


    TLtdWindow		=  OBJECT(TWindow)
	Limit	: TRect;
      constructor Init(var Bounds,ALimit: TRect; ATitle: TTitleStr; ANumber: integer);
      constructor Load(var S: TStream);
      procedure ChangeBounds(var Bounds: TRect);  VIRTUAL;
      procedure InitFrame;  VIRTUAL;
      procedure Zoom;  VIRTUAL;
    end;


    TTimeView		=  OBJECT(TView)
	Hour,Min,Sec	: word;
      constructor Init(var Bounds: TRect);
      procedure Draw;  VIRTUAL;
      procedure Update;  VIRTUAL;
    end;


    TUserScreen		=  OBJECT(TScroller)
      constructor Init(var Bounds: TRect; AHScrollBar,AVScrollBar: PScrollBar);
      procedure Draw;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      function	Valid(Command: word) : boolean;  VIRTUAL;
    end;


  function  SParam(S: pstring;  Next: pointer) : pointer;
  function  DParam(N: longint;  Next: pointer) : pointer;
    { accessories for FormatStr() and MessageBox() procedures }


  procedure AssignWinRect(var Bounds: TRect;  MaxX,MaxY: integer);
    { assigns a rectangle which cascades into the desktop }

  function  InsertLine(Dialog: PDialog;  Col,Row,Width,Max: integer;
			Fmt: boolean; ALabel: string; HL: word) : PInputLine;
    { inserts a TInputLine view with (optional) history list }

  function  InsertText(Dialog: PDialog; Col,Row: integer; AText: string) : PView;
    { inserts a single-line standard text view }

  function  NewVarItem(Name, Param: TMenuStr; var Ind: pstring;
			KeyCode, Command, AHelpCtx: word;
			Next: PMenuItem) : PMenuItem;
    { creates a new menu item with a status indicator }

  function  wnNextAvail : integer;
    { finds the lowest available window number }

  procedure TrimDialog(Window: PWindow);
    { resizes a dialog window }

  function  StdMenuHint(AHelpCtx: word) : string;
    { returns a context-sensitive hint string for any the Std????MenuItems
      that were introduced with Turbo Pascal 7.0. }

  function  StdWindowHint(AHelpCtx: word) : string;
    { returns a context-sensitive hint string for StdWindowMenuItems }

  procedure RegisterTVGizma;


const

{$IFDEF VER60 }
    hcNew	= $FF01;
    hcOpen	= $FF02;
    hcSave	= $FF03;
    hcSaveAs	= $FF04;
    hcSaveAll	= $FF05;
    hcChangeDir	= $FF06;
    hcDosShell	= $FF07;
    hcExit	= $FF08;

    hcUndo	= $FF10;
    hcCut	= $FF11;
    hcCopy	= $FF12;
    hcPaste	= $FF13;
    hcClear	= $FF14;

    hcTile	= $FF20;
    hcCascade	= $FF21;
    hcCloseAll	= $FF22;
    hcResize	= $FF23;
    hcZoom	= $FF24;
    hcNext	= $FF25;
    hcPrev	= $FF26;
    hcClose	= $FF27;
{$ENDIF }

    RLtdFrame	:  TStreamRec = (
	ObjType:  rnLtdFrame;
	VmtLink:  ofs(TypeOf(TLtdFrame)^);
	Load:	  @TLtdFrame.Load;
	Store:	  @TLtdFrame.Store
      );

    RLtdWindow	:  TStreamRec = (
	ObjType:  rnLtdWindow;
	VmtLink:  ofs(TypeOf(TLtdWindow)^);
	Load:	  @TLtdWindow.Load;
	Store:	  @TLtdWindow.Store
      );


implementation

const	KeptScreen	  : PVideoBuf = nil;
var	KeptCol, KeptRow  : byte;
	KeptHeight	  : integer;


  { == Param Functions =================================================== }

const	iparmax			= 15;  { max number of parameters - 1 }
	ipar	: integer	= iparmax;

var	Apar	: array[0..iparmax] of pointer;


function  SParam(S: pstring;  Next: pointer) : pointer;
begin
  {$IFOPT R+ }
  If (ipar < 0) then RunError(201);
  {$ENDIF }
  If (Next = nil) then ipar := iparmax;
  Apar[ipar] := S;
  SParam := @Apar[ipar];
  Dec(ipar);
end;


function  DParam(N: longint;  Next: pointer) : pointer;
begin
  {$IFOPT R+ }
  If (ipar < 0) then RunError(201);
  {$ENDIF }
  If (Next = nil) then ipar := iparmax;
  Apar[ipar] := pointer(N);
  DParam := @Apar[ipar];
  Dec(ipar);
end;


  { ====================================================================== }


procedure AssignWinRect(var Bounds: TRect;  MaxX,MaxY: integer);
var  P : PView;
begin
 {$IFDEF VER60 }
  DeskTop^.GetExtent(Bounds);
 {$ELSE }
  PApplication(Application)^.GetTileRect(Bounds);
 {$ENDIF }
  P := DeskTop^.Current;
  If (P <> nil) and (P^.Options and ofTileable = 0) then P := nil;
  If (P <> nil) then
    begin
    If (P^.Origin.X >= Bounds.A.X) and (P^.Origin.X < Bounds.B.X) then Bounds.A.X := succ(P^.Origin.X);
    If (P^.Origin.Y >= Bounds.A.Y) and (P^.Origin.Y < Bounds.B.Y) then Bounds.A.Y := succ(P^.Origin.Y);
    If (Bounds.B.X - Bounds.A.X < MinWinSize.X) or
       (Bounds.B.Y - Bounds.A.Y < MinWinSize.Y) then
      begin
     {$IFDEF VER60 }
      DeskTop^.GetExtent(Bounds);
     {$ELSE }
      PApplication(Application)^.GetTileRect(Bounds);
     {$ENDIF }
      end;
    end;
  If (MaxX > 0) and (Bounds.B.X - Bounds.A.X > MaxX) then Bounds.B.X := Bounds.A.X + MaxX;
  If (MaxY > 0) and (Bounds.B.Y - Bounds.A.Y > MaxY) then Bounds.B.Y := Bounds.A.Y + MaxY;
end;


  { ====================================================================== }


function  InsertLine(Dialog: PDialog;	Col,Row,Width,Max: integer;
		     Fmt: boolean; ALabel: string;  HL: word) : PInputLine;
var  i	: integer;
     R	: TRect;
     B	: PInputLine;
begin
  With Dialog^ do
    begin
    i  := succ(CStrLen(ALabel));
    R.Assign(Col, Row, Col + Width + 2, succ(Row));
    If (ALabel <> '') then
      begin
      If Fmt then R.Move(1, 1) else R.Move(i, 0);
      end;
    B  := New(PInputLine, Init(R, Max));
    Insert(B);
    If (HL > 0) then
      begin
      R.A.X := R.A.X + Width + 2;
      R.B.X := R.A.X + 3;
      Insert(New(PHistory, Init(R, B, HL)));
      end;
    If (ALabel <> '') then
      begin
      R.Assign(Col, Row, Col + i, succ(Row));
      Insert(New(PLabel, Init(R, ALabel, B)));
      end;
    end;
  InsertLine := B;
end;


  { ====================================================================== }


function  InsertText(Dialog: PDialog; Col,Row: integer; AText: string) : PView;
var  R : TRect;
     B : PView;
begin
  With Dialog^ do
    begin
    R.Assign(Col, Row, Col + length(AText), succ(Row));
    B  := New(PStaticText, Init(R, AText));
    Insert(B);
    end;
  InsertText := B;
end;


  { ====================================================================== }


function  NewVarItem(Name, Param: TMenuStr; var Ind: pstring;
		     KeyCode, Command, AHelpCtx: word;
		     Next: PMenuItem) : PMenuItem;
var  P : PMenuItem;
begin
  P := NewItem(Name,Param, KeyCode,Command,AHelpCtx, Next);
  Ind := P^.Param;
  NewVarItem := P;
end;


  { ====================================================================== }


function  wnNextAvail : integer;
var  wn : integer;
    function  UsedWN(P: PWindow) : boolean;  far;
    begin
      UsedWN := (P <> PWindow(DeskTop^.Background)) and (P^.Number = wn)
    end;
begin
  wn := 0;
  Repeat Inc(wn) until (DeskTop^.FirstThat(@UsedWN) = nil);
  wnNextAvail := wn;
end;


  { ====================================================================== }


procedure TrimDialog(Window: PWindow);
var  B	  : TRect;
     MinX : integer;
    procedure FindBounds(P: PView);  far;
    begin
      If (PFrame(P) <> Window^.Frame) and (P^.GetState(sfVisible)) then
	begin
	If (P^.Origin.X < MinX) then MinX := P^.Origin.X;
	If (P^.Options and ofCenterX <> 0) then P^.MoveTo(0, P^.Origin.Y);
	If (P^.Size.X + P^.Origin.X > B.B.X) then B.B.X := P^.Size.X + P^.Origin.X;
	If (P^.Size.Y + P^.Origin.Y > B.B.Y) then B.B.Y := P^.Size.Y + P^.Origin.Y;
	P^.GrowMode := 0;
	end;
    end;
    procedure ReCenter(P: PView);  far;
    begin
      If (P^.Options and ofCenterX <> 0) and (PFrame(P) <> Window^.Frame) and
	 (Window^.Size.X > P^.Size.X) then
	P^.MoveTo(((Window^.Size.X - P^.Size.X) shr 1), P^.Origin.Y);
    end;
begin
  If (Window = nil) then Exit;
  B.Assign(0,0,10,0);
  If (Window^.Title <> nil) then B.B.X := 12 + length(Window^.Title^);
  MinX := 999;
  Window^.ForEach(@FindBounds);
  If (MinX = 999) then MinX := 2;
  B.B.X := B.B.X + MinX + 1;
  B.B.Y := B.B.Y + 1;
  If (B.B.X > Window^.Size.X) then B.B.X := Window^.Size.X;
  If (B.B.Y > Window^.Size.Y) then B.B.Y := Window^.Size.Y;
  Window^.GrowTo(B.B.X, B.B.Y);
  Window^.ForEach(@ReCenter);
  Window^.Options := Window^.Options or ofCentered;
  Window^.DrawView;
end;


  { ====================================================================== }


function  StdMenuHint(AHelpCtx: word) : string;
begin
  Case AHelpCtx of
    hcNew:	StdMenuHint := 'Create a new file in a new window';
    hcOpen:	StdMenuHint := 'Locate and open a file in a new window';
    hcSave:	StdMenuHint := 'Save the file in the active window';
    hcSaveAs:	StdMenuHint := 'Save the current file under a different name, directory or drive';
    hcSaveAll:	StdMenuHint := 'Save all modified files';
    hcChangeDir:StdMenuHint := 'Choose a new default directory';
    hcDosShell:	StdMenuHint := 'Temporarily exit to DOS';
    hcExit:	StdMenuHint := 'Exit program';

    hcUndo:	StdMenuHint := 'Undo the previous editor operation';
    hcCut:	StdMenuHint := 'Remove the selected text and put it in the clipboard';
    hcCopy:	StdMenuHint := 'Copy the selected text into the clipboard';
    hcPaste:	StdMenuHint := 'Insert the selected text from the clipboard at the cursor position';
    hcClear:	StdMenuHint := 'Delete the selected text';

    hcTile:	StdMenuHint := 'Arrange windows on desktop by tiling';
    hcCascade:	StdMenuHint := 'Arrange windows on desktop by cascading';
    hcCloseAll:	StdMenuHint := 'Close all windows on the desktop';
    hcResize:	StdMenuHint := 'Change the size or position of the active window';
    hcZoom:	StdMenuHint := 'Enlarge or restore the size of the active window';
    hcNext:	StdMenuHint := 'Make the next window active';
    hcPrev:	StdMenuHint := 'Make the previous window active';
    hcClose:	StdMenuHint := 'Close the active window';
   else		StdMenuHint := '';
    end;
end;


function  StdWindowHint(AHelpCtx: word) : string;
begin
  Case AHelpCtx of
    hcTile:	StdWindowHint := 'Arrange windows on desktop by tiling';
    hcCascade:	StdWindowHint := 'Arrange windows on desktop by cascading';
    hcCloseAll:	StdWindowHint := 'Close all windows on the desktop';
    hcResize:	StdWindowHint := 'Change the size or position of the active window';
    hcZoom:	StdWindowHint := 'Enlarge or restore the size of the active window';
    hcNext:	StdWindowHint := 'Make the next window active';
    hcPrev:	StdWindowHint := 'Make the previous window active';
    hcClose:	StdWindowHint := 'Close the active window';
   else		StdWindowHint := '';
    end;
end;


  { == TAppA ============================================================= }


constructor TAppA.Init;
begin
  InitMemory;
  InitVideo;
  //If PreserveScreen and (StartupMode = ScreenMode) then
  If PreserveScreen then
    begin
   {$IFDEF VER60 }
    GetBufMem(pointer(KeptScreen), sizeof(TVideoBuf));
   {$ELSE }
    NewCache(pointer(KeptScreen), sizeof(TVideoBuf));
   {$ENDIF }
    If (KeptScreen <> nil) then Move(ScreenBuffer^, KeptScreen^, sizeof(KeptScreen^));
    KeptCol := WhereX;
    KeptRow := WhereY;
    KeptHeight := ScreenHeight;
    end
   else
    KeptScreen := nil;
  InitEvents;
  InitSysError;
  InitHistory;
  TProgram.Init;
  InitClock;
  Insert(Clock);
  If (VideoInd <> nil) then Str(ScreenHeight:length(VideoInd^), VideoInd^);
end;


destructor TAppA.Done;
begin
  If (Clock <> nil) then Dispose(Clock, Done);
  TProgram.Done;
  DoneHistory;
  DoneSysError;
  DoneEvents;
  DoneVideo;
  If PreserveScreen and (KeptScreen <> nil) then
    begin
    Move(KeptScreen^, ScreenBuffer^, sizeof(KeptScreen^));
    GotoXY(KeptCol, KeptRow);
    end
   else
    PrintStr(#27'[J'^M'   '^M);  { clear screen with ANSI colors if possible }
  If (KeptScreen <> nil) then
    begin
   {$IFDEF VER60 }
    FreeBufMem(KeptScreen);
   {$ELSE }
    DisposeCache(KeptScreen);
   {$ENDIF }
    KeptScreen := nil;
    end;
  DoneMemory;
end;


procedure TAppA.EventError(var Event: TEvent);
var  k : boolean;
begin
  With Event do
    If (What = evKeyDown) and (Current = PView(DeskTop)) then
      begin
      k := TRUE;
      Case KeyCode of
	kbUp,kbLeft,kbCtrlLeft:		KeyCode := kbShiftTab;
	kbDown,kbRight,kbCtrlRight:	KeyCode := kbTab;
       else				k := FALSE;
	end;
      If k then
	begin
	PutEvent(Event);
	ClearEvent(Event);
	end;
      end;
  If (Event.What <> evNothing) then TApplication.EventError(Event);
end;


procedure TAppA.HandleEvent(var Event: TEvent);
var  R : TRect;
     M : word;

    procedure DeskTopCommand;
    begin
      Desktop^.Lock;
     {$IFDEF VER60 }
      DeskTop^.GetExtent(R);
     {$ELSE }
      GetTileRect(R);
     {$ENDIF }
      Case Event.Command of
	cmCascade:	Desktop^.Cascade(R);
	cmTile:		Desktop^.Tile(R);
	end;
      Message(Desktop, evBroadcast, cmDMX_FixSize, @Self);
      Desktop^.Unlock;
    end;

    procedure ShowUserScreen;
    var  Dialog : PDialog;
    begin
      GetExtent(R);
      Dialog := New(PDialog, Init(R, 'User Screen'));
      Dialog^.Insert(New(PUserScreen, Init(R, nil,nil)));
      If (ValidView(Dialog) <> nil) then
	begin
	ExecView(Dialog);
	Dispose(Dialog, Done);
	end;
    end;

    procedure DoBeep;
    begin
      If BeepOn then
	begin
	Sound(523);
	Delay(50);
	NoSound;
	end;
    end;

begin
  {$IFNDEF VER60 }
  If (Event.What = evCommand) and (Event.Command = cmDosShell) and
     (KeptScreen <> nil)
   then
    begin
    DisposeCache(KeptScreen);
    KeptScreen := nil;
    end;
  {$ENDIF }
  TApplication.HandleEvent(Event);
  If (Event.What = evCommand) then
    begin
    Case Event.Command of
      cmCascade,cmTile:		DeskTopCommand;
      cmBeep,cmDMX_WrongKey:	DoBeep;
      cmToggleSound:
	begin
	BeepOn := not BeepOn;
	If (SoundInd <> nil) then
	  begin
	  If BeepOn then SoundInd^ := SoundIndOn else SoundInd^ := SoundIndOff;
	  end;
	end;
      cmToggleVideo:
	begin
	//M := ScreenMode xor smFont8x8;
	M := smFont8x8;
	If (M and smFont8x8 = 0) then ShadowSize.X := 2 else ShadowSize.X := 1;
	SetScreenMode(M);
	If (VideoInd <> nil) then Str(ScreenHeight:length(VideoInd^), VideoInd^);
	end;
      cmUserScreen:	ShowUserScreen;
     else		Exit;
      end;
    ClearEvent(Event);
    end;
end;


procedure TAppA.Idle;
var  M : word;
     E : TEvent;

    function  IsTileable(P: PView) : boolean;  far;
    begin
      IsTileable := (P^.Options and ofTileable <> 0) and P^.GetState(sfVisible);
    end;

  {$IFNDEF VER60 }
    function  IsCloseable(P: PWindow) : boolean;  far;
    begin
      IsCloseable := (pointer(DeskTop^.Background) <> P)
		 and (P^.Flags and wfClose <> 0) and P^.GetState(sfVisible);
    end;
  {$ENDIF }

begin
  TApplication.Idle;
  If (Desktop^.FirstThat(@IsTileable) <> nil) then
    EnableCommands([cmTile, cmCascade])
   else
    DisableCommands([cmTile, cmCascade]);

  {$IFNDEF VER60 }
  If (Desktop^.FirstThat(@IsCloseable) <> nil) then
    EnableCommands([cmCloseAll])
   else
    DisableCommands([cmCloseAll]);
  {$ENDIF }

  If (Current = PView(DeskTop)) and (DeskTop^.Current = nil) then
    begin
    E.What	:= evCommand;
    E.Command	:= cmMenu;
    E.InfoPtr	:= @Self;
    PutEvent(E);
    end;
  If (Clock <> nil) then Clock^.Update;
end;


procedure TAppA.InitClock;
var  R : TRect;
begin
  GetExtent(R);
  Dec(R.B.X);
  R.A.X := R.B.X - 8;
  R.B.Y := R.A.Y + 1;
  Clock := New(PTimeView, Init(R));
end;


function  TAppA.LoadConfigFile(FName: FNameStr; Header: pstring) : boolean;
var  S	: TBufStream;
     E	: longint;
begin
  S.Init(FName, stOpenRead, 1024);
  If (Header <> nil) then S.Seek(length(Header^));
  If (S.Status = stOK) then ReadConfigData(S);
  If (S.Status <> stOK) and (S.ErrorInfo <> 2) then
    begin
    E := S.ErrorInfo;
    MessageBox('Error (#%d) reading config file.', @E, mfError or mfOKButton);
    end;
  LoadConfigFile := (S.Status = stOK) or (S.ErrorInfo <> 2);
  S.Done;
end;


function  TAppA.NewSoundItem(AHelpCtx: word; ANext: PMenuItem) : PMenuItem;
begin
  NewSoundItem := NewVarItem('~S~ound', SoundIndOn, SoundInd, kbNoKey,
				cmToggleSound, AHelpCtx, ANext);
end;


function  TAppA.NewVideoItem(AHelpCtx: word; ANext: PMenuItem) : PMenuItem;
begin
  If HiResScreen then
    NewVideoItem := NewVarItem('~V~ideo mode', '    ', VideoInd, kbNoKey,
				cmToggleVideo, AHelpCtx, ANext)
   else
    NewVideoItem := ANext;
end;


procedure TAppA.OutOfMemory;
begin
  MessageBox('Not enough memory for this operation.', nil, mfError + mfOKButton);
end;


procedure TAppA.ReadConfigData(var S: TStream);
var  Vid : word;
     Snd : boolean;
begin
  S.Read(Vid, sizeof(Vid));
  S.Read(Snd, sizeof(Snd));
  If (S.Status = stOK) then
    begin
  {$IFNDEF VER60 }
    LoadHistory(S);
  {$ENDIF }
    If (Snd <> BeepOn) then
      begin
      BeepOn := Snd;
      If (SoundInd <> nil) then
	begin
	If BeepOn then SoundInd^ := SoundIndOn else SoundInd^ := SoundIndOff;
	end;
      end;
    //If HiResScreen and (Vid <> ScreenMode) then
    If HiResScreen then
      begin
      //Vid := ScreenMode xor smFont8x8;
      Vid := smFont8x8;
      If (Vid and smFont8x8 = 0) then ShadowSize.X := 2 else ShadowSize.X := 1;
      SetScreenMode(Vid);
      If (VideoInd <> nil) then Str(ScreenHeight:length(VideoInd^), VideoInd^);
      end;
    end;
end;


procedure TAppA.SaveConfigFile(FName: FNameStr; Header: pstring);
var  S	: TBufStream;
     E	: longint;
begin
  S.Init(FName, stCreate, 1024);
  If (Header <> nil) then S.Write(Header^[1], length(Header^));
  If (S.Status = stOK) then WriteConfigData(S);
  If (S.Status <> stOK) then
    begin
    E := S.ErrorInfo;
    MessageBox('Error (#%d) writing config file.', @E, mfError or mfOKButton);
    end;
  S.Done;
end;


procedure TAppA.WriteConfigData(var S: TStream);
begin
  S.Write(ScreenMode, sizeof(ScreenMode));
  S.Write(BeepOn, sizeof(BeepOn));
  {$IFNDEF VER60 }
  StoreHistory(S);
  {$ENDIF }
end;


procedure TAppA.WriteShellMsg;
begin
  PrintStr(#27'[J'^M'   '^M'Type EXIT to return to program...'^M^J);
end;


  { == TLtdFrame ========================================================= }


procedure TLtdFrame.Draw;
{ draws a zoom icon if the LtdWindow is at maximum size }
var XY : TPoint;
begin
  TFrame.Draw;
  If (State and sfActive <> 0) and (Owner <> nil) and (PWindow(Owner)^.Flags and wfZoom <> 0) then
    begin
    If (PLtdWindow(Owner)^.Limit.B.X > 0) then
      XY.X := PLtdWindow(Owner)^.Limit.B.X else XY.X := Owner^.Owner^.Size.X;
    If (PLtdWindow(Owner)^.Limit.B.Y > 0) then
      XY.Y := PLtdWindow(Owner)^.Limit.B.Y else XY.Y := Owner^.Owner^.Size.Y;
    If (Size.X >= XY.X) and (Size.Y >= XY.Y) then
      WriteStr((Size.X - 4), 0, #18, 5);
    end;
end;


  { == TLtdWindow ======================================================== }


constructor TLtdWindow.Init(var Bounds,ALimit	: TRect;
				ATitle		: TTitleStr;
				ANumber		: integer);
begin
  TWindow.Init(Bounds, ATitle, ANumber);
  Move(ALimit, Limit, sizeof(Limit));
end;


constructor TLtdWindow.Load(var S: TStream);
begin
  TWindow.Load(S);
  S.Read(Limit, sizeof(Limit));
end;


procedure TLtdWindow.ChangeBounds(var Bounds: TRect);
begin
  If (Limit.A.X > 0) and (Bounds.B.X - Bounds.A.X <= Size.X - Limit.A.X) then
    Bounds.B.X := Bounds.A.X + succ(Limit.A.X);
  If (Limit.A.Y > 0) and (Bounds.B.Y - Bounds.A.Y <= Size.Y - Limit.A.Y) then
    Bounds.B.Y := Bounds.A.Y + succ(Limit.A.Y);
  If (Limit.B.X > 0) and (Bounds.B.X - Bounds.A.X > Limit.B.X) then Bounds.B.X := Bounds.A.X + Limit.B.X;
  If (Limit.B.Y > 0) and (Bounds.B.Y - Bounds.A.Y > Limit.B.Y) then Bounds.B.Y := Bounds.A.Y + Limit.B.Y;
  TWindow.ChangeBounds(Bounds);
end;


procedure TLtdWindow.InitFrame;
var R : TRect;
begin
  GetExtent(R);
  Frame := New(PLtdFrame, Init(R));
end;


procedure TLtdWindow.Zoom;
var R  : TRect;
    XY : TPoint;
begin
  If (Limit.B.X = 0) or (Limit.B.X > Owner^.Size.X) then
    XY.X := Owner^.Size.X else XY.X := Limit.B.X;
  If (Limit.B.Y = 0) or (Limit.B.Y > Owner^.Size.Y) then
    XY.Y := Owner^.Size.Y else XY.Y := Limit.B.Y;
  If ((Size.X <> XY.X) or (Size.Y <> XY.Y)) then
    begin
    GetBounds(ZoomRect);
    Owner^.GetExtent(R);
    Locate(R);
    end
   else
    Locate(ZoomRect);
end;


  { == TTimeView ========================================================= }


constructor TTimeView.Init(var Bounds: TRect);
begin
  TView.Init(Bounds);
  Min := 99;
  Update;
end;


procedure TTimeView.Draw;
var  B : TDrawBuffer;
     C : word;
     H : word;
     A,Suffix : string;
begin
  Suffix := ' pm';
  H  := Hour mod 12;
  If (Hour < 12) then Suffix[2] := 'a';
  If (H = 0) then H := 12;
  Str((H * 1000) + Min:5, A);
  A[3] := ':';
  A := A + Suffix;
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, A, C);
  WriteLine(0, 0, Size.X, 1, B);
end;


procedure TTimeView.Update;
var  H,M,T : word;
begin
  GetTime(H,M,Sec,T);
  If (Hour <> H) or (Min <> M) then
    begin
    Hour := H;
    Min  := M;
    DrawView;
    If (Sec = 0) and (Min in [0,30]) then
      Message(Application, evBroadcast, cmChime, @Self);
    end;
end;


  { == TUserScreen ======================================================= }


constructor TUserScreen.Init(var Bounds: TRect; AHScrollBar,AVScrollBar: PScrollBar);
var  Width,Height : integer;
begin
  TScroller.Init(Bounds, AHScrollBar,AVScrollBar);
  Width  := 80;
  Height := KeptHeight;
  If (StartupMode in [0,1]) then Width := 40;
  SetCursor(pred(KeptCol), pred(KeptRow));
  If (KeptScreen = nil) then Height := 0;
  GrowMode := gfGrowHiX or gfGrowHiY;
  SetLimit(Width,Height);
end;


procedure TUserScreen.Draw;
var  i, Y : integer;
     B	  : TDrawBuffer;
begin
  If (KeptScreen = nil) then Limit.Y := 0;
  For Y := 0 to Size.Y - 1 do
    begin
    FillChar(B, sizeof(B), 0);
    i := Delta.Y + Y;
    If (i < Limit.Y) then
      Move(KeptScreen^[(i * Limit.X) + Delta.X], B, Limit.X shl 1);
    WriteLine(0, Y, Size.X, 1, B);
    end;
  If (Limit.Y > 0) then ShowCursor;
end;


procedure TUserScreen.HandleEvent(var Event: TEvent);
begin
  TScroller.HandleEvent(Event);
  If (Owner^.State and sfModal <> 0) and (Event.What in [evKeyDown,evMouseDown]) then
    begin
    Owner^.EndModal(cmCancel);
    ClearEvent(Event);
    end;
end;


function  TUserScreen.Valid(Command: word) : boolean;
begin
  If (Command = cmValid) and (KeptScreen = nil) then
    begin
    MessageBox('User screen was not preserved.', nil, mfError + mfOKButton);
    Valid := FALSE;
    end
   else
    Valid := TScroller.Valid(Command);
end;


  { ====================================================================== }


procedure RegisterTVGizma;
begin
  RegisterType(RLtdFrame);
  RegisterType(RLtdWindow);
end;


  { ====================================================================== }


End.
