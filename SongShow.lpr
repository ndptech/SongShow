program SongShow;

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dbflaz, Control, Words, setup, Edit, scripture, cclreport, advancededit;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TControlForm, ControlForm);
  Application.CreateForm(TWordsForm, WordsForm);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TScriptureForm, ScriptureForm);
  Application.CreateForm(TCCLReportForm, CCLReportForm);
  Application.CreateForm(TAdvancedEditForm, AdvancedEditForm);
  Application.Run;
end.

