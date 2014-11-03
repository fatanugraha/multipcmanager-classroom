unit formMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, UniqueInstance, Forms, Controls, Graphics, Dialogs, ExtCtrls, unitReporter, IdSync, StdCtrls,
  ComCtrls, IdTCPClient, IdGlobal, unitdebug, IdContext, IdTCPServer, LCL, LCLIntf, LCLType, Menus, unitDatabase, unitSendMessage,
  process, unitASsignUploader, unitQuizDownloader, unitAnswerUploader, lresources, unitlanguage;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnAssignDetail: TButton;
    btnQuizDetail: TButton;
    btnQuizStart: TButton;
    imgUpdate: TImage;
    imgAbout: TImage;
    imgStopSession: TImage;
    btnDoAssignment: TButton;
    btnDoQuiz: TButton;
    Footer: TPanel;
    Header1: TPanel;
    lblUpdate: TLabel;
    lblAbout: TLabel;
    lblConnectionStatus: TLabel;
    MenuItem1: TMenuItem;
    MessageListener: TIdTCPServer;
    imgStatus: TImage;
    imgMessaging: TImage;
    imgWorks: TImage;
    imgMainLogo: TImage;
    imgPreferences: TImage;
    imgStartClass: TImage;
    lblStatus: TLabel;
    lblMessaging: TLabel;
    lblWorks: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblAssignmentStatus: TLabel;
    lblClassID: TLabel;
    lblStopSession: TLabel;
    lblPreferences: TLabel;
    lblQuizStatus: TLabel;
    lblSessionName: TLabel;
    lblStartClass: TLabel;
    lblTeacherName: TLabel;
    lvAssignment: TListView;
    lvQuiz: TListView;
    mmChatLog: TMemo;
    mmChatSend: TMemo;
    lblNew: TLabel;
    OpenDlg: TOpenDialog;
    pnlUpdate: TPanel;
    pnlAbout: TPanel;
    pnlQuizDownloadWait: TPanel;
    pnlScan: TPanel;
    pnlMain: TPanel;
    pnlAssignment: TPanel;
    pnlMessage: TPanel;
    pnlStart: TPanel;
    pnlStatus: TPanel;
    pnlWait: TPanel;
    lblSelected: TLabel;
    pnlUploadWait: TPanel;
    PopupMenu1: TPopupMenu;
    Tray: TTrayIcon;
    UniqueInstance1: TUniqueInstance;
    procedure btnAssignDetailClick(Sender: TObject);
    procedure btnDoAssignmentClick(Sender: TObject);
    procedure btnDoQuizClick(Sender: TObject);
    procedure btnQuizDetailClick(Sender: TObject);
    procedure btnQuizStartClick(Sender: TObject);
    procedure FooterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgAboutClick(Sender: TObject);
    procedure imgMessagingClick(Sender: TObject);
    procedure imgStopSessionClick(Sender: TObject);
    procedure imgWorksClick(Sender: TObject);
    procedure imgPreferencesClick(Sender: TObject);
    procedure imgStartClassClick(Sender: TObject);
    procedure lblStatusClick(Sender: TObject);
    procedure lblUpdateClick(Sender: TObject);
    procedure lvAssignmentClick(Sender: TObject);
    procedure lvQuizClick(Sender: TObject);
    procedure lvQuizSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure MessageListenerExecute(AContext: TIdContext);
    procedure mmChatLogChange(Sender: TObject);
    procedure mmChatSendEnter(Sender: TObject);
    procedure mmChatSendExit(Sender: TObject);
    procedure mmChatSendKeyPress(Sender: TObject; var Key: char);
    procedure pnlQuizDownloadWaitClick(Sender: TObject);
    procedure pnlQuizDownloadWaitResize(Sender: TObject);
    procedure TrayClick(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject; ParamCount: integer; Parameters: array of string);
    procedure UpdateAssignList;
    procedure UpdateQuizList;
  private
    //SESSION DATA
    Password, SessionName, ClassId, TeacherName: string;
    MsgHistory: TStringList;

    //BACKGROUND SERVICES
    Reporter: TReporter;
    MessageSender: TMessageSender;
    QuizDownloader: TQuizDownloader;
    AnswerUploader: TAnswerUploader;

    //AUXILIARY VARIABLES
    UploadedAssignIdx: integer;

    procedure ReArrange;
    procedure StopSession;

    procedure StartQuizDownload;
    procedure DoneQuizDownload;
    procedure ErrorQuizDownload;

    procedure StartAnswerUpload;
    procedure DoneAnswerUpload;
    procedure ErrorAnswerUpload;

    procedure OnLockScreenStatusChange;
    procedure ShowAssignmentCover(QuizCount, AssignCount: integer);
  public
    //SESSION DATA
    Language: integer;
    SessionToken: string;
    ServerIP: string;
    UserName: string;
    QuizInfo: TQuizDB;
    VoteInfo: TVoteDB;
    QuizDone: integer;
    AssignInfo: TAssignDB;
    AssignDone: integer;
    FileUploader: TUploader;
    LockScreen: boolean;
    AnyBroadcast: boolean;
    IPBroadcast: boolean;

    //AUXILIARY VARIABLES
    NewMessage: boolean;
    CurrentQuizRaw: TStringList;

    procedure DoVote;
    procedure NotifyNewAssignment;
    procedure AfterQuizDone;
    procedure UploadingDone;
    procedure UploadingError;
    procedure ShowUploadingForm;
    procedure HideUploadingForm;
    procedure StartSession(ASessionName, ATeacherName, AClassID, AServerIP, AToken, APassword: string);
  end;

