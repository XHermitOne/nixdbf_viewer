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

{$mode objfpc}{$H+}

uses
  //{$IFDEF UNIX}{$IFDEF UseCThreads}
  //cthreads,
  //{$ENDIF}{$ENDIF}
  App,            // TApplication
  MsgBox,         // MessageBox
  Objects,
  Drivers,        // Hotkey
  Views,
  Menus
  //Objects, Drivers, Views, Editors, Menus, Dialogs, App,             { Standard GFV units }
  //FVConsts, AsciiTab,
  //Gadgets, TimedDlg, MsgBox, StdDlg,
  //Classes, SysUtils, CustApp
  { you can add units after this };

type
  { TNixDBFViewerApplication }
  TNixDBFViewerApplication = object(TApplication)
    procedure  InitStatusLine;  virtual;         // Status Line
    procedure InitMenuBar; virtual;              // Menu
  //protected
  //  procedure DoRun; override;
  //
  //public
  //  constructor Create(TheOwner: TComponent); override;
  //  destructor Destroy; override;
  //  procedure WriteHelp; virtual;
  end;

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

var
  Application: TNixDBFViewerApplication;
begin
  //Application:=TNixDBFViewerApplication.Create(nil);
  //Application.Title:='NixDBF Viewer';
  //Application.Run;
  //Application.Free;
  Application.Title:='NixDBF Viewer';
  Application.Init;
  // MessageBox('Hello World !', nil, mfOKButton);
  Application.Run;   // Wen es weiter gehen soll.
  Application.Done;
end.

