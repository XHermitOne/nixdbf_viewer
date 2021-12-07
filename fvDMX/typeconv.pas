{
Модуль функции конвертации данных.

Версия: 0.0.0.1
}

unit TypeConv;
{$mode objfpc}{$H+}

interface

uses
  SysUtils, SysConst;


{ 2 байта в слово }
function BytesToWord(HiByte: Byte; LoByte: Byte): Word;

{ Взять из слова старший байт }
function WordToHiByte(AWord: Word): Byte;
{ Взять из слова младший байт }
function WordToLoByte(AWord: Word): Byte;

implementation

{ 2 байта в слово }
function BytesToWord(HiByte: Byte; LoByte: Byte): Word;
begin
  Result := Word(HiByte) shl 8 or LoByte;
end;

{ Взять из слова старший байт }
function WordToHiByte(AWord: Word): Byte;
begin
  Result := Byte(AWord shr 8);
end;

{ Взять из слова младший байт }
function WordToLoByte(AWord: Word): Byte;
begin
  Result := Byte(AWord and $00FF);
end;

end.