var
  frmMain: TfrmMain;

const
  FileVersion = '2.0 Build 2'; // make sure we update this string when releasing new version

implementation

{$R *.lfm}

uses
  UnitGlobal, unitthreadsync, FormPreferences, formScanNetwork, formWorksDetail, formQuizviewer, formABout, FormUpdater,
  formLockScreen, FormVote;

procedure TFrmMain.ShowAssignmentCover(QuizCount, AssignCount: integer);
begin
  lvAssignment.Visible := not (AssignCount = 0);
  lvQuiz.Visible := not (QuizCount = 0);

  btnAssignDetail.Visible := lvAssignment.Visible;
  btnDoAssignment.Visible := lvAssignment.Visible;
  btnQuizDetail.Visible := lvQuiz.Visible;
  btnDoQuiz.Visible := lvQuiz.Visible;

  if LvAssignment.Visible and lvQuiz.Visible then
  begin
    //margintop = 16; left=13
    lvAssignment.Top := 16;
    lvAssignment.Height:= (pnlAssignment.Height - 3 * 13) div 2;;
    lvQuiz.top := lvAssignment.Top + lvAssignment.Height + 13;
    lvQuiz.Height := (pnlAssignment.Height - 3 * 13) div 2;
  end
  else if lvAssignment.Visible then
  begin
    lvAssignment.Top := 16;
    lvAssignment.Height := pnlASsignment.Height - 32;
  end
  else
  begin
    lvQuiz.Top := 16;
    lvQuiz.Height := pnlASsignment.Height - 32;
  end;

  btnAssignDetail.top := lvAssignment.Top + lvAssignment.Height - btnAssignDetail.Height;
  btnAssignDetail.Left := 13;
  btnAssignDetail.SendToBack;
  btnDoAssignment.top := lvAssignment.Top + lvAssignment.Height - btnDoAssignment.Height;
  btnDoAssignment.Left := pnlAssignment.Width - 13 - btnDoAssignment.Width;
  btnDoAssignment.SendToBack;

  btnQuizDetail.top := lvQuiz.Top + lvQuiz.Height - btnQuizDetail.Height;
  btnQuizDetail.Left := 13;
  btnQuizDetail.SendToBack;
  btnDoQuiz.Top := lvQuiz.Top + lvQuiz.Height - btnDoQuiz.Height;
  btnDoQuiz.Left := pnlAssignment.Width - 13 - btnDoQuiz.Width;
  btnDoQuiz.SendToBack;

  with pnlAssignment do
  begin
    if (not lvQuiz.Visible) and (not lvQuiz.Visible) then
    begin
      FOnt.Color := clWhite;
      Font.Size := 14;
      Caption := 'Tidak ada tugas yang harus dikerjakan.';
    end
    else
    begin
      FOnt.Color := clDefault;
      Font.Size := 0;
      Caption := '';
    end;
  end;
end;

