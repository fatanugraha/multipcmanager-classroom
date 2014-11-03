unit FormAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLIntf,
  ExtCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbllogo3enter: TLabel;
    lbllogo1enter: TLabel;
    lbllogo2enter: TLabel;
    Panel1: TPanel;
    anim: TTimer;
    anim1: TTimer;
    anim2: TTimer;
    procedure anim1Timer(Sender: TObject);
    procedure anim2Timer(Sender: TObject);
    procedure animTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label11MouseEnter(Sender: TObject);
    procedure Label11MouseLeave(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label16Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
  private
    counter: integer;
    phase: byte;
    current: byte;
    procedure SetStartShow;
  public
    procedure OpenAbout(version, build: String);
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

procedure TfrmAbout.OpenAbout(version, build: String);
begin
  Label3.Caption := version+' '+build;
  SetStartShow;
end;

procedure TfrmAbout.animTimer(Sender: TObject);
const
  elev = 100;
var
  tmp: integer;
begin
  if phase = 0 then
  begin
    anim.Enabled := False;
    phase := 1;
    sleep(500);
    anim.Enabled := True;
  end;
  tmp := StrToInt('$' + IntToHex(current, 2) + IntToHex(current, 2) + IntToHex(current, 2));
  if Current <> 255 then
  begin
    lbllogo1enter.font.color := tmp;
    lbllogo2enter.font.color := tmp;
    lbllogo3enter.font.color := tmp;
    Inc(Current, 5);
    update;
  end
  else begin
    anim.Enabled := False;
    anim1.enabled := true;
  end;
end;

procedure TfrmAbout.anim1Timer(Sender: TObject);
var
  tmp: integer;
begin
  tmp := StrToInt('$' + IntToHex(current, 2) + IntToHex(current, 2) + IntToHex(current, 2));
  if Current <> 75 then
  begin
    lbllogo1enter.font.color := tmp;
    lbllogo2enter.font.color := tmp;
    lbllogo3enter.font.color := tmp;
    dec(Current, 5);
    update;
  end
  else begin
    anim1.enabled := false;
    sleep(400);
    current := 80;
    panel1.visible := true;
    anim2.enabled := true;
  end;
end;

procedure TfrmAbout.anim2Timer(Sender: TObject);
const
  elev = 100;
var
  i, tmp: integer;
begin
  if phase = 0 then
  begin
    anim.Enabled := False;
    phase := 1;
    sleep(500);
    anim.Enabled := True;
  end;
  tmp := StrToInt('$' + IntToHex(current, 2) + IntToHex(current, 2) + IntToHex(current, 2));
  if Current <> 255 then
  begin
    for i := 1 to 19 do begin
      if (i = 8) or (i = 9) or (i = 13) or (i = 17) then continue;
      TLAbel(FindComponent('Label'+inttostr(i))).Font.Color := tmp;
    end;
    Inc(Current, 5);
    update;
  end
  else begin
    anim2.Enabled := False;
  end;
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  SetStartShow;
end;

procedure TfrmAbout.Label11Click(Sender: TObject);
begin
  OpenUrl('https://www.facebook.com/AlppinSaja');
end;

procedure TfrmAbout.Label11MouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Color := clBlue;
end;

procedure TfrmAbout.Label11MouseLeave(Sender: TObject);
begin
    TLabel(Sender).Font.Color := clWhite;
end;

procedure TfrmAbout.Label12Click(Sender: TObject);
begin
  OpenUrl('https://www.facebook.com/iyyan.fahsyah');
end;

procedure TfrmAbout.Label16Click(Sender: TObject);
begin
  OpenUrl('http://www.cybzlab.web.id');
end;

procedure TfrmAbout.Label18Click(Sender: TObject);
begin
  OpenUrl('https://www.facebook.com/adit.ramadhan');
end;

procedure TfrmAbout.SetStartShow;
var
  w: integer;
  i, docLeft, doctop: integer;
begin
  current := 80;
  counter := 0;
  phase := 0;
  w := lblLogo1Enter.Width+LblLogo2Enter.Width+LblLogo3Enter.Width;
  docleft := (Width - (w+15)) div 2;
  docTop := (Height - (lbllogo1enter.Height)) div 2;

  lbllogo1enter.top := doctop;
  lbllogo1enter.left := docleft;
  lbllogo2enter.top := doctop;
  lbllogo2enter.left := lbllogo1enter.left + lbllogo1enter.Width + 2;
  lbllogo3enter.top := doctop;
  lbllogo3enter.left := lbllogo2enter.left + lbllogo2enter.Width + 13;

  for i := 1 to 19 do begin
    if (i = 8) or (i = 9) or (i = 13) or (i = 17) then continue;
    TLAbel(FindComponent('Label'+inttostr(i))).Font.Color := $4f4f4f;
  end;
  lbllogo1enter.font.color := $4f4f4f;
  lbllogo2enter.font.color := $4f4f4f;
  lbllogo3enter.font.color := $4f4f4f;
  panel1.Font.Color := $4f4f4f;
  panel1.Visible := False;
  anim.Enabled := True;
end;

end.