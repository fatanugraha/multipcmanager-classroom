unit formAddVote;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls, LCLType,
  StdCtrls, ExtCtrls;

type

  { TfrmAddVote }

  TfrmAddVote = class(TForm)
    Bevel1: TBevel;
    btnAdd: TButton;
    Button2: TButton;
    Button3: TButton;
    btnRemove: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;

    Label4: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAddVote: TfrmAddVote;

implementation

{$R *.lfm}

uses
  FormMain, unitDatabase, unitglobal;

{ TfrmAddVote }

procedure TfrmAddVote.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmAddVote.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=vk_return then
    btnadd.click;
end;

procedure TfrmAddVote.FormShow(Sender: TObject);
begin
  Edit2.Text := '';
  Memo1.Text := '';
  Edit1.Text := '';
  edit1.top := ListBox1.Top+listbox1.height+6;
  btnRemove.top := edit1.top;
  btnadd.top := edit1.top;
  btnRemove.height := edit1.height;
  btnadd.height := edit1.height;
  ListBox1.Clear;
end;

procedure TfrmAddVote.ListBox1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex = -1 then begin
    btnRemove.Visible := false;
    Edit1.Left := 15;
    Edit1.Width := btnAdd.Left-13-6;
  end else begin
    btnRemove.Visible := true;
    Edit1.left := btnRemove.left+btnRemove.Width+6;
    Edit1.Width := btnAdd.Left-13 -12 - btnRemove.Width;
  end;
end;

procedure TfrmAddVote.Button2Click(Sender: TObject);
var
  i: integer;
begin
  if Listbox1.Items.Count = 0 then
    exit;
  if (Edit2.Text = '') or (Memo1.Text = '') then
    exit;

  SetLength(VoteData, Length(VoteData)+1);
  with VoteData[High(VoteData)] do begin
    Title:= Edit2.Text;
    Desc := Memo1.TExt;
    Submision := 0;
    SetLength(Data, ListBox1.Items.Count);
    for i := 0 to Listbox1.items.count-1 do begin
      Data[i].Value := Listbox1.Items[i];
      Data[i].Total:= 0;
    end;
    SetLength(DoneId, 0);
  end;

  frmMain.imgVoteClick(frmMain.imgVote);
  Close;
end;

procedure TfrmAddVote.btnAddClick(Sender: TObject);
begin
  if listbox1.items.Count = 10 then
  begin
    msgbox('Maksimum item hanya 10.', 'Pemberitahuan', MB_ICONINFORMATION);
    exit;
  end;
  if trim(edit1.text) <> '' then
    if Listbox1.Items.IndexOf(trim(edit1.text)) = -1 then
      listbox1.items.add(edit1.text);
  edit1.text := '';
end;

procedure TfrmAddVote.btnRemoveClick(Sender: TObject);
begin
  if Listbox1.ITemIndex <> -1 then begin
    ListBox1.Items.Delete(Listbox1.ITemIndex);
    Listbox1.itemindex := -1;
    ListBox1Click(nil);
  end;
end;

end.

