unit unitquizfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, unitquizmaker, Controls, Graphics, Forms, Dialogs, Math, zipper, unitdebug, fileutil;

type
  TQuizChoiceAns = array of integer;

  TQuizFile = class(TObject)
    Choices: array of TQuizChoice;
    Essays: array of TQuizEssay;
    date, time: string; //month/day/year //hh:mm
    Random: boolean;
    MaxChar: integer;
    ChoicesQuiz, EssayQuiz, ChoicesCount: integer;
  const
    Version = '2.0';
  const
    FileType = 'multipcmanager classroom quiz file';
  const
    Publisher = 'multipcmanager classroom quiz maker';
  private
    procedure WriteHeader(var list: TStringList);
    procedure WriteData(var list: TStringList);
  public
    function RandomizeChoice: TQuizChoiceAns;
    procedure ImportFromQuizMaker(const AQuizMaker: TQuizMaker);
    procedure ExportToQuizMaker(var AQuizMaker: TQuizMaker; parent: TRefPnl);
    procedure LoadFromFile(FileName: string);
    procedure LoadFromStrings(const List: TStrings);
    procedure SaveToFile(FileName: string);
    procedure SaveToStrings(out AString: TStrings);
  end;

  PQuizFile = ^TQuizFile;

implementation

uses
  unitglobal;

function tab(depth: integer = 1): string;
begin
  Result := '';
  while depth > 0 do
  begin
    Result := Result + #9;
    Dec(depth);
  end;
end;

function TQuizFile.RandomizeChoice: TQuizChoiceAns;

  function Shuffle(var AString: array of string): integer;
  var
    tmp: array of string;
    idx: array of integer;
    t, i: integer;
  begin
    SetLength(tmp, Length(AString));
    setlength(idx, Length(Astring));
    for i := 0 to High(AString) do
    begin
      tmp[i] := AString[i];
      idx[i] := i;
    end;
    for i := 0 to High(Astring) do
    begin
      t := RandomFrom(Idx);
      while t = -1 do
        t := RandomFrom(Idx);
      if t = 0 then
        Result := i;
      AString[i] := tmp[t];
      idx[t] := -1;
    end;
  end;

var
  i: integer;
begin
  SetLength(Result, Length(Choices));
  for i := 0 to High(Choices) do
    Result[i] := Shuffle(Choices[i].Choices);
end;

procedure TQuizFile.ImportFromQuizMaker(const AQuizMaker: TQuizMaker);
var
  i, j: integer;
begin
  ChoicesQuiz := AQuizMaker.QuizChoicesCount;
  EssayQuiz := AQuizMaker.QuizEssayCount;
  ChoicesCount := AQuizMaker.ChoicesCount;
  SetLength(Choices, ChoicesQuiz);
  SetLength(Essays, EssayQuiz);
  Date := FormatDateTime('m/d/yyyy', now);
  Time := FormatDateTime('hh:nn', now);
  Random := AQuizMaker.Random;
  MaxChar := AQuizMaker.MaxChars;
  for i := 0 to High(AQuizMaker.ChoicesComponent) do
  begin
    Choices[i].PictureStream := TMemoryStream.Create;
    if AQuizmaker.ChoicesComponent[i].PictureAv then
      AQuizMaker.ChoicesComponent[i].Image.Picture.SaveToStream(Choices[i].PictureSTream);
    Choices[i].Question := TStringList.Create;
    Choices[i].Question.Text := AQuizMaker.ChoicesComponent[i].Memo.Text;
    SetLength(Choices[i].Choices, ChoicesCount);
    for j := 0 to AQuizMaker.ChoicesCount - 1 do
      Choices[i].Choices[j] := AQuizMaker.ChoicesComponent[i].EditArr[j].Text;
  end;
  for i := 0 to High(AQuizMaker.EssaysComponent) do
  begin
    Essays[i].PictureStream := TMemoryStream.Create;
    if AQuizmaker.EssaysComponent[i].PictureAv then
      AQuizMaker.EssaysComponent[i].Image.Picture.SaveToStream(Essays[i].PictureSTream);
    Essays[i].Question := TStringList.Create;
    Essays[i].Question.Text := AQuizMaker.EssaysComponent[i].Memo.Text;
  end;
