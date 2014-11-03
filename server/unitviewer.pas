unit unitviewer;

{$mode objfpc}{$H+}

interface

uses
  StdCtrls, Classes, SysUtils, ExtCtrls, Graphics, Dialogs, unitdebug;

type
  TRefPnl = ^TPanel;
  TimgArr = array of TImage;
  TLblArr = array of TLabel;

  TViewerAlign = (vaLeft, vaCenter, vaRight);

  TViewer = class(TObject)
  private
    ImgArray: array of TImage;
    LblArray: array of TLabel;
    FWMargin: integer;
    FHMargin: integer;
    FDocHMargin: integer;
    FDocWMargin: integer;
    FAmount: integer;
    FAlign: TViewerAlign;
    FImgW, FImgH: integer;
    FFontOpt: TFont;
    FLblMargin: integer;
    FContainer: TRefPnL;
    property Container: TRefPnl read FContainer write FContainer;
  public
    Removed: array of boolean;
    property Count: integer read FAmount;
    property MarginW: integer read FWMargin write FWMargin;
    property MarginLbl: integer read FLblMargin write FLblMargin;
    property MarginH: integer read FHMargin write FHMargin;
    property Height: integer read FImgH write FImgH;
    property DocMarginH: integer read FDocHMargin write FDocHMargin;
    property DocMarginW: integer read FDocWMargin write FDocWMargin;
    property Width: integer read FImgW write FImgW;
    property Font: TFont read FFontOpt;
    property ImgData: TImgArr read ImgArray;
    property LblData: TLblArr read LblArray;
    property Align: TViewerAlign read FAlign write FAlign;
    procedure Repaint;
    procedure Add(Caption: string);
    procedure Remove(index: integer);
    constructor Create(AContainer: TRefPnl);
    destructor Destroy; override;
  end;

implementation

procedure TViewer.Add(Caption: string);
var
  i: integer;
begin
  SetLength(removed, Length(ImgArray)+1);
  Removed[High(removed)] := false;
  SetLength(ImgArray, Length(ImgArray)+1);
  SetLength(LblArray, Length(LblArray)+1);
  i := High(LblArray);
  ImgArray[i] := TImage.Create(Container^);
  ImgArray[i].Parent := Container^;
  ImgArray[i].proportional := true;
  ImgArray[i].Center:= true;
  ImgArray[i].Width := FImgW;
  ImgArray[i].Height := FImgH;

  LblArray[i] := TLabel.Create(Container^);
  LblArray[i].Parent := Container^;
  LblArray[i].Visible := true;
  ImgArray[i].Visible := true;
  LblArray[i].Font := FFontOpt;
  LblArray[i].Caption := Caption;
  LblArray[i].AutoSize := false;
  LblArray[i].Width := FImgW;
  LblArray[i].Alignment := taCenter;

  Inc(FAmount);
  Repaint;
end;

procedure TViewer.Remove(index: integer);
begin
  LblArray[Index].Caption := '';
  ImgArray[Index].Picture.clear;

  removed[index] := true;
  Repaint;
end;

constructor TViewer.Create(AContainer: TRefPnl);
var
  i: integer;
begin
  inherited Create;
  SetLength(ImgArray, 0);
  SetLength(LblArray, 0);
  FAmount := 0;
  FFontOpt := TFont.Create;
  FContainer := AContainer;
end;

procedure TViewer.Repaint;
var
  k, y,x: integer;
  i: integer;
begin
  k := (Container^.Width div (FImgW+FWMargin)); //max image in a row
  FDocHMargin := (Container^.width - (k*(FImgW+FWMargin))) div 2;

  X := FDocHMargin;
  y := FDocWMargin;
  for i := 0 to High(ImgArray) do begin
    if Removed[i] then
      continue;

    ImgArray[i].Left := x;
    ImgArray[i].top := y;
    LblArray[i].left := x;
    LblArray[i].Top := y+FImgH+FLblMargin;

    if x+(2*FImgW)+FWMargin > Container^.Width then begin
      x := FDocHMargin;
      y := y+FImgH+(2*FLblMargin)+lblArray[i].Height;
    end else
      x := x+FImgW+FWMargin;
  end;
end;

destructor TViewer.Destroy;
var
  i: integer;
begin
  inherited Destroy;
  for i := 0 to High(ImgArray) do begin
    ImgArray[i].free;
    LblArray[i].free;
  end;
end;

end.


