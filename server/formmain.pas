{
    NOTE: WE USE WRITELN TO SEND INTEGERS DUE TO HANDLE UNSTABILITY USING WRITE() WHEN SENDING FROM LINUX TO WINDOWS
}
unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Process, Math, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, LCLIntf, LCLType, Dialogs, ExtCtrls, unitdebug,
  unittemporaryman, unitDatabase, unitSendMessage, StdCtrls, ComCtrls, unitviewer, IdUDPServer, IdSocketHandle, IdGlobal,
  IdTCPServer, IdContext, UnitThreadSync, IdUDPClient, IdThread, IdCustomTCPServer, UniqueInstance;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnControlPanel1: TImage;
    btnCreateGroup: TButton;
    Button1: TButton;
    btnAssignDetail: TButton;
    Button2: TButton;
    Button3: TButton;
    btnQuizDetail: TButton;
    btnQuizMod: TButton;
    btnQuizValue: TButton;
    btnAssignOpenDir: TButton;
    Button4: TButton;
    btnNewGroup: TButton;
    btnRemoveGroup: TButton;
    Header: TPanel;
    imgAbout: TImage;
    imgVote: TImage;
    imgGroup: TImage;
    imgLockRes: TImage;
    ImgUnlockRes: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblBroadcast1: TLabel;
    lblGroup: TLabel;
    lblAbout: TLabel;
    ListBox1: TListBox;
    ListView1: TListView;
    ListView2: TListView;
    lvVote: TListView;
    Memo1: TMemo;
    Memo2: TMemo;
    pnlAbout: TPanel;
    pnlGroup: TPanel;
    pnlVote: TPanel;
    pnlAssignment: TPanel;
    pnlMessages: TPanel;
    ScrollBox1: TScrollBox;
    svIdentifier: TIdUDPServer;
    svReporter: TIdTCPServer;
    svGeneral: TIdTCPServer;
    imgStatus: TImage;
    imgMessaging: TImage;
    imgAssignment: TImage;
    imgLock: TImage;
    imgDefaultBackgr: TImage;
    imgMailClosed: TImage;
    imgMailOpen: TImage;
    lblTeacherName: TLabel;
    lblStatus: TLabel;
    lblClassName: TLabel;
    lblMessaging: TLabel;
    lblAssignment: TLabel;
    lblLock: TLabel;
    lblSessionName: TLabel;
    lblControlPanel1: TLabel;
    lblNew: TLabel;
    pnlStatus: TPanel;
    Footer: TPanel;
    lblSelected: TLabel;
    OnlineChecker: TTimer;
    tvGroup: TTreeView;
    UniqueInstance1: TUniqueInstance;
    procedure btnAssignDetailClick(Sender: TObject);
    procedure btnControlPanel1Click(Sender: TObject);
    procedure btnCreateGroupClick(Sender: TObject);
    procedure btnNewGroupClick(Sender: TObject);
    procedure btnQuizDetailClick(Sender: TObject);
    procedure btnQuizModClick(Sender: TObject);
    procedure btnQuizValueClick(Sender: TObject);
    procedure btnRemoveGroupClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnAssignOpenDirClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure imgGroupClick(Sender: TObject);
    procedure imgVoteClick(Sender: TObject);
    procedure imgStatusClick(Sender: TObject);
    procedure imgMessagingClick(Sender: TObject);
    procedure imgAssignmentClick(Sender: TObject);
    procedure imgLockClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure lblAboutClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: boolean);
    procedure ListView2Click(Sender: TObject);
    procedure ListView2SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvVoteClick(Sender: TObject);
    procedure Memo2Enter(Sender: TObject);
    procedure Memo2Exit(Sender: TObject);
    procedure Memo2KeyPress(Sender: TObject; var Key: char);
    procedure svGeneralExecute(AContext: TIdContext);
    procedure svIdentifierUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure svReporterExecute(AContext: TIdContext);
    procedure OnlineCheckerTimer(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject; ParamCount: integer; Parameters: array of string);
  private
    SessionToken: string;
  public
    Viewer: TViewer;
    HasInit: boolean;
    LockScreen: boolean;
    TeacherName, ClassID, SessionName, Password: string;
    MessageSender: TMessageSender;

    procedure StartClass;
    procedure StopClass;
  end;

var
  counter: int64;
  TempManager: TTemporaryManager;
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses
  FormSplash, UnitGlobal, FormQuizDetail, FormAddAssignment, FormAddQuiz, FormQuizPointView, FormEssayModerator, FormAddVote,
  FormVote, FormAbout, FormAssignmentDetail;

