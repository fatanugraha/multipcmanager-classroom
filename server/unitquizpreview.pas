unit unitquizpreview;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  unitQuizFile, unitdebug, Math;

type
  PQuizFile = ^TQuizFile;
  PScrollBox = ^TScrollBox;
  TStrArray = array of string;
  TIntArr = array of integer;

  TQuizPreviewChoice = record
    Panel: TPanel;
    NumberPnl: TPanel;
    NumberLbl: TLabel;
    Image: TImage;
    Question: TLabel;
    Choice: array of TLabel;
  end;

  TQuizPreviewEssay = record
    Panel: TPanel;
    NumberPnl: TPanel;
    NumberLbl: TLabel;
    Image: TImage;
    Question: TLabel;
    Answer: TMemo;
  end;

  TQuizAnswers = record
    Choices: array of integer;
    Essays: array of string;
  end;

  TQuizPreview = class(TObject)
  private
    FInfo: TPanel;
    FLblInfo1, FLblInfo2, FLblInfo3: TLabel;
    FRevealed: boolean;
    FAnswers: TQuizAnswers;
    FQuizFile: PQuizFile;
    FParent: PScrollBox;
    FChoices: array of TQuizPreviewChoice;
    FEssays: array of TQuizPreviewEssay;
    FBookmark: TPanel;
    FShuffle: boolean;
    FInitialised: boolean;
    FShuffleChoice: boolean;
  const
    Margin = 10;
    DocMargin = 20;
  private
    function GetAnswers: TQuizAnswers;
    procedure OnMemoEnter(Sender: TObject);
    procedure OnMemoExit(Sender: TObject);
    procedure OnLabelMouseEnter(Sender: TObject);
    procedure OnLabelMouseExit(Sender: TObject);
    procedure OnLabelClick(Sender: TObject);
  public
    constructor Create(QuizFile: PQuizFile; Parent: PScrollBox);
    destructor Destroy; override;
  public
    property ShufflePlace: boolean read FShuffle write FShuffle;
    property ShuffleChoices: boolean read FShuffleChoice write FShuffleChoice;
    property Answers: TQuizAnswers read GetAnswers;
  public
    procedure RevealAnswer(const Key: TIntArr; AnAnswers: TQuizAnswers);
    function CheckBlanks: TIntArr;
    procedure Draw(ShowRevealInfo: boolean=false);
  end;

implementation

uses
   unitglobal;

procedure TQuizPreview.RevealAnswer(const Key: TIntArr; AnAnswers: TQuizAnswers);
function InsertLB(const astring: string): string;
var
  i: integer;
begin
  for i := 1 to Length(Astring) do
    if (astring[i] = char(11)) or (astring[i] = char(14)) then
      result := result+char(ord(astring[i])-1)
    else
      result := result+astring[i];
end;

const
  color_ans = $1DE6B5;//green light
  color_sel_ans = $4cb122;
  color_def=$FFFFFF;
  color_sel=$404040;
var
  i, j: integer;
begin
  FRevealed := True;
  for i := 0 to High(AnAnswers.Choices) do
  begin
    for j := 0 to high(FChoices[i].Choice) do
      with FChoices[i].Choice[j] do
      begin
        if Key[i] = j then
          if AnAnswers.Choices[i] = j then
            color := color_sel_ans
          else
            color := color_ans
        else
          if AnAnswers.Choices[i] = j then begin
            color := color_sel;
            font.Color := clWhite;
          end
          else
            color := color_def;
      end;
  end;
  for i := 0 to High(FAnswers.Essays) do
  begin
    with FEssays[i].Answer do
    begin
      ReadOnly := True;
      Text := InsertLB(AnAnswers.Essays[i]);
      Font.Color:= clBlack;
      Font.Style:= [];
    end;
  end;
end;

function TQuizPreview.CheckBlanks: TIntArr;
var
  i: integer;
  tmp: TQuizAnswers;
begin
  tmp := Answers;
  for i := 0 to High(tmp.Choices) do
  begin
    if tmp.choices[i] = -1 then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[high(Result)] := i + 1;
    end;
  end;
  for i := 0 to High(tmp.Essays) do
  begin
    if trim(tmp.essays[i]) = '' then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[high(Result)] := High(tmp.Choices) + i + 1;
    end;
  end;
end;

procedure TQuizPreview.OnMemoExit(Sender: TObject);
begin
  if FRevealed then
    exit;
  if FInitialised then
    if TMemo(Sender).Text = '' then
    begin
      TMemo(Sender).Font.Color := clGray;
      TMemo(Sender).Font.Style := [fsItalic];
      TMemo(Sender).Text := 'klik untuk menjawab soal ini...';
    end;
