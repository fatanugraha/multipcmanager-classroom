unit formessaymoderatorsub;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls, unitQuizFile, spin;

type

  { TfrmEssayModeratorSub }

  TEssayModeratorRec = record
    Answer: TMemo;
    Question: Tlabel;
    ValueSpin: TSpinEdit;
    ValueLbl: TLabel
  end;

  TfrmEssayModeratorSub = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    pnlCover: TPanel;
    ScrollBox1: TScrollBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    UserIdx, QuizIdx: integer;
    cmp: array of TEssayModeratorRec;
  public
    procedure LoadComponents;
    procedure UnloadComponents;
    procedure SwitchToId;
  end;

var
  frmEssayModeratorSub: TfrmEssayModeratorSub;

implementation

{$R *.lfm}

{ TfrmEssayModeratorSub }

uses
  unitDatabase, FormMain, FormEssayModerator;

procedure TFrmEssayModeratorSub.SwitchToId;
function InsertLB(const astring: string): string;
var
  i: integer;
begin
  for i := 1 to Length(Astring) do
    if (astring[i] = char(11)) or (astring[i] = char(14)) then
      result := result+char(ord(astring[i])-1)
    else
      result := result+astring[i];
end;

var
  i: integer;
begin
  for i := 0 to High(cmp) do
  begin
    cmp[i].Answer.Text := InsertLB(RealtimeData[UserIdx].QuizAnswers[QuizIDx].Essays[i]);
    cmp[i].ValueSpin.Value := 0;
  end;
end;

procedure TfrmEssayModeratorSub.LoadComponents;
const
  margin = 20;
  _margin = 10;
var
  AFile: TQuizFile;
  comparator: TMemo;
  y, i: integer;
begin

  //place cover here :)
  AFile := TQuizFile.Create;

  AFile.LoadFromFile(WorksData.Quiz[QuizIdx].QuizData.FileName);

  SetLength(cmp, AFile.EssayQuiz);

  comparator := TMemo.Create(nil);
  Comparator.Width := Panel1.Width - 2 * Margin;
  Comparator.WordWrap := True;
  Comparator.BorderStyle := bsNone;
  Comparator.Font.color := clwhite;
  Comparator.Font.Size := 12;

  y := 0;

  for i := 0 to high(cmp) do
  begin
    with cmp[i] do
    begin
      Comparator.Text := Afile.Essays[i].Question.Text;
      Question := TLabel.Create(ScrollBox1);
      Question.Top := y + Margin;
      Question.Parent := ScrollBox1;
      Question.Autosize := False;
      Question.Font.color := clwhite;
      Question.Font.Size := 12;
      Question.Width := ScrollBox1.Width - 2 * Margin;
      Question.Anchors := [akleft, akright, aktop];
      Question.WordWrap := True;
      Question.Caption := Afile.Essays[i].Question.Text;
      Question.Height := 22 * Comparator.Lines.Count;
      Question.Left := margin;
      Question.Name := 'q_' + IntToStr(i);

      Answer := TMemo.Create(ScrollBox1);
      Answer.Top := Question.Height + Question.Top + _Margin;
      Answer.parent := ScrollBox1;
      Answer.Width := ScrollBox1.Width - 2 * Margin;
      Answer.Anchors := [akleft, akright, aktop];
      Answer.ScrollBars := ssVertical;
      Answer.Height := 50;
      Answer.ReadOnly := true;
      answer.Name := 'a_' + IntToStr(i);
      Answer.Anchors := [akleft, akright, aktop];
      Answer.Left := Margin;

      ValueSpin := TSpinEdit.Create(ScrollBox1);
      ValueSpin.Parent := ScrollBox1;
      ValueSpin.Top := Answer.Height + answer.Top + _Margin;
      ValueSpin.Width := 100;
      ValueSpin.MaxValue := WorksData.Quiz[QuizIdx].EssayPoint;
      VAlueSpin.MinValue := 0;
      ValueSpin.Left := ScrollBox1.Width - Margin - valuespin.Width;
      VAlueSpin.Anchors := [akright, aktop];
      ValueSpin.Name := 'v_' + IntToStr(i);

      ValueLbl := TLAbel.Create(ScrollBox1);
      ValueLbl.parent := ScrollBox1;
      valuelbl.Anchors := [akright, aktop];
      ValueLbl.top := VAlueSpin.Top + 3;
      ValueLbl.Font.COlor := clWhite;
      ValueLbl.Caption := 'Nilai Jawaban (Poin Max: '+inttostr(WorksData.Quiz[QuizIdx].EssayPoint)+') :';
      ValueLbl.Left := VAlueSpin.left - valueLbl.Width - 6;
      y := VAlueSpin.Top + ValueSpin.Height;
    end;
  end;
  comparator.Free;
  AFile.Free;