procedure TfrmMain.StartClass;
begin
  Hasinit := True;
  svGeneral.Active := True;
  svReporter.Active := True;
  svIdentifier.Active := True;

  SetLength(WorksData.Assignment, 0);
  SetLength(WorksData.Quiz, 0);
  SetLength(CommandsData, 0);
  SetLength(RealtimeData, 0);
  SetLength(GroupData.Data, 0);
  GroupData.created := False;

  pnlStatus.Font.Color := clWhite;
  pnlStatus.Caption := 'Belum ada peserta didik yang bergabung.';
  imgStatusClick(imgStatus);

  LockScreen := False;
  OnlineChecker.Enabled := True;
  SessionToken := GenerateRandomName(10) + FormatDateTime('hhnnss', now);
  MessageSender := TMessageSender.Create('', 59005, 'Message');
  TempManager := TTemporaryManager.Create(ExpandFileNameUTF8('temp'));
end;

procedure TFrmMain.StopClass;
var
  aProcess: TProcess;
  i: integer;
begin
  if not hasinit then
    exit;
  for i := 0 to High(worksData.Quiz) do
  begin
    worksdata.quiz[i].QuizData.Free;
  end;
  Hasinit := False;
  OnlineChecker.Enabled := False;
  svGeneral.Active := False;
  svReporter.Active := False;
  svIdentifier.Active := False;
  TeacherName := '';
  ClassID := '';
  SessionName := '';
  Password := '';
  SetLength(WorksData.Assignment, 0);
  SetLength(WorksData.Quiz, 0);
  SetLength(CommandsData, 0);
  for i := 0 to high(realtimeData) do
  begin
    with realtimedata[i] do
    begin
      if Assigned(AdditionalData) then
        AdditionalData.Free;
      if Assigned(Msg) then
        Msg.Free;

      SetLength(QuizPoints, 0);
      SetLength(DoneAssign, 0);
      SetLength(DoneQuiz, 0);
    end;
  end;
  SetLength(RealtimeData, 0);
  uniqueinstance1.Enabled := False;
  SetLength(GroupData.Data, 0);
  MessageSender.Free;
  TempManager.DeleteTemporaryFiles;
  tempmanager.Destroy;
  viewer.Free;
  aProcess := TProcess.Create(nil);
  aProcess.CommandLine := Application.ExeName;
  aProcess.Execute;
  aProcess.Free;
  frmSplash.Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Viewer := TViewer.Create(@ScrollBox1);
  Viewer.DocMarginH := 20;
  Viewer.DocMarginW := 20;
  Viewer.Height := 168;
  Viewer.Width := 300;
  Viewer.MarginH := 20;
  Viewer.MarginW := 20;
  Viewer.MarginLbl := 10;
  Viewer.Font.Color := clWhite;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  ListView1.Height := (pnlAssignMent.Height - 172) div 2;
  button1.top := ListView1.Top + ListView1.Height + 8;
  btnAssignDetail.top := ListView1.Top + ListView1.Height + 8;
  btnAssignOpenDir.top := ListView1.Top + ListView1.Height + 8;
  Label2.top := Button1.Top + button1.Height + 23;
  ListView2.Top := Label2.Top + Label2.Height + 8;
  ListView2.Height := (pnlAssignMent.Height - 172) div 2;
  Button3.Top := ListView2.Top + ListView2.Height + 8;
  btnQuizDetail.Top := ListView2.Top + ListView2.Height + 8;
  btnQuizMod.Top := ListView2.Top + ListView2.Height + 8;
  btnQuizValue.Top := ListView2.Top + ListView2.Height + 8;
  if Assigned(viewer) then
    viewer.Repaint;
end;

procedure TfrmMain.imgGroupClick(Sender: TObject);
var
  i, j, idx: integer;