end;

procedure TQuizFile.ExportToQuizMaker(var AQuizMaker: TQuizMaker; parent: TRefPnl);
var
  i, j: integer;
begin
  AQuizMaker := TQuizMaker.Create(Parent, ChoicesQuiz, EssayQuiz, ChoicesCount, True);
  AQuizMaker.ImportBegin;
  AQuizMaker.Repaint;
  for i := 0 to ChoicesQuiz - 1 do
  begin
    AQuizMaker.ChoicesComponent[i].Memo.Lines.Assign(Choices[i].Question);
    for j := 0 to ChoicesCount - 1 do
    begin
      if Choices[i].Choices[j] = '' then
      begin
        AQuizMaker.ChoicesComponent[i].EditCover[j].Font.Color := $CECECE;
        AQuizMaker.ChoicesComponent[i].EditCover[j].Font.Style := [fsItalic];
        AQuizMaker.ChoicesComponent[i].EditCover[j].Caption := '  klik untuk mengubah isi...';
      end
      else
      begin
        AQuizMaker.ChoicesComponent[i].EditCover[j].Font.Color := $FFFFFF;
        AQuizMaker.ChoicesComponent[i].EditCover[j].Font.Style := [];
      end;
      AQuizMaker.ChoicesComponent[i].EditCover[j].Caption := '  ' + Choices[i].Choices[j];
      AQuizMaker.ChoicesComponent[i].EditArr[j].Text := Choices[i].Choices[j];
    end;
    if Choices[i].PictureStream.Size <> 0 then
    begin
      AQuizMaker.ChoicesComponent[i].PictureAv := True;
      AQuizMaker.ChoicesComponent[i].Button.Caption := 'Hapus Gambar';
      AQuizMaker.ChoicesComponent[i].Image.Picture.LoadFromStream(Choices[i].PictureStream);
    end
    else
      AQuizMaker.ChoicesComponent[i].PictureAv := False;
  end;
  for i := 0 to EssayQuiz - 1 do
  begin
    AQuizMaker.EssaysComponent[i].Memo.Lines.Assign(Essays[i].Question);
    if Essays[i].PictureStream.Size <> 0 then
    begin
      AQuizMaker.EssaysComponent[i].PictureAv := True;
      AQuizMaker.EssaysComponent[i].Image.Picture.LoadFromStream(Essays[i].PictureStream);
    end
    else
      AQuizMaker.EssaysComponent[i].PictureAv := False;
  end;
  AQuizMaker.ImportEnd;
end;

procedure TQuizFile.LoadFromFile(FileName: string);
var
//  zip: TUnZipper;
//  valid: boolean;
//  i: integer;
  List: TstringList;
begin
  List := TSTringList.Create;
  List.loadfromfile(fileName);
  LoadFromSTrings(List);
  List.Free;
  //try
  //  zip := TUnzipper.Create;
  //  zip.FileName := FileName;
  //  if not DirectoryExistsUTF8('tmp') then
  //    mkdir('tmp');
  //
  //  zip.OutputPath := IncludeTrailingBackslash(Extractfilepath(filename));
  //  zip.UnZipAllFiles;
  //
  //  if zip.entries.count = 1 then
  //    if zip.Entries[0].DisplayName = 'core' then
  //      valid := true;
  //
  //  if valid then begin
  //    zip.UnZipAllFiles;
  //    List := TStringList.Create;
  //    list.LoadFromFile(IncludeTrailingBackslash(Extractfilepath(filename))+'core');
  //    deletefile(IncludeTrailingBackslash(Extractfilepath(filename))+'core');
  //    LoadFromStrings(list);
  //  end;
  //  zip.free;
  //  List.free;
  //except
  //  valid := false;
  //end;
  //
  //if not valid then
  //  raise Exception.Create('Berkas tidak valid.');
