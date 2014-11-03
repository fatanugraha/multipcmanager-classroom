unit unitthreadsync;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdSync, Forms, unitdebug, ExtCtrls, LCLType, LCLIntf, Graphics;

type
  TSync = class(TIdSync)
  protected
    procedure DoSynchronize; override;
  public
    procSwitch: string;
    procParams: array of string;
    procParamsAux: array of pointer;
  end;

procedure CreateSync(var ASync: TSync; ProcName: string; ParamsCount: integer; ParamsAuxCount: integer = 0);
procedure DestroySync(var ASync: TSync);

implementation

uses
  FormMain, UnitGlobal;

procedure TSync.DoSynchronize;
var
  ScreenDC: HDC;
  a: TJpegImage;
begin
  with frmMain do begin
    if procswitch = 'capture' then begin
      screendc := LCLIntf.GetDC(0);
      a := TJpegImage.Create;
      a.CompressionQuality := 40;
      a.LoadFromDevice(screendc);
      TMemoryStream(ProcParamsAUX[0]^).Clear;
      a.SaveToStream(TMemoryStream(ProcParamsAUX[0]^));
      a.Free;
      releasedc(0, screendc);
    end else
    if procswitch = 'Message' then
    begin
      with FrmMain do
      begin
        mmChatLog.Lines.Add('Pengajar:');
        mmChatLog.Lines.add(procparams[0]);
        mmChatLog.Lines.Add('');
        if lblselected.Left <> imgMessaging.Left then
        begin
          lblNew.Left := imgMessaging.Left;
          lblNew.Width := imgMessaging.Width;
          NewMessage := true;
          TrayMsg('Pesan Baru', 'Anda mendapat pesan baru dari pengajar.', bfInfo);
        end;
      end;
    end;
  end;
end;

procedure CreateSync(var ASync: TSync; ProcName: string; ParamsCount: integer; ParamsAuxCount: integer = 0);
begin
  Async := TSync.Create;
  SetLength(ASync.ProcParams, ParamsCount);
  SetLength(ASync.procParamsAux, ParamsAuxCount);
  ASync.procSwitch := procname;
end;

procedure DestroySync(var ASync: TSync);
begin
  ASync.Free;
end;

end.