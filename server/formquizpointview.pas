unit FormQuizPointView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls, unitQuizFile,
  StdCtrls, ExtCtrls;

type

  { TfrmQuizPointView }

  TfrmQuizPointView = class(TForm)
    btnQuizMod: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lv: TListView;
    Panel1: TPanel;
    pnlCover: TPanel;
    dlg: TSaveDialog;
    procedure btnQuizModClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lvClick(Sender: TObject);
  private
    quizfileinit: boolean;
    quizfile: TQuizFile;
  public
    { public declarations }
  end;

var
  frmQuizPointView: TfrmQuizPointView;

implementation

{$R *.lfm}

uses
  FormMain, unitDatabase, unitDebug, unitglobal, unitlistviewtocsv, formquizpreview, unitquizpreview;

{ TfrmQuizPointView }

procedure TfrmQuizPointView.FormShow(Sender: TObject);
var
  i: integer;
begin
  quizfileInit := false;
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

procedure TfrmQuizPointView.lvClick(Sender: TObject);
begin
  if lv.ItemIndex <> -1 then
    button3.visible := true;
end;

procedure TfrmQuizPointView.ComboBox1Select(Sender: TObject);
var
  i: integer;
  tmp: TListItem;
  UserId, Idx, ChoiceVal, EssayVal, MaxVal: integer;
begin
  idx := Combobox1.ItemIndex;

  if idx = -1 then
    exit
  else
    lv.Clear;

  MaxVal := WorksData.Quiz[Idx].ChoicePoint * WorksData.Quiz[Idx].TotalChoice + WorksData.Quiz[Idx].EssayPoint * WorksData.Quiz[Idx].TotalEssay;
  for i := 0 to High(WorksData.Quiz[Combobox1.ItemIndex].QuizDoneId) do
  begin
    ChoiceVal := 0;
    EssayVal := 0;

    UserID := WorksData.Quiz[idx].QuizDoneId[i];

    tmp := lv.Items.Add;
    tmp.Caption := IntToStr(i + 1);
    tmp.SubItems.add(RealtimeData[UserID].Name);

    ChoiceVal := RealtimeData[UserID].QuizPoints[idx].Choice;

    tmp.SubItems.add(IntToStr(ChoiceVal));

    if WorksData.Quiz[idx].TotalEssay > 0 then begin
      if RealtimeData[UserID].QuizPoints[Idx].Essay <> -1 then
      begin
        EssayVal := RealtimeData[UserId].QuizPoints[idx].Essay;
        tmp.SubItems.add(IntToStr(EssayVal));
      end
      else
        tmp.SubItems.add('Belum Dikoreksi');
      btnQuizMod.Visible := true;
    end else begin
      tmp.SubItems.add('-');
      btnQuizMod.Visible := false;
    end;

    tmp.SubItems.add(IntToStr(ChoiceVal+EssayVal));
  end;

  label2.Caption := 'Total Submisi: ' + IntToStr(Length(WorksData.Quiz[Idx].QuizDoneId));
  label3.Caption := 'Nilai Maximum: ' + IntToStr(MaxVal);

  if Length(WorksData.Quiz[Idx].QuizDoneId) = 0 then
  begin
    with pnlCover do
    begin
      align := alClient;
      BringToFront;
      Caption := 'belum ada submisi untuk quiz ini.';
      Visible := True;
    end;
  end
  else
    pnlCover.Visible := False;
end;

procedure TfrmQuizPointView.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if quizfileinit then
    quizfile.destroy;
  with frmMain do
    button3.visible := true;
end;

procedure TfrmQuizPointView.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmQuizPointView.Button3Click(Sender: TObject);
begin
  if not quizFileInit then begin
    QuizFile := TQuizFile.Create;
    QuizFile.LoadFromFile(WorksData.Quiz[combobox1.ItemIndex].QuizData.FileName);
  end;
  frmQuizPreview.ShowPreview(quizFile, true);
  frmQuizPreview.QuizPrev.RevealAnswer(WorksData.Quiz[Combobox1.itemIndex].QuizAns, RealtimeData[lv.ItemIndex].QuizAnswers[combobox1.itemindex]);
end;

procedure TfrmQuizPointView.Button1Click(Sender: TObject);
begin
  if dlg.Execute then
    ExportCsv(lv, dlg.Filename, 'Daftar Nilai ' + WorksData.Quiz[Combobox1.ItemIndex].Name);
end;

procedure TfrmQuizPointView.btnQuizModClick(Sender: TObject);
begin
  frmMain.btnQuizMod.click;
end;

end.
