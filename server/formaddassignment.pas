unit FormAddAssignment;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin;

type

  { TfrmAddAssignment }

  TfrmAddAssignment = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Memo1: TMemo;
    selDir: TSelectDirectoryDialog;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
  end;

var
  frmAddAssignment: TfrmAddAssignment;

implementation

{$R *.lfm}

uses
  unitGlobal, unitdatabase, formMain;

{ TfrmAddAssignment }

procedure TfrmAddAssignment.FormShow(Sender: TObject);
begin
  Label1.Caption := 'Tambahkan Tugas';
  Edit2.Text := '';
  Memo1.Text := '';
  Edit1.Text := AppPath + 'Berkas Tugas'+dirdelimiter;
  Combobox1.ItemIndex := 0;
  spinedit1.Value := 1;
  button3.Visible := True;
  edit1.Width := button3.Left - edit1.left - 6;
  button2.Visible := True;
  button1.Caption := 'Selesai';
  edit2.ReadOnly := False;
  memo1.ReadOnly := False;
  label6.left := spinedit1.left;
  button3.top := edit1.top;
  button3.Height := edit1.Height;
end;

procedure TfrmAddAssignment.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmAddAssignment.Button3Click(Sender: TObject);
begin
  if SelDir.Execute then
    edit1.Text := SelDir.FileName;
end;

procedure TfrmAddAssignment.Button1Click(Sender: TObject);
var
  tmp: integer;
begin
  if copy(edit1.text,1,2) = '\\' then
  begin
    msgBox('Tidak dapat menggunakan direktori yang berada di komputer lain/ini menggunakan jaringan ('+edit1.text+')', 'Kesalahan', 16);
    exit;
  end;
  if not checkext(Combobox1.Text) then
  begin
    msgBox('nama ekstensi tidak sahih. (' + combobox1.Text + ')', 'Kesalahan', 16);
    exit;
  end;
  if (edit2.Text = '') or (memo1.Text = '') or (combobox1.Text = '') then
  begin
    msgBox('masih terdapat field yang kosong.', 'Kesalahan', 16);
    exit;
  end;
  SetLength(WorksData.Assignment, Length(WorksData.Assignment) + 1);
  tmp := high(WorksData.Assignment);
  with WorksData.Assignment[tmp] do
  begin
    Name := edit2.Text;
    Description := Memo1.Text;
    Directory := edit1.Text;
    FileExt := combobox1.Text;
    SizeLimit := SpinEdit1.Value;
    SetLength(DoneId, 0);
  end;
  frmmain.ImgAssignmentClick(frmMain.imgAssignment);
  Close;
end;

end.
