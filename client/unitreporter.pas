unit unitReporter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdTCPClient, unitdebug, Graphics, LCLType, LCLIntf, unitDatabase, Forms, stdctrls, process, unitThreadSync;

type
  PQuizDB = ^TQuizDB;
  PAssignDB = ^TAssignDB;
  PVoteDB = ^TVoteDB;
  PThreadMethod = ^TThreadMethod;
  Plabel = ^TLabel;

  TReporter = class(TThread)
  private
    FVoteUpd, FAssignUpd, FQuizUpd: TThreadMethod;
    FClient: TIdTCPClient;
    FInterval: integer;
    FStream: TMemoryStream;
    Sync: TSync;
    PQuizInfo: PQuizDB;
    FToken: string;
    FServerIP: string;
    FServerPort: word;
    PAssignInfo: PAssignDB;
    PVoteInfo: PVoteDB;
    FNotify: TThreadMethod;
    FOnBroadCastChange, FOnLockscreenChange: TTHreadMethod;
    FAnyBroadcast, FLockScreen: PBoolean;
    FIPBroadcast: PString;
    FLabel: PLabel;
    procedure ShowDcStatus;
    procedure ShowNormalStatus;
    procedure ShowExpiredSession;
  private
    SetQuizDataIndex: integer;
    SetQuizDataName: string;
    SetQuizDataDesc: string;
    SetQuizDataDur: int64;
    procedure SetQuizData;
  private
    SetArrayLengthParam: array [0..1] of integer; //[0] = 0=quiz; 1=assign [1] =array length
    procedure SetArrayLength;
  private
    SetAssignDataName: string;
    SetAssignDataDesc: string;
    SetAssignDataExt: string;
    SetAssignDataIndex: integer;
    SetAssignDataSize: int64;
    procedure SetAssignData;
  private
    SetVoteDataTitle: string;
    SetVoteDataDesc: string;
    SetVoteDataOption: array of string;
    SetVoteDataIndex: integer;
    SetVoteChoice: int64;
    procedure SetVoteData;
  protected
    procedure Execute; override;
  public
    // ALL PROPERTY MUST BE ASSGINED.
    property VoteDB: PVoteDB read PVoteInfo write PVoteInfo;
    property QuizDB: PQuizDB read PQuizInfo write PQuizInfo;
    property AssignDB: PAssignDB read PAssignInfo write PAssignInfo;
    property Token: string read FToken write FToken;
    property Notifier: TThreadMethod read FNotify write FNotify;
    property UpdateQuiz: TThreadMethod read FQuizUpd write FQuizUpd;
    property UpdateAssign: TThreadMethod read FAssignUpd write FAssignUpd;
    property UpdateVote: TThreadMethod read FVoteUpd write FVoteUpd;
    property BroadcastStatus: PBoolean read FAnyBroadcast write FanyBroadcast;
    property Lockscreen: PBoolean read FLockScreen write FLockScreen;
    property BroadcastSvIP: PString read FIPBroadcast write FIPBroadcast;
    property OnBroadcastChange: TThreadMethod write FOnBroadcastChange;
    property OnLockScreenChange: TThreadMethod write FOnLockScreenChange;
    property StatusLabel: PLabel write FLabel;
  public
    constructor Create(ServerIP: string; Port: word; interval: integer);
    destructor Destroy; override;
  end;

implementation

uses unitglobal;

procedure TReporter.ShowDcStatus;
begin
  FLabel^.Caption := 'terputus dari server.'
end;

procedure TReporter.ShowNormalStatus;
begin
  FLabel^.caption := '';
end;

procedure TReporter.SetAssignData;
begin
  PAssignInfo^[SetAssignDataIndex].Name := SetAssignDataName;
  PAssignInfo^[SetAssignDataIndex].Description := SetAssignDataDesc;
  PAssignInfo^[SetAssignDataIndex].FileExt := SetAssignDataExt;
  PAssignInfo^[SetAssignDataIndex].SizeLimit := SetAssignDataSize;
  FAssignUpd;
end;

procedure TReporter.SetQuizData;
begin
  PQuizInfo^[SetQuizDataIndex].Name := SetQuizDataName;
  PQuizInfo^[SetQuizDataIndex].Description := SetQuizDataDesc;
  PQuizInfo^[SetQuizDataIndex].Duration := SetQuizDataDur;
  FQuizUpd;
end;

procedure TReporter.SetArrayLength;
begin
  case SetArrayLengthParam[0] of
    0: SetLength(PQuizInfo^, SetArrayLengthParam[1]);
    1: SetLength(PAssignInfo^, SetArrayLengthParam[1]);
    2: SetLength(PVoteInfo^, SetArrayLengthParam[1]);
  end;
end;

procedure TReporter.ShowExpiredSession;
var
  aProcess:Tprocess;
