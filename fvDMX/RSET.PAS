
{=======================================================}
{							}
{	RSET	--General data types and constants	}
{							}
{	Copyright (c) 1992  Randolph Beck		}
{			    P.O. Box  56-0487		}
{			    Orlando, FL 32856		}
{			    CIS:  72361,753		}
{							}
{=======================================================}

Unit RSet;

interface

type
    TREALNUM  =  Real;
    PREALNUM	= ^TREALNUM;

    { Using TREALNUM for floating point numbers makes it easy
      to change from REAL to DOUBLE or other real number type. }


    PBoolean	= ^Boolean;
    PByte	= ^Byte;
    PShortInt	= ^Shortint;
    PInteger	= ^Integer;
    PWord	= ^Word;
    PLongInt	= ^LongInt;
    PReal	= ^Real;

    PCharArray	= ^TCharArray;
    TCharArray	=  array[0..32767] of char;


const
    FirstCmdNum	=  4400;  { starting number for reserved commands }
    FirstRegNum	=  4400;  { starting number for registered objects }


    { Day and Month constants }
    Sunday	=   0;
    Monday	=   1;
    Tuesday	=   2;
    Wednesday	=   3;
    Thursday	=   4;
    Friday	=   5;
    Saturday	=   6;

    January	=   1;
    February	=   2;
    March	=   3;
    April	=   4;
    May		=   5;
    June	=   6;
    July	=   7;
    August	=   8;
    September	=   9;
    October	=  10;
    November	=  11;
    December	=  12;


    { file-open mode constants for TDosStreams }
    stDenyAll	= $10;
    stDenyWrite	= $20;
    stDenyRead	= $30;
    stDenyNone	= $40;


    { KeyCode constants }
    kbCtrlA	= $1E01;
    kbCtrlB	= $3002;
    kbCtrlC	= $2E03;
    kbCtrlD	= $2004;
    kbCtrlE	= $1205;
    kbCtrlF	= $2106;
    kbCtrlG	= $2207;
    kbCtrlH	= $2308;
    kbCtrlI	= $1709;
    kbCtrlJ	= $240A;
    kbCtrlK	= $250B;
    kbCtrlL	= $260C;
    kbCtrlM	= $320D;
    kbCtrlN	= $310E;
    kbCtrlO	= $180F;
    kbCtrlP	= $1910;
    kbCtrlQ	= $1011;
    kbCtrlR	= $1312;
    kbCtrlS	= $1F13;
    kbCtrlT	= $1414;
    kbCtrlU	= $1615;
    kbCtrlV	= $2F16;
    kbCtrlW	= $1117;
    kbCtrlX	= $2D18;
    kbCtrlY	= $1519;
    kbCtrlZ	= $2C1A;
    kbShiftEnter= $1C0D;


implementation


End.
