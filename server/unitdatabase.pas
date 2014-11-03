unit UnitDatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, unitQuizFile, unitQuizPreview;

type
  TIntArr= array of integer;

  TVoteDBSubRec = record
    Value: string;
    Total: Word;
  end;

  TVoteDBRec = record
    Title, Desc: string;
    Submision: integer;
    Data: array of TVoteDBSubRec;
    doneid: array of integer;
  end;

  TVoteDB = array of TVoteDBRec;

  TRealtimeDBQuizPoint = record
    Essay: integer;
    Choice: integer;
    //EssayAns: array of string;
  end;

  TRealtimeDBRec = record
    Name: string;
    IP: string;
    FormerIP: string; //if user left.
    AdditionalData, Msg: TStringList;
    NewData: boolean;
    Online: boolean;
    QuizPoints: array of TRealtimeDBQuizPoint;
    DoneAssign, DoneQuiz: array of integer;
    QuizAnswers: array of TQuizAnswers;
  end;

  TAssignmentDBRec = record
    Name, Description, FileExt: string;
    Directory: string;
    SizeLimit: int64;
    //Done: int64;
    DoneId: array of integer;
  end;

  TQuizDBRec = record
    QuizPath: string;
    Name, Description: string;
    Duration: int64;
    TotalChoice, TotalEssay: integer;
    ChoicePoint, EssayPoint: integer;
    QuizDoneId: array of integer;
    QuizAns: TIntArr;
    QuizData: TFileStream;
  end;

  TCommandsDB = array of boolean;

  TRealtimeDB = array of TRealtimeDBRec;

  TWorkDB = record
    Assignment: array of TAssignmentDBRec;
    Quiz: array of TQuizDBRec;
  end;

  TGroupDB = record
    created: boolean;
    Data: array of array of string; //person's name in TViewer
  end;

var
  CommandsData: TCommandsDB;
  RealtimeData: TRealtimeDB;
  WorksData: TWorkDB;
  VoteData: TVoteDB;
  GroupData: TGroupDB;

implementation

end.