begin
  MsgBox('Sesi telah kadaluarsa. Silahkan buka ulang MultiPC Manager 2.0 Classroom Client',
    'Sesi Kadaluarsa', MB_ICONEXCLAMATION);
  aProcess := TProcess.Create(nil);
  aProcess.CommandLine := Application.ExeName;
  aProcess.Execute;
  aProcess.Free;
  Application.Terminate;
end;

procedure TReporter.SetVoteData;
var
  i: integer;
begin
  PVoteInfo^[SetVoteDataIndex].Title := SetVoteDataTitle;
  PVoteInfo^[SetVoteDataIndex].Desc := SetVoteDataDesc;
  PVoteInfo^[SetVoteDataIndex].choice := SetVoteChoice;
  SetLength(PVoteInfo^[SetVoteDataIndex].options, Length(SetVoteDataOption));
  for i := 0 to High(SetVoteDataOption) do
    PVoteInfo^[SetVoteDataIndex].options[i] := SetVoteDataOption[i];
end;

procedure TReporter.Execute;
var
  strtmp: string;
  tmp, i, j: integer;
  NewWorks: boolean;
begin
  sleep(2000);
  while not terminated do
  begin
    with FClient do
      try
        if not Connected then
          Connect;
        with IOHandler do
        begin
          //AUTHENTICATION
          WriteLn(FToken);
          if (ReadLn = 'Denied') then
          begin
            Synchronize(@ShowExpiredSession);
          end;

          //SEND SCREENSHOT TO SERVER
          sync.Synchronize;
          WriteLn('Screenshot');
          WriteLn(IntToStr(FStream.Size));
          Write(FStream);
          NewWorks := False;

          //SYNCHRONISING ASSIGNMENT DATA
          WriteLn(IntToStr(Length(PAssignInfo^)));
          if ReadLn = 'False' then
          begin
            NewWorks := True;
            tmp := StrToInt(ReadLn);
            SetArrayLengthParam[0] := 1;
            SetArrayLengthParam[1] := tmp;
            Synchronize(@SetArrayLength);
            for i := 0 to tmp - 1 do
            begin
              SetAssignDataIndex := i;
              SetAssignDataName := readln;
              SetAssignDataDesc := readln;
              SetAssignDataExt := readln;
              SetAssignDataSize := StrToInt(ReadLn);
              Synchronize(@SetAssignData);
            end;
          end;

          //SYNCHRONISING QUIZ DATA
          WriteLn(IntToStr(Length(PQuizInfo^)));
          if ReadLn = 'False' then
          begin
            NewWorks := True;
            tmp := StrToInt(ReadLn);
            SetArrayLengthParam[0] := 0;
            SetArrayLengthParam[1] := tmp;
            Synchronize(@SetArrayLength);
            for i := 0 to tmp - 1 do
            begin
              SetQuizDataIndex := i;
              SetQuizDataName := ReadLn;
              SetQuizDataDesc := ReadLn;
              SetQuizDataDur := StrToInt(ReadLn);
              Synchronize(@SetQuizData);
            end;
          end;

          //GET VOTE DATA
          WriteLn(IntToStr(Length(PVoteInfo^)));
          if readln = 'False' then
          begin
            tmp := StrToInt(ReadLn);
            SetArrayLengthParam[0] := 2;
            SetArrayLengthParam[1] := tmp;
            Synchronize(@SetArrayLength);
            for i := 0 to tmp - 1 do
            begin
              SetVoteDataIndex := i;
              SetVoteDataTitle := Readln;
              SetVoteDataDesc := Readln;
              SetVoteChoice := StrToInt(ReadLn);
              j := StrToInt(ReadLn);
              SetLength(SetVoteDataOption, j);
              for j := 0 to high(SetVoteDataOption) do
                SetVoteDataOption[j] := Readln;
              Synchronize(@SetVoteData);
            end;
            Synchronize(FVoteUpd);
          end;

          //GET LOCKSCREEN INFO
          strtmp := readln;
          FLockScreen^ := strtmp = 'True';
          Synchronize(FOnLockScreenChange);
        end;

        if IOHandler.ReadLn = 'Disconnect' then
          Disconnect(False);

        if NewWorks then
          Synchronize(FNotify);

        Synchronize(@ShowNormalStatus);
      except
        on e: Exception do
        begin
          //dbg(e.message);
          Synchronize(@ShowDCStatus);
          Disconnect;
        end;
      end;
    sleep(FInterval * 1000);
  end;
end;

constructor TReporter.Create(ServerIP: string; Port: word; interval: integer);
begin
  inherited Create(True);
  FClient := TIdTCPClient.Create;
  FClient.Host := ServerIp;
  FClient.Port := Port;
  FServerIP := ServerIP;
  FServerPort := Port;
  FInterval := Interval;
  FStream := TMemoryStream.Create;
  CreateSync(Sync, 'capture', 0, 1);
  sync.procparamsAux[0] := @FStream;
end;

destructor TReporter.Destroy;
begin
  inherited;
  FStream.Free;
  FClient.Free;
  DestroySync(Sync);
end;


end.