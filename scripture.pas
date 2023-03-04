unit Scripture;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, LCLType, ComCtrls, Character;

type

  { TScriptureForm }

  TScriptureForm = class(TForm)
    BShowAll: TButton;
    BScripLoad: TButton;
    BScripSave: TButton;
    CBPrimaryBible: TComboBox;
    CBSecondaryBible: TComboBox;
    CBVerseNL: TCheckBox;
    CBTertiaryBible: TComboBox;
    EGap: TEdit;
    LbTertiary: TLabel;
    LGap: TLabel;
    LbSplit: TLabel;
    LbSecondary: TLabel;
    LbPrimary: TLabel;
    LBChapter2: TListBox;
    LBVerse2: TListBox;
    LBScrip: TListBox;
    LVerse: TLabel;
    RBHoriz: TRadioButton;
    RBVert: TRadioButton;
    ScriptureShow: TButton;
    LChapter: TLabel;
    LBook: TLabel;
    LBBook: TListBox;
    LBChapter: TListBox;
    LBVerse: TListBox;
    SBAddScrip: TSpeedButton;
    SBDelScrip: TSpeedButton;
    SBScripUp: TSpeedButton;
    SBScripDown: TSpeedButton;
    SBBlank: TSpeedButton;
    TBSplit: TTrackBar;
    procedure AddScripClick(Sender: TObject);
    procedure BScripLoadClick(Sender: TObject);
    procedure BScripSaveClick(Sender: TObject);
    procedure BShowAllClick(Sender: TObject);
    procedure CBPrimaryBibleChange(Sender: TObject);
    procedure CBSecondaryBibleChange(Sender: TObject);
    procedure CBTertiaryBibleChange(Sender: TObject);
    procedure CBVerseNLChange(Sender: TObject);
    procedure EGapChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LBBookSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure LBChapter2SelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure LBChapterSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure LBScripDblClick(Sender: TObject);
    procedure LBVerseSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure RBVertChange(Sender: TObject);
    procedure SBBlankClick(Sender: TObject);
    procedure SBDelScripClick(Sender: TObject);
    procedure SBScripDownClick(Sender: TObject);
    procedure SBScripUpClick(Sender: TObject);
    procedure ScriptureShowClick(Sender: TObject);
    procedure TBSplitChange(Sender: TObject);
    procedure PopulateBibleList();
    procedure PopulateBookList();
  private

  public

  end;

var
  ScriptureForm: TScriptureForm;

implementation

uses
  Control;

{$R *.lfm}

{ TScriptureForm }

procedure TScriptureForm.FormShow(Sender: TObject);
begin
  ScriptureForm.Top := ControlForm.Top + 10;
  ScriptureForm.Left := ControlForm.Left + 10;
  PopulateBookList();
  If ControlForm.TertiaryBibleId > 0 then
  begin
    RBVert.Checked:=True;
    RBVert.Enabled:=False;
    RBHoriz.Enabled:=False;
  end
  else
  begin
    RBVert.Enabled:=True;
    RBHoriz.Enabled:=True;
  end;
end;

procedure TScriptureForm.FormCreate(Sender: TObject);
begin
  LBBook.Clear;
  PopulateBibleList;
  TBSplit.Position:=ControlForm.BiblePrimarySplit;
  if ControlForm.SplitDir = 'V' then
    RBVert.Checked:=true
  else
    RBHoriz.Checked:=true;
  CBVerseNL.Checked:=ControlForm.NewLinePerVerse;
  EGap.Text := IntToStr(ControlForm.HorizSplitGap);

end;

procedure TScriptureForm.PopulateBibleList();
var
  itemNo : integer;
