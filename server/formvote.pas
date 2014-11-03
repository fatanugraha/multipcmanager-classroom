unit FormVote;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TAStyles, TASeries, TASources, Forms,
  unitdebug, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  TACustomSource, TALegendPanel, TACustomSeries;

type

  { TfrmVote }

  TfrmVote = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    Chart1: TChart;
    ListView1: TListView;
    Panel1: TPanel;
    PieChart: TPieSeries;
    Label1: TLabel;
    Source: TListChartSource;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1DrawItem(Sender: TCustomListView; AItem: TListItem; ARect: TRect; AState: TOwnerDrawState);
  private
    { private declarations }
  public

  end;

const
  colors: array [0..9] of string = ('$FFFFFF', '$7F7F7F', '$150088', '$241CED', '$277FFF', '$00F2FF',
    '$4CB122', '$E8A200', '$CC483F', '$A449A3');

var
  frmVote: TfrmVote;

implementation

{$R *.lfm}

uses
  FormMain, unitDatabase;

procedure TfrmVote.FormShow(Sender: TObject);
var
  tmp: string;
  i: integer;
  a: TListItem;
begin
  PieChart.Active := False;
  PieChart.Clear;
  listview1.Clear;
  Source.DataPoints.Clear;
  PieChart.ShowInLegend := True;
  for i := 0 to High(VoteData[frmMain.lvVote.ItemIndex].Data) do
  begin
    a := ListView1.Items.Add;
    a.Caption := VoteData[frmMain.lvVote.ItemIndex].Data[i].Value;
    a.SubItems.add(IntToStr(VoteData[frmMain.lvVote.ItemIndex].Data[i].Total));
    if VoteData[frmMain.lvVote.ItemIndex].Data[i].Total = 0 then
      continue;
    tmp := VoteData[frmMain.lvVote.ItemIndex].Data[i].Value + '|';
    tmp := tmp + IntToStr(VoteData[frmMain.lvVote.ItemIndex].Data[i].Total) + '|';
    tmp := tmp + colors[i] + '|' + VoteData[frmMain.lvVote.ItemIndex].Data[i].Value;
    Source.DataPoints.Add(tmp);
  end;
  if (VoteData[frmMain.lvVote.ItemIndex].submision <> frmMain.viewer.Count) then
  begin
    tmp := 'Abstain|';
    tmp := tmp + IntToStr(frmMain.Viewer.Count - VoteData[frmMain.lvVote.ItemIndex].submision) + '|';
    tmp := tmp + '$C3C3C3|Abstain';
    Source.DataPoints.Add(tmp);
  end;
  pieChart.Source := Source;
  PieChart.Active := True;
  chart1.Legend.Visible := True;
end;

procedure TfrmVote.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmVote.ListView1DrawItem(Sender: TCustomListView; AItem: TListItem; ARect: TRect;
  AState: TOwnerDrawState);
begin
  Brush.Color := StrToInt(colors[AItem.Index]);
end;

end.