end;

procedure TQuizFile.LoadFromStrings(const List: TStrings);

  procedure LineToStream(var AString: string; var Stream: TMemoryStream);
  var
    tmp: string;
    strStream: TStringStream;
    i: integer;
  begin
    tmp := '';
    for i := 1 to Length(AString) do
    begin
      if i mod 2 = 1 then
        tmp := tmp + char(StrToInt('$' + Astring[i] + Astring[i + 1]));
    end;
    StrStream := TSTringStream.Create(tmp);
    tmp := '';
    Stream.LoadFromStream(strStream);
    strStream.Free;
    //showmessage(inttostr(stream.size));
  end;

var
  b, i, j, tmp: integer;
  verification: array of boolean;
  spc, a: boolean;
  pict, subclause, clause, subnode, node, Value: string;
begin
  spc := False;
  clause := '';
  subnode := '';
  node := '';
  subclause := '';
  pict := '';
  setlength(verification, 0);
  b := 0;
  try
    for i := 0 to List.Count - 1 do
    begin
      if (spc = False) and (clause <> '') and (trim(list[i]) = '}') then
      begin
        clause := '';
        a := True;
        for j := 0 to high(verification) do
          a := verification[j] and a;
        if not a then
          raise Exception.Create('Berkas tidak valid.');
        SetLength(verification, 0);
      end;

      if clause = '' then
      begin
        list[i] := trim(List[i]);
        clause := Copy(list[i], 1, length(list[i]) - 1);
        if clause = 'DOCINFO' then
        begin
          setLength(verification, 4);
          Inc(b);
          spc := False;
        end
        else if clause = 'QUIZINFO' then
        begin
          SetLength(Verification, 5);
          Inc(b);
          spc := False;
        end
        else if clause = 'QUIZDATA' then
        begin
          Inc(b);
          spc := True;
          setLength(choices, ChoicesQUiz);
          setLength(essays, essayQUiz);
          for tmp := 0 to ChoicesQuiz - 1 do
          begin
            choices[tmp].PictureStream := TMemoryStream.Create;
            SetLength(choices[tmp].Choices, ChoicesCount);
            choices[tmp].Question := TStringList.Create;
          end;
          for tmp := 0 to EssayQuiz - 1 do
          begin
            essays[tmp].PictureStream := TMemoryStream.Create;
            essays[tmp].Question := TStringList.Create;
          end;
        end;
      end
      else
      begin
        List[i] := Trim(list[i]);
        if clause = 'DOCINFO' then
        begin
          //showmessage(list[i]);
          node := trim(copy(trim(List[i]), 1, pos(':', trim(List[i])) - 1));
          Value := trim(copy(List[i], pos(':', List[i]) + 2, Length(List[i]) - 1 - Pos(List[i], ':')));
          //showmessage('node: '+node+'; value: '+value);
          if (node = 'type') then
          begin
            if (Value <> FileType) then
              raise Exception.Create('Tipe file tidak didukung (' + Value + ').');
            verification[0] := True;
          end
          else if (node = 'version') then
          begin
            if Value <> version then
              raise Exception.Create('Tipe versi file tidak didukung (' + Value + ').');
            verification[1] := True;
          end
          else if node = 'date' then
          begin
            Date := Value;
            verification[2] := True;
          end
          else if node = 'time' then
          begin
            time := Value;
            verification[3] := True;
          end;
        end
        else if clause = 'QUIZINFO' then
        begin
          node := trim(copy(trim(List[i]), 1, pos(':', trim(List[i])) - 1));
          Value := trim(copy(List[i], pos(':', List[i]) + 2, Length(List[i]) - 1 - Pos(List[i], ':')));
          if node = 'choice-quiz' then
          begin
            ChoicesQuiz := StrToInt(Value);
            verification[0] := True;
          end
          else if node = 'essay-quiz' then
          begin
            EssayQuiz := StrToInt(Value);

            verification[1] := True;
          end
          else if node = 'choices' then
          begin
            ChoicesCount := StrToInt(Value);
            verification[2] := True;
          end
          else if node = 'max-char' then
          begin
            MaxChar := StrToInt(Value);
            verification[3] := True;
          end
          else if node = 'random' then
          begin
            Random := boolean(StrToInt(Value));
            verification[4] := True;
          end;
        end
        else if clause = 'QUIZDATA' then
        begin
          //showmessage(list[i]);
          if (subclause = '') and (list[i][length(list[i])] = '{') then
            subclause := trim(copy(list[i], 1, length(list[i]) - 1))
          else if (subnode = '') and (trim(list[i]) = '}') then
            subclause := ''
          else if ((subclause <> '') and (subnode = '') and (list[i][length(list[i])] = '{')) then
            subnode := trim(copy(list[i], 1, length(list[i]) - 1))
          else if (trim(list[i]) = '}') and (subnode <> '') then
          begin
            if subnode = 'PICTUREDATA' then
            begin
              if Subclause[1] = 'M' then
                LineToStream(pict, TMemoryStream(
                  choices[StrToInt(Copy(subclause, 3, length(subclause) - 2)) - 1].PictureStream))
              else
                LineToStream(pict, TMemoryStream(
                  essays[StrToInt(Copy(subclause, 3, length(subclause) - 2)) - 1].PictureStream));
              pict := '';
            end;
            subnode := '';
          end
          else
          begin
            if copy(subclause, 1, 2) = 'MC' then
            begin
              tmp := StrToInt(copy(subclause, 3, length(subclause) - 2)) - 1;
              if subnode = 'QUESTION' then
                choices[tmp].Question.Add(trim(list[i]))
              else if subnode = 'ANSWER' then
              begin
                choices[tmp].Choices[0] := trim(list[i]);
              end
              else if Copy(subnode, 1, 7) = 'CHOICE-' then
                choices[tmp].Choices[StrToInt(copy(subnode, 8, length(subnode) - 7))] := trim(list[i])
              else if subnode = 'PICTUREDATA' then
                pict := pict + trim(list[i]);
            end
            else if copy(subclause, 1, 2) = 'EC' then
            begin
              tmp := StrToInt(copy(subclause, 3, length(subclause) - 2)) - 1;
              if subnode = 'QUESTION' then
                essays[tmp].Question.Add(trim(list[i]))
              else if subnode = 'PICTUREDATA' then
                pict := pict + trim(list[i]);
            end;
          end;
        end;
      end;
    end;
  finally

  end;
  if (b <> 3) then
    raise Exception.Create('not valid.');