begin
  CBPrimaryBible.Clear;
  CBSecondaryBible.Clear;
  CBSecondaryBible.Items.Add('');
  CBSecondaryBible.ItemIndex := 0;
  CBTertiaryBible.Clear;
  CBTertiaryBible.Items.Add('');
  CBTertiaryBible.ItemIndex := 0;
  ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId`, `bibleName` FROM `bibles` ORDER BY `bibleName`';
  ControlForm.SQLMainQuery.Open;
  itemNo := 0;
  while not(ControlForm.SQLMainQuery.EOF) do
  begin
    CBPrimaryBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    CBSecondaryBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    CBTertiaryBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    if (ControlForm.DefaultBibleId = 0) then // Set a default bible is there is none set
      ControlForm.DefaultBibleId := ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger;
    if (ControlForm.DefaultBibleId = ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger) then
      CBPrimaryBible.ItemIndex:=itemNo;
    if (ControlForm.SecondaryBibleId = ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger) then
      CBSecondaryBible.ItemIndex := itemNo + 1; //Secondary bible has an extra blank entry at the start
    if (ControlForm.TertiaryBibleId = ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger) then
      CBTertiaryBible.ItemIndex := itemNo + 1; //Tertiary bible has an extra blank entry at the start
    itemNo := itemNo + 1;
    ControlForm.SQLMainQuery.Next;
  end;
  ControlForm.SQLMainQuery.Close;
  PopulateBookList();
end;

procedure TScriptureForm.PopulateBookList();
var
  LastBookId : integer;
  LastChapter, LastChapter2, LastVerse, LastVerse2 : integer;
begin
  LastBookId := LBBook.ItemIndex;
  LastChapter := LBChapter.ItemIndex;
  LastChapter2 := LBChapter2.ItemIndex;
  LastVerse := LBVerse.ItemIndex;
  LastVerse2 := LBVerse2.ItemIndex;
  LBBook.Clear;
  LBChapter.Clear;
  LBChapter2.Clear;
  LBVerse.Clear;
  LBVerse2.Clear;
  ControlForm.SQLMainQuery.SQL.Text := 'SELECT bookName FROM bibleBooks WHERE bibleId = :BIBLEID ORDER BY bookId';
  ControlForm.SQLMainQuery.ParamByName('BIBLEID').AsInteger := ControlForm.DefaultBibleId;
  ControlForm.SQLMainQuery.Open;
  while not ControlForm.SQLMainQuery.EOF do
  begin
    LBBook.Items.Add(ControlForm.SQLMainQuery.FieldByName('bookName').AsString);
    ControlForm.SQLMainQuery.Next;
  end;
  ControlForm.SQLMainQuery.Close;
  If LBBook.Count >= LastBookId then
  begin
    LBBook.ItemIndex := LastBookId;
    LBChapter.ItemIndex:=LastChapter;
    LBChapter2.ItemIndex:=LastChapter2;
    LBVerse.ItemIndex:=LastVerse;
    LBVerse2.ItemIndex:=LastVerse2;
  end;
end;

procedure TScriptureForm.AddScripClick(Sender: TObject);
var
  SelEnd : String;
begin
  if LBVerse.ItemIndex >= 0 then
  begin
    SelEnd := '';
    If (LBVerse2.ItemIndex >= 0) then
    begin
      If (LBChapter2.ItemIndex <> LBChapter.ItemIndex) then
        SelEnd := '-' + LBChapter2.Items.Strings[LBChapter2.ItemIndex] + ':' + LBVerse2.Items.Strings[LBVerse2.ItemIndex]
      else
        If (LBVerse2.ItemIndex <> LBVerse.ItemIndex) then
          SelEnd := '-' + LBVerse2.Items.Strings[LBVerse2.ItemIndex];
    end;
    LBScrip.Items.Add(LBBook.Items.Strings[LBBook.ItemIndex] + '|' + LBChapter.Items.Strings[LBChapter.ItemIndex] + ':' + LBVerse.Items.Strings[LBVerse.ItemIndex] + SelEnd + '|' + CBPrimaryBible.Items.Strings[CBPrimaryBible.ItemIndex]);
  end;
end;

procedure TScriptureForm.BScripLoadClick(Sender: TObject);
var
  SCFile : TextFile;
  Line : string;
begin
  ControlForm.OpenDialog1.DefaultExt := '.scrip';
  ControlForm.OpenDialog1.Title := 'Open Scripture List';
  ControlForm.OpenDialog1.Filter := 'Scripture List|*.scrip';
  if (ControlForm.OpenDialog1.Execute) then
  begin
    AssignFile(SCFile, ControlForm.OpenDialog1.FileName);
    Reset(SCFile);
    LBScrip.Clear;
    while not EOF(SCFile) do
    begin
      Readln(SCFile, Line);
      if (Length(Line) > 0) then
        LBScrip.Items.Add(Line);
    end;
    CloseFile(SCFile);
    if (LBScrip.Items.Count > 0) then
      LBScrip.ItemIndex := 0;
  end;
end;

procedure TScriptureForm.BScripSaveClick(Sender: TObject);
var
  SCFile: TextFile;
  i: integer;
begin
  ControlForm.SaveDialog1.DefaultExt := '.scrip';
  ControlForm.SaveDialog1.Title := 'Save Scripture List';
  ControlForm.SaveDialog1.Filter := 'Scripture List|*.scrip';
  if (ControlForm.SaveDialog1.Execute) then
  begin
    AssignFile(SCFile, ControlForm.SaveDialog1.FileName);
    Rewrite(SCFile);
    for i := 0 to LBScrip.Items.Count - 1 do
      WriteLn(SCFile, LBScrip.Items[i]);
    CloseFile(SCFile);
  end;
end;

procedure TScriptureForm.BShowAllClick(Sender: TObject);
var
  i : integer;
  ScriptureFile : TextFile;
begin
  if (LBScrip.Count > 0) then
  begin
    ControlForm.SongFileName := ControlForm.SongDirectory + 'Local' + PathDelim + 'QuickScripture.txt';
    AssignFile(ScriptureFile, ControlForm.SongFileName);
    Rewrite(ScriptureFile);
    for i := 0 to (LBScrip.Count - 1) do
    begin
      if LBScrip.Items.Strings[i] = 'BLANK' then
      begin
        Writeln(ScriptureFile, '<TEXT', (i + 1), '>');
        Writeln(ScriptureFile, '');
        Writeln(ScriptureFile, '</TEXT>');
      end
      else
      begin
        Writeln(ScriptureFile, '<SCRIP', (i + 1), '>');
        Writeln(ScriptureFile, LBScrip.Items.Strings[i]);
        Writeln(ScriptureFile, '</SCRIP>');
      end;
    end;
    CloseFile(ScriptureFile);
    ControlForm.LoadSong(Sender, false);
    if (ControlForm.ShowButton.Enabled) and (ControlForm.ShowButton.Caption = 'S&how') then
      ControlForm.ShowButton.Click;
  end;
end;

procedure TScriptureForm.CBPrimaryBibleChange(Sender: TObject);
begin
  if (CBPrimaryBible.ItemIndex >= 0) then
  begin
    ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId` FROM `bibles` WHERE `bibleName` = :BIBLENAME';
    ControlForm.SQLMainQuery.ParamByName('BIBLENAME').AsString := CBPrimaryBible.Items.Strings[CBPrimaryBible.ItemIndex];
    ControlForm.SQLMainQuery.Open;
    If not(ControlForm.SQLMainQuery.EOF) then
      ControlForm.DefaultBibleId := ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger;
    ControlForm.SQLMainQuery.Close;
    PopulateBookList();
  end;
