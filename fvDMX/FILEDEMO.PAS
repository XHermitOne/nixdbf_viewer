
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	FILEDEMO  --Buffered File Editing Demo		}
{	tvDMX	  --data editing project		}
{							}
{	Copyright (c) 1993  Randolph Beck		}
{			    P.O. Box  56-0487		}
{			    Orlando, FL 32856		}
{			    CIS:  72361,753		}
{							}
{	This program demonstates how to use tvDMX	}
{	with regular Pascal files.  See FILESHOP.PAS	}
{	to work with streams.				}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Program FILEDEMO;

{$M 16384,8192,655360 }
{$B-,I-,R-,X+,V- }

uses  Objects, Drivers, Views, Menus, App, MsgBox,
      RSet, DmxGizma, tvGizma, tvDMX, tvDMXBUF, tvDMXREP;

const
    xLabel	=  ' Name                     Debit       Credit     mm-dd-yyyy ';
    xTemplate	=  ' ssssssssssssssssssssบ($rr,rrr.zz)|($rr,rrr.zz)|' + fldDATE;

    MyLabel	:  string[length(xLabel)]	= xLabel;
    MyTemplate	:  string[length(xTemplate)]	= xTemplate;

    cmOpenWin	=  101;
    cmPrint	=  102;


type
    DataRec	=  RECORD
	S	: array[1..20] of char;
	R1,R2	: TRealNum;
	Date	: array[1..8] of char;
    end;

    DataFile	 =  file of DataRec;

    PDmxDataFile  = ^TDmxDataFile;
    TDmxDataFile	 =  OBJECT(TDmxEditBuf)
	ErrorInfo	: word;
      function	RecordLimit : longint;	VIRTUAL;
      function	SeekRec(RecNum : longint) : boolean;  VIRTUAL;
      function	SeekEnd : boolean;  VIRTUAL;
      function	ReadRec(var RecData ) : boolean;  VIRTUAL;
      function	WriteRec(var RecData ) : boolean;  VIRTUAL;
    end;


    TAppN	  =  OBJECT(TAppA)
    end;

    TMyApp	  =  OBJECT(TAppN)
      constructor Init;
      destructor  Done;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure InitMenuBar;  VIRTUAL;
      procedure OpenWindow;
      function	OpenFile(var F : DataFile;  FName : string)  : boolean;
      procedure CloseFile(var F : DataFile);
    end;


var
    WorkFile	:  DataFile;


  { ออ TDmxDataFile ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  TDmxDataFile.RecordLimit : longint;
begin
  RecordLimit := FileSize(DataFile(WorkingData^));
  ErrorInfo := IOResult;
end;


function  TDmxDataFile.SeekRec(RecNum : longint) : boolean;
begin
  Seek(DataFile(WorkingData^), RecNum);
  ErrorInfo := IOResult;
  SeekRec := (ErrorInfo = 0);
end;


function  TDmxDataFile.SeekEnd : boolean;
begin
  SeekEnd := SeekRec(RecordLimit);
end;


function  TDmxDataFile.ReadRec(var RecData ) : boolean;
begin
  Read(DataFile(WorkingData^), DataRec(RecData));
  ErrorInfo := IOResult;
  ReadRec := (ErrorInfo = 0);
end;


function  TDmxDataFile.WriteRec(var RecData ) : boolean;
begin
  Write(DataFile(WorkingData^), DataRec(RecData));
  ErrorInfo := IOResult;
  WriteRec := (ErrorInfo = 0);
end;


  { ออ TMyApp ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TMyApp.Init;
begin
  TAppN.Init;

  If not OpenFile(WorkFile, 'FILEDEMO.DAT') then
    begin
    DisableCommands([cmOpenWin]);
    MessageBox('Error initializing file.', nil, mfError + mfOKButton);
    end;

end;


destructor TMyApp.Done;
begin
  TAppN.Done;
  CloseFile(WorkFile);
end;


procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TAppN.HandleEvent(Event);
  If Event.What = evCommand then
    begin
    Case Event.Command of
      cmOpenWin	: OpenWindow;
      cmPrint	: PrnCurrentDMX;
     else
      Exit;
      end;
    ClearEvent(Event);
    end;
end;


procedure TMyApp.InitMenuBar;
var  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen',    'F4',   kbF4,   cmOpenWin,	hcNoContext,
      NewItem('~P~rint',   'F9',   kbF9,   cmPrint,	hcNoContext,
      NewLine(
      NewSoundItem(hcNoContext,
      NewVideoItem(hcNoContext,
      NewLine(
      NewItem('e~X~it',  'Alt-X',  kbAltX, cmQuit,	hcNoContext,
      nil)))))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~S~ize/Move', 'Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom',      'F5',  kbF5,    cmZoom,	hcNoContext,
      NewItem('~T~ile',      '',    kbNoKey, cmTile,	hcNoContext,
      NewItem('C~a~scade',   '',    kbNoKey, cmCascade, hcNoContext,
      NewItem('~N~ext',      'F6',  kbF6,    cmNext,	hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3',  kbAltF3, cmClose,	hcNoContext,
      NewLine(
      NewItem('~U~ser screen', 'Alt-F5',  kbAltF5, cmUserScreen, hcNoContext,
      nil)))))))))),
    nil)))
  ));
end;


procedure TMyApp.OpenWindow;
var  R	: TRect;
     W	: PWindow;
     DMX: PDmxDataFile;
begin
  AssignWinRect(R, length(MyLabel) + 2, 0);  { assign window dimensions }
      { width of string MyLabels plus two for the border; }
      { zero rows indicates extend to bottom of screen }

  New(W, Init(R, 'Data Window', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable; { must be tileable for AssignWinRect }
    GetExtent(R);		  { create new rectangle for editor object }
    R.Grow(-1,-1);			      { shrink -1 to avoid borders }
    Inc(R.A.Y, 2);			 { make room for TDmxLabels object }
    New(DMX, Init(MyTemplate,				 { template string }
		WorkFile,				    { working data }
		0,			 { irrelevant if you use ResetSize }
		R,					{ view's rectangle }
		New(PDmxLabels, InitInsert(W, @MyLabel)), { label string }
		New(PDmxExpRecInd, InitInsert(W, 10)), { indicator width }
		StandardScrollBar(sbHandleKeyboard or sbHorizontal),
		StandardScrollBar(sbHandleKeyboard or sbVertical)
		)
	);
    DMX^.Expandable := TRUE;	{ allows more records to be added }
    DMX^.ResetSize;		{ reset DataBlockSize and Limits }
    Insert(DMX);
    end;
  DeskTop^.Insert(ValidView(W));
end;


function  TMyApp.OpenFile(var F : DataFile;  FName : string) : boolean;
var  Err : word;
begin
  Assign(F, FName);
  Reset(F);
  Err := IOResult;
  If (Err <> 0) then
    begin
    ReWrite(F);
    Err := IOResult;
    end;
  OpenFile := (Err = 0);
end;


procedure TMyApp.CloseFile(var F : DataFile);
begin
  Close(F);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }

var  MyApp	:  TMyApp;

Begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.