end;

procedure TQuizPreview.OnMemoEnter(Sender: TObject);
begin
  if FRevealed then
    exit;
  if TMemo(Sender).Font.Color = clGray then
  begin
    TMemo(Sender).Font.Color := clBlack;
    TMemo(Sender).Font.Style := [];
    TMemo(Sender).Text := '';
  end;
end;

function TQuizPreview.GetAnswers: TQuizAnswers;
var
  i: integer;
begin
  for i := 0 to High(FEssays) do
    if FEssays[i].Answer.Font.Style <> [fsitalic] then
      FAnswers.Essays[i] := FEssays[i].Answer.Text
    else
      FAnswers.Essays[i] := '';
  Result := FAnswers;
end;

procedure TQuizPreview.OnLabelMouseEnter(Sender: TObject);
begin
  if FRevealed then
    exit;
  if TLabel(Sender).color <> $404040 then
    TLabel(Sender).Color := $CCCCCC;
end;

procedure TQuizPreview.OnLabelMouseExit(Sender: TObject);
begin
  if FRevealed then
    exit;
  if TLabel(Sender).color <> $404040 then
    TLabel(Sender).Color := $FFFFFF;
end;

procedure TQuizPreview.OnLabelClick(Sender: TObject);
var
  tmp: string;
  i, x, y: integer;
begin
  if FRevealed then exit;

  tmp := Copy(TLabel(Sender).Name, 16, Length(TLabel(Sender).Name) - 15);
  x := StrToInt(Copy(tmp, 1, Pos('_', tmp) - 1)) - 1;
  y := StrToInt(Copy(tmp, Pos('_', tmp) + 1, Length(tmp) - Pos('_', tmp))) - 1;

  TLabel(Sender).Color := $404040;
  TLabel(Sender).Font.Color := clWhite;
  FAnswers.Choices[x] := y;
  for i := 0 to High(FChoices[x].Choice) do
  begin
    if i <> y then
    begin
      FChoices[x].Choice[i].Color := $FFFFFF;
      FChoices[x].Choice[i].Font.Color := clBlack;
    end;
  end;
end;

procedure TQuizPreview.Draw(ShowRevealInfo: boolean=false);

  function CommonSeq(x: integer): TIntArr;
  var
    i: integer;
  begin
    SetLength(Result, X);
    for i := 0 to x - 1 do
      Result[i] := i;
  end;

  function RandomSeq(x: integer): TIntArr;
  var
    seq: TIntArr;
    i, tmp: integer;
  begin
    SetLength(Result, X);
    SetLength(Seq, X);
    for i := 0 to x - 1 do
      Seq[i] := i;
    for i := 0 to x - 1 do
    begin
      tmp := RandomFrom(Seq);
      while tmp = -1 do
        tmp := RandomFrom(Seq);
      Result[i] := tmp;
      seq[tmp] := -1;
    end;
  end;

const
  color_ans = $1DE6B5;//green light
  color_sel_ans = $4cb122;
  color_def=$FFFFFF;
      color_sel=$404040;
var
  Seq: TIntArr;
  Comparator: TMemo;
  fsStream: TMemoryStream;
  Height, i, j, y, x: integer;
  tidx, idx: array of integer;
