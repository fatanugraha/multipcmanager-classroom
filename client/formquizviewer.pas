unit formquizviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, {$IFDEF LCLGTK2} gtk2, gdk2, glib2, {$ENDIF}
  StdCtrls, unitQuizPreview, unitQuizFile, LCLTYpe;

type

  { TfrmQuizPreview }

  TfrmQuizPreview = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    lblTimeLeft: TLabel;
    pnlWaitCover: TPanel;
    pnlStatus: TPanel;
    ScrollBox1: TScrollBox;
    FTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure FTimerTimer(Sender: TObject);
  private
    FQuizFile: TQuizFile;
    FTime: int64;
    FCurrentTime: int64;
    QuitCode: integer;
  public
    procedure DoQuiz(const Data: TStringList; Time: int64);
    procedure DoneQuiz;
  end;

var
  AnswersUploaded: boolean;
  Answers: TQuizAnswers;
  Prev: TQuizPreview;
  frmQuizPreview: TfrmQuizPreview;

implementation

{$R *.lfm}

uses
  unitglobal, formMain;

procedure TfrmQuizPreview.FTimerTimer(Sender: TObject);

function FormatTime(a: int64): string;
begin
  Result := '';

  if Length(IntToStr(a div 3600)) = 1 then
    result := result+'0';
  Result := result+IntToStr(a div 3600)+':';

  a := a mod 3600;

  if Length(intToStr(a div 60)) = 1 then
    Result := result+'0';
  Result := Result+intToStr(a div 60)+':';

  a := a mod 60;

  if Length(intToStr(a)) = 1 then
    result := result+'0';
  Result := Result+intToStr(a);
end;

begin
  Inc(FcurrentTime);
  lbLTimeLeft.Caption := FormatTime(FTime-FCurrentTime);
  if FCurrentTime > FTime then begin
    DoneQuiz;
    FTImer.Enabled := false;
  end;
end;

procedure TfrmQuizPreview.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if QuitCode = -1 then
  begin
    if MsgBox('Apakah anda sudah selesai dan ingin mengumpulkan hasil kuis?', 'Konfirmasi', MB_YESNOCANCEL or MB_ICONQUESTION) = ID_YES then
      doneQuiz
    else
      CanClose := false;
  end else
    CanClose := true;
  QuitCode := -1;
end;

procedure TfrmQuizPreview.FormShow(Sender: TObject);
begin
  LblTimeLeft.left := Label1.Left+label1.width+10;
  QuitCode := -1;
end;

procedure TfrmQuizPreview.Button1Click(Sender: TObject);
begin
  FTimer.Enabled:= false;
  close;
end;

procedure TfrmQuizPreview.Button2Click(Sender: TObject);
var
  tmp: TIntArr;
  str: string;
  i: integer;
begin
  tmp := prev.CheckBlanks;
  if length(tmp) > 0 then begin
    str := '';
    for i := 0 to high(tmp) do
      str := str+inttostr(tmp[i])+', ';
    SetLength(Str, Length(Str)-2);
    MsgBox('Nomor berikut masih kosong:'+lineEnding+LineEnding+str, 'Cek Jawaban', MB_ICONINFORMATION);
  end else begin
    MsgBox('Semua pertanyaan telah terjawab.', 'Cek Jawaban', MB_ICONINFORMATION);
  end;
end;

procedure TfrmQuizPreview.DoQuiz(const Data: TStringList; Time: int64);
begin
  Left := 0;
  Top := 0;
  Show;

  with pnlWaitCover do begin
    SetBounds(0, 0, Screen.Width, Screen.Height);
    Visible := true;
    Caption := 'Sedang memuat ...';
  end;

  {$IFDEF LCLGTK2}
    WindowState := wsFullscreen;
    gdk_window_fullscreen(PGtkWidget(Handle)^.window);
    //gdk_window_unfullscreen(PGtkWidget(Handle)^.window);
  {$ELSE}
    BorderStyle := bsNone;
    BorderIcons := [];
    Width := SCreen.Width;
    Height := Screen.Height;
    FormStyle := fsStayOnTOp;
    WindowState := wsFullscreen;
  {$ENDIF}

  update;
  FTime := Time*60;
  FQuizFIle := TQuizFile.Create;
  FQuizFile.LoadFromStrings(TStrings(Data));
  Prev := TQuizPreview.Create(@FQuizFile, @ScrollBox1);
  Prev.ShuffleChoices := true;
  Prev.ShufflePlace := FQuizFile.Random;
  Prev.Draw;
  FQuizFile.Free;
  FCurrentTIme := 0;

  with pnlWaitCover do begin
    SetBounds(0, 0, 0, 0);
    Anchors := [];
    Visible := false;
  end;

  FTimer.Enabled := True;
end;

procedure TfrmQuizPreview.DoneQuiz;
begin
  QuitCode := 1;
  Answers := prev.Answers;
  frmMain.AfterQuizDone;
  close;
  prev.free;
  {$IFDEF LCLGTK2}
    gdk_window_unfullscreen(PGtkWidget(Handle)^.window);
  {$endif}
end;

end.