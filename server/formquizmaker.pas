unit formquizmaker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin, Buttons, unitQuizMaker, unitQuizFile;

type

  { TfrmQuizMaker }

  TfrmQuizMaker = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgClose: TImage;
    imgSave: TImage;
    imgOpen: TImage;
    imgPreview: TImage;
    imgMainLogo: TImage;
    Label1: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Header: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    opdlg: TOpenDialog;
    Panel1: TPanel;
    pnlCreate: TPanel;
    pnlStart: TPanel;
    dlg: TSaveDialog;
    ScrollBox1: TScrollBox;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure imgPreviewClick(Sender: TObject);
    procedure imgSaveClick(Sender: TObject);
    procedure imgOpenClick(Sender: TObject);
  private
    FilePath: string;
    QuizMaker: TQuizMaker;
    QuizMakerAssigned: boolean;
    procedure CreateForm(ChoiceCount, Choice, Essay: integer);
    procedure StrictSize;
    procedure FreeSize;
  public
    procedure ReArrange;
  const
    def_h = 408;
    def_w = 735;

  end;

var
  frmQuizMaker: TfrmQuizMaker;

implementation

{$R *.lfm}

uses
  FormSplash, FormQuizPreview;

procedure TfrmQuizMaker.StrictSize;
begin
  with frmSplash do
  begin
    BorderIcons := [biMinimize, biSystemMenu];
    Caption := frmSplash.DefaultCaption;
    with Constraints do
    begin
      MaxHeight := 408;
      MaxWidth := 735;
      MinHeight := 408;
      MinWidth := 735;
    end;
    Width := def_w;
    Height := def_h;
    position := poScreenCenter;
  end;
end;

procedure TfrmQuizMaker.FreeSize;
begin
  with frmSplash do
  begin
    BorderIcons := [biMinimize, biMaximize, biSystemMenu];
    Constraints.MaxHeight := 0;
    Constraints.MaxWidth := 0;
    Constraints.MinHeight := 408;
    Constraints.MinWidth := 735;
  end;
end;

procedure TfrmQuizMaker.CreateForm(ChoiceCount, Choice, Essay: integer);
begin
  QuizMaker := TQuizMaker.Create(@ScrollBox1, Choice, Essay, ChoiceCount);
  QuizMaker.Repaint;
  QuizMakerAssigned := True;
end;

procedure TfrmQuizMaker.ReArrange;
const
  img_margin = 80; //px
  img_size = 64; //px
begin
  imgMainLogo.Left := (Width div 2) - (imgMainLogo.Width div 2);
  image2.left := (Width div 2) - (2 * img_margin + 3 * img_size) div 2;
  label1.Left := image2.Left;
  image1.Left := image2.Left + img_size + img_margin;
  label2.left := image1.Left;
  image3.Left := image1.Left + img_size + img_margin;
  label3.left := image3.Left;
  pnlStart.BringToFront;
  frmSplash.Constraints.MaxHeight := 408;
  frmSplash.Constraints.MaxWidth := 735;
  frmSplash.Constraints.MinHeight := 408;
  frmSplash.Constraints.MinWidth := 735;
  BorderIcons := [biMinimize, biSystemMenu];
end;

procedure TfrmQuizMaker.Button1Click(Sender: TObject);
begin
  if not ((spinedit1.Value = 0) and (spinedit3.Value = 0)) then
  begin
    Panel1.Visible := False;
    imgPreview.Visible := True;
    imgSave.Visible := True;
    CreateForm(SpinEdit2.Value, SpinEdit1.Value, SpinEdit3.Value);
  end;
end;

procedure TfrmQuizMaker.FormCreate(Sender: TObject);
begin
  QuizMakerAssigned := false;
end;

procedure TfrmQuizMaker.FormShow(Sender: TObject);
{$IFDEF LINUX}
var
   docheight: integer;
{$ENDIF}
begin
  ReArrange;
  {$IFDEF LINUX}
  docHeight := spinEdit1.Height*5+24;
  Panel1.height := docHeight;
  SpinEdit1.Left := label7.width+label7.left+12;
  SpinEdit1.Top := 6;
  Label4.top := spinedit1.top+((spinedit1.height-label4.height) div 2);
  SpinEdit2.Left := label7.width+label7.left+12;
  SpinEdit2.Top := spinEdit1.Top+spinEdit1.Height+3;
  Label6.top := spinedit2.top+((spinedit2.height-label6.height) div 2);
  SpinEdit3.Left := label7.width+label7.left+12;
  SpinEdit3.Top := spinEdit2.Top+spinEdit2.Height+3;
  Label5.top := spinedit3.top+((spinedit3.height-label5.height) div 2);
  SpinEdit4.Left := label7.width+label7.left+12;
  SpinEdit4.Top := spinEdit3.Top+spinEdit3.Height+3;
  Label7.top := spinedit4.top+((spinedit4.height-label7.height) div 2);
  Checkbox1.left := label7.width+label7.left+12;
  Label12.top := spinedit4.top+spinedit4.height+3+((spinedit4.height-label12.height) div 2);
  Checkbox1.Top := label12.top;
  {$ENDIF}