begin
  // add cover here
  FParent^.VertScrollBar.Visible := False;
  FParent^.AutoScroll := False;
  y := 0;
  // info
  if ShowRevealInfo then begin
    FInfo := TPanel.Create(FParent^);
    FLblInfo1 := TLabel.Create(FInfo );
    FLblInfo2 := TLabel.Create(FInfo );
    FLblInfo3 := TLabel.Create(FInfo );
    with Finfo do begin
      name := '__info';
      color := clWhite;
      Left := DOcMargin;
      Caption := '';
      font.Color := clBlack;
      Height := 10*2+23*3+6*2;
      parent := FParent^;
      Width := FParent^.Width - 2*DocMargin;
      top := DocMargin;
      Anchors := [akleft, aktop, akright];
    end;
    with fLblInfo3 do begin
      Parent := FInfo;
      Transparent := false;
      Autosize:= false;
      Height := 23;
      width := Finfo.Width-2*Margin;
      Anchors := [akleft, aktop, akright];
      layout := tlCenter;
      Left := Margin;
      Name:= '__info1';
      Color := Color_sel_ans;
      Caption := '  Jawaban yang benar dan dipilih peserta didik';
      top := 10;
    end;
    with fLblInfo2 do begin
      Parent := FInfo;
      Transparent := false;
      Autosize:= false;
      Height := 23;
      width := Finfo.Width-2*Margin;
      Anchors := [akleft, aktop, akright];
      layout := tlCenter;
      Left := Margin;
      Name:= '__info2';
      Color := Color_ans;
      Caption := '  Jawaban yang benar';
      top := 10+23+6;
    end;
    with fLblInfo1 do begin
      Parent := FInfo;
      Transparent := false;
      Autosize:= false;
      Height := 23;
      width := Finfo.Width-2*Margin;
      Anchors := [akleft, aktop, akright];
      layout := tlCenter;
      Left := Margin;
      Name:= '__info3';
      Color := Color_sel;
      Font.Color := clWhite;
      Caption := '  Jawaban yang dipilih peserta didik';
      top := 10+23+6+23+6;
    end;
    y := FInfo.height+DocMargin;
  end;

  with Comparator do
  begin
    Comparator := TMemo.Create(nil);
    comparator.Parent := fparent^;
    comparator.ScrollBars := ssVertical;
    Comparator.font.size := 10;
    comparator.Height := 100;
    left := 0;
    top := 0;
    BorderStyle := bsNone;
    Width := FParent^.Width - 2 * Margin - 32;
    WordWrap := True;
  end;

  if FShuffle then
  begin
    SetLength(Idx, Length(FCHoices));
    SetLength(tIdx, Length(FCHoices));
    for i := 0 to High(FChoices) do
      tidx[i] := i;
    for i := 0 to High(FChoices) do
    begin
      j := -1;
      while j = -1 do
        j := RandomFrom(Tidx);
      idx[i] := j;
      tidx[j] := -1;
    end;
  end;

  if FShuffleChoice then
    Seq := RandomSeq(FQuizFile^.ChoicesCount)
  else
    Seq := CommonSeq(FQuizFile^.ChoicesCount);

  for i := 0 to High(FChoices) do
  begin
    if FShuffle then
      x := idx[i]
    else
      x := i;

    with FChoices[x] do
    begin
      Panel.Width := FParent^.Width - 2 * DocMargin;
      Panel.Left := DocMargin;
      Panel.Top := y + DocMargin;
      Panel.Anchors := [aktop, akRight, akLeft];
      Panel.Color := clWhite;
      Panel.Caption := '';

      NumberPnl.Width := 32;
      NumberPnl.Align := AlLeft;
      NumberPnl.Color := $1F1F1F;

      NumberLbl.Top := 14;
      NumberLbl.AutoSize := False;
      NumberLbl.Width := 32;
      NumberLbl.Left := 0;
      NumberLbl.Alignment := taCenter;
      NumberLbl.Font.Color := clWhite;
      NumberLbl.Caption := IntToStr(i + 1);

      Image.Top := Margin;
      Image.Left := Margin + NumberPnl.Width;
      Image.AutoSize := False;
      Image.Width := Panel.Width - NumberPnl.Width - 2 * margin;
      Image.Proportional := True;
      Image.Center := True;
      image.Anchors := [akTop, akLeft, akRight];

      if FQuizFile^.Choices[x].PictureStream.Size > 0 then
      begin
        fsStream := TmemoryStream.Create;
        FsStream.LoadFromStream(FQuizFile^.Choices[x].PictureStream);
        Image.Picture.LoadFromStream(FsStream);
        FsStream.Free;
        if Image.Picture.Graphic.Width > Image.Width then
          image.Height := (Image.Width * Image.Picture.Graphic.Height) div Image.Picture.Graphic.Width
        else
          Image.Height := Image.Picture.Graphic.Height;
      end
      else
        Image.Height := 0;

      Comparator.Lines.Text := FQuizFile^.Choices[x].Question.Text;

      Question.Top := Image.Top + Image.Height + Margin;
      Question.font.size := 10;
      Question.Height := 20 * Comparator.Lines.Count;//comparator.VertScrollBar.Range;
      Question.Width := Panel.Width - NumberPnl.Width - 2 * margin;
      Question.Caption := FQuizFile^.Choices[x].Question.Text;
      Question.Left := Margin + NumberPnl.Width;
      Question.Anchors := [aktop, akLeft, akRight];

      for j := 0 to High(Choice) do
      begin
        Choice[j].Left := Margin + NumberPnl.Width;
        choice[j].Top := Question.Height + Question.Top + margin + 6 * seq[j] + Choice[j].Height * seq[j];
        Choice[j].Width := Panel.Width - NumberPnl.Width - 2 * margin;
        Choice[j].Caption := ' ' + char(Ord('a') + seq[j]) + '. ' + FQuizFile^.Choices[x].Choices[j];
        Choice[j].Color := $FFFFFF;
        choice[j].Font.Color := clBlack;
        Choice[j].Anchors := [aktop, akleft, akRight];
        Choice[j].Cursor := crHandPoint;
      end;

      Height := 0;
      for j := 0 to High(seq) do
        if seq[j] > seq[Height] then
          Height := j;

      Panel.Height := Choice[Height].Top + Choice[Height].Height + Margin;
      y := Panel.top + Panel.Height;
    end;
  end;

  for i := 0 to High(FEssays) do
  begin
    with FEssays[i] do
    begin
      Panel.Width := FParent^.Width - 2 * DocMargin;
      Panel.Left := DocMargin;
      Panel.Top := y + DocMargin;
      Panel.Anchors := [aktop, akRight, akLeft];
      Panel.Color := clWhite;
      Panel.Caption := '';

      NumberPnl.Width := 32;
      NumberPnl.Align := AlLeft;
      NumberPnl.Color := $1F1F1F;

      NumberLbl.Top := 14;
      NumberLbl.AutoSize := False;
      NumberLbl.Width := 32;
      NumberLbl.Left := 0;
      NumberLbl.Alignment := taCenter;
      NumberLbl.Font.Color := clWhite;
      NumberLbl.Caption := IntToStr(i + length(FChoices) + 1);

      Image.Top := Margin;
      Image.Left := Margin + NumberPnl.Width;
      Image.AutoSize := False;
      Image.Width := Panel.Width - NumberPnl.Width - 2 * margin;
      Image.Proportional := True;
      Image.Center := True;
      image.Anchors := [akTop, akLeft, akRight];

      if FQuizFile^.Essays[i].PictureStream.Size > 0 then
      begin
        fsStream := TmemoryStream.Create;
        FsStream.LoadFromStream(FQuizFile^.Essays[i].PictureStream);
        Image.Picture.LoadFromStream(FsStream);
        FsStream.Free;
        if Image.Picture.Graphic.Width > Image.Width then
          image.Height := (Image.Width * Image.Picture.Graphic.Height) div Image.Picture.Graphic.Width
        else
          Image.Height := Image.Picture.Graphic.Height;
      end
      else
        Image.Height := 0;

      Comparator.Text := FQuizFile^.Essays[i].Question.Text;
      Comparator.font.size := 10;

      Question.Top := Image.Top + Image.Height + Margin;
      Question.font.size := 10;
      Question.Height := 20 * Comparator.Lines.Count;
      Question.Width := Panel.Width - NumberPnl.Width - 2 * margin;
      Question.Caption := FQuizFile^.Essays[i].Question.Text;
      Question.Left := Margin + NumberPnl.Width;
      Question.Anchors := [aktop, akLeft, akRight];

      Answer.Left := Margin + NumberPnl.Width;
      Answer.Top := Question.Height + Question.Top + margin;
      Answer.Width := Panel.Width - NumberPnl.Width - 2 * margin;
      Answer.Anchors := [aktop, akLeft, akRight];
      Answer.Height := 50;
      OnMemoExit(Answer);

      Panel.Height := Answer.Top + Answer.Height + Margin;
      y := Panel.top + Panel.Height;
    end;
  end;
  FParent^.VertScrollBar.Visible := True;
  FParent^.AutoScroll := True;

  Comparator.Free;
  FBookmark.Top := y + Docmargin;

  // remove cover here
