program classroom_server;

{$mode objfpc}{$H+}

uses
 {$IFDEF LINUX} cthreads, {$ENDIF}
  Interfaces,
  uniqueinstanceraw,
  uniqueinstance_package, // this includes the LCL widgetset
  Forms,
  FormMain,
  unitviewer,
  UnitDatabase,
  FormSplash,
  formNewSession,
  UnitThreadSync,
  unitglobal,
  formquizmaker,
  unitquizmaker,
  FormQuizPreview,
  unitdebug,
  unitquizfile,
  unitquizpreview,
  FormAddAssignment,
  lazcontrols,
  tachartlazaruspkg,
  FormAddQuiz,
  FormQuizPointView,
  unitlistviewtocsv,
  FormEssayModerator,
  formessaymoderatorsub,
  formAddVote,
  FormVote,
  FormSettings,
  unittemporaryman,
  formassignmentdetail,
  formQuizDetail,
  FormAbout;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmSplash, frmSplash);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmNewSession, frmNewSession);
  Application.CreateForm(TfrmQuizMaker, frmQuizMaker);
  Application.CreateForm(TfrmQuizPreview, frmQuizPreview);
  Application.CreateForm(TfrmAddAssignment, frmAddAssignment);
  Application.CreateForm(TfrmAddQuiz, frmAddQuiz);
  Application.CreateForm(TfrmQuizPointView, frmQuizPointView);
  Application.CreateForm(TfrmEssayModerator, frmEssayModerator);
  Application.CreateForm(TfrmEssayModeratorSub, frmEssayModeratorSub);
  Application.CreateForm(TfrmAddVote, frmAddVote);
  Application.CreateForm(TfrmVote, frmVote);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.CreateForm(TfrmAssignmentDetail, frmAssignmentDetail);
  Application.CreateForm(TfrmQuizDetail, frmQuizDetail);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
