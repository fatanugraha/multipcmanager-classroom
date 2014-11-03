unit formpreferences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, IniFiles, unitlanguage;

type

  { TfrmPreferences }

  TfrmPreferences = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    procedure CreateNewIni;
    function GetUserName: string;
    function GetLanguage: integer;
    procedure WriteIni(AName: string; Alang: integer);
    procedure SetFirstTime;
    procedure SetNormal;
  end;

var
  frmPreferences: TfrmPreferences;

implementation

{$R *.lfm}

uses
  FormMain, unitGlobal;

{ TfrmPreferences }

procedure TFrmPreferences.SetFirstTime;
begin
  BorderIcons := [];
  Button2.Visible := False;
end;

procedure TFrmPreferences.SetNormal;
begin
  BorderIcons := [biSystemMenu];
  Button2.Visible := True;
end;

procedure TfrmPreferences.CreateNewIni;
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath + 'preferences.ini');
  a.WriteString('General', 'UserName', '');
  a.WriteInteger('General', 'Language', 0);
  a.Free;
end;

function TFrmPreferences.GetUserName: string;
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath + 'preferences.ini');
  try
    Result := a.ReadString('General', 'UserName', '');
  except
    CreateNewIni;
    Result := '';
  end;
  a.Free;
end;

function TFrmPreferences.GetLanguage: integer;
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath + 'preferences.ini');
  try
    Result := a.ReadInteger('General', 'Language', 0);
  except
    CreateNewIni;
    Result := 0;
  end;
  a.Free;
end;

procedure TfrmPreferences.WriteIni(AName: string; Alang: integer);
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath + 'preferences.ini');
  a.WriteString('General', 'UserName', AName);
  a.WriteInteger('General', 'Language', ALang);
  a.Free;
end;

procedure TfrmPreferences.FormShow(Sender: TObject);
var
  docleft, doctop: integer;
begin
  Edit1.Text := GetUserName;
  if Edit1.Text = '' then
    SetFirstTime
  else
    SetNormal;
  combobox1.ItemIndex := getLanguage;
  docLeft := (Width - (label1.Width + 12 + edit1.Width)) div 2;
  DocTop := (Height - (edit1.Height + 20 + button2.Height)) div 2;
  Label1.Left := DocLeft;
  Edit1.Left := label1.left + label1.Width + 12;
  edit1.top := doctop;
  label1.top := doctop + ((edit1.Height - label1.Height) div 2);
  //combobox1.top := edit1.top + edit1.Height + 6;
  //label2.top := combobox1.Top + ((combobox1.Height - label2.Height) div 2);
  //Label2.Left := label1.left;
  //combobox1.left := edit1.left;
  //combobox1.Width := edit1.Width;
  button1.top := edit1.top + edit1.Height + 20;
  button1.left := edit1.left + edit1.Width - button1.Width;
  button2.top := button1.top;
  button2.left := button1.left - 6 - button2.Width;
end;

procedure TfrmPreferences.Button1Click(Sender: TObject);
begin
  if trim(edit1.Text) = '' then
    exit;
  WriteIni(Edit1.Text, combobox1.ItemIndex);
  FrmMain.UserName := edit1.Text;
  frmMain.Language := combobox1.ItemIndex;
  sw_lang(combobox1.ItemIndex = 1);
  button2.click;
end;

procedure TfrmPreferences.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmPreferences.Edit1Change(Sender: TObject);
begin
  if Trim(Edit1.Text) = '' then
    Button1.Enabled := False
  else
    button1.Enabled := True;
end;

procedure TfrmPreferences.Edit1KeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['A'..'Z', 'a'..'z', #8, ' ']) then
    key := #0;
end;

procedure TfrmPreferences.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmMain.Enabled := True;
  FrmMain.SetFocus;
end;

end.


