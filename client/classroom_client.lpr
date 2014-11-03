program classroom_client;

{$mode objfpc}{$H+}

uses
  {$IFDEF Linux}
    cthreads,
    cmem,
  {$ENDIF}

  uniqueinstance_package, Interfaces,
  Forms, formMain, unitglobal, unitdatabase, unitReporter, unitthreadsync,
  formpreferences, unitsendmessage, formScanNetwork, formworksdetail,
  unitassignuploader, unitquizDownloader, unitdebug, unitquizfile,
  unitquizmaker, unitquizpreview, formabout, formquizviewer, unitansweruploader,
  FormLockScreen, FormVote, unitlanguage, unitupdater, formupdater;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.ShowMainForm := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmScanNetwork, frmScanNetwork);
  Application.CreateForm(Tfrmworksdetail, frmworksdetail);
  Application.CreateForm(TfrmQuizPreview, frmQuizPreview);
  Application.CreateForm(TfrmLockScreen, frmLockScreen);
  Application.CreateForm(TfrmVote, frmVote);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmUpdater, frmUpdater);
  Application.Run;
end.