end;

procedure TScriptureForm.CBSecondaryBibleChange(Sender: TObject);
begin
  if (CBSecondaryBible.ItemIndex >= 0) then
  begin
    ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId` FROM `bibles` WHERE `bibleName` = :BIBLENAME';
    ControlForm.SQLMainQuery.ParamByName('BIBLENAME').AsString := CBSecondaryBible.Items.Strings[CBSecondaryBible.ItemIndex];
    ControlForm.SQLMainQuery.Open;
    If not(ControlForm.SQLMainQuery.EOF) then
      ControlForm.SecondaryBibleId:= ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger
    else
    begin
      ControlForm.SecondaryBibleId := 0;
      CBTertiaryBible.ItemIndex := 0;
      CBTertiaryBibleChange(Sender);
    end;
    ControlForm.SQLMainQuery.Close;
  end
  else
  begin
    ControlForm.SecondaryBibleId := 0;
    CBTertiaryBible.ItemIndex := 0;
    CBTertiaryBibleChange(Sender);
  end;
end;

procedure TScriptureForm.CBTertiaryBibleChange(Sender: TObject);
begin
  if (CBTertiaryBible.ItemIndex >= 0) then
  begin
    ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId` FROM `bibles` WHERE `bibleName` = :BIBLENAME';
    ControlForm.SQLMainQuery.ParamByName('BIBLENAME').AsString := CBTertiaryBible.Items.Strings[CBTertiaryBible.ItemIndex];
    ControlForm.SQLMainQuery.Open;
    If not(ControlForm.SQLMainQuery.EOF) then
    begin
      ControlForm.TertiaryBibleId:= ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger;
      RBVert.Checked := True;  // Three way is only vertical split
      RBVert.Enabled := False;
      RBHoriz.Enabled := False;
    end
    else
    begin
      ControlForm.TertiaryBibleId := 0;
      RBVert.Enabled := True;
      RBHoriz.Enabled := True;
    end;
    ControlForm.SQLMainQuery.Close;
  end
  else
  begin
    ControlForm.TertiaryBibleId := 0;
    RBVert.Enabled := True;
    RBHoriz.Enabled := True;
  end;
