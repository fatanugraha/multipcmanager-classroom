unit formupdater;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, unitUpdater, StdCtrls,
  ComCtrls, process, IdComponent;

type

  { TfrmUpdater }

  TfrmUpdater = class(TForm)
    Button1: TButton;
    Header: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    InitDownload: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InitDownloadTimer(Sender: TObject);
  private
    procedure OnErrorVersion;
    procedure OnDoneVersion(const Stream: TStream);
    procedure OnWorkFile(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: int64);
    procedure OnWorkBeginFile(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: int64);
    procedure OnDoneFile(const Stream: TStream);
    procedure OnErrorFile;
  public
    { public declarations }
  end;

const
  urlversion = 'http://download.cybzlab.web.id/multipcmanager/classroom/client.latestversion';
  urlfile = 'http://download.cybzlab.web.id/multipcmanager/classroom/client.exe';

var
  frmUpdater: TfrmUpdater;
  GetRespVersion: TGetResponse;
  GetRespFile: TGetResponse;

implementation

{$R *.lfm}

uses
  FormMain;

{ TfrmUpdater }

procedure TfrmUpdater.FormCreate(Sender: TObject);
begin

end;

procedure TfrmUpdater.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  GetRespVersion.Free;
  if ASsigned(GetRespFile) then
  begin
    GetRespFile.Terminate;
    GetRespFile.Free;
  end;
end;

procedure TfrmUpdater.Button1Click(Sender: TObject);
begin
  Close;
  frmMain.pnlStart.BringToFront;
  InitDownload.Enabled := False;
end;

procedure TfrmUpdater.FormResize(Sender: TObject);
begin
  Label2.Top := ((Height - Header.Height) div 2) - ((Label2.Height + 20 + progressbar1.Height) div 2);
  Progressbar1.top := Label2.Top + Label2.Height + 20;
end;

procedure TfrmUpdater.FormShow(Sender: TObject);
begin
  FormResize(self);
  progressbar1.Width := Width - label1.left * 2;
  Progressbar1.left := label1.left;
  Progressbar1.Visible := True;
  progressbar1.Style := pbstMarquee;
  InitDownload.Enabled := False;
  Label2.Caption := 'Mencari versi terbaru ...';
  GetRespVersion := TGetResponse.Create(urlversion, @OnDoneVersion, @OnErrorVersion);
  getRespVersion.Start;
end;

procedure TfrmUpdater.InitDownloadTimer(Sender: TObject);
begin
  InitDownload.Enabled := False;
  Label2.Caption := 'Mempersiapkan tempat ...';
  try
    if FileExistsUTF8(Application.Exename + '_updatetmp') then
      DeleteFile(Application.Exename + '_updatetmp');
    if FileExistsUTF8(IncludeTrailingBackslash(ExtractFilePath(Application.Exename)) + 'new_version.exe') then
      DeleteFile(IncludeTrailingBackslash(ExtractFilePath(Application.Exename)) + 'new_version.exe');
  except
    Label2.Caption := 'Kesalahan: Tidak dapat membuat berkas temporary.';
    progressbar1.Visible := False;
    exit;
  end;
  Label2.Caption := 'Mengunduh versi terbaru ...';
  progressbar1.style := pbstNormal;
  getRespFile := TGetResponse.Create(UrlFile, @OnDoneFile, @OnErrorFile, Application.Exename + '_updatetmp');
  GEtRespFile.OnWorkBegin := @OnWorkBeginFile;
  GetRespFile.OnWork := @OnWorkFile;
  getRespFile.Start;
end;

procedure TfrmUpdater.OnWorkFile(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: int64);
begin
  ProgressBar1.Position := AWorkCount;
end;

procedure TfrmUpdater.OnWorkBeginFile(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: int64);
begin
  ProgressBar1.Max := AWorkCountMax;
end;

procedure TfrmUpdater.OnDoneFile(const Stream: TStream);
var
  proc: TProcess;
begin
  //extract switcher app from resource
  proc := TProcess.Create(nil);
  proc.CommandLine := IncludeTrailingBackslash(ExtractFilePath(Application.Exename))+'switcher.exe update-die';
  proc.Execute;
  //wait for die
end;

procedure TfrmUpdater.OnErrorFile;
begin
  Label2.Caption := 'Kesalahan: Terdapat kesalahan saat mengunduh versi terbaru. Pastikan anda terhubung dengan internet.';
  progressbar1.Visible := False;
end;

procedure TfrmUpdater.OnErrorVersion;
begin
  Label2.Caption := 'Kesalahan: Terdapat kesalahan saat mencari versi terbaru. Pastikan anda terhubung dengan internet.';
  progressbar1.Visible := False;
end;

procedure TfrmUpdater.OnDoneVersion(const Stream: TStream);
begin
  if TSTringStream(STream).dataString <> FileVersion then
  begin
    InitDownload.Enabled := True;
  end
  else
  begin
    Label2.Caption := 'Anda sedang menggunakan versi terbaru (' + FileVersion + ')';
    Progressbar1.Visible := False;
  end;
end;

end.
