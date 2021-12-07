
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	SAMPLES   --Multi-window sample demo program	}
{	tvDMX	  --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Program SAMPLES;

{ This program was written to demonstrate various data structures.  You can
  examine the field templates and copy some portions into WORKSHOP.PAS for
  your own experiments.

  The design of some of these record structures may seem pointless since
  they are intended only to demonstrate the interface mechanism.

  The "Account" window is the simplest example here.  It's somewhat bland,
  but most programmers will only require simple data structures like this.

  The "Payroll" window is a larger data window.  It demonstrates the 'Z'
  template code, which forces the display of leading zeroes in that field.
  Its last three fields are marked as READ-ONLY(with the ^R code).  These
  are entered automatically by the virtual methods in object TDmxPayroll,
  which overrides TDmxEditor.  Unlike "Accounts" and "Busy", this window is
  a regular TWindow type.

  The "Busy" window uses a more complex template string.  Note the heavy use
  of control codes, and that the last field in the main window is Read-Only.
  One of the integer fields is marked as a "skip" field(that means that the
  cursor will not land on it).

  The DateTime type is used here, with fldDATETIME, fldDATE, and fldTIME
  constants --as defined in the DMXGIZMA unit.	Its Year, Month and Day are
  swapped by codes in the fldDATETIME and fldDATE string to place it in its
  more familiar Month-Day-Year order.  An enumerated field is now used for
  the date portion, although its corresponding dialog box does not.


  Three other views are available from the menu:  "Hex" is a tvDMX-driven
  hex-byte editor using the same data as Busy window;  "Invoice" is the
  tvDMX-shareware invoice converted into a tvDMX form;  and "Dialog" is a
  dialog box that uses tvDMX descendants for individual field input, using
  the data in the current window at the current record.  A dialog window
  may also be actuated by double-clicking a record with a mouse.

    It should be noted that the invoice form can be printed and used to
    register for this package, in accordance with the license agreement.
    But previously registered programmers do not need to register again
    for this version.

  The data in most windows can be output to a printer or a text file (with
  SAMPLES.OUT as the default), using the objects in unit tvDMXREP.PAS.  The
  cmPrint command in TMyApp.HandleEvent() now prompts first to let the user
  adjust page and destination options before printing.

  The dialog box examples are constructed in two different ways.  The dialog
  box for the "Account" data is a regular dialog box with tvDMX InputFields
  from the StdDMX unit.  The "Payroll" and "Busy" data dialog boxes use the
  new EntryBox() function from the DmxForms unit.  (See program FORMSHOP for
  examples of more elaborate forms.)  EntryBox() is similar to the InputBox()
  function in the MsgBox unit, except that it allows for an entire record of
  data to be edited.  And it will scroll on either axis if your form too
  large for the desktop --as is the case with the "Busy" data's form in 25-
  line screen mode.

  (See file TVDMXHEX.PAS for the code used in the hexadecimal byte editor.)
 }

{$V-,X+ }

uses
    Dos, { required to define DateTime type }
    Crt, { required for Sound() procedure used by cmChime command }
    Objects, Drivers, Views, Menus, Dialogs, App, MsgBox,
    RSet, DmxGizma, tvGizma, tvDMX, StdDMX, tvDmxHex, tvDmxRep, DmxForms;

const
    cmAbout	  =  101;
    cmHasDialog   =  103;

    cmAccounts	  =  111;
    cmPayroll	  =  112;
    cmBusy	  =  113;
    cmHex	  =  114;
    cmInvoice	  =  115;
    cmDialog	  =  116;
    cmRecDialog   =  117;
    cmPrint	  =  118;

    hcDeskTop	  = 1100;
    hcAccWin	  = 1100;
    hcPayWin	  = 1200;
    hcBusyWin	  = 1300;
    hcHexWin	  = 1400;
    hcInvoiceWin  = 1500;
    hcDialogs	  = 4000;
    hcMenus	  = 50000;

    hcReadOnly	  = 1500;
    hcEnumField	  = 1501;

    hcMain	  = hcMenus;
    hcAccounts	  = hcMain + 1;
    hcPayroll	  = hcMain + 2;
    hcBusy	  = hcMain + 3;
    hcHex	  = hcMain + 4;
    hcInvoice	  = hcMain + 5;
    hcDialog	  = hcMain + 6;
    hcPrint	  = hcMain + 7;

    hcWindow	  = hcMain + 10;
    hcUserScr	  = hcWindow + 1;

    hcOptions	  = hcMain + 20;
    hcSound	  = hcOptions + 1;
    hcVideo	  = hcOptions + 2;
    hcPrnOpt	  = hcOptions + 3;


  { ออ Accounts template and data structure ออออออออออออออออออออออออออออออ }

const
    AccountLabel : string[80] =
	' Transaction          Debit        Credit      [?] ';

    AccountInfo  : string[80] =
	' SSSSSSSSSSSSSSSS`SSSSSSSSSS| rrr,rrr.zz  | rrr,rrr.zz  | [x] ';

      { Note that the '`' character marks the end of the visible field. }

type
    PAccount	  = ^TAccount;
    TAccount	  =  RECORD
	Account	:  string[26];
	Debit	:  TREALNUM;
	Credit	:  TREALNUM;
	Status	:  boolean;
    end;


  { ออ Payroll template and data structure อออออออออออออออออออออออออออออออ }

const { The last three fields are marked READ-ONLY, and are automatically
	entered by the virtual methods in object TDmxPayroll. }

    PayrollLblA  = ' Employee                ID     Earnings       FICA        FITW        SITW   ';
    PayrollInfo  = ' ssssssssssssssssssssss| ZZW บ $rr,rrr.zz | $r,rrr.zz '^R'| $r,rrr.zz '^R'| $r,rrr.zz '^R;
    PayrollLblB  = ' (dollar amounts are dependent upon Earnings)';

type
    PPayroll	  = ^TPayroll;
    TPayroll	  =  RECORD
	Employee :  string[22];
	ID	 :  word;
	Earnings :  TREALNUM;
	FICA	 :  TREALNUM;  { READ-ONLY }
	FITW	 :  TREALNUM;  { READ-ONLY }
	SITW	 :  TREALNUM;  { READ-ONLY }
    end;


  { ออ Busy data structure อออออออออออออออออออออออออออออออออออออออออออออออ }

const { The Busy Window's template uses many of the special options.  Since
	it uses an enumerated field, the template is defined in the method
	that instantiates these windows. }

    _BusyLabel	  =
	' Name                  SSN             Balance      Start Date   Time   <A>  [B]   Pointer       Value     RO ';

    BusyLabel	  :  string[length(_BusyLabel)] =  _BusyLabel;

type
    PBusyData	  = ^TBusyData;
    TBusyData	  =  RECORD
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


  { ออ Invoice data structure ออออออออออออออออออออออออออออออออออออออออออออ }

      { The Invoice Window is a TDmxForm-descendant, so its template uses
	is built by nested NewSItem() calls.  See function InvoiceForm(). }

const
    UnitPrice	= 20.00;
    SitePrice	= 50.00;

    { bit values for TInvoiceRec.Tools }
    AnsiView	= $0001;
    Blaise	= $0002;
    Btrieve	= $0004;
    PXE		= $0008;
    Topaz	= $0010;
    TPW		= $0020;
    TurboPower	= $0040;

    BBS		=   0;
    CIS		=   1;
    Internet	=   2;
    UserGroup	=   3;
    Friend	=   4;
    OtherSource	=   5;

type
    TInvoiceRec		= RECORD
	Co,Addr,City,Rep1,Rep2	: string[25];
	ContactA,ContactB	: string[25];
	Quantity		: integer;
	Item			: (Registration, SiteLicense);
	Price,Total		: TREALNUM;
	DiskType		: (disk3p5, disk5p25);
	SendWhen		: (whenrx, whennextver);
	 { How long have you been using Turbo Vision? }
	Years,Months		: word;
	 { Which version of Borland Pascal are you using? }
	TPversion		: TREALNUM;
	 { List any programming tools/add-ins that you use... }
	Tools,WhoSaid		: word;
	BlaiseProd		: string[21];
	SourceName		: string[14];
	TPowerProd		: string[17];
	Others			: array[0..4] of string[44];
    end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


type
    PDmxInvoice	  = ^TDmxInvoice;
    TDmxInvoice	  =  OBJECT(TDmxForm)
      procedure EvaluateField;  VIRTUAL;
      procedure FieldText(var S: string;  var Color: word;
			  Field: pDMXfieldrec;  var DataRec );  VIRTUAL;
      function	GetHelpCtx : word;  VIRTUAL;
    end;


    PDmxEditTbl	   = ^TDmxEditTbl;
    PDmxEditTblWin = ^TDmxEditTblWin;


    TDmxEditTbl     =  OBJECT(TDmxEditor)
      function	GetHelpCtx : word;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure SetState(AState: word; Enable: boolean);  VIRTUAL;
      function  Valid(Command: word) : boolean;  VIRTUAL;
    end;


    TDmxEditTblWin  =  OBJECT(TDmxWindow)
      procedure InitDMX(ATemplate: string;  var AData;
			ALabels,ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
    end;


    PDmxPayroll    = ^TDmxPayroll;

    TDmxPayroll	   =  OBJECT(TDmxEditTbl)
      procedure EvaluateField;	VIRTUAL;
      procedure ZeroizeField(Whole: boolean; Field: pDMXfieldrec);  VIRTUAL;
      procedure RecalcRecord;
    end;


    PMyStatusLine  = ^TMyStatusLine;
    TMyStatusLine  =  OBJECT(TStatusLine)
      function	Hint(AHelpCtx: word) : string;  VIRTUAL;
    end;


    TAppN	   =  OBJECT(TAppPrn)  { from tvDMXREP.PAS }
    end;

    TMyApp	   =  OBJECT(TAppN)
      constructor Init;
      procedure Idle;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure InitMenuBar;	 VIRTUAL;
      procedure InitStatusLine;  VIRTUAL;
      procedure AccountWindow;
      procedure PayrollWindow;
      procedure BusyWindow;
      procedure HexWindow;
      procedure InvoiceFormWin;
      procedure AccountDialog(P: PDmxEditTbl);
      procedure PayrollDialog(P: PDmxPayroll);
      procedure BusyDialog(P: PDmxEditTbl);
    end;


const
    MaxRecordNum  =   49;

var
    Accounts	:  array[0..MaxRecordNum] of TAccount;
    Payroll	:  array[0..MaxRecordNum] of TPayroll;
    BusyData	:  array[0..MaxRecordNum] of TBusyData;
    InvoiceRec	:  TInvoiceRec;


  procedure InitializeData;  forward;  { for the sample data }


  { ออ TMyStatusLine อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TMyStatusLine.Hint(AHelpCtx: word) : string;
begin
  Case AHelpCtx of
    hcDragging:   Hint := #24#25#26#27' Move  Shift-'#24#25#26#27' Resize  '#17#196#217' Done  Esc Cancel';
    hcReadOnly:   Hint := '(Read-Only field)';
    hcEnumField:  Hint := '(Use "+" or "-")';

    hcAccWin:	  Hint := '';
    hcPayWin:	  Hint := '';
    hcBusyWin:	  Hint := '';
    hcHexWin:	  Hint := '';
    hcInvoiceWin: Hint := '';
    hcDialogs:	  Hint := '';

    hcMain:	  Hint := 'Demonstration window selections';
    hcAccounts:   Hint := 'Demo of simple data structure';
    hcPayroll:	  Hint := 'Demo of read-only fields which are entered by virtual methods';
    hcBusy:	  Hint := 'Demo of complex date fields, hidden fields, and a "skip" field';
    hcHex:	  Hint := 'Hex editor using the same data as the Busy window';
    hcInvoice:	  Hint := 'Demo form window using a descendant of object TDmxForm';
    hcDialog:	  Hint := 'Open a dialog box for the current record';
    hcPrint:	  Hint := 'Print data in the current window (set destination in Options menu)';

    hcWindow:	  Hint := 'Arrange and manipulate windows';
    hcUserScr:	  Hint := 'Display the original user screen';

    hcOptions:	  Hint := 'Sound, video and printer options';
    hcSound:	  Hint := 'Toggle sound on/off';
    hcVideo:	  Hint := 'Toggle video mode';
    hcPrnOpt:	  Hint := 'Change printer/output destination and parameters';

   else		  Hint := StdMenuHint(AHelpCtx);  { from tvGIZMA.PAS }
    end;
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  InvoiceForm : PSItem;
{ The labels are enclosed by tilde ('~') symbols, and
  the '\' delimiter is used to separate text from literals. }

    function  Heading(Next: PSItem) : PSItem;
    begin
      Heading :=
	NewSItem('~  Remit to:                                 From:~',
	NewSItem('',
	NewSItem('~    Randolph Beck                            ~\sssssssssssssssssssssssss\ ',
	NewSItem('~    P.O. Box  56-0487                        ~\sssssssssssssssssssssssss',
	NewSItem('~    Orlando, FL 32856                        ~\sssssssssssssssssssssssss',
	NewSItem('~    CIS: 72361,753                           ~\sssssssssssssssssssssssss',
	NewSItem('~                                             ~\sssssssssssssssssssssssss',
	NewSItem('',
	NewSItem('~                ฐฐฐฐฐ   ฐฐ     ฐฐ ฐฐ   ฐฐ~',
	NewSItem('~   ฐฐ            ฐฐ ฐฐ  ฐฐฐ   ฐฐฐ  ฐฐ ฐฐ    Contact individual:~',
	NewSItem('~  ฐฐฐฐฐ ฐฐ   ฐฐ  ฐฐ  ฐฐ ฐฐฐฐ ฐฐฐฐ   ฐฐฐ      ~\sssssssssssssssssssssssss',
	NewSItem('~   ฐฐ    ฐฐ ฐฐ   ฐฐ  ฐฐ ฐฐ ฐฐฐ ฐฐ   ฐฐฐ      ~\sssssssssssssssssssssssss',
	NewSItem('~   ฐฐ     ฐฐฐ    ฐฐ  ฐฐ ฐฐ  ฐ  ฐฐ  ฐฐ ฐฐ~',
	NewSItem('~    ฐฐ     ฐ    ฐฐฐฐฐฐ  ฐฐ     ฐฐ ฐฐ   ฐฐ~',
		Next))))))))))))));
    end;

    function  Information(Next: PSItem) : PSItem;
    begin
      Information :=
	NewSItem('~             Qty                          Unit Price~',
	NewSItem('',
	NewSItem('           \IIII \'
		+ InitEnumField(TRUE, accReadOnly + accSkip, 0,
			NewSItem(' tvDMX Registration ',
			NewSItem(' tvDMX Site License ',
				nil)))                 + '    \ $RRR.ZZ '^S^R,
	NewSItem('',
	NewSItem('~                                   Total  ~\ $RRR.ZZ '^R,
	NewSItem('',
	NewSItem('',
	NewSItem('~  I prefer ~'
		+ InitEnumField(TRUE, accNormal, 0,
			NewSItem('3 1/2"',
			NewSItem('5 1/4"',
				nil))) + '~ disks.~',
		Next))))))));
    end;

    function  Instructions(Next: PSItem) : PSItem;
    begin
      Instructions :=
	NewSItem('~  Note that the tvDMX toolkit has been delivered and accepted by~',
	NewSItem('~  the customer.  A current disk, including full documentation and~',
	NewSItem('~  more units, will be sent ~'
		+ InitEnumField(TRUE, accNormal, 0,
			NewSItem('when the next update is available.',
			NewSItem('upon receipt of this paid invoice.',
				nil))),
		Next)));
    end;

    function  ClientInfo(ANext: PSItem) : PSItem;
    begin
      ClientInfo :=
	NewSItem('~  Client Information (Optional)~',
	NewSItem('~  ออออออออออออออออออ~',
	NewSItem('',
	NewSItem('~    How long have you been using Turbo Vision?~\ W '#0'~years ~\WW '^U#11#0'~months~',
	NewSItem('',
	NewSItem('~    Which version of Turbo Pascal are you using?~\RR.ZR',
	NewSItem('',
	NewSItem('~    List tools that you use:           Where did you find tvDMX?~',
	NewSItem('   \ [KA]~ AnsiView                     ~\ (kB)~ BBS                  ~',
	NewSItem('   \ [KA]~ Blaise:~\sssssssssssssssssssss\ (kB)~ CompuServe           ~',
	NewSItem('   \ [KA]~ Btrieve                      ~\ (kB)~ Internet             ~',
	NewSItem('   \ [KA]~ Paradox Engine               ~\ (kB)~ User group           ~',
	NewSItem('   \ [KA]~ Topaz                        ~\ (kB)~ friend or collegue   ~',
	NewSItem('   \ [KA]~ Turbo Pascal for Windows     ~\ (kB)~ Other:~\ssssssssssssss',
	NewSItem('   \ [KA]~ TurboPower:~\sssssssssssssssss',
	NewSItem('',
	NewSItem('~     Others:~\ssssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~            ~\ssssssssssssssssssssssssssssssssssssssssssss',
	NewSItem('~            ~\ssssssssssssssssssssssssssssssssssssssssssss',
		ANext)))))))))))))))))));
    end;

begin
  InvoiceForm := NewSItem(^A,
	Heading(
	NewSItem('',
	NewSItem('',
	Information(
	NewSItem('',
	Instructions(
	NewSItem('',
	NewSItem('',
	NewSItem('',
	ClientInfo(
	NewSItem('',
		nil))))))))))));
end;


  { ออ TDmxInvoice อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxInvoice.EvaluateField;
begin
  TDmxForm.EvaluateField;
  If FieldAltered and (CurrentField^.typecode = 'I') then
    With InvoiceRec do
      begin
     { tvDMX goes for $20.00 each registration (const ToolPrice)
		   or $50.00 for a site license (const SitePrice).
       This method calculates the proper payment.
      }
      If (Quantity <= 2) then
	begin
	Price := UnitPrice;
	Total := Quantity * UnitPrice;
	Item  := Registration;
	end
       else
	begin
	Price := SitePrice;
	Total := Price;
	Item  := SiteLicense;
	end;
      DrawView;
      end;
end;


procedure TDmxInvoice.FieldText(var S: string; var Color: word;
				Field: pDMXfieldrec;  var DataRec );
var  i : integer;
     P : pchar;
begin
  TDmxForm.FieldText(S, Color, Field, DataRec);
  If (upcase(Field^.typecode) in ['S','#','C','0']) and (Field^.fieldsize > 0) then
    begin
    P := @DataRec;
    Inc(PtrRec(P).Ofs, Field^.datatab);
    If (Color > 0) and ((P^ = #0) or DrawingField) then
      For i := 1 to length(S) do
	If (S[i] = ' ') and (Field^.template^[i] = #0) then S[i] := '_';
    end;
end;


function  TDmxInvoice.GetHelpCtx : word;
begin
  If (CurrentField^.typecode = fldENUM) then
    GetHelpCtx := hcEnumField
  else
  If (CurrentField^.access and accReadOnly <> 0) then
    GetHelpCtx := hcReadOnly
  else
    GetHelpCtx := HelpCtx;
end;


  { ออ TDmxEditTbl อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TDmxEditTbl.GetHelpCtx : word;
begin
  If (CurrentField^.typecode = fldENUM) then
    GetHelpCtx := hcEnumField
  else
  If (CurrentField^.access and accReadOnly <> 0) then
    GetHelpCtx := hcReadOnly
  else
    GetHelpCtx := HelpCtx;
end;


procedure TDmxEditTbl.HandleEvent(var Event: TEvent);
begin
  TDmxEditor.HandleEvent(Event);
  With Event do
    If (What = evCommand) then
      begin
      Case Command of
	cmDialog,cmDMX_DoubleClick:
	  Message(Application, evCommand, cmRecDialog, @Self);
	cmHasDialog:
	  begin end;  { just allow this event to clear }
       else	Exit;
	end;
      ClearEvent(Event);
      end;
end;


procedure TDmxEditTbl.SetState(AState: word; Enable: boolean);
begin
  TDmxEditor.SetState(AState, Enable);
  If (AState and sfActive <> 0) then
    begin
    If Enable then EnableCommands([cmDialog]) else DisableCommands([cmDialog]);
    end;
end;


function  TDmxEditTbl.Valid(Command: word) : boolean;
var  V	: boolean;
begin
  V := TDmxEditor.Valid(Command);
  If not V and
    ((Command = cmDMX_ZeroizeField) or (Command = cmDMX_ZeroizeRecord))
   then
    If (MessageBox('Records has READ-ONLY fields.'^M
		 + 'Should a partial erase be performed?',
		nil, mfError or mfYesButton or mfNoButton) = cmYes) then V := TRUE;
  Valid := V;
end;


  { ออ TDmxEditTblWin ออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxEditTblWin.InitDMX(ATemplate: string;  var AData;
				  ALabels,ARecInd: PDmxLink;
				  BSize: longint);
{ To override TDmxEditor (as does object TDmxEditTbl above), you could
  override a TDmxWindow object to insert the new object.  This window
  type is used for the "Accounts" and "Busy" windows.  (The "Payroll"
  window uses a regular TWindow type.)
 }
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If ALabels <> nil then Inc(R.A.Y, ALabels^.Size.Y);
  DMX := New(PDmxEditTbl, Init(ATemplate, AData, BSize, R,
		ALabels, ARecInd,
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical)));
  Insert(DMX);
end;


  { ออ TDmxPayroll อออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxPayroll.EvaluateField;
{ virtual method called after a field is edited...
  -- It updates the three READ-ONLY fields when field 3 is modified.
 }
begin
  TDmxEditTbl.EvaluateField;
  If (CurrentField^.fieldnum = 3) and FieldAltered then RecalcRecord;
end;


procedure TDmxPayroll.ZeroizeField(Whole: boolean; Field: pDMXfieldrec);
{ virtual method called to clear a field...
  -- The program will still operate properly without overriding this method,
     but the READ-ONLY fields would not react until the user changes fields.
 }
begin
  TDmxEditTbl.ZeroizeField(Whole, Field);
  If (Field^.fieldnum = 3) then RecalcRecord;
end;


procedure TDmxPayroll.RecalcRecord;
{ new method to follow up on changes }
begin
  With Payroll[CurrentRecord] do
    begin
    FICA  := Earnings * 0.075;
    FITW  := Earnings * 0.28;
    SITW  := Earnings * 0.05;
    end;
  RedrawRecord := TRUE;  { forces entire record to be redrawn }
end;


  { ออ TMyApp ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TMyApp.Init;
begin
  TAppN.Init;
  MenuBar^.HelpCtx := hcMenus;
  DeskTop^.HelpCtx := hcDeskTop;
  hcEntryBox	   := hcDialogs;
  InitializeData;  { initialize the sample data }

  { Open the first 5 selections }
  AccountWindow;
  PayrollWindow;
  BusyWindow;
  HexWindow;
  InvoiceFormWin;

  DeskTop^.SelectNext(FALSE);  { change back to account window }

  Message(Application, evCommand, cmAbout, @Self);

end;


procedure TMyApp.Idle;
begin
  TAppN.Idle;
  If (Message(DeskTop, evCommand, cmDMX_RollCall, @Self) <> nil) then
    EnableCommands([cmPrint])
   else
    DisableCommands([cmPrint]);
end;


procedure TMyApp.HandleEvent(var Event: TEvent);

    procedure About;
    const AIntro = ^C'tvDMX Demo'^M^M
		 + ^C'Copyright (c) 1994'^M
		 + ^C'Randolph Beck'^M;
	{$IFDEF DPMI }
	  AVStr	 = 'Protected';
	{$ELSE }
	  AVStr	 = 'Real';
	{$ENDIF }
	 Intro	: string[length(AIntro)] = AIntro;
	 VStr	: string[length(AVStr)]	 = AVStr;
    var	 R	: TRect;
	 Dialog	: PDialog;
	 S	: string;
    begin
      R.Assign(0, 0, 41, 13);
      Dialog := New(PDialog, Init(R, 'About'));
      With Dialog^ do
	begin
	Options := Options or ofCentered;
	R.Grow(-1,-2);
	FormatStr(S, '%s'^M^C'Memory available: %d'^M^C'[%s mode]',
		sparam(@Intro,
		dparam(MemAvail,
		sparam(@VStr,
			nil)))^
		);
	Insert(New(PStaticText, Init(R, S)));
	R.Assign(16, 10, 26, 12);
	Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));
	HelpCtx := hcDialogs;
	end;
      ExecView(Dialog);
      Dispose(Dialog, Done);
    end;

    procedure DoChime;
    begin
      If BeepOn then
	begin
	Sound(1047);
	Delay(50);
	If (Event.InfoPtr = nil) or (PTimeView(Event.InfoPtr)^.Min = 0) then
	  begin
	  NoSound;
	  Delay(50);
	  Sound(2094);
	  end
	 else
	  Sound(523);
	Delay(100);
	NoSound;
	end;
    end;

    procedure DoRecDialog;
    var  P : PDmxEditTbl;
    begin
      P := Event.InfoPtr;
      If (P <> nil) then
	begin
	If (P^.WorkingData = @Accounts) then AccountDialog(P)
	else
	If (P^.WorkingData = @Payroll)	then PayrollDialog(PDmxPayroll(P))
	else
	If (P^.WorkingData = @BusyData) then BusyDialog(P);
	end;
    end;

    procedure PrintPageTop;
    var  S : string;
    begin
      S := PWindow(PDmxReport(Event.InfoPtr)^.DMX^.Owner)^.Title^;
      PDmxReport(Event.InfoPtr)^.PrintLn(S);  { prints window title }
    end;

    procedure PrintPageEnd;
    begin
      With PDmxReport(Event.InfoPtr)^ do
	If (succ(pred(LastRecord) div PageSize) > 1) then
	  PrnPageEnd(Event)
	 else
	  PDmxReport(Event.InfoPtr)^.PrintLn('tvDMX 2.5');
    end;

begin
  TAppN.HandleEvent(Event);
  If (Event.What and evMessage <> 0) then
    begin
    Case Event.Command of
      cmAbout:		About;
      cmAccounts:	AccountWindow;
      cmPayroll:	PayrollWindow;
      cmBusy:		BusyWindow;
      cmHex:		HexWindow;
      cmInvoice:	InvoiceFormWin;
      cmRecDialog:	DoRecDialog;
      cmChime:		DoChime;
      cmPrint:		If PrnSetOptions(hcDialogs,hcDialogs,hcDialogs) = cmOK
			 then PrnCurrentDMX;
      cmPRN_SetOptions:	PrnSetOptions(hcDialogs,hcDialogs,hcDialogs);
      cmPRN_NewPage:	PrintPageTop;
      cmPRN_EndPage:	PrintPageEnd;
     else
      Exit;
      end;
    If (Event.What = evCommand) then ClearEvent(Event);
    end;
end;


procedure TMyApp.InitMenuBar;
var  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~S~amples', hcMain, NewMenu(
      NewItem('~A~ccounts', '',    kbNoKey, cmAccounts,hcAccounts,
      NewItem('Pa~y~roll',  '',    kbNoKey, cmPayroll, hcPayroll,
      NewItem('~B~usy',     'F4',  kbF4,    cmBusy,    hcBusy,
      NewItem('~H~ex',	    '',    kbNoKey, cmHex,     hcHex,
      NewItem('~I~nvoice',  '',    kbNoKey, cmInvoice, hcInvoice,
      NewLine(
      NewItem('~P~rint',    'F9',  kbF9,    cmPrint,   hcPrint,
      NewItem('~D~ialog',   'F2',  kbF2,    cmDialog,  hcDialog,
      NewLine(
      NewItem('e~X~it',   'Alt-X', kbAltX,  cmQuit,    hcExit,
      nil))))))))))),
    NewSubMenu('~W~indow', hcWindow, NewMenu(
      NewItem('~S~ize/Move', 'Ctrl-F5', kbCtrlF5, cmResize, hcResize,
      NewItem('~Z~oom',      'F5',  kbF5,    cmZoom,	hcZoom,
      NewItem('~T~ile',      '',    kbNoKey, cmTile,	hcTile,
      NewItem('C~a~scade',   '',    kbNoKey, cmCascade, hcCascade,
      NewItem('~N~ext',      'F6',  kbF6,    cmNext,	hcNext,
      NewItem('~P~revious',  'Shift-F6', kbShiftF6, cmPrev, hcPrev,
      NewItem('~C~lose', 'Alt-F3',  kbAltF3, cmClose,	hcClose,
      NewLine(
      NewItem('~U~ser screen', 'Alt-F5',  kbAltF5, cmUserScreen, hcUserScr,
      nil)))))))))),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewSoundItem(hcSound,
      NewVideoItem(hcVideo,
      NewItem('~P~rint options...','', kbNoKey, cmPRN_SetOptions, hcPrnOpt,
      nil)))),
    nil)
  )))));
end;


procedure TMyApp.InitStatusLine;
var  R:	TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PMyStatusLine, Init(R,
    NewStatusDef(hcNoContext, hcDeskTop - 1,
      NewStatusKey('tvDMX',		kbNoKey,cmAbout,
      nil),
    NewStatusDef(hcDeskTop, hcDialogs - 1,
      NewStatusKey('tv~DMX~  ',	kbNoKey,cmAbout,
      NewStatusKey('~F2~ Dialog',	kbF2,	cmDialog,
      NewStatusKey('~F5~ Zoom',	kbF5,	cmZoom,
      NewStatusKey('~F6~ Next',	kbF6,	cmNext,
      NewStatusKey('~F9~ Print',	kbF9,	cmPrint,
      NewStatusKey('~F10~ Menu',	kbF10,	cmMenu,
      nil)))))),
    NewStatusDef(hcDialogs, hcMenus - 1,
      NewStatusKey('~Esc~ Cancel',	kbEsc,	cmCancel,
      nil),
    NewStatusDef(hcMenus, $FFFF,
      NewStatusKey('tv~DMX~',		kbNoKey,cmAbout,
      nil),
    nil))))
  ));
