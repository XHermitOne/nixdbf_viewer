
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	FILESHOP  --Buffered Stream Editing Demo	}
{	tvDMX	  --data editing project		}
{							}
{	Copyright (c) 1992,93	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Program FILESHOP;

{ This program works like WORKSHOP.PAS, except that it uses data from a
  STREAM instead of in memory.	The object's provisions for error-checking
  are not used but can be expanded by overriding TDmxExpBuf.ErrorFunc().

  Modify the strings xInfo and xLabel to change the record structure.  Then
  delete FILESHOP.DAT(if it exists).

  See unit file TVDMXBUF.PAS for more information on the TDmxExpBuf object.
 }

{$M 16384,8192,655360 }
{$B-,R-,X+,V- }

uses  Objects, Drivers, Views, Menus, App, MsgBox,
      RSet, DmxGizma, tvDMX, tvDMXBUF, tvGizma;

const
    xLabels	=  ' String Field            +Real         Real      Word   Seg : Ofs ';
    xTemplate	=  ' ssssssssssssssssssssบRRRRRRR.ZZZR|($rr,rrr.zz)|WWWWW บ HHHH:HHHH ';

    Prefix =  'FILESHOP.DAT --from a tvDMX program by R. Beck'#13#10#26;
	{ this string is used as a demo file header }


    InteriorInfo	:  string[length(xTemplate)]	=  xTemplate;
    InteriorHeader	:  string[length(xLabels)]	=  xLabels;

    PrefixInfo		:  string[length(Prefix)]	=  Prefix;

    cmOpenWin		=  101;


type
    TRecord	=  RECORD
	A	: string[20];
	B	: real;
	C	: real;
	D	: word;
	E	: pointer;
    end;


    PDmxInterior  = ^TDmxInterior;
    TDmxInterior  =  OBJECT(TDmxExpBuf)

     { see documentation on tvDMX's virtual methods if you wish to
       modify your tvDMX view's behavior  }

    end;


    PDmxStreamWin = ^TDmxStreamWin;
    TDmxStreamWin =  OBJECT(TDmxExpBufWin)
      procedure InitDMX(ATemplate : string;  var AData;
			 ALabels, ARecInd  : PDmxLink;
			 BSize	: longint);  VIRTUAL;
    end;


    TAppN	=  OBJECT(TAppA)
    end;

    TMyApp	=  OBJECT(TAppN)
      constructor Init;
      destructor  Done;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure InitMenuBar;  VIRTUAL;
      procedure OpenWindow;
      function	OpenFile(var F : TDosStream;  FName : string)  : boolean;
      procedure CloseFile(var F : TDosStream);
    end;


var
    WorkFile	:  TDosStream;	{ could be any TStream derivative }


  { ออ TDmxInterior ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


     { see documentation on tvDMX's virtual methods if you wish to
       modify your tvDMX view's behavior  }


  { ออ TDmxStreamWin อออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxStreamWin.InitDMX(ATemplate : string;  var AData;
				 ALabels, ARecInd : PDmxLink; BSize : longint);
var  R	   : TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If (ALabels <> nil) then Inc(R.A.Y, 2);
  Insert(New(PDmxInterior, Init(ATemplate, AData, BSize, R,
		ALabels, ARecInd,
		StandardScrollBar(sbHorizontal+ sbHandleKeyboard),
		StandardScrollBar(sbVertical  + sbHandleKeyboard))));

end;


  { ออ TMyApp ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TMyApp.Init;
begin
  TAppN.Init;

  If OpenFile(WorkFile, 'FILESHOP.DAT') then
    begin
    OpenWindow;  { open the data window }
    end
   else
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
      cmOpenWin  : OpenWindow;
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
    NewSubMenu('~F~ileshop', hcNoContext, NewMenu(
      NewItem('~O~pen',    'F4',   kbF4,   cmOpenWin, hcNoContext,
      NewLine(
      NewSoundItem(hcNoContext,
      NewVideoItem(hcNoContext,
      NewLine(
      NewItem('e~X~it',  'Alt-X',  kbAltX, cmQuit,    hcNoContext,
      nil))))))),
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
begin
  AssignWinRect(R, length(xLabels) + 2, 0);

  { Reminder:  The stream used for WorkFile must already be initialized,
	       and be able to read and write data to and from the stream. }

  DeskTop^.Insert(ValidView(
	New(PDmxStreamWin, Init(R,
		'Fileshop',
		wnNextAvail,
		InteriorInfo,
		WorkFile,		 { TStream-derivative }
		length(PrefixInfo),		{ prefix size }
		InteriorHeader,
		10))
	));
end;


function  TMyApp.OpenFile(var F : TDosStream;  FName : string)	: boolean;
var  Len : longint;
begin
  With F do
    begin
    Init(FName, stOpen);
    If Status <> stOk then
      begin
      Done;
      Init(FName, stCreate);
      Done;
      Init(FName, stOpen);
      end;
    If Status = stOk then
      begin
      Len := GetSize;
      If Len < length(PrefixInfo) then
	begin
	Seek(0);
	Reset;
	Write(PrefixInfo[1], length(PrefixInfo));
	end;
      end;
    OpenFile := (Status = stOk);
    end;
end;


procedure TMyApp.CloseFile(var F : TDosStream);
begin
  F.Done
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }

var
    MyApp      :  TMyApp;

Begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.