begin
  lblSelected.Left := imggroup.left;
  btnCreateGroup.Visible := not GroupData.created;
  tvGroup.Visible := not btnCreateGroup.Visible;
  btnRemoveGroup.Visible := not btnCreateGroup.Visible;
  btnNewGroup.Visible := not btnCreateGroup.Visible;
  if not GroupData.created then
  begin
    pnlGroup.Caption := 'kelas ini belum terbagi menjadi grup.';
    pnlGroup.Font.Color := clWhite;
    pnlGroup.Font.Size := 14;
    btnCreategroup.top := (pnlGroup.Height div 2) + 30;
    btnCreateGroup.Left := (pnlGroup.Width - btncreategroup.Width) div 2;
  end
  else
  begin
    pnlGroup.Font.Color := clblack;
    pnlGroup.Font.Size := 8;
    tvGroup.Items.Clear;
    tvGroup.SetBounds(memo1.Left, ListBox1.Top, memo1.Width, 0);
    tvGroup.Height := pnlGroup.Height - 34 - 6 - btnNewGroup.Height;
    btnNewGroup.left := tvGroup.Left + tvGroup.Width - btnNewGroup.Width;
    btnNewGroup.Top := tvGroup.Top + tvGroup.Height + 6;
    btnRemoveGroup.left := btnNewGroup.left - 6 - btnremovegroup.Width;
    btnRemoveGroup.top := btnNewGroup.Top;

    for i := 0 to high(groupData.Data) do
    begin
      tvGroup.Items.Add(nil, 'Grup ' + IntToStr(i + 1));
      idx := tvGroup.items.Count - 1;
      for j := 0 to high(groupdata.Data[i]) do
      begin
        if groupdata.Data[i, j] = '' then
          continue;
        tvGroup.Items.AddChild(tvGroup.Items[idx], groupData.Data[i, j]);
      end;
    end;
  end;
  pnlGroup.bringToFront;
end;

procedure TfrmMain.imgVoteClick(Sender: TObject);
var
  I: integer;
  item: TListItem;
begin
  pnlVote.BringToFront;
  lblSelected.Left := imgVote.left;
  LvVote.Clear;
  for i := 0 to High(VoteData) do
  begin
    item := LvVote.Items.Add;
    item.Caption := IntToStr(i + 1);
    Item.SubItems.Add(VoteData[i].Title);
    Item.SubItems.Add(VoteData[i].Desc);
    if Viewer.Count = 0 then
      Item.SubItems.Add('0%')
    else
      Item.SubItems.Add(IntToStr(Trunc(VoteData[i].Submision / Viewer.Count * 100)) + '%');
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  frmAddAssignment.Parent := pnlAssignment;
  frmAddAssignment.BorderStyle := bsNone;
  frmAddAssignment.Align := alClient;
  frmAddassignment.Show;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  frmAddVote.Parent := pnlVote;
  frmAddVote.BorderStyle := bsNone;
  frmAddVote.Align := alClient;
  frmAddVote.Show;
end;

procedure TfrmMain.btnQuizModClick(Sender: TObject);
begin
  frmEssayModerator.Parent := pnlAssignment;
  frmEssayModerator.BorderStyle := bsNone;
  frmEssayModerator.Align := alClient;
  frmEssayModerator.Show;
end;

procedure TfrmMain.btnCreateGroupClick(Sender: TObject);

  function isInt(val: string): boolean;
  var
    i: integer;
  begin
    if length(val) = 0 then
    begin
      Result := False;
      exit;
    end;
    Result := True;
    for i := 1 to length(val) do
    begin
      if not (val[i] in ['0'..'9']) then
      begin
        Result := False;
        break;
      end;
    end;
  end;

  function sumremoved: integer;
  var
    i: integer;
  begin
    Result := 0;
    for i := 0 to high(RealtimeData) do
      if realtimedata[i].IP = 'removed' then
        Inc(Result);
  end;

  function validate(val: integer): boolean;
  begin
    Result := viewer.Count - sumremoved >= val;
  end;

var
  Value: string;
  h, i, x: integer;
  raw: array of integer;
begin
  while not isInt(Value) do
  begin
    if not InputQuery('Informasi Grup', 'Masukkan total group:', Value) then
      exit;
  end;

  if StrToInt(value) = 0 then exit;

  if not validate(StrToInt(Value)) then
  begin
    msgBox('Tidak dapat membagi ' + IntToStr(viewer.Count) + ' orang menjadi ' + Value + ' grup', 'Kesalahan', 16);
    exit;
  end;

  SetLength(GroupData.Data, StrToInt(Value));
  SetLength(raw, viewer.Count);
  for i := 0 to high(raw) do
    raw[i] := i;

  h := 0;
  with groupdata do
    for i := 0 to high(raw) do
    begin
      x := -1;
      while x = -1 do
        x := randomfrom(raw);
      raw[x] := -1;

      setlength(groupdata.Data[h mod StrToInt(Value)], length(groupdata.Data[h mod StrToInt(Value)]) + 1);
      groupdata.Data[h mod StrToInt(Value), high(groupdata.Data[h mod StrToInt(Value)])] := viewer.LblData[x].Caption;
      Inc(h);
    end;

  groupdata.created := True;
  imgGroupClick(imgGroup);
end;

