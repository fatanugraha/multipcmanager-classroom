unit unitquizDownloader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdTCPClient, FileUtil, unitDebug;

type
  PStringList = ^TStringList;

  TQuizDownloader = class(TThread)
  private
    FCommand, FToken: string;
    FClient: TIdTCPClient;
    FOnError, FOnDone, FOnStart: TThreadMethod;
    PHolder: PStringList;
    FIdx: integer;
  protected
    procedure Execute; override;
  public
    constructor Create(IP: string; Port: word; Command: string; QuizIdx: integer; Token: string; Holder: PStringList);
    destructor Destroy; override;
  public
    property OnDone: TThreadMethod read FOnDone write FOnDone;
    property OnStart: TThreadMethod read FOnStart write FOnStart;
    property OnError: TThreadMethod read FOnError write FOnError;
  end;

implementation

procedure TQuizDownloader.Execute;
var
  fsTmp: TFileStream;
  i, Count: integer;
begin
  Synchronize(FOnStart);
  PHolder^.Clear;
  FreeOnTerminate := True;
  while not terminated do
  begin
    with FClient do
      try
        if not Connected then
          Connect;
        with IOHAndler do
        begin
          WriteLn(FCommand);
          WriteLn(FToken);
          WriteLn(IntToStr(FIdx));
          Count := StrToInt(ReadLn);
          fsTmp := TFileStream.Create(ExpandFileNameUTF8('tmp.quiz'), fmCreate or fmShareExclusive);
          ReadStream(fsTmp, Count, false);
          fsTmp.Free;
        end;
        Disconnect;
        PHolder^.LoadFromFile(ExpandFileNameUTF8('tmp.quiz'));
        DeleteFile(ExpandFileNameUTF8('tmp.quiz'));
      except
        Disconnect;
        Synchronize(FOnError);
      end;
    Terminate;
  end;
  Synchronize(FonDone);
end;

constructor TQuizDownloader.Create(IP: string; Port: word; Command: string; QuizIdx: integer;
  Token: string; Holder: PStringList);
begin
  inherited Create(True);
  FCommand := Command;
  FClient := TIdTCPCLient.Create(nil);
  FClient.Host := IP;
  FClient.Port := Port;
  FIdx := QUizIdx;
  FToken := token;
  PHolder := Holder;
end;

destructor TQuizDownloader.Destroy;
begin
  FClient.Free;
  inherited Destroy;
end;

end.