end;

procedure StreamToLine(var stream: TMemoryStream; var List: TStringList; tabDepth: integer);
var
  buffer, buffer_1: string;
  i: longint;
begin
  buffer := ''; //do not localise
  buffer_1 := '';
  SetString(buffer, PChar(stream.Memory), Stream.Size div sizeOf(char));
  for i := 1 to Length(Buffer) do
  begin
    Buffer_1 := Buffer_1 + IntToHex(Ord(Buffer[i]), 2);
    if ((i mod 64) = 0) and (i <> 0) then
    begin
      List.Add(tab(tabDepth) + buffer_1);
      buffer_1 := '';
    end;
  end;
  List.Add(tab(tabdepth) + buffer_1);
end;

procedure TQuizFile.WriteHeader(var list: TStringList);
begin
  List.Add('DOCINFO{');
  List.Add(tab + 'type: ' + FileType);
  List.Add(tab + 'version: ' + Version);
  List.Add(tab + 'creator: ' + Publisher);
  List.Add(tab + 'date: ' + FormatDateTime('m/d/yyyy', now));
  List.Add(tab + 'time: ' + FormatDateTime('hh:nn', now));
  list.add('}');
  List.Add('QUIZINFO{');
  List.Add(tab + 'choice-quiz: ' + IntToStr(ChoicesQuiz));
  List.Add(tab + 'essay-quiz: ' + IntToStr(EssayQuiz));
  List.Add(tab + 'choices: ' + IntToStr(ChoicesCount));
  List.Add(tab + 'max-char: ' + IntToStr(MaxChar));
  List.Add(tab + 'random: ' + IntToStr(Ord(Random)));
  List.Add('}');