procedure TfrmMain.btnControlPanel1Click(Sender: TObject);
begin
  if msgBox('Apakah anda yakin untuk menutup sesi kelas ini?' + lineending +
    'Data temporary untuk sesi ini akan dihapus.', 'Konfirmasi', mb_iconquestion or mb_yesnocancel) = ID_YES then
    StopClass;
end;

procedure TfrmMain.btnAssignDetailClick(Sender: TObject);
begin
  if ListView1.ItemIndex = -1 then
    exit;

  with frmAssignmentDetail do
  begin
    Parent := pnlAssignment;
    BorderStyle := bsNone;
    Align := alClient;
    ShowData(frmMain.ListView1.ItemIndex);
    Show;
  end;
end;

procedure TfrmMain.btnNewGroupClick(Sender: TObject);
begin
  btnRemoveGroup.Click;
  btnCreateGroup.Click;
end;

procedure TfrmMain.btnQuizDetailClick(Sender: TObject);
begin
  if ListView2.ItemIndex = -1 then
    exit;

  with frmQuizDetail do
  begin
    Parent := pnlAssignment;
    BorderStyle := bsNone;
    Align := alClient;
    ShowData(frmMain.ListView2.ItemIndex);
    Show;
  end;
end;

procedure TfrmMain.btnQuizValueClick(Sender: TObject);
begin
  frmQuizPointView.Parent := pnlAssignment;
  frmQuizPointView.BorderStyle := bsNone;
  frmQuizPointView.Align := alClient;
  frmQuizPointView.Show;
end;

procedure TfrmMain.btnRemoveGroupClick(Sender: TObject);
begin
  tvGroup.Items.Clear;
  setLength(groupData.Data, 0);
  groupdata.created := False;
  imgGroupClick(imgGroup);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
  frmAddQuiz.Parent := pnlAssignment;
  frmAddQuiz.Align := alClient;
  frmAddQuiz.Show;
end;

procedure TfrmMain.btnAssignOpenDirClick(Sender: TObject);
var
  aprocess: TProcess;
  AssignmentId: integer;
begin
  aprocess := TProcess.Create(nil);
  AssignmentId := listview1.ItemIndex;
  CreateAssignDir(WorksData.Assignment[AssignmentId].Directory + ClassID + DirDelimiter + SessionName + DirDelimiter,
    WorksData.Assignment[AssignmentId].Name, WorksData.Assignment[AssignmentId].Description);
  {$IFDEF Windows}
  aprocess.CommandLine := 'explorer "' + WorksData.Assignment[AssignmentId].Directory +
    ClassID + DirDelimiter + SessionName + DirDelimiter + WorksData.Assignment[AssignmentId].Name + '"';
{$ENDIF}
  {$IFDEF Linux}
  aprocess.commandline := 'nautilus "' + WorksData.Assignment[AssignmentId].Directory +
    ClassID + '/' + SessionName + '/' + WorksData.Assignment[AssignmentId].Name + '"';
{$ENDIF}
  aprocess.Execute;
  aprocess.Free;
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
  frmVote.Parent := pnlVote;
  frmVote.BorderStyle := bsNone;
  frmVote.Align := alClient;
  frmVote.Show;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Application.Terminate;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
  btnControlPanel1Click(self);
end;

procedure TfrmMain.imgStatusClick(Sender: TObject);
begin
  pnlStatus.BringToFront;
  lblSelected.Left := TLabel(Sender).left;
end;

procedure TfrmMain.imgMessagingClick(Sender: TObject);
var
  i: integer;
begin
  pnlMessages.BringToFront;
  lblSelected.Left := imgMessaging.left;
  Listbox1.Clear;
  lblNew.Width := 0;
  lblNew.Left := 0;
  for i := 0 to High(RealtimeData) do
    if realtimedata[i].IP = 'removed' then
      continue
    else if realtimedata[i].NewData then
      ListBox1.items.Add(realtimedata[i].Name + ' - Pesan Baru')
    else
      ListBox1.items.Add(realtimedata[i].Name);
  ListBox1.Height := Memo2.Top + Memo2.Height - Listbox1.top;
end;

procedure TfrmMain.imgAssignmentClick(Sender: TObject);
var
  i: integer;
  a: TListItem;