end;

constructor TQuizPreview.Create(QuizFile: PQuizFile; Parent: PScrollBox);
var
  i, j: integer;
begin
  inherited Create;
  FRevealed := false;
  FInitialised := True;
  FQuizFile := QuizFile;
  FParent := Parent;
  Setlength(FChoices, Length(FQuizFile^.Choices));
  SetLength(FEssays, Length(FQuizFile^.Essays));
  for i := 0 to High(FQuizFile^.Choices) do
  begin
    with FChoices[i] do
    begin
      Panel := TPanel.Create(Parent^);
      Panel.Parent := Parent^;
      Panel.Name := 'Choice_panel_' + IntToStr(i + 1);
      Panel.BevelOuter := bvNone;

      NumberPnl := TPanel.Create(Panel);
      NumberPnl.Parent := Panel;
      NumberPnl.Name := 'Choice_numberpnl_' + IntToStr(i + 1);
      NumberPnl.Caption := '';
      NumberPnl.BevelOuter := bvNone;

      NumberLbl := TLabel.Create(NumberPnl);
      NumberLbl.Parent := NumberPnl;
      NumberLbl.Name := 'Choice_numberlbl_' + IntToStr(i + 1);

      Image := TImage.Create(Panel);
      Image.Parent := Panel;
      Image.Name := 'Choice_image_' + IntToStr(i + 1);

      Question := TLabel.Create(panel);
      Question.Parent := Panel;
      Question.Name := 'Choice_question_' + IntToStr(i + 1);
      Question.Autosize := False;
      Question.WordWrap := True;

      SetLength(Choice, FQuizFile^.ChoicesCount);
      for j := 0 to FQuizFile^.ChoicesCount - 1 do
      begin
        Choice[j] := TLabel.Create(Panel);
        Choice[j].Transparent := False;
        Choice[j].Parent := Panel;
        Choice[j].AutoSize := False;
        Choice[j].Layout := tlCenter;
        Choice[j].Name := 'Choice_choices_' + IntToStr(i + 1) + '_' + IntToStr(j + 1);
        Choice[j].Height := 23;
        Choice[j].OnClick := @OnLabelClick;
        Choice[j].OnMouseEnter := @OnLabelMouseEnter;
        Choice[j].OnMouseLeave := @OnLabelMouseExit;
      end;
    end;
  end;
  for i := 0 to High(FQuizFile^.Essays) do
  begin
    with FEssays[i] do
    begin
      Panel := TPanel.Create(Parent^);
      Panel.Parent := Parent^;
      Panel.Name := 'Essay_panel_' + IntToStr(i + 1);
      Panel.bevelOuter := bvNone;
      panel.Caption := '';

      NumberPnl := TPanel.Create(Panel);
      NumberPnl.Parent := Panel;
      NumberPnl.Name := 'Essay_numberpnl_' + IntToStr(i + 1);
      NumberPnl.Caption := '';
      NumberPnl.BevelOuter := bvNone;

      NumberLbl := TLabel.Create(NumberPnl);
      NumberLbl.Parent := NumberPnl;
      NumberLbl.Name := 'Essay_numberlbl_' + IntToStr(i + 1);

      Image := TImage.Create(Panel);
      Image.Parent := Panel;
      Image.Name := 'Essay_image_' + IntToStr(i + 1);

      Question := TLabel.Create(panel);
      Question.Parent := Panel;
      Question.Name := 'Essay_question_' + IntToStr(i + 1);
      Question.Autosize := False;
      Question.WordWrap := True;

      Answer := TMemo.Create(panel);
      Answer.Parent := panel;
      Answer.Name := 'Essay_Answer_' + IntToStr(i + 1);
      Answer.Caption := '';
      Answer.OnExit := @OnMemoExit;
      Answer.OnEnter := @OnMemoEnter;
    end;
  end;

  FBookmark := TPanel.Create(Parent^);
  Fbookmark.Name := 'Bookmark';
  FBookmark.Height := 0;
  FbookMark.Parent := Parent^;
  Fbookmark.Width := 10;
  FBookmark.BevelOuter := bvNone;

  SetLength(FAnswers.Choices, Length(FQuizFile^.Choices));
  SetLength(FAnswers.Essays, Length(FQuizFile^.Essays));
  for i := 0 to high(FAnswers.Choices) do
    FAnswers.Choices[i] := -1;
end;

destructor TQuizPreview.Destroy;
var
  i, j: integer;
begin
  FInitialised := False;
  if Assigned(FInfo) then begin
    FlblInfo1.Free;
    FlblInfo2.Free;
    FlblInfo3.Free;
    Finfo.Free;
  end;
  for i := 0 to High(FChoices) do
  begin
    with FChoices[i] do
    begin
      NumberLbl.Free;
      NumberPnl.Free;
      Image.Free;
      Question.Free;
      for j := 0 to High(Choice) do
        Choice[j].Free;
      SetLength(Choice, 0);
      Panel.Free;
    end;
  end;
  for i := 0 to High(FEssays) do
  begin
    with FEssays[i] do
    begin
      NumberLbl.Free;
      NumberPnl.Free;
      Image.Free;
      Question.Free;
      Answer.Free;
      Panel.Free;
    end;
  end;
  FBookmark.Free;
  Setlength(FChoices, 0);
  SetLength(FEssays, 0);
  inherited Destroy;
end;

end.
