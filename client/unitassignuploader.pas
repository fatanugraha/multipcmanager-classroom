unit unitassignuploader;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef unix} cthreads, cmem, {$endif}
  Classes, SysUtils, IdTCPClient, LCLTYPE;

type
  TUploader = class(TThread)
  private
    FClient: TIdTCPCLient;
    FFileName, FCommand: string;
    FStream: TFileStream;
    FOnError: TThreadMethod;
    FOnDone: TThreadMethod;
  protected
    procedure Execute; override;
  public
    constructor Create(FileName, Host: string; Port: Word; Command: string; onError, onDone: TThreadMethod);
    destructor Destroy; override;
  end;

implementation

procedure TUploader.Execute;
begin
  FreeOnTerminate := true;
  while not Terminated do begin
    try
      FClient.Connect;
      FClient.IOHandler.WriteLn(FCommand);
      FClient.IOHandler.WriteLn(IntToStr(FStream.Size));
      FClient.IOHandler.Write(FStream);
      Fclient.Disconnect;
      Synchronize(FOnDone);
    except
      Synchronize(FonError);
      FClient.Disconnect;
    end;
    Terminate;
  end;
end;

constructor TUploader.Create(FileName, Host: string; Port: word; Command: string; onError, onDone: TThreadMethod);
begin
  inherited Create(True);
  FOnError := OnError;
  FOnDone := OnDone;
  FClient := TIdTCPClient.Create;
  FClient.Host := Host;
  FClient.Port := Port;
  FCommand := COmmand;
  FFileName := FileName;
  FStream := TFileStream.Create(FFileName, fmopenRead or fmShareExclusive);
  Start;
end;

destructor TUploader.Destroy;
begin
  inherited Destroy;
  FClient.Free;
  FStream.Free;
end;

end.

