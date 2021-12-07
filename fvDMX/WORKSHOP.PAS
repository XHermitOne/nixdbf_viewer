
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	WORKSHOP  --generic tvDMX demo program		}
{	tvDMX	  --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,93	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Program WORKSHOP;

{  This program was added to allow you to experiment with your own file
   structures.	Just edit the strings xTemplate and xLabels and you will see
   how easy it is to create new record structures --and what could go wrong
   if you mix types or leave out field delimiters.

   A record structure does not need to be defined to the compiler because
   this application uses a generic database of 8000 bytes(using the record
   structure specified by the string xTemplate).

   All you need to do is edit xTemplate and xLabels: tvDMX will do the rest.
 }

{$M 16384,16384,655360}
{$V-,X+,D-,B-,R- }

uses
    Objects, Drivers, Views, Menus, App,
    RSet, DmxGizma, tvDMX, tvGizma, tvDMXREP;

const
    xLabels	=  ' String Field            +Real         Real      Word   Seg : Ofs ';
    xTemplate	=  ' ssssssssssssssssssssบRRRRRRR.ZZZR|($rr,rrr.zz)|WWWWW บ HHHH:HHHH ';

    cmOpenWin	=  101;
    cmPrint	=  102;


type
    PDmxInterior    = ^TDmxInterior;
    TDmxInterior    =  OBJECT(TDmxEditor)

     { see documentation on tvDMX's virtual methods if you wish to
       modify your tvDMX view's behavior  }

    end;


    TAppN	=  OBJECT(TAppPrn)
    end;

    TMyApp	=  OBJECT(TAppN)
      constructor Init;
      procedure HandleEvent(var Event : TEvent);  VIRTUAL;
      procedure InitMenuBar;  VIRTUAL;
      procedure OpenWindow;
    end;


var
    WorkWindow	:  array[1..8000] of byte;  { generic database }


  { ออ TDmxInterior ออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


     { see documentation on tvDMX's virtual methods if you wish to
       modify your tvDMX view's behavior  }


  { ออ TMyApp ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TMyApp.Init;
begin
  TAppN.Init;
  OpenWindow;
end;


procedure TMyApp.HandleEvent(var Event : TEvent);
begin
  TAppN.HandleEvent(Event);
  If Event.What = evCommand then
    begin
    Case Event.Command of
      cmOpenWin:	OpenWindow;
      cmPrint:		PrnCurrentDMX;
      cmPRN_NewPage:	PrnPageStart(Event);
      cmPRN_EndPage:	PrnPageEnd(Event);
      cmPRN_SetOptions:	PrnSetOptions(hcNoContext, hcNoContext, hcNoContext);
     else		Exit;
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
    NewSubMenu('tv~DMX~', hcNoContext, NewMenu(
      NewItem('~O~pen',  'F4', kbF4, cmOpenWin, hcNoContext,
      NewLine(
      NewSoundItem(hcNoContext,
      NewVideoItem(hcNoContext,
      NewLine(
      NewItem('e~X~it',  'Alt-X',  kbAltX, cmQuit, hcNoContext,
      nil))))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~S~ize/Move', 'Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom',      'F5', kbF5,    cmZoom,	hcNoContext,
      NewItem('~T~ile',      '',   kbNoKey, cmTile,	hcNoContext,
      NewItem('C~a~scade',   '',   kbNoKey, cmCascade,	hcNoContext,
      NewItem('~N~ext',      'F6', kbF6,    cmNext,    hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3',  kbAltF3, cmClose,	hcNoContext,
      NewLine(
      NewItem('~U~ser screen', 'Alt-F5', kbAltF5, cmUserScreen, hcNoContext,
      nil)))))))))),
    NewSubMenu('~P~rint', hcNoContext, NewMenu(
      NewItem('~P~rint', 'F9', kbF9, cmPrint, hcNoContext,
      StdPrnMenuItems(hcNoContext,
      nil))),
    nil))))
  ));
end;


procedure TMyApp.OpenWindow;
var  R	: TRect;
     W	: PWindow;
begin
  AssignWinRect(R, length(xLabels) + 2, 0);  { assign window dimensions }
      { width of string xLabels plus two for the border; }
      { zero rows indicates extend to bottom of screen }

  New(W, Init(R, 'Work Window', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable; { must be tileable for AssignWinRect }
    GetExtent(R);		  { create new rectangle for editor object }
    R.Grow(-1,-1);			      { shrink -1 to avoid borders }
    Inc(R.A.Y, 2);			 { make room for TDmxLabels object }
    Insert(New(PDmxInterior,
	  Init(xTemplate,				 { template string }
		WorkWindow,				    { working data }
		sizeof(WorkWindow),		    { size of working data }
		R,					{ view's rectangle }
		New(PDmxFLabels, InitInsert(W, xLabels)), { label string }
		New(PDmxRecInd, InitInsert(W, 10)),    { indicator width }
		W^.StandardScrollBar(sbHorizontal),
		W^.StandardScrollBar(sbVertical)
		)
	));
    end;
  DeskTop^.Insert(ValidView(W));
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }

var  MyApp	:  TMyApp;


Begin
  FillChar(WorkWindow, sizeof(WorkWindow), 0);

  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.
