unit unitdebug;

{$mode objfpc}{$H+}

interface

uses
  dialogs, sysutils, classes;

procedure log(a: string);
procedure dbg;
procedure dbg(a: TStringList);
procedure dbg(a: array of string);
procedure dbg(a: integer);
procedure dbg(a: string);
procedure dbg(a: boolean);

implementation

uses
  unitglobal;

procedure dbg(a: boolean);
begin
  showmessage(booltostr(a,true));
end;

procedure dbg;
begin
  dbg('here.');
end;

procedure log(a: string);
var
  ab: TSTringList;
begin
  ab := TStringList.create;
  if fileexists(apppath+'log.txt') then
    ab.loadfromfile(apppath+'log.txt');
  ab.add(a);
  ab.SaveToFile(apppath+'log.txt');
  ab.free;
end;

procedure dbg(a: array of string);
var
  i: integer;
  str: string;
begin
  str := '';
  for i := low(a) to high(a) do
    str := str+'['+inttostr(i)+'] = '+a[i]+';'+#13#10;
  showmessage(str);
end;

procedure dbg(a: TStringList);
var
  i: integer;
  str: string;
begin
  str := '';
  for i := 0 to a.count-1 do
    str := str+'['+inttostr(i)+'] = '+a[i]+';'+#13#10;
  showmessage(str);
end;

procedure dbg(a: integer);
begin
  showmessage(inttostr(a));
end;

procedure dbg(a: string);
begin
  showmessage(a);
end;

end.

