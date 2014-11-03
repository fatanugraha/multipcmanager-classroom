unit unitglobal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, FileUtil, UnitDatabase, IdGlobal, Math, unitdebug;

type
  TIntArr = array of integer;
  TStrArr = array of string;
  PStrArr = ^TStrArr;

function SeekIndex(AnInteger: integer; AnArray: array of integer): integer;
procedure AddElement(var AnArray: TIntArr; Data: integer);
function checkvalidname(anString: string): boolean;
function CheckExt(AnExt: string): boolean;
function MsgBox(Text, Caption: string; Flags: integer): integer;
function AppPath: string;
function FindIndex(IP: string): integer;
function ConvertToBuffer(AString: string; Limit: integer = 8192): TIdBytes;
function ConvertToString(const ABuffer: TIdBytes): string;
function GenerateRandomName(Len: integer): string;
procedure CreateAssignDir(root, Name, desc: string);
function FindRelIndex(IP: string): integer;
function RelToFix(index: integer): integer;
function FixToRel(Index: integer): integer;

const
  allowedchars = ['a'..'z', 'A'..'Z', #13, #8, '0'..'9', '!'..'/', ' '];
 {$IFDEF Windows} DirDelimiter = '\';
{$ELSE} DirDelimiter = '/'; {$ENDIF}

implementation

function SeekIndex(AnInteger: integer; AnArray: array of integer): integer;
var
  i: integer;
begin
  result := -1;
  for i := Low(anArray) to high(AnArray) do
    if anarray[i] = aninteger then
    begin
      result := i;
      break;
    end;
end;

function RelToFix(index: integer): integer;
var
  i, x: integer;
begin
  x := 0;
  for i := 0 to High(RealtimeData) do
  begin
    if RealtimeData[i].ip = 'removed' then begin
      Inc(x);
      continue;
    end;

    if (index + x) = i then
    begin
      Result := i;
      break;
    end;
  end;
end;

function FixToRel(Index: integer): integer;
var
  i, x: integer;
begin
  x := 0;
  for i := 0 to High(RealtimeData) do
  begin
    if RealtimeData[i].ip = 'removed' then begin
      Inc(x);
      continue;
    end;

    if i = index then begin
      result := i-x;
      break;
    end;
  end;
end;

procedure AddElement(var AnArray: TIntArr; Data: integer);
begin
  SetLength(AnArray, Length(AnArray) + 1);
  AnArray[High(anArray)] := Data;
end;

function ExtractStr(AString: string; delimiter: char): TStrArr;
var
  x, Y, Count: integer;
begin
  SetLength(Result, 0);
  Y := 0;
  Count := 1;
  for x := 1 to length(AString) do
    if AString[x] = delimiter then
      Inc(Count);
  SetLength(Result, Count);
  for x := 1 to length(AString) do
    if AString[x] = delimiter then
      Inc(Y)
    else
      Result[Y] := Result[Y] + AString[x];
  if Length(Result) = 0 then
    SetLength(Result, 1);
end;

procedure CreateAssignDir(root, Name, desc: string);
var
  tmp: TstrArr;
  a: TStringList;
  I: integer;
  path: string;
begin
  if not DirectoryExists(root + Name) then
  begin
    tmp := ExtractStr(root + Name, dirdelimiter);
    path := tmp[0] + DirDelimiter;
    for i := 1 to High(tmp) do
    begin
      if not DirectoryExists(path + tmp[i]) then
        mkdir(path + tmp[i]);
      path := path + tmp[i] + DirDelimiter;
    end;
  end
  else
    exit;
  a := TStringList.Create;
  a.Add(Desc);
  a.SaveToFile(path + '[Deskripsi Tugas].txt');
  a.Free;
end;

function checkvalidname(anString: string): boolean;
const
  illegals: array [0..29] of string =
    ('/', '?', '<', '>', DirDelimiter, ':', '*', '|', '”', 'com1,', 'com2,', 'com3,', 'com4,', 'com5,', 'com6,',
    'com7,', 'com8,', 'com9,', 'lpt1,', 'lpt2,', 'lpt3,', 'lpt4,', 'lpt5,', 'lpt6,', 'lpt7',
    'lpt8,', 'lpt9,', 'con,', 'nul,', 'prn');
var
  i: integer;
  tmp: string;
begin
  tmp := lowercase(AnString);
  for i := 0 to High(illegals) do
  begin
    if Pos(tmp, illegals[i]) <> 0 then
    begin
      Result := False;
      exit;
    end;
  end;
  Result := True;
end;

function CheckExt(AnExt: string): boolean;
begin
  Result := (AnExt[1] = '.') and (anExt[Length(anext)] <> '.') and checkvalidname(anext);
end;

function MsgBox(Text, Caption: string; Flags: integer): integer;
begin
  Result := Application.MessageBox(PChar(Text), PChar(Caption), flags);
end;

function ConvertToBuffer(AString: string; Limit: integer = 8192): TIdBytes;
var
  i: integer;
begin
  if Length(AString) > Limit then
    raise Exception.Create('string exceeds limit');
  SetLength(Result, Length(AString));
  for i := 1 to Length(AString) do
  begin
    Result[i - 1] := Ord(AString[i]);
  end;
end;

function ConvertToString(const ABuffer: TIdBytes): string;
var
  i: integer;
begin
  Result := ''; //do not localise
  for i := 0 to High(ABuffer) do
    Result := Result + char(ABuffer[i]);
end;

function AppPath: string;
begin
  Result := ExtractFilePath(Application.Exename);
  if Result[Length(Result)] <> DirDelimiter then
    Result := Result + DirDelimiter;
end;

function GenerateRandomName(Len: integer): string;
const
  A: array [0..25] of integer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24, 25);
  b: array [0..1] of integer = (0, 1);
  d: array [0..9] of integer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
var
  I: integer;
begin
  Result := '';
  for I := 1 to Len do
  begin
    if RandomFrom(b) = RandomFrom(b) then
      Result := Result + char(Ord('0') + RandomFrom(d))
    else
      Result := Result + UpperCase(char(Ord('A') + RandomFrom(A)));
  end;
end;

function FindRelIndex(IP: string): integer;
var
  i, x: integer;
begin
  x := -1;
  Result := -1;
  for i := 0 to High(RealtimeData) do
  begin
    if RealtimeData[i].IP = 'removed' then
      continue;
    Inc(x);

    if RealtimeData[i].IP = IP then
    begin
      Result := x;
      break;
    end;
  end;
end;

function FindIndex(IP: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to High(RealtimeData) do
  begin
    if RealtimeData[i].IP = IP then
    begin
      Result := i;
      break;
    end;
  end;
end;

end.