end;

procedure TfrmEssayModeratorSub.UnloadComponents;
var
  i: integer;
begin
  for i := 0 to high(cmp) do
    with cmp[i] do
    begin
      Question.Free;
      Answer.Free;
      ValueSpin.Free;
      ValueLbl.Free;
    end;
end;

procedure TfrmEssayModeratorSub.ComboBox1Select(Sender: TObject);
begin
  if Combobox1.itemindex = -1 then
    exit;

  userIdx := WorksData.Quiz[QuizIdx].QuizDoneId[combobox1.ItemIndex];

  if (RealtimeData[UserIdx].QuizPoints[QuizIdx].Essay = -1) then
  begin
    SwitchToId;
    pnlCover.Visible := False;
  end
  else
  begin
    with pnlCover do
    begin
      align := alClient;
      BringToFront;
      Caption := 'Nilai peserta didik ini telah dikoreksi.';
      Visible := True;
    end;
  end;
end;

procedure TfrmEssayModeratorSub.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  unloadComponents;
  frmEssayModerator.ComboBox1Select(frmEssayModerator.ComboBox1);
end;

procedure TfrmEssayModeratorSub.Button1Click(Sender: TObject);
var
  i: integer;
begin
  if (userIdx = -1) or (quizIdx = -1) then exit;

  if (RealtimeData[UserIdx].QuizPoints[QuizIdx].Essay <> -1) then exit;
  RealtimeData[UserIdx].QuizPoints[QuizIdx].Essay := 0;
  for i := 0 to high(cmp) do
    Inc(realtimedata[UserIdx].QuizPoints[QuizIdx].Essay, cmp[i].ValueSpin.Value);
  combobox1Select(combobox1);
end;

procedure TfrmEssayModeratorSub.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmEssayModeratorSub.Button3Click(Sender: TObject);
begin
  if Combobox1.ItemIndex-1 < 0 then
    combobox1.ItemIndex := combobox1.Items.count-1
  else
    combobox1.itemindex := combobox1.ItemIndex-1;
  combobox1Select(combobox1);
end;

procedure TfrmEssayModeratorSub.Button4Click(Sender: TObject);
begin
  combobox1.ItemIndex:= (combobox1.ItemIndex+1) mod combobox1.Items.count;
  combobox1Select(combobox1);
end;

procedure TfrmEssayModeratorSub.FormShow(Sender: TObject);
var
  i: integer;
begin
  Combobox1.Clear;

  QuizIdx := frmMain.ListView2.ItemIndex;
  userIdx := -1;

  with pnlCover do
  begin
    align := alClient;
    BringToFront;
    Caption := 'Pilih nama peserta didik yang akan dikoreksi jawaban esainya.';
    Visible := True;
  end;
  update;

  for i := 0 to High(WorksData.Quiz[frmMain.ListView2.ItemIndex].QuizDoneId) do
    Combobox1.Items.Add(realtimedata[WorksData.Quiz[frmMain.ListView2.ItemIndex].QuizDoneId[i]].Name);

  button3.enabled := combobox1.Items.count <> 0;
  button4.enabled := combobox1.Items.count <> 0;
  button1.enabled := combobox1.Items.count <> 0;

  LoadComponents;

  Combobox1.ItemIndex := frmEssayModerator.lv.ItemIndex;
  Combobox1Select(Combobox1);
end;

end.