procedure TFrmMain.OnLockScreenStatusChange;
begin
  if LockScreen <> frmLockScreen.state then
    if LockScreen then
      frmLockScreen.Lock('Harap perhatikan pengajar.')
    else
      frmLockScreen.Unlock;
end;

procedure TfrmMain.DoVote;
var
  i: integer;
begin
  if frmVote.progress then
    exit;
  for i := 0 to High(Voteinfo) do
  begin
    if VoteInfo[i].choice = -1 then
    begin
      frmVote.Position := poDesktopCenter;
      frmVote.Parent := nil;
      frmVote.ShowInTaskBar := stAlways;
      frmVote.Show;
      break;
    end;
  end;
end;

procedure TfrmMain.AfterQuizDone;
var
  idx: integer;
begin
  idx := StrToInt(lvQuiz.Items[lvQuiz.ItemIndex].Caption) - 1;
  AnswerUploader := TAnswerUploader.Create(ServerIp, 59000, 'QuizAnswers', Answers, idx, SessionToken);
  AnswerUploader.OnDone := @DoneAnswerUpload;
  AnswerUploader.OnStart := @StartAnswerUpload;
  AnswerUploader.OnError := @ErrorAnswerUpload;
  AnswerUploader.Start;
end;

procedure TfrmMain.StartAnswerUpload;
begin
  with pnlQuizDownloadWait do
  begin
    btnQuizStart.Visible := False;
    Caption := 'Mengirim jawaban kuis ...';
    Align := AlClient;
    BringToFront;
    Font.Size := 12;
    Font.Color := clWhite;
    Visible := True;
  end;
  update;
end;

procedure TfrmMain.ErrorAnswerUpload;
begin
  with pnlQuizDownloadWait do
  begin
    btnQuizStart.Caption := 'Coba Lagi';
    btnQuizStart.Visible := True;
    Caption := 'Terdapat kesalahan saat mengirim jawab kuis. Pastikan sambungan anda.';
    Align := AlClient;
    BringToFront;
    Font.Size := 12;
    Font.Color := clWhite;
  end;
  update;
end;

procedure TfrmMain.DoneAnswerUpload;
begin
  with pnlQuizDownloadWait do
  begin
    btnQuizStart.Caption := 'Tutup';
    btnQuizStart.Visible := True;
    Caption := 'Jawaban quiz telah dikumpulkan.';
    Align := AlClient;
    BringToFront;
    Font.Size := 12;
    Font.Color := clWhite;
  end;
  update;
  QuizInfo[StrToInt(lvQuiz.Items[lvQuiz.ItemIndex].Caption) - 1].done := True;
  ImgWorksClick(imgWorks);
  Inc(QuizDone);
  NotifyNewAssignment;
  CurrentQuizRAw.Clear;
end;

procedure TfrmMain.StartSession(ASessionName, ATeacherName, AClassID, AServerIP, AToken, APassword: string);
begin
  //SHOW WAIT COVER
  pnlWait.Caption := 'Mempersiapkan sesi ...';
  pnlWait.BringToFront;
  pnlWait.Visible := True;
  update;

  //INITIALISING VARIABLES
  SessionName := ASessionName;
  TeacherName := ATeacherName;
  ClassID := AClassID;
  ServerIP := AServerIP;
  SessionToken := AToken;
  Password := APassword;
  MsgHistory := TStringList.Create;
  NewMessage := False;

  //UPDATING USER INTERFACES
  lblClassId.Caption := ': ' + ClassID;
  lblTeacherName.Caption := ': ' + TeacherName;
  lblSessionName.Caption := ': ' + SessionName;
  lblQuizStatus.Caption := 'Anda memiliki ' + IntToStr(Length(QuizInfo) - QuizDone) + ' quiz untuk dikerjakan.';
  lblAssignmentStatus.Caption := 'Anda memiliki ' + IntToStr(Length(AssignInfo) - AssignDone) +
    ' pekerjaan untuk dikumpulkan.';
  lblStatusClick(nil);

  //INITIALISING SERVERS AND BACKGROUND SERVICES
  LockScreen := False;
  MessageListener.Active := True;
  MessageSender := TMessageSender.Create(ServerIP, PortServerGeneral, 'Message');
  Reporter := TReporter.Create(ServerIP, PortServerReporter, 5);
  with Reporter do
  begin
    QuizDb := @QuizInfo;
    AssignDb := @AssignInfo;
    Token := SessionToken;
    Notifier := @NotifyNewAssignment;
    UpdateQuiz := @UpdateQuizList;
    updateAssign := @UpdateAssignList;
    BroadCastStatus := @AnyBroadcast;
    LockScreen := @frmMain.LockScreen;
    OnLockScreenChange := @OnLockScreenStatusChange;
    VoteDB := @VoteInfo;
    UpdateVote := @doVote;
    StatusLabel := @lblConnectionStatus;
    start;
  end;

  //HIDE WAIT COVER
  pnlWait.Visible := False;

  //SHOW TRAY ICON
  Tray.Visible := True;