begin
  pnlAssignment.BringToFront;
  lblSelected.Left := TLabel(Sender).left;
  ListView1.Clear;
  ListView2.Clear;
  for i := 0 to High(WorksData.Assignment) do
  begin
    with Worksdata.assignment[i] do
    begin
      a := ListView1.Items.Add;
      a.Caption := IntToStr(i + 1);
      a.SubItems.add(Name);
      a.SubItems.add(Description);
      a.SubItems.add(IntToStr(Length(DoneId)));
    end;
  end;
  for i := 0 to High(WorksData.Quiz) do
  begin
    with Worksdata.quiz[i] do
    begin
      a := ListView2.Items.Add;
      a.Caption := IntToStr(i + 1);
      a.SubItems.add(Name);
      a.SubItems.add(Description);
      a.SubItems.add(IntToStr(Duration));
      a.SubItems.add(IntToStr(Length(QuizDoneId)));
    end;
  end;
    btnQuizDetail.Visible := False;
    btnQuizValue.Visible := False;
    btnQuizMod.Visible := False;
  update;
end;

procedure TfrmMain.imgLockClick(Sender: TObject);
begin
  LockScreen := not LockScreen;

  if LockScreen then
  begin
    imgLock.Picture.Assign(imgUnlockRes.Picture);
    lblLock.Caption := 'Buka Kunci';
  end
  else
  begin
    imgLock.Picture.Assign(imgLockRes.Picture);
    lblLock.Caption := 'Kunci Layar';
  end;
end;

procedure TfrmMain.Label5Click(Sender: TObject);
begin
  Label6.Visible := True;
  Viewer.Height := Viewer.Height + 10;
  Viewer.Width := Viewer.Width + 18;
  viewer.Repaint;
end;

procedure TfrmMain.Label6Click(Sender: TObject);
begin
  if (Viewer.Height <= 113) and (Viewer.Width <= 200) then
    Label6.Visible := False
  else
  begin
    Viewer.Height := Viewer.Height - 10;
    Viewer.Width := Viewer.Width - 18;
    viewer.Repaint;
  end;
end;

procedure TfrmMain.lblAboutClick(Sender: TObject);
begin
  lblSelected.left := imgAbout.left;
  pnlAbout.BringToFront;
  with frmAbout do
  begin
    frmAbout.Parent := pnlAbout;
    frmAbout.borderStyle := bsNone;
    frmAbout.align := alClient;
    frmAbout.Show;
    frmAbout.OpenAbout('2.0 Server', 'Release Build 2');
  end;
end;

procedure TfrmMain.ListBox1Click(Sender: TObject);
var
  x: integer;
begin
  if ListBox1.ItemIndex <> -1 then
  begin
    Listbox1.Height := 82;
    Memo2.Text := '';
    Memo2Exit(nil);
    x := RelToFix(ListBox1.ItemIndex);
    memo1.Lines.Assign(realtimedata[x].Msg);
    realtimedata[x].newdata := False;
    ListBox1.items[listbox1.ItemIndex] := realtimedata[x].Name;
    memo1.ScrollBy(0, high(integer));
  end
  else
  begin
    ListBox1.Height := Memo2.Top + Memo2.Height - listbox1.top;
    Memo2.Text := '';
    Memo2Exit(nil);
  end;
end;

procedure TfrmMain.ListView1Click(Sender: TObject);
begin
  btnAssignDetail.Visible := ListView1.ItemIndex <> -1;
  btnAssignOpenDir.Visible := ListView1.ItemIndex <> -1;
end;

procedure TfrmMain.ListView1SelectItem(Sender: TObject; Item: TListItem; selected: boolean);
begin
  btnAssignDetail.Visible := ListView1.ItemIndex <> -1;
  btnAssignOpenDir.Visible := ListView1.ItemIndex <> -1;
end;

procedure TfrmMain.ListView2Click(Sender: TObject);
begin
    btnQuizDetail.Visible := ListView2.ItemIndex <> -1;
    btnQuizValue.Visible := ListView2.ItemIndex <> -1;
    btnQuizMod.Visible := ListView2.ItemIndex <> -1;
end;

procedure TfrmMain.ListView2SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  btnQuizDetail.Visible := True;
  btnQuizValue.Visible := True;
  if WorksData.Quiz[ListView2.ItemIndex].EssayPoint > 0 then
  begin
    btnQuizMod.Left := btnQuizDetail.left + btnQuizDetail.Width + 6;
    btnQuizValue.Left := btnQuizDetail.left + btnQuizDetail.Width + 12 + btnQuizMod.Width;
    btnQuizMod.Visible := True;
  end
  else
  begin
    btnQuizValue.Left := btnQuizDetail.left + btnQuizDetail.Width + 6;
    btnQuizMod.Visible := False;
  end;
end;

procedure TfrmMain.lvVoteClick(Sender: TObject);
begin
  Button4.Visible := (lvVote.ItemIndex <> -1) and (VoteData[lvVote.ItemIndex].Submision <> 0);
