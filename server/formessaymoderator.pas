unit FormEssayModerator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls;

type

  { TfrmEssayModerator }

  TfrmEssayModerator = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lv: TListView;
    Panel1: TPanel;
    pnlCover: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmEssayModerator: TfrmEssayModerator;

implementation

{$R *.lfm}

uses
  unitdebug, unitdatabase, FormMain, formessaymoderatorsub, formQuizPointView;

{ TfrmEssayModerator }

procedure TfrmEssayModerator.FormShow(Sender: TObject);
var
  i: integer;
begin
  with frmMain do begin
    btnQuizMod.visible := false;
    btnQuizValue.visible := false;
    btnQuizDetail.visible := false;
    button3.visible := false;
  end;
  Combobox1.Clear;
  with pnlCover do
  begin
    align := alClient;
    BringToFront;
    Caption := 'Pilih Daftar Nilai Quiz pada opsi diatas.';
    Visible := True;
  end;
  for i := 0 to High(WorksData.Quiz) do
    Combobox1.Items.Add(WorksData.Quiz[i].Name);
  ComboboX1.ItemIndex := -1;
  lv.Clear;

  if frmmain.Listview2.ItemIndex <> -1 then
  begin
    ComboBox1.ItemIndex := frmmain.Listview2.ItemIndex;
    COmboBox1Select(combobox1);
  end;
end;

procedure TfrmEssayModerator.ComboBox1Select(Sender: TObject);
var
  i: integer;
  UserID, idx: integer;
  a, b: integer;
  tmp: TListItem;
begin
  idx := Combobox1.ItemIndex;

  if idx = -1 then
    exit
  else
    lv.Clear;

  a := 0;
  b := 0;

  for i := 0 to High(WorksData.Quiz[Idx].QuizDoneId) do
  begin
    UserID := WorksData.Quiz[ComboBox1.ItemIndex].QuizDoneId[i];
    tmp := lv.Items.Add;
    tmp.Caption := IntToStr(i + 1);
    tmp.SubItems.Add(RealtimeData[UserID].Name);

    if RealtimeData[UserId].QuizPoints[idx].Essay = -1 then
    begin
      Inc(a);
      tmp.SubItems.add('Belum dikoreksi');
    end
    else
    begin
      Inc(b);
      tmp.SubItems.add('Sudah dikoreksi (' + IntToStr(RealtimeData[UserId].QuizPoints[idx].Essay) + '/' + IntToStr(WorksData.Quiz[idx].EssayPoint*WorksData.Quiz[idx].TotalEssay) + ')');
    end;
  end;

  Label2.Caption := 'Total Submisi: ' + IntToStr(a + b);
  Label3.Caption := IntToStr(a) + ' belum dikoreksi';

  if WorksData.Quiz[Combobox1.ItemIndex].TotalEssay = 0 then
    with pnlCover do
    begin
      align := alClient;
      BringToFront;
      Caption := 'Quiz ini tidak memiliki soal esai.';
      Visible := True;
    end
  else
    pnlCover.Visible := False;
end;

procedure TfrmEssayModerator.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  frmmain.button3.visible := true;
end;

procedure TfrmEssayModerator.Button2Click(Sender: TObject);
begin
  Close;
  if frmQuizPointView.visible then begin
    frmQuizPointView.FormShow(frmQuizPointView);
  end;
end;

procedure TfrmEssayModerator.Button1Click(Sender: TObject);
begin
  frmEssayModeratorSub.Parent := frmMain.pnlAssignment;
  frmEssayModeratorSub.BorderStyle := bsNone;
  frmEssayModeratorSub.Align := alClient;
  frmEssayModeratorSub.Show;
end;

end.
