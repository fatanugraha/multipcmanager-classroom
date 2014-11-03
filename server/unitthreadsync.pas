unit UnitThreadSync;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdSync, Graphics, ComCtrls, unitdebug;

type
  TSync = class(TIdSync)
  protected
    procedure DoSynchronize; override;
  public
    procSwitch: string;
    procParams: array of string;
    procParamsAux: array of pointer;
  end;

procedure CreateSync(var ASync: TSync; ProcName: shortstring; ParamsCount: integer; ParamsAuxCount: integer = 0);
procedure DestroySync(var ASync: TSync);

implementation

uses
  FormMain, UnitDatabase, UnitGlobal, formQuizDetail, formvote, formAssignmentDetail, formessaymoderator, formquizpointview;

procedure CreateSync(var ASync: TSync; ProcName: shortstring; ParamsCount: integer; ParamsAuxCount: integer = 0);
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

procedure TSync.DoSynchronize;
var
  i, temp_int1, Idx, QuizIdx: integer;
  a: TListItem;
begin
  if procswitch = 'SubmitVote' then
  begin
    //procparams[0] contains IP
    //procparams[1] contains vote idx
    //procparams[2] contains vote choice idx
    idx := StrToInt(Procparams[1]);
    i := StrToInt(ProcParams[2]);
    SetLength(VoteData[idx].doneid, Length(VoteData[idx].doneid) + 1);
    VoteData[idx].doneid[High(VoteData)] := FindIndex(procparams[0]);

    Inc(VoteData[idx].Submision);
    Inc(voteData[idx].Data[i].Total);
    if frmVote.Visible then
      frmVote.FormShow(frmVote);
    if frmmain.lblSelected.left = frmmain.imgVote.left then
      frmMain.imgVoteClick(frmmain.imgVote);
  end
  else
  if ProcSwitch = 'QuizAnswers' then
  begin
    //procparams[0] contains IP
    //procparams[1] contains Quiz IDx, as string
    //procparamsaux[0] pointer of array of integer;
    //procparamsaux[1] pointer of array of string;

    Idx := FindIndex(procparams[0]);
    QuizIdx := StrToInt(procparams[1]);

    if Length(RealtimeData[Idx].QuizPoints) <> Length(WorksData.Quiz) then
      SetLength(RealtimeData[Idx].QuizPoints, Length(WorksData.Quiz));

    with RealtimeData[Idx].QuizPoints[QuizIdx] do
    begin
      choice := 0;
      Essay := -1;
    end;

    AddElement(RealtimeData[Idx].DoneQuiz, QuizIdx);
    AddElement(WorksData.Quiz[QuizIdx].QuizDoneId, Idx);

    //copy answers to db
    if Length(RealtimeData[idx].QuizAnswers) <> Length(worksData.Quiz) then
      SetLength(RealtimeData[idx].QuizAnswers, Length(worksData.Quiz));

    SetLength(RealtimeData[idx].QuizAnswers[QuizIdx].Choices, Length(TIntArr(procparamsAux[0]^)));
    SetLength(RealtimeData[idx].QuizAnswers[QuizIdx].Essays, Length(TIntArr(procparamsAux[0]^)));

    for i := 0 to High(TIntArr(procparamsAux[0]^)) do //copy choices
      RealtimeData[idx].QuizAnswers[QuizIdx].Choices[i] := TIntArr(procparamsAux[0]^)[i];

    for i := 0 to High(TStrARr(procparamsaux[1]^)) do //copy essays
      RealtimeData[Idx].QuizAnswers[QuizIdx].Essays[i] := TStrArr(procparamsaux[1]^)[i];


    RealtimeData[Idx].QuizPoints[QuizIdx].Choice := 0;

    for i := 0 to High(TIntArr(Procparamsaux[0]^)) do
      if (TIntArr(Procparamsaux[0]^)[i] <> -1) and (TIntArr(Procparamsaux[0]^)[i] =
        WorksData.Quiz[QuizIdx].QuizAns[i]) then
        Inc(RealtimeData[Idx].QuizPoints[QuizIdx].Choice, WorksData.Quiz[QuizIdx].ChoicePoint);

    if (frmmain.lblSelected.left = frmmain.imgAssignment.left) and (not frmQuizPointView.visible) and (not frmEssayModerator.visible) then
      frmMain.imgAssignmentClick(frmMain.imgAssignment);

    if (frmQuizPointView.visible) and (not frmEssayModerator.visible) then
      frmQuizPointView.FormShow(frmQuizPointView);

    if frmQuizDetail.Visible then
      frmQuizDetail.ShowData(frmQuizDetail.id);
  end
  else if ProcSwitch = 'AddUser' then
  begin
    //Procparams[0] contains IP
    //Procparams[1] contains Name
    if FindIndex(procparams[0]) = -1 then
      for i := 0 to high(realtimedata) do
        if (RealtimeData[i].FormerIP = procparams[0]) and (RealtimeData[i].Name = procparams[1]) then
        begin
          realtimedata[i].IP := RealtimeData[i].FormerIP;
          RealtimeData[i].FormerIP := '';
          frmMain.viewer.removed[i] := False;
          frmMain.viewer.Repaint;
          exit;
        end;
    //add name verification TODO
    SetLength(RealtimeData, Length(RealtimeData) + 1);
    temp_int1 := High(RealtimeData);
    RealtimeData[temp_int1].IP := procparams[0];
    RealtimeData[temp_int1].Name := procparams[1];
    RealtimeData[temp_int1].Msg := TStringList.Create;
    RealtimeData[temp_int1].AdditionalData := TStringList.Create;
    RealtimeData[temp_int1].Online := True;

    with frmMain do
    begin
      if imgMessaging.Left = lblSelected.left then
        imgMessagingClick(imgMessaging);
    end;

    frmMain.Viewer.Add(procparams[1]);
    frmMain.pnlStatus.Caption := '';
    TempManager.AddFile(procparams[0] + '.jpg');
  end
  else if ProcSwitch = 'RemUser' then
  begin
    //procparams[0] contains IP
    temp_int1 := FindIndex(procparams[0]);

    RealtimeData[temp_int1].Online := False;
    RealtimeData[temp_int1].FormerIp := RealtimeData[temp_int1].IP;
    RealtimeData[temp_int1].IP := 'removed';

    frmMain.Viewer.Remove(temp_int1);
    with frmMain do
    begin
      if imgMessaging.Left = lblSelected.left then
        imgMessagingClick(imgMessaging);
    end;
  end
  else if ProcSwitch = 'Message' then
  begin
    temp_int1 := FindIndex(ProcParams[0]);

    RealtimeData[temp_int1].Msg.Add(RealtimeData[temp_int1].Name + ':');
    RealtimeData[temp_int1].Msg.Add(ProcParams[1]);
    RealtimeData[temp_int1].Msg.Add('');

    with frmmain do
    begin
      if lblSelected.left <> imgMessaging.left then
      begin
        lblNew.Left := imgMessaging.left;
        lblnew.Width := imgMessaging.Width;
        realtimedata[temp_int1].NewData := True;
      end
      else
      begin
        if Listbox1.ItemIndex <> -1 then
        begin
          if RelToFix(ListBox1.ItemIndex) = temp_int1 then
          begin
            Memo1.Text := RealtimeData[Temp_int1].Msg.Text;
            memo1.ScrollBy(0, memo1.Height);
          end;
        end
        else
        begin
          Listbox1.Items[FixToRel(temp_int1)] := RealtimeData[temp_int1].Name + ' - Pesan Baru';
          realtimedata[temp_int1].NewData := True;
        end;
      end;
    end;
  end
  else if ProcSwitch = 'ScreenShot' then
  begin
    try
      temp_int1 := FindIndex(ProcParams[0]);
      RealtimeData[temp_int1].Online := True;
      if temp_int1 = -1 then
        exit;
      if not DirectoryExists(AppPath + 'temp' + dirDelimiter) then
        mkdir(AppPath + 'temp' + dirDelimiter);
      TMemoryStream(procparamsAUX[0]^).SaveToFile(apppath + 'temp' + dirDelimiter + procparams[0] + '.jpg');
      frmMain.viewer.ImgData[temp_int1].Picture.LoadFromFile(apppath + 'temp' + dirdelimiter + procparams[0] + '.jpg');
      frmMain.Update;
    except
    end;
  end
  else if ProcSwitch = 'IncAssignment' then
  begin
    SetLength(RealtimeData[StrToInt(procparams[0])].DoneAssign,
      Length(RealtimeData[StrToInt(procparams[0])].DoneAssign) + 1);

    RealtimeData[StrToInt(procparams[0])].DoneAssign[High(RealtimeData[StrToInt(procparams[0])].DoneAssign)] :=
      StrToInt(procparams[1]);
    SetLength(WorksData.Assignment[StrToInt(procparams[1])].DoneId,
      Length(WorksData.Assignment[StrToInt(procparams[1])].DoneId) + 1);
    WorksData.Assignment[StrToInt(procparams[1])].DoneId[High(WorksData.Assignment[StrToInt(procparams[1])].DoneId)] :=
      StrToInt(procparams[0]);
    with frmMain do
      if lblSelected.left = imgAssignment.Left then
      begin
        listview1.Clear;
        for i := 0 to High(WorksData.Assignment) do
        begin
          with Worksdata.assignment[i] do
          begin
            a := ListView1.Items.Add;
            a.Caption := IntToStr(i + 1);
            a.SubItems.add(Name);
            a.SubItems.add(Description);
            a.SubItems.add(IntToStr(Length(DoneId)));
          end;
        end;
      end;

    if frmAssignmentDetail.Visible then
      frmAssignmentDetail.showdata(frmAssignmentDetail.id);
  end;
end;

end.
