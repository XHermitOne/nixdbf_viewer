
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	FORMSHOP  --Record Form Editing Demo		}
{	tvDMX	  --data editing project		}
{							}
{	Copyright (c) 1993,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Program FORMSHOP;

{$M 16384,16384,655360}
{$V-,X+,D+,B-,R- }

uses
    Dos, Crt,
    Objects, Drivers, Views, Dialogs, Menus, App, MsgBox,
    RSet, DmxGizma, tvDMX, tvGizma, DmxForms, tvDmxRep;

const
    cmEditWin	=  101;
    cmEditDlg	=  102;
    cmEditBox	=  103;
    cmRegForm	=  104;
    cmPrint	=  105;

    hcDeskTop	= hcDragging + 1;
    hcDialogs	= $4000;
    hcMenus	= $8000;

    hcPrnOptions = hcDialogs + 100;
    hcOKPrint	 = hcPrnOptions + 10;
    hcCanxPrint	 = hcPrnOptions + 11;

    { help-context modifiers }
    hcEnumField	= 1;
    hcReadOnly	= 2;

    { tools used }
    AnsiView	= $01;
    Blaise	= $02;
    OWL		= $04;
    Btrieve	= $08;
    PXE		= $10;
    Topaz	= $20;
    TPower	= $40;

type
    TBusyData		=  RECORD  { same as TBusyData in SAMPLES.PAS }
	Marker		:  byte;	{ HIDDEN field }
	Name		:  string[30];
	SSN		:  string[9];
	realfield1	:  TREALNUM;
	DT		:  datetime;
	intfield0	:  integer;	{ READ-ONLY }
	intfield1	:  integer;
	ptrfield	:  pointer;
	realfield2	:  TREALNUM;
	hextwo		:  byte;	{ READ-ONLY }
    end;

    PResponseRec	= ^TResponseRec;
    TResponseRec	=  RECORD
	 { Programmer Information }
	Name,Co,Addr	: string[42];
	City		: string[16];
	State		: string[12];
	Zip,Country	: string[16];
	 { How long have you been using Turbo Vision? }
	Years,Months	: word;
	 { Which version of Borland/Turbo Pascal are you using? }
	TPxBP		: boolean;	TPversion	: TREALNUM;
	 { List any programming tools/add-ins that you use... }
	Tools		: word;
	BlaiseProd	: string[40];
	PXEver		: TREALNUM;
	TPowerProd	: string[36];
	Others		: array[0..4] of string[48];
    end;


    PDmxRecView	  = ^TDmxRecView;
    PDmxRecDlg	  = ^TDmxRecDlg;
    PDmxPrgrInfo  = ^TDmxPrgrInfo;

    TDmxRecView	  =  OBJECT(TDmxForm)
      procedure FieldText(var S: string;  var Color: word;
			  Field: pDMXfieldrec;  var DataRec );  VIRTUAL;
      function	GetHelpCtx : word;  VIRTUAL;
    end;

    TDmxRecDlg	  =  OBJECT(TDmxDlgForm)
      function	GetHelpCtx : word;  VIRTUAL;
    end;

    TDmxPrgrInfo  =  OBJECT(TDmxRecView)
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
    end;


    PMyStatusLine  = ^TMyStatusLine;
    TMyStatusLine  =  OBJECT(TStatusLine)
      function	Hint(AHelpCtx: word) : string;  VIRTUAL;
    end;


    TAppN	=  OBJECT(TAppPrn)
    end;

    TMyApp	=  OBJECT(TAppN)
      constructor Init;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure InitMenuBar;  VIRTUAL;
      procedure InitStatusLine;  VIRTUAL;
      procedure EditRecord;
      procedure EditDialog;
      procedure EditEntryBox;
      procedure RegistrationForm;
    end;


var
    MainData	: array[0..2047] of byte;   { untyped data for form }
    PrgrInfo	: TResponseRec;			{ registration form }
    BusyRec	: TBusyData;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  HelpCtxNum(P: PDmxEditor) : word;
begin
  With P^ do
    begin
    If (State and sfDragging <> 0) then
      HelpCtxNum := hcDragging
    else
    If (CurrentField^.access and accReadOnly <> 0) then
      HelpCtxNum := HelpCtx + hcReadOnly
    else
    If (CurrentField^.typecode = fldENUM) then
      HelpCtxNum := HelpCtx + hcEnumField
    else
      HelpCtxNum := HelpCtx;
    end;
end;


procedure TDmxRecView.FieldText(var S: string; var Color: word;
				 Field: pDMXfieldrec;	var DataRec );
var  i : integer;
     P : pchar;
begin
  If (upcase(Field^.typecode) in['S','#','C','0']) and (Field^.fieldsize > 0) then
    begin
    P := @DataRec;
    Inc(PtrRec(P).Ofs, Field^.datatab);
    If (P^ = #0) or (Color > $3F) then For i := 1 to length(S) do
      If (S[i] = ' ') and (Field^.template^[i] = #0) then S[i] := '_';
    end;
end;


function  TDmxRecView.GetHelpCtx : word;
begin
  GetHelpCtx := HelpCtxNum(@Self);
end;


function  TDmxRecDlg.GetHelpCtx : word;
begin
  GetHelpCtx := HelpCtxNum(@Self);
end;


  { ออ TDmxPrgrInfo ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxPrgrInfo.HandleEvent(var Event: TEvent);
const Lines	: integer = 0;
begin
  TDmxRecView.HandleEvent(Event);

  { The remainder of this method modifies the print/output procedure to
    leave several blank lines at the bottom of the page.  Note that the
    cmPrint command is intercepted, and handled here instead of by the
    main application view.
   }
  If (Event.What = evCommand) then
    begin
    If (Event.Command = cmPrint) then
      begin
      If (PrnSetOptions(hcPrnOptions,hcOKPrint,hcCanxPrint) = cmOK) then
	If (PrnOpt.Len < 41) then
	  MessageBox('Page length is too short.', nil, mfError or mfOKButton)
	 else
	  begin
	  Lines := PrnOpt.Len;
	  PrnOpt.Len := 41;
	  PrnCurrentDMX;
	  PrnOpt.Len := Lines;
	  end;
      ClearEvent(Event);
      end
    else
    If (Event.Command = cmPRN_EndPage) then
      begin
      With PDmxReport(Event.InfoPtr)^ do
	begin
	PrintLn('');
	PrintLn('  Add any additional questions or comments...');
	While (CurrentLine < Lines) do PrintLn('');
	end;
      ClearEvent(Event);
      end;
    end;
end;


  { ออ TMyStatusLine อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TMyStatusLine.Hint(AHelpCtx: word) : string;
begin
  Case AHelpCtx of
    hcDragging:  Hint := #24#25#26#27' Move  Shift-'#24#25#26#27' Resize  '#17#196#217' Done  Esc Cancel';
    hcReadOnly	+ hcDesktop,
    hcReadOnly	+ hcDialogs:	Hint := '(Read-Only field)';
    hcEnumField + hcDesktop,
    hcEnumField + hcDialogs:	Hint := '(Use "+" or "-")';
    hcPrnOptions:		Hint := 'Send output to printer';
    hcPrnOptions+1:		Hint := 'Send output to file (press <Tab> to enter filename)';
    hcPrnOptions+2:		Hint := 'Enter output file name';
    hcPrnOptions+3:		Hint := 'Output unfiltered text';
    hcPrnOptions+4:		Hint := 'Print record or line numbers';
    hcPrnOptions+5:		Hint := 'LF code follows carriage return';
    hcPrnOptions+6:		Hint := 'Wait before each new page';
    hcPrnOptions+7:		Hint := 'Enter page length';
    hcPrnOptions+8:		Hint := 'Enter page width';
    hcOKPrint:			Hint := 'Accept these settings and start printing';
    hcCanxPrint:		Hint := 'Close this dialog box and cancel print';
   else				Hint := '';
    end;
end;


  { ออ TMyApp ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TMyApp.Init;
begin
  TAppN.Init;
  MenuBar^.HelpCtx := hcMenus;
  DeskTop^.HelpCtx := hcDeskTop;
  hcEntryBox  := hcDialogs;
end;


procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TAppN.HandleEvent(Event);
  If Event.What = evCommand then
    begin
    Case Event.Command of
      cmEditWin:	EditRecord;
      cmEditDlg:	EditDialog;
      cmEditBox:	EditEntryBox;
      cmRegForm:	RegistrationForm;
      cmPrint:		PrnCurrentDMX;
      cmPRN_SetOptions:	PrnSetOptions(hcPrnOptions,hcDialogs,hcDialogs);
      cmPRN_NewPage:	PrnPageStart(Event);
      cmPRN_EndPage:	PrnPageEnd(Event);
     else		Exit;
      end;
    ClearEvent(Event);
    end;
end;


procedure TMyApp.InitMenuBar;
var  R : TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('tv~DMX~', hcNoContext, NewMenu(
      NewItem('~O~pen',      'F3',   kbF3,   cmEditWin,	hcNoContext,
      NewItem('~R~eg form',  'F4',   kbF4,   cmRegForm,	hcNoContext,
      NewItem('~D~ialog',    'F2',   kbF2,   cmEditDlg,	hcNoContext,
      NewItem('~E~ntry Box', 'F7',   kbF7,   cmEditBox,	hcNoContext,
      NewLine(
      NewSoundItem(hcNoContext,
      NewVideoItem(hcNoContext,
      NewLine(
      NewItem('e~X~it',  'Alt-X',  kbAltX,   cmQuit,	hcNoContext,
      nil)))))))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~S~ize/Move', 'Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom',      'F5',  kbF5,    cmZoom,	hcNoContext,
      NewItem('~T~ile',      '',    kbNoKey, cmTile,	hcNoContext,
      NewItem('C~a~scade',   '',    kbNoKey, cmCascade, hcNoContext,
      NewItem('~N~ext',      'F6',  kbF6,    cmNext,	hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3',  kbAltF3, cmClose,	hcNoContext,
      nil)))))))),
    NewSubMenu('~P~rint', hcNoContext, NewMenu(
      NewItem('~P~rint',  'F9',   kbF9,   cmPrint,	hcNoContext,
      StdPrnMenuItems(hcNoContext,
      nil))),
    nil))))
  ));
end;


procedure TMyApp.InitStatusLine;
var  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PMyStatusLine, Init(R,
    NewStatusDef(hcNoContext, hcDragging,
      NewStatusKey('tvDMX', kbNoKey, cmMenu,
      nil),
    NewStatusDef(hcDeskTop, hcDialogs - 1,
      NewStatusKey('tv~DMX~  ',      kbNoKey, cmMenu,
      NewStatusKey('~F2~ Dialog',    kbF2,    cmEditDlg,
      NewStatusKey('~F5~ Zoom',      kbF5,    cmZoom,
      NewStatusKey('~F6~ Next',      kbF6,    cmNext,
      NewStatusKey('~F9~ Print',     kbF9,    cmPrint,
      NewStatusKey('~F10~ Menu',     kbF10,   cmMenu,
      nil)))))),
    NewStatusDef(hcDialogs, hcMenus - 1,
      NewStatusKey('tvDMX',	      kbNoKey, cmMenu,
      NewStatusKey('~Esc~ Cancel',   kbEsc,   cmCancel,
      nil)),
    NewStatusDef(hcMenus, $FFFF,
      NewStatusKey('tv~DMX~  ',      kbNoKey, cmMenu,
      nil),
    nil))))
  ));
end;


procedure TMyApp.EditRecord;
{ The labels are enclosed by tilde ('~') symbols, and
  the '\' delimiter is used to separate text from literals. }
var  R	: TRect;
     A	: string;
     W	: PWindow;
     DMX : PDmxRecView;
     TT,Templates : PSItem;

    function  BlankYesNo : DmxIDstr;
    begin
      BlankYesNo := InitEnumField(TRUE, accNormal, 0,
	NewSItem(' ???',
	NewSItem(' Yes ',
	NewSItem(' No',
		nil))));
    end;

    function  SavingsNowOrChecking : DmxIDstr;
    begin
      SavingsNowOrChecking := InitEnumField(TRUE, accNormal, 0,
	NewSItem(' ???',
	NewSItem(' Savings',
	NewSItem(' NOW',
	NewSItem(' Checking ',
		nil)))));
    end;

    function  PersonalInfo(ANext: PSItem) : PSItem;
    begin
      PersonalInfo :=
	NewSItem(^A'~ PERSONAL INFORMATION~',
	NewSItem('~ ออออออออออออออออออออ~',
	NewSItem('',
	NewSItem('~ First Name        Middle            Last~',
	NewSItem( ' SSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS',
	NewSItem('',
	NewSItem('~ Home Address          City                 State  Zip code~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS\SS\   \##### ####',
	NewSItem('~ Previous Address      City                 State  Zip code~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS\SS\   \##### ####',
	NewSItem('',
	NewSItem('',
	NewSItem('~ Telephone  Home:~\(###) ###-####\~  Business:~\(###) ###-####',
	NewSItem('~ Social Security Number:~ \###-##-####\~  Date of Birth:~\' + fldDATE,
	NewSItem('~ Dependents:~\WW \~  U.S. Citizen:~' + BlankYesNo + '~  Resident:~' + BlankYesNo,
		ANext)))))))))))))));
    end;

    function  EmploymentInfo(ANext: PSItem) : PSItem;
    begin
      EmploymentInfo :=
	NewSItem('~ EMPLOYMENT INFORMATION~',
	NewSItem('~ ออออออออออออออออออออออ~',
	NewSItem('',
	NewSItem('~ Employer                            How long?~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS\WW '#0'~years  ~\WW '^U#11#0'~months~',
	NewSItem('~ Address               City                 State  Zip code~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS\SS\   \##### ####',
	NewSItem('',
	NewSItem('~ Occupation:~\ SSSSSSSSSSSSSSSS\~   Annual gross salary:~\($r,rrr,rrr)',
	NewSItem('~ Other income:~\($r,rrr,rrr)\~   Source:~\SSSSSSSSSSSSSSSSSSSS',
	NewSItem('',
	NewSItem('~ Former Employer                     How long?~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS\WW '#0'~years  ~\WW '#0'~months~',
	NewSItem('~ Address               City                 State  Zip code~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS\SS\   \##### ####',
		ANext)))))))))))))));
    end;

    function  FinancialInfo(ANext: PSItem) : PSItem;
    begin
      FinancialInfo :=
	NewSItem('~ FINANCIAL INFORMATION~',
	NewSItem('~ อออออออออออออออออออออ~',
	NewSItem('',
	NewSItem('~ Credit Card     Account Number       Credit Card     Account Number~',
	NewSItem( ' SSSSSSSSSSSSSS\\####-####-####-####\ SSSSSSSSSSSSSS\\####-####-####-####',
	NewSItem('~ Other Credit             Account Number~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSSSSSS\SSSSSSSSSSSSSSSSSSSSSSSS',
	NewSItem('~ Bank/Financial Institution    City             Acc Number    Type~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSS\SSSSSSSSSSSS\' + SavingsNowOrChecking,
	NewSItem( ' SSSSSSSSSSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSS\SSSSSSSSSSSS\' + SavingsNowOrChecking,
	NewSItem('',
	NewSItem('~ Check if you have any of the following:~',
	NewSItem('~ IRA: ~'#0'[X]\~ CD: ~'#0'[X]\~ Money Mkt Acc: ~'#0'[X]\~ Stocks/Bonds: ~'#0'[X]',
		ANext)))))))))))));
    end;

    function  JointAccountInfo(ANext: PSItem) : PSItem;
    begin
      JointAccountInfo :=
	NewSItem('~ JOINT ACCOUNT INFORMATION~',
	NewSItem('~ อออออออออออออออออออออออออ~',
	NewSItem('',
	NewSItem('~ First Name        Middle            Last~',
	NewSItem( ' SSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS',
	NewSItem('',
	NewSItem('~ Home Address          City                 State  Zip code~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS\SS\   \##### ####',
	NewSItem('~ Telephone  Home:~\(###) ###-####\~  Business:~\(###) ###-####',
	NewSItem('~ Social Security Number:~ \###-##-####\~  Date of Birth:~\' + fldDATE,
	NewSItem('',
	NewSItem('~ Employer                            How long?~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS\WW '#0'~years  ~\WW '#0'~months~',
	NewSItem('~ Address               City                 State  Zip code~',
	NewSItem( ' SSSSSSSSSSSSSSSSSSSS\ SSSSSSSSSSSSSSSSSSSS\SS\   \##### ####',
	NewSItem('',
	NewSItem('~ Occupation:~\ SSSSSSSSSSSSSSSS\~   Annual gross salary:~\($r,rrr,rrr)',
	NewSItem('~ Other income:~\($r,rrr,rrr)\~   Source:~\SSSSSSSSSSSSSSSSSSSS',
		ANext))))))))))))))))));
    end;

