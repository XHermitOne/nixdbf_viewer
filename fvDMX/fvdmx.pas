{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit fvDMX;

{$warn 5023 off : no warning about unused units}
interface

uses
  DMXFORMS, DMXGIZMA, RSET, STDDMX, TVDMX, TVDMXBUF, TVDMXCOL, TVDMXHEX, 
  TVDMXREP, TVGIZMA, Avail, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('fvDMX', @Register);
end.