end;

procedure TScriptureForm.CBVerseNLChange(Sender: TObject);
begin
  ControlForm.NewLinePerVerse:=CBVerseNL.Checked
end;

procedure TScriptureForm.EGapChange(Sender: TObject);
begin
  If (Length(EGap.Text) > 0) and (IsNumber(WideString(EGap.Text), 1)) then
    ControlForm.HorizSplitGap:=StrToInt(EGap.Text);
end;

procedure TScriptureForm.LBBookSelectionChange(Sender: TObject; User: boolean);
begin
  LBChapter.Clear;
  LBChapter2.Clear;
  LBVerse.Clear;
  LBVerse2.Clear;
  ControlForm.SQLMainQuery.SQL.Text := 'SELECT chapter FROM bibleVerse JOIN bibleBooks ON bibleVerse.bibleId = bibleBooks.bibleId AND bibleVerse.bookId = bibleBooks.bookId WHERE bibleBooks.bibleId = :BIBLEID AND bookName = :BOOKNAME GROUP BY chapter';
  ControlForm.SQLMainQuery.ParamByName('BIBLEID').AsInteger := ControlForm.DefaultBibleId;
  ControlForm.SQLMainQuery.ParamByName('BOOKNAME').AsString := LBBook.Items.Strings[LBBook.ItemIndex];
  ControlForm.SQLMainQuery.Open;
  while not ControlForm.SQLMainQuery.EOF do
  begin
    LBChapter.Items.Add(ControlForm.SQLMainQuery.FieldByName('chapter').AsString);
    LBChapter2.Items.Add(ControlForm.SQLMainQuery.FieldByName('chapter').AsString);
    ControlForm.SQLMainQuery.Next;
  end;
  ControlForm.SQLMainQuery.Close;
end;

procedure TScriptureForm.LBChapter2SelectionChange(Sender: TObject;
  User: boolean);
