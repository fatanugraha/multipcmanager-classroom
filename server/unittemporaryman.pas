unit unittemporaryman;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil;

type
  TTemporaryFileInfo= record
    FileName: string;
    Deleted: boolean;
  end;

  TTemporaryManager = class(TObject)
    FFileDir: string;
    FFileList: array of TTemporaryFileInfo;
  public
    constructor Create(TemporaryDir: string);
    procedure AddFile(FileName: string);
    procedure DeleteTemporaryFiles;
    destructor Destroy; override;
  end;

implementation

constructor TTemporaryManager.Create(TemporaryDir: string);
begin
  inherited Create;
  FFileDir := IncludeTrailingBackslash(TemporaryDir);
end;

procedure TTemporaryManager.AddFile(FileName: string);
var
  idx: integer;
begin
  idx := Length(FFileList);
  SetLength(FFileList, idx+1);
  FFileList[idx].FileName := filename;
  FFileList[idx].Deleted := false;
end;

procedure TTemporaryManager.DeleteTemporaryFiles;
var
  i: integer;
begin
  for i := 0 to high(FFileList) do begin
    if FFileList[i].Deleted then continue;
    try
      if FileExistsUTF8(FFileDir+FFileList[i].FileName) then
        DeleteFile(FFileDir+FFileList[i].FileName);
      FFileList[i].deleted := true;
    except
      FFileList[i].deleted := false;
    end;
  end;
  try
  rmDir(ExcludeTrailingBackslash(FFileDir));
  except
  end;
end;

destructor TTemporaryManager.Destroy;
begin
  inherited Destroy;
  SetLength(FFileList, 0);
end;

end.

