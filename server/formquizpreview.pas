unit FormQuizPreview;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, unitQuizPreview, unitQuizFile, unitdebug;

type

  { TfrmQuizPreview }

  TfrmQuizPreview = class(TForm)
    ScrollBox1: TScrollBox;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ScrollBox1Click(Sender: TObject);
  private
    Initialised: boolean;
  public
    QuizPrev: TQuizPreview;
    procedure ShowPreview(var ASource: TQuizFile; reveal: boolean=false);
    procedure ClosePreview;
  end;

var
  frmQuizPreview: TfrmQuizPreview;

implementation

{$R *.lfm}

procedure TfrmQuizPreview.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ClosePreview;
end;

procedure TfrmQuizPreview.ScrollBox1Click(Sender: TObject);
begin

end;

procedure TfrmQuizPreview.Button1Click(Sender: TObject);
begin

end;

procedure TfrmQuizPreview.ShowPreview(var ASource: TQuizFile; reveal: boolean=false);
begin
  ScrollBox1.VertScrollBar.Visible := False;
  ScrollBox1.AutoScroll:=false;
  WindowState := wsMaximized;
  Show;
  QuizPrev := TQuizPreview.Create(@ASource, @ScrollBox1);
  QuizPrev.ShufflePlace:=ASource.Random;
  QuizPrev.ShuffleChoices:= true;
  initialised := true;
  QuizPrev.Draw(reveal);
end;

procedure TFrmQuizPreview.ClosePreview;
begin
  QuizPrev.Destroy;
  initialised := false;
end;

end.


