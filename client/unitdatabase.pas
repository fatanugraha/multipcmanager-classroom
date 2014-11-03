unit unitdatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TQuizDBRec = record
    Name, Description: string;
    Duration: int64;
    exec, done: boolean;
  end;

  TAssignDBRec = record
    Name, Description: string;
    FileExt: string;
    SizeLimit: int64;
    exec, done: boolean;
  end;

  TVoteDBRec = record
    Title, Desc: string;
    options: array of string;
    choice: integer;
  end;

  TQuizDB = array of TQuizDBRec;
  TAssignDB = array of TAssignDBRec;
  TVoteDB = array of TVoteDBrec;

implementation

end.