end;

procedure TQuizFile.WriteData(var list: TStringList);
var
  i, j: integer;
begin
  List.Add('QUIZDATA{');
  for i := 0 to ChoicesQuiz - 1 do
  begin
    List.Add(tab(1) + 'MC' + IntToStr(i + 1) + '{');
    List.Add(tab(2) + 'INFO{');
    List.Add(tab(3) + 'picture: ' + IntToStr(Ord(Choices[i].PictureStream.Size <> 0)));
    List.ADd(tab(2) + '}');
    List.Add(tab(2) + 'QUESTION{');
    for j := 0 to Choices[i].Question.Count - 1 do
      List.Add(tab(3) + Choices[i].Question[j]);
    List.Add(tab(2) + '}');
    List.Add(tab(2) + 'ANSWER{');
    List.Add(tab(3) + Choices[i].Choices[0]);
    List.Add(tab(2) + '}');
    for j := 1 to High(Choices[i].Choices) do
    begin
      List.Add(tab(2) + 'CHOICE-' + IntToStr(j) + '{');
      List.Add(tab(3) + Choices[i].Choices[j]);
      List.Add(tab(2) + '}');
    end;
    if Choices[i].PictureStream.Size <> 0 then
    begin
      List.Add(tab(2) + 'PICTUREDATA{');
      StreamToLine(TMemoryStream(Choices[i].PictureStream), List, 3);
      List.Add(tab(2) + '}');
    end;
    List.Add(tab(1) + '}');
  end;
  for i := 0 to EssayQuiz - 1 do
  begin
    List.Add(tab(1) + 'EC' + IntToStr(i + 1) + '{');
    List.Add(tab(2) + 'INFO{');
    List.Add(tab(3) + 'picture: ' + IntToStr(Ord(Essays[i].PictureStream.Size <> 0)));
    List.ADd(tab(2) + '}');
    List.Add(tab(2) + 'QUESTION{');
    for j := 0 to Essays[i].Question.Count - 1 do
      List.Add(tab(3) + Essays[i].Question[j]);
    List.Add(tab(2) + '}');
    if Essays[i].PictureStream.Size <> 0 then
    begin
      List.Add(tab(2) + 'PICTUREDATA{');
      StreamToLine(TMemoryStream(Essays[i].PictureStream), List, 3);
      List.Add(tab(2) + '}');
    end;
    List.Add(tab(1) + '}');
  end;
  List.Add(tab(0) + '}');
end;

procedure TQuizFile.SaveToFile(FileName: string);
var
  //Zip: TZipper;
  //Stream: TSTringStream;
  List: TStringList;
begin
  List := Tstringlist.create;
  writeHeader(list);
  writeData(list);
  list.SaveToFile(filename);
  list.free;
  //try
  //  list := TStringList.Create;
  //  writeHeader(list);
  //  writedata(list);
  //  Stream := TSTringSTream.Create(list.Text);
  //  list.Free;
  //
  //  zip := TZipper.Create;
  //  zip.FileName := FileName;
  //  zip.Entries.AddFileEntry(stream, 'core');
  //  zip.ZipAllFiles;
  //  stream.Free;
  //  zip.Free;
  //except
  //  on E: Exception do
  //    MsgBox('Tidak dapat menyimpan berkas  ' + ExtractFIleName(filename) + lineending +
  //      lineending + 'Pesan kesalahan:' + e.message, 'Kesalahan', 16);
  //end;
end;

procedure TQuizFile.SaveToStrings(out AString: TStrings);
begin
  WriteHeader(TStringList(Astring));
  WriteData(TStringList(Astring));
end;

end.
