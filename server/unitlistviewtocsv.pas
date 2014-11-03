unit unitlistviewtocsv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls;

function ExportCSV(const ListView: TListView; FileName: string; Header: string): boolean;

implementation

function ExportCSV(const ListView: TListView; FileName: string; Header: string): boolean;
var
  List: TStringList;
  i,j: integer;
  tmp: string;
begin
  try
  List := TStringList.Create;
  List.Add(Header);
  List.Add('');
  tmp := '';
  for i := 0 to ListView.Columns.COunt-1 do
    tmp := tmp+ListView.Columns[i].Caption+',';
  SetLength(tmp, Length(tmp)-1);
  list.Add(tmp);
  for i := 0 to ListView.Items.Count-1 do
  begin
    tmp := ListView.Items[i].caption+',';
    for j := 0 to ListView.Items[i].SubItems.Count-1 do
      tmp:=tmp+ListView.Items[i].SubItems[j]+',';
    SetLength(tmp, Length(tmp)-1);
    List.Add(tmp);
  end;
  List.SaveToFile(FileName);
  List.Free;
  result := true;
  except
    result := false;
  end;
end;

end.