begin
  Templates :=
	PersonalInfo(
	NewSItem('',
	NewSItem('',
	NewSItem('',
	NewSItem('',
	EmploymentInfo(
	NewSItem('',
	NewSItem('',
	NewSItem('',
	NewSItem('',
	FinancialInfo(
	NewSItem('',
	NewSItem('',
	NewSItem('',
	NewSItem('',
	JointAccountInfo(
	NewSItem('',
		nil)))))))))))))))));

  AssignWinRect(R, 0,0);  { assign window dimensions }
  New(W, Init(R, 'EDIT RECORD', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable; { must be tileable for AssignWinRect }
    GetExtent(R);		  { create new rectangle for editor object }
    R.Grow(-1,-1);			      { shrink -1 to avoid borders }
    New(DMX,
	  Init(Templates,				   { template list }
		FALSE,				 { normal keyboard control }
		MainData,				     { record data }
		R,					{ view's rectangle }
		nil,nil,
		W^.StandardScrollBar(sbHorizontal),
		W^.StandardScrollBar(sbVertical)
		)
	);
    DMX^.Options := DMX^.Options or ofFramed;
    DMX^.HelpCtx := hcDesktop;
    Insert(DMX);
    end;
  DeskTop^.Insert(ValidView(W));

  DisposeSItems(Templates);  { not needed after initialization }

end;


procedure TMyApp.EditDialog;
var  R,R2 : TRect;
     A	  : string;
     D	  : PDialog;
     DMX  : PDmxRecDlg;
     Templates : PSItem;
begin
    { The string literals are enclosed by tilde ('~') symbols, and
      the '\' delimiter is used to separate fields from the literals. }
  Templates :=
	NewSItem(^A'B'^H,  { hidden BYTE field }
	NewSItem('~    Name~',
	NewSItem( '   \ssssssssssssssssssssssssssssss  ',
	NewSItem('',
	NewSItem('~    SSN:    ~\###-##-####',
	NewSItem('',
	NewSItem('~    Balance:~\($rrr,rrr.zz)',
	NewSItem('',
	NewSItem('~      Date: ~\' + fldDATE,
	NewSItem('~      Time: ~\' + fldTIME,
	NewSItem('',
	NewSItem('~      <A>   ~\iiiii '^R^S'\~ (skip field)~',
	NewSItem('~      [B]   ~\iiiii ',
	NewSItem('',
	NewSItem('~    Pointer:~\HHHH:HHHH',
	NewSItem('~    Value:  ~\RRR,RRR.ZZRR ~pts~',
	NewSItem('',
	NewSItem('~       RO:  ~\ HH '^R,
	NewSItem('',
		  nil)))))))))))))))))));

  R.Assign(0,0, 40,18);
  New(D, Init(R, 'Busy Record/Dialog'));
  With D^ do
    begin
    Options := Options or ofCentered;
    HelpCtx := hcDialogs;
    GetExtent(R);		  { create new rectangle for editor object }
    R.Grow(-1,-1);			      { shrink -1 to avoid borders }
    R.B.Y := R.A.Y + 12;
    New(DMX,
	  Init(Templates,				   { template list }
		R,					{ view's rectangle }
		nil,				   { no H-ScrollBar needed }
		D^.StandardScrollBar(sbVertical)
		)
	);
    DMX^.Options := DMX^.Options or ofFramed;
    DMX^.HelpCtx := hcDialogs;
    Insert(DMX);
    R.Assign((Size.X shr 1) - 11, Size.Y-3,(Size.X shr 1) - 1, Size.Y-1);
    Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));
    R.Assign((Size.X shr 1) + 1, Size.Y-3,(Size.X shr 1) + 11, Size.Y-1);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    SelectNext(FALSE);
    end;
  DeskTop^.ExecView(D);
  DisposeSItems(Templates);
end;


procedure TMyApp.EditEntryBox;
var  Control : integer;
begin
  Control := EntryBox('BusyRecord/EntryBox', @BusyRec, mfOKCancel + mfDefault,
	NewSItem(^A'B'^H,  { hidden BYTE field }
	NewSItem('~    Name~',
	NewSItem( '   \ssssssssssssssssssssssssssssss  ',
	NewSItem('',
	NewSItem('~    SSN:    ~\###-##-####',
	NewSItem('',
	NewSItem('~    Balance:~\($rrr,rrr.zz)',
	NewSItem('',
	NewSItem('~      Date: ~\' + fldDATE,
	NewSItem('~      Time: ~\' + fldTIME,
	NewSItem('',
	NewSItem('~      <A>   ~\iiiii '^R^S'\~ (skip field)~',
	NewSItem('~      [B]   ~\iiiii ',
	NewSItem('',
	NewSItem('~    Pointer:~\HHHH:HHHH',
	NewSItem('~    Value:  ~\RRR,RRR.ZZRR ~pts~',
	NewSItem('',
	NewSItem('~       RO:  ~\ HH '^R,
	NewSItem('',
		 nil)))))))))))))))))))
	);
end;


procedure TMyApp.RegistrationForm;
{ The labels are enclosed by tilde ('~') symbols, and
  the '\' delimiter is used to separate text from literals. }
const
     fldBOOL	= '[X]' + ^C+char(accSpecA);
var  R	: TRect;
     A	: string;
     W	: PWindow;
     DMX : PDmxPrgrInfo;
     TT,Templates : PSItem;

    function  BorlandOrTurbo : DmxIDstr;
    begin
      BorlandOrTurbo := InitEnumField(TRUE, accNormal, 0,
	NewSItem(' Turbo Pascal',
	NewSItem('Borland Pascal',
		nil)));
    end;

    function  Heading(ANext: PSItem) : PSItem;
    begin
      Heading :=
	NewSItem(^A,
	NewSItem('~  If you have a printer:  Please take a few moments to complete',
	NewSItem('~  as much of this form as possible.  (Registered users can upgrade',
	NewSItem('~  to this version free, and should not register again.)',
	NewSItem('',
	NewSItem('',
	ANext))))));
    end;

    function  ProgrammerInfo(ANext: PSItem) : PSItem;
    begin
      ProgrammerInfo :=
	NewSItem('~      Name   ~\ ssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~      Company~\ ssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~      Address~\ SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS',
	NewSItem('~      City   ~\ SSSSSSSSSSSSSSSS\~ State/Prov.~\SSSSSSSSSSSS',
	NewSItem('~             ~\ SSSSSSSSSSSSSSSS',
	NewSItem('~             ~\ SSSSSSSSSSSSSSSS',
	NewSItem('',
	NewSItem('',
	NewSItem('~  How long have you been using Turbo Vision?~\WW '^U#5#0'~years ~\WW '^U#11#0'~months~',
	NewSItem('',
	NewSItem('~  Which version of ~' + BorlandOrTurbo + '~ are you using?~\RR.ZR',
	NewSItem('',
	NewSItem('~  List any programming tools/add-ins that you use:~',
	NewSItem('~    ~\ [KA] ~  AnsiView               ~',
	NewSItem('~    ~\ [KA] ~  Blaise:~\ssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~    ~\ [KA] ~  Borland/Turbo Pascal Object Windows Library     ~',
	NewSItem('~    ~\ [KA] ~  Btrieve                ~',
	NewSItem('~    ~\ [KA] ~  Paradox Engine ver~\R.ZR',
	NewSItem('~    ~\ [KA] ~  Topaz                  ~',
	NewSItem('~    ~\ [KA] ~  TurboPower:~\ssssssssssssssssssssssssssssssssssss',
	NewSItem('',
	NewSItem('~    Others:~\ssssssssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~           ~\ssssssssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~           ~\ssssssssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('',
		ANext)))))))))))))))))))))))));
    end;

    function  Instructions(ANext: PSItem) : PSItem;
    begin
      Instructions :=
	NewSItem('~  Print this form and send it with $20 registration fee to:~',
	NewSItem('',
	NewSItem('~                 Randolph Beck~',
	NewSItem('~                 tvDMX Registration (2.5)~',
	NewSItem('~                 P.O. Box  56-0487~',
	NewSItem('~                 Orlando, FL  32856-0487~',
	NewSItem('',
		ANext)))))));
    end;

