
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	tvDMXHEX  --Hexadecimal Data Editing Unit	}
{	tvDMX	  --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1993  Randolph Beck		}
{			    P.O. Box  56-0487		}
{			    Orlando, FL 32856		}
{			    CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Unit tvDMXHEX;

{$V-,X+,O+,D-,B-,R- }

interface

uses  Objects, Drivers, Views, Menus, App, RSet, DmxGizma, tvDMX, StdDMX;


const
    _HexLabels	=  '  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F   0123456789ABCDEF ';

    HexInfo	=    ^A					{ show all zeroes }
		   + '\HH\HH\HH\HH\HH\HH\HH\HH'		{ hex byte display }
		   + ^D + '-HH\HH\HH\HH\HH\HH\HH\HH'	{  of 16 bytes }
		   + '\ \'				{ blank spaces }
		   + ^P + char(-16)			{ position -16 bytes }
		   + 'c'^V#0#0'c'^V#0#0'c'^V#0#0'c'^V#0#0  { 16 characters }
		   + 'c'^V#0#0'c'^V#0#0'c'^V#0#0'c'^V#0#0  { Default Value }
		   + 'c'^V#0#0'c'^V#0#0'c'^V#0#0'c'^V#0#0  {	  is ZERO. }
		   + 'c'^V#0#0'c'^V#0#0'c'^V#0#0'c'^V#0#0;

    HexLabels	:  string[length(_HexLabels)]  = _HexLabels;


type
    PDmxHexInd		= ^TDmxHexInd;
    PDmxHex		= ^TDmxHex;
    PDmxHexWin		= ^TDmxHexWin;


      { hexadecimal record number indicator }
    TDmxHexInd		=  OBJECT(TDmxRecInd)
      procedure Draw;  VIRTUAL;
    end;


      { main tvDMX-editing view }
    TDmxHex		=  OBJECT(TDmxEditor)
      procedure EvaluateField;	VIRTUAL;
      function	RecNumStr(RecNum : integer) : string;  VIRTUAL;
    end;


      { tvDMX-Window view }
    TDmxHexWin		=  OBJECT(TDmxWindow)
      constructor Init(var Bounds    : TRect;
			    ATitle    : TTitleStr;
			    ANumber   : integer;
			var AData;
			    BSize     : longint);
      procedure InitDMX(ATemplate : string;  var AData;
			 ALabels, ARecInd : PDmxLink;
			 BSize	 : longint);  VIRTUAL;
      function	NewRecInd(Len : integer)  : PDmxLink;  VIRTUAL;
    end;


const
    RDmxHexInd	 :  TStreamRec =(
	ObjType:   rnDmxHexInd;
	VmtLink:   ofs(TypeOf(TDmxHexInd)^);
	Load:	   @TDmxHexInd.Load;
	Store:	   @TDmxHexInd.Store
      );


  procedure RegisterTVDMXHEX;


implementation


  { ออ TDmxHexInd ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxHexInd.Draw;
const bts  :  array[0..15] of char = '0123456789ABCDEF';
var   A    :  string;
      B    :  TDrawBuffer;
      C    :  word;
begin
  C := GetColor(6);
  MoveChar(B, ' ', C, Size.X);
  With PDmxEditor(Link)^ do
    A := '['
	+ bts[(CurrentRecord shr 12) and $0F]
	+ bts[(CurrentRecord shr  8) and $0F]
	+ bts[(CurrentRecord shr  4) and $0F]
	+ bts[CurrentRecord and $0F]
	+ bts[(CurrentField^.fieldnum + $0F) and $0F]
	+ ']';
  While (length(A) > Size.X) and (A[2] = '0') do Delete(A,2,1);
  If length(A) > Size.X then
    MoveChar(B, showOVERFLOW, C, Size.X)
   else
    MoveStr(B[succ((Size.X) - length(A)) shr 1], A, C);
  WriteBuf(0, 0, Size.X, 1, B);
end;


  { ออ TDmxHex อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure TDmxHex.EvaluateField;
{ entire record must be redrawn if one byte is changed }
begin
  If FieldAltered then ReDrawRecord := TRUE;
  TDmxEditor.EvaluateField;
end;


function  TDmxHex.RecNumStr(RecNum : integer) : string;
const bts : array[0..15] of char = '0123456789ABCDEF';
var   A   : string;
begin
  If (RecNum >= RecordLimit) then
    A := '      '
   else
    begin
    A := ' 0000 ';
    If ((RecNum shr 12) and $0F > 0) then A[1] := bts[(RecNum shr 12) and $0F];
    A[2] := bts[(RecNum shr  8) and $0F];
    A[3] := bts[(RecNum shr  4) and $0F];
    A[4] := bts[RecNum and $0F];
    end;
  RecNumStr := A;
end;


  { ออ TDmxHexWin ออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


constructor TDmxHexWin.Init(var Bounds	 : TRect;
				 ATitle   : TTitleStr;
				 ANumber  : integer;
			     var AData;
				 BSize	  : longint);
begin
  TWindow.Init(Bounds, ATitle, ANumber);
  InitDMX(HexInfo, AData, NewDmxLabels(HexLabels), NewRecInd(6), BSize);
  Options := Options or ofTileable;
end;


procedure TDmxHexWin.InitDMX(ATemplate : string;  var AData;
			      ALabels, ARecInd : PDmxLink; BSize : longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  Inc(R.A.Y, 2);

  Insert(New(PDmxHex, Init(ATemplate, AData, BSize, R,
			      ALabels, ARecInd,
			      StandardScrollBar(sbHorizontal+ sbHandleKeyboard),
			      StandardScrollBar(sbVertical  + sbHandleKeyboard))));
end;


function  TDmxHexWin.NewRecInd(Len : integer)  : PDmxLink;
begin
  If Len <= 0 then
    NewRecInd := nil
   else
    NewRecInd := New(PDmxHexInd, InitInsert(@Self, Len));
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


procedure RegisterTVDMXHEX;
begin
  RegisterType(RDmxHexInd);
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }



End.
