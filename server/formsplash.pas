unit FormSplash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, UniqueInstance, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, LCLType;

type

  { TfrmSplash }

  TfrmSplash = class(TForm)
    imgCreateQuiz: TImage;
    imgMainLogo: TImage;
    imgPreferences: TImage;
    imgStartClass: TImage;
    lblCreateQuiz: TLabel;
    lblPreferences: TLabel;
    lblSelected: TLabel;
    lblStartClass: TLabel;
    pnlStartClass: TPanel;
    pnlQuizMaker: TPanel;
    pnlSettings: TPanel;
    pnlStart: TPanel;
    procedure FormShow(Sender: TObject);
    procedure imgCreateQuizClick(Sender: TObject);
    procedure imgStartClassClick(Sender: TObject);
    procedure lblPreferencesClick(Sender: TObject);
  private
    { private declarations }
  public
    const DefaultCaption = 'MultiPC Manager 2.0 Classroom Server';
    procedure ReArrange;
  end;

var
  frmSplash: TfrmSplash;
  aTeacherName: string;

implementation

{$R *.lfm}

uses
  FormQuizMaker, FormNewSession, formSettings;

{ TfrmSplash }

procedure TfrmSplash.ReArrange;
const
  img_margin = 80; //px
  img_size =64; //px
begin
  imgMainLogo.Left := (Width div 2) - (imgMainLogo.Width div 2);
  imgStartClass.left := (Width div 2) - (2*img_margin + 3*img_size) div 2;
  imgCreateQuiz.Left := ImgStartClass.Left+img_size+img_margin;
  imgPreferences.Left := ImgCreateQuiz.Left+img_size+img_margin;
{  {$IFDEF Windows}
  lblStartClass.Left :=  imgStartClass.Left;
  lblCreateQuiz.left := imgCreateQuiz.Left;
  lblPreferences.left := imgPreferences.left;
  {$ENDIF}
  {$IFDEF Linux}}
  lblstartclass.autosize := true;
  lblCreateQuiz.autosize := true;
  lblPreferences.AutoSize := true;
  lblStartClass.Left := imgStartClass.Left-((lblStartClass.Width-imgStartClass.Width) div 2);
  lblCreateQuiz.Left := imgCreateQuiz.Left-((lblCreateQuiz.Width-imgCreateQuiz.Width) div 2);
  lblpreferences.Left := imgpreferences.Left-((lblpreferences.Width-imgpreferences.Width) div 2);
  //{$ENDIF}
  pnlStart.BringToFront;
end;

procedure TfrmSplash.FormShow(Sender: TObject);
begin
  aTeacherName := frmSettings.GetUserName;
  ReArrange;
  pnlStart.BringToFront;
  if aTeacherName = '' then
    lblPreferencesClick(nil)
  else
  if paramCount = 2 then begin
    frmNewSession.ComboBox1.text := paramstr(1);
    frmNewSession.ComboBox2.text := paramstr(2);
    frmNewSession.Button1.Click;
  end;
end;

procedure TfrmSplash.imgCreateQuizClick(Sender: TObject);
begin
  Caption := frmSplash.DefaultCaption + ' - ' + 'Pembuat Quiz';

  pnlQuizMaker.BringToFront;

  frmQuizMaker.Align:= alClient;
  frmQuizMaker.BorderStyle:= bsNone;
  frmQuizMaker.Parent := pnlQuizMaker;
  frmQuizMaker.Show;
end;

procedure TfrmSplash.imgStartClassClick(Sender: TObject);
begin
  pnlStartClass.BringToFront;
  frmNewSession.parent := pnlStartClass;
  frmNewSession.Align := alClient;
  frmNewSession.BorderStyle := bsNone;
  frmnewsession.Show;
end;

procedure TfrmSplash.lblPreferencesClick(Sender: TObject);
begin
  pnlSettings.BringToFront;
  frmSettings.parent := pnlSettings;
  frmSettings.Align := alClient;
  frmSettings.BorderStyle := bsNone;
  frmSettings.Show;
end;

end.

