unit formNewSession;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmNewSession }

  TfrmNewSession = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmNewSession: TfrmNewSession;

implementation

{$R *.lfm}

uses
  FormMain, FormSplash;

{ TfrmNewSession }

procedure TfrmNewSession.FormShow(Sender: TObject);
var
  docLeft, docTop: integer;
begin
  ComboBox2Change(nil);
  frmMain.Enabled := false;
  DocLeft := (Width-(label3.Width+12+Combobox1.Width)) div 2;
  Label1.left := DocLeft;
  Label2.Left := DocLeft;
  Label3.Left := DocLeft;
  Combobox1.Left := Label3.Left+label3.Width+20;
  Combobox2.Left := Label3.Left+label3.Width+20;
  Edit1.Left := Label3.Left+label3.Width+20;
  DocTop := (height - (Combobox1.Height*3+12+10+button2.height)) div 2;
  Combobox1.Top := DocTop;
  Combobox2.Top := Combobox1.Top+Combobox1.height+6;
  Edit1.Top := Combobox2.Top+Combobox2.height+6;
  label1.top := Combobox1.top+(Combobox1.Height-label1.height) div 2;
  label2.top := Combobox2.top+(Combobox2.Height-label2.height) div 2;
  label3.top := Edit1.top+(Edit1.Height-label3.height) div 2;
  button1.top := Edit1.Top+Edit1.Height+10;
  button2.Top := button1.Top;
  button1.left := Edit1.left+Edit1.Width-button1.width;
  button2.left := button1.left-button2.width-3;
end;

procedure TfrmNewSession.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmMain.Enabled := true;
  Combobox1.Text := '';
  Combobox2.Text := '';
  Edit1.Text := '';
end;

procedure TfrmNewSession.Button2Click(Sender: TObject);
begin
  close;
  frmSplash.pnlStart.bringtofront;
end;

procedure TfrmNewSession.ComboBox2Change(Sender: TObject);
begin
  if ((Combobox1.text <> '') and (combobox2.text <> '')) then
    button1.enabled := true
  else
    button1.enabled := false;
end;

procedure TfrmNewSession.Button1Click(Sender: TObject);
begin
  with frmMain do begin
    HasInit := true;
    TeacherName := aTeacherName;
    ClassID := Combobox1.Text;
    SessionName := Combobox2.Text;
    Password := edit1.text;
    StartClass;
    FrmSplash.Visible := false;
    FrmMain.Show;
  end;
  Close;
end;

end.
