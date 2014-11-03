unit formScanNetwork;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  unitdebug, IdTCPClient, LCLType, StdCtrls, ComCtrls, IdUDPClient, IdUDPServer,
  IdSync, IdSocketHandle, IdGlobal, sockets;

type

  { TfrmScanNetwork }

  TfrmScanNetwork = class(TForm)
    btnConnectServer: TButton;
    Button1: TButton;
    Button2: TButton;
    Header: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lvList: TListView;
    pnlScanner: TPanel;
    Server: TIdUDPServer;
    procedure btnConnectServerClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure lblRescanClick(Sender: TObject);
    procedure lvListClick(Sender: TObject);
    procedure lvListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ServerUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
  private
    ServerIPs: array of string;
  public
    procedure Scan;
  end;

  TASync = class(TIdSync)
  protected
    procedure DoSynchronize; override;
  public
    Params: array of string;
  end;

var
  frmScanNetwork: TfrmScanNetwork;

implementation

{$R *.lfm}

uses
  FormMain, unitGlobal;

procedure TASync.DoSynchronize;
var
  ListItem: TListItem;
begin
  SetLength(frmScanNetwork.ServerIPs, length(frmScanNetwork.ServerIps) + 1);
  frmScanNetwork.ServerIPs[High(frmScanNetwork.serverIps)] := params[0];
  with frmScanNetwork.lvList do
  begin
    ListItem := Items.Add;
    ListItem.Caption := IntToStr(Items.Count);
    ListItem.SubItems.Add(Params[1]+' ('+params[0]+')');
    ListItem.SubItems.Add(Params[3]);
    ListItem.SubItems.Add(Params[2]);
    ListItem.SubItems.Add(Params[4]);
    frmMain.Update;
  end;
end;

procedure TfrmScanNetwork.lblRescanClick(Sender: TObject);
begin

end;

procedure TfrmScanNetwork.lvListClick(Sender: TObject);
begin
  if lvList.ItemIndex = -1 then
    btnConnectServer.visible := false
  else
    btnConnectServer.visible := true;
end;

procedure TfrmScanNetwork.lvListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  btnConnectServer.visible := false;
end;

procedure TfrmScanNetwork.ServerUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);

  procedure IncData;
  begin
    SetLength(ServerIPs, Length(ServerIPs) + 1);
    ServerIPs[High(ServerIPs)] := ABinding.PeerIP;
  end;

var
  cmd: string;
  tmp: array of string;
  Async: TASync;
begin
  cmd := ConvertToString(AData);
  tmp := ExtractStr(cmd);
  //dbg(cmd);
  if tmp[0] = 'ReplyInfo' then
  begin
    async := TASync.Create;
    SetLength(async.Params, 5);
    async.Params[0] := ABinding.PeerIP;
    async.params[1] := tmp[1];
    async.params[2] := tmp[2];
    async.params[3] := tmp[3];
    async.params[4] := tmp[4];
    async.synchronize;
    async.Free;
  end;
end;

procedure TfrmScanNetwork.btnConnectServerClick(Sender: TObject);
var
  SessionToken, Password: string;
  tmp, i: integer;
  cl: TIdTCPCLient;
  aSessionName, aSessionSubject, aTeacherName: string;
begin
  Password := '';
  if Copy(lvList.Items[lvList.ItemIndex].SubItems[3], 1, 2) = 'Ya' then
  begin
    if not InputQuery('Verifikasi Password', 'Masukkan password yang diberikan oleh pengajar kelas yang bersangkutan.',
      password) then
      exit;
  end
  else
    password := '';

  cl := TIdTCPClient.Create(nil);
  with cl do
    try
      Host := ServerIPs[lvList.ItemIndex];
      Port := 59000;
      Connect;

      with IOHandler do
      begin
        WriteLn('AddUser');
        WriteLn(password);
        if ReadLnWait(5) = 'True' then
        begin
          WriteLn(frmMain.UserName);
          SessionToken := ReadLn;

          tmp := StrToInt(ReadLn); // quiz count
          Setlength(frmMain.QuizInfo, tmp);
          for i := 0 to tmp - 1 do
          begin
            frmMain.QuizInfo[i].Name := ReadLn;
            frmMain.QuizInfo[i].Description := ReadLn;
            frmMain.QuizInfo[i].Duration := StrToInt(ReadLn);
          end;

          tmp := StrToInt(ReadLn); // assignment count
          SetLength(frmMain.AssignInfo, tmp);
          for i := 0 to tmp - 1 do
          begin
            frmMain.AssignInfo[i].Name := ReadLn;
            frmMain.AssignInfo[i].Description := readln;
            frmMain.AssignInfo[i].FileExt := readln;
            frmMain.AssignInfo[i].SizeLimit := StrToInt(ReadLn);
          end;

          if ReadLn = 'Exists' then // check if this client has session data in server
          begin
            frmMain.QuizDone := StrToInt(ReadLn);
            for i := 0 to frmMain.QuizDone - 1 do
              frmMain.QuizInfo[StrToInt(ReadLn)].done := True;
            frmMain.AssignDone := StrToInt(ReadLn);
            for i := 0 to frmMain.AssignDone - 1 do
              frmMain.AssignInfo[StrToInt(ReadLn)].done := True;
          end;

          aSessionName := lvList.Items[lvList.ItemIndex].SubItems[0];
          aSessionSubject := lvList.Items[lvList.ItemIndex].SubItems[1];
          aTeacherName := lvList.Items[lvList.ItemIndex].SubItems[2];
          frmMain.StartSession(aSessionSubject, aTeacherName, aSessionName, ServerIPs[lvList.ItemIndex], SessionToken, Password);
          Server.Active := false;
          frmScanNetwork.Close;
          FrmMain.pnlMain.BringToFront;
          update;
        end
        else
          MsgBox('Password yang anda masukkan untuk kelas ini salah.', 'Password Salah', MB_ICONEXCLAMATION);
      end;
    except
      on E: Exception do
      begin
        MsgBox('Tidak dapat terhubung dengan server kelas (' + ServerIPs[lvList.ItemIndex] +
          ')', 'Kesalahan', MB_ICONERROR);
      end;
    end;

  if cl.Connected then
    cl.Disconnect;
  cl.Free;
end;

procedure TfrmScanNetwork.Button1Click(Sender: TObject);
begin
  close;
  frmMain.pnlStart.BringToFront;
end;

procedure TfrmScanNetwork.Button2Click(Sender: TObject);
begin
  Scan;
end;

procedure TfrmScanNetwork.FormShow(Sender: TObject);
begin

end;

procedure TfrmScanNetwork.Label3Click(Sender: TObject);
begin

end;

procedure TFrmScanNetwork.Scan;
var
  Client: TIdUDPClient;
begin
  Server.Active := True;
  Client := TIdUDPClient.Create;
  client.BroadcastEnabled:= true;
  SetLength(ServerIPs, 0);
  lvList.Items.Clear;
  try
    client.Broadcast('AskInfo', 59003);
  except
  end;
  client.Free;
end;

end.