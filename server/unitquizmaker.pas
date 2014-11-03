unit unitquizmaker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, ExtCtrls, Controls, Graphics, Forms, ExtDlgs, Dialogs, unitdebug;

type
  TComponentChoiceRec = record
    Image: TImage;
    PictureAv: boolean;
    Button: TButton;
    Memo: TMemo;
    EditArr: array of TEdit;
    EditCover: array of TLabel;
    Panel: TPanel;
    LblArr: array of TLabel;
    LblNumber: TLabel;
    PnlNumber: TPanel;
  end;

  TFileInfo = record
    Date: string;
    Time: string;
    FileName, variant, Version, Creator: string;
  end;

  TComponentEssayRec = record
    Image: TImage;
    lblNumber: TLabel;
    pnlNumber: TPanel;
    Panel: TPanel;
    Button: TButton;
    Memo: TMemo;
    PictureAv: boolean;
  end;

  TRefPnl = ^TScrollBox;

  TComponentChoice = array of TComponentChoiceRec;
  TComponentEssay = array of TComponentEssayRec;

  TQuizChoice = record
    Question: TStrings;
    PictureStream: TStream;
    Choices: array of string;
  end;

  TQuizEssay = record
    Question: TStrings;
    PictureStream: TStream;
  end;

  TQuizMaker = class(TObject)
  protected
    FWait: TPanel;
    FComponentChoiceArr: TComponentChoice;
    FComponentEssayArr: TComponentEssay;
    FParent: TRefPnl;
    FChoicesCount: integer;
    FChoicesQuiz: integer;
    FEssayQuiz: integer;
    FChanged: boolean;
    FRandom: boolean;
    FMaxChars: integer;
    FBookMark: TPanel;
    FImporting: boolean;
    FInit: boolean;
  const
    MemoH = 122;
    {$IFDEF WINDOWS}
    EditH = 23;
    {$ENDIF}
    {$IFDEF LINUX}
    EditH = 33;
    {$ENDIF}
    Margin = 10;
  private
    function GetChoicePanelHeight(Choices: integer): integer;
    function GetEssayPanelHeight: integer;
    procedure ButtonClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure EditCoverMouseEnter(Sender: TObject);
    procedure EditCoverMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure EditCoverMouseLeave(Sender: TObject);
  public
    constructor Create(Parent: TRefPnl; QChoice, QEssay, QChoicesCount: integer; Import: boolean = False);
    property HasChanged: boolean read FChanged write FChanged;
    property MaxChars: integer read FMaxChars;
    property Random: boolean read FRandom;
    property SetInit: boolean write FInit;
    property ChoicesComponent: TComponentChoice read FComponentChoiceArr write FComponentChoiceArr;
    property Parent: TRefPnl read FParent;
    property EssaysComponent: TComponentEssay read FComponentEssayArr write FComponentEssayArr;
    property QuizChoicesCount: integer read FChoicesQuiz write FChoicesQuiz;
    property ChoicesCount: integer read FChoicesCount write FChoicesCount;
    property QuizEssayCount: integer read FEssayQuiz write FEssayQuiz;
    procedure Repaint;
    procedure ImportBegin;
    procedure ImportEnd;
    destructor Destroy; override;
  end;

implementation

procedure TQuizMaker.EditCoverMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  i, j: integer;
  tmp: string;
begin
  tmp := copy(TLabel(Sender).Name, 8, Length(TLabel(Sender).Name) - 7);
  i := StrToInt(copy(tmp, 1, pos('_', tmp) - 1)) - 1;
  j := StrToInt(copy(tmp, pos('_', tmp) + 1, length(tmp) - pos('_', tmp))) - 1;
  ChoicesComponent[i].EditArr[j].Visible := True;
  ChoicesComponent[i].EditArr[j].SetFocus;
  ChoicesComponent[i].EditCover[j].Visible := False;
end;

procedure TQuizMaker.EditExit(Sender: TObject);
var
  i, j: integer;
  tmp: string;
begin
  tmp := copy(TLabel(Sender).Name, 7, Length(TLabel(Sender).Name) - 6);
  i := StrToInt(copy(tmp, 1, pos('_', tmp) - 1)) - 1;
  j := StrToInt(copy(tmp, pos('_', tmp) + 1, length(tmp) - pos('_', tmp))) - 1;
  ChoicesComponent[i].EditArr[j].Visible := False;
  ChoicesComponent[i].EditCover[j].Visible := True;
  if ChoicesComponent[i].EditArr[j].Caption = '' then
  begin
    ChoicesComponent[i].EditCover[j].Caption := '  klik untuk mengubah isi...';
    ChoicesComponent[i].EditCover[j].Font.Style := [fsItalic];
  end;
end;

procedure TQuizMaker.EditChange(Sender: TObject);
var
  i, j: integer;
  tmp: string;
begin
  if not FInit then
  begin
    tmp := copy(TLabel(Sender).Name, 7, Length(TLabel(Sender).Name) - 6);
    i := StrToInt(copy(tmp, 1, pos('_', tmp) - 1)) - 1;
    j := StrToInt(copy(tmp, pos('_', tmp) + 1, length(tmp) - pos('_', tmp))) - 1;
    if ChoicesComponent[i].EditArr[j].Text = '' then
      ChoicesComponent[i].EditCover[j].Font.Style := [fsItalic]
    else
      ChoicesComponent[i].EditCover[j].Font.Style := [];
    ChoicesComponent[i].EditCover[j].Caption := '  ' + ChoicesComponent[i].EditArr[j].Text;
    FChanged := True;
  end;
end;

procedure TQuizMaker.EditCoverMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Color := $4B4B4B;
  TLabel(Sender).Transparent := False;
end;

procedure TQuizMaker.EditCoverMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Transparent := True;
end;

procedure TQuizMaker.MemoChange(Sender: TObject);
begin
  if not FInit then
    FChanged := True;
end;

procedure TQuizMaker.ButtonClick(Sender: TObject);
var
  dlg: TOpenPictureDialog;
  idx: integer;
begin
  idx := StrToInt(Copy(TButton(Sender).Name, 9, Length(TButton(Sender).Name) - 8)) - 1;

  if TButton(Sender).Caption <> 'Hapus Gambar' then
  begin
    dlg := TOpenPictureDialog.Create(FParent^.Parent.Parent);
    dlg.Filter := 'Tipe yang didukung (*.bmp;*.png;*.jpg;*.jpeg;*.jpe)|*.bmp;*.png;*.jpg;*.jpeg;*.jpe';
    if dlg.Execute then
    begin
      if TButton(Sender).Name[2] = 'E' then
      begin
        FComponentEssayArr[idx].Image.Picture.LoadFromFile(dlg.fileName);
        FComponentEssayArr[idx].PictureAV := True;
      end
      else
      begin
        FComponentChoiceArr[idx].Image.Picture.LoadFromFile(dlg.fileName);
        FComponentChoiceArr[idx].PictureAV := True;
      end;
      TButton(Sender).Caption := 'Hapus Gambar';
      FChanged := True;
    end;
    dlg.Free;
  end
  else
  begin
    if TButton(Sender).Name[2] = 'E' then
    begin
      FComponentEssayArr[idx].Image.Picture.Clear;
      FComponentEssayArr[idx].PictureAV := False;
      FChanged := True;
    end
    else
    begin
      FComponentChoiceArr[idx].Image.Picture.Clear;
      FComponentChoiceArr[idx].PictureAV := False;
      FChanged := True;
    end;
    TButton(Sender).Caption := 'Tambahkan Gambar';
  end;
end;

procedure TQuizMaker.ImportBegin;
begin
  Fwait.Visible := True;
  FWait.BringTOFront;
  FWait.Caption := 'Mengimpor data dari berkas ...';
  Fparent^.Update;
  SetInit := True;
end;

procedure TQuizMaker.ImportEnd;
begin
  FWait.Visible := False;
  Fparent^.Update;
  SetInit := False;
end;

constructor TQuizMaker.Create(Parent: TRefPnl; QChoice, QEssay, QChoicesCount: integer; Import: boolean = False);
var
  i, j: integer;
begin
  FWait := TPanel.Create(Parent^);
  Fwait.Name := '_FWait';
  FWait.Parent := Parent^;
  FWait.Align := alClient;
  FWait.BevelOuter := bvNone;
  Fwait.Font.Color := clWhite;
  FWait.BringToFront;
  FWait.Font.Size := 10;
  FImporting := Import;
  FParent := Parent;
  if not Import then
    FWait.Caption := 'Sedang membuat komponen [0/' + IntToStr(QEssay + QChoice) + '] ...'
  else begin
    ImportBegin;
    FWait.Caption := 'Mengimpor data dari berkas ...'
  end;
  Parent^.Update;
  FInit := True;
  FChoicesQuiz := QChoice;
  FEssayQuiz := QEssay;
  FParent^.VertScrollBar.Visible := False;
  FChoicesCount := QChoicesCount;
  SetLength(FComponentChoiceArr, QChoice);
  SetLength(FComponentEssayArr, QEssay);
  for i := 0 to QChoice - 1 do
  begin
    if not import then
      FWait.Caption := 'Sedang membuat komponen [' + IntToStr(i + 1) + '/' + IntToStr(QEssay + QChoice) + '] ...';
    Parent^.Update;
    with FComponentChoiceArr[i] do
    begin
      PictureAv := False;
      Panel := TPanel.Create(FParent^);
      Panel.Parent := FParent^;
      Panel.Name := TComponentName('_CPanel' + IntToStr(i + 1));
      FWait.BringToFront;
      Parent^.Update;
      Image := TImage.Create(Panel);
      Image.Name := TComponentName('_CImage' + IntToStr(i + 1));
      Image.Parent := Panel;
      Image.Stretch := True;
      Button := TButton.Create(Panel);
      Button.Name := TComponentName('_CButton' + IntToStr(i + 1));
      Button.Parent := Panel;
      Button.OnClick := @ButtonClick;
      Memo := TMemo.Create(Panel);
      Memo.Name := TComponentName('_CMemo' + IntToStr(i + 1));
      Memo.Parent := Panel;
      Memo.OnChange := @MemoChange;
      SetLength(EditArr, QChoicesCount);
      SetLength(LblArr, QChoicesCount);
      SetLength(EditCover, QChoicesCount);
      for j := 0 to QChoicesCount - 1 do
      begin
        EditArr[j] := TEdit.Create(panel);
        editArr[j].Name := TComponentName('_CEdit' + IntToStr(i + 1) + '_' + IntToStr(j + 1));
        LblArr[j] := TLabel.Create(panel);
        LblArr[j].Name := TComponentName('_CLabel' + IntToStr(i + 1) + '_' + IntToStr(j + 1));
        LblArr[j].Parent := Panel;
        EditArr[j].Parent := Panel;
        EditArr[j].OnExit := @EditExit;
        EditArr[j].OnChange := @EditChange;
        EditArr[j].Visible := False;
        EditCover[j] := TLabel.Create(panel);
        EditCover[j].Parent := panel;
        EditCover[j].Name := TComponentName('_CCover' + IntToStr(i + 1) + '_' + IntToStr(j + 1));
        EditCover[j].Font.Color := $CECECE;
        EditCover[j].AutoSize := False;
        EditCover[j].Height := EditArr[j].Height;
        EditCover[j].Layout := tlCenter;
        EditCover[j].Caption := '  klik untuk mengubah isi...';
        EditCover[j].Font.Style := [fsItalic];
        EditCover[j].Cursor := crIBeam;
        EditCover[j].OnMouseEnter := @EditCoverMouseEnter;
        EditCover[j].OnMouseLeave := @EditCoverMouseLeave;
        EditCover[j].OnMouseDown := @EditCoverMouseDown;
      end;
      PnlNumber := TPanel.Create(Panel);
      PnlNumber.Name := TComponentName('_CAPanel' + IntToStr(i + 1));
      pnlNumber.Parent := Panel;
      LblNumber := TLabel.Create(pnlNumber);
      LblNumber.Name := TComponentName('_CALabel' + IntToStr(i + 1));
      LblNumber.Parent := pnlNumber;
    end;
  end;

  for i := 0 to QEssay - 1 do
  begin
    if not import then
    FWait.Caption := 'Sedang membuat komponen [' + IntToStr(QChoice + i + 1) + '/' + IntToStr(QEssay + QChoice) + '] ...';
    Parent^.Update;
    with FComponentEssayArr[i] do
    begin
      Panel := TPanel.Create(FParent^);
      Panel.Name := TComponentName('_EPanel' + IntToStr(i + 1));
      Panel.Parent := FParent^;
      Fwait.BringToFront;
      Parent^.Update;
      Image := TImage.Create(Panel);
      Image.Name := TComponentName('_EImage' + IntToStr(i + 1));
      Image.Parent := Panel;
      Button := TButton.Create(Panel);
      Button.Parent := Panel;
      Button.OnClick := @ButtonClick;
      Button.Name := TComponentName('_EButton' + IntToStr(i + 1));
      Memo := TMemo.Create(Panel);
      Memo.Parent := Panel;
      Memo.Name := TComponentName('_EMemo' + IntToStr(i + 1));
      PnlNumber := TPanel.Create(Panel);
      PnlNumber.Parent := Panel;
      pnlNumber.Name := TComponentName('_EAPanel' + IntToStr(i + 1));
      LblNumber := TLabel.Create(pnlNumber);
      lblNumber.Parent := pnlNumber;
      lblNumber.Name := TComponentName('_EALabel' + IntToStr(i + 1));
    end;
  end;
  FBookMark := TPanel.Create(FParent^);
  FBookMark.Parent := FParent^;
  FBookMark.Name := '_QBookMark';
  fbookmark.BevelOuter := bvNone;
  Fbookmark.Caption := '';
  FBookMark.Width := 10;
  FBookMark.Height := 10;
  FBookMark.Visible := True;
  FParent^.VertScrollBar.Visible := True;
  FInit := False;
  if not import then
  FWait.Visible := False;