end;

procedure TfrmQuizMaker.Image1Click(Sender: TObject);
var
  a: TQuizFile;
begin
  if opdlg.Execute then
  begin
    Image2Click(nil);
    FilePath := opdlg.filename;
    a := TQuizFile.Create;
    a.LoadFromFile(FilePath);
    a.ExportToQuizMaker(QuizMaker, @ScrollBox1);
    a.Free;
    QuizMakerAssigned := true;
    Panel1.Visible := False;
    imgPreview.Visible := True;
    imgSave.Visible := True;
    {$IFDEF LINUX}
      pnlCreate.Visible := true;
    {$ENDIF}
  end;
end;

procedure TfrmQuizMaker.Image2Click(Sender: TObject);
begin
  FreeSize;
  pnlCreate.BringToFront;
  Header.Caption := 'Untitled';
  Panel1.Visible := True;
  SpinEdit1.Value := 0;
  SpinEdit2.Value := 2;
  SpinEdit3.Value := 0;
  SpinEdit4.Value := 0;
  {$IFDEF LINUX}
    pnlCreate.Visible := true;
  {$ENDIF}
end;

procedure TfrmQuizMaker.Image3Click(Sender: TObject);
begin
  StrictSize;
  Close;
  frmSplash.pnlStart.BringToFront;
end;

procedure TfrmQuizMaker.imgCloseClick(Sender: TObject);
begin
  if QuizMakerAssigned then
  begin
    if Quizmaker.HasChanged then
      case application.MessageBox('Apakah anda ingin menyimpan dokumen sebelum menutup berkas?', 'Konfirmasi penyimpanan', $20 + $3) of
        6: imgSaveClick(imgSave);
        2: exit;
      end;
    QuizMaker.Destroy;
    QuizMakerAssigned := False;
  end;

  imgSave.Visible := False;
  imgPreview.Visible := False;
  pnlStart.BringToFront;
  {$IFDEF LINUX}
    pnlCreate.Visible := false;
  {$ENDIF}
  FilePath := '';
  Header.Caption := 'Untitled';
end;

procedure TfrmQuizMaker.imgPreviewClick(Sender: TObject);
var
  a: TQuizFile;
begin
  a := TQuizFile.Create;
  a.ImportFromQuizMaker(QuizMaker);
  frmQuizPreview.ShowPreview(a);
  frmQuizPreview.Caption:= 'Pratinjau soal';
  a.Free;
end;

procedure TfrmQuizMaker.imgSaveClick(Sender: TObject);
var
  a: TQuizFile;
  tmp: string;
begin
  if not Assigned(QuizMaker) then
    exit;

  if filepath = '' then
  begin
    if dlg.Execute then
    begin
      a := TQuizFile.Create;
      a.ImportFromQuizMaker(QuizMaker);
      tmp := dlg.FileName;
      if Copy(tmp, length(tmp)-4, 5) <> '.quiz' then
         tmp := tmp+'.quiz';
      a.SaveToFile(tmp);
      a.Free;

      FilePath := tmp;
      Header.Caption := ExtractFileName(tmp);
      QuizMaker.HasChanged := False;
    end;
  end
  else
  begin
    a := TQuizFile.Create;
    a.ImportFromQuizMaker(QuizMaker);
    a.SaveToFile(FilePath);
    a.Free;
    QuizMaker.HasChanged := False;
  end;
end;

procedure TfrmQuizMaker.imgOpenClick(Sender: TObject);
var
  a: TQuizFile;
begin
  if opdlg.Execute then
  begin
    FilePath := opdlg.filename;

    if QuizMakerAssigned then
      QuizMaker.Destroy;

    a := TQuizFile.Create;
    a.LoadFromFile(opdlg.FileName);
    a.ExportToQuizMaker(QuizMaker, @ScrollBox1);
    a.Free;

    Panel1.Visible := False;
    imgPreview.Visible := True;
    imgSave.Visible := True;
    update;
  end;
end;

end.
