unit FormVote;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IdTCPClient, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TfrmVote }

  TfrmVote = class(TForm)
    Button1: TButton;
    cl: TIdTCPClient;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    closeSender : string;
    LblArr: array of TLabel;
    idx, choice: integer;
    progress: boolean;
    procedure LblMouseEnter(Sender: TObject);
    procedure LblMouseExit(Sender: TObject);
    procedure LblMouseClick(Sender: TObject);
  end;

var
  frmVote: TfrmVote;

implementation

{$R *.lfm}

uses
  FormMain, unitdebug, unitGlobal;

procedure TfrmVote.LblMouseEnter(Sender: TObject);
begin
  if Tlabel(Sender).Color <> $FFFFFF then begin
    TLabel(sender).Color := $AAAAAA;
    TLabel(Sender).font.Color := clWhite;
  end;
end;

procedure TfrmVote.LblMouseExit(Sender: TObject);
begin
  if Tlabel(Sender).Color <> $FFFFFF then begin
    TLAbel(Sender).Color := color;
    TLabel(Sender).font.Color := clWhite;
  end;
end;

procedure TfrmVote.LblMouseClick(Sender: TObject);
begin
  if choice <> -1 then begin
    LbLArr[Choice].Color := Color;
    LbLArr[Choice].Font.Color := clWhite;
  end;
  choice := StrToInt(Copy(Tlabel(sender).Name, 9, Length(Tlabel(sender).Name)-8));
  TLabel(Sender).font.Color := clBlack;
  TLabel(sender).Color := $FFFFFF;
end;

procedure TfrmVote.FormShow(Sender: TObject);
var
  i, j: integer;
begin
  choice := -1;
  progress := true;
  for i := 0 to high(frmMain.VoteInfo) do begin
    if frmMain.VoteInfo[i].choice =-1  then
    begin
      idx := i;
      Label1.Caption := frmMain.VoteInfo[i].Title;
      Label2.Caption := frmMain.VoteInfo[i].Desc;
      SetLength(LblArr, Length(frmMain.VoteInfo[i].options));
      for j := 0 to High(frmMain.VoteInfo[i].options) do begin
        if not Assigned(Lblarr[j]) then
          Lblarr[j] := TLabel.Create(frmMain);
        with LblArr[j] do begin
          name := 'Options_'+inttostr(j);
          Parent := self;
          Autosize := false;
          Font.Color := clWhite;
          Transparent := false;
          Color := frmVote.Color;
          Layout := tlCenter;
          Caption := '  '+frmMain.VoteInfo[i].options[j];
          SetBounds(16, 80+6*(j+1)+20*j, frmVote.Width-32, 20);
          OnMouseEnter := @LblMouseEnter;
          OnMouseLeave := @LblMouseExit;
          OnClick := @LblMouseClick;
        end;
      end;
      Height := 80+6*(Length(frmMain.VoteInfo[i].options)-1)+16*length(frmMain.VoteInfo[i].options)+62;
      break;
    end;
  end;
end;

procedure TfrmVote.Button1Click(Sender: TObject);
var
  i: integer;
begin
  if choice = -1 then exit;

  if cl.Connected then
    cl.Disconnect;
  cl.Host:= frmMain.ServerIP;
  cl.port := PortServerGeneral;
  try
    cl.connect;
    cl.IOHandler.WriteLn('SubmitVote');
    cl.Iohandler.WriteLn(IntToStr(Idx));
    cl.Iohandler.WriteLn(IntToStr(Choice));
    cl.Disconnect;
    frmmain.VoteInfo[idx].choice := choice;
    closeSender := 'done';
    close;
    for i := 0 to High(lblArr) do
      lblarr[i].free;
    SetLength(Lblarr, 0);
  except
    on e: exception do begin
      MsgBox('Tidak dapat mengirim hasil vote, harap coba lain waktu.', 'Kesalahan', 16);
      cl.disconnect;
    end;
  end;
end;

procedure TfrmVote.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
begin
  progress := false;
  for i := 0 to High(lblArr) do
    lblarr[i].free;
  SetLength(LblArr, 0);
end;

procedure TfrmVote.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  i: integer;
begin
  CanClose := false;
  if CloseSender = 'done' then begin
    CloseSender := '';
    for i := 0 to high(frmMAin.VoteInfo) do begin
      if frmMain.VoteInfo[i].choice = -1 then
      begin
        FormShow(frmVote);
        exit;
      end;
    end;
    CanClose := true;
  end;
end;

procedure TfrmVote.FormCreate(Sender: TObject);
begin
  progress := false;
end;

end.