end;

destructor TQuizMaker.Destroy;
var
  i, j: integer;
begin
  inherited;
  Fwait.Free;
  for i := 0 to High(FComponentChoiceArr) do
  begin
    with FComponentChoiceArr[i] do
    begin
      Image.Free;
      Button.Free;
      Memo.Free;
      LblNumber.Free;
      for j := 0 to FChoicesCount - 1 do
      begin
        EditArr[j].Free;
        LblArr[j].Free;
      end;
      PnlNumber.Free;
      Panel.Free;
    end;
  end;
  for i := 0 to High(FComponentEssayArr) do
  begin
    with FComponentEssayArr[i] do
    begin
      Image.Free;
      LblNumber.Free;
      Memo.Free;
      PnlNumber.Free;
      Panel.Free;
    end;
  end;
  FBookMark.Free;
  SetLength(FComponentChoiceArr, 0);
  SetLength(FComponentEssayArr, 0);
end;

function TQuizMaker.GetChoicePanelHeight(Choices: integer): integer;
begin
  Result := ((Choices + 2) * Margin) + Choices * EditH + MemoH;
end;

function TQuizMaker.GetEssayPanelHeight: integer;
begin
  Result := (2 * Margin) + MemoH;
end;

procedure TQuizMaker.Repaint;
var
  pnlWidth, pnlHeight, pnlHeight1, i, j: integer;
begin
  FWait.Visible := True;
  FWait.BringToFront;
  Parent^.Update;
  Finit := True;
  FParent^.AutoScroll := False;
  FParent^.VertScrollBar.Visible := False;
  pnlWidth := FParent^.Parent.Width - (2 * Margin){ - 17};
  pnlHeight := GetChoicePanelHeight(FChoicesCount);
  for i := 0 to FChoicesQuiz - 1 do
  begin
    if not Fimporting then
    FWait.Caption := 'Sedang melukis ulang [' + IntToStr(i + 1) + '/' + IntToStr(FEssayQuiz + FChoicesQuiz) + '] ...';
    Parent^.Update;
    with FComponentChoiceArr[i] do
    begin
      with Panel do
      begin
        Left := Margin;
        Top := (pnlHeight * i) + ((i + 1) * Margin);
        Height := pnlHeight;
        Width := pnlWidth;
        Color := $373737;
        Anchors := [akTop, akLeft, akRight];
        Caption := '';
        BevelOuter := bvNone;
      end;
      with pnlNumber do
      begin
        Align := alLeft;
        Width := 32;
        Color := $001F1F1F;
        bevelOuter := bvNone;
        Caption := '';
      end;
      with lblNumber do
      begin
        AutoSize := False;
        Top := 12;
        Left := 0;
        Width := 32;
        Alignment := taCenter;
        Font.Color := clWhite;
        Caption := IntToStr(i + 1);
      end;
      with image do
      begin
        Left := 40;
        Top := Margin;
        Width := 120;
        Height := 120;
      end;
      with Memo do
      begin
        Left := Image.Left + Image.Width + Margin;
        top := Margin;
        Width := Panel.Width - Memo.Left - 8;
        Height := MemoH;
        Anchors := [akLeft, akRight, akTop];
        ScrollBars := ssVertical;
        Clear;
      end;
      with Button do
      begin
        left := Image.Left;
        Width := 120;
        Top := Margin + Image.Height - Height;
        Caption := 'Tambahkan Gambar';
      end;
      with LblArr[0] do
      begin
        Caption := 'Jawaban:';
        top := 2 * Margin + MemoH + 4;
        Left := Memo.left - Margin - Width;
        Font.Color := clWhite;
      end;
      for j := 0 to FChoicesCount - 1 do
      begin
        with EditArr[j] do
        begin
          Top := (Margin * (j + 2)) + MemoH + (j * editH);
          Left := Memo.Left;
          Text := '';
          Anchors := [akLeft, akRight, aktop];
          Width := Memo.Width;
        end;
        with EditCover[j] do
        begin
          Top := (Margin * (j + 2)) + MemoH + (j * editH);
          Left := Memo.Left;
          Anchors := [akLeft, akRight, aktop];
          Width := Memo.Width;
          BringToFront;
        end;
        if j = 0 then
          continue;
        with LblArr[j] do
        begin
          FOnt.color := clWhite;
          Caption := 'Pilihan ke-' + IntToStr(j) + ':';
          Top := EditArr[j].Top + 4;
          Left := EditArr[j].left - Margin - Width;
        end;
      end;
    end;
  end;

  pnlHeight1 := GetEssayPanelHeight;
  for i := 0 to FEssayQuiz - 1 do
  begin
    if not Fimporting then
    FWait.Caption := 'Sedang melukis ulang [' + IntToStr(FChoicesQuiz + i + 1) + '/' + IntToStr(FEssayQuiz + FChoicesQuiz) + '] ...';
    Parent^.Update;
    with FComponentEssayArr[i] do
    begin
      with Panel do
      begin
        left := Margin;
        top := ((FChoicesQuiz + (i + 1)) * Margin) + (FChoicesQuiz * pnlHeight) + (i * pnlHeight1);
        Width := pnlWidth;
        Height := pnlHeight1;
        Color := $373737;
        Anchors := [akTop, akLeft, akRight];
        Caption := '';
        BevelOuter := bvNone;
      end;
      with pnlNumber do
      begin
        Align := alLeft;
        Width := 32;
        Color := $001F1F1F;
        BevelOuter := bvNone;
        Caption := '';
      end;
      with lblNumber do
      begin
        AutoSize := False;
        Top := 12;
        Left := 0;
        Width := 32;
        Alignment := taCenter;
        Font.Color := clWhite;
        Caption := IntToStr(FChoicesQuiz + i + 1);
      end;
      with image do
      begin
        Left := 40;
        Top := Margin;
        Width := 120;
        Height := 120;
      end;
      with Memo do
      begin
        Left := Image.Left + Image.Width + 8;
        top := Margin;
        Width := Panel.Width - Memo.Left - 8;
        Height := MemoH;
        Anchors := [akLeft, akRight, akTop];
        ScrollBars := ssVertical;
        Clear;
      end;
      with Button do
      begin
        left := 40;
        Width := 120;
        Top := Margin + Image.Height - Height;
        Caption := 'Tambahkan Gambar';
      end;
    end;
  end;
  if QuizEssayCount > 0 then
    FBookMark.Top := EssaysComponent[QuizEssayCount - 1].Panel.Top + EssaysComponent[QuizEssayCount - 1].Panel.Height
  else
    FBookMark.Top := ChoicesComponent[QuizChoicesCount - 1].Panel.Top + ChoicesComponent[QuizChoicesCount - 1].Panel.Height;
  FParent^.AutoScroll := True;
  FParent^.VertScrollBar.Visible := True;
  Finit := False;
  Fwait.BringToFront;
  FWait.Visible := False;
end;

end.