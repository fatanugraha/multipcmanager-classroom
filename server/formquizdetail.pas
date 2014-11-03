unit formQuizDetail;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls;

type

  { TfrmQuizDetail }

  TfrmQuizDetail = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ListView1: TListView;
    ListView2: TListView;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { private declarations }
  public
    id: integer;
    procedure ShowData(index: integer);
  end;

var
  frmQuizDetail: TfrmQuizDetail;

implementation

{$R *.lfm}

uses
  UnitDatabase;

{ TfrmQuizDetail }

procedure TfrmQuizDetail.ShowData(index: integer);
var
  a: TListItem;
  i: integer;
  doneidx: array of boolean;
begin
  id := index;
  Label3.Caption := WorksData.Quiz[Index].Name;
  Memo1.Text := WorksData.Quiz[Index].Description;
  Label10.Caption := IntToStr(WorksData.Quiz[Index].Duration) + ' menit';
  Label5.Caption := IntToStr(Length(WorksData.Quiz[Index].QuizDoneId));
  ListView1.Clear;
  ListView2.Clear;
  SetLength(DoneIdx, Length(realtimedata));
  for i := 0 to High(DoneIdx) do
    DoneIdx[i] := False;
  for i := 0 to High(WorksData.Quiz[index].Quizdoneid) do
  begin
    a := ListView1.Items.Add;
    a.Caption := IntToStr(i + 1);
    a.SubItems.Add(RealtimeData[WorksData.Quiz[index].Quizdoneid[i]].Name);
    doneidx[WorksData.Quiz[index].Quizdoneid[i]] := True;
  end;
  for i := 0 to High(realtimeData) do
  begin
    if doneidx[i] then
      continue;

    a := ListView2.Items.Add;
    a.Caption := IntToStr(ListView2.Items.Count);
    a.Subitems.Add(RealtimeData[i].Name);
  end;
end;

procedure TfrmQuizDetail.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmQuizDetail.FormResize(Sender: TObject);
begin
  listview1.Width := (Memo1.Width - 12) div 2;
  Listview2.Width := ListView1.Width;
  ListView2.Left := Listview1.Left + Listview1.Width + 12;
  Label7.Left := ListView2.Left;
end;

end.