begin
  LBVerse2.Clear;
  If (LBChapter2.ItemIndex >= 0) then
  begin
    ControlForm.SQLMainQuery.SQL.Text := 'SELECT verse FROM bibleVerse JOIN bibleBooks ON bibleVerse.bibleId = bibleBooks.bibleId AND bibleVerse.bookId = bibleBooks.bookId WHERE bibleBooks.bibleId = :BIBLEID AND bookName = :BOOKNAME AND chapter = :CHAPTER ORDER BY verse';
    ControlForm.SQLMainQuery.ParamByName('BIBLEID').AsInteger := ControlForm.DefaultBibleId;
    ControlForm.SQLMainQuery.ParamByName('BOOKNAME').AsString := LBBook.Items.Strings[LBBook.ItemIndex];
    ControlForm.SQLMainQuery.ParamByName('CHAPTER').AsInteger := StrToInt(LBChapter2.Items.Strings[LBChapter2.ItemIndex]);
    ControlForm.SQLMainQuery.Open;
    while not ControlForm.SQLMainQuery.EOF do
    begin
      LBVerse2.Items.Add(ControlForm.SQLMainQuery.FieldByName('verse').AsString);
      ControlForm.SQLMainQuery.Next;
    end;
    ControlForm.SQLMainQuery.Close;
  end;

end;

procedure TScriptureForm.LBChapterSelectionChange(Sender: TObject; User: boolean
  );
var
  inc2 : boolean;
begin
  LBVerse.Clear;
  If (LBChapter.ItemIndex >= 0) then
  begin
    If (LBChapter2.ItemIndex < LBChapter.ItemIndex) then
    begin
      LBChapter2.ItemIndex := LBChapter.ItemIndex;
      LBVerse2.Clear;
      inc2 := true
    end
    else
      inc2 := false;
    ControlForm.SQLMainQuery.SQL.Text := 'SELECT verse FROM bibleVerse JOIN bibleBooks ON bibleVerse.bibleId = bibleBooks.bibleId AND bibleVerse.bookId = bibleBooks.bookId WHERE bibleBooks.bibleId = :BIBLEID AND bookName = :BOOKNAME AND chapter = :CHAPTER ORDER BY verse';
    ControlForm.SQLMainQuery.ParamByName('BIBLEID').AsInteger := ControlForm.DefaultBibleId;
    ControlForm.SQLMainQuery.ParamByName('BOOKNAME').AsString := LBBook.Items.Strings[LBBook.ItemIndex];
    ControlForm.SQLMainQuery.ParamByName('CHAPTER').AsInteger := StrToInt(LBChapter.Items.Strings[LBChapter.ItemIndex]);
    ControlForm.SQLMainQuery.Open;
    while not ControlForm.SQLMainQuery.EOF do
    begin
      LBVerse.Items.Add(ControlForm.SQLMainQuery.FieldByName('verse').AsString);
      If (inc2 = true) then
        LBVerse2.Items.Add(ControlForm.SQLMainQuery.FieldByName('verse').AsString);
      ControlForm.SQLMainQuery.Next;
    end;
    ControlForm.SQLMainQuery.Close;
  end;

end;

procedure TScriptureForm.LBScripDblClick(Sender: TObject);
var
  ScriptureFile : TextFile;
begin
  If (LBScrip.ItemIndex >= 0) then
  begin
    ControlForm.SongFileName := ControlForm.SongDirectory + 'Local' + PathDelim + 'QuickScripture.txt';
    AssignFile(ScriptureFile, ControlForm.SongFileName);
    Rewrite(ScriptureFile);
    Writeln(ScriptureFile, '<SCRIP>');
    Writeln(ScriptureFile, LBScrip.Items.Strings[LBScrip.ItemIndex]);
    Writeln(ScriptureFile, '</SCRIP>');
    CloseFile(ScriptureFile);
    ControlForm.LoadSong(Sender, false);
    if (ControlForm.ShowButton.Enabled) and (ControlForm.ShowButton.Caption = 'S&how') then
      ControlForm.ShowButton.Click;
  end;
end;

procedure TScriptureForm.LBVerseSelectionChange(Sender: TObject; User: boolean);
begin
  If ((LBChapter.ItemIndex = LBChapter2.ItemIndex) and (LBVerse2.ItemIndex < LBVerse.ItemIndex)) then
    LBVerse2.ItemIndex := -1;
end;

