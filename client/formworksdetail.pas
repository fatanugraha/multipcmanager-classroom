unit formworksdetail;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfrmworksdetail }

  Tfrmworksdetail = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblDesc: TLabel;
    lblExt: TLabel;
    lblName: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    switch: integer; //0=quiz; 1=assignment
    idx: integer;
  end;

var
  frmworksdetail: Tfrmworksdetail;

implementation

{$R *.lfm}

{ Tfrmworksdetail }

uses
  formMain;

procedure Tfrmworksdetail.Button1Click(Sender: TObject);
begin
  close;
end;

procedure Tfrmworksdetail.FormShow(Sender: TObject);
begin
  if switch = 1 then begin
    lblName.caption := frmMain.AssignInfo[idx].Name;
    lblDesc.caption := frmMain.AssignInfo[idx].Description;
    Label3.caption := 'Ekstensi berkas yang diterima:';
    lblExt.Left := label3.left+label3.width+6;
    lblExt.caption := frmMain.AssignInfo[idx].FileExt;
  end else begin
    lblName.caption := frmMain.QuizInfo[idx].Name;
    lblDesc.caption := frmMain.QuizInfo[idx].Description;
    Label3.caption := 'Durasi pengerjaan maksimum:';
    lblExt.Left := label3.left+label3.width+6;
    lblExt.caption := IntToStr(frmMain.QuizInfo[idx].Duration)+' menit';
  end;
end;

end.

