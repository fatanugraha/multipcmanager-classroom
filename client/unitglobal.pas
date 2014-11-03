unit unitglobal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, LCLIntf, LCLType, IDGlobal, Forms, ExtCtrls;

type
  TStrArray = array of string;

const
  PortServerGeneral = 59000;    //TCP
  PortServerReporter = 59001;   //TCP
  PortServerBroadcast = 59002;  //TCP
  PortServerIdentifier = 59003; //UDP
  PortClientIdentifier = 59004; //UDP
  PortClientMessaging = 59005;  //TCP

function AppPath: string;
procedure TrayMsg(Title, Msg: string; Flags: TBalloonFlags);
function MsgBox(Text, Caption: string; Flags: integer): integer;
function ConvertToString(const ABuffer: TIdBytes): string;
function ConvertToBuffer(AString: string; Limit: integer = 8192): TIdBytes;
function ExtractStr(AString: string): TStrArray;

implementation

uses
  FormMain;

procedure TrayMsg(Title, Msg: string; Flags: TBalloonFlags);
begin
  with frmMain.Tray do begin
    BalloonFlags:= flags;
    BalloonHint := msg;
    BalloonTitle := Title;
    ShowBalloonHint;
  end;
end;

function AppPath: string;
const
  {$ifdef windows}
  delimiter = '\';
  {$endif}
  {$ifdef linux}
  delimiter = '/';
  {$endif}
begin
  result := ExtractFilePAth(Application.Exename);
  if result[Length(result)] <> delimiter then
    result := result+delimiter;
end;

function MsgBox(Text, Caption: string; Flags: integer): integer;
begin
  result := Application.MessageBox(PChar(text), PCHar(caption), flags);
end;

function ExtractStr(AString: string): TStrArray;
var
  x, Y, Count: integer;
begin
  SetLength(Result, 0);
  Y := 0;
  Count := 1;
  for x := 1 to length(AString) do
    if AString[x] = '|' then
      Inc(Count);
  SetLength(Result, Count);
  for x := 1 to length(AString) do
    if AString[x] = '|' then
      Inc(Y)
    else
      Result[Y] := Result[Y] + AString[x];
  if Length(result) = 0 then
    SetLength(result, 1);
end;

function ConvertToBuffer(AString: string; Limit: integer = 8192): TIdBytes;
var
	i: integer;
begin
	if Length(AString) > Limit then
		raise Exception.Create('string exceeds limit');

	SetLength(Result, Length(AString));
	for i := 1 to Length(AString) do begin
		Result[i-1] := ord(AString[i]);
	end;
end;

function ConvertToString(const ABuffer: TIdBytes): string;
var
	i: integer;
begin
	result := ''; //do not localise
	for i := 0 to High(ABuffer) do
		Result := result + Char(ABuffer[i]);
end;

end.


