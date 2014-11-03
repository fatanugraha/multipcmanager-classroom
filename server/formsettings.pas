unit FormSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, iniFiles;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    procedure CreateNewIni;
    function GetUserName: string;
    procedure WriteUserName(AName: string);
    procedure SetFirstTime;
    procedure SetNormal;
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.lfm}

uses
  FormSplash, unitglobal;

procedure TfrmSettings.SetFirstTime;
begin
  BorderIcons := [];
  Button2.Visible:= false;
end;

procedure TfrmSettings.SetNormal;
begin
  BorderIcons := [biSystemMenu];
  Button2.Visible:= true;
end;

procedure TfrmSettings.FormShow(Sender: TObject);
var
  docLeft, DocTop: integer;
begin
  Edit1.Text := GetUserName;
  if Edit1.text = '' then
    SetFirstTime
  else
    SetNormal;
  docLeft := (width - (label1.Width+12+edit1.width)) div 2;
  DocTop := (height - (edit1.height+20+button2.Height)) div 2;
  Label1.Left := DocLeft;
  Edit1.Left := label1.left+label1.width+12;
  edit1.top := doctop;
  label1.top := doctop+((edit1.height-label1.height) div 2);
  button1.top := edit1.top+edit1.height+20;
  button1.left := edit1.left+edit1.width-button1.width;
  button2.top := button1.top;
  button2.left := button1.left - 6 - button2.width;
end;

procedure TfrmSettings.Button2Click(Sender: TObject);
begin
    close;
  frmSplash.pnlStart.BringToFront;
end;

procedure TfrmSettings.Edit1Change(Sender: TObject);
begin
  if Trim(Edit1.text) = '' then
    Button1.enabled := false
  else
    button1.enabled := true;
end;

procedure TfrmSettings.Edit1KeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['A'..'Z', 'a'..'z', #8, ' ', '.']) then
    key := #0;
end;

procedure TfrmSettings.Button1Click(Sender: TObject);
begin
  if trim(edit1.text) = '' then
    exit;
  WriteUserName(Edit1.text);
  aTeacherName := edit1.text;
  Close;
  frmSplash.pnlStart.BringToFront;
end;

procedure TfrmSettings.CreateNewIni;
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath+'preferences.ini');
  a.WriteString('General','UserName','');
  a.Free;
end;

function TfrmSettings.GetUserName: string;
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath+'preferences.ini');
  try
    result := a.ReadString('General','UserName','');
  except
    CreateNewIni;
    result := '';
  end;
  a.Free;
end;

procedure TfrmSettings.WriteUserName(AName: string);
var
  a: TIniFile;
begin
  a := TIniFile.Create(AppPath+'preferences.ini');
  a.WriteString('General','UserName',AName);
  a.Free;
end;

end.