end;


procedure TMyApp.AccountWindow;
var  R	: TRect;
     W	: PDmxWindow;
begin
  AssignWinRect(R, length(AccountLabel) + 2, 0);
  W := New(PDmxEditTblWin, Init(R,	{ window rectangle }
		'Accounts',		{ window title }
		wnNextAvail,		{ window number }
		AccountInfo,		{ template string }
		Accounts,		{ data records }
		sizeof(Accounts),	{ data size }
		AccountLabel,		{ heading label }
		7));			{ indicator width }
  W^.HelpCtx := hcAccWin;
  DeskTop^.Insert(ValidView(W));
end;


procedure TMyApp.PayrollWindow;
var  R	 : TRect;
     DMX : PDmxPayroll;
     W	 : PWindow;
begin
  AssignWinRect(R, length(PayrollLblA) + 2, 0);
  New(W, Init(R, 'Payroll', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable;
    HelpCtx := hcPayWin;
    GetExtent(R);
    R.Grow(-1,-3);		{ adjust R for border and labels }
    New(DMX, Init(PayrollInfo,	{ template string }
		Payroll,		{ data records }
		sizeof(Payroll),	{ data size }
		R,			{ view rectangle }
		New(PDmxFLabels, InitInsert(W, PayrollLblA)),
		New(PDmxRecInd,  InitInsert(W, 7)),
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical))
	 );
    Insert(DMX);
    R.Assign(1, Size.Y - 3, pred(Size.X), Size.Y - 1);
    Insert(New(PDmxFLabels, Init(PayrollLblB, R)));
    end;
  DeskTop^.Insert(ValidView(W));
end;


procedure TMyApp.BusyWindow;
var  R	: TRect;
     W	: PDmxWindow;
     BusyInfo : string;

    function  fldEnumDATE : string;
    begin
      fldEnumDATE :=  ^F + ^P+char(2) +
	InitEnumField(TRUE, 0,0,
		NewSItem('  0?-',
		NewSItem(' Jan-',
		NewSItem(' Feb-',
		NewSItem(' Mar-',
		NewSItem(' Apr-',
		NewSItem(' May-',
		NewSItem(' Jun-',
		NewSItem(' Jul-',
		NewSItem(' Aug-',
		NewSItem(' Sep-',
		NewSItem(' Oct-',
		NewSItem(' Nov-',
		NewSItem(' Dec-',
		NewSItem(' ERR-',
		nil))))))))))))))
	) + ^H'B' +  { hide the upper byte of the month's WORD field }
	#0'ZW-'^Z + ^U+char(31) +
	#0'ZZZW '^Z^F + ^P+char(-6) +
	#0 + ^P+char(4);
    end;

begin
  BusyInfo	:= 'B' + ^H		{ hidden byte field }
		 + #0' ssssssssssssssssssss`ssssssssss'  { Name field }
		 + '| ###-##-#### '	{ string of numerics only }
		 + '|($rrr,rrr.zz)'	{ positive or negative currency }

		{ DateTime type: }
		 + '|' + fldEnumDATE
		 + #0  + fldTIME	{ constant defined in DMXGIZMA.PAS }

		 + '|iii ' + ^Z^R^S	{ showzeroes/readonly/skip }
		 + '\iii '		{ normal integer }
		 + '| HHHH:HHHH '	{ hex longint value }
		 + '|RRR,RRR.RRR '	{ positive values only }
		 + '| hh ' + ^Z^R;	{ showzeroes/readonly field }

  AssignWinRect(R, length(BusyLabel) + 2, 0);
  W := New(PDmxEditTblWin, Init(R,	{ window rectangle }
		'Busy Window',		{ window title }
		wnNextAvail,		{ window number }
		BusyInfo,		{ template string }
		BusyData,		{ data records }
		sizeof(BusyData),	{ data size }
		BusyLabel,		{ heading label }
		10));			{ indicator width }
  W^.HelpCtx := hcBusyWin;
  DeskTop^.Insert(ValidView(W));
end;


procedure TMyApp.HexWindow;
{ uses objects in file tvDMXHEX.PAS }
var  R	: TRect;
     W	: PDmxWindow;
begin
  AssignWinRect(R, length(HexLabels) + 2, 0);
  W := New(PDmxHexWin, Init(R, 'Hex Window', wnNextAvail,
			      BusyData, sizeof(BusyData)));
  W^.HelpCtx := hcHexWin;
  DeskTop^.Insert(ValidView(W));
end;


procedure TMyApp.InvoiceFormWin;
var  R	: TRect;
     W	: PWindow;
     DMX: PDmxInvoice;
     Templates: PSItem;
begin
  Templates := InvoiceForm;
  AssignWinRect(R, 0,0);  { assign window dimensions }
  New(W, Init(R, 'INVOICE', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable; { must be tileable for AssignWinRect }
    GetExtent(R);		  { create new rectangle for editor object }
    R.Grow(-1,-1);			      { shrink -1 to avoid borders }
    New(DMX, Init(Templates,				   { template list }
	    TRUE,				   { alternate key control }
	    InvoiceRec,					     { record data }
	    R,						{ view's rectangle }
	    nil,nil,
	    StandardScrollBar(sbHorizontal),
	    StandardScrollBar(sbVertical))
	);
    DMX^.HelpCtx := hcDesktop;
    Insert(DMX);
    end;
  DeskTop^.Insert(ValidView(W));
  DisposeSItems(Templates);  { not needed after initialization }
end;


procedure TMyApp.AccountDialog(P: PDmxEditTbl);
var  R	     : TRect;
     Dialog  : PDialog;
     B	     : PButton;
     A	     : string;
     Control : word;
begin
  Str(succ(P^.CurrentRecord), A);
  DeskTop^.GetExtent(R);
  Dialog := New(PDialog, Init(R, 'Account Record #' + A));
  If (Dialog <> nil) then
    begin
    With Dialog^ do
      begin
      HelpCtx  := hcDialogs;
      InsertField(Dialog, 5,2, TRUE,  ' ~T~ransaction', ' SSSSSSSSSSSSSSSSSSSSSSSSSS');
      InsertField(Dialog, 2,5, TRUE,  '    ~D~ebit        Credit', ' rrr,rrr.zz  \ rrr,rrr.zz  ');
      InsertField(Dialog, 6,8, FALSE, '~S~tatus: ', '~[Cleared]~'^X);
      R.Assign(0, 10, 10, 12);
      B := New(PButton, Init(R, 'O~K~', cmOK, bfDefault));
      B^.Options := B^.Options or ofCenterX;
      Insert(B);
      SelectNext(FALSE);
      SetData(Accounts[P^.CurrentRecord]);
      end;
    TrimDialog(Dialog);
    Control := DeskTop^.ExecView(Dialog);
    If (Control = cmOK) then
      begin
      { return record to table }
      Dialog^.GetData(Accounts[P^.CurrentRecord]);
      { redraw all windows that use Accounts }
      Message(DeskTop, evBroadcast, cmDMX_DrawData, @Accounts);
      end;
    Dispose(Dialog, Done);
    end;
end;


procedure TMyApp.PayrollDialog(P: PDmxPayroll);
var  A	: string;
begin
  Str(succ(P^.CurrentRecord), A);
  If (EntryBox('Employee Record #'+A, P^.RecordData, mfOKCancel,
	NewSItem(^A,
	NewSItem('~      Name~',
	NewSItem('~    ~\ ssssssssssssssssssssss'#0'Ü  ',
	NewSItem('~      ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿~',
	NewSItem('~      ID Number: ~\ ZZW '#0'Ü ',
	NewSItem('~                   ฿฿฿฿฿~',
	NewSItem('~      Earnings:~\ $rr,rrr.zz ' + #0'Ü '#0'r'^H#0'r'^H#0'r'^H,
	NewSItem('~                 ฿฿฿฿฿฿฿฿฿฿฿฿~',
		 nil))))))))
	) = cmOK)
	then
	  begin
	  P^.RecalcRecord;
	  Message(DeskTop, evBroadcast, cmDMX_DrawData, @Payroll);
	  end;
end;


procedure TMyApp.BusyDialog(P: PDmxEditTbl);
var  A	: string;
begin
  Str(succ(P^.CurrentRecord), A);
  If (EntryBox('Record #'+A, P^.RecordData, mfOKCancel,
	NewSItem(^A'B'^H,  { this is a hidden BYTE field }
	NewSItem('~      Name~',
	NewSItem('~    ~\ ssssssssssssssssssssssssssssss'#0'Ü  ',
	NewSItem('~      ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿~',
	NewSItem('    ~SSN:     ~\ ###-##-#### '#0'Ü',
	NewSItem('~               ฿฿฿฿฿฿฿฿฿฿฿฿฿~',
	NewSItem('    ~Balance: ~\($rrr,rrr.zz)'#0'Ü',
	NewSItem('~               ฿฿฿฿฿฿฿฿฿฿฿฿฿~',
	NewSItem('~              Date         Time~',
	NewSItem('~          ~\' + fldDATETIME,
	NewSItem('',
	NewSItem('~    Integer [A]: ~\iii '^R^S#0'~Ü (skip field)~',
	NewSItem('~    Integer <B>: ~\iii '#0'Û',
	NewSItem('~                   ฿฿฿฿~',
	NewSItem('~    Pointer: ~\ HHHH:HHHH '#0'Ü',
	NewSItem('~               ฿฿฿฿฿฿฿฿฿฿฿~',
	NewSItem('~           Value~',
	NewSItem('~        ~\RRR,RRR.ZZRR ~pts~ '#0'Ü',
	NewSItem('~          ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿~',
	NewSItem('~        Read-Only: ~\ HH '^R+#0'Ü',
	NewSItem('~                     ฿฿฿฿~',
		 nil)))))))))))))))))))))
	) = cmOK)
	then
	  Message(DeskTop, evBroadcast, cmDMX_DrawData, @BusyData);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure InitializeData;
{ creates test data }
var  i,j  : integer;
     F	  : SearchRec;

    procedure InitAccount(ARecNum: integer; AName: string);
    begin
      With Accounts[ARecNum] do
	begin
	Account	:= AName;
	Debit	:= Random(50000) * 0.9;
	Credit	:= Random(50000) * 0.9;
	Status	:= (Credit > Debit);
	end;
    end;

    procedure InitBusyRec(ARecNum: integer; AName: string);
    var  i : integer;
    begin
      With BusyData[ARecNum] do
	begin
	Name	:= AName;
	intfield0  := ARecNum;
	hextwo	   := lo(ARecNum);
	If ARecNum < 26 then
	  begin
	  intfield1	:= random(255);
	  ptrfield	:= pointer(random(MaxInt));
	  realfield1	:= random(200) * random(200) / succ(random(199));
	  realfield2	:= random(200) * random(200) / succ(random(199));
	  DT.Year	:= 1988 + random(4);
	  DT.Month	:= succ(random(12));
	  DT.Day	:= succ(random(28));
	  DT.Hour	:= random(24);
	  DT.Min	:= random(60);
	  DT.Sec	:= random(60);
	  SSN[0]	:= #9;
	  For i := 1 to 9 do SSN[i] := chr(random(10) + 48);
	  end;
	end;
    end;

    procedure InitPayroll(ARecNum: integer; AName: string);
    begin
      With Payroll[ARecNum] do
	begin
	Employee :=  AName;
	If (ARecNum = 0) then ID := 44 else ID := Random(400);
	Earnings :=  Random(3000) + 4000.0;
	FICA	 :=  Earnings * 0.075;
	FITW	 :=  Earnings * 0.28;
	SITW	 :=  Earnings * 0.05;
	end;
    end;

begin
  RandSeed := 31;
  fillchar(Accounts,   sizeof(Accounts),   0);
  fillchar(Payroll,    sizeof(Payroll),	   0);
  fillchar(BusyData,   sizeof(BusyData),   0);
  fillchar(InvoiceRec, sizeof(InvoiceRec), 0);

  InitAccount( 0, 'ACME TOOL CO.');
  InitAccount( 1, 'READING R. R.');
  InitAccount( 2, 'EXXON CORP.');
  InitAccount( 3, 'ELECTRIC CO.');
  InitAccount( 4, 'B&O R. R.');
  InitAccount( 5, 'NYNEX');

  InitBusyRec( 0, 'Abigail Adams');
  InitBusyRec( 1, 'Betty Boop');
  InitBusyRec( 2, 'Cindy Crawford');
  InitBusyRec( 3, 'Dana Delaney');
  InitBusyRec( 4, 'Eve Easton');
  InitBusyRec( 5, 'Farrah Fawcett');
  InitBusyRec( 6, 'Ginger Grant');
  InitBusyRec( 7, 'Holly Hunter');
  InitBusyRec( 8, 'Ida Inman');
  InitBusyRec( 9, 'Janet Jackson');
  InitBusyRec(10, 'Katie Kingfield');
  InitBusyRec(11, 'Lois Lane');
  InitBusyRec(12, 'Marilyn Monroe');
  InitBusyRec(13, 'Nichelle Nichols');
  InitBusyRec(14, 'Olive Oyl');
  InitBusyRec(15, 'Paula Prentiss');
  InitBusyRec(16, 'Quia Quinn');
  InitBusyRec(17, 'Rita Rudner');
  InitBusyRec(18, 'Samantha Stevens');
  InitBusyRec(19, 'Tina Turner');
  InitBusyRec(20, 'Ursula Upton');
  InitBusyRec(21, 'Vicky Vail');
  InitBusyRec(22, 'Wendy Wilson');
  InitBusyRec(23, 'Xuxa');
  InitBusyRec(24, 'Yvette Yokomuro');
  InitBusyRec(25, 'Zelda Zimmerman');

  For i := 26 to MaxRecordNum do InitBusyRec(i, '');
  BusyData[0].SSN  := '';

  InitPayroll( 0, 'Alex Trebek');
  InitPayroll( 1, 'Pat Sajak');
  InitPayroll( 2, 'Vanna White');
  InitPayroll( 3, 'Merv Griffin');

  InvoiceRec.Quantity := 1;
  InvoiceRec.Price := UnitPrice;
  InvoiceRec.Total := UnitPrice;

  {$IFDEF VER60 }
  InvoiceRec.TPversion := 6.0;
  {$ELSE }
  InvoiceRec.Tools  := InvoiceRec.Tools or TPW;
  {$ENDIF }

  {$IFDEF VER70 }
  InvoiceRec.TPversion := 7.0;
  {$ENDIF }
  {$IFDEF VER75 }
  InvoiceRec.TPversion := 7.5;
  {$ENDIF }
  {$IFDEF VER80 }
  InvoiceRec.TPversion := 8.0;
  {$ENDIF }

  FindFirst('\TVDT', Directory, F);
  If (DosError = 0) then
    begin
    InvoiceRec.Tools := InvoiceRec.Tools or Blaise;
    InvoiceRec.BlaiseProd := 'TVDT';
    end;

  FindFirst('\PXENG*.', Directory, F);
  While (DosError = 0) and (F.Attr and Directory = 0) do FindNext(F);
  If (DosError = 0) then InvoiceRec.Tools := InvoiceRec.Tools or PXE;

  FindFirst('\CIM', Directory, F);
  If (DosError = 0) then
    InvoiceRec.WhoSaid := CIS
   else
    begin
    FindFirst('\WINCIM', Directory, F);
    If (DosError = 0) then InvoiceRec.WhoSaid := CIS;
    end;

end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }

var  MyApp  : TMyApp;

Begin
  { set default printing options }
  PrnOpt.Dest	 := 0;					{ default output=PRN }
  PrnOpt.Options := PrnOpt.Options and not repLineNums;	{ no line numbers }
  PrnOpt.Options := PrnOpt.Options or repExtChars;	{ extended chars }
  PrnOpt.Len	 :=  55;				{ rows per page }
  PrnOpt.Wid	 :=  80;				{ maximum page width }

  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.
