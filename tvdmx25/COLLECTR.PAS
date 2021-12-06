
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	COLLECTR  --Collection Data Editing Demo	}
{	tvDMX	  --data editing project		}
{							}
{	Copyright (c) 1992,93	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Program COLLECTR;

(*  This program demonstrates how to use unit tvDMXCOL.PAS with a collection
    of records and a collection of objects.  tvDMXCOL uses TDmxCollector(a
    tvDMX descendant object) to edit data in collections.

    Although TDmxCollector can be derived to work with sorted collections,
    this would require some changes to the EvaluateRecord() method.
    Even so, this perpetual sorting could disturb the user, so it might
    still be best to transfer the data to a non-sorting collection and then
    sort again afterward.

    TDmxCollectorWin is a TDmxWindow derivative that uses TDmxCollector.

    Both of the sample windows in this program are of the same structure and
    appearance, but this was only to make my work easier.  It should be easy
    to insert TDmxCollectorWin-windows into your programs with your data.
    Just make sure that your DMX template matches the data.


  Function fldObjectVMT(Obj : PObject) : string;

   ...generates a template prefix for an object's virtual method table.
    This is declared in unit tvDMXCOL.	It should be used with collections
    of TObject derivatives so that tvDMX can create VMT's when new records
    are entered.  Object Obj is disposed after its VMT code is known.

    The template prefix is actually a pair of hidden fields with default
    values as that of the VMT ID.

    Procedure ObjWindow() uses this function.

 *)

{$V-,X+,B-,R- }

uses
    Objects, Drivers, Memory, Views, Menus, App, MsgBox,
    RSet, DmxGizma, tvGizma, tvDMX, StdDMX, tvDMXCOL, tvDMXREP,
    tvDMXBUF;

const
    cmRecWin	    =  101;
    cmObjWin	    =  102;
    cmPrint	    =  103;

    { This is the label and template for record TMyRecord. }

    _RecLabels	 =  ' String Field          String Field 2          +Real         Real      Word   Seg : Ofs ';
    _RecTemplate =  ' ssssssssssssssssssss| ssssssssssssssssssssบRRRRRRR.RRR |($rr,rrr.zz)|WWWWW บ HHHH:HHHH ';
    RecLabels	 :  string[length(_RecLabels)]	  =  _RecLabels;
    RecTemplate	 :  string[length(_RecTemplate)]  =  _RecTemplate;


    { This is the label and template for object TMyObject. }

    _ObjLabels	 =  ' String Field          String Field 2          +Real         Real      Word   Seg : Ofs ';
    _ObjTemplate =  ' ssssssssssssssssssss| ssssssssssssssssssssบRRRRRRR.RRR |($rr,rrr.zz)|WWWWW บ HHHH:HHHH ';
    ObjLabels	 :  string[length(_ObjLabels)]	  =  _ObjLabels;
    ObjTemplate	 :  string[length(_ObjTemplate)]  =  _ObjTemplate;
    { The codes to provide for a VMT are concatenated in TApp.ObjWindow. }


type
    PRecCollection  = ^TRecCollection;
    TRecCollection  =  OBJECT(TCollection)
      procedure FreeItem(Item : pointer);  VIRTUAL;
    end;


    PMyRecord  = ^TMyRecord;
    TMyRecord  =  RECORD
	S1     : string[20];
	S2     : string[20];
	R1,R2  : real;
	W      : word;
	P      : pointer;
    end;


    PMyObject  = ^TMyObject;
    TMyObject  =  OBJECT(TObject)
	S1     : string[20];
	S2     : string[20];
	R1,R2  : real;
	W      : word;
	P      : pointer;
      constructor Init(AS1,AS2 :string; AR1,AR2 :real; AW :word; AP :pointer);
    end;


    TAppN	=  OBJECT(TAppPrn)
    end;

    TApp	=  OBJECT(TAppN)
      procedure HandleEvent(var Event : TEvent);  VIRTUAL;
      procedure InitMenuBar;  VIRTUAL;
      procedure RecWindow;
      procedure ObjWindow;
    end;


var
    RecCollection  :  PRecCollection;
    ObjCollection  :  PCollection;


  { ออ TRecCollection ออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TRecCollection.FreeItem(Item : pointer);
begin
  If (Item <> nil) then Dispose(PMyRecord(Item));
end;


  { ออ TMyObject อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TMyObject.Init(AS1,AS2 :string; AR1,AR2 :real; AW :word; AP :pointer);
begin
  TObject.Init;
  S1 := AS1;
  S2 := AS2;
  R1 := AR1;
  R2 := AR2;
  W  := AW;
  P  := AP;
end;


  { ออ TApp ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TApp.HandleEvent(var Event : TEvent);
begin
  TAppN.HandleEvent(Event);
  If Event.What = evCommand then
    begin
    Case Event.Command of
      cmRecWin: 	RecWindow;
      cmObjWin: 	ObjWindow;
      cmPrint:		PrnCurrentDMX;
      cmPRN_NewPage:	PrnPageStart(Event);
      cmPRN_EndPage:	PrnPageEnd(Event);
      cmPRN_SetOptions:	PrnSetOptions(hcNoContext, hcNoContext, hcNoContext);
     else		Exit;
      end;
    ClearEvent(Event);
    end;
end;


procedure TApp.InitMenuBar;
var  R : TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~C~ollector', hcNoContext, NewMenu(
      NewItem('~R~ecords',  'F3',  kbF3,   cmRecWin, hcNoContext,
      NewItem('~O~bjects',  'F4',  kbF4,   cmObjWin, hcNoContext,
      NewLine(
      NewSoundItem(hcNoContext,  { these are methods of TAppA }
      NewVideoItem(hcNoContext,  { this item appears only on hi-res systems }
      NewLine(
      NewItem('e~X~it',  'Alt-X',  kbAltX, cmQuit,   hcNoContext,
      nil)))))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~S~ize/Move', 'Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom',      'F5',  kbF5,    cmZoom, hcNoContext,
      NewItem('~T~ile',      '',    kbNoKey, cmTile, hcNoContext,
      NewItem('C~a~scade',   '',    kbNoKey, cmCascade, hcNoContext,
      NewItem('~N~ext',      'F6',  kbF6,    cmNext, hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3',  kbAltF3, cmClose, hcNoContext,
      NewLine(
      NewItem('~U~ser screen', 'Alt-F5', kbAltF5, cmUserScreen, hcNoContext,
      nil)))))))))),
    NewSubMenu('~P~rint', hcNoContext, NewMenu(
      NewItem('~P~rint',     '',    kbNoKey, cmPrint,  hcNoContext,
      StdPrnMenuItems(hcNoContext,
      nil))),
    nil))))
  ));