end;

procedure TfrmMain.Memo2Enter(Sender: TObject);
begin
  if Memo2.Font.Style = [fsItalic] then
  begin
    Memo2.Font.Style := [];
    Memo2.Font.Color := clBlack;
    Memo2.Text := '';
  end;
end;

procedure TfrmMain.Memo2Exit(Sender: TObject);
begin
  if memo2.Text = '' then
  begin
    memo2.Font.Style := [fsItalic];
    memo2.Font.Color := clGray;
    memo2.Text := 'tekan enter untuk mengirim pesan';
  end;
end;

procedure TfrmMain.Memo2KeyPress(Sender: TObject; var Key: char);
var
  x: integer;
begin
  if key = #13 then
  begin
    key := #0;
    if Trim(Memo2.Text) = '' then
      exit;

    x := RelToFix(Listbox1.ItemIndex);

    if realtimedata[x].IP = 'removed' then
    begin
      msgBox('peserta didik ini telah meninggalkan sesi kelas.', 'Pengguna tidak tersedia', 16);
      exit;
    end;
    if MessageSender.SendMessage(RealtimeData[x].IP, trim(Memo2.Text)) = False then
    begin
      MsgBox('Tidak dapat mengirim pesan ke ' + RealtimeData[x].Name + '.',
        'Kesalahan sambungan', 16);
    end
    else
    begin
      RealtimeData[x].Msg.Add('Anda:');
      RealtimeData[x].Msg.Add(trim(Memo2.Text));
      RealtimeData[x].Msg.Add('');
      Memo1.Lines.Add('Anda:');
      Memo1.Lines.Add(trim(Memo2.Text));
      Memo1.Lines.Add('');
      Memo2.Clear;
    end;
  end;
end;

procedure TfrmMain.OnlineCheckerTimer(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to High(RealtimeData) do
  begin
    if RealtimeData[i].IP = 'removed' then
      continue;

    if Realtimedata[i].Online then
      Viewer.LblData[i].Caption := RealtimeData[i].Name
    else
      Viewer.LblData[i].Caption := RealtimeData[i].Name + ' - (Offline)';
    RealtimeData[i].Online := False;
  end;
end;

procedure TfrmMain.UniqueInstance1OtherInstance(Sender: TObject; ParamCount: integer; Parameters: array of string);
begin

end;

procedure TfrmMain.svGeneralExecute(AContext: TIdContext);

  procedure writeinfos;
  var
    i: integer;
  begin
    AContext.Connection.IOHandler.Writeln(SessionToken);
    Acontext.Connection.IOHandler.WriteLn(IntToStr(Length(WorksData.Quiz)));
    for i := 0 to high(WorksData.Quiz) do
    begin
      with AContext.Connection.IOHandler do
      begin
        WriteLn(WorksData.Quiz[i].Name);
        WriteLn(WorksData.Quiz[i].Description);
        WriteLn(IntToStr(WorksData.Quiz[i].Duration));
      end;
    end;
    Acontext.Connection.IOHandler.WriteLn(IntToStr(Length(WorksData.Assignment)));
    for i := 0 to high(worksdata.Assignment) do
    begin
      with AContext.Connection.IOHandler do
      begin
        WriteLn(WorksData.Assignment[i].Name);
        WriteLn(WorksData.Assignment[i].Description);
        WriteLn(WorksData.Assignment[i].FileExt);
        WriteLn(IntToStr(WorksData.Assignment[i].SizeLimit));
      end;
    end;
  end;

var
  ip, cmd: string;
  i, j: integer;
  size: int64;
  Stream: TFileStream;
  temp_str1: string;
  AssignmentID, temp_int1: integer;
  tmpChoice: TIntArr;
  tmpEssay: TSTrArr;
  sync: TSync;
begin
  try
    ip := AContext.Binding.PeerIP;
    cmd := AContext.Connection.IOHandler.ReadLn;

    if cmd = 'SubmitVote' then
    begin
      i := StrToInt(AContext.Connection.IOHandler.ReadLn);
      j := StrToInt(AContext.Connection.IOHandler.ReadLn);

      if SeekIndex(FindIndex(ip), VoteData[i].doneid) <> -1 then
        exit;

      CreateSync(sync, cmd, 3);
      Sync.procParams[0] := ip;
      Sync.procParams[1] := IntToStr(i);
      Sync.procParams[2] := IntToStr(j);
      Sync.Synchronize;
      DestroySync(Sync);
    end
    else if cmd = 'QuizAnswers' then
    begin
      with AContext.Connection.IOHandler do
      begin
        if ReadLn <> SessionToken then
          exit;
        j := StrToInt(ReadLn);
        SetLength(tmpChoice, StrToInt(ReadLn));
        for i := 0 to High(TmpChoice) do
          tmpchoice[i] := StrToInt(ReadLn);
        SetLength(tmpEssay, StrToInt(ReadLn));
        for i := 0 to High(TmpEssay) do
          tmpEssay[i] := ReadLn;
      end;

      CreateSync(Sync, cmd, 2, 2);
      Sync.procParams[0] := ip;
      Sync.Procparams[1] := IntToStr(j);
      sync.procParamsAux[0] := @tmpChoice;
      sync.procParamsAux[1] := @tmpEssay;
      Sync.Synchronize;
      DestroySync(sync);
    end
    else
    if cmd = 'GetQuiz' then
    begin
      if AContext.Connection.IOHandler.Readln = SessionToken then
      begin
        i := StrToInt(AContext.Connection.IOHandler.ReadLn);
        if i > High(WorksData.Quiz) then
          exit;
        AContext.Connection.IOHandler.WriteLn(intToStr(WorksData.Quiz[i].QuizData.Size));
        AContext.Connection.IOHandler.Write(WorksData.Quiz[i].QuizData);
      end;
    end
    else if cmd = 'AddUser' then
    begin
      if AContext.Connection.IOHandler.Readln = Password then
      begin
        AContext.Connection.IOHandler.WriteLn('True');
        temp_str1 := AContext.Connection.IOHandler.ReadLn;
        temp_int1 := FindIndex(ip);
        writeinfos;
        if temp_int1 = -1 then
        begin
          AContext.Connection.IOHandler.Writeln('New');
          createSync(sync, cmd, 2);
          Sync.ProcParams[0] := ip;
          sync.ProcParams[1] := temp_str1;
          sync.Synchronize;
          DestroySync(Sync);
        end
        else
        begin
          AContext.Connection.IOHandler.Writeln('Exists');
          AContext.Connection.IOHandler.WriteLn(IntToStr(Length(RealtimeData[temp_int1].DoneQuiz)));//total done quiz
          for i := 0 to high(RealtimeData[temp_int1].DoneQuiz) do
            AContext.Connection.IOHandler.WriteLn(IntToStr(RealtimeData[temp_int1].DoneQuiz[i]));
          AContext.Connection.IOHandler.WriteLn(IntToStr(Length(RealtimeData[temp_int1].DoneAssign)));
          //total done assignment
          for i := 0 to high(RealtimeData[temp_int1].DoneAssign) do
            AContext.Connection.IOHandler.WriteLn(IntToStr(RealtimeData[temp_int1].DoneAssign[i]));
        end;
      end
      else
        AContext.Connection.IOHandler.WriteLn('False');
      OnlineCheckerTimer(nil);
    end
    else if cmd = 'Message' then
    begin
      CreateSync(Sync, 'Message', 2);
      Sync.procParams[0] := ip;
      sync.Procparams[1] := AContext.Connection.IOHandler.Readln;
      Sync.Synchronize;
      DestroySync(sync);
    end
    else if cmd = 'RemUser' then
    begin
      CreateSync(Sync, 'RemUser', 1);
      Sync.ProcParams[0] := ip;
      Sync.Synchronize;
      DestroySync(Sync);
    end
    else if copy(cmd, 1, 10) = 'Assignment' then
    begin
      temp_int1 := FindIndex(ip);
      AssignmentId := StrToInt(Copy(cmd, 11, Length(cmd) - 10));
      CreateAssignDir(WorksData.Assignment[AssignmentId].Directory + ClassID + DirDelimiter +
        SessionName + DirDelimiter,
        WorksData.Assignment[AssignmentId].Name, WorksData.Assignment[AssignmentId].Description);
      temp_str1 := WorksData.Assignment[AssignmentId].Directory + DirDelimiter + ClassId +
        DirDelimiter + SessionName + DirDelimiter + WorksData.Assignment[AssignmentId].Name + DirDelimiter;
      temp_str1 := temp_str1 + RealtimeData[temp_int1].Name + ' ';
      temp_str1 := temp_str1 + FormatDateTime('hh', now) + 'h_';
      temp_str1 := temp_str1 + FormatDateTime('nn', now) + 'm ';
      temp_str1 := temp_str1 + FormatDateTime('dd_mm_yyyy', now);
      temp_str1 := temp_str1 + WorksData.Assignment[AssignmentId].FileExt;
      Stream := TFileStream.Create(temp_str1, fmCreate or fmShareDenyWrite);
      size := StrToInt(AContext.Connection.IOHandler.ReadLn);
      AContext.Connection.IOHandler.ReadStream(Stream, Size, False);
      Stream.Free;
      CreateSync(sync, 'IncAssignment', 2);
      Sync.procParams[0] := IntToStr(temp_int1);
      Sync.procParams[1] := IntToStr(AssignmentId);
      Sync.Synchronize;
      DestroySync(sync);
    end;
  except
  end;
end;

procedure TfrmMain.svIdentifierUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
var
  cl: TIdUDPClient;
  Buffer: string;
  tmp: string;
begin
  tmp := ConvertToString(AData);
  if Copy(tmp, 1, 7) = 'AskInfo' then
  begin
    cl := TIdUDPClient.Create(nil);
    Buffer := 'ReplyInfo|' + ClassId + '|' + TeacherName + '|' + SessionName + '|';
    if Password <> '' then
      Buffer := Buffer + 'Ya'
    else
      Buffer := Buffer + 'Tidak';
    cl.SendBuffer(ABinding.PeerIP, 59004, ConvertToBuffer(Buffer));
    cl.Free;
  end;
end;

procedure TfrmMain.svReporterExecute(AContext: TIdContext);
var
  sync: TSync;
  Stream: TMemoryStream;
  Size: int64;
  i, j: integer;
begin
  with AContext.Connection.IOHandler do
    try
      if readln = SessionToken then
        WriteLn('Pass')
      else
        Writeln('Denied');

      if FindIndex(AContext.Binding.PeerIP) = -1 then
        exit;

      //RECEIVE CLIENT'S DESKTOP SCREENSHOT
      if AContext.Connection.IOHandler.ReadLn = 'Screenshot' then
      begin
        Size := StrToInt(AContext.Connection.IOHandler.ReadLn);
        if Size <= 1000000 then //less or equal than 1MB
        begin
          Stream := TMemoryStream.Create;
          ReadStream(Stream, Size);
          CreateSync(Sync, 'ScreenShot', 1, 1);
          Sync.ProcParams[0] := AContext.Binding.PeerIP;
          Sync.ProcParamsAUX[0] := @Stream;
          Sync.Synchronize;
          Stream.Free;
          DestroySync(Sync);
        end;
      end
      else
        exit;

      //SYNCHRONISING CLIENT'S ASSIGNMENT DATA AND SERVER'S.
      if StrToInt(ReadLn) = Length(WorksData.Assignment) then // Check Assignments first
        WriteLn('True')
      else
      begin
        WriteLn('False');
        WriteLn(IntToStr(Length(WorksData.Assignment)));
        for i := 0 to High(WorksData.Assignment) do
        begin
          WriteLn(WorksData.Assignment[i].Name);
          WriteLn(WorksData.Assignment[i].Description);
          WriteLn(WorksData.Assignment[i].FileExt);
          WriteLn(IntToStr(WorksData.Assignment[i].SizeLimit));
        end;
      end;

      //SYNCHRONISING CLIENT'S QUIZ DATA AND SERVER'S.
      if StrToInt(ReadLn) = Length(WorksData.Quiz) then // Check Assignments first
        WriteLn('True')
      else
      begin
        WriteLn('False');
        WriteLn(IntToStr(Length(WorksData.Quiz)));
        for i := 0 to High(WorksData.Quiz) do
        begin
          WriteLn(WorksData.Quiz[i].Name);
          WriteLn(WorksData.Quiz[i].Description);
          WriteLn(IntToStr(WorksData.Quiz[i].Duration));
        end;
      end;

      //SYNCHRONISING CLIENT'S VOTE DATA
      if StrToInt(ReadLn) = Length(VoteData) then
        WriteLn('True')
      else
      begin
        Writeln('False');
        WriteLn(IntToStr(Length(VoteData)));
        for i := 0 to High(VoteData) do
        begin
          WriteLn(VoteData[i].Title);
          WriteLn(VoteData[i].Desc);
          WriteLn(IntToStr(seekindex(FindIndex(AContext.Binding.PeerIp), VoteData[i].doneid)));
          WriteLn(IntToStr(Length(votedata[i].Data)));
          for j := 0 to high(VoteData[i].Data) do
            WriteLn(Votedata[i].Data[j].Value);
        end;
      end;

      if LockScreen then
        WriteLn('True')
      else
        WriteLn('False');

      WriteLn('Disconnect');
    except
      //on e: Exception do noting :) - Patrick Star

    end;
end;

end.