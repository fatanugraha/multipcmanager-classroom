unit FormAddQuiz;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, unitdebug, unitQuizFile, StdCtrls, Spin;

type

  { TfrmAddQuiz }

  TfrmAddQuiz = class(TForm)
    Bevel1: TBevel;
    btnDone: TButton;
    btnCancel: TButton;
    Button3: TButton;
    edtQuizDir: TEdit;
    edtQuizName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    mmDescription: TMemo;
    opd: TOpenDialog;
    spChoicePoint: TSpinEdit;
    spEssayPoint: TSpinEdit;
    spDuration: TSpinEdit;
    procedure btnDoneClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure edtQuizDirChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    freed: boolean;
    tmp_qfile: TQuizFile;
  public
  end;

var
  frmAddQuiz: TfrmAddQuiz;

implementation

{$R *.lfm}

uses unitDatabase, FormMain, unitglobal;

{ TfrmAddQuiz }

procedure TfrmAddQuiz.FormShow(Sender: TObject);
begin
  frmMain.btnQuizDetail.Visible := False;
  frmMain.btnQuizVAlue.Visible := False;
  frmMain.btnQuizMod.Visible := False;
  edtQuizName.Text := '';
  mmDescription.Text := '';
  edtQuizDir.Text := '';
  spChoicePoint.Value := 1;
  spEssayPoint.Value := 1;
  spDuration.Value := 1;
  btnDone.Enabled := False;
  Label7.Visible := False;
  spChoicePoint.Visible := False;
  Label8.Visible := False;
  spEssayPoint.Visible := False;
  label9.Visible := False;
  button3.height := edtQuizDir.Height;
  button3.top := edtQuizDir.top;
end;

procedure TfrmAddQuiz.Button3Click(Sender: TObject);
begin
  if opd.Execute then
  begin
    if not freed then
      tmp_qfile.Free;

    tmp_qfile := TQuizFile.Create;
    freed := False;

    //TODO: insert cover here;
    update;
    tmp_qfile.LoadFromFile(opd.FileName);
    //TODO: remove cover here;

    label9.Caption := 'Info Berkas: ' + IntToStr(tmp_qfile.ChoicesQuiz) + ' soal pilihan dan ' + IntToStr(tmp_qfile.EssayQuiz) + ' soal esai.';
    Label9.Visible := True;

    edtQuizDir.Text := opd.filename;

    spChoicePoint.Visible := tmp_qfile.ChoicesQuiz > 0;
    Label7.Visible := spChoicePoint.Visible;

    if spChoicePoint.Visible then
    begin
      spEssayPoint.Left := 280;
      label8.left := 280;
    end
    else
    begin
      spEssayPoint.Left := 138;
      Label8.left := 138;
    end;

    spEssayPoint.Visible := tmp_qfile.EssayQuiz > 0;

    if spEssayPoint.Visible then
      Label8.Visible := True
    else
      Label8.Visible := False;
  end;
end;

procedure TfrmAddQuiz.edtQuizDirChange(Sender: TObject);
begin
  if (edtQuizName.Caption <> '') and (mmDescription.Text <> '') and (edtQuizDir.Text <> '') then
    btnDone.Enabled := True
  else
    btnDone.Enabled := False;
end;

procedure TfrmAddQuiz.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not freed then
  begin
    tmp_qfile.Free;
    freed := True;
  end;
end;

procedure TfrmAddQuiz.btnDoneClick(Sender: TObject);
begin
  if (edtQuizName.Text = '') or (mmDescription.Text = '') or (edtQuizDir.Text = '') then
  begin
    msgBox('masih terdapat field yang kosong.', 'Kesalahan', 16);
    exit;
  end;

  SetLength(WorksData.Quiz, Length(WorksData.Quiz) + 1);
  with WorksData.Quiz[High(WorksData.Quiz)] do
  begin
    if spChoicePoint.Visible then
      ChoicePoint := spChoicePoint.Value
    else
      ChoicePoint := 0;
    if spEssayPoint.Visible then
      EssayPoint := spEssayPoint.Value
    else
      EssayPoint := 0;

    Duration := spDuration.Value;
    QuizPath := edtQuizDir.Text;
    Description := mmDescription.Text;
    Name := edtQuizName.Text;

    QuizAns := tmp_qfile.RandomizeChoice;
    TotalChoice := tmp_qfile.ChoicesQuiz;
    TotalEssay := tmp_qfile.EssayQuiz;

    if not DirectoryExistsUTF8(ExpandFileNameUTF8('temp')) then
      Mkdir(ExpandFileNameUTF8('temp'));

    if FileExistsUTF8(ExpandFileNameUTF8('temp') + dirDelimiter +'quiz_' + IntToStr(High(WorksData.Quiz))) then
      DeleteFileUTF8(ExpandFileNameUTF8('temp') + dirdelimiter +'quiz_' + IntToStr(High(WorksData.Quiz)));

    tmp_qfile.SaveToFile(ExpandFileNameUTF8('temp') +dirdelimiter + 'quiz_' + IntToStr(High(WorksData.Quiz)));

    if Assigned(QuizData) then
      QuizData.Free;

    QuizData := TFileStream.Create(ExpandFileNameUTF8('temp') +dirdelimiter+ 'quiz_' + IntToStr(High(WorksData.Quiz)), fmOpenRead or fmShareDenyWrite);
    //dbg('quiz_' + IntToStr(High(WorksData.Quiz)));
    TempManager.AddFile('quiz_' + IntToStr(High(WorksData.Quiz)));
    frmmain.imgAssignmentClick(frmMain.ImgAssignment);
    Close;
  end;
end;

procedure TfrmAddQuiz.btnCancelClick(Sender: TObject);
begin
  Close;
end;

end.
