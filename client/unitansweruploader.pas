unit unitansweruploader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, unitQuizFile, unitQuizPreview, IdTCPClient;

type
  TAnswerUploader = class(TThread)
  private
    FCommand, FToken: string;
    FIdx: integer;
    FClient: TIdTCPClient;
    FOnError, FOnDone, FOnStart: TThreadMethod;
    FAnswers: TQuizAnswers;
  protected
    procedure Execute; override;
  public
    constructor Create(IP: string; Port: word; Command: string; const Answers: TQuizAnswers;
      Idx: integer; Token: string);
    destructor Destroy; override;
  public
    property OnDone: TThreadMethod read FOnDone write FOnDone;
    property OnStart: TThreadMethod read FOnStart write FOnStart;
    property OnError: TThreadMethod read FOnError write FOnError;
  end;

implementation

constructor TAnswerUploader.Create(IP: string; Port: word; Command: string; const Answers: TQuizAnswers;
  Idx: integer; Token: string);
begin
  inherited Create(True);
  FCommand := Command;
  FClient := TIdTCPCLient.Create(nil);
  FClient.Host := IP;
  FClient.Port := Port;
  FIdx := Idx;
  FAnswers := Answers;
  FToken := token;
end;

destructor TAnswerUploader.Destroy;
begin
  inherited Destroy;
  FClient.Free;
end;

procedure TAnswerUploader.Execute;
function RemoveLB(const astring:string): string;
var
  i: integer;
begin
  for i := 1 to length(Astring) do
    if (Astring[i] = char(10)) or (Astring[i] = char(13)) then
      result := result+char(ord(Astring[i])+1)
    else
      result := result+Astring[i];
end;

var
  i: integer;
begin
  FreeOnTerminate := True;
  Synchronize(FOnStart);
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

          WriteLn(IntToStr(Length(FAnswers.Choices)));
          for i := 0 to High(FAnswers.Choices) do
            WriteLn(IntToStr(FAnswers.Choices[i]));

          WriteLn(IntToStr(Length(FAnswers.Essays)));
          for i := 0 to High(FAnswers.Essays) do
            WriteLn(RemoveLB(FAnswers.Essays[i]));

        end;
        Disconnect;
      except
        Disconnect;
        Synchronize(FOnError);
        //TODO: LOGGING
      end;
    Synchronize(FonDone);
    Terminate;
  end;
end;

end.
