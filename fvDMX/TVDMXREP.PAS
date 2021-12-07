
{=======================================================}
{							}
{	tvDMXREP  --tvDMX Data Reporting Objects	}
{	tvDMX	  --data editing project		}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{=======================================================}

Unit tvDMXREP;

//{$V-,X+,B-,R-,I- }
{$mode Delphi}{$H+}
//{$mode objfpc}{$H+}


interface

uses
  Dos,
  Objects,
  Drivers,
  Memory,
  Views,
  Dialogs,
  Menus,
  App,
  MsgBox,
  RSet,
  DmxGizma,
  tvGizma,
  tvDMX,
  StdDMX;

const
    NewLineStr	:  string[7] =	^M^J;
    NewPageStr	:  string[7] =	^L;

    { Output Options }
    repExtChars	=   1;	{ Allow extended characters }
    repLineNums	=   2;	{ Display record/line numbers }
    repCrLf	=   4;	{ Line feed on carriage return }
    repPgFeed	=   8;	{ Manual page feed }

    { stand-ins for printing extended characters }
    prnRadioBtn	: char	= '*';	{ DMX RadioButton ON indicator }
    prnCheckBox	: char	= 'X';	{ DMX CheckBox ON indicator }
    prnOVERFLOW	: char	= '*';	{ TRUE indicator }
    prnTRUE	: char	= '*';	{ TRUE indicator }
    prnFALSE	: char	= ' ';	{ FALSE indicator }
    prnBlock	: char	= ':';	{ Block character }
    prnUnprintable:char	= '.';	{ out of printable range }


type
    PDmxReport	= ^TDmxReport;
    TDmxReport	=  OBJECT(TObject)
	Owner		: PView;
	DMX		: PDmxScroller;
	Delimiter	: char;
	LineNums	: boolean;
	CurPos		: integer;
	LeftMargin	: integer;
	RightMargin	: integer;
	PageWidth	: integer;
	PageSize	: integer;
	CurrentPage	: integer;
	CurrentLine	: integer;
	CurrentRecord	: integer;
	LastRecord	: integer;
	MarginHit	: boolean;
	ErrorInfo	: word;
      constructor Init(aDMX : PDmxScroller;  ADelimiter : char;
			ALineNums : boolean;  APageSize,APageWidth : integer);
      procedure NewLine;
      procedure PrintCtrl(St : string);
      procedure DoPrint(var Buf;  Count : word);
      procedure GotoPos(Pos : integer);
      procedure Print(var Buf;	Count : word);	VIRTUAL;
      procedure SetupPage;  VIRTUAL;
      procedure EndPage;  VIRTUAL;
      procedure SetupDMX;  VIRTUAL;
      procedure EndDMX;  VIRTUAL;
      procedure SetupLine;  VIRTUAL;
      procedure EndLine;  VIRTUAL;
      function	RecNumStr(RecNum : integer) : string;  VIRTUAL;
      procedure PrintStr(St : string);
      procedure PrintLabels;  VIRTUAL;
      procedure PrintLn(St : string);
      procedure PrintRec;
      procedure PrintRows;
      procedure Run;  VIRTUAL;
    end;


    PDmxReportFile  = ^TDmxReportFile;
    TDmxReportFile  =  OBJECT(TDmxReport)
	ReportText	: Text;
      constructor Init(aDMX : PDmxScroller;  ADelimiter : char;
			ALineNums : boolean;  APageSize,APageWidth : integer;
			AFilename : FNameStr);
      destructor  Done;  VIRTUAL;
      procedure Print(var Buf;	Count : word);	VIRTUAL;
    end;


    PDmxReportStream  = ^TDmxReportStream;
    TDmxReportStream  =  OBJECT(TDmxReport)
	Stream		: PStream;
      constructor Init(aDMX : PDmxScroller;  ADelimiter : char;
			ALineNums : boolean;  APageSize,APageWidth : integer;
			AStream : PStream);
      procedure Print(var Buf;	Count : word);	VIRTUAL;
    end;


    TPrnOpt	= RECORD  { dialog box's data for printer-options }
	Dest	: word;
	FName	: string[23];
	Options	: word;
	Len,Wid	: word;
    end;


    _TAppPrn	=  OBJECT(TAppA)
    end;

    TAppPrn	=  OBJECT(_TAppPrn)
      procedure HandleEvent(var Event : TEvent);  VIRTUAL;
      function	StdPrnMenuItems(AHelpCtx : word;  ANext : PMenuItem): PMenuItem;
      procedure ReadConfigData(var S: TStream);  VIRTUAL;
      procedure WriteConfigData(var S: TStream);  VIRTUAL;
    end;


var   PrnOpt	:  TPrnOpt;

  procedure DmxReportBoxRect(var R :TRect;  ATitle :TTitleStr; Msg :string; Report :PDmxReport);
  procedure DmxReportBox(ATitle :TTitleStr; Msg :string; Report :PDmxReport);

  procedure PrnCurrentDMX;
  procedure PrnPageStart(var Event : TEvent);
  procedure PrnPageEnd(var Event : TEvent);
  function  PrnSetOptions(AHelpCtx,AOKCtx,ACancelCtx : word) : word;


implementation

  { == TDmxReport ======================================================== }


constructor TDmxReport.Init(aDMX : PDmxScroller;  ADelimiter : char;
		ALineNums : boolean;  APageSize,APageWidth : integer);
begin
  TObject.Init;
  DMX		:= aDMX;
  Delimiter	:= ADelimiter;
  LineNums	:= ALineNums;
  PageSize	:= APageSize;
  PageWidth	:= APageWidth;
  If (DMX <> nil) and (DMX^.RecordSize > 0) then LastRecord := DMX^.RecordLimit;
end;


procedure TDmxReport.NewLine;
begin
  PrintCtrl(NewLineStr)
end;


procedure TDmxReport.PrintCtrl(St : string);
var  i,j,x : integer;
    procedure IncPos;
    begin
      inc(j);
      If (j <= LeftMargin) or (j >= RightMargin) then
	begin
	Delete(St,i,1);
	Dec(i);
	end;
    end;
    procedure DecPos;
    begin
      dec(j);
      If (j >= LeftMargin) or (j <= RightMargin) then
	begin
	Delete(St,i,1);
	Dec(i);
	end;
    end;
begin
  If CtrlBreakHit then Exit;
  j := CurPos;
  If (length(St) > 0) then
    begin
    i := 1;
    While (i <= length(St)) do
      begin
      Case St[i] of
	^H :  DecPos;
	^I :
	  begin
	  x := j;
	  Repeat inc(x) until (x mod 8 = 0);
	  If (j < LeftMargin) or (x > RightMargin) then
	    begin
	    Delete(St,i,1);
	    Dec(i);
	    Repeat
	      inc(j);
	      If (j > LeftMargin) and (j < RightMargin) then
		begin
		inc(i);
		Insert(' ',St,i);
		end;
	    Until (j mod 8 = 0);
	    end
	   else
	    j := x;
	  end;
	^J :
	  begin
	  inc(CurrentLine);
	  end;
	^L :
	  begin
	  inc(CurrentPage);
	  CurrentLine := 0;
	  j := 0;
	  end;
	^M :
	  begin
	  j := 0;
	  If (NewLineStr = ^M) then inc(CurrentLine);
	  end;
       else  IncPos;
	end;
      inc(i);
      end;
    If (length(St) > 0) then Print(St[1], length(St));
    CurPos := j;
    end;
  If (Application <> nil) then Application^.Idle;
end;


procedure TDmxReport.DoPrint(var Buf;  Count : word);
var  i,j : integer;
     x	 : integer;
     P	 : PCharArray;
     L	 : longint;
begin
  If (Count = 0) or CtrlBreakHit then Exit;
  P := @Buf;
  L := Count;
  x := CurPos + Count;
  While (CurPos < LeftMargin) and (L > 0) do
    begin
    //inc(ptrrec(P).ofs);
    P := Pointer(PtrUInt(P) + 1);
    dec(L);
    inc(CurPos);
    end;
  i := x;
  While (i > RightMargin) and (L > 0) do
    begin
    dec(L);
    dec(i);
    MarginHit := TRUE;
    end;
  If (L > 0) then Print(P^, L);
  CurPos := x;
end;


procedure TDmxReport.GotoPos(Pos : integer);
begin
  While (CurPos < Pos) do PrintCtrl(' ');
  While (CurPos > Pos) do PrintCtrl(^H);
end;


procedure TDmxReport.Print(var Buf;  Count : word);
begin
  Abstract
end;


procedure TDmxReport.SetupPage;
begin
end;


procedure TDmxReport.EndPage;
begin
  PrintCtrl(NewPageStr);
end;


procedure TDmxReport.SetupDMX;
var  i : integer;
     S : string;
begin
  S := RecNumStr(1) + 'ออ';
  If (Delimiter = #0) or (Delimiter >= #127) then S[1] := 'อ' else S[1] := '-';
  If LineNums and (length(S) > 2) then
    begin
    FillChar(S[1], length(S), S[1]);
    PrintStr(S);
    end;
  If (DMX^.Limit.X > 0) then For i := 1 to DMX^.Limit.X do PrintStr(S[1]);
  NewLine;
end;


procedure TDmxReport.EndDMX;
begin
  SetupDMX;  { print the same divider line }
end;


procedure TDmxReport.SetupLine;
begin
end;


procedure TDmxReport.EndLine;
begin
  NewLine
end;


function  TDmxReport.RecNumStr(RecNum : integer) : string;
begin
  RecNumStr := DMX^.RecNumStr(RecNum)
end;


procedure TDmxReport.PrintStr(St : string);
begin
  If (length(St) > 0) then DoPrint(St[1], length(St));
end;


procedure TDmxReport.PrintLabels;
begin
  If (DMX^.Labels <> nil) then With PDmxLabels(DMX^.Labels)^ do
    begin
    DoPrint(Data^, Len);
    end;
end;


procedure TDmxReport.PrintLn(St : string);
begin
  PrintStr(St);
  NewLine;
end;


procedure TDmxReport.PrintRec;
var  i		: integer;
     Color	: word;
     A		: string;
     fieldrec	: pDMXfieldrec;
     DataRec	: pointer;
begin
  Color	:= 0;
  If (CurrentRecord < 0) or (CurrentRecord >= LastRecord) then
    DataRec := nil
   else
    DataRec := DMX^.DataAt(CurrentRecord);
  fieldrec := DMX^.DMXfield1;
  While (fieldrec <> nil) do
    begin
    With fieldrec^ do
      begin
      If (access and accHidden = 0) then
	begin
	If access and accDelimiter <> 0 then
	  begin
	  If (typecode >= #127) and (Delimiter <> #0) then
	    A := Delimiter else A := typecode;
	  end
	 else
	  begin
	  If (DataRec = nil) then
	    begin
	    //A[0] := char(fieldrec^.shownwid);
	    SetLength(A, fieldrec^.shownwid);
	    fillchar(A[1], length(A), ' ');
	    end
	   else
	    begin
	    A	:= FieldString(fieldrec,[], DataRec^);
	    DMX^.FieldText(A, Color, fieldrec, DataRec^);
	    //A[0] := char(fieldrec^.shownwid);
	    SetLength(A, fieldrec^.shownwid);
	    end;
	  For i := 1 to length(A) do
	    If (A[i] <= #31) or ((Delimiter <> #0) and (A[i] >= #127)) then
	      begin
	      If (A[i] = showRadioBtn)  then A[i] := prnRadioBtn
	      else
	      If (A[i] = showCheckBox)  then A[i] := prnCheckBox
	      else
	      If (A[i] = showTRUE)	then A[i] := prnTRUE
	      else
	      If (A[i] = showFALSE)	then A[i] := prnFALSE
	      else
	      If (A[i] = showOVERFLOW)	then A[i] := prnOVERFLOW
	      else
		begin
		Case A[i] of
		  'อ':			A[i] := '=';
		  'ฤ':			A[i] := '-';
		  'ฐ','ฑ','ฒ','Û':	A[i] := prnBlock;
		  #0:			A[i] := ' ';
		  //#1..#31, #127..#255:	A[i] := prnUnprintable;
		  //end;
                else
                  A[i] := prnUnprintable;
                end;
		end;
	      end;
	  end;
	PrintStr(A);
	end;
      end;
    fieldrec := fieldrec^.Next;
    end;
end;


procedure TDmxReport.PrintRows;
var  Recs : integer;
     Line : string;
     F	  : pDMXfieldrec;
begin
  SetupDMX;
  Recs := CurrentRecord + PageSize;
  F := DMX^.DMXfield1;
  While (CurrentRecord < Recs) and (not CtrlBreakHit) do
    begin
    SetupLine;
    If LineNums then
      begin
      Line := RecNumStr(CurrentRecord) + 'ณ ';
      If (length(Line) > 2) then
	begin
	If (Delimiter <> #0) then Line[length(Line) - 1] := Delimiter;
	PrintStr(Line);
	end;
      end;
    PrintRec;
    EndLine;
    Inc(CurrentRecord);
    end;
  If not CtrlBreakHit then EndDMX;
end;


procedure TDmxReport.Run;
var  i,n : integer;
     b	 : boolean;
     S	 : string;
     P	 : PView;
begin
  If (DMX^.Owner <> nil) then P := DMX^.Owner else P := DMX;
  CtrlBreakHit	:= FALSE;
  While (CurrentRecord < LastRecord) and (not CtrlBreakHit) do
    begin
    LeftMargin	:= 0;
    RightMargin := PageWidth;
    n := CurrentRecord;
    Repeat
      MarginHit := FALSE;
      CurPos	:= 0;
      If (Application <> nil) then
	Message(Application, evCommand, cmPRN_NewPage, @Self);
      If (P^.State and sfActive = 0) then
	Message(P, evCommand, cmPRN_NewPage, @Self);
      SetupPage;
      If (DMX^.Labels <> nil) then
	begin
	S := RecNumStr(1) + '  ';
	If LineNums and (length(S) > 2) then
	  begin
	  FillChar(S[1], length(S), ' ');
	  If (Delimiter <> #0) then S[length(S) - 1] := Delimiter;
	  PrintStr(S);
	  end;
	PrintLabels;
	NewLine;
	end;
      PrintRows;
      If not CtrlBreakHit then
	begin
	If (DMX^.State and sfActive = 0) then
	  b := (Message(DMX, evCommand, cmPRN_EndPage, @Self) = nil)
	 else
	  b := TRUE;
	If b and (Application <> nil) then
	  Message(Application, evCommand, cmPRN_EndPage, @Self);
	If not CtrlBreakHit then EndPage;
	end;
      If MarginHit then
	begin
	Inc(RightMargin, PageWidth);
	Inc(LeftMargin,  PageWidth);
	Dec(CurrentPage);
	CurrentRecord := n;
	end;
    Until CtrlBreakHit or not MarginHit;
    end;
end;


  { == TDmxReportFile ==================================================== }


constructor TDmxReportFile.Init(aDMX : PDmxScroller;  ADelimiter : char;
			ALineNums : boolean; APageSize,APageWidth : integer;
			AFilename : FNameStr);
begin
  TDmxReport.Init(aDMX, ADelimiter, ALineNums, APageSize,APageWidth);
  Assign(ReportText, AFilename);
  Append(ReportText);
  ErrorInfo := IOResult;
  If (ErrorInfo <> 0) then
    begin
    ReWrite(ReportText);
    ErrorInfo := IOResult;
    end;
end;


destructor TDmxReportFile.Done;
begin
  Close(ReportText);
  TDmxReport.Done;
end;


procedure TDmxReportFile.Print(var Buf;  Count : word);
//var  Reg : registers;
begin
  //If (ErrorInfo = 0) and (Count > 0) then
  //  begin
  //  With Reg do
  //    begin
  //    DS := seg(Buf);
  //    DX := ofs(Buf);
  //    CX := Count;
  //    BX := textrec(ReportText).Handle;
  //    AX := $4000;
  //    end;
  //  MsDos(Reg);
  //  If (Reg.Flags and FCarry <> 0) then ErrorInfo := Reg.AX;
  //  end;
end;


  { == TDmxReportStream ================================================== }


constructor TDmxReportStream.Init(aDMX : PDmxScroller;	ADelimiter : char;
			ALineNums : boolean;  APageSize,APageWidth : integer;
			AStream : PStream);
begin
  TDmxReport.Init(aDMX, ADelimiter, ALineNums, APageSize,APageWidth);
  Stream := AStream;
end;


procedure TDmxReportStream.Print(var Buf;  Count : word);
begin
  Stream^.Write(Buf, Count);
  If (Stream^.ErrorInfo <> stOK) then ErrorInfo := Stream^.ErrorInfo;
end;


  { ====================================================================== }

type
    PBlueText	= ^TBlueText;
    TBlueText	=  OBJECT(TStaticText)
      function	GetPalette : PPalette;	VIRTUAL;
    end;


function  TBlueText.GetPalette : PPalette;
const CBlueText : string[1] = #19;
begin
  GetPalette := @CBlueText;
end;


procedure DmxReportBoxRect(var R : TRect;  ATitle : TTitleStr;
			   Msg : string; Report : PDmxReport);
var  Rect	: TRect;
     View	: PStaticText;
     ECode	: longint;
     Watch	: PDialog;
begin
  If (Report <> nil) and (Report^.DMX <> nil) and
     (Report^.DMX^.RecordLimit > 0) then
    begin
    Watch := New(PDialog, Init(R, ATitle));
    //If (longint(R.A) = 0) then Watch^.Options := Watch^.Options or ofCentered;
    If ((R.A.X = 0) and (R.A.Y = 0)) then Watch^.Options := Watch^.Options or ofCentered;
    Watch^.Flags := 0;

    Rect.Assign(3, 2, Watch^.Size.X - 2, Watch^.Size.Y - 3);
    Watch^.Insert(New(PStaticText, Init(Rect, Msg)));

    Rect.Assign(1, Watch^.Size.Y - 2, Watch^.Size.X - 1, Watch^.Size.Y - 1);
    Watch^.Insert(New(PBlueText, Init(Rect, ^C'Press Ctrl-Break to cancel')));

    DeskTop^.Insert(Watch);
    Report^.Owner := Watch;
    Report^.Run;
    DeskTop^.Delete(Watch);
    Report^.Owner := nil;
    Dispose(Watch, Done);
    If (Report^.ErrorInfo <> 0) then
      begin
      ECode := Report^.ErrorInfo;
      MessageBox('Device error: %d.', @ECode, mfError or mfOKButton);
      end;
    CtrlBreakHit := FALSE;
    end
   else
    MessageBox('No data for reporting.', nil, mfError or mfOKButton);
  If (Report <> nil) then Dispose(Report, Done);
end;


procedure DmxReportBox(ATitle :TTitleStr; Msg :string; Report :PDmxReport);
var  Rect	: TRect;
begin
  Rect.Assign(0,0, 50,9);
  DmxReportBoxRect(Rect, ATitle, Msg, Report);
end;


  { ====================================================================== }


procedure PrnCurrentDMX;
var  ToName	: FNameStr;
     C		: char;
     E		: TEvent;
begin
  If (PrnOpt.Dest = 1) then ToName := PrnOpt.FName else ToName := 'PRN';
  If (PrnOpt.Options and repExtChars = 0) then C := '|' else C := #0;
  If (PrnOpt.Options and repCrLf = 0) then NewLineStr := ^M else NewLineStr := ^M^J;
  If (ToName = '') then
    MessageBox('No output filename given.', nil, mfError + mfOKButton)
  else
  If (PrnOpt.Len < 1) or (PrnOpt.Wid < 10) then
    MessageBox('Page width or length is too short.', nil, mfError + mfOKButton)
   else
    begin
    DmxReportBox('Printing',  'Processing output to...'^M^M^C + ToName,
	New(PDmxReportFile, Init(Message(DeskTop, evCommand, cmDMX_RollCall, Application),
	     C,(PrnOpt.Options and repLineNums = repLineNums), PrnOpt.Len, PrnOpt.Wid, ToName))
      );
    Exit;
    end;
  If (Application <> nil) then
    begin
    E.What    := evCommand;
    E.Command := cmPRN_SetOptions;
    E.InfoPtr := Application;
    Application^.PutEvent(E);
    end;
end;


procedure PrnPageStart(var Event : TEvent);
begin
  With PDmxReport(Event.InfoPtr)^ do
    If (DMX^.Owner <> nil) and (PWindow(DMX^.Owner)^.Title <> nil) then
      PrintLn(PWindow(DMX^.Owner)^.Title^);
end;


procedure PrnPageEnd(var Event : TEvent);
//var  S : string[80];
var  S : ShortString;
begin
  With PDmxReport(Event.InfoPtr)^ do
    begin
    If (PageSize <= 0) or (LastRecord <= 0) then Exit;
    FormatStr(S, 'Page %d of %d',
	dparam(succ(CurrentPage),
	dparam(succ(pred(LastRecord) div PageSize),
	nil))^);
    PrintLn(S);
    end;
end;


function  PrnSetOptions(AHelpCtx,AOKCtx,ACancelCtx : word) : word;
{  AHelpCtx+0 = 'Destination: Printer'
   AHelpCtx+1 = 'Destination: File'
   AHelpCtx+2 = 'Destination: (Filename)'
   AHelpCtx+3 = 'Options: Allow extended characters'
   AHelpCtx+4 = 'Options: Display record numbers'
   AHelpCtx+5 = 'Options: Line feed on carriage return'
   AHelpCtx+6 = 'Options: Manual page feed'
   AHelpCtx+7 = 'Page Length'
   AHelpCtx+8 = 'Page Width'
 }
var  i	: integer;
     R	: TRect;
     D	: PDialog;

    function  InsertRadioButtons : PView;
    var  R   : TRect;
	 P   : PView;
    begin
      R.Assign(3, 3, 38, 5);
      P := New(PRadioButtons, Init(R,
		NewSItem('~P~rinter',
		NewSItem('~F~ile:',
		nil))
	     ));
      P^.HelpCtx := AHelpCtx;
      D^.Insert(P);
      InsertRadioButtons := P;
    end;

    function  InsertCheckBoxes : PView;
    var  R   : TRect;
	 P   : PView;
    begin
      R.Assign(3, 7, 38, 11);
      P := New(PCheckBoxes, Init(R,
		NewSItem('~A~llow extended characters',
		NewSItem('~D~isplay record/line numbers',
		NewSItem('L~i~ne feed on carriage return',
		NewSItem('~M~anual page feed',
		nil))))
	     ));
      P^.HelpCtx := AHelpCtx + 3;
      D^.Insert(P);
      InsertCheckBoxes := P;
    end;

begin
  PrnSetOptions := cmCancel;
  If (Application = nil) then Exit;
  R.Assign(0,0, 40,18);
  D := New(PDialog, Init(R, 'Print Settings'));
  With D^ do
    begin
    Options := Options or ofCentered;

    R.Assign(4, 2, 16, 3);
    Insert(New(PLabel, Init(R, '~D~estination', InsertRadioButtons)));

    InsertField(D, 14,4, FALSE, '', ' SSSSSSSSSSSSSSSSSSSSSSS')^.HelpCtx := AHelpCtx + 2;

    R.Assign(4, 6, 16, 7);
    Insert(New(PLabel, Init(R, '~O~ptions', InsertCheckBoxes)));

    InsertField(D, 4,12, FALSE, 'Page ~L~ength: ', 'WWWW ')^.HelpCtx := AHelpCtx + 7;
    InsertField(D, 4,13, FALSE, 'Page ~W~idth:  ', 'WWWW ')^.HelpCtx := AHelpCtx + 8;

    R.Assign(7, 15, 17, 17);
    Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));
    Current^.HelpCtx := AOKCtx;

    R.Assign(21, 15, 33, 17);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    Current^.HelpCtx := ACancelCtx;

    SelectNext(FALSE);
    end;

  If (Application^.ValidView(D) <> nil) then
    begin
    D^.SetData(PrnOpt);
    If (DeskTop^.ExecView(D) = cmOK) then
      begin
      D^.GetData(PrnOpt);
      While (PrnOpt.FName[length(PrnOpt.FName)] = ' ') do Dec(PrnOpt.FName[0]);
      While (PrnOpt.FName[1] = ' ') and (length(PrnOpt.FName) > 0) do
	System.Delete(PrnOpt.FName, 1,1);
      PrnSetOptions := cmOK;
      end;
    Dispose(D, Done);
    end;
end;


  { == TAppPrn =========================================================== }


procedure TAppPrn.HandleEvent(var Event : TEvent);
var  SysCommand : boolean;
     E		: TEvent;

    procedure WaitForNewPage;
    const Msg	= 'Insert a sheet for printing.';
    var   R	: TRect;
	  D	: PDialog;
    begin
      If not CtrlBreakHit and ((PrnOpt.Options and repPgFeed <> 0) and (PrnOpt.Dest <> 1)) then
	begin
	If (DeskTop^.Current = nil) then
	  begin
	  R.Assign(0, 0, 41, 13);
	  R.Move((DeskTop^.Size.X - (R.B.X - R.A.X)),(DeskTop^.Size.Y - (R.B.Y - R.A.Y)));
	  end
	 else
	  DeskTop^.Current^.GetBounds(R);
	D := New(PDialog, Init(R, 'New Page'));
	With D^ do
	  begin
	  GetExtent(R);
	  R.Grow(-3,-2);
	  Insert(New(PStaticText, Init(R, Msg)));
	  R.Assign((Size.X shr 1) + 1, Size.Y - 3,(Size.X shr 1) + 11, Size.Y - 1);
	  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
	  R.Assign((Size.X shr 1) - 11, Size.Y - 3,(Size.X shr 1) - 1, Size.Y - 1);
	  Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));
	  end;
	CtrlBreakHit := (DeskTop^.ExecView(D) = cmCancel);
	Dispose(D, Done);
	end;
    end;

    procedure PrintChar(S : string);
    var  Prn : Text;
	 Err : word;
	 St  : string;
    begin
      Assign(Prn,'PRN');
      ReWrite(Prn);
      Err := IOResult;
      If (Err = 0) then
	begin
	St := S;
	If (St = ^M) then
	  If (PrnOpt.Options and 4 = 0) then St := ^M else St := ^M^J;
	write(Prn, St);
	Err := IOResult;
	Close(Prn);
	end;
    end;

    procedure ResetPrinter;
    //var  Reg: Registers;
    begin
 //    {$IFDEF DPMI }
 //     Reg.AX := 1;
 //     Reg.DX := 0;
 //     Intr($17, Reg);
 //    {$ELSE }
 //     asm
	//mov	ah,  1
	//xor	dx, dx
	//int	17h
	//end;
 //    {$ENDIF }
    end;

begin
  If (Event.What = evCommand) and (Event.Command = cmPRN_NewPage) then
    WaitForNewPage;
  _TAppPrn.HandleEvent(Event);
  If (Event.What = evCommand) then
    begin
    Case Event.Command of
      cmPRN_LineFeed:	PrintChar(^M);
      cmPRN_FormFeed:	PrintChar(^L);
      cmPRN_Reset:	ResetPrinter;
      end;
   { Event is not cleared for these commands }
    end;
end;


function  TAppPrn.StdPrnMenuItems(AHelpCtx : word;  ANext : PMenuItem): PMenuItem;
    function  hc(N : word) : word;
    begin
      If (AHelpCtx = hcNoContext) then hc := hcNoContext else hc := AHelpCtx + N;
    end;
begin
  StdPrnMenuItems :=
	NewItem('~S~ettings...','', kbNoKey, cmPRN_SetOptions, AHelpCtx,
	NewLine(
	NewItem('~L~ine feed',	'',  kbNoKey, cmPRN_LineFeed, hc(1),
	NewItem('~F~orm feed',	'',  kbNoKey, cmPRN_FormFeed, hc(2),
	NewItem('~R~eset',	'',  kbNoKey, cmPRN_Reset,    hc(3),
	ANext)))));
end;


procedure TAppPrn.ReadConfigData(var S: TStream);
begin
  inherited ReadConfigData(S);
  S.Read(PrnOpt, sizeof(PrnOpt));
end;


procedure TAppPrn.WriteConfigData(var S: TStream);
begin
  inherited WriteConfigData(S);
  S.Write(PrnOpt, sizeof(PrnOpt));
end;


  { ====================================================================== }

var R : TRect;
    D : DirStr;
    N : NameStr;
    X : ExtStr;

Begin
  PrnOpt.Dest	 := 1;
  PrnOpt.Options := repLineNums or repCrLf;
  PrnOpt.Len	 := 55;
  PrnOpt.Wid	 := 78;
  If (ParamStr(0) = '') then PrnOpt.FName := 'FILE.OUT' else
    begin
    FSplit(ParamStr(0), D,N,X);
    PrnOpt.FName := N + '.OUT';
    end;
End.