procedure TScriptureForm.RBVertChange(Sender: TObject);
begin
  if RBVert.Checked then
    ControlForm.SplitDir := 'V'
  else
    ControlForm.SplitDir := 'H';
end;

procedure TScriptureForm.SBBlankClick(Sender: TObject);
begin
      LBScrip.Items.Add('BLANK');
end;

procedure TScriptureForm.SBDelScripClick(Sender: TObject);
var
  Reply, OldIndex: integer;
begin
  if LBScrip.ItemIndex > -1 then
  begin
    Reply := Application.MessageBox('Delete from scripture list?',
      'Confirm Delete', MB_ICONQUESTION + MB_YESNO);
    if Reply = idYes then
    begin
      OldIndex := LBScrip.ItemIndex;
      LBScrip.Items.Delete(LBScrip.ItemIndex);
      if LBScrip.Items.Count > OldIndex then
        LBScrip.ItemIndex := OldIndex
      else
        LBScrip.ItemIndex := LBScrip.Items.Count - 1;
    end;
  end;
end;

procedure TScriptureForm.SBScripDownClick(Sender: TObject);
var
  Item: string;
begin
  if (LBScrip.ItemIndex >= 0) and (LBScrip.ItemIndex < (LBScrip.Items.Count - 1)) then
  begin
    Item := LBScrip.Items[LBScrip.ItemIndex];
    LBScrip.Items[LBScrip.ItemIndex] := LBScrip.Items[LBScrip.ItemIndex + 1];
    LBScrip.Items[LBScrip.ItemIndex + 1] := Item;
    LBScrip.ItemIndex := LBScrip.ItemIndex + 1;
  end;
end;

procedure TScriptureForm.SBScripUpClick(Sender: TObject);
var
  Item: string;
begin
  if LBScrip.ItemIndex > 0 then
  begin
    Item := LBScrip.Items[LBScrip.ItemIndex];
    LBScrip.Items[LBScrip.ItemIndex] := LBScrip.Items[LBScrip.ItemIndex - 1];
    LBScrip.Items[LBScrip.ItemIndex - 1] := Item;
    LBScrip.ItemIndex := LBScrip.ItemIndex - 1;
  end;
end;

procedure TScriptureForm.ScriptureShowClick(Sender: TObject);
var
  SelEnd : String;
  ScriptureFile : TextFile;
begin
  if LBVerse.ItemIndex >= 0 then
  begin
    SelEnd := '';
    If (LBVerse2.ItemIndex >= 0) then
    begin
      If (LBChapter2.ItemIndex <> LBChapter.ItemIndex) then
        SelEnd := '-' + LBChapter2.Items.Strings[LBChapter2.ItemIndex] + ':' + LBVerse2.Items.Strings[LBVerse2.ItemIndex]
      else
        If (LBVerse2.ItemIndex <> LBVerse.ItemIndex) then
          SelEnd := '-' + LBVerse2.Items.Strings[LBVerse2.ItemIndex];
    end;
    ControlForm.SongFileName := ControlForm.SongDirectory + 'Local' + PathDelim + 'QuickScripture.txt';
    AssignFile(ScriptureFile, ControlForm.SongFileName);
    Rewrite(ScriptureFile);
    Writeln(ScriptureFile, '<SCRIP>');
    Writeln(ScriptureFile, LBBook.Items.Strings[LBBook.ItemIndex] + '|' + LBChapter.Items.Strings[LBChapter.ItemIndex] + ':' + LBVerse.Items.Strings[LBVerse.ItemIndex] + SelEnd);
    Writeln(ScriptureFile, '</SCRIP>');
    CloseFile(ScriptureFile);
    ControlForm.LoadSong(Sender, false);
    if (ControlForm.ShowButton.Enabled) and (ControlForm.ShowButton.Caption = 'S&how') then
      ControlForm.ShowButton.Click;
    ScriptureForm.Hide;
  end;
end;

procedure TScriptureForm.TBSplitChange(Sender: TObject);
begin
  ControlForm.BiblePrimarySplit:=TBSplit.Position;
end;

end.