begin
  Templates := Heading(ProgrammerInfo(Instructions(nil)));

  AssignWinRect(R, 0,0);  { assign window dimensions }
  New(W, Init(R, 'USER RESPONSE FORM', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable; { must be tileable for AssignWinRect }
    GetExtent(R);		  { create new rectangle for editor object }
    R.Grow(-1,-1);			      { shrink -1 to avoid borders }
    New(DMX,
	 Init(Templates,				   { template list }
		TRUE,				   { alternate key control }
		PrgrInfo,				     { record data }
		R,					{ view's rectangle }
		nil,nil,
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical)
		)
	);
    DMX^.Options := DMX^.Options or ofFramed;
    DMX^.HelpCtx := hcDesktop;
    Insert(DMX);
    end;
  DeskTop^.Insert(ValidView(W));

  DisposeSItems(Templates);  { not needed after initialization }

end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure Namer(FN: string; posx: integer);
var  S:	 TDosStream;
     N:	 string[80];
begin
  If (PrgrInfo.Name <> '') then Exit;
  S.Init(FN, stOpenRead);
  S.Seek(posx);
  S.Read(N[1], 25);
  If (S.Status = stOK) and (N[1] >= 'A') then
    begin
    N[0] := #25;
    N[0] := chr(pred(pos(#0, N)));
    PrgrInfo.Name := N;
    end;
  S.Done;
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }

var  MyApp:  TMyApp;
     N:	 pathstr;
     F:	 SearchRec;

Begin
  { initialize the form data }
  FillChar(MainData, sizeof(MainData), 0);
  FillChar(PrgrInfo, sizeof(PrgrInfo), 0);

  { modify default printing options }
  PrnOpt.Options := PrnOpt.Options and not repLineNums; { no line numbers }
  PrnOpt.Len	 :=  55;				{ rows per page }
  PrnOpt.Wid	 := 132;				{ maximum page width }

  { attempt to fill in the user's name }
  Namer('\PDOXWIN\PDOXWIN.SOM', 6);
  Namer('\CIM\CIM.CFG', 3);

  {$IFDEF VER60 }
  PrgrInfo.TPversion := 6.0;
  {$ENDIF }
  {$IFDEF VER70 }
  PrgrInfo.TPversion := 7.0;
  {$ENDIF }

  {$IFDEF DPMI }
  PrgrInfo.TPxBP := TRUE;
  PrgrInfo.Tools := PrgrInfo.Tools or OWL;
  {$ELSE }
  FindFirst('BP.*', AnyFile - Directory, F);
  If (DosError = 0) then
    begin
    PrgrInfo.TPxBP := TRUE;
    PrgrInfo.Tools := PrgrInfo.Tools or OWL;
    end;
  {$ENDIF }

  FindFirst('\TVDT', Directory, F);
  If (DosError = 0) then
    begin
    PrgrInfo.Tools := PrgrInfo.Tools or Blaise;
    PrgrInfo.BlaiseProd := 'Turbo Vision Development Toolkit';
    end;

  FindFirst('\PXENG*.', AnyFile, F);
  While (DosError = 0) and (F.Attr and Directory = 0) do FindNext(F);
  If (DosError = 0) then
    begin
    PrgrInfo.Tools := PrgrInfo.Tools or PXE;
    If (F.Name = 'PXENG30') then
      PrgrInfo.PXEver := 3.0
    else
    If (PrgrInfo.TPversion = 6.0) then
      PrgrInfo.PXEver := 2.0
    end;


  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.