end;

procedure TfrmMain.ShowUploadingForm;
begin
  pnlUploadWait := TPanel.Create(pnlAssignment);
  pnlUploadWait.Name := 'pnlUploadWait';
  pnlWait.parent := pnlAssignment;
  pnlWait.Align := alClient;
  pnlWait.BevelOuter := bvNone;
  pnlWait.Font.Color := clwhite;
  pnlWait.Font.Size := 10;
  pnlWait.Caption := 'Menunggah berkas ...';
  pnlWait.BringToFront;
  update;
end;

procedure TfrmMain.HideUploadingForm;
begin
  pnlUploadWait.Free;
end;

procedure Tfrmmain.NotifyNewAssignment;
begin
  lblQuizStatus.Caption := 'Anda memiliki ' + IntToStr(Length(QuizInfo) - QuizDOne) + ' quiz untuk dikerjakan.';
  lblAssignmentStatus.Caption := 'Anda memiliki ' + IntToStr(Length(AssignInfo) - AssignDone) +
    ' pekerjaan untuk dikumpulkan.';
  TrayClick(nil);
end;

procedure TfrmMain.StopSession;
begin
  //DEINITIALISING SERVERS AND BACKGROUND SERVICES
  MessageListener.Active := False;
  MessageSender.Free;
  Reporter.Free;

  //DEINITIALISING VARIABLES
  SessionName := '';
  TeacherName := '';
  ClassID := '';
  ServerIP := '';
  SessionToken := '';
  Password := '';
  MsgHistory.Free;
  SetLength(QuizInfo, 0);
  SetLength(AssignInfo, 0);

  //SHOW SPLASH PAGE
  pnlStart.BringToFront;

  //HIDE TRAY ICON
  Tray.Visible := False;
end;

procedure TfrmMain.imgMessagingClick(Sender: TObject);
begin
  pnlMessage.BringToFront;
  lblSelected.left := imgMessaging.Left;
  lblNew.left := 0;
  lblNew.Width := 0;
  NewMessage := False;
end;

procedure TfrmMain.imgStopSessionClick(Sender: TObject);
var
  aprocess: tprocess;
  cl: TIdTCPClient;
begin
  cl := TIdTCPClient.Create(nil);
  try
    cl.Host := ServerIp;
    cl.Port := PortServerGeneral;
    cl.Connect;
    cl.IOHandler.WriteLn('RemUser');
  finally
    cl.Free;
  end;
  MessageListener.Active := False;
  aProcess := TProcess.Create(nil);
  aProcess.CommandLine := Application.ExeName;
  aProcess.Execute;
  aProcess.Free;
  Close;
end;

procedure TfrmMain.lblStatusClick(Sender: TObject);
begin
  pnlStatus.BringToFront;
  lblSelected.left := imgStatus.Left;
  lblClassId.Left:= label5.left+label5.width+8;
  lblSessionName.Left:= label5.left+label5.width+8;
  lblTeacherName.Left:= label5.left+label5.width+8;
end;

procedure TfrmMain.lblUpdateClick(Sender: TObject);
begin
  frmUpdater.Parent := pnlUpdate;
  frmUpdater.align := alClient;
  PnlUpdate.BringToFront;
  frmUpdater.Show;
end;

procedure TfrmMain.lvAssignmentClick(Sender: TObject);
begin
  if lvAssignment.ItemIndex <> -1 then
    lvAssignment.Height := btnAssignDetail.top - lvAssignment.Top - 6
  else
    lvAssignment.Height := btnAssignDetail.top + btnAssignDetail.Height - lvAssignment.Top;
end;

