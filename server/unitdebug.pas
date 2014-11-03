unit unitdebug;

{$mode objfpc}{$H+}

interface

uses
  Dialogs, SysUtils, Classes;

const
  debug_build = True;

procedure dbg;
procedure dbg(a: TStringList);
procedure dbg(a: array of string);
procedure dbg(a: array of integer);
procedure dbg(a: integer);
procedure dbg(a: string);
procedure dbg(a: boolean);
procedure dbg(a: extended);

implementation

uses
  unitglobal;

procedure dbg(a: extended);
begin
  if debug_build then
    dbg(floattostr(a));
end;

procedure dbg;
begin
  if debug_build then
    dbg('here.');
end;

procedure dbg(a: boolean);
begin
  if debug_build then
    ShowMessage(booltostr(a, True));
end;

procedure dbg(a: array of string);
var
  i: integer;
  str: string;
begin
  if debug_build then
  begin
    str := '';
    for i := low(a) to high(a) do
      str := str + '[' + IntToStr(i) + '] = ' + a[i] + ';' + #13#10;
    ShowMessage(str);
  end;
end;

procedure dbg(a: TStringList);
var
  i: integer;
  str: string;
begin
  if debug_build then
  begin
    str := '';
    for i := 0 to a.Count - 1 do
      str := str + '[' + IntToStr(i) + '] = ' + a[i] + ';' + #13#10;
    ShowMessage(str);
  end;
end;

procedure dbg(a: array of integer);
var
  i: integer;
  str: string;
begin
  if debug_build then
  begin
    str := '';
    for i := low(a) to high(a) do
      str := str + '[' + IntToStr(i) + '] = ' + IntToStr(a[i]) + ';' + #13#10;
    ShowMessage(str);
  end;
end;

procedure dbg(a: integer);
begin
  if debug_build then
    ShowMessage(IntToStr(a));
end;

procedure dbg(a: string);
begin
  if debug_build then
    ShowMessage(a);
end;

end.
