unit unitsendmessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdTCPClient;

type
  TMessageSender = class(TObject)
  private
    FClient: TIdTCPClient;
    FCommand: string;
  public
    constructor Create(Host: string; Port: word; Command: string);
    function SendMessage(AMessage: string): boolean; overload;
    function SendMessage(Host, AMessage: string): boolean; overload;
    destructor Destroy; override;
  end;

implementation

constructor TMessageSender.Create(Host: string; Port: word; Command: string);
begin
  inherited Create;
  FClient := TIdTCPClient.Create;
  FClient.Host := Host;
  FClient.Port := Port;
  FCommand := Command;
end;

function TMessageSender.SendMessage(AMessage: string): boolean;
begin
  try
    if not FClient.Connected then
      FClient.Connect;
    with FClient.IOHandler do begin
      WriteLn(FCommand);
      Writeln(AMessage);
    end;
    FClient.Disconnect;
    result := true;
  except
    FClient.Disconnect;
    result := false;
  end;
end;

function TMessageSender.SendMessage(Host, AMessage: string): boolean;
begin
  try
    if FClient.Connected then
      FClient.Disconnect;
    FClient.Host := host;
    FClient.Connect;
    with FClient.IOHandler do begin
      WriteLn(FCommand);
      Writeln(AMessage);
    end;
    FClient.Disconnect;
    result := true;
  except
    FClient.Disconnect;
    result := false;
  end;
end;

destructor TMessageSender.Destroy;
begin
  FClient.Free;
  inherited;
end;

end.

