
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}
{							}
{	DMXGIZMA  --constants, variables and functions	}
{	tvDMX	  --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ}

Unit DMXGIZMA;

{$V-,X+,O+,D+,B-,R- }

interface

uses  Objects, Drivers, Views, Dialogs, App, RSet;

{$DEFINE tvDMX2A }

const
    { tvDMX commands }
    cmDMX		= FirstCmdNum;	{ defined in RSET.PAS }

    cmDMX_RollCall	= cmDMX +  1;
    cmDMX_Ack		= cmDMX +  2;
    cmDMX_FieldAltered	= cmDMX +  3;
    cmDMX_Draw		= cmDMX +  4;
    cmDMX_DrawData	= cmDMX +  5;
    cmDMX_Lock		= cmDMX +  6;
    cmDMX_LockData	= cmDMX +  7;
    cmDMX_Unlock	= cmDMX +  8;
    cmDMX_UnlockData	= cmDMX +  9;
    cmDMX_FixSize	= cmDMX + 10;
    cmDMX_SetupRecord	= cmDMX + 11;
    cmDMX_WrongKey	= cmDMX + 12;

    cmDMX_ZeroizeField	= cmDMX + 13;
    cmDMX_ZeroizeRecord	= cmDMX + 14;

    cmDMX_Enter		= cmDMX + 15;
    cmDMX_Left		= cmDMX + 16;
    cmDMX_Right		= cmDMX + 17;
    cmDMX_Home		= cmDMX + 18;
    cmDMX_End		= cmDMX + 19;

    cmDMX_goto		= cmDMX + 20;

    cmDMX_NextRow	= cmDMX + 21;
    cmDMX_Up		= cmDMX + 22;
    cmDMX_Down		= cmDMX + 23;
    cmDMX_PgUp		= cmDMX + 24;
    cmDMX_PgDn		= cmDMX + 25;
    cmDMX_ScreenTop	= cmDMX + 26;
    cmDMX_ScreenBottom	= cmDMX + 27;
    cmDMX_Top		= cmDMX + 28;
    cmDMX_Bottom	= cmDMX + 29;

    cmDMX_DoubleClick	= cmDMX + 30;  { mouse was double-clicked }
    cmDMX_RecIndClicked	= cmDMX + 31;  { record indicator was clicked }
    cmDMX_Reset		= cmDMX + 32;  { tvDMXCOL: reset size of collection }
    cmDMX_ScrollBarChanged =cmDMX+33;  { updates the TDmxLabels views }
    cmDMX_InsertRec	= cmDMX + 34;  { inserts a new record }

    cmPRN_NewPage	= cmDMX + 40;  { tvDMXREP: broadcast before new page }
    cmPRN_EndPage	= cmDMX + 41;  { tvDMXREP: broadcast before page end }
    cmPRN_SetOptions	= cmDMX + 42;  { tvDMXREP: open options window }
    cmPRN_LineFeed	= cmDMX + 43;  { tvDMXREP: line feed to printer }
    cmPRN_FormFeed	= cmDMX + 44;  { tvDMXREP: form feed to printer }
    cmPRN_Reset		= cmDMX + 45;  { tvDMXREP: reset printer }

    cmUserScreen	= cmDMX + 51;  { tvGizma: invokes User Screen }
    cmToggleSound	= cmDMX + 52;  { tvGizma: toggles BeepOn }
    cmToggleVideo	= cmDMX + 53;  { tvGizma: toggles video mode }
    cmBeep		= cmDMX + 54;  { tvGizma: beeps if BeepOn is TRUE }
    cmChime		= cmDMX + 55;  { tvGizma: broadcast every 30 minutes }


    { tvDMX view registration numbers }
    rnDMX		= FirstRegNum;	{ defined in RSET.PAS }

    rnLtdFrame		= rnDMX +  1;	{ RegisterTVGIZMA }
    rnLtdWindow		= rnDMX +  2;

    rnDmxExtLabels	= rnDMX +  3;	{ RegisterTVDMX }
    rnDmxLabels		= rnDMX +  4;
    rnDmxFLabels	= rnDMX +  5;
    rnDmxMLabels	= rnDMX +  6;
    rnDmxRecInd		= rnDMX +  7;
    rnDmxScroller	= rnDMX +  8;
    rnDmxEditor		= rnDMX +  9;

    rnDmxHexInd		= rnDMX + 10;	{ RegisterTVDMXHEX }

    rnDmxEditDlg	= rnDMX + 11;	{ RegisterSTDDMX }
    rnInputFields	= rnDMX + 12;
    rnValidFields	= rnDMX + 13;
    rnDmxViewer		= rnDMX + 14;
    rnDmxWindow		= rnDMX + 15;

    rnDmxCollectView	= rnDMX + 16;	{ RegisterTVDMXCOL }
    rnDmxCollector	= rnDMX + 17;
    rnDmxCollectViewWin	= rnDMX + 18;
    rnDmxCollectorWin	= rnDMX + 19;

    rnDmxStreamBuf	= rnDMX + 20;	{ RegisterTVDMXBUF }
    rnDmxExpBuf		= rnDMX + 21;
    rnDmxExpRecInd	= rnDMX + 22;
    rnDmxBufWin		= rnDMX + 23;
    rnDmxExpBufWin	= rnDMX + 24;

    rnDmxForm		= rnDMX + 25;	{ RegisterDMXFORMS }
    rnDmxDlgForm	= rnDMX + 26;


    cDMX		= #06#07#05#05#01#02;
			 {  |  |  |  |	|  | }
  {  1 normal fields -------+  |  |  |	|  | }
  {  2 normal selected field --+  |  |	|  | }
  {  3 read-only selected field --+  |	|  | }
  {  4 locked field -----------------+	|  | }
  {  5 delimiter -----------------------+  | }
  {  6 border -----------------------------+ }


    { tvDMX field access attributes }
    accNormal	 =    0;
    accReadOnly	 =    1;
    accHidden	 =    2;
    accSkip	 =    4;
    accDelimiter =    8;
    accExternal	 =  $10;	{ for future use }
    accSpecA	 =  $20;
    accSpecB	 =  $40;
    accSpecC	 =  $80;

    showTRUE	 :  char  =   'þ';  { TRUE indicator  }
    showFALSE	 :  char  =   ' ';  { FALSE indicator }
    showOVERFLOW :  char  =   '*';  { overflow indicator for numbers }
    showDecPt	 :  char  =   '.';  { decimal point display }
    showRadioBtn :  char  =   #7;   { DMX RadioBtn indicator (#4 looks better) }
    showCheckBox :  char  =   'X';  { DMX CheckBox ON indicator }

    SizeOfFldCluster	:  integer = sizeof(WORD);

    fldSTR		=   'S';  { string field }
    fldSTRNUM		=   '#';  { numeric string field }
    fldCHAR		=   'C';  { character field }
    fldCHARNUM		=   '0';  { numeric character field }
    fldCHARVAL		=   'N';  { dbase formatted numeric field }
    fldBYTE		=   'B';  { byte field }
    fldSHORTINT		=   'J';  { shortint field }
    fldWORD		=   'W';  { word field }
    fldINTEGER		=   'I';  { integer field }
    fldLONGINT		=   'L';  { longint field }
    fldREALNUM		=   'R';  { real number field  (uses TREALNUM) }
    fldBOOLEAN		=   'X';  { boolean value field }
    fldHEXVALUE		=   'H';  { hexadecimal numeric entry }
    fldENUM		=   ^E;   { enumerated field }
    fldBLOb		=   ^M;   { unformatted data field }
    fldCLUSTER		=   'K';  { 'K'=CheckBox; 'k'=RadioButton }

    fldZEROMOD		=   'Z';  { zero modifier }
    fldCONTRACTION	=   '`';  { limit of visible text }

    fldAPPEND		=   ^G;   { append from pointer }
    fldSITEMS		=   ^I;   { link to chain of TSItem templates }

    fldXSPACES		=   ' ';  { spaces --extended code follows <Esc> }
    fldXTABTO		=   ^I;   { tab    --extended code follows <Esc> }
    fldXFIELDNUM	=   ^F;   { fnum   --extended code follows <Esc> }


  { Complex fields: }

    fldDATE	 =  ' WW-'^F^Z + ^U+char(12) + ^P+char(2) +
		     #0'ZW-'^Z + ^U+char(31) +
		     #0'ZZZW '^Z^F + ^P+char(-6) +
		     #0 + ^P+char(4);

    fldTIME	 =  ' WW:'^F^Z + ^U+char(23) +
		     #0'ZW '^Z + ^U+char(59) +
		     #0'W'^F^H#0;  { seconds are hidden }

    fldDATETIME  =  ' WW-'^F^Z + ^U+char(12) + ^P+char(2) +
		     #0'ZW-'^Z + ^U+char(31) +
		     #0'ZZZW '^Z^F + ^P+char(-6) +
		      '\' + ^P+char(4) +
		      ' WW:'^F^Z + ^U+char(23) +
		     #0'ZW:'^Z	 + ^U+char(59) +
		     #0'ZW '^Z^F + ^U+char(59);  { seconds are not hidden }

    fldNDATE	 =  { dBASE-formatted date field }
		    ' NN-'^Z^F^V'0' + ^P+char(4) +
		     #0'ZN-'^Z^V'0' +
		     #0'ZZZN '^Z^F^V'0' + ^P+char(-8) +
		     #0^P + char(4);

    CurrentCurPos : integer = 0;


