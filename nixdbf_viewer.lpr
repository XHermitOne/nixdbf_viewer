{
Программа просмотра DBF файлов с помощью утилиты nixdbf.

Версия 0.0.1.1

@bold(Поиск утечек памяти)

Включение поиска утечек:
Меню Lazarus -> Проект -> Параметры проекта... ->
Параметры компилятора -> Отладка -> Выставить галки для ключей -gl и -gh

Вывод делаем в текстовый файл *.mem в:

@longcode(#
***********************************************************
if UseHeapTrace then     // Test if reporting is on
   SetHeapTraceOutput(ChangeFileExt(ParamStr(0), '.mem'));
***********************************************************
#)

Допустим, имеем код, который заведомо без утечек:

@longcode(#
***********************************************************
uses heaptrc;
var
  p1, p2, p3: pointer;

begin
  getmem(p1, 100);
  getmem(p2, 200);
  getmem(p3, 300);

  // ...

  freemem(p3);
  freemem(p2);
  freemem(p1);
end.
***********************************************************
#)

, после запуска и завершения работы программы, в консоли наблюдаем отчет:

@longcode(#
***********************************************************
Running "f:\programs\pascal\tst.exe "
Heap dump by heaptrc unit
3 memory blocks allocated : 600/608
3 memory blocks freed     : 600/608
0 unfreed memory blocks : 0
True heap size : 163840 (80 used in System startup)
True free heap : 163760
***********************************************************
#)

Утечек нет, раз "0 unfreed memory blocks"
Теперь внесем утечку, "забудем" вернуть память выделенную под p2:

@longcode(#
***********************************************************
uses heaptrc;
var
  p1, p2, p3: pointer;

begin
  getmem(p1, 100);
  getmem(p2, 200);
  getmem(p3, 300);

  // ...

  freemem(p3);
  // freemem(p2);
  freemem(p1);
end.
***********************************************************
#)

и смотрим на результат:

@longcode(#
***********************************************************
Running "f:\programs\pascal\tst.exe "
Heap dump by heaptrc unit
3 memory blocks allocated : 600/608
2 memory blocks freed     : 400/408
1 unfreed memory blocks : 200
True heap size : 163840 (80 used in System startup)
True free heap : 163488
Should be : 163496
Call trace for block $0005D210 size 200
  $00408231
***********************************************************
#)

200 байт - утечка...
Если будешь компилировать еще и с ключом -gl,
то ко всему прочему получишь и место, где была выделена "утекающая" память.

ВНИМАНИЕ! Если происходят утечки памяти в модулях Indy
необходимо в C:\lazarus\fpc\3.0.4\source\packages\indy\IdCompilerDefines.inc
добавить @code($DEFINE IDFREEONFINAL) в секции FPC (2+)
и перекомпилировать проект.
}

program nixdbf_viewer;

{$mode Delphi}{$H+}
//{$mode objfpc}{$H+}

uses
  //{$IFDEF UNIX}{$IFDEF UseCThreads}
  //cthreads,
  //{$ENDIF}{$ENDIF}
  App,            // TApplication
  MsgBox,         // MessageBox
  Objects,
  Drivers,        // Hotkey
  Views,
  Menus,
  RSET,
  STDDMX,
  TVGIZMA,
  TVDMX,
  DMXGIZMA,
  Avail, DMXFORMS
  //Objects, Drivers, Views, Editors, Menus, Dialogs, App,             { Standard GFV units }
  //FVConsts, AsciiTab,
  //Gadgets, TimedDlg, MsgBox, StdDlg,
  //Classes, SysUtils, CustApp
  { you can add units after this };

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

const
    AccountLabel : string =
	' Transaction          Debit        Credit      [?] ';

    AccountInfo  : string =
	' SSSSSSSSSSSSSSSS`SSSSSSSSSS| rrr,rrr.zz  | rrr,rrr.zz  | [x] ';

type
  PDmxEditTbl	   = ^TDmxEditTbl;
  TDmxEditTbl     =  OBJECT(TDmxEditor)
    function	GetHelpCtx : word;  VIRTUAL;
    procedure HandleEvent(var Event: TEvent);  VIRTUAL;
    procedure SetState(AState: word; Enable: boolean);  VIRTUAL;
    function  Valid(Command: word) : boolean;  VIRTUAL;
  end;

  PDmxEditTblWin = ^TDmxEditTblWin;
  TDmxEditTblWin  =  OBJECT(TDmxWindow)
    procedure InitDMX(ATemplate: string;  var AData;
      		ALabels,ARecInd: PDmxLink;
      		BSize: longint);  VIRTUAL;
  end;

  PAccount	  = ^TAccount;
  TAccount	  =  RECORD
	Account	:  string;
	Debit	:  TREALNUM;
	Credit	:  TREALNUM;
	Status	:  boolean;
  end;

  { TNixDBFViewerApplication }
  TNixDBFViewerApplication = object(TApplication)
    procedure  InitStatusLine;  virtual;         // Status Line
    procedure InitMenuBar; virtual;              // Menu

    procedure TableWindow;

  //protected
  //  procedure DoRun; override;
  //
  //public
  //  constructor Create(TheOwner: TComponent); override;
  //  destructor Destroy; override;
  //  procedure WriteHelp; virtual;
  end;

const
    MaxRecordNum  =   49;

var
  Accounts	:  array[0..MaxRecordNum] of TAccount;

{ TNixDBFViewerApplication }
procedure TNixDBFViewerApplication.InitStatusLine;
var
  Rect: TRect;
begin
  GetExtent(Rect);
  Rect.A.Y := Rect.B.Y - 1;

  StatusLine := New(PStatusLine,
                    Init(Rect,
                         NewStatusDef(0,
                                      $FFFF,
                                      NewStatusKey('~Alt+X~ Exit',
                                                   kbAltX, cmQuit, nil), nil)));
end;

procedure TNixDBFViewerApplication.InitMenuBar;
var
  Rect: TRect;
begin
  GetExtent(Rect);
  Rect.B.Y := Rect.A.Y + 1;

  MenuBar := New(PMenuBar,
                 Init(Rect,
                      NewMenu(NewSubMenu('~F~ile', hcNoContext,
                                         NewMenu(NewItem('E~x~it',
                                                         'Alt-X',
                                                         kbAltX,
                                                         cmQuit,
                                                         hcNoContext,
                  nil)), nil))));
end;

procedure TNixDBFViewerApplication.TableWindow;
var
  R	: TRect;
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

//procedure TNixDBFViewerApplication.DoRun;
//var
//  ErrorMsg: String;
//begin
//  // quick check parameters
//  ErrorMsg:=CheckOptions('h', 'help');
//  if ErrorMsg<>'' then begin
//    ShowException(Exception.Create(ErrorMsg));
//    Terminate;
//    Exit;
//  end;
//
//  // parse parameters
//  if HasOption('h', 'help') then begin
//    WriteHelp;
//    Terminate;
//    Exit;
//  end;
//
//  { add your program here }
//
//  // stop program loop
//  Terminate;
//end;

//constructor TNixDBFViewerApplication.Create(TheOwner: TComponent);
//begin
//  inherited Create(TheOwner);
//  StopOnException:=True;
//end;
//
//destructor TNixDBFViewerApplication.Destroy;
//begin
//  inherited Destroy;
//end;
//
//procedure TNixDBFViewerApplication.WriteHelp;
//begin
//  { add your help code here }
//  writeln('Usage: ', ExeName, ' -h');
//end;
//
////procedure  TTutorApp.lnitStatusLine;
////var
////  R: TRect;
////begin
////  GetExtent (R)  ;
////  R.A.Y. :=  R.B.Y - 1;
////  New (StatusLine, Init(R,NewStatusDef(O, $EFFF,
////                                       StdStatusKeys(nil) ,
////                                       NewStatusDef($FOOO, $FFFF,
////                                       StdStatusKeys(nil) ,
////                                       nil)))) ;
////
////end;

{ == TDmxEditTbl ======================================================= }
function TDmxEditTbl.GetHelpCtx : word;
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
var
  V	: boolean;
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

{ == TDmxEditTblWin ==================================================== }


procedure TDmxEditTblWin.InitDMX(ATemplate: string;  var AData;
      			  ALabels,ARecInd: PDmxLink;
      			  BSize: longint);
{ To override TDmxEditor (as does object TDmxEditTbl above), you could
override a TDmxWindow object to insert the new object.  This window
type is used for the "Accounts" and "Busy" windows.  (The "Payroll"
window uses a regular TWindow type.)
}
var
  R	: TRect;
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

var
  Application: TNixDBFViewerApplication;
begin
  //Application:=TNixDBFViewerApplication.Create(nil);
  //Application.Title:='NixDBF Viewer';
  //Application.Run;
  //Application.Free;
  //Application.Title:='NixDBF Viewer';
  Application.Init;
  // MessageBox('Hello World !', nil, mfOKButton);
  Application.Run;   // Wen es weiter gehen soll.
  Application.Done;
end.