end;


procedure TApp.RecWindow;
var  R	: TRect;
begin
  AssignWinRect(R, 0,0);
  DeskTop^.Insert(ValidView(New(PDmxCollectorWin, Init(R,
		'Record Editor',
		wnNextAvail,
		RecTemplate,
		RecCollection,
		0,  { maximum collection size (0=no limit; -1=no expansions) }
		RecLabels, 11)
	)));
end;


procedure TApp.ObjWindow;
var  R	: TRect;
     T	: string;
var  W	 : PWindow;
begin
  T := fldObjectVMT(New(PMyObject,Init('','',0.,0.,0,nil))) + ObjTemplate;
  AssignWinRect(R, 0,0);

  New(W, Init(R, 'Object Editor', wnNextAvail));
  With W^ do
    begin
    Options := Options or ofTileable;
    GetExtent(R);
    R.Grow(-1,-1);
    Inc(R.A.Y, 2);
    Insert(New(PDmxCollector, Init(T,
		ObjCollection^, 0, R,
		New(PDmxFLabels,   InitInsert(W, ObjLabels)),
		New(PDmxExpRecInd, InitInsert(W, 10)),
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical))
	 ));
    end;
  DeskTop^.Insert(W);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure InitializeData;
{ creates test data }

    function NewRec(AS1,AS2 :string; AR1,AR2 :real; AW :word; AP :pointer) : PMyRecord;
    var PR : PMyRecord;
    begin
      New(PR);
      With PR^ do
	begin
	S1 := AS1;
	S2 := AS2;
	R1 := AR1;
	R2 := AR2;
	W  := AW;
	P  := AP;
	end;
      NewRec := PR;
    end;

begin
  RecCollection^.Insert(NewRec('Abigail Adams',  'Massachusetts',1,1, 1, pointer(0)));
  RecCollection^.Insert(NewRec('Betty Boop',	 'ToonTown',	 2,2, 2, pointer(4)));
  RecCollection^.Insert(NewRec('Charlie Chaplin','IBM Archives', 3,3, 3, pointer(8)));
  RecCollection^.Insert(NewRec('Doris Day',	 'Hollywood',	 4,4, 4, pointer(12)));
  RecCollection^.Insert(NewRec('Elbert Eagleton','Elm Street',	 5,5, 5, pointer(16)));

  ObjCollection^.Insert(New(PMyObject, Init('Adam West', 'Gotham City', 1,1, 1, pointer(20))));
  ObjCollection^.Insert(New(PMyObject, Init('Burt Ward', 'Gotham City', 2,2, 2, pointer(24))));
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure CloseData(Name : string;  Collection : PCollection);
{ displays count of records in a collection, and disposes of the collection }
var  S : string;
begin
  FormatStr(S, '%d (0%xH) records entered into %s.',
	     dparam(Collection^.Count,
	     dparam(Collection^.Count,
	     sparam(@Name,
		     nil)))^
	);
  PrintStr(S + ^M^J);
  Collection^.FreeAll;
  Dispose(Collection, Done);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


var  MyApp : TApp;

Begin
  New(RecCollection, Init(200, 10));
  New(ObjCollection, Init(200, 10));
  InitializeData;

  MyApp.Init;
  MyApp.Run;
  MyApp.Done;

  CloseData('RecCollection', RecCollection);
  CloseData('ObjCollection', ObjCollection);
End.