procedure TfrmMain.lvQuizClick(Sender: TObject);
begin
  if lvQuiz.ItemIndex <> -1 then
    lvQuiz.Height := btnQuizDetail.top - lvQuiz.Top - 6
  else
    lvQuiz.Height := btnQuizDetail.top + btnQuizDetail.Height - lvQuiz.Top;

end;

procedure TfrmMain.lvQuizSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  lvQuiz.Height := btnQuizDetail.top - lvQuiz.Top - 6
end;

procedure TfrmMain.MenuItem1Click(Sender: TObject);
begin
  Application.Restore;
  application.BringToFront;
  SetFocus;
end;

procedure TfrmMain.imgWorksClick(Sender: TObject);
begin
  updateAssignList;
  UpdateQuizList;
  pnlAssignment.Bringtofront;
  lvQuizClick(lvQuiz);
  lvAssignmentClick(lvAssignment);
  lblSelected.Left := imgWorks.Left;
end;

procedure TfrmMain.imgPreferencesClick(Sender: TObject);
begin
  frmPreferences.parent := pnlStart;
  frmPreferences.BorderStyle := bsNone;
  frmPreferences.Align := alClient;
  frmPreferences.Show;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  UserName := frmPreferences.GetUserName;
  ReArrange;
  pnlStart.BringToFront;
  if Username = '' then
    imgPreferencesClick(self);
end;

procedure TfrmMain.imgAboutClick(Sender: TObject);
begin
  lblSelected.left := imgAbout.left;
  pnlAbout.BringToFront;
  with frmAbout do
  begin
    frmAbout.Parent := pnlAbout;
    frmAbout.borderStyle := bsNone;
    frmAbout.align := alClient;
    frmAbout.Show;
    frmAbout.OpenAbout('2.0 Client', 'Release Build 2');
  end;
end;

procedure TfrmMain.btnAssignDetailClick(Sender: TObject);
begin
  if LvAssignment.ItemIndex = -1 then
    exit;

  frmWorksDetail.Parent := pnlAssignment;
  frmWorksDetail.Align := alClient;
  frmWorksDetail.Switch := 1;
  frmWorksDetail.idx := StrToInt(lvAssignment.Items[lvAssignment.ItemIndex].Caption) - 1;
  frmWorksDetail.Show;
  frmWorksDetail.BringToFront;
end;

procedure TfrmMain.UploadingDone;
begin
  HideUploadingForm;
  AssignInfo[UploadedAssignIdx].done := True;
  Inc(AssignDone);
  NotifyNewASsignment;
  UpdateAssignList;
end;

procedure TfrmMain.UploadingError;
begin
  HideUploadingForm;
  MsgBox('Pengiriman berkas gagal. Harap ulangi lagi.', 'Kesalahan', 16);
end;

procedure TfrmMain.btnDoAssignmentClick(Sender: TObject);
var
  idx: integer;
begin
  if LvAssignment.ItemIndex = -1 then
    exit;
  idx := StrToInt(lvAssignment.Items[lvAssignment.ItemIndex].Caption) - 1;
  OpenDlg.Filter := 'Berkas yang didukung (' + AssignInfo[idx].FileExt + ')|*' + AssignInfo[idx].FileExt;
  if OpenDlg.Execute then
  begin
    if Fileutil.FileSize(opendlg.FileName) > int64(AssignInfo[idx].SizeLimit * 1000000) then
    begin
      MsgBox('Ukuran berkas yang anda pilih melebihi batas yang ditentukan oleh pengajar. ' +
        IntToStr(AssignInfo[idx].SizeLimit) + ' MB', 'Ukuran berkas terlalu besar', MB_ICONEXCLAMATION);
      exit;
    end;
    ShowUploadingForm;
    UploadedAssignIdx := idx;
    FileUploader := TUploader.Create(OpenDlg.FileName, ServerIP, PortServerGeneral, 'Assignment' +
      IntToStr(idx), @UploadingError, @UploadingDone);
  end;
end;

procedure TfrmMain.btnDoQuizClick(Sender: TObject);
begin
  if LvQuiz.ItemIndex = -1 then
    exit;
  if not Assigned(CurrentQuizRaw) then
    CurrentQuizRaw := TStringList.Create;
  QuizDownloader := TQuizDownloader.Create(ServerIP, 59000, 'GetQuiz', StrToInt(lvQuiz.Items[lvQuiz.ItemIndex].Caption) -
    1, SessionToken, @CurrentQuizRaw);
  QuizDownloader.OnDone := @DoneQuizDownload;
  QuizDownloader.OnStart := @StartQuizDownload;
  QuizDownloader.OnError := @ErrorQuizDownload;
  QuizDownloader.Start;
