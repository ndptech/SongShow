unit Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, LCLType;

type

  { TEditForm }

  TEditForm = class(TForm)
    EditSave: TButton;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    SongEdit: TSynEdit;
    procedure EditSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SongEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
  private
    { private declarations }
    Saved: boolean;
  public
    EditFileName: string;
    { public declarations }
  end;

var
  EditForm: TEditForm;

implementation

uses Control;

{$R *.lfm}

{ TEditForm }

procedure TEditForm.EditSaveClick(Sender: TObject);
var
  SongFile : TextFile;
  i : integer;
  Reload : boolean;
  Directory, Filename : string;
begin
  If EditFileName = '' then
  begin
    Reload := false;
    SaveDialog1.InitialDir := ControlForm.SongDirectory + 'Local';
    SaveDialog1.FileName := '';
    SaveDialog1.DefaultExt := '.txt';
    SaveDialog1.Filter := 'Text Files|*.txt';
    if (SaveDialog1.Execute) then
      EditFileName := SaveDialog1.FileName;
  end
  else
    Reload := true;
  If EditFileName <> '' then
  begin
    AssignFile(SongFile, EditFileName);
    Rewrite(SongFile);
    For i := 0 to SongEdit.Lines.Count - 1 do
      WriteLn (SongFile, SongEdit.Lines[i]);
    CloseFile(SongFile);
    Filename := Copy(EditFileName, Length(ControlForm.SongDirectory)+1, Length(EditFileName) - Length(ControlForm.SongDirectory));
    Directory := '';
    While Pos(PathDelim, Filename) > 0 do
    begin
      Directory := Directory + Copy(Filename, 1, Pos(PathDelim, Filename));
      Filename := Copy(Filename, Pos(PathDelim, Filename) + 1, Length(Filename) - Pos(PathDelim, Filename));
    end;
    ControlForm.IndexSong(Filename, Directory, 0, 1, i, 0, not Reload);
    If (ControlForm.SongFileName = '') then
      ControlForm.SongFileName := EditFileName;
    If (ControlForm.SongFileName = EditFileName) then  // Only re-display if the song being saved is the current loaded song
      ControlForm.LoadSong(Sender, Reload);
  end;
  Saved := true;
  ModalResult := mrOK;
  If not (fsModal in FormState) then
    Close;
end;


procedure TEditForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  Reply : integer;
begin
  if (Saved = false) and (SongEdit.Modified = true) then
  begin
    Reply := Application.MessageBox('Song changed - do you want to save the changes?', 'Song changed', MB_ICONQUESTION + MB_YESNO);
    if Reply = IDYES then
      EditSaveClick(Sender)
  end;
end;

procedure TEditForm.FormShow(Sender: TObject);
begin
  EditForm.Top := ControlForm.Top + 20;
  EditForm.Left := ControlForm.Left + 20;
  Saved := false;
  SongEdit.Modified := false;
  FocusControl(SongEdit);
end;

procedure TEditForm.SongEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_S) and (ssCtrl in Shift) then
    EditSaveClick(Sender);
end;

end.

