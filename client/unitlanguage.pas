unit unitlanguage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Lresources, Forms, StdCtrls, ComCtrls, ExtCtrls, LCLType;

type
  PForm = ^TForm;
  TstrArray=array of string;
//string db, we'll write this down here to make lot of things easier, more efficient and to low down the cpu usage.
const
  lang_close = 0;
  lang_tryagain = 1;
  lang_error = 2;
  lang_warning = 3;
  lang_info = 4;
  lang_start_do = 5;
  lang_new_message = 6;
  lang_status = 7;
  lang_minutes = 8;
  lang_message_enter = 9;
  lang_define_usern = 10;
  lang_preferences = 11;
  lang_confirm = 12;
  lang_prog_up_quiz = 13;
  lang_prog_prepintf = 14;
  lang_prog_up_file = 15;
  lang_prog_down_quiz = 16;
  lang_prog_loading = 17;
  lang_err_up_quiz = 18;
  lang_err_up_file = 19;
  lang_err_down_quiz = 20;
  lang_err_send_msg = 21;
  lang_err_send_vote = 22;
  lang_err_contact_sv = 23;
  lang_fmt_quiz_left = 24;
  lang_fmt_assign_left = 25;
  lang_fmt_filespec = 26;
  lang_fmt_quiz_maxdur = 27;
  lang_fmt_quiz_undone = 28;
  lang_fmt_assign_undone = 29;
  lang_cl = 30;
  lang_sv = 31;
  lang_file_spec = 32;
  lang_max_dur = 33;
  lang_empty_ans = 34;
  lang_send_conf = 35;
  lang_attention = 36;
  lang_ans_uploaded = 37;
  lang_max_ans = 38;
  lang_info_new_msg1 = 39;
  lang_info_new_msg2 = 40;
  lang_no_notif = 41;
  lang_ins_pwd = 42;
  lang_wrong_pwd = 43;
  lang_no_network = 44;


var
  lang_res: array of string;

procedure sw_lang(id: boolean);
procedure translate_frm(frm: PForm; lang: integer);

implementation
uses
  unitglobal;
function ExtractStr(AString: string): TStrArray;
var
  X, Y, Count: integer;
begin
  SetLength(result, 0);
  Y := 0;
  Count := 1;
  for X := 1 to Length(AString) do
    if AString[X] = '|' then
      inc(Count);
  SetLength(result, Count);
  for X := 1 to Length(AString) do
    if AString[X] = '|' then
      inc(Y)
    else
      result[Y] := result[Y] + AString[X];

end;

procedure translate_frm(frm: PForm; lang: integer);
var
  List: TStringList;
  strm: TLazarusResourceStream;
  Section: string;
  a: TStrArray;
  I: integer;
  sectionDone: boolean;
begin
  List := TStringList.Create;
  try
    case Lang of
      0: strm := TLazarusResourceStream.Create('en-us', nil);
      1: strm := TLazarusResourceStream.Create('id-id', nil);
    end;
    list.loadfromstream(strm);
    strm.free;
    Section := '';
    sectionDone := False;
    for I := 0 to List.Count - 1 do
      if (List[i][1] = '<') and (List[i][length(list[i])] = '>') then
      begin
        section := Copy(List[i], 2, length(list[i]) - 2);
        if sectionDone then
          break;
      end
      else
      begin
        if section = '' then
          raise Exception.Create('Not valid language pack');
        if section = frm^.ToString then
        begin
          a := ExtractStr(List[i]);
          if (a[0] = 'TLabel') and (a[2] = 'Caption') then
            TLabel(frm^.FindComponent(a[1])).Caption := a[3]
          else if (a[0] = 'TPanel') and (a[2] = 'Caption') then
            TPanel(frm^.FindComponent(a[1])).Caption := a[3]
          else if (a[0] = 'TImage') and (a[2] = 'Hint') then
            TImage(frm^.FindComponent(a[1])).Hint := a[3]
          else if (a[0] = 'TListView') and (Copy(a[2], 1, 7) = 'Columns') then
            TListView(frm^.FindComponent(a[1])).Columns[StrToInt(a[2][9])].Caption := a[3];
          sectionDone := True;
        end;
      end;
  except
    //if Language = LangBahasa then
    //  MessageBox(AffectedForm.Handle, 'Terjadi kesalahan saat memuat bahasa.', 'Error', mb_IconError)
    //else if Language = langEnglish then
      MsgBox('Error occured while loading interface language.', 'Error', mb_IconError)
  end;
  List.Free;
end;


procedure sw_lang(id: boolean);
var
  strm: TLazarusResourceStream;
  list: TStringList;
  i: integer;
begin
  list := TStringList.Create;
  if id then
    strm := TLazarusResourceStream.Create('id_lang_resource', nil)
  else
    strm := TLazarusResourceStream.Create('en_lang_resource', nil);
  list.LoadFromStream(strm);
  setlength(lang_res, list.Count);
  for i := 0 to list.Count - 1 do
    lang_res[i] := list[i];
  strm.Free;
  list.Free;
end;

initialization
  {$I lang.lrs}
end.