end;

procedure TfrmMain.StartQuizDownload;
begin
  with pnlQuizDownloadWait do
  begin
    Visible := True;
    btnQuizStart.Visible := False;
    Caption := 'Sedang mengunduh berkas kuis ...';
    Align := AlClient;
    BringToFront;
    Font.Size := 12;
    Font.Color := clWhite;
  end;
  update;
end;

procedure TfrmMain.DoneQuizDownload;
begin
  pnlQuizDownloadWait.Caption := 'Berkas telah diunduh. Waktu Pengerjaan: ' + IntToStr(
    QuizInfo[StrToInt(lvQuiz.Items[lvQuiz.ItemIndex].Caption) - 1].Duration) + ' menit.';
  btnQUizStart.Caption := 'Mulai Pengerjaan';
  btnQUizStart.Visible := True;
  update;
end;

procedure TfrmMain.ErrorQuizDownload;
begin
  Caption := 'Terdapat kesalahan pada saat mengunduh berkas kuis. Pastikan sambungan anda dan coba lagi.';
  btnQUizStart.Caption := 'Tutup';
  update;
end;

procedure TfrmMain.btnQuizDetailClick(Sender: TObject);
begin
  if LvQuiz.ItemIndex = -1 then
    exit;

  frmWorksDetail.Parent := pnlAssignment;
  frmWorksDetail.Align := alClient;
  frmWorksDetail.Switch := 0;
  frmWorksDetail.idx := StrToInt(lvQuiz.Items[lvQuiz.ItemIndex].Caption) - 1;
  frmWorksDetail.Show;
  frmWorksDetail.BringToFront;
end;

procedure TfrmMain.btnQuizStartClick(Sender: TObject);
begin
  if btnQuizStart.Caption = 'Tutup' then begin
    pnlQuizDownloadWait.Visible := False;
    UpdateQuizList;
  end
  else if btnQuizStart.Caption = 'Coba Lagi' then
    AfterQuizDone
  else
  begin
    btnQuizStart.Visible := False;
    frmQuizPreview.DoQuiz(CurrentQuizRaw, QuizInfo[StrToInt(lvQuiz.Items[lvQuiz.ItemIndex].Caption) - 1].Duration);
  end;
end;

procedure TfrmMain.FooterClick(Sender: TObject);
begin

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  pnlStart.bringToFront;
end;

procedure TfrmMain.imgStartClassClick(Sender: TObject);
begin
  frmScanNetwork.Parent := pnlScan;
  frmScanNetwork.align := alClient;
  frmScanNetwork.Show;
  PnlScan.BringToFront;
  update;
  frmScanNetwork.Scan;
end;

procedure TfrmMain.MessageListenerExecute(AContext: TIdContext);
var
  sync: TSync;
begin
  if AContext.Binding.PeerIP = ServerIP then
  begin
    with ACOntext.Connection.IOHAndler do
    begin
      if Readln = 'Message' then
      begin
        CreateSync(sync, 'Message', 1);
        Sync.procparams[0] := readln;
        Sync.Synchronize;
        DestroySync(Sync);
      end;
    end;
  end;
end;

procedure TfrmMain.mmChatLogChange(Sender: TObject);
begin
  mmchatlog.ScrollBy(0, mmchatlog.Height);
end;

procedure TfrmMain.mmChatSendEnter(Sender: TObject);
begin
  if mmChatSend.Font.Style = [fsItalic] then
  begin
    mmChatSend.Font.Style := [];
    mmChatSend.Font.Color := clBlack;
    mmChatSend.Text := '';
  end;
end;

procedure TfrmMain.mmChatSendExit(Sender: TObject);
begin
  if mmChatSend.Text = '' then
  begin
    mmChatSend.Font.Style := [fsItalic];
    mmChatSend.Font.Color := clGray;
    mmChatSend.Text := 'tekan enter untuk mengirim pesan ke pengajar';
  end;
end;

