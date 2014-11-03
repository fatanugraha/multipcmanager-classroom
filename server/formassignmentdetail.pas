unit formassignmentdetail;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, unitDebug;

type

  { TfrmAssignmentDetail }

  TfrmAssignmentDetail = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
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
  frmAssignmentDetail: TfrmAssignmentDetail;

implementation

{$R *.lfm}

uses FormMain, unitDatabase;

{ TfrmAssignmentDetail }

procedure TfrmAssignmentDetail.ShowData(index: integer);
var
  i: integer;
  a: TListItem;
  doneIdx: array of boolean;
begin
  id := index;
  Label3.Caption := WorksData.Assignment[Index].Name;
  Memo1.Text := WorksData.Assignment[Index].Description;
  Label11.Caption := WorksData.Assignment[Index].Directory;
  Label10.Caption := IntToStr(WorksData.Assignment[Index].SizeLimit)+' MB';
  Label5.Caption := IntToStr(Length(WorksData.Assignment[Index].DoneId));
  ListView1.Clear;
  ListView2.Clear;
  SetLength(DoneIdx, Length(realtimedata));
  for i := 0 to High(DoneIdx) do
    DoneIdx[i] := false;
  for i := 0 to High(WorksData.Assignment[index].doneid) do begin
    a := ListView1.Items.Add;
    a.Caption:= IntToSTr(i+1);
    a.SubItems.Add(RealtimeData[WorksData.Assignment[index].doneid[i]].Name);
    doneidx[WorksData.Assignment[index].doneid[i]] := true;
  end;
  for i := 0 to High(realtimeData) do begin
    if doneidx[i] then continue;

    a := ListView2.Items.Add;
    a.Caption := IntToStr(ListView2.Items.Count);
    a.Subitems.Add(RealtimeData[i].Name);

  end;
end;

procedure TfrmAssignmentDetail.FormResize(Sender: TObject);
begin
  listview1.Width := (Memo1.Width - 12) div 2;
  Listview2.Width := ListView1.Width;
  ListView2.Left := Listview1.Left+Listview1.Width+12;
  Label7.Left := ListView2.Left;
end;

procedure TfrmAssignmentDetail.Button1Click(Sender: TObject);
begin
  close;
end;

end.