type
    pDMXfieldrec = ^tDMXfieldrec;
    tDMXfieldrec =  RECORD    { these records describe each field for tvDMX }
	Next,Prev	:  pDMXfieldrec;
	access		:  byte;	{ read-only, hidden, skip, accSpecX }
	fieldnum	:  byte;	{ 1..totalfields (0=none) }
	screentab	:  integer;	{ virtual column num. }
	columnwid	:  byte;	{ width of field column }
	shownwid	:  byte;	{ visible width of column }
	typecode	:  char;	{ 's', 'r', etc. }
	fillvalue	:  char;	{ #0 or ' ' }
	upperlimit	:  byte;	{ maximum value limit }
	showzeroes	:  boolean;	{ display zero values }
	truelen		:  byte;	{ unformatted text length }
	parenthesis	:  boolean;	{ '('/')' characters }
	decimals	:  byte;	{ decimal point or cluster value }
	fieldsize	:  integer;	{ sizeof (datatype) }
	datatab		:  integer;	{ position in record }
	template	:  pstring;	{ field template }
    end;


    showcodes	= (showanyway, shownegative, showregular, showCurrentField);
    showset	=  set of showcodes;	{ used when displaying fields }

    DmxIDstr	=  string[8];		{ contracted template string }



  function  InitAppendFields(ATemplate: pstring) : DmxIDstr;
    { initialize a pointer to more field templates }

  function  InitBlobField(Len: integer; AccMode,Default: byte) : DmxIDstr;
    { initialize an unformatted data field }

  function  InitEnumField(ShowZ: boolean;  AccMode,Default: byte;
			  AItems: PSItem) : DmxIDstr;
    { initialize a tvDMX enum field list }

  function  InitTSItemFields(ATemplates: PSItem) : DmxIDstr;
    { initialize a chain of TSItem templates }

  procedure DisposeSItems(AItems: PSItem);
    { dispose a chain of TSItems }

  function  ReadSItems(var S: TStream) : PSItem;
    { reads strings from a pick list }

  procedure WriteSItems(var S: TStream; Items: PSItem);
    { writes strings to a pick list }

  function  MaxItemStrLen(AItems: PSItem) : integer;
    { returns the maximum length of the strings in a pick list }

  function  SItemsLen(S: PSItem) : integer;
    { returns the cumulative length of the strings in a pick list }

  function  DmxStrLen(S: string)  : integer;
    { returns the length of the visible portions of a tvDMX template string }

  function  FieldString(fieldrec: pDMXfieldrec;
			Show: showset;  var DataRec )  : string;
    { returns a display string from a tvDMX field record }


implementation


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  InitAppendFields(ATemplate: pstring) : DmxIDstr;
var  S : DmxIDstr;
begin
  S := fldAPPEND + #0#0#0#0#0#0#0;
  Move(ATemplate, S[2], 4);
  InitAppendFields := S;
end;


function  InitBlobField(Len: integer; AccMode,Default: byte) : DmxIDstr;
var  S : DmxIDstr;
begin
  S := fldBLOb + #0#0#0#0#0 + chr(AccMode) + chr(Default);
  Move(Len, S[2], sizeof(Len));
  InitBlobField := S;
end;


function  InitEnumField(ShowZ: boolean; AccMode,Default: byte;
			AItems: PSItem) : DmxIDstr;
var  S : DmxIDstr;
begin
  S := fldENUM + #0#0#0#0 + char(ShowZ) + chr(AccMode) + chr(Default);
  Move(AItems, S[2], 4);
  InitEnumField := S;
end;


function  InitTSItemFields(ATemplates: PSItem) : DmxIDstr;
var  S : DmxIDstr;
begin
  S := fldSITEMS + #0#0#0#0#0#0#0;
  Move(ATemplates, S[2], 4);
  InitTSItemFields := S;
end;


procedure DisposeSItems(AItems: PSItem);
var  P : PSItem;
begin
  While (AItems <> nil) do
    begin
    P := AItems^.Next;
    If (AItems^.Value <> nil) then DisposeStr(AItems^.Value);
    Dispose(AItems);
    AItems := P;
    end;
end;


function  ReadSItems(var S: TStream) : PSItem;
var  P,P1 : PSItem;
     n	  : integer;
begin
  P1 := nil;
  S.Read(n, sizeof(n));
  While (S.Status = stOK) and (n > 0) do
    begin
    If (P1 = nil) then
      begin
      New(P1);
      P := P1;
      end
     else
      begin
      New(P^.Next);
      P := P^.Next;
      end;
    P^.Value := S.ReadStr;
    P^.Next  := nil;
    Dec(n);
    end;
  ReadSItems := P1;
end;


procedure WriteSItems(var S: TStream; Items: PSItem);
var  P : PSItem;
     n : integer;
begin
  P := Items;
  n := 0;
  While (P <> nil) do
    begin
    Inc(n);
    P := P^.Next;
    end;
  S.Write(n, sizeof(n));
  While (Items <> nil) do
    begin
    S.WriteStr(Items^.Value);
    Items := Items^.Next;
    end;
end;


function  MaxItemStrLen(AItems: PSItem) : integer;
var  len : integer;
begin
  len := 0;
  While (AItems <> nil) do
    begin
    If (AItems^.Value <> nil) and (length(AItems^.Value^) > len) then
      len := length(AItems^.Value^);
    AItems := AItems^.Next;
    end;
  MaxItemStrLen := len;
end;


function  SItemsLen(S: PSItem) : integer;
var  Len : integer;
begin
  Len := 0;
  While (S <> nil) do
    begin
    If (S^.Value <> nil) then Inc(Len, length(S^.Value^));
    S := S^.Next;
    end;
  SItemsLen := Len;
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  DmxStrLen(S: string) : integer;
var  i,Len,Wid,Ttl	: integer;
     h			: boolean;

    procedure ResetDelimiter(D: boolean);
    begin
      If not h then
	begin
	If (Wid = 0) then Inc(Ttl, Len) else Inc(Ttl, Wid);
	end;
      If D then Inc(Ttl);
      Len := 0;
      Wid := 0;
      h   := FALSE;
    end;

begin
  h   := FALSE;
  Ttl := 0;
  Len := 0;
  Wid := 0;
  i   := 0;
  While (i < length(S)) do
    begin
    Inc(i);
    Case upcase(S[i]) of
      '~':
	begin
	Inc(i);
	While (S[i] <> '~') and (i < length(S)) do
	  begin
	  Inc(Len);
	  Inc(i);
	  end;
	end;
      ^C, ^P, ^U, ^V:	Inc(i);
      ^H:		h := TRUE;
      ^D:
	begin
	ResetDelimiter(TRUE);
	Inc(i);
	end;
      fldCONTRACTION:	Wid := Len;
      fldCLUSTER:
	begin
	Inc(Len);
	Inc(i);
	end;
      fldENUM:
	begin
	ResetDelimiter(FALSE);
	Inc(Len, MaxItemStrLen(PSItem(S[i+1])));
	Inc(i, sizeof(DmxIDstr) - 1);
	end;
      fldBLOb:
	begin
	ResetDelimiter(FALSE);
	Inc(i, sizeof(DmxIDstr) - 1);
	end;
      fldAPPEND:
	begin
	ResetDelimiter(FALSE);
	Inc(Len, DmxStrLen(pstring(S[i+1])^));
	Inc(i, sizeof(DmxIDstr) - 1);
	end;
      #0,'\','|','ณ','บ':
	begin
	ResetDelimiter(S[i] <> #0);
	end;
      ^A..^Z:	begin  end;
      #27:
	begin
	Inc(i);
	Case upcase(S[i]) of
	  fldXSPACES,fldXTABTO:
	    begin
	    end;
	  fldXFIELDNUM:
	    begin
	    Inc(i);
	    end;
	  end;
	end;
     else	Inc(Len);
      end;
    end;
  ResetDelimiter(FALSE);
  DmxStrLen := Ttl;
end;


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


function  FieldString(fieldrec: pDMXfieldrec; Show: showset;  var DataRec ) : string;
var  i,j,Len	:  integer;
     C		:  char;
     Numbers	:  boolean;
     ItsBlank	:  boolean;
     Q		:  boolean;
     L		:  longint;
     A,T	:  string;
     R		:  TREALNUM;
     Items	:  PSItem;

     Data	:  pointer;
     DataBool	:  pboolean	absolute Data;
     DataByte	:  pbyte	absolute Data;
     DataShort	:  pshortint	absolute Data;
     DataInt	:  pinteger	absolute Data;
     DataWord	:  pword	absolute Data;
     DataLong	:  plongint	absolute Data;
     DataReal	:  PREALNUM	absolute Data;
     DataStr	:  pstring	absolute Data;

    function  HexByte(Number: byte)  : string;
    const bts  : array[0..15] of char = '0123456789ABCDEF';
    begin
      HexByte := bts[(Number shr 4) and $0F] + bts[Number and $0F]
    end;

    function  BlankField : boolean;
    var  i : word;
    begin
      BlankField := TRUE;
      If Len > 0 then
	For i := 0 to pred(fieldrec^.fieldsize) do
	  If DataStr^[i] <> #0 then BlankField := FALSE;
    end;

    function  CheckBlank(Zero: boolean) :  boolean;
    begin
      If (Zero) and not ((fieldrec^.showzeroes) or (showanyway in Show)) then
	begin
	fillchar(A[1], Len, ' ');
	A[0]	   := chr(Len);
	ItsBlank   := TRUE;
	CheckBlank := TRUE;
	end
       else
	CheckBlank := FALSE;
    end;

    function  CheckInfinity : boolean;
    var  w : word;
    begin
      CheckInfinity := FALSE;
      If (sizeof(TREALNUM) = sizeof(Double)) then
	begin
	Move(pstring(DataStr)^[6], w, sizeof(w));
	If (w and $7FF0 = $7FF0) then
	  begin
	  fillchar(A[1], Len, ' ');
	  A[0]	   := chr(Len);
	  ItsBlank := TRUE;
	  CheckInfinity := TRUE;
	  end;
	end;
    end;

    procedure FormNum(sign: boolean);
    { length of A[] must equal Len + 1 }
    var  i,j : integer;
	 cc  : char;
    begin
      With fieldrec^ do
	begin
	If sign and (shownegative in Show) then
	  begin
	  i := 1;
	  While (A[i] = ' ') do Inc(i);
	  If (i > 1) then A[pred(i)] := '-';
	  end;
	If (parenthesis) then
	  begin
	  If sign then
	    begin
	    T[pos('(', T)] := ' ';
	    T[pos(')', T)] := ' ';
	    end
	   else
	    begin
	    A[pos('-', A)] := ' ';
	    If length(A) > succ(Len) then Delete(A, 1,1);
	    end;
	  end;
	If (A[1] <> ' ') then
	  begin
	  fillchar(A[1], Len, showOVERFLOW);
	  A[0] := chr(Len);
	  end
	 else
	  begin
	  Delete(A, 1,1);
	  Numbers := TRUE;
	  end;
	end;
    end;


begin
  With fieldrec^ do
    begin
    If (fieldrec = nil) or (access and accHidden <> 0) then
      begin
      FieldString := '';
      Exit;
      end;
    If (template = nil) or (columnwid = 0) then
      begin
      If typecode <> #0 then FieldString := typecode else FieldString := '';
      Exit;
      end;
    If (upcase(typecode) = fldENUM) then
      begin
      fillchar(T[1], columnwid, ' ');
      T[0] := chr(columnwid);
      end
     else
      T  := template^;
    If (fieldsize = 0) then
      begin
      FieldString := T;
      Exit;
      end;
    Data := ptr(seg(DataRec), ofs(DataRec) + datatab);
    Len  := truelen;
    Numbers  := FALSE;
    ItsBlank := FALSE;
    Q	 := FALSE;
    C	 := upcase(typecode);
    Case C of

      fldSTR, fldSTRNUM:			{ 'S'/'#' }
	begin
	If DataStr^ <> '' then
	  For i := 1 to length(DataStr^) do
	    If ord(DataStr^[i]) and $DF <> 0 then Q := TRUE;
	If not CheckBlank(not Q) then
	  begin
	  fillchar(A[1], Len, ' ');
	  Move(DataStr^[1], A[1], length(DataStr^));
	  A[0] := chr(Len);
	  end;
	end;

      fldCHAR, fldCHARNUM:		{ 'C'/'0' }
	begin
	If Len > 0 then
	  For i := 0 to pred(Len) do
	    If ((ord(DataStr^[i]) and $DF) <> 0) then Q := TRUE;
	If not CheckBlank(not Q) then
	  begin
	  Move(Data^, A[1], Len);
	  A[0] := chr(Len);
	  end;
	end;

      fldCHARVAL:			{ 'N' }
	begin
	A[0] := chr(fieldsize);
	Move(Data^, A[1], fieldsize);
	Val(A, R, i);
	If i <> 0 then R := 0.0;
	If not CheckBlank(R = 0.0) then
	  begin
	  If decimals > 0 then
	    begin
	    Str(R:(Len + 2):decimals, A);
	    Delete(A,(Len + 2) - decimals, 1);
	    end
	   else
	    Str(R:(Len + 1):0, A);
	  FormNum(R >= 0);
	  end;
	end;

      fldBYTE:				{ 'B' }
	If not CheckBlank(DataByte^ = 0) then
	  begin
	  Str(DataByte^:(Len + 1), A);
	  FormNum(TRUE);
	  end;

      fldSHORTINT:			{ 'J' }
	If not CheckBlank(DataShort^ = 0) then
	  begin
	  Str(DataShort^:(Len + 1), A);
	  FormNum(DataShort^ >= 0);
	  end;

      fldWORD:				{ 'W' }
	If not CheckBlank(DataWord^ = 0) then
	  begin
	  Str(DataWord^:(Len + 1), A);
	  FormNum(TRUE);
	  end;

      fldINTEGER:			{ 'I' }
	If not CheckBlank(DataInt^ = 0) then
	  begin
	  Str(DataInt^:(Len + 1), A);
	  FormNum(DataInt^ >= 0);
	  end;

      fldLONGINT:			{ 'L' }
	If not CheckBlank(DataLong^ = 0) then
	  begin
	  Str(DataLong^:(Len + 1), A);
	  FormNum(DataLong^ >= 0);
	  end;

      fldREALNUM:			{ 'R' }
	begin
	If not CheckInfinity and not CheckBlank(DataReal^ = 0.0) then
	  begin
	  If decimals > 0 then
	    begin
	    Str(DataReal^:(Len + 2):decimals, A);
	    Delete(A,(Len + 2) - decimals, 1);
	    end
	   else
	    Str(DataReal^:(Len + 1):0, A);
	  If (abs(DataReal^) > 1e35) then
	    begin
	    A := '**********************************';
	    If (DataReal^ < 0.0) then A[1] := '-';
	    end;
	  FormNum(DataReal^ >= 0);
	  end;
	end;

      fldBOOLEAN:			{ 'X' }
	begin
	If (Len = 0) then
	  begin
	  If DataBool^ then A := '' else ItsBlank := TRUE;
	  end
	 else
	  begin
	  If not CheckBlank(not DataBool^) then
	    begin
	    If DataBool^ then
	      fillchar(A[1], Len, showTRUE)
	     else
	      fillchar(A[1], Len, showFALSE);
	    A[0] := chr(Len);
	    end;
	  end;
	end;

      fldHEXVALUE:			{ 'H' }
	If not CheckBlank(BlankField) then
	  begin
	  A  := '';
	  For i := 0 to pred(fieldsize) do A := hexbyte(ord(DataStr^[i])) + A;
	  If (length(A) > Len) then Delete(A, 1,1);
	  end;

      fldENUM:				{ ^P  }
	If not CheckBlank(DataByte^ = 0) then
	  begin
	  A  := '';
	  Items := PSItem(template);
	  i	:= DataByte^;
	  While (i > 0) do
	    begin
	    Dec(i);
	    If (Items <> nil) then Items := Items^.Next else i := 0;
	    end;
	  If (Items <> nil) and (Items^.Value <> nil) and (Items^.Value^ <> '') then
	    begin
	    Move(Items^.Value^[1], T[1], length(Items^.Value^));
	    end;
	  end;

      fldCLUSTER:			{ 'K' }
	begin
	L := 0;
	If (sizeof(L) > fieldsize) then
	  Move(Data^, L, fieldsize)
	 else
	  Move(Data^, L, sizeof(L));
	If (typecode >= 'a') then  { RadioButton }
	  begin
	  If (L = decimals) then
	    fillchar(A[1], Len, showRadioBtn)
	   else
	    fillchar(A[1], Len, ' ');
	  A[0] := chr(Len);
	  end
	 else
	  begin
	  If odd(L shr decimals) then
	    fillchar(A[1], Len, showCheckBox)
	   else
	    fillchar(A[1], Len, ' ');
	  A[0] := chr(Len);
	  end;
	end;

      end;  { case of C }

    If ItsBlank then
      begin
      fillchar(T[1], length(T), ' ');
      end
     else
      If A <> '' then
	begin
	j  := length(A);
	Q  := (fieldrec^.decimals > 0);
	For i := length(T) downto 1 do
	  begin
	  If Q and (showanyway in Show) and (j <= CurrentCurPos) then Q := FALSE;
	  If (ord(T[i]) and $FE = 0) then
	    begin
	    If j > 0 then
	      begin
	      If Q then If (A[j] = '0') then A[j] := ' ' else Q := FALSE;
	      If (T[i] = #0) or (A[j] > ' ') then
		T[i] := A[j]
	       else
		begin
		T[i] := '0';
		Q := FALSE;
		end;
	      Dec(j);
	      end;
	    end
	   else
	    begin
	    If Q and (T[i] = showDecPt) then
	      begin
	      Q := FALSE;
	      T[i] := ' ';
	      end;
	    If Numbers and (T[i] = ',') then
	      begin
	      If (j <= 0) then T[i] := ' '
	       else
		begin
		If (A[j] in [' ','-']) then
		  begin
		  T[i] := A[j];
		  Dec(j);
		  end;
		end;
	      end;
	    end;
	  end;
	end;
    end;

  CurrentCurPos := 0;
  FieldString := T;

end;  { FieldString() }


  { ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }



End.