procedure TfrmMain.mmChatSendKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
  begin
    key := #0;
    if trim(mmChatSend.Text) = '' then
      exit;
    if MessageSender.SendMessage(trim(mmChatSend.Text)) = False then
    begin
      MsgBox('Tidak dapat mengirim pesan ke pengajar.', 'Kesalahan sambungan', 16);
    end
    else
    begin
      mmChatLog.Lines.Add('Anda:');
      mmChatLog.Lines.Add(Trim(mmChatSend.Text));
      mmchatLog.Lines.Add('');
      mmCHatSend.Clear;
    end;
  end;
end;

procedure TfrmMain.pnlQuizDownloadWaitClick(Sender: TObject);
begin

end;

procedure TfrmMain.pnlQuizDownloadWaitResize(Sender: TObject);
begin
  btnQuizStart.Left := (pnlAssignment.Width div 2) - (btnQuizStart.Width div 2);
  btnQuizStart.Top := pnlAssignment.Height div 2 - btnquizStart.Height div 2 + 50;
end;

procedure TfrmMain.TrayClick(Sender: TObject);
var
  MsgStatus, quizStatus, AssignStatus: string;
begin
  if Length(QuizInfo) - QuizDone > 0 then
    QuizStatus := IntToStr(Length(QuizInfo) - QuizDone) + ' quiz belum dikerjakan.' + LineEnding
  else
    QuizStatus := '';
  if Length(AssignInfo) - AssignDone > 0 then
    AssignStatus := IntToStr(Length(AssignInfo) - AssignDone) + ' pekerjaan belum dikumpulkan.' + LineEnding
  else
    AssignStatus := '';
  if NewMessage then
    MsgStatus := 'Terdapat pesan baru dari pengajar.'
  else
    MsgStatus := '';

  if QuizStatus + AssignStatus + MsgStatus <> '' then
    TrayMsg('Status', QuizStatus + AssignStatus + MsgStatus, bfInfo)
  else
    TrayMsg('Status', 'Tidak ada pemberitahuan yang penting.', bfInfo);
end;

procedure TfrmMain.UniqueInstance1OtherInstance(Sender: TObject; ParamCount: integer; Parameters: array of string);
begin
  SetForeGroundWindow(Application.MainForm.Handle);
end;

procedure TfrmMain.UpdateAssignList;
var
  tmp: TlistItem;
  i: integer;
begin
  lvAssignment.Clear;
  for i := 0 to high(assignInfo) do
    if not AssignInfo[i].done then
    begin
      tmp := lvAssignment.Items.add;
      tmp.Caption := IntToStr(i + 1);
      tmp.SubItems.add(assigninfo[i].Name);
      tmp.SubItems.add(assigninfo[i].Description);
    end;
  ShowAssignmentCover(Length(QuizInfo) - QuizDone, Length(AssignInfo) - AssignDone);
end;

procedure TfrmMain.UpdateQuizList;
var
  tmp: TlistItem;
  i: integer;
begin
  lvQuiz.Clear;
  for i := 0 to High(QuizInfo) do
    if not QuizInfo[i].done then
    begin
      tmp := lvQuiz.Items.add;
      tmp.Caption := IntToStr(i + 1);
      tmp.SubItems.add(quizinfo[i].Name);
      tmp.SubItems.add(quizinfo[i].Description);
      tmp.SubItems.add(IntToStr(quizinfo[i].Duration) + ' menit');
    end;
  ShowAssignmentCover(Length(QuizInfo) - QuizDone, Length(AssignInfo) - AssignDone);
end;

procedure TfrmMain.ReArrange;
const
  img_margin = 80; //px
  img_size = 64; //px
begin
  pnlStart.BringToFront;
  imgMainLogo.Left := (Width div 2) - (imgMainLogo.Width div 2);
  imgStartClass.left := (Width div 2) - (1 * img_margin + 2 * img_size) div 2;
  lblStartClass.Left := imgStartClass.Left-(lblStartClass.width-imgStartClass.Width)div 2;
  imgPreferences.Left := ImgStartClass.Left + img_size + img_margin;
  lblPreferences.left := imgPreferences.left-(lblPreferences.width-imgpreferences.Width)div 2;
  //imgUpdate.left := imgPreferences.left+ img_size+img_margin;
  //lblUpdate.left := imgUpdate.left;
end;

end.
