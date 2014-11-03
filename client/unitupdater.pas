unit unitupdater;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdHTTP, FIleUtil, Forms, IdComponent;

type
  TResponseProc = procedure(const stream: TStream) of object;

  TGetResponse = class(TThread)
  private
    strm1: TSTringStream;
    strm2: TFileStream;
    FHttp: TIdHTTP;
    FUrl: string;
    FOnDone: TResponseProc;
    FOnError: TThreadMethod;
    FOnWork: TWorkEvent;
    FOnWorkBegin: TWorkBeginEvent;
    FFileName: string;
  protected
    procedure Done;
    procedure Execute; override;
  public
    constructor Create(Url: string; const OnDone: TResponseProc; const OnError: TThreadMethod; FileName: string = '');
    property OnWorkBegin: TWorkBeginEvent read FOnWorkBegin write FOnWorkBegin;
    property OnWork: TWorkEvent read FOnWork write FOnWork;
  end;


implementation

procedure TGetResponse.Done;
begin
  if FFileName = '' then
    FOnDone(strm1)
  else
    FOnDone(Strm2);
end;

procedure TGetResponse.Execute;
begin
  if Assigned(FOnWork) then
    FHttp.OnWork := FOnWork;

  if Assigned(FOnWorkBegin) then
    FHttp.OnWorkBegin := FOnWorkBegin;

  while not terminated do
  begin
    try
      if FFIleName = '' then begin
        strm1 := TStringStream.Create('');
        FHttp.Get(FUrl, Strm1);
      end
      else
      begin
        strm2 := TFileStream.Create(FFileName, fmCreate);
        FHttp.Get(FUrl, Strm2);
      end;
      Synchronize(@Done);
    except
      synchronize(FOnError);
    end;
    terminate;
  end;

  if FFileName = '' then
    strm1.free
  else
    strm2.free;

  FHttp.Free;
end;

constructor TGetResponse.Create(Url: string; const OnDone: TResponseProc; const OnError: TThreadMethod; FileName: string = '');
begin
  FHttp := TIdHTTP.Create(nil);
  FUrl := Url;
  FOnDone := OnDone;
  FOnError := OnError;
  FFileName := FileName;
  inherited Create(True);
end;

end.
