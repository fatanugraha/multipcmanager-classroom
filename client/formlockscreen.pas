unit FormLockScreen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, LCLIntf, LCLType,
  StdCtrls;

type

  { TfrmLockScreen }

  TfrmLockScreen = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    State: boolean;
    procedure Lock(Message: string);
    procedure Unlock;
  end;

var
  frmLockScreen: TfrmLockScreen;

implementation

{$R *.lfm}

procedure TfrmLockScreen.Button1Click(Sender: TObject);
begin
  unlock;
end;

procedure TfrmLockScreen.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := not state;
end;

procedure TfrmLockScreen.FormCreate(Sender: TObject);
begin
  State := false;
end;

procedure TfrmLockScreen.Timer1Timer(Sender: TObject);
begin
  frmLockScreen.BringToFront;
  SetFocus;
end;

procedure TfrmLockScreen.Lock(Message: string);
begin
  Show;
  state := true;
  panel1.Caption := Message;
  parent := nil;
  ParentWindow := GetDC(0);
  borderStyle := bsNone;
  Top := 0;
  Left := 0;
  Width := Screen.Width;
  Height := Screen.Height;
  WindowState := wsMaximized;
  FormStyle := fsSystemStayOnTop;
  timer1.enabled := true;
end;

procedure TfrmLockScreen.Unlock;
begin
  state := false;
  timer1.enabled := false;
  Close;
end;

end.
