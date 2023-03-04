unit Control;

{$mode objfpc}{$H+}

interface

uses
  Classes{$IFDEF WINDOWS}, windows{$ENDIF}, SysUtils, XMLConf, sqlite3conn, sqldb, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, LCLType, Grids, Menus,
  lconvencoding, lazutf8, fpjson, jsonparser, fphttpclient, vinfo, lclintf, RegexPr,
  fphttpserver, laz2_DOM, laz2_XMLRead, strutils, opensslsockets, types;

{$IFDEF WINDOWS}
type
  TWMHotKey = Packed Record
   MSG   : Cardinal;
   HotKey: PtrInt;
   Unused: PtrInt;
   Result: PtrInt;
  end;
{$ENDIF}

type

  { TControlForm }

  THTTPServerThread = Class(TThread)
  private
    HTTPServer : TFPHTTPServer;
  public
    constructor Create(APort : Word; Const OnRequest: THTTPServerRequestHandler);
    procedure Execute; override;
    procedure DoTerminate; override;
    property Server : TFPHTTPServer Read HTTPServer;
  end;

  TControlForm = class(TForm)
    FilesPopupMenu: TPopupMenu;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    FilesPublish: TMenuItem;
    FileMenuEdit: TMenuItem;
    ResMenuCCLRem: TMenuItem;
    ResMenuEditSource: TMenuItem;
    ResMenuEditSong: TMenuItem;
    ResMenuCCL: TMenuItem;
    ResMenuAdd: TMenuItem;
    MenuItemNewSong: TMenuItem;
    MenuItemSongEdit: TMenuItem;
    MenuItemPublish: TMenuItem;
    MenuItemCCLExport: TMenuItem;
    MenuItemCCLStop: TMenuItem;
    MenuItemCCLStart: TMenuItem;
    MenuItemCCL: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemLoadBible: TMenuItem;
    MenuItemImgExp: TMenuItem;
    MenuItemIDXExport: TMenuItem;
    MenuItemScan: TMenuItem;
    MenuItemSync: TMenuItem;
    MenuItemSavePL: TMenuItem;
    MenuItemLoadPL: TMenuItem;
    MenuItemSetup: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItemNew: TMenuItem;
    ResultsPopupMenu: TPopupMenu;
    ScriptureButton: TButton;
    SQLPhraseQuery: TSQLQuery;
    CurrVerseLab: TLabel;
    LBCurrentMarker: TListBox;
    NextVerse: TMemo;
    NextVerseLab: TLabel;
    OpenDialog1: TOpenDialog;
    PrevVerseLab: TLabel;
    LWarning: TLabel;
    SaveDialog1: TSaveDialog;
    CurrVerse: TMemo;
    PrevVerse: TMemo;
    SearchString: TLabeledEdit;
    SongSequence: TListBox;
    PlayList: TListBox;
    SongControl: TLabeledEdit;
    FilesList: TListBox;
    ShowButton: TButton;
    InsertToPL: TSpeedButton;
    DeleteFromPL: TSpeedButton;
    MoveUpPL: TSpeedButton;
    MoveDownPL: TSpeedButton;
    SongShowConfig: TXMLConfig;
    DBConnection: TSQLite3Connection;
    SQLMainQuery: TSQLQuery;
    SQLInsertQuery: TSQLQuery;
    SQLLastId: TSQLQuery;
    SQLBibleUpd: TSQLQuery;
    SQLBibleIns: TSQLQuery;
    SQLWordIns: TSQLQuery;
    SQLWordFind: TSQLQuery;
    SQLUpdateQuery: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    ResultGrid: TStringGrid;
    procedure BIngExpClick(Sender: TObject);
    procedure DeleteFromPLClick(Sender: TObject);
    procedure DownloadAllButtonClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure FileMenuEditClick(Sender: TObject);
    procedure FilesListDblClick(Sender: TObject);
    procedure FilesListKeyDown(Sender: TObject; var Key: word; {%H-}Shift: TShiftState);
    procedure FilesListMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure FilesPublishClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure IdxExpButtonClick(Sender: TObject);
    procedure LBCurrentMarkerClick(Sender: TObject);
    procedure LBCurrentMarkerDblClick(Sender: TObject);
    procedure LoadPLButtonClick(Sender: TObject);
    procedure LoadSong(Sender: TObject; Reload: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InsertToPLClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItemCCLExportClick(Sender: TObject);
    procedure MenuItemCCLStartClick(Sender: TObject);
    procedure MenuItemCCLStopClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemLoadBibleClick(Sender: TObject);
    procedure MenuItemFileClick(Sender: TObject);
    procedure MenuItemNewClick(Sender: TObject);
    procedure MenuItemNewSongClick(Sender: TObject);
    procedure MenuItemPublishClick(Sender: TObject);
    procedure MenuItemSongEditClick(Sender: TObject);
    procedure MoveDownPLClick(Sender: TObject);
    procedure MoveUpPLClick(Sender: TObject);
    procedure NewSongClick(Sender: TObject);
    procedure PlayListClick(Sender: TObject);
    procedure PlayListDblClick(Sender: TObject);
    procedure PlayListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PlayListDragOver(Sender, Source: TObject; X, Y: Integer;
      {%H-}State: TDragState; var Accept: Boolean);
    procedure PlayListKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure PlayListMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure ResMenuAddClick(Sender: TObject);
    procedure ResMenuCCLClick(Sender: TObject);
    procedure ResMenuCCLRemClick(Sender: TObject);
    procedure ResMenuEditSongClick(Sender: TObject);
    procedure ResMenuEditSourceClick(Sender: TObject);
    procedure ResultGridDblClick(Sender: TObject);
    procedure ResultGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure ResultGridKeyDown(Sender: TObject; var Key: word; {%H-}Shift: TShiftState);
    procedure ResultGridMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure ResultGridResize(Sender: TObject);
    procedure SavePLButtonClick(Sender: TObject);
    procedure ScanSongsClick(Sender: TObject);
    procedure ScriptureButtonClick(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure SearchStringKeyDown(Sender: TObject; var Key: Word;
      {%H-}Shift: TShiftState);
    procedure SetupButtonClick(Sender: TObject);
    procedure ShowButtonClick(Sender: TObject);
    procedure SyncSongsButtonClick(Sender: TObject);
    procedure SongControlKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
{$IFDEF WINDOWS}
  protected
    procedure WMHotKey(Var MSG: TWMHotKey); Message WM_HOTKEY;
{$ENDIF}
  private
    { private declarations }
    WindowTop: integer;
    WindowLeft: integer;
    Title: string;
    CCLSong: integer;
    SoftwareVersion: string;
    BuildNo : integer;
    OnScreenTime: TDateTime;
    DBVersion : integer;
    FirstVerseType : string;
    FirstRun : boolean;
    StartupAllowRemoteControl: boolean;
    HTTPParameter : string;
    HTTPValue : string;
    SongControlKey : string;
    ResultsHTMLMarkup : string;
    CCLEvent : string;
    DraggingItemNumber : integer;
    procedure AddVerseToSong(CurrentItem: string; AutoAmend: boolean);
    procedure AddVerseToSec();
    procedure AddVerseToThird();
    procedure CheckVerseLen(var CurrentItem: string; CurLinesPerScreen: integer; var LastBreakPoint: integer);
    procedure MoveLinesFwd(CurrentItem: string; BreakPoint: integer);
    procedure ScanDirectory(Directory : string; var NumUpdated : integer; Force : integer);
    function StripPunct(Line: string): string;
    procedure SyncSongs(GetAll: integer);
    procedure PublishSong(SongId : integer);
    procedure DoHandleRequest(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
    procedure ProcessSettings;
    procedure ProcessSongControlKey;
    procedure ProcessSearchString;
    procedure ProcessLoadSong;
    procedure AddScripLines(var CurrentItem: string; var CurrentIndex : integer; CurLinesPerScreen : integer; Line, SecLine, ThirdLine: string; FirstDone : boolean);
    function LinesNeeded(Line: string; DispWidth: integer): integer;
    procedure AddScripText(Line : string; DispWidth: integer; BibleNo : integer; FirstDone : boolean);
  public
    { public declarations }
    SongFileName: String;
    CurrentSongId: integer;
    SongIndex: TStringList;
    SongWords: TStringList;
    Song: array of TStringList;
    SongFmt: array of TStringList;
    SecBible: array of TStringList;
    SecBibleFmt: array of TStringList;
    ThirdBible: array of TStringList;
    ThirdBibleFmt: array of TStringList;
    ScreenBGImgs: array of String;
    Verse: TStringList;
    VerseFmt: TStringList;
    SecVerse: TStringList;
    SecVerseFmt: TStringList;
    ThirdVerse: TStringList;
    ThirdVerseFmt: TStringList;
    PlayOrder: TStringList;
    LoopStart: integer; //Begining of default play loop
    LoopEnd: integer; //Ending of default play loop
    LastItem: integer; //Last item in play list (allowing for it to be split into several parts)
    CopyRight: string;
    CurrentPosition: integer;
    CurrentPLItem: integer;
    CurrentPLItemName: string;
    SongDirectory: String;
    DataDir: String;
    FontName: String;
    ChorusFont: string;
    TextFont: String;
    ScreenBGImg: String;
    FontSize: integer;
    TextFontSize: integer;
    TopMargin: integer;
    LeftMargin: integer;
    BottomMargin: integer;
    RightMargin: integer;
    LinesPerScreen: integer;
    TextLinesPerScreen: integer;
    BottomSpace: integer;
    TopWords: integer;
    LeftWords: integer;
    HeightWords: integer;
    WidthWords: integer;
    ShowBorder: boolean;
    AutoMerge: boolean;
    AllowRemoteControl: boolean;
    GlobalHotkeys: boolean;
    LineIndent: integer;
    CCLNo: string;
    FGColour: TColor;
    BGColour: TColor;
    OLColour: TColor;
    OLSize: integer;
    BGImage: string;
    CurrentBGimage: String;
    SyncURL: string;
    SyncUser: string;
    SyncPass: string;
    LastSync: string; // The last modified stamp of the last sync
    DefaultBibleId: integer;
    SecondaryBibleId: integer;
    TertiaryBibleId: integer;
    BiblePrimarySplit: integer;
    SplitDir: string;
    NewLinePerVerse: boolean;
    HorizSplitGap : integer;
    procedure BuildSongList;
    procedure IndexSong(FileName: string; Directory : string; Central : integer; SongUpdated : integer; var NumUpdated: integer; Force : integer; Select : boolean);
    procedure VerseShow(PLItem: integer);
    procedure CCLRecord;
    procedure CCLRecordSong(FileName: string);
    procedure CCLRemoveSong(FileName: string);
    function Encode3to4(const Value, Table: AnsiString): AnsiString;
    function EncodeBase64(const Value: AnsiString): AnsiString;
  end;

const
  TableBase64 =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

var
  ControlForm: TControlForm;
  FServer : THTTPServerThread;

implementation

uses
  Words, Setup, Edit, AdvancedEdit, Scripture, CCLReport;

{$R *.lfm}

{ TControlForm }

procedure TControlForm.ShowButtonClick(Sender: TObject);
begin
  if (WordsForm.Visible = False) then
  begin
    WordsForm.Show;
    ShowButton.Caption := '&Hide';
    OnScreenTime := Now;
    ControlForm.FocusControl(SongControl);
  end
  else
  begin
    WordsForm.Hide;
    CCLRecord();
    ShowButton.Caption := 'S&how';
  end;
end;

procedure TControlForm.SongControlKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  PLItem: integer;
  i : integer;
  CleanSearch, CleanTest: string;
  VerseRegex: TRegexPr;
begin
  if Key = VK_Prior then
  begin
    if ssCtrl in Shift then
    begin
      if PlayList.Items.Count > 0 then
      begin
        if PlayList.ItemIndex > 0 then
        begin
          PlayList.ItemIndex := PlayList.ItemIndex - 1;
          PlayListDblClick(Sender);
        end;
      end;
    end
    else
    begin
      if CurrentPosition > 0 then
        VerseShow(CurrentPosition - 1);
    end;
  end;

  if Key = VK_Next then
  begin
    if ssCtrl in Shift then
    begin
      if PlayList.Items.Count > 0 then
      begin
        if PlayList.ItemIndex < (PlayList.Items.Count - 1) then
        begin
          PlayList.ItemIndex := PlayList.ItemIndex + 1;
          PlayListDblClick(Sender);
        end;
      end;
    end
    else
    begin
      if CurrentPosition = LoopEnd then
        VerseShow(LoopStart)
      else
      if CurrentPosition < (PlayOrder.Count - 1) then
        VerseShow(CurrentPosition + 1);
    end;
  end;

  if Key = VK_End then
  begin
    if LoopEnd < (PlayOrder.Count - 1) then
      VerseShow(LoopEnd + 1)
    else
    if PlayOrder.IndexOf('END') > -1 then
      VerseShow(PlayOrder.IndexOf('END'))
    else
      VerseShow(LastItem);
  end;

  if Key = VK_Home then
    VerseShow(0);

  if ((Key = VK_Insert) or (Key = VK_F9) or (Key = VK_F5) or ((Key = VK_B) and (ssCtrl in Shift) and (ShowButton.Caption = 'S&how'))) and (ShowButton.Enabled = true) then
  begin
    WordsForm.Show;
    ShowButton.Caption := '&Hide';
    OnScreenTime := Now;
    ControlForm.FocusControl(SongControl);
    Key := 0;
  end;

  if (Key = VK_Delete) or (Key = VK_Escape) or ((Key = VK_B) and (ssCtrl in Shift) and (ShowButton.Caption = '&Hide')) then
  begin
    WordsForm.Hide;
    CCLRecord();
    ShowButton.Caption := 'S&how';
    ControlForm.FocusControl(SongControl);
    Key := 0;
  end;

  if Key = VK_Return then
  begin
    PLItem := PlayOrder.IndexOf(SongControl.Text);
    if PLItem >= 0 then
    begin
      VerseShow(PLItem);
      SongControl.Text := '';
      Exit;
    end;

    VerseRegex := TRegexPr.Create;
    VerseRegex.Expression := RegExprString(SongControl.Text + '(_|$)');
    VerseRegex.ModifierI := true;
    for i := 0 to (PlayOrder.Count - 1) do
    begin
      if VerseRegex.Exec(PlayOrder.Strings[i]) then
      begin
        VerseShow(i);
        SongControl.Text := '';
        VerseRegex.Free;
        Exit;
      end;
    end;
    VerseRegex.Free;

    if FileExists(SongDirectory + SongControl.Text + '.txt') then
    begin
      SongFileName := SongDirectory + SongControl.Text + '.txt';
      SongControl.Text := '';
      LoadSong(Sender, False);
      Exit;
    end;

    if (SongControl.Text <> '') then
    begin
      CleanSearch := LowerCase(StripPunct(SongControl.Text));
      for i := 0 to (PlayOrder.Count - 1) do
      begin
        CleanTest := SongWords[i];
        If Pos(CleanSearch, CleanTest) > 0 then
        begin
          VerseShow(i);
          SongControl.Text := '';
          SongControl.SetFocus;
          Exit;
        end;
      end;
    end;
  end;

end;


procedure TControlForm.SyncSongsButtonClick(Sender: TObject);
var
  currentShiftState: TShiftState;
begin
  currentShiftState := GetKeyShiftState;
  if ssShift in currentShiftState then
    SyncSongs(1)
  else
    SyncSongs(0);
end;

procedure TControlForm.InsertToPLClick(Sender: TObject);
begin
  PlayList.Items.Add(Copy(SongFileName, Length(SongDirectory) + 1,
    Length(SongFileName) - Length(SongDirectory)));
end;

procedure TControlForm.MenuItem1Click(Sender: TObject);
var
  Filename : string;
  Splt : Integer;
  SongFile: TextFile;
  Line: string;
begin
  If FilesList.ItemIndex = -1 then
    exit;

  Filename := FilesList.Items.Strings[FilesList.ItemIndex];
  Splt := Pos('.txt (', Filename);
  If (Splt > 0) then
    Filename := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6)) + Copy(Filename, 1, Splt + 3);
  Filename := SongDirectory + Filename;
  EditForm.SongEdit.Lines.Clear();
  AssignFile(SongFile, Filename);
  Reset(SongFile);
  while not EOF(SongFile) do
  begin
    Readln(SongFile, Line);
    Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
    EditForm.SongEdit.Lines.Add(Line);
  end;
  CloseFile(SongFile);
  EditForm.EditFileName := Filename;
  EditForm.ShowModal;
end;

procedure TControlForm.MenuItem2Click(Sender: TObject);
var
  Filename : string;
  Directory : string;
  Splt : Integer;
  Reply, i: integer;
  Prompt: string;
begin
  If FilesList.ItemIndex = -1 then
    exit;
  Filename := FilesList.Items.Strings[FilesList.ItemIndex];
  Prompt := 'Delete song file ' + Filename + '?';
  Reply := Application.MessageBox(PChar(Prompt),
    'Confirm Delete', MB_ICONQUESTION + MB_YESNO);
  if Reply = idYes then
  begin
    FilesList.Items.Delete(FilesList.Items.IndexOf(Filename));
    Splt := Pos('.txt (', Filename);
    Directory := '';
    If (Splt > 0) then
    begin
      Directory := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6));
      Filename := Copy(Filename, 1, Splt + 3);
    end;

    Reply := 0;
    for i := 1 to ResultGrid.RowCount - 1 do begin
       if (ResultGrid.Cells[3, i] = Directory+Filename) then
         Reply := i;
    end;
    if (Reply > 0) then
    begin
      for i := Reply to ResultGrid.RowCount - 2 do
        ResultGrid.Rows[i].Assign(ResultGrid.Rows[i + 1]);
      ResultGrid.RowCount := ResultGrid.RowCount - 1;
    end;

    SQLMainQuery.SQL.Text := 'SELECT songId FROM songs WHERE filename = :FILENAME AND directory = :DIRECTORY';
    SQLMainQuery.Params.ParamByName('FILENAME').AsString := Filename;
    SQLMainQuery.Params.ParamByName('DIRECTORY').AsString := Directory;
    SQLMainQuery.Open;
    while not SQLMainQuery.EOF do
    begin
      DBConnection.ExecuteDirect('DELETE FROM songWords WHERE songId = ' + SQLMainQuery.FieldByName('songId').AsString);
      DBConnection.ExecuteDirect('DELETE FROM songPhrases WHERE songId = ' + SQLMainQuery.FieldByName('songId').AsString);
      DBConnection.ExecuteDirect('DELETE FROM songs WHERE songId = ' + SQLMainQuery.FieldByName('songId').AsString);
      SQLMainQuery.Next;
    end;
    SQLMainQuery.Close;
    SQLTransaction1.Commit;

    DeleteFile(PChar(SongDirectory+Directory+Filename));
  end;
end;

procedure TControlForm.MenuItemCCLExportClick(Sender: TObject);
begin
  CCLReportForm.ShowModal;
end;

procedure TControlForm.MenuItemCCLStartClick(Sender: TObject);
begin
  if InputQuery('CCL Recording', 'Enter event name', CCLEvent) then
    if (CCLEvent <> '') then
    begin
      LWarning.Caption := 'CCL Recording started';
      if (SongFileName <> '') then
        LoadSong(Sender, True);
    end;
end;

procedure TControlForm.MenuItemCCLStopClick(Sender: TObject);
begin
  CCLEvent := '';
  LWarning.Caption := 'CCL Recording stopped';
end;

procedure TControlForm.MenuItemExitClick(Sender: TObject);
begin
  ControlForm.Close;
end;

procedure TControlForm.MenuItemLoadBibleClick(Sender: TObject);
var
  BibleDoc : TXMLDocument;
  Bible : TDOMNode;
  Book : TDOMNode;
  Chapter : TDOMNode;
  BVerse : TDOMNode;
  BibleId : integer;
begin
  OpenDialog1.Title:='Load Bible XML';
  OpenDialog1.DefaultExt:='.xml';
  OpenDialog1.Filter := 'XML Bible Files|*.xml';
  if (OpenDialog1.Execute) then
  begin
    MenuItemLoadBible.Enabled := False;
    LWarning.Caption := 'Loading...';

    try
      ReadXMLFile(BibleDoc, OpenDialog1.FileName);
      Bible := BibleDoc.FindNode('XMLBIBLE');
      if Assigned(Bible) then
      begin
        SQLBibleUpd.SQL.Text := 'SELECT `bibleId` FROM `bibles` WHERE `bibleName` = :BIBLENAME';
        SQLBibleUpd.Params.ParamByName('BIBLENAME').AsString := Bible.Attributes.GetNamedItem('biblename').TextContent;
        SQLBibleUpd.Open;
        if (SQLBibleUpd.EOF) then
        begin
          SQLBibleIns.SQL.Text := 'INSERT INTO `bibles` (`bibleName`) VALUES (:BIBLENAME)';
          SQLBibleIns.Params.ParamByName('BIBLENAME').AsString := Bible.Attributes.GetNamedItem('biblename').TextContent;
          SQLLastId.SQL.Text := 'SELECT last_insert_rowid() AS bibleId';
          SQLBibleIns.ExecSQL;
          SQLLastId.Open;
          BibleId := SQLLastId.FieldByName('bibleId').AsInteger;
          SQLLastId.Close;
        end
        else
        begin
          BibleId := SQLBibleUpd.FieldByName('bibleId').AsInteger;
        end;
        SQLBibleUpd.Close;

        // Clear any old entries for this bible
        SQLBibleUpd.SQL.Text := 'DELETE FROM `bibleBooks` WHERE `bibleId` = :BIBLEID';
        SQLBibleUpd.ParamByName('BIBLEID').AsInteger := BibleId;
        SQLBibleUpd.ExecSQL;
        SQLTransaction1.Commit;
        SQLBibleUpd.SQL.Text := 'DELETE FROM `bibleVerse` WHERE `bibleId` = :BIBLEID';
        SQLBibleUpd.ParamByName('BIBLEID').AsInteger := BibleId;
        SQLBibleUpd.ExecSQL;
        SQLTransaction1.Commit;

        SQLBibleUpd.SQL.Text:='INSERT INTO bibleBooks (bibleId, bookId, bookname) VALUES (:BIBLEID, :BOOKID, :BOOKNAME)';
        SQLBibleUpd.ParamByName('BIBLEID').AsInteger := BibleId;
        SQLBibleIns.SQL.Text:='INSERT INTO bibleVerse (bibleId, bookId, chapter, verse, verseWords) VALUES (:BIBLEID, :BOOKID, :CHAPTER, :VERSE, :VERSEWORDS)';
        SQLBibleIns.ParamByName('BIBLEID').AsInteger := BibleId;

        Book := Bible.FirstChild;
        while Assigned(Book) do
        begin
          LWarning.Caption := Bible.Attributes.GetNamedItem('biblename').TextContent + ' ' + Book.Attributes.GetNamedItem('bname').TextContent;
          SQLBibleUpd.ParamByName('BOOKID').AsInteger := StrToInt(Book.Attributes.GetNamedItem('bnumber').TextContent);
          SQLBibleUpd.ParamByName('BOOKNAME').AsString := Book.Attributes.GetNamedItem('bname').TextContent;
          SQLBibleUpd.ExecSQL;
          SQLBibleIns.ParamByName('BOOKID').AsInteger := StrToInt(Book.Attributes.GetNamedItem('bnumber').TextContent);
          Chapter := Book.FirstChild;
          while Assigned(Chapter) do
          begin
            SQLBibleIns.ParamByName('CHAPTER').AsInteger := StrToInt(Chapter.Attributes.GetNamedItem('cnumber').TextContent);
            BVerse := Chapter.FirstChild;
            while Assigned(BVerse) do
            begin
              SQLBibleIns.ParamByName('VERSE').AsInteger := StrToInt(BVerse.Attributes.GetNamedItem('vnumber').TextContent);
              SQLBibleIns.ParamByName('VERSEWORDS').AsString := BVerse.TextContent;
              SQLBibleIns.ExecSQL;
              SQLTransaction1.Commit;
              BVerse := BVerse.NextSibling;
              Application.ProcessMessages();
            end;
            Chapter := Chapter.NextSibling;
          end;
          Book := Book.NextSibling;
        end;
      end;
      LWarning.Caption := 'Loaded ' + Bible.Attributes.GetNamedItem('biblename').TextContent;
    finally
      Bible.Free;
    end;

    SetupForm.PopulateBibleList;

    MenuItemLoadBible.Enabled := true;
  end;
end;

procedure TControlForm.MenuItemFileClick(Sender: TObject);
begin

end;

procedure TControlForm.MenuItemNewClick(Sender: TObject);
begin

end;

procedure TControlForm.MenuItemNewSongClick(Sender: TObject);
begin
  AdvancedEditForm.Show;
  AdvancedEditForm.NewSong;
end;

procedure TControlForm.MenuItemPublishClick(Sender: TObject);
var
  Prompt: string;
  Reply: integer;
begin
  If CurrentSongId > 0 then
  begin
    Prompt := 'Publish song ' + SongFileName + '?';
    Reply := Application.MessageBox(PChar(Prompt),
    'Confirm Publish', MB_ICONQUESTION + MB_YESNO);
    if Reply = idYes then
      PublishSong(CurrentSongId);
  end;
end;

procedure TControlForm.MenuItemSongEditClick(Sender: TObject);
begin
  if (SongFileName <> '') then
  begin
    AdvancedEditForm.Show;
    AdvancedEditForm.EditSong(SongFileName);
  end;
end;

procedure TControlForm.MoveDownPLClick(Sender: TObject);
var
  Item: string;
begin
  if (PlayList.ItemIndex >= 0) and (PlayList.ItemIndex < (PlayList.Items.Count - 1)) then
  begin
    Item := PlayList.Items[PlayList.ItemIndex];
    PlayList.Items[PlayList.ItemIndex] := PlayList.Items[PlayList.ItemIndex + 1];
    PlayList.Items[PlayList.ItemIndex + 1] := Item;
    PlayList.ItemIndex := PlayList.ItemIndex + 1;
  end;
end;

procedure TControlForm.MoveUpPLClick(Sender: TObject);
var
  Item: string;
begin
  if PlayList.ItemIndex > 0 then
  begin
    Item := PlayList.Items[PlayList.ItemIndex];
    PlayList.Items[PlayList.ItemIndex] := PlayList.Items[PlayList.ItemIndex - 1];
    PlayList.Items[PlayList.ItemIndex - 1] := Item;
    PlayList.ItemIndex := PlayList.ItemIndex - 1;
  end;
end;

procedure TControlForm.NewSongClick(Sender: TObject);
var
  TempSongFileName: string;
begin
  TempSongFileName := SongFileName;
  SongFileName := '';
  EditForm.EditFileName := '';
  EditForm.SongEdit.Lines.Clear();
  EditForm.SongEdit.Lines.Append('v1');
  EditForm.SongEdit.Lines.Append('<v1>');
  EditForm.SongEdit.Lines.Append('</v>');
  EditForm.SongEdit.Lines.Append('<copy>');
  EditForm.SongEdit.Lines.Append('</copy>');
  if (EditForm.ShowModal = mrCancel) then
    SongFileName := TempSongFileName;
end;

procedure TControlForm.PlayListClick(Sender: TObject);
begin

end;


procedure TControlForm.PlayListDblClick(Sender: TObject);
var
  Reload: boolean;
begin
  if SongFileName = SongDirectory + PlayList.Items.Strings[PlayList.ItemIndex] then
    Reload := True
  else
    Reload := False;
  SongFileName := SongDirectory + PlayList.Items.Strings[PlayList.ItemIndex];
  LoadSong(Sender, Reload);
end;

procedure TControlForm.PlayListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Filename : string;
  Splt : integer;
  ItemUnderMouse : integer;
begin
  If Source = ResultGrid then
    PlayList.Items.Add(ResultGrid.Cells[3, ResultGrid.Row]);

  If Source = FilesList then
  begin
    Filename := FilesList.Items.Strings[FilesList.ItemIndex];
    Splt := Pos('.txt (', Filename);
    If (Splt > 0) then
      Filename := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6)) + Copy(Filename, 1, Splt + 3);
    PlayList.Items.Add(Filename);
  end;

  if Source = PlayList then
  begin
    ItemUnderMouse := PlayList.ItemAtPos(Types.Point(X, Y), true);
    if (ItemUnderMouse > -1) and (ItemUnderMouse < PlayList.Count) and (DraggingItemNumber > -1) then
      PlayList.Items.Move(DraggingItemNumber, ItemUnderMouse);
  end;
end;

procedure TControlForm.PlayListDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  ItemUnderMouse : integer;
begin
  If Source = ResultGrid then
    Accept := true;
  If Source = FilesList then
    Accept := true;
  If Source = PlayList then
  begin
    ItemUnderMouse := PlayList.ItemAtPos(Types.Point(X, Y), true);
    Accept:=(ItemUnderMouse>-1) and (ItemUnderMouse<PlayList.Count);
  end;
end;

procedure TControlForm.PlayListKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    PlayListDblClick(Sender);
  if Key = VK_Delete then
    DeleteFromPLClick(Sender);
  if (Key = VK_Up) and (ssCtrl in Shift) then
  begin
    MoveUpPlClick(Sender);
    Key := 0;
  end;
  if (Key = VK_Down) and (ssCtrl in Shift) then
  begin
    MoveDownPlClick(Sender);
    Key := 0;
  end;
end;

procedure TControlForm.PlayListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If Button = mbLeft then begin
    DraggingItemNumber := PlayList.ItemAtPos(Point(X, Y), true);
    If (DraggingItemNumber > -1) and (DraggingItemNumber < PlayList.Count) then
      PlayList.BeginDrag(false)
    else
    begin
      DraggingItemNumber := -1;
      PlayList.BeginDrag(false);
    end;
  end;
end;

procedure TControlForm.ResMenuAddClick(Sender: TObject);
begin
  if ResultGrid.RowCount = 1 then
    exit;

  if ResultGrid.Cells[3, ResultGrid.Row] = '' then
    exit;

  PlayList.Items.Add(ResultGrid.Cells[3, ResultGrid.Row]);
end;

procedure TControlForm.ResMenuCCLClick(Sender: TObject);
begin
  if ResultGrid.RowCount = 1 then
    exit;

  if (ResultGrid.Cells[3, ResultGrid.Row] = '') or (CCLEvent = '') then
    exit;

  CCLRecordSong(ResultGrid.Cells[3, ResultGrid.Row]);
end;

procedure TControlForm.ResMenuCCLRemClick(Sender: TObject);
begin
  if ResultGrid.RowCount = 1 then
    exit;

  if ResultGrid.Cells[3, ResultGrid.Row] = '' then
    exit;

  CCLRemoveSong(ResultGrid.Cells[3, ResultGrid.Row]);
end;

procedure TControlForm.ResMenuEditSongClick(Sender: TObject);
var
  Filename : string;
begin
  if ResultGrid.RowCount = 1 then
    exit;

  if ResultGrid.Cells[3, ResultGrid.Row] = '' then
    exit;

  Filename := SongDirectory + ResultGrid.Cells[3, ResultGrid.Row];
  AdvancedEditForm.Show;
  AdvancedEditForm.EditSong(Filename);
end;

procedure TControlForm.ResMenuEditSourceClick(Sender: TObject);
var
  Filename : string;
  SongFile: TextFile;
  Line: string;
begin
  if ResultGrid.RowCount = 1 then
    exit;

  if ResultGrid.Cells[3, ResultGrid.Row] = '' then
    exit;

  FileName := SongDirectory + ResultGrid.Cells[3, ResultGrid.Row];
  EditForm.SongEdit.Lines.Clear();
  AssignFile(SongFile, FileName);
  Reset(SongFile);
  while not EOF(SongFile) do
  begin
    Readln(SongFile, Line);
    Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
    EditForm.SongEdit.Lines.Add(Line);
  end;
  CloseFile(SongFile);
  EditForm.EditFileName := FileName;
  EditForm.ShowModal;

end;

procedure TControlForm.ResultGridDblClick(Sender: TObject);
var
  Reload: boolean;
begin
  if SongFileName = SongDirectory + ResultGrid.Cells[3, ResultGrid.Row] then
    Reload := True
  else
    Reload := False;
  SongFileName := SongDirectory + ResultGrid.Cells[3, ResultGrid.Row];
  LoadSong(Sender, Reload);
end;

procedure TControlForm.ResultGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (gdFixed in aState) then exit;
  if ResultGrid.Cells[0, aRow] = '0_0' then exit;
  if aRow = ResultGrid.Row then
    ResultGrid.Canvas.Brush.Color := clHighlight
  else
    ResultGrid.Canvas.Brush.Color := clActiveCaption;
  if (LeftStr(ResultGrid.Cells[0, aRow], 1) = '1') then
    ResultGrid.Canvas.Font.Style := [fsBold];
  ResultGrid.Canvas.FillRect(aRect);
  ResultGrid.Canvas.TextOut(aRect.Left + 2, aRect.Top + 2, ResultGrid.Cells[aCol, aRow]);
end;

procedure TControlForm.ResultGridKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = VK_Insert then
    PlayList.Items.Add(ResultGrid.Cells[3, ResultGrid.Row]);
  if Key = VK_Return then
    ResultGridDblClick(Sender);
end;

procedure TControlForm.ResultGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    ResultGrid.BeginDrag(false);
end;

procedure TControlForm.ResultGridResize(Sender: TObject);
var
  WidthLeft: integer;
begin
  ResultGrid.AutoSizeColumns;
  WidthLeft := ResultGrid.Width - ResultGrid.ColWidths[1] -
    ResultGrid.ColWidths[2] - ResultGrid.ColWidths[3];
  if WidthLeft <> 0 then
  begin
    ResultGrid.ColWidths[1] := ResultGrid.ColWidths[1] + Round(WidthLeft / 3);
    ResultGrid.ColWidths[2] := ResultGrid.ColWidths[2] + Round(WidthLeft / 3);
    ResultGrid.ColWidths[3] :=
      ResultGrid.ClientWidth - (ResultGrid.ColWidths[1] + ResultGrid.ColWidths[2]);
  end;
end;

procedure TControlForm.SavePLButtonClick(Sender: TObject);
var
  PLFile: TextFile;
  i: integer;
begin
  SaveDialog1.DefaultExt := '.sspl';
  SaveDialog1.Title := 'Save Play List';
  SaveDialog1.Filter := 'SongShow Play List|*.sspl';
  if (SaveDialog1.Execute) then
  begin
    AssignFile(PLFile, SaveDialog1.FileName);
    Rewrite(PLFile);
    for i := 0 to PlayList.Items.Count - 1 do
      WriteLn(PLFile, PlayList.Items[i]);
    CloseFile(PLFile);
  end;
end;

procedure TControlForm.ScanDirectory(Directory : string; var NumUpdated : integer; Force : integer);
var
  SearchResult: TSearchRec;
begin
  if FindFirst(SongDirectory + Directory + '*.txt', faAnyFile, SearchResult) = 0 then
  begin
    IndexSong(SearchResult.Name, Directory, 0, 1, NumUpdated, Force, false);
    while FindNext(SearchResult) = 0 do
    begin
      IndexSong(SearchResult.Name, Directory, 0, 1, NumUpdated, Force, false);
      Application.ProcessMessages;
    end;
  end;
  FindClose(SearchResult);
  if FindFirst(SongDirectory + Directory + '*', faDirectory, SearchResult) = 0 then
  begin
    if ((SearchResult.Attr and faDirectory = faDirectory) and (Copy(SearchResult.Name, 1, 1) <> '.')) then
      ScanDirectory(Directory + SearchResult.Name + PathDelim, NumUpdated, Force);
    while FIndNext(SearchResult) = 0 do
      If ((SearchResult.Attr and faDirectory = faDirectory) and (Copy(SearchResult.Name, 1, 1) <> '.')) then
        ScanDirectory(Directory + SearchResult.Name + PathDelim, NumUpdated, Force);
  end;
  FindClose(SearchResult);
end;

procedure TControlForm.ScanSongsClick(Sender: TObject);
var
  NumUpdated: integer;
  currentShiftState: TShiftState;
begin
  MenuItemScan.Enabled := False;
  MenuItemScan.Caption := 'Scanning...';
  currentShiftState := GetKeyShiftState;
  NumUpdated := 0;
  if ssShift in currentShiftState then
    ScanDirectory('', NumUpdated, 1)
  else
    ScanDirectory('', NumUpdated, 0);

  SQLMainQuery.SQL.Text := 'SELECT filename, directory, songId FROM songs';
  SQLMainQuery.Open;
  while not SQLMainQuery.EOF do
  begin
    if not FileExists(SongDirectory + SQLMainQuery.FieldByName('directory').AsString + SQLMainQuery.FieldByName('filename').AsString) then
    begin
      DBConnection.ExecuteDirect('DELETE FROM songWords WHERE songId = ' + SQLMainQuery.FieldByName('songId').AsString);
      DBConnection.ExecuteDirect('DELETE FROM songPhrases WHERE songId = ' + SQLMainQuery.FieldByName('songId').AsString);
      DBConnection.ExecuteDirect('DELETE FROM songs WHERE songId = ' + SQLMainQuery.FieldByName('songId').AsString);
      If (SQLMainQuery.FieldByName('directory').AsString <> '') then
        FilesList.Items.Delete(FilesList.Items.IndexOf(SQLMainQuery.FieldByName('filename').AsString + ' (' + SQLMainQuery.FieldByName('directory').AsString + ')'))
      else
        FilesList.Items.Delete(FilesList.Items.IndexOf(SQLMainQuery.FieldByName('filename').AsString));
    end;
    SQLMainQuery.Next;
  end;
  SQLMainQuery.Close;
  SQLTransaction1.Commit;
  MenuItemScan.Caption := 'Scan S&ongs';
  MenuItemScan.Enabled := True;
  LWarning.Caption := IntToStr(NumUpdated) + ' updated';
end;

procedure TControlForm.ScriptureButtonClick(Sender: TObject);
begin
  ScriptureForm.Show;
end;

procedure TControlForm.SearchClick(Sender: TObject);
var
  SearchText, word, Where, SongWhere, SearchPhrase: string;
  i, songtest: integer;
begin
  SearchText := StripPunct(LowerCase(Trim(SearchString.Text)));
  if SearchText = '' then
    exit;
  SearchText := SearchText + ' ';
  Where := '';
  SongWhere := '';
  SearchPhrase := '';
  SQLWordFind.SQL.Text :=
    'SELECT wordId FROM words WHERE word >= :WORD AND word <= :ENDWORD';
  SQLPhraseQuery.SQL.Text :=
    'SELECT wordId FROM words WHERE word = :WORD';
  i := Pos(' ', SearchText);
  songtest := 0;
  while i > 0 do
  begin
    word := Trim(Copy(SearchText, 1, i - 1));
    if (word <> '') then
    begin
      SQLWordFind.Params.ParamByName('WORD').AsString := word;
      if Length(word) > 4 then
        SQLWordFind.Params.ParamByName('ENDWORD').AsString := word + 'zzzzzz'
      else
        SQLWordFind.Params.ParamByName('ENDWORD').AsString := word;
      Where := '';
      SQLWordFind.Open;
      while not SQLWordFind.EOF do
      begin
        if Where <> '' then
          Where := Where + ',';
        Where := Where + SQLWordFind.FieldByName('wordId').AsString;
        SQLWordFind.Next;
      end;
      SQLWordFind.Close;
      if Where <> '' then
      begin
        SQLMainQuery.SQL.Text := 'SELECT songId FROM songWords WHERE wordId IN ('+Where+')';
        if (songtest > 0) then
          SQLMainQuery.SQL.Text := SQLMainQuery.SQL.Text + ' AND songId IN ('+SongWhere+')';
        SQLMainQuery.Open;
        SongWhere := '';
        while not SQLMainQuery.EOF do
        begin
          if SongWhere <> '' then
            SongWhere := SongWhere + ',';
          SongWhere := SongWhere + SQLMainQuery.FieldByName('songId').AsString;
          SQLMainQuery.Next
        end;
        SQLMainQuery.Close;
        songtest := songtest + 1;
        SQLPhraseQuery.Params.ParamByName('WORD').AsString := word;
        SQLPhraseQuery.Open;
        if not SQLPhraseQuery.EOF then
        begin
          if SearchPhrase <> '' then
            SearchPhrase := SearchPhrase + ',';
          SearchPhrase := SearchPhrase + SQLPhraseQuery.FieldByName('wordId').AsString;
        end;
        SQLPhraseQuery.Close;
      end;
    end;
    SearchText := Copy(SearchText, i + 1, Length(SearchText) - i);
    i := Pos(' ', SearchText);
  end;
  ResultGrid.Clean([gzNormal]);
  ResultGrid.RowCount := 1;
  if SongWhere <> '' then
  begin
    SQLMainQuery.SQL.Text :=
      'SELECT filename, directory, firstline, chorus, CASE WHEN (firstlinenopunct LIKE :SEARCH) OR (chorusnopunct LIKE :SEARCH) THEN 1 ELSE 0 END AS `match`,' +
      'IFNULL(( SELECT SUM(CASE WHEN phrase LIKE :PHRASE THEN 1 ELSE 0 END) FROM songPhrases WHERE songPhrases.songId = songs.songId ), 0) AS `songMatch` ' +
      'FROM songs WHERE songId IN ('+ SongWhere + ') ORDER BY CASE WHEN (firstlinenopunct LIKE :SEARCH) OR (chorusnopunct LIKE :SEARCH) THEN 0 ELSE 1 END, songMatch DESC, firstline';
    SQLMainQuery.Params.ParamByName('SEARCH').AsString := '%'+StripPunct(SearchString.Text)+'%';
    SQLMainQuery.Params.ParamByName('PHRASE').AsString := '%'+SearchPhrase+'%';
    SQLMainQuery.Open;
    i := 1;
    while not SQLMainQuery.EOF do
    begin
      if i = ResultGrid.RowCount then
        ResultGrid.RowCount := i + 1;
      ResultGrid.Cells[3, i] := SQLMainQuery.FieldByName('directory').AsString+SQLMainQuery.FieldByName('filename').AsString;
      ResultGrid.Cells[1, i] := SQLMainQuery.FieldByName('firstline').AsString;
      ResultGrid.Cells[2, i] := SQLMainQuery.FieldByName('chorus').AsString;
      ResultGrid.Cells[0, i] := SQLMainQuery.FieldByName('match').AsString+'_'+SQLMainQuery.FieldByName('songMatch').AsString;
      SQLMainQuery.Next;
      i := i + 1;
    end;
    ResultGridResize(Sender);
    ResultGrid.Row := 0;
    SQLMainQuery.Close;
  end;
end;

procedure TControlForm.SearchStringKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SearchClick(Sender);
  if Key = VK_ESCAPE then
  begin
    ResultGrid.Clean([gzNormal]);
    ResultGrid.RowCount := 1;
    Key := 0;
  end;
end;

procedure TControlForm.FormCreate(Sender: TObject);
var
  VerInfo : TVersionInfo;
  PLFile : TextFile;
  i : integer;
  Line : string;
begin
  SongIndex := TStringList.Create;
  SongWords := TStringList.Create;
  Verse := TStringList.Create;
  VerseFmt := TStringList.Create;
  SecVerse := TStringList.Create;
  SecVerseFmt := TStringList.Create;
  ThirdVerse := TStringList.Create;
  ThirdVerseFmt := TStringList.Create;
  PlayOrder := TStringList.Create;
  LWarning.Caption := '';
  PrevVerseLab.Caption := '';
  CurrVerseLab.Caption := '';
  NextVerseLab.Caption := '';
  FilesList.ScrollWidth := FilesList.Width - 4;
  PlayList.ScrollWidth := PlayList.Width - 4;
  SongSequence.ScrollWidth := SongSequence.Width - 4;
  LBCurrentMarker.ScrollWidth := LBCurrentMarker.Width - 4;
  ShowButton.Enabled:=false;
  VerInfo := TVersionInfo.Create;
  FirstRun := true;
  CurrentSongId := 0;

  VerInfo.Load(HINSTANCE);
  SoftwareVersion := IntToStr(VerInfo.FixedInfo.FileVersion[0])+'.'+IntToStr(VerInfo.FixedInfo.FileVersion[1])+'.'+IntToStr(VerInfo.FixedInfo.FileVersion[2])+'.'+IntToStr(VerInfo.FixedInfo.FileVersion[3]);
  BuildNo := VerInfo.FixedInfo.FileVersion[3];
  ControlForm.Caption:= 'Song Show - ' + SoftwareVersion;
  ControlForm.KeyPreview := True;

  if Application.HasOption('p', 'portable') then
  begin
    SongShowConfig.Filename := GetCurrentDir() + PathDelim + 'SongShow.cfg';
    DataDir := GetCurrentDir() + PathDelim;
  end
  else
  begin
    SongShowConfig.Filename := GetAppConfigFile(False);
    DataDir := GetAppConfigDir(False);
  end;

  // Make data directory if it doesn't exist
  if not DirectoryExists(DataDir) then
    mkdir(DataDir);

  // Read Software Config
  DBVersion := SongShowConfig.GetValue('DBVersion', 1);
  SongDirectory := AnsiString(SongShowConfig.GetValue('SongDirectory', WideString(DataDir)));
  FontName := AnsiString(SongShowConfig.GetValue('FontName', 'Arial'));
  ChorusFont := AnsiString(SongShowConfig.GetValue('ChorusFont', 'Arial'));
  TextFont := AnsiString(SongShowConfig.GetValue('TextFont', 'Arial'));
  FontSize := SongShowConfig.GetValue('FontSize', 32);
  TextFontSize := SongShowConfig.GetValue('TextFontSize', 24);
  TopMargin := SongShowConfig.GetValue('TopMargin', 10);
  LeftMargin := SongShowConfig.GetValue('LeftMargin', 10);
  BottomMargin := SongShowConfig.GetValue('BottomMargin', 10);
  RightMargin := SongShowConfig.GetValue('RightMargin', 10);
  LinesPerScreen := SongShowConfig.GetValue('LinesPerScreen', 20);
  TextLinesPerScreen := SongShowConfig.GetValue('TextLinesPerScreen', 30);
  BottomSpace := SongShowConfig.GetValue('BottomSpace', 0);
  WindowTop := SongShowConfig.GetValue('WindowTop', 0);
  WindowLeft := SongShowConfig.GetValue('WindowLeft', 0);
  TopWords := SongShowConfig.GetValue('TopWords', 0);
  LeftWords := SongShowConfig.GetValue('LeftWords', 0);
  HeightWords := SongShowConfig.GetValue('HeightWords', 0);
  WidthWords := SongShowConfig.GetValue('WidthWords', 0);
  LineIndent := SongShowConfig.GetValue('LineIndent', 100);
  FGColour := SongShowConfig.GetValue('FGColour', clWhite);
  BGColour := SongShowConfig.GetValue('BGColour', clBlack);
  OLColour := SongShowConfig.GetValue('OLColour', clGray);
  OLSize := SongShowConfig.GetValue('OLSize', 0);
  BGimage := AnsiString(SongShowConfig.GetValue('BGimage', ''));
  ShowBorder := SongShowConfig.GetValue('ShowBorder', False);
  AutoMerge := SongShowConfig.GetValue('AutoMerge', False);
  AllowRemoteControl := SongShowConfig.GetValue('AllowRemoteControl', False);
  GlobalHotkeys := SongShowConfig.GetValue('GlobalHotkeys', False);
  StartupAllowRemoteControl := AllowRemoteControl;
  CCLNo := AnsiString(SongShowConfig.GetValue('CCLNo', ''));
  SyncURL := AnsiString(SongShowConfig.GetValue('SyncURL', ''));
  SyncUser := AnsiString(SongShowConfig.GetValue('SyncUser', ''));
  SyncPass := AnsiString(SongShowConfig.GetValue('SyncPass', ''));
  LastSync := AnsiString(SongShowConfig.GetValue('LastSync', '0000-00-00 00:00:00'));
  DefaultBibleId := SongShowConfig.GetValue('DefaultBibleId', 0);
  SecondaryBibleId := SongShowConfig.GetValue('SecondaryBibleId', 0);
  TertiaryBibleId := SongShowConfig.GetValue('TertiaryBibleId', 0);
  BiblePrimarySplit := SongShowConfig.GetValue('BiblePrimarySplit', 50);
  SplitDir := AnsiString(SongShowConfig.GetValue('SplitDir', 'V'));
  NewLinePerVerse := SongShowConfig.GetValue('NewLinePerVerse', False);
  HorizSplitGap := SongShowConfig.GetValue('HorizSplitGap', 20);

  // Make local song directory if it doesn't exist
  if not DirectoryExists(SongDirectory+'Local') then
    mkdir(SongDirectory+'Local');

  DBConnection.Close; // Make sure the database is closed
  DBConnection.DatabaseName := DataDir + 'songs.db';

  if not FileExists(DataDir + 'songs.db') then
  begin
    // Create the database and the tables
    try
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('CREATE TABLE `words` (`wordId` integer PRIMARY KEY, `word` varchar(30));');
      DBConnection.ExecuteDirect('CREATE INDEX `word` ON `words` (`word`);');
      DBConnection.ExecuteDirect('CREATE TABLE `songs` (`songId` integer PRIMARY KEY, `filename` varchar(100), `firstline` varchar(250), `chorus` varchar(250), `filedate` integer, `directory` varchar(250), `central` integer, `updated` integer, `firstlinenopunct` varchar(250), `chorusnopunct` varchar(250));');
      DBConnection.ExecuteDirect('CREATE INDEX `filename` ON `songs` (`filename`);');
      DBConnection.ExecuteDirect('CREATE TABLE `songWords` (`songId` integer, `wordId` integer, `freq` integer)');
      DBConnection.ExecuteDirect('CREATE INDEX `songId` ON `songWords` (`songId`)');
      DBConnection.ExecuteDirect('CREATE INDEX `wordId` ON `songWords` (`wordId`, `songId`)');
      DBConnection.ExecuteDirect('CREATE TABLE `songPhrases` (`songId` integer, `itemCode` varchar(10), phrase text)');
      DBConnection.ExecuteDirect('CREATE INDEX `songIdPhrases` ON `songPhrases` (`songId`, `itemCode`)');
      DBConnection.ExecuteDirect('CREATE TABLE `bibles` (`bibleId` integer PRIMARY KEY, `biblename` varchar(30), rtl integer)');
      DBConnection.ExecuteDirect('CREATE TABLE `bibleBooks` (`bibleId` integer, `bookId` integer, `bookname` varchar(30));');
      DBConnection.ExecuteDirect('CREATE INDEX `bookId` ON `bibleBooks` (`bibleId`, `bookId`)');
      DBConnection.ExecuteDirect('CREATE INDEX `bookname` ON `bibleBooks` (`bibleId`, `bookname`)');
      DBConnection.ExecuteDirect('CREATE TABLE `bibleVerse` (`bibleId` integer, `bookId` integer, `chapter` integer, `verse` integer, `verseWords` text)');
      DBConnection.ExecuteDirect('CREATE INDEX `verse` ON `bibleVerse` (`bibleId`, `bookId`, `chapter`, `verse`)');
      DBConnection.ExecuteDirect('CREATE TABLE `cclrecord` (`cclrecordId` integer PRIMARY KEY, `ccldate` real, `songId` integer, `cclevent` varchar(100), `cclname` text, `cclcopy` text)');
      DBConnection.ExecuteDirect('CREATE INDEX `cclDate` ON `cclrecord` (`ccldate`, `cclevent`)');

      SQLTransaction1.Commit;

      DBVersion := 8;
    except
      ShowMessage('Unable to Create new Database');
    end;
  end
  else
  begin
    // Check for older database versions and do upgrades needed.
    if (DBVersion = 1) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('CREATE TABLE `bibleBooks` (`bookId` integer PRIMARY KEY, `bookname` varchar(30));');
      DBConnection.ExecuteDirect('CREATE INDEX `bookname` ON `bibleBooks` (`bookname`)');
      DBConnection.ExecuteDirect('CREATE TABLE `bibleVerse` (`bookId` integer, `chapter` integer, `verse` integer, `verseWords` text)');
      DBConnection.ExecuteDirect('CREATE INDEX `verse` ON `bibleVerse` (`bookId`, `chapter`, `verse`)');

      SQLTransaction1.Commit;

      DBVersion := 2;
    end;
    if (DBVersion = 2) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('ALTER TABLE `songs` ADD COLUMN `directory` varchar(250)');
      DBConnection.ExecuteDirect('UPDATE `songs` SET `directory` = ""');

      SQLTransaction1.Commit;

      DBVersion := 3;
    end;
    if (DBVersion = 3) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('ALTER TABLE `songs` ADD COLUMN `central` integer');
      DBConnection.ExecuteDirect('ALTER TABLE `songs` ADD COLUMN `updated` integer');
      DBConnection.ExecuteDirect('UPDATE `songs` SET central = 0, updated = 0');
      SQLTransaction1.Commit;

      DBVersion := 4;
    end;
    if (DBVersion = 4) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('ALTER TABLE `songs` ADD COLUMN `firstlinenopunct` varchar(250)');
      DBConnection.ExecuteDirect('ALTER TABLE `songs` ADD COLUMN `chorusnopunct` varchar(250)');
      SQLTransaction1.Commit;

      SQLMainQuery.SQL.Text := 'SELECT songId, firstline, chorus FROM songs';
      SQLMainQuery.Open;

      SQLUpdateQuery.SQL.Text := 'UPDATE songs SET `firstlinenopunct` = :FIRST, `chorusnopunct` = :CHORUS WHERE `songId` = :SONGID';

      while not SQLMainQuery.EOF do
      begin
        SQLUpdateQuery.Params.ParamByName('SONGID').AsInteger := SQLMainQuery.FieldByName('songId').AsInteger;
        SQLUpdateQuery.Params.ParamByName('FIRST').AsString := StripPunct(SQLMainQuery.FieldByName('firstline').AsString);
        SQLUpdateQuery.Params.ParamByName('CHORUS').AsString := StripPunct(SQLMainQuery.FieldByName('chorus').AsString);
        SQLUpdateQuery.ExecSQL;
        SQLMainQuery.Next;
      end;
      SQLTransaction1.Commit;
      SQLMainQuery.Close;

      DBVersion := 5;
    end;
    if (DBVersion = 5) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('CREATE TABLE `songPhrases` (`songId` integer, itemCode varchar(10), phrase text)');
      DBConnection.ExecuteDirect('CREATE INDEX `songIdPhrases` ON `songPhrases` (`songId`, `itemCode`)');
      SQLTransaction1.Commit;

      DBVersion := 6;
    end;
    if (DBVersion = 6) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('CREATE TABLE `bibles` (`bibleId` integer PRIMARY KEY, `biblename` varchar(30), rtl integer)');
      DBConnection.ExecuteDirect('ALTER TABLE `bibleBooks` RENAME TO `bibleBooksOld`');
      DBConnection.ExecuteDirect('CREATE TABLE `bibleBooks` (`bibleId` integer, `bookId` integer, `bookname` varchar(30));');
      DBConnection.ExecuteDirect('CREATE INDEX `bookId` ON `bibleBooks` (`bibleId`, `bookId`)');
      DBConnection.ExecuteDirect('INSERT INTO `bibleBooks` (`bookId`, `bookname`) SELECT * FROM `bibleBooksOld`');
      DBConnection.ExecuteDirect('DROP TABLE bibleBooksOld');
      DBConnection.ExecuteDirect('CREATE INDEX `bookname` ON `bibleBooks` (`bibleId`, `bookname`)');
      DBConnection.ExecuteDirect('ALTER TABLE `bibleVerse` ADD COLUMN `bibleId` integer');
      DBConnection.ExecuteDirect('DROP INDEX `verse`');
      DBConnection.ExecuteDirect('CREATE INDEX `verse` ON `bibleVerse` (`bibleId`, `bookId`, `chapter`, `verse`)');
      SQLTransaction1.Commit;

      SQLMainQuery.SQL.Text := 'SELECT COUNT(*) AS books FROM bibleBooks';
      SQLMainQuery.Open;
      if (SQLMainQuery.FieldByName('books').AsInteger > 0) then
      begin
        // A bible was loaded - the only valid one before was ESV so mark this one as such
        DBConnection.ExecuteDirect('INSERT INTO `bibles` (`bibleId`, `bibleName`, `rtl`) VALUES(1, "ENGLISHESV", 0)');
        DBConnection.ExecuteDirect('UPDATE `bibleBooks` SET `bibleId` = 1');
        DBConnection.ExecuteDirect('UPDATE `bibleVerse` SET `bibleId` = 1');
        SQLTransaction1.Commit;
      end;
      SQLMainQuery.Close;
      DBVersion := 7;
    end;
    if (DBVersion = 7) then
    begin
      DBConnection.Open;
      SQLTransaction1.Active := True;

      DBConnection.ExecuteDirect('CREATE TABLE `cclrecord` (`cclrecordId` integer PRIMARY KEY, `ccldate` real, `songId` integer, `cclevent` varchar(100), `cclname` text, `cclcopy` text)');
      DBConnection.ExecuteDirect('CREATE INDEX `cclDate` ON `cclrecord` (`ccldate`, `cclevent`)');
      SQLTransaction1.Commit;

      DBVersion := 8;
    end;
  end;

  DBConnection.Open;

  SQLMainQuery.SQL.Text := 'SELECT COUNT(*) AS books FROM bibleBooks';
  SQLMainQuery.Open;
  if (SQLMainQuery.FieldByName('books').AsInteger = 0) then
    ScriptureButton.Visible := False;
  SQLMainQuery.Close;

  BuildSongList;

  MenuItemCCLStart.Click;

  for i := 1 to ParamCount do
  begin
    if (RightStr(ParamStr(i), 5) = '.sspl') then
    begin
      AssignFile(PLFile, ParamStr(i));
      Reset(PLFile);
      PlayList.Clear;
      while not EOF(PLFile) do
      begin
        Readln(PLFile, Line);
        if (Length(Line) > 0) and (RightStr(Line, 4) = '.txt') then
          PlayList.Items.Add(Line);
      end;
      CloseFile(PLFile);
    end;
  end;

  MenuItemSync.Enabled := false;

  If StartupAllowRemoteControl then
    FServer := THTTPServerThread.Create(8001, @DoHandleRequest);

  WordsForm.PopulateDefaultBG(BGImage);

{$IFDEF WINDOWS}
  If GlobalHotkeys then
  begin
    If not RegisterHotKey(Handle, 111000, MOD_CONTROL + MOD_ALT, VK_Insert) then
      ShowMessage('Hotkey "Show" not registered.');
    If not RegisterHotKey(Handle, 111001, MOD_CONTROL + MOD_ALT, VK_Next) then
      ShowMessage('Hotkey "Next" not registered.');
    If not RegisterHotKey(Handle, 111002, MOD_CONTROL + MOD_ALT, VK_Prior) then
      ShowMessage('Hotkey "Prev" not registered.');
    If not RegisterHotKey(Handle, 111003, MOD_CONTROL + MOD_ALT, VK_End) then
      ShowMessage('Hotkey "End" not registered.');
    If not RegisterHotKey(Handle, 111004, MOD_CONTROL + MOD_ALT, VK_Home) then
      ShowMessage('Hotkey "Home" not registered.');
  end;
{$ENDIF}
end;

procedure TControlForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  SongIndex.Clear;
  SongWords.Clear;
  for i := 0 to (Length(Song) - 1) do
  begin
    Song[i].Clear;
    SongFmt[i].Clear;
  end;
  Verse.Clear;
  VerseFmt.Clear;
  PlayOrder.Clear;

  SongShowConfig.SetValue('DBVersion', DBVersion);
  SongShowConfig.SetValue('SongDirectory', WideString(SongDirectory));
  SongShowConfig.SetValue('DataDir', WideString(DataDir));
  SongShowConfig.SetValue('FontName', WideString(FontName));
  SongShowConfig.SetValue('ChorusFont', WideString(ChorusFont));
  SongShowConfig.SetValue('TextFont', WideString(TextFont));
  SongShowConfig.SetValue('FontSize', FontSize);
  SongShowConfig.SetValue('TextFontSize', TextFontSize);
  SongShowConfig.SetValue('TopMargin', TopMargin);
  SongShowConfig.SetValue('LeftMargin', LeftMargin);
  SongShowConfig.SetValue('BottomMargin', BottomMargin);
  SongShowConfig.SetValue('RightMargin', RightMargin);
  SongShowConfig.SetValue('LinesPerScreen', LinesPerScreen);
  SongShowConfig.SetValue('TextLinesPerScreen', TextLinesPerScreen);
  SongShowConfig.SetValue('BottomSpace', BottomSpace);
  SongShowConfig.SetValue('WindowTop', ControlForm.Top);
  SongShowConfig.SetValue('WindowLeft', ControlForm.Left);
  SongShowConfig.SetValue('TopWords', TopWords);
  SongShowConfig.SetValue('LeftWords', LeftWords);
  SongShowConfig.SetValue('HeightWords', HeightWords);
  SongShowConfig.SetValue('WidthWords', WidthWords);
  SongShowConfig.SetValue('LineIndent', LineIndent);
  SongShowConfig.SetValue('FGColour', FGColour);
  SongShowConfig.SetValue('BGColour', BGColour);
  SongShowConfig.SetValue('OLColour', OLColour);
  SongShowConfig.SetValue('OLSize', OLSize);
  SongShowConfig.SetValue('BGimage', WideString(BGimage));
  SongShowConfig.SetValue('ShowBorder', ShowBorder);
  SongShowConfig.SetValue('AutoMerge', AutoMerge);
  SongShowConfig.SetValue('AllowRemoteControl', AllowRemoteControl);
  SongShowConfig.SetValue('GlobalHotkeys', GlobalHotkeys);
  SongShowConfig.SetValue('CCLNo', WideString(CCLNo));
  SongShowConfig.SetValue('SyncURL', WideString(SyncURL));
  SongShowConfig.SetValue('SyncUser', WideString(SyncUser));
  SongShowConfig.SetValue('SyncPass', WideString(SyncPass));
  SongShowConfig.SetValue('LastSync', WideString(LastSync));
  SongShowConfig.SetValue('DefaultBibleId', DefaultBibleId);
  SongShowConfig.SetValue('SecondaryBibleId', SecondaryBibleId);
  SongShowConfig.SetValue('TertiaryBibleId', TertiaryBibleId);
  SongShowConfig.SetValue('BiblePrimarySplit', BiblePrimarySplit);
  SongShowConfig.SetValue('SplitDir', WideString(SplitDir));
  SongShowConfig.SetValue('NewLinePerVerse', NewLinePerVerse);
  SongShowConfig.SetValue('HorizSplitGap', HorizSplitGap);
  SongShowConfig.Flush();

  DBConnection.Close;

  If StartupAllowRemoteControl then
    FServer.Terminate;
{$IFDEF WINDOWS}
  UnregisterHotKey(Handle, 111000);
  UnregisterHotKey(Handle, 111001);
  UnregisterHotKey(Handle, 111002);
  UnregisterHotKey(Handle, 111003);
{$ENDIF}
end;

procedure TControlForm.FormShow(Sender: TObject);
begin
  ControlForm.Top := WindowTop;
  ControlForm.Left := WindowLeft;
end;

procedure TControlForm.AddVerseToSong(CurrentItem: string; AutoAmend: boolean);
var
  SearchItem: string;
  i: integer;
begin
  if Verse.Count > 0 then
  begin
    SongIndex.Append(CurrentItem);
    i := SongIndex.Count;
    SetLength(Song, i);
    Song[i - 1] := TStringList.Create;
    Song[i - 1].Assign(Verse);
    SetLength(SongFmt, i);
    SongFmt[i - 1] := TStringList.Create;
    SongFmt[i - 1].Assign(VerseFmt);
    SetLength(ScreenBGImgs, i);
    ScreenBGImgs[i - 1] := ScreenBGImg;

    if (Copy(CurrentItem, Length(CurrentItem), 1) = 'a') and (AutoAmend) then
    begin // we're adding an "extra part" to a verse - add it to the play order
      SearchItem := Copy(CurrentItem, 1, Length(CurrentItem) - 1);
      i := 0;
      while (i < PlayOrder.Count) do
      begin
        if PlayOrder.Strings[i] = SearchItem then
        begin
          if i = (PlayOrder.Count - 1) then
            PlayOrder.Append(CurrentItem)
          else
            PlayOrder.Insert(i + 1, CurrentItem);
          if LoopStart > i then
            LoopStart := LoopStart + 1;
          if LoopEnd >= i then
            LoopEnd := LoopEnd + 1;
          if LastItem > i then
            LastItem := LastItem + 1;
        end;
        i := i + 1;
      end;
    end;
  end;
end;

procedure TControlForm.AddVerseToSec();
var
  i: integer;
begin
  i := SongIndex.Count;
  SetLength(SecBible, i);
  SecBible[i - 1] := TStringList.Create;
  SecBible[i - 1].Assign(SecVerse);
  SetLength(SecBibleFmt, i);
  SecBibleFmt[i - 1] := TStringList.Create;
  SecBibleFmt[i - 1].Assign(SecVerseFmt);
end;

procedure TControlForm.AddVerseToThird();
var
  i: integer;
begin
  i := SongIndex.Count;
  SetLength(ThirdBible, i);
  ThirdBible[i - 1] := TStringList.Create;
  ThirdBible[i - 1].Assign(ThirdVerse);
  SetLength(ThirdBibleFmt, i);
  ThirdBibleFmt[i - 1] := TStringList.Create;
  ThirdBibleFmt[i - 1].Assign(ThirdVerseFmt);
end;

procedure TControlForm.CheckVerseLen(var CurrentItem: string; CurLinesPerScreen: integer; var LastBreakPoint: integer);
var
  OrphanCheck: boolean;
begin
  OrphanCheck := True;
  if (Verse.Count = 1) and (LastBreakPoint > 0) then
    // We've added the first line to an "extra" screen and there was a potential break point
  begin
    MoveLinesFwd(CurrentItem, LastBreakPoint);
    LastBreakPoint := -1;
  end;
  while (Copy(VerseFmt[0], 1, 1) = 'R') and (OrphanCheck) do
  begin
    if (Song[SongIndex.IndexOf(Copy(CurrentItem, 1, Length(CurrentItem) - 1))].Count > 2)
    then  // We have more than 2 lines on the previous screen
      if (LastBreakPoint > 0) then
        // There's a break point - use that
        MoveLinesFwd(CurrentItem, LastBreakPoint)
      else
        MoveLinesFwd(CurrentItem,
          Song[SongIndex.IndexOf(Copy(CurrentItem, 1, Length(CurrentItem) - 1))].Count - 2)
    else
      OrphanCheck := False;
  end;
  if Verse.Count > CurLinesPerScreen then
  begin

  end;
  if Verse.Count = CurLinesPerScreen then
  begin
    if CurrentItem = 'V1' then
      Title := Verse[0] + ' - ' + Title;
    if CurrentItem = 'V' then
      Title := Verse[0] + ' - ' + Title;
    if CurrentItem = 'C1' then
      Title := Title + Verse[0];
    if CurrentItem = 'C' then
      Title := Title + Verse[0];
    if CurrentItem = 'CH1' then
      Title := Title + Verse[0];
    if CurrentItem = 'CH' then
      Title := Title + Verse[0];
    AddVerseToSong(CurrentItem, True);
    Verse.Clear;
    VerseFmt.Clear;
    CurrentItem := CurrentItem + 'a';
  end;
end;

procedure TControlForm.IndexSong(FileName: string; Directory : string; Central: integer; SongUpdated: integer; var NumUpdated: integer; Force : integer; Select : boolean);
var
  SongId, WordId, i, FileDate: integer;
  SongFile: TextFile;
  Line, word, CurrentItem, FirstLine, Chorus, ItemWords: string;
  UpdateFile, InText, RealChorus: boolean;
begin
  UpdateFile := True;
  if FileExists(SongDirectory + Directory + FileName) then
  begin
    FileDate := FileAge(SongDirectory + Directory + FileName);
    SQLMainQuery.SQL.Text := 'SELECT songId, filedate, central FROM songs WHERE directory = "'+Directory+'" AND filename = "' + FileName + '";';
    SQLMainQuery.Open;
    if SQLMainQuery.EOF then
    begin
      SQLMainQuery.Close;

      SQLUpdateQuery.SQL.Text := 'INSERT INTO songs (filename, directory, filedate, central, updated) VALUES (:FILENAME, :DIRECTORY, :FILEDATE, :CENTRAL, :UPDATED)';
      SQLUpdateQuery.Params.ParamByName('FILENAME').AsString := FileName;
      SQLUpdateQuery.Params.ParamByName('DIRECTORY').AsString := Directory;
      SQLUpdateQuery.Params.ParamByName('FILEDATE').AsInteger := FileDate;
      SQLUpdateQuery.Params.ParamByName('CENTRAL').AsInteger := Central;
      SQLUpdateQuery.Params.ParamByName('UPDATED').AsInteger := SongUpdated;
      SQLUpdateQuery.ExecSQL;
      SQLTransaction1.Commit;

      SQLMainQuery.SQL.Text := 'SELECT last_insert_rowid() AS songId, :CENTRAL AS central';
      SQLMainQuery.Params.ParamByName('CENTRAL').AsInteger := Central;
      SQLMainQuery.Open;
      If Directory <> '' then
      begin
        If FilesList.Items.IndexOf(FileName + ' (' + Directory + ')') < 0 then
          FilesList.Items.Add(FileName + ' (' + Directory + ')');
      end
      else
        If FilesList.Items.IndexOf(FileName) < 0 then
          FilesList.Items.Add(FileName);
      If Select then
      begin
        FilesList.ClearSelection;
        If Directory <> '' then
          FilesList.Selected[FilesList.Items.IndexOf(FileName + ' (' + Directory + ')')] := true
        else
          FilesList.Selected[FilesList.Items.IndexOf(FileName)] := true;
      end;
    end
    else
    if SQLMainQuery.FieldByName('filedate').AsInteger >= FileDate then
    begin
      UpdateFile := False;
      SongUpdated := 0;
    end;
    SongId := SQLMainQuery.FieldByName('songId').AsInteger;
    // Coming here from saving an edit, we don't know if it's central or not so lookup existing status.  If we're coming here from a sync then Central will be 1
    If Central = 0 then
      Central := SQLMainQuery.FieldByName('central').AsInteger;
    SQLMainQuery.Close;

    if (UpdateFile) or (Force = 1) then
    begin
      AssignFile(SongFile, SongDirectory + Directory + FileName);
      Reset(SongFile);
      InText := False;
      SQLMainQuery.SQL.Text := 'DELETE FROM songWords WHERE songId = :SONGID;';
      SQLMainQuery.Params.ParamByName('SONGID').AsInteger := songId;
      SQLMainQuery.ExecSQL;
      SQLMainQuery.SQL.Text := 'DELETE FROM songPhrases WHERE songId = :SONGID;';
      SQLMainQuery.Params.ParamByName('SONGID').AsInteger := songId;
      SQLMainQuery.ExecSQL;
      SQLMainQuery.SQL.Text := 'SELECT freq FROM songWords WHERE songId = :SONGID AND wordId = :WORDID';
      SQLMainQuery.Params.ParamByName('SONGID').AsInteger := songId;
      SQLInsertQuery.SQL.Text := 'INSERT INTO songWords (songId, wordId, freq) VALUES (:SONGID, :WORDID, 1);';
      SQLInsertQuery.Params.ParamByName('SONGID').AsInteger := songId;
      SQLUpdateQuery.SQL.Text := 'UPDATE songWords SET freq = freq + 1 WHERE songId = :SONGID AND wordId = :WORDID;';
      SQLUpdateQuery.Params.ParamByName('SONGID').AsInteger := songId;
      SQLWordFind.SQL.Text := 'SELECT wordId FROM words WHERE word = :WORD';
      SQLWordIns.SQL.Text := 'INSERT INTO words (word) VALUES (:WORD)';
      SQLLastId.SQL.Text := 'SELECT last_insert_rowid() AS wordId';
      SQLPhraseQuery.SQL.Text := 'INSERT INTO songPhrases (songId, itemCode, phrase) VALUES (:SONGID, :ITEMCODE, :PHRASE)';
      FirstLine := '';
      Chorus := '';
      ItemWords := '';
      RealChorus := False;
      CurrentItem := '';
      while not EOF(SongFile) do
      begin
        Readln(SongFile, Line);
        Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
        if Copy(Line, 1, 2) = '</' then
        begin
          InText := False;
          if ((ItemWords <> '') and (CurrentItem <> '')) then
          begin
            SQLPhraseQuery.Params.ParamByName('SONGID').AsInteger := songId;
            SQLPhraseQuery.Params.ParamByName('ITEMCODE').AsString := CurrentItem;
            SQLPhraseQuery.Params.ParamByName('PHRASE').AsString := ItemWords;
            SQLPhraseQuery.ExecSQL;
          end;
        end
        else
        if Copy(Line, 1, 1) = '<' then
        begin
          InText := True;
          CurrentItem := LowerCase(Copy(Line, 2, Pos('>', Line) - 2));
          ItemWords := '';
        end
        else
        begin
          if (InText and (CurrentItem <> 'copy')) then
          begin
            if (CurrentItem = 'v') or (CurrentItem = 'v1') then
            begin
              if (FirstLine = '') then
                FirstLine := Line;
              if (Copy(Line, 1, 1) = '{') and (Chorus = '') then
              begin
                if RightStr(Line, 1) = '}' then
                  Line := Copy(Line, 2, Length(Line) - 2);
                Chorus := Line;
              end;
            end;
            if ((Chorus = '') or (RealChorus = False)) and
              ((CurrentItem = 'c') or (CurrentItem = 'c1') or (CurrentItem = 'ch') or (CurrentItem = 'ch1')) then
            begin
              Chorus := Line;
              RealChorus := True;
            end;
            Line := StripPunct(LowerCase(Line));
            Line := Trim(Line) + ' ';
            i := Pos(' ', Line);
            while i > 0 do
            begin
              word := Trim(Copy(Line, 1, i - 1));
              if (word <> '') then
              begin
                SQLWordFind.Params.ParamByName('WORD').AsString := word;
                SQLWordFind.Open;
                if SQLWordFind.EOF then
                begin
                  SQLWordIns.Params.ParamByName('WORD').AsString := word;
                  SQLWordIns.ExecSQL;
                  SQLLastId.Open;
                  WordId := SQLLastId.FieldByName('wordId').AsInteger;
                  SQLLastId.Close;
                end
                else
                  WordId := SQLWordFind.FieldByName('wordId').AsInteger;
                SQLWordFind.Close;
                SQLMainQuery.Params.ParamByName('WORDID').AsInteger := WordId;
                SQLMainQuery.Open;
                if SQLMainQuery.EOF then
                begin
                  SQLInsertQuery.Params.ParamByName('WORDID').AsInteger := WordId;
                  SQLInsertQuery.ExecSQL;
                end
                else
                begin
                  SQLUpdateQuery.Params.ParamByName('WORDID').AsInteger := WordId;
                  SQLUpdateQuery.ExecSQL;
                end;
                SQLMainQuery.Close;
                if (ItemWords <> '') then
                  ItemWords := ItemWords + ',';
                ItemWords := ItemWords + IntToStr(WordId);
              end;
              Line := Copy(Line, i + 1, Length(Line) - i);
              i := Pos(' ', Line);
            end;
          end;
        end;
      end;
      SQLUpdateQuery.SQL.Text := 'UPDATE songs SET firstline = :FIRSTLINE, chorus = :CHORUS, filedate = :FILEDATE, central = :CENTRAL, updated = :UPDATED, firstlinenopunct = :FIRSTNP, chorusnopunct = :CHORUSNP WHERE songId = :SONGID';
      SQLUpdateQuery.Params.ParamByName('FIRSTLINE').AsString := FirstLine;
      SQLUpdateQuery.Params.ParamByName('FIRSTNP').AsString := StripPunct(FirstLine);
      SQLUpdateQuery.Params.ParamByName('CHORUS').AsString := Chorus;
      SQLUpdateQuery.Params.ParamByName('CHORUSNP').AsString := StripPunct(Chorus);
      SQLUpdateQuery.Params.ParamByName('SONGID').AsInteger := SongId;
      SQLUpdateQuery.Params.ParamByName('FILEDATE').AsInteger := FileDate;
      SQLUpdateQuery.Params.ParamByName('CENTRAL').AsInteger := Central;
      SQLUpdateQuery.Params.ParamByName('UPDATED').AsInteger := SongUpdated;
      SQLUpdateQuery.ExecSQL;
      SQLTransaction1.Commit;
      CloseFile(SongFile);
      NumUpdated := NumUpdated + 1;
    end;
  end;
end;

procedure TControlForm.LoadSong(Sender: TObject; Reload: boolean);
var
  SongFile: TextFile;
  Line, Line2, Line3, OrigLine: string;
  CurrentItem, NextItem, FileName, Directory: string;
  VerseWords: string;
  CurrentIndex, NextIndex, i, j, k, l, m, LineWid, ContLine, Margin, InLoop,
  IndentExtra, CalcLinesPerScreen, LastBreakPoint, ThisBreakPoint, CurLinesPerScreen,
  Chapter1, Verse1, Chapter2, Verse2, BibleId, Splt: integer;
  CurrentChar, ItalLine, FontType: char;
  ScripUsed : boolean;
begin
  if FileExists(SongFileName) then
  begin
    CurrentBGimage := '';
    SongIndex.Clear;
    SongWords.Clear;
    ScripUsed := false;
    for i := 0 to Length(Song) - 1 do
    begin
      Song[i].Clear;
      SongFmt[i].Clear;
    end;
    for i := 0 to Length(SecBible) - 1 do
    begin
      if SecBible[i] <> nil then
      begin
        SecBible[i].Clear;
        SecBibleFmt[i].Clear;
      end;
    end;
    for i := 0 to Length(ThirdBible) - 1 do
    begin
      if ThirdBible[i] <> nil then
      begin
        ThirdBible[i].Clear;
        ThirdBibleFmt[i].Clear;
      end;
    end;
    Verse.Clear;
    VerseFmt.Clear;
    SecVerse.Clear;
    SecVerseFmt.Clear;
    ThirdVerse.Clear;
    ThirdVerseFmt.Clear;
    PlayOrder.Clear;
    CopyRight := '';
    AssignFile(SongFile, SongFileName);
    Reset(SongFile);
    CurrentItem := '';
    CurrentIndex := -1;
    LoopEnd := -1;
    LoopStart := 0;
    LastItem := -1;
    LastBreakPoint := -1;
    ThisBreakPoint := 0;
    InLoop := 0;
    Readln(SongFile, Line);
    Line := UpperCase(Line);
    LWarning.Caption := '';
    Title := '';
    CCLSong := 0;
    FirstVerseType := '';
    ScreenBGImg := '';

    if Copy(Line, 1, 1) = '<' then
    begin
      // If we've got an '<' then this is a tag not a play list - reset the file for the main verse reading.
      Reset(SongFile);
    end
    else
    begin
      // Otherwise the first line is the play list
      // If it's blank then nothing will get loaded and therefore it will be a blank list
      // dealt with lower down
      for i := 1 to length(Line) do
      begin
        CurrentChar := Copy(Line, i, 1)[1];
        case CurrentChar of
          ',':
          begin
            if CurrentItem <> '' then
            begin
              CurrentIndex := PlayOrder.Add(CurrentItem);
              if (FirstVerseType = '') or (LoopStart = CurrentIndex) then
                FirstVerseType := Copy(CurrentItem, 0, 1);
              CurrentItem := '';
            end;
          end;
          // When setting the loop start and end points, CurrentIndex is pointing at the previous item
          '[': LoopStart := CurrentIndex + 1;
          ']': LoopEnd := CurrentIndex + 1;
          else
            CurrentItem := CurrentItem + CurrentChar;
        end;
      end;
      // If there's anything left in CurrentItem, add it to the play order
      if CurrentItem <> '' then
        CurrentIndex := PlayOrder.Add(CurrentItem);
      LastItem := CurrentIndex;
      // If we haven't set the end of the loop then assume it's the end of the song
      if LoopEnd = -1 then
        LoopEnd := CurrentIndex;
    end;

    while not EOF(SongFile) do
    begin
      Readln(SongFile, Line);
      Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
      ContLine := 0;
      ThisBreakPoint := 0;
      if Copy(Line, 1, 1) = '<' then
      begin
        OrigLine := Line;
        Line := UpperCase(Line);
        LastBreakPoint := -1;
        if Copy(Line, 2, 1) = '/' then
        begin
          if CurrentItem <> '' then
          begin
            case CurrentItem of
              'COPY' :
              begin
                CopyRight := '';
                for i := 0 to (Verse.Count - 1) do
                  CopyRight := CopyRight + Verse[i] + LineEnding;
              end;

              'CCL' :
              begin
                if (CCLEvent <> '') then
                begin
                  CopyRight := CopyRight + 'CCL Licence nº ' + CCLNo + LineEnding;
                  CCLSong := 1;
                end;
              end;

              'BGIMG' : CurrentBGimage := Verse[0];

              otherwise
              begin
                if (CurrentItem = 'V1') or (CurrentItem = 'V') then
                  Title := Verse[0] + ' - ' + Title;
                if (CurrentItem = 'C1') or (CurrentItem = 'C') or (CurrentItem = 'CH1') or (CurrentItem = 'CH') then
                  Title := Title + Verse[0];
                AddVerseToSong(CurrentItem, True);
                If (SecondaryBibleId > 0) and (SecVerse.Count > 0) then
                  AddVerseToSec();
                If (TertiaryBibleId > 0) and (ThirdVerse.Count > 0) then
                  AddVerseToThird();
                LastBreakPoint := -1;
                ThisBreakPoint := 0;
                CurrentItem := '';
              end;
            end;
          end;
        end
        else
        begin
          ScreenBGImg := '';
          if ((Pos(' ', Line)) > 0) and (Pos(' ', Line) < Pos('>', Line)) then
          begin
            CurrentItem := Copy(Line, 2, Pos(' ', Line) - 2);
            i := Pos('BGIMG="', Line);
            if (i > 0) then
              ScreenBGImg := Copy(OrigLine, i + 7, Pos('"', line, i + 7) - i - 7);
          end
          else
            CurrentItem := Copy(Line, 2, Pos('>', Line) - 2);
          Verse.Clear;
          VerseFmt.Clear;
          SecVerse.Clear;
          SecVerseFmt.Clear;
          ThirdVerse.Clear;
          ThirdVerseFmt.Clear;
          if ((Copy(CurrentItem, 1, 4) = 'TEXT') or (Copy(CurrentItem, 1, 5) = 'SCRIP')) then
          begin
            CalcLinesPerScreen := (WordsForm.Height - TopMargin - BottomMargin) div TextFontSize;
            if (CalcLinesPerScreen > TextLinesPerScreen) then
              CurLinesPerScreen := TextLinesPerScreen
            else
              CurLinesPerScreen := CalcLinesPerScreen
          end
          else
          begin
            CalcLinesPerScreen := (WordsForm.Height - TopMargin - BottomMargin) div FontSize;
            if (CalcLinesPerScreen > LinesPerScreen) then
              CurLinesPerScreen := LinesPerScreen
            else
              CurLinesPerScreen := CalcLinesPerScreen;
          end;
        end;
      end
      else
      begin
        if CurrentItem <> '' then
        begin
          IndentExtra := 1;
          if Copy(Line, 1, 1) = '{' then
          begin
            InLoop := 1;
            Line := Copy(Line, 2, Length(Line) - 1);
          end;
          if Copy(Line, Length(Line), 1) = '}' then
          begin
            InLoop := 2;
            Line := Copy(Line, 1, Length(Line) - 1);
          end;
          if Copy(Line, 1, 1) = '|' then
          begin
            IndentExtra := 0;
            Line := Copy(Line, 2, Length(Line) - 1);
          end;
          if Copy(Line, Length(Line), 1) = '|' then
          begin
            ThisBreakPoint := 1;
            Line := Copy(Line, 1, Length(Line) - 1);
          end;
          if Copy(CurrentItem, 1, 1) = 'C' then
            if InLoop > 0 then
              ItalLine := ' ' // Chorus 'subloop'
            else
              ItalLine := 'I' // Italic on choruses
          else
          if InLoop > 0 then
            ItalLine := 'I' // Verse 'subloop'
          else
            ItalLine := ' '; // Normal otherwise

          if CurrentItem = 'COPY' then
          begin
            WordsForm.vf.Name := FontName;
            WordsForm.vf.Style := [];
            WordsForm.vf.FullHeight := Round(FontSize / 2);
            FontType := 'N';
          end
          else
          begin
            if Copy(CurrentItem, 1, 1) = 'C' then
            begin
              WordsForm.vf.Name := ChorusFont;
              FontType := 'C';
            end
            else
            begin
              WordsForm.vf.Name := FontName;
              FontType := 'N';
            end;
            if (ItalLine = 'I') then
              WordsForm.vf.Style := [fsItalic, fsBold]
            else
              WordsForm.vf.Style := [fsBold];
            if ((Copy(CurrentItem, 1, 4) = 'TEXT') or (Copy(CurrentItem, 1, 5) = 'SCRIP')) then
            begin
              WordsForm.vf.FullHeight := TextFontSize;
              WordsForm.vf.Name := TextFont;
              FontType := 'T';
            end
            else
              WordsForm.vf.FullHeight := FontSize;
          end;

          If (Copy(CurrentItem, 1, 5) = 'SCRIP') then
          begin
            if Length(Line) > 5 then
            begin
              i := Pos('|', Line);  // Scripture format book|chapter1:verse1-chapter2:verse2|biblename
              j := Pos('|', Copy(Line, i + 1, Length(line) - i));
              if (j > 0) then
              begin
                Line2 := Copy(Line, 1, i - 1) + ' ' + Copy(Line, i + 1, j - 1);
                SQLMainQuery.SQL.Text := 'SELECT bibleId FROM bibles WHERE bibleName = :BIBLENAME';
                SQLMainQuery.Params.ParamByName('BIBLENAME').AsString := Copy(Line, i + j + 1, Length(Line) - i - j);
                SQLMainQuery.Open;
                If not SQLMainQuery.EOF then
                  BibleId := SQLMainQuery.FieldByName('bibleId').AsInteger
                else
                  BibleId := DefaultBibleId;
                Line := Copy(Line, 1, i + j - 1);
                SQLMainQuery.Close;
              end
              else
              begin
                Line2 := Copy(Line, 1, i - 1) + ' ' + Copy(Line, i + 1, Length(Line) - i);
                BibleId := DefaultBibleId;
              end;
              CurrentIndex := Verse.Add(Line2);
              if (ItalLine = 'I') then
                VerseFmt.Append('L' + ' ' + FontType)
              else
                VerseFmt.Append('L' + 'I' + FontType);
              If (SecondaryBibleId > 0) and (SplitDir = 'H') then
              begin
                SecVerse.Add('');
                SecVerseFmt.Append('L ' + FontType);
              end;
              SQLMainQuery.SQL.Text := 'SELECT bookId FROM bibleBooks WHERE bibleId = :BIBLEID AND bookname = :BOOKNAME';
              SQLMainQuery.Params.ParamByName('BIBLEID').AsInteger := BibleId;
              SQLMainQuery.Params.ParamByName('BOOKNAME').AsString := Copy(Line, 1, i - 1);
              SQLMainQuery.Open;
              If not SQLMainQuery.EOF then
              begin
                j := Pos(':', Copy(Line, i+1, Length(Line) - i));
                SQLWordFind.SQL.Text := 'SELECT verse, verseWords FROM bibleVerse WHERE bibleId = :BIBLEID AND bookId = :BOOKID AND chapter = :CHAPTER AND verse >= :VERSE1 AND verse <= :VERSE2 ORDER BY verse';
                SQLPhraseQuery.SQL.Text := 'SELECT verseWords FROM bibleVerse WHERE bibleId = :BIBLEID AND bookId = :BOOKID AND chapter = :CHAPTER AND verse = :VERSE';
                SQLWordIns.SQL.Text := 'SELECT verseWords FROM bibleVerse WHERE bibleId = :BIBLEID AND bookId = :BOOKID AND chapter = :CHAPTER AND verse = :VERSE';
                SQLWordFind.Params.ParamByName('BIBLEID').AsInteger := BibleId;
                SQLPhraseQuery.Params.ParamByName('BIBLEID').AsInteger := SecondaryBibleId;
                SQLWordIns.Params.ParamByName('BIBLEID').AsInteger := TertiaryBibleId;
                SQLWordFind.Params.ParamByName('BOOKID').AsInteger := SQLMainQuery.FieldByName('bookId').AsInteger;
                SQLPhraseQuery.Params.ParamByName('BOOKID').AsInteger := SQLMainQuery.FieldByName('bookId').AsInteger;
                SQLWordIns.Params.ParamByName('BOOKID').AsInteger := SQLMainQuery.FieldByName('bookId').AsInteger;
                Chapter1 := StrToInt(Copy(Line, 1+i, j - 1));
                Chapter2 := Chapter1;
                k := Pos('-', Copy(Line, i+1+j, Length(Line) - (i + 1 + j)));
                if (k > 0) then
                begin
                  Verse1 := StrToInt(Copy(Line, i+1+j, k - 1));
                  l := Pos(':', Copy(Line, i + 1 + j + k, Length(Line) - (i + j + k)));
                  if (l > 0) then
                  begin
                    Chapter2 := StrToInt(Copy(Line, i + 1 + j + k, l - 1));
                    Verse2 := StrToInt(Copy(Line, i + 1 + j + k + l, Length(Line) - (i + j + k + l)));
                  end
                  else
                  begin
                    Verse2 := StrToInt(Copy(Line, i + 1 + j + k, Length(Line) - (i + j + k)));
                  end;
                end
                else
                begin
                  Verse1 := StrToInt(Copy(Line, i + 1 + j, Length(Line) - (i + j)));
                  Verse2 := StrToInt(Copy(Line, i + 1 + j, Length(Line) - (i + j)));
                end;

                If (Chapter2 < Chapter1) then
                  Chapter2 := Chapter1;
                If ((Chapter2 = Chapter1) and (Verse2 < Verse1)) then
                  Verse2 := Verse1;

                Line := '';
                Line2 := '';
                Line3 := '';

                for m := Chapter1 to Chapter2 do
                begin
                  SQLWordFind.Params.ParamByName('CHAPTER').AsInteger := m;
                  SQLPhraseQuery.Params.ParamByName('CHAPTER').AsInteger := m;
                  SQLWordIns.Params.ParamByName('CHAPTER').AsInteger := m;
                  If (m = Chapter1) then
                    SQLWordFind.Params.ParamByName('VERSE1').AsInteger := Verse1
                  else
                    SQLWordFind.Params.ParamByName('VERSE1').AsInteger := 1;
                  If (m = Chapter2) then
                    SQLWordFind.Params.ParamByName('VERSE2').AsInteger := Verse2
                  else
                    SQLWordFind.Params.ParamByName('VERSE2').AsInteger := 999;  // There's no chapters with this many verses
                  SQLWordFind.Open;
                  While not SQLWordFind.EOF do
                  begin
                    If (SecondaryBibleId > 0) then
                    begin
                      SQLPhraseQuery.Params.ParamByName('VERSE').AsInteger := SQLWordFind.FieldByName('verse').AsInteger;
                      SQLPhraseQuery.Open;
                      If not(SQLPhraseQuery.EOF) then
                        Line2 := '^'+IntToStr(SQLWordFind.FieldByName('verse').AsInteger)+SQLPhraseQuery.FieldByName('verseWords').AsString+' ';
                      SQLPhraseQuery.Close;
                      If (TertiaryBibleId > 0) then
                      begin
                        SQLWordIns.Params.ParamByName('VERSE').AsInteger := SQLWordFind.FieldByName('verse').AsInteger;
                        SQLWordIns.Open;
                        If not(SQLWordIns.EOF) then
                          Line3 := '^'+IntToStr(SQLWordFind.FieldByName('verse').AsInteger)+SQLWordIns.FieldByName('verseWords').AsString+' ';
                        SQLWordIns.Close;
                      end;
                    end;
                    Line := '^'+IntToStr(SQLWordFind.FieldByName('verse').AsInteger)+SQLWordFind.FieldByName('verseWords').AsString + ' ';
                    AddScripLines(CurrentItem, CurrentIndex, CurLinesPerScreen, Line, Line2, Line3, ScripUsed);
                    ScripUsed := true;
                    SQLWordFind.Next;
                  end;
                  SQLWordFind.Close;
                end;
              end;
              SQLMainQuery.Close;
            end;
          end
          else
          begin
            LineWid := Round(WordsForm.vf.GetTextSize(StringReplace(Line, '^', '', [rfReplaceAll])).x);
            if LineWid > (WordsForm.Width - (LeftMargin + RightMargin)) then
            begin
              Margin := LeftMargin + RightMargin;
              Line2 := '';
              i := Pos(' ', Line);
              while i > 0 do
              begin
                if WordsForm.vf.GetTextSize(StringReplace(Line2 + Copy(Line, 1, i), '^', '', [rfReplaceAll])).x <
                  (WordsForm.Width - Margin) then
                begin
                  Line2 := Line2 + Copy(Line, 1, i);
                  Line := Copy(Line, i + 1, Length(Line));
                end
                else
                begin
                  CurrentIndex := Verse.Add(Line2);
                  if (ContLine = 0) or (IndentExtra = 0) then
                  begin
                    VerseFmt.Append('L' + ItalLine + FontType);
                    ContLine := 1;
                    if (IndentExtra = 1) then
                      Margin := LineIndent + LeftMargin + RightMargin;
                  end
                  else
                    VerseFmt.Append('R' + ItalLine + FontType);
                  CheckVerseLen(CurrentItem, CurLinesPerScreen, LastBreakPoint);
                  Line2 := Copy(Line, 1, i);
                  Line := Copy(Line, i + 1, Length(Line));
                end;
                i := Pos(' ', Line);
              end;
              // No more spaces found, Line2 is the start of the line and Line is the last word
              if WordsForm.vf.GetTextSize(StringReplace(Line2 + Line, '^', '', [rfReplaceAll])).x <
                (WordsForm.Width - Margin) then
                Line := Line2 + Line
              else
              if Length(Line2) > 0 then
              begin
                CurrentIndex := Verse.Add(Line2);
                if (ContLine = 0) or (IndentExtra = 0) then
                begin
                  VerseFmt.Append('L' + ItalLine + FontType);
                  ContLine := 1;
                end
                else
                  VerseFmt.Append('R' + ItalLine + FontType);
                CheckVerseLen(CurrentItem, CurLinesPerScreen, LastBreakPoint);
              end;
            end;
            // Either we've got the whole line here or we've got the remnant from a
            // multiline split.  If it's the second i.e. ContLine = 1 and the line is blank then we
            // don't want to add an extra line.
            if ((Length(Line) > 0) or (ContLine = 0)) then
            begin
              CurrentIndex := Verse.Add(Line);
              if (ContLine = 0) or (IndentExtra = 0) then
                VerseFmt.Append('L' + ItalLine + FontType)
              else
                VerseFmt.Append('R' + ItalLine + FontType);
              CheckVerseLen(CurrentItem, CurLinesPerScreen, LastBreakPoint);
            end;
            if InLoop = 2 then
              InLoop := 0;
          end;
        end;
      end;
      if (ThisBreakPoint = 1) then // The current line was marked as a break line
        LastBreakPoint := Verse.Count - 1;
    end;
    if (CCLSong = 0) AND (CCLEvent <> '') then
      LWarning.Caption := LWarning.Caption + 'No CCL marker ';
    CloseFile(SongFile);

    // If the play order isn't defined then just do everythig in order
    if PlayOrder.Count = 0 then
    begin
      PlayOrder.Assign(SongIndex);
      LoopStart := 0;
      LoopEnd := PlayOrder.Count - 1;
      LastItem := LoopEnd;
      FirstVerseType := Copy(SongIndex.Strings[0], 0, 1);
    end;

    // Clear play list of items not in the song file
    i := 0;
    while i < PlayOrder.Count do
    begin
      if SongIndex.IndexOf(PlayOrder[i]) = -1 then
      begin
        LWarning.Caption := LWarning.Caption + 'Missing ' + PlayOrder[i] + ' ';
        PlayOrder.Delete(i);
        if LoopStart > i then
          LoopStart := LoopStart - 1;
        if LoopEnd >= i then
          LoopEnd := LoopEnd - 1;
      end
      else
        i := i + 1;
    end;
    if (AutoMerge) and (not ScripUsed) then  // Look for screens we can merge
    begin
      i := 0;
      l := 0;
      while i < (PlayOrder.Count - 1) do
      begin
        k := 0;
        if (i < (LoopStart - 1)) or ((i >= LoopStart) and (i <= LoopEnd - 1)) or
          (i > LoopEnd) then
          // We can only merge if we've got 2 screens in the same chunk of the play sequence
        begin
          CurrentItem := PlayOrder[i];
          CurrentIndex := SongIndex.IndexOf(CurrentItem);
          NextItem := PlayOrder[i + 1];
          NextIndex := SongIndex.IndexOf(NextItem);

          if ((Song[CurrentIndex].Count + Song[NextIndex].Count) < CurLinesPerScreen) and (Copy(CurrentItem, Length(CurrentItem), 1) <> 'a') and (FirstVerseType = Copy(CurrentItem, 0, 1)) and ((l = 0) or (FirstVerseType <> Copy(NextItem, 0, 1))) then
          begin
            Verse.Clear;
            VerseFmt.Clear;
            Verse.Assign(Song[CurrentIndex]);
            VerseFmt.Assign(SongFmt[CurrentIndex]);
            Verse.Append('');
            VerseFmt.Append('L N');
            ScreenBGimg := ScreenBGimgs[CurrentIndex]; // Use custom background from first screen
            if ScreenBGimg = '' then
              ScreenBGimg := ScreenBGimgs[NextIndex]; // unless it's not set, in which case use the other
            for j := 0 to Song[NextIndex].Count - 1 do
            begin
              Verse.Append(Song[NextIndex].Strings[j]);
              VerseFmt.Append(SongFmt[NextIndex].Strings[j]);
            end;
            if (FirstVerseType <> Copy(NextItem, 0, 1)) then
              l := 1;
            CurrentItem := CurrentItem + '_' + NextItem;
            AddVerseToSong(CurrentItem, False);
            PlayOrder[i] := CurrentItem;
            if LoopStart > i then
              LoopStart := LoopStart - 1;
            if LoopEnd >= i then
              LoopEnd := LoopEnd - 1;
            PlayOrder.Delete(i + 1);
            LastItem := LastItem - 1;
            k := 1;
          end
          else
            l := 0;
        end;
        if (k = 0) then
          i := i + 1;
      end;
    end;
    // Populate view of PlayOrder here incase we've increased it with long verses or removed / merged any items
    SongSequence.Items.Assign(PlayOrder);
    LBCurrentMarker.Clear;
    for i := 0 to (SongSequence.Items.Count - 1) do
    begin
      if (i >= LoopStart) and (i <= LoopEnd) then
        SongSequence.Selected[i] := True;
      LBCurrentMarker.Items.Append('  ');
    end;
    WordsForm.PopulateSongBG(CurrentBGImage);
    WordsForm.InitialiseScreens();
    if (Reload) then
    begin
      i := 0;
      if (PlayOrder.Count > CurrentPLItem) then
        if (PlayOrder[CurrentPLItem] = CurrentPLItemName) then
        begin
          i := 1;
          VerseShow(CurrentPLItem)
        end;
      if (i = 0) then
        if PlayOrder.IndexOf(CurrentPLItemName) >= 0 then
          VerseShow(PlayOrder.IndexOf(CurrentPLItemName))
        else
          VerseShow(0);
    end
    else
      VerseShow(0);
    for i := 0 to (PlayOrder.Count - 1) do
    begin
      VerseWords := '';
      Verse.Assign(Song[SongIndex.IndexOf(PlayOrder[i])]);
      for j := 0 to (Verse.Count - 1) do
      begin
        Line := Verse[j];
        Line := StripPunct(LowerCase(Line));
        VerseWords := VerseWords + Trim(Line) + ' ';
      end;
      SongWords.Append(VerseWords);
    end;
    MenuItemPublish.Enabled:=false;
    if scripUsed then
      CurrentSongId := 0
    else
    begin
      Filename := Copy(SongFileName, Length(SongDirectory) + 1, Length(SongFileName) - Length(SongDirectory));
      Splt := Pos(PathDelim, Filename);
      Directory := '';
      If (Splt > 0) then
      begin
        Directory := Copy(Filename, 1, Splt);
        Filename := Copy(Filename, Splt + 1, Length(Filename) - Splt);
      end;
      SQLMainQuery.SQL.Text := 'SELECT songId, central FROM songs WHERE filename = :FILENAME AND directory = :DIRECTORY';
      SQLMainQuery.Params.ParamByName('FILENAME').AsString := Filename;
      SQLMainQuery.Params.ParamByName('DIRECTORY').AsString := Directory;
      SQLMainQuery.Open;
      if (not SQLMainQuery.EOF) then
      begin
        CurrentSongId := SQLMainQuery.FieldByName('songId').AsInteger;
        if (SQLMainQuery.FieldByName('central').AsInteger = 0) then
          MenuItemPublish.Enabled := true;
      end;
      SQLMainQuery.Close;
    end;
    ControlForm.Caption := 'Song Show - ' + Title + ' - ' + SongFileName;
    ShowButton.Enabled:=true;
    ControlForm.FocusControl(SongControl);
  end;
end;

procedure TControlForm.AddScripLines(var CurrentItem : string; var CurrentIndex : integer; CurLinesPerScreen : integer; Line, SecLine, ThirdLine : string; FirstDone : Boolean);
var
  Width1, Width2, Width3, Lines1, Lines2, Lines3, Needed1, Needed2, Needed3 : integer;
begin
  CurrentIndex := -1;
  Lines1 := CurLinesPerScreen - 1;
  Lines3 := Lines1;
  Width1 := WordsForm.Width - (LeftMargin + RightMargin);
  if SecondaryBibleId > 0 then
  begin
    if SplitDir = 'V' then
    begin
      If TertiaryBibleId > 0 then // Three bibles - always split 33% each way
      begin
        Lines1 := Round((CurLinesPerScreen - 1) / 3);
        Lines2 := Lines1;
        Lines3 := (CurLinesPerScreen - 1) - Lines1 - Lines2;
      end
      else
      begin
        Lines1 := Round((CurLinesPerScreen - 1) * BiblePrimarySplit / 100);
        Lines2 := (CurLinesPerScreen - 1) - Lines1;
      end;
      Width2 := Width1;
      Width3 := Width1;
    end
    else
    begin // Three bibles are always V split - Lines3 and Width3 just set to avoid compiler errors
      Width1 := Round((WordsForm.Width - (LeftMargin + RightMargin + HorizSplitGap)) * BiblePrimarySplit / 100);
      Width2 := WordsForm.Width - (LeftMargin + RightMargin + HorizSplitGap) - Width1;
      Width3 := Width2;
      Lines2 := Lines1;
    end;
  end;
  // If the current verse already has any lines, check the lines needed for the new verse
  Needed2 := 0;
  Needed3 := 0;
  If Verse.Count > 0 then
  begin
    // Count lines for primary bible
    If NewLinePerVerse then
      Needed1 := LinesNeeded(Line, Width1)
    else
      Needed1 := LinesNeeded(Verse[Verse.Count - 1]+' '+Line, Width1) - 1;
    If SecondaryBibleId > 0 then
    begin
      If NewLinePerVerse then
        Needed2 := LinesNeeded(SecLine, Width2)
      else
        If (SecVerse.Count > 0) then
          Needed2 := LinesNeeded(SecVerse[SecVerse.Count - 1]+' '+Line, Width2) - 1
        else
          Needed2 := LinesNeeded(SecLine, Width2);
      If TertiaryBibleId > 0 then
        If NewLinePerVerse then
          Needed3 := LinesNeeded(ThirdLine, Width3)
        else
          If (ThirdVerse.Count > 0) then
            Needed3 := LinesNeeded(ThirdVerse[ThirdVerse.Count - 1]+' '+Line, Width3) - 1
          else
            Needed3 := LinesNeeded(ThirdLine, Width3);
    end;
    // Do we have space for the new verse?  Verse.Count has 1 removed as we assume one line is taken for the reference on the first bible
    If (Needed1 > (Lines1 - (Verse.Count - 1))) or (Needed2 > (Lines2 - SecVerse.Count)) or (Needed3 > (Lines3 - ThirdVerse.Count)) then
    begin
      AddVerseToSong(CurrentItem, True);
      Verse.Clear;
      VerseFmt.Clear;
      If SecondaryBibleId > 0 then
      begin
        AddVerseToSec();
        SecVerse.Clear;
        SecVerseFmt.Clear;
      end;
      If TertiaryBibleId > 0 then
      begin
        AddVerseToThird();
        ThirdVerse.Clear;
        ThirdVerseFmt.Clear;
      end;
      CurrentItem := CurrentItem + 'a';
    end;
  end;

  AddScripText(Line, Width1, 1, FirstDone);
  If SecondaryBibleId > 0 then
    AddScripText(SecLine, Width2, 2, FirstDone);
  If TertiaryBibleId > 0 then
    AddScripText(ThirdLine, Width3, 3, FirstDone);

end;

function TControlForm.LinesNeeded(Line: string; DispWidth : integer): integer;
var
  LineWid, i, Needed : integer;
  Line2 : string;
begin
  Needed := 0;
  LineWid := Round(WordsForm.vf.GetTextSize(StringReplace(Line, '^', '', [rfReplaceAll])).x);
  if LineWid > Width then
  begin
    Line2 := '';
    i := Pos(' ', Line);
    while i > 0 do
    begin
      if WordsForm.vf.GetTextSize(StringReplace(Line2 + Copy(Line, 1, i), '^', '', [rfReplaceAll])).x < DispWidth then
      begin
        Line2 := Line2 + Copy(Line, 1, i);
        Line := Copy(Line, i + 1, Length(Line));
      end
      else
      begin
        Inc(Needed);
        Line2 := Copy(Line, 1, i);
        Line := Copy(Line, i + 1, Length(Line));
      end;
      i := Pos(' ', Line);
    end;
    // No more spaces found, Line2 is the start of the line and Line is the last word
    if WordsForm.vf.GetTextSize(StringReplace(Line2 + Line, '^', '', [rfReplaceAll])).x < DispWidth then
      Line := Line2 + Line
    else
    if Length(Line2) > 0 then
      Inc(Needed);
  end;
  if (Length(Line) > 0) then
    Inc(Needed);

  Result := Needed;
end;

procedure TControlForm.AddScripText(Line : string; DispWidth: integer; BibleNo : integer; FirstDone : boolean);
var
  LineWid, i : integer;
  Line2 : string;
begin
  If (not NewLinePerVerse) and (FirstDone) then
  begin
    Line2 := '';
    case BibleNo of
      1:
        begin
          If (Verse.Count > 0) then
          begin
            Line2 := Verse[Verse.Count - 1] + ' ';
            Verse.Delete(Verse.Count - 1);
          end;
        end;
      2:
        begin
          If (SecVerse.Count > 0) then
          begin
            Line2 := SecVerse[SecVerse.Count - 1] + ' ';
            SecVerse.Delete(SecVerse.Count - 1);
          end;
        end;
      3:
        begin
          If (ThirdVerse.Count > 0) then
          begin
            Line2 := ThirdVerse[ThirdVerse.Count - 1] + ' ';
            ThirdVerse.Delete(ThirdVerse.Count - 1);
          end;
        end;
    end;
    Line := Line2 + Line;
  end;
  LineWid := Round(WordsForm.vf.GetTextSize(StringReplace(Line, '^', '', [rfReplaceAll])).x);
  if LineWid > DispWidth then
  begin
    Line2 := '';
    i := Pos(' ', Line);
    while i > 0 do
    begin
      if WordsForm.vf.GetTextSize(StringReplace(Line2 + Copy(Line, 1, i), '^', '', [rfReplaceAll])).x < DispWidth then
      begin
        Line2 := Line2 + Copy(Line, 1, i);
        Line := Copy(Line, i + 1, Length(Line));
      end
      else
      begin
        case BibleNo of
          1:
          begin
            Verse.Add(Line2);
            VerseFmt.Append('S T');
          end;
          2:
          begin
            SecVerse.Add(Line2);
            SecVerseFmt.Append('S T');
          end;
          3:
          begin
            ThirdVerse.Add(Line2);
            ThirdVerseFmt.Append('S T');
          end;
        end;
        Line2 := Copy(Line, 1, i);
        Line := Copy(Line, i + 1, Length(Line));
      end;
      i := Pos(' ', Line);
    end;
    // No more spaces found, Line2 is the start of the line and Line is the last word
    if WordsForm.vf.GetTextSize(StringReplace(Line2 + Line, '^', '', [rfReplaceAll])).x < DispWidth then
      Line := Line2 + Line
    else
    if Length(Line2) > 0 then
    begin
      case BibleNo of
        1:
          begin
            Verse.Add(Line2);
            VerseFmt.Append('S T');
          end;
        2:
          begin
            SecVerse.Add(Line2);
            SecVerseFmt.Append('S T');
          end;
        3:
          begin
            ThirdVerse.Add(Line2);
            ThirdVerseFmt.Append('S T');
          end;
      end;
    end;
  end;
  if (Length(Line) > 0) then
  begin
    case BibleNo of
      1:
        begin
          Verse.Add(Line);
          VerseFmt.Append('S T');
        end;
      2:
        begin
          SecVerse.Add(Line);
          SecVerseFmt.Append('S T');
        end;
      3:
        begin
          ThirdVerse.Add(Line);
          ThirdVerseFmt.Append('S T');
        end;
    end;
  end;

end;

procedure TControlForm.MoveLinesFwd(CurrentItem: string; BreakPoint: integer);
var
  TmpVerse1, TmpVerseFmt1, TmpVerse2, TmpVerseFmt2: TStringList;
  i, LastItemIndex: integer;
begin
  LastItemIndex := SongIndex.IndexOf(Copy(CurrentItem, 1, Length(CurrentItem) - 1));
  if BreakPoint < Song[LastItemIndex].Count then
  begin
    TmpVerse1 := TStringList.Create;
    TmpVerseFmt1 := TStringList.Create;
    TmpVerse2 := TStringList.Create;
    TmpVerseFmt2 := TStringList.Create;
    TmpVerse1.Assign(Song[LastItemIndex]);
    TmpVerseFmt1.Assign(SongFmt[LastItemIndex]);
    TmpVerse2.Clear();
    TmpVerseFmt2.Clear();
    for i := 0 to BreakPoint do
    begin
      TmpVerse2.Append(TmpVerse1[i]);
      TmpVerseFmt2.Append(TmpVerseFmt1[i]);
    end;
    Song[LastItemIndex].Assign(TmpVerse2);
    SongFmt[LastItemIndex].Assign(TmpVerseFmt2);
    TmpVerse2.Clear();
    TmpVerseFmt2.Clear();
    for i := BreakPoint + 1 to TmpVerse1.Count - 1 do
    begin
      TmpVerse2.Append(TmpVerse1[i]);
      TmpVerseFmt2.Append(TmpVerseFmt1[i]);
    end;
    for i := 0 to Verse.Count - 1 do
    begin
      TmpVerse2.Append(Verse[i]);
      TmpVerseFmt2.Append(VerseFmt[i]);
    end;
    Verse.Assign(TmpVerse2);
    VerseFmt.Assign(TmpVerseFmt2);
    TmpVerse1.Clear;
    TmpVerse1.Destroy;
    TmpVerseFmt1.Clear;
    TmpVerseFmt1.Destroy;
    TmpVerse2.Clear;
    TmpVerse2.Destroy;
    TmpVerseFmt2.Clear;
    TmpVerseFmt2.Destroy;
  end;
end;


function TControlForm.StripPunct(Line: string): string;
var
  i: integer;
  Character, PlainLine: string;
begin
  PlainLine := '';
  for i := 1 to UTF8Length(Line) do
  begin
    Character := UTF8Copy(Line, i, 1);
    if (Character = 'á') or (Character = 'à') or (Character = 'â') or (Character = 'ä') or (Character = 'ă') or (Character = 'ã') or (Character = 'å') then
      Character := 'a';
    if Character = 'ç' then
      Character := 'c';
    if (Character = 'é') or (Character = 'è') or (Character = 'ê') or (Character = 'ë') then
      Character := 'e';
    if (Character = 'í') or (Character = 'ì') or (Character = 'î') or (Character = 'ï') then
      Character := 'i';
    if (Character = 'ñ') then
      Character := 'n';
    if (Character = 'ó') or (Character = 'ò') or (Character = 'ô') or (Character = 'ö') or (Character = 'õ') or (Character = 'ø') then
      Character := 'o';
    if (Character = 'ş') or (Character = 'ș') or (Character = 'ß') then
      Character := 's';
    if (Character = 'ţ') or (Character = 'ț') then
      Character := 't';
    if (Character = 'ú') or (Character = 'ù') or (Character = 'û') or (Character = 'ü') then
      Character := 'u';
    if Character[1] in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
      'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
      'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
      'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
      'W', 'X', 'Y', 'Z', ' '] then
      PlainLine := PlainLine + Character;
  end;
  Result := PlainLine;
end;

procedure TControlForm.VerseShow(PLItem: integer);
var
  CurrentItem, i: integer;
begin
  CurrentPLItem := PLItem;
  CurrentPLItemName := PlayOrder[PLItem];
  CurrentItem := SongIndex.IndexOf(CurrentPLItemName);
  Verse.Clear;
  if CurrentItem >= 0 then
  begin
    Verse.Assign(Song[CurrentItem]);
    VerseFmt.Assign(SongFmt[CurrentItem]);

    WordsForm.DrawScreen(PLItem);
    if (WordsForm.Visible) then
      WordsForm.FormPaint(ControlForm);

    for i := 0 to (LBCurrentMarker.Items.Count - 1) do
      if i = PLItem then
        LBCurrentMarker.Items[i] := '->'
      else
        LBCurrentMarker.Items[i] := '  ';
    CurrentPosition := PLItem;

    CurrVerse.Lines.Assign(Verse);
    CurrVerseLab.Caption := PlayOrder[PLItem];
    if PLItem > LoopStart then
    begin
      i := SongIndex.IndexOf(PlayOrder[PLItem - 1]);
      PrevVerse.Lines.Assign(Song[i]);
      PrevVerseLab.Caption := PlayOrder[PLItem - 1];
    end
    else
    begin
      PrevVerse.Lines.Clear;
      PrevVerseLab.Caption := '';
    end;

    if PLItem < LoopEnd then
    begin
      i := SongIndex.IndexOf(PlayOrder[PLItem + 1]);
      NextVerse.Lines.Assign(Song[i]);
      NextVerseLab.Caption := PlayOrder[PLItem + 1];
      WordsForm.DrawScreen(PLItem + 1);
    end
    else
    if PLItem < (PlayOrder.Count - 1) then
    begin
      i := SongIndex.IndexOf(PlayOrder[PLItem + 1]);
      NextVerse.Lines.Assign(Song[i]);
      NextVerseLab.Caption := PlayOrder[PLItem + 1];
      WordsForm.DrawScreen(PLItem + 1);
    end
    else
    begin
      NextVerse.Lines.Clear;
      NextVerseLab.Caption := '';
    end;
    SongSequence.TopIndex := PLItem;
    LBCurrentMarker.TopIndex := PLItem;
  end;
  LBCurrentMarker.ClearSelection;
end;

procedure TControlForm.FilesListDblClick(Sender: TObject);
var
  Reload: boolean;
  Filename : WideString;
  Splt : Integer;
begin
  Filename := WideString(FilesList.Items.Strings[FilesList.ItemIndex]);
  Splt := Pos('.txt (', Filename);
  If (Splt > 0) then
    Filename := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6)) + Copy(Filename, 1, Splt + 3);
  if SongFileName = SongDirectory + AnsiString(Filename) then
    Reload := True
  else
    Reload := False;
  SongFileName := SongDirectory + AnsiString(Filename);
  LoadSong(Sender, Reload);
end;

procedure TControlForm.FilesListKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  Filename : String;
  Splt : Integer;
begin
  if Key = VK_Insert then
  begin
    Filename := FilesList.Items.Strings[FilesList.ItemIndex];
    Splt := Pos('.txt (', Filename);
    If (Splt > 0) then
      Filename := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6)) + Copy(Filename, 1, Splt + 3);
    PlayList.Items.Add(Filename);
    Key := 0;
  end;
  if Key = VK_Return then
  begin
    FilesListDblClick(Sender);
    Key := 0;
  end;
end;

procedure TControlForm.FilesListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  If Button = mbLeft then
    FilesList.BeginDrag(false);
end;

procedure TControlForm.FilesPublishClick(Sender: TObject);
var
  Filename : string;
  Directory : string;
  Prompt : string;
  Splt : integer;
  Reply : integer;
begin
  If FilesList.ItemIndex = -1 then
    exit;
  Filename := FilesList.Items.Strings[FilesList.ItemIndex];
  Directory := '';
  Splt := Pos('.txt (', Filename);
  If (Splt > 0) then begin
    Directory := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6));
    Filename := Copy(Filename, 1, Splt + 3);
  end;

  SQLMainQuery.SQL.Text := 'SELECT songId FROM songs WHERE filename = :FILENAME AND directory = :DIRECTORY and central = 0';
  SQLMainQuery.Params.ParamByName('FILENAME').AsString := Filename;
  SQLMainQuery.Params.ParamByName('DIRECTORY').AsString := Directory;
  SQLMainQuery.Open;
  if not SQLMainQuery.EOF then
  begin
    Prompt := 'Publish song ' + Directory + Filename + '?';
    Reply := Application.MessageBox(PChar(Prompt),
    'Confirm Publish', MB_ICONQUESTION + MB_YESNO);
    if Reply = idYes then
      PublishSong(SQLMainQuery.FieldByName('songId').AsInteger);
  end;
  SQLMainQuery.Close;
end;

procedure TControlForm.FormActivate(Sender: TObject);
var
  HTTPClient : TFPHTTPClient;
  IPRegex : TRegExpr;
  RawData : string;
  Reply : integer;
begin
  if FirstRun then
  begin
    FirstRun := false;
    if SyncURL <> '' then
    begin
      try
        HTTPClient := TFPHTTPClient.Create(nil);
        IPRegex := TRegExpr.Create;
        try
          RawData := HTTPClient.Get('http://checkip.dyndns.org');
          IPRegex.Expression := RegExprString('\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');
          if IPRegex.Exec(RawData) then
          begin
            MenuItemSync.Enabled := true;
            Reply := Application.MessageBox('Internet access - do you want to sync songs?', 'Sync Songs', MB_ICONQUESTION + MB_YESNO);
            if Reply = IDYES then
              SyncSongs(0);
          end;
        except
          on E: Exception do
          begin
            LWarning.Caption := 'No internet access';
          end;
        end;
      finally
        HTTPClient.Free;
        IPRegex.Free;
      end;
    end;
  end;
end;

procedure TControlForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var PassKey: boolean;
begin
  PassKey := false;
  if NOT SongControl.Focused then
  begin
    if SearchString.Focused then
    begin
      if (Key = VK_Prior) or (Key = VK_Next) or (Key = VK_F5) then
        PassKey := true;
    end
    else
    begin
      if (FilesList.Focused) OR (ResultGrid.Focused) then
      begin
        if (Key = VK_Escape) or (Key = VK_F5) then
          PassKey := true;
      end
      else
        if (Key = VK_Prior) or (Key = VK_Next) or (Key = VK_End) or (Key = VK_Home) or (Key = VK_Escape) or (Key = VK_F5) then
          passKey := true;
    end;
    if PassKey then
    begin
      SongControlKeyDown(Sender, Key, Shift);
      Key := 0;
    end;
  end;
end;

procedure TControlForm.IdxExpButtonClick(Sender: TObject);
var
  IdxFile: TextFile;
  Line: string;
begin
  SaveDialog1.DefaultExt := '.csv';
  SaveDialog1.Title := 'Export Song Index';
  SaveDialog1.Filter := 'CSV File|*.csv';
  if (SaveDialog1.Execute) then
  begin
    AssignFile(IdxFile, SaveDialog1.FileName);
    Rewrite(IdxFile);
    SQLMainQuery.SQL.Text := 'SELECT filename, directory, firstline, chorus FROM songs WHERE firstline <> "" OR chorus <> "" ORDER BY firstline, chorus';
    SQLMainQuery.Open;
    writeln(IdxFile, '"First Line","Chorus","Filename"');
    while not SQLMainQuery.EOF do
    begin
      Line := '"' + SQLMainQuery.FieldByName('firstline').AsString + '","' + SQLMainQuery.FieldByName('chorus').AsString + '","' + SQLMainQuery.FieldByName('filename').AsString + '"';
      Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
      writeln(IdxFile, Line);
      SQLMainQuery.Next;
    end;
    SQLMainQuery.Close;
    CloseFile(IdxFile);
  end;
end;

procedure TControlForm.LBCurrentMarkerClick(Sender: TObject);
begin
    ControlForm.FocusControl(SongControl);
end;


procedure TControlForm.LBCurrentMarkerDblClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to (LBCurrentMarker.Count-1) do
  begin
    if LBCurrentMarker.Selected[i] then
    begin
      LBCurrentMarker.ClearSelection;
      VerseShow(i);
      ControlForm.FocusControl(SongControl);
      break;
    end;
  end;
end;

procedure TControlForm.LoadPLButtonClick(Sender: TObject);
var
  PLFile: TextFile;
  Line: string;
begin
  OpenDialog1.DefaultExt := '.sspl';
  OpenDialog1.Title := 'Open Play List';
  OpenDialog1.Filter := 'SongShow Play List|*.sspl';
  if (OpenDialog1.Execute) then
  begin
    AssignFile(PLFile, OpenDialog1.FileName);
    Reset(PLFile);
    PlayList.Clear;
    while not EOF(PLFile) do
    begin
      Readln(PLFile, Line);
      if (Length(Line) > 0) and (RightStr(Line, 4) = '.txt') then
        PlayList.Items.Add(Line);
    end;
    CloseFile(PLFile);
    if (PlayList.Items.Count > 0) then
    begin
      PlayList.ItemIndex := 0;
      PlayListDblClick(Sender);
    end;
  end;
end;

procedure TControlForm.EditButtonClick(Sender: TObject);
var
  SongFile: TextFile;
  Line: string;
begin
  if (SongFileName <> '') then
  begin
    EditForm.SongEdit.Lines.Clear();
    AssignFile(SongFile, SongFileName);
    Reset(SongFile);
    while not EOF(SongFile) do
    begin
      Readln(SongFile, Line);
      Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
      EditForm.SongEdit.Lines.Add(Line);
    end;
    CloseFile(SongFile);
  end
  else
    EditForm.SongEdit.Lines.Clear();
  EditForm.EditFileName := SongFileName;
  EditForm.Show;
end;

procedure TControlForm.FileMenuEditClick(Sender: TObject);
var
  Filename : string;
  Splt : integer;
begin
  If FilesList.ItemIndex = -1 then
    exit;
  Filename := FilesList.Items.Strings[FilesList.ItemIndex];
  Splt := Pos('.txt (', Filename);
  If (Splt > 0) then
    Filename := Copy(Filename, Splt + 6, Length(Filename) - (Splt + 6)) + Copy(Filename, 1, Splt + 3);
  Filename := SongDirectory + Filename;
  AdvancedEditForm.Show;
  AdvancedEditForm.EditSong(Filename);
end;

procedure TControlForm.BuildSongList;
begin
  FilesList.Clear;
  SQLMainQuery.SQL.Text := 'SELECT filename, directory FROM songs ORDER BY filename, directory';
  SQLMainQuery.Open;
  while not SQLMainQuery.EOF do
  begin
    if SQLMainQuery.FieldByName('directory').AsString <> '' then
      FilesList.Items.Add(SQLMainQuery.FieldByName('filename').AsString + ' (' + SQLMainQuery.FieldByName('directory').AsString + ')')
    else
      FilesList.Items.Add(SQLMainQuery.FieldByName('filename').AsString);
    SQLMainQuery.Next;
  end;
  SQLMainQuery.Close;
end;

procedure TControlForm.SyncSongs(GetAll : integer);
var
  HttpClient : TFPHttpClient;
  SongsData: TJSONData;
  SongCounter: integer;
  SongData: TJSONObject;
  SongFile: TextFile;
  SongId, i, j, Uploaded, Downloaded : integer;
  More : Boolean;
  SongLine, Markup, SongNo, AuthToken, HttpResponse : string;
begin
  MenuItemSync.Enabled:=false;

  Uploaded := 0;
  Downloaded := 0;

  LWarning.Caption:='Sync started';

  If (GetAll = 0) then
  begin
    // Find amended central songs to sync up
    SQLMainQuery.SQL.Text := 'SELECT filename, directory, songId FROM songs WHERE central = 1 AND updated = 1';
    SQLMainQuery.Open;
    SQLUpdateQuery.SQL.Text := 'UPDATE songs SET updated = 0 WHERE songId = :SONGID';
    SongData := TJSONObject.Create;
    i := 1;
    while not SQLMainQuery.EOF do
    begin
      LWarning.Caption:= 'Uploading '+IntToStr(i)+' of '+IntToStr(SQLMainQuery.RecordCount)+' ('+SQLMainQuery.FieldByName('filename').AsString+')';
      Application.ProcessMessages;
      AssignFile(SongFile, SongDirectory + SQLMainQuery.FieldByName('directory').AsString + SQLMainQuery.FieldByName('filename').AsString);
      Markup := '';
      Reset(SongFile);
      j := 0;
      while not EOF(SongFile) do
      begin
        Readln(SongFile, SongLine);
        SongLine := ConvertEncoding(SongLine, GuessEncoding(SongLine), EncodingUTF8); // Ensure we're using UTF8
        if ((j = 0) and (length(SongLine) > 0)) then
           j := 1;
        if j = 1 then
           Markup := Markup + SongLine + #13 + #10;
      end;
      CloseFile(SongFile);
      SongData.Clear;
      SongData.Add('markup', Markup);
      AuthToken := EncodeBase64(SyncUser+':'+SyncPass);
      HttpClient := TFPHttpClient.Create(Nil);
      HttpClient.AddHeader('Authorization','Basic '+AuthToken);
      HttpClient.RequestBody := TStringStream.Create(SongData.AsJSON);
      HttpClient.AddHeader('Content-Type','application/json');
      SongNo := SQLMainQuery.FieldByName('filename').AsString;
      HttpResponse := HttpClient.Put(SyncURL+'/wp-json/songdb/v1/update/'+Copy(SongNo, 1, Length(SongNo) - 4));
      if HttpClient.ResponseStatusCode = 200 then
      begin
        SQLUpdateQuery.Params.ParamByName('SONGID').AsInteger := SQLMainQuery.FieldByName('songId').AsInteger;
        SQLUpdateQuery.ExecSQL;
        Uploaded := Uploaded + 1;
        i := i + 1;
      end
      else
      begin
        if HttpClient.ResponseStatusCode <> 403 then
        begin
          LWarning.Caption:= 'Sync returned '+IntToStr(HttpClient.ResponseStatusCode)+' '+HttpResponse;
          break;
        end;
      end;
      HttpClient.RequestBody.Free;
      HttpClient.Free;
      SQLMainQuery.Next;
    end;
    SQLMainQuery.Close;
    SQLTransaction1.Commit;
    SongData.Destroy;
  end;

  // Retrieve changes from central list
  if (GetAll = 1) then
    LastSync := '0000-00-00:00:00:00';
  More := True; // We keep doing the download until we get an empty answer

  HttpClient := TFPHttpClient.Create(Nil);
  while (More) do
  begin
    LWarning.Caption:= 'Downloading changes';
    Application.ProcessMessages;
    More := False;

    if (SyncUser <> '') then
    begin
      AuthToken := EncodeBase64(SyncUser+':'+SyncPass);
      HttpClient.AddHeader('Authorization', 'Basic '+AuthToken);
    end;

    HttpResponse := HttpClient.Get(SyncURL+'/wp-json/songdb/v1/sync/'+Copy(LastSync, 1, 10)+':'+Copy(LastSync, 12, 8));
    if HttpClient.ResponseStatusCode = 200 then
    begin
      try
        SongsData := GetJSON(HttpResponse);
        if Assigned(SongsData) then
          case SongsData.JSONType of
            jtArray: // an array of Songs
              begin
                i := 0;
                for SongCounter := 0 to SongsData.Count - 1 do
                begin
                  SongData := TJSONObject(SongsData.Items[SongCounter]);
                  if SongData.IndexOfName('song_number', false) >= 0 then
                  begin
                    SongId := SongData.Integers['song_number'];
                    LWarning.Caption:= 'Processing '+Format('%.4d', [SongId])+'.txt';
                    Application.ProcessMessages;
                    AssignFile(SongFile, SongDirectory+Format('%.4d', [SongId])+'.txt');
                    Rewrite(SongFile);
                    Writeln(SongFile, SongData.Strings['markup']);
                    CloseFile(SongFile);
                    IndexSong(Format('%.4d', [SongId])+'.txt', '', 1, 0, i, 0, false);
                    Downloaded := Downloaded + 1;
                    LastSync := SongData.Strings['modified'];
                    More := True;
                  end;
                end;
              end;
          end;
      except
        LWarning.Caption:='Sync returned invalid data';
      end;
    end
    else
      LWarning.Caption:= 'Sync returned '+IntToStr(HttpClient.ResponseStatusCode)+' '+HttpResponse;
  end;
  HttpClient.Free;

  MenuItemSync.Enabled:=true;

  if ((Uploaded > 0) or (Downloaded > 0)) then
    LWarning.Caption:='Sync completed ('+IntToStr(Downloaded)+' downloaded, '+IntToStr(Uploaded)+ ' uploaded)'
  else
    if (LWarning.Caption = 'Downloading changes') then
      LWarning.Caption := 'Sync completed';

  HttpClient := TFPHttpClient.Create(Nil);
  HttpResponse := HttpClient.Get(SyncURL+'/ssversion/?download_file=1');
  if HttpClient.ResponseStatusCode = 200 then
  begin
    SongLine := HttpResponse;
    i := Pos('.', HttpResponse);
    While i > 0 do
    begin
      SongLine := Copy(SongLine, i + 1, Length(SongLine) - i);
      i := Pos('.', SongLine);
    end;
    if (StrToInt(SongLine) > BuildNo) then
      if (QuestionDlg('New Software Version', 'Song Show version '+HttpResponse+' now available', mtCustom, [mrYes, 'Download', mrIgnore, 'Not Now'], '') = mrYes) then
        OpenUrl(SyncURL+'/songshow-setup/?download_file=1');
  end;
  HttpClient.Free;

end;

procedure TControlForm.PublishSong(SongId : integer);
var
  HttpClient : TFPHttpClient;
  SongsData: TJSONData;
  SongData: TJSONObject;
  SongFile: TextFile;
  i, SongNumber : integer;
  SongLine, Markup, AuthToken, HttpResponse, Filename : string;
begin
  MenuItemSync.Enabled := false;
  MenuItemPublish.Enabled := false;

  LWarning.Caption:='Publishing...';

  SQLMainQuery.SQL.Text := 'SELECT filename, directory, firstline, chorus FROM songs WHERE songId = :SONGID';
  SQLMainQuery.ParamByName('SONGID').AsInteger := SongId;
  SQLMainQuery.Open;
  SQLUpdateQuery.SQL.Text := 'UPDATE songs SET updated = 0, filename = :FILENAME, directory = "", central = 1 WHERE songId = :SONGID';
  SongData := TJSONObject.Create;
  if not SQLMainQuery.EOF then
  begin
    LWarning.Caption:= 'Publishing '+SQLMainQuery.FieldByName('filename').AsString;
    Filename := SQLMainQuery.FieldByName('filename').AsString;
    If SQLMainQuery.FieldByName('directory').AsString <> '' then
      Filename := Filename + ' (' + SQLMainQuery.FieldByName('directory').AsString + ')';
    SongData.Add('title', SQLMainQuery.FieldByName('firstline').AsString);
    Application.ProcessMessages;
    AssignFile(SongFile, SongDirectory + SQLMainQuery.FieldByName('directory').AsString + SQLMainQuery.FieldByName('filename').AsString);
    Markup := '';
    Reset(SongFile);
    i := 0;
    while not EOF(SongFile) do
    begin
      Readln(SongFile, SongLine);
      SongLine := ConvertEncoding(SongLine, GuessEncoding(SongLine), EncodingUTF8); // Ensure we're using UTF8
      if ((i = 0) and (length(SongLine) > 0)) then
         i := 1;
      if i = 1 then
         Markup := Markup + SongLine + #13 + #10;
    end;
    CloseFile(SongFile);
    SongData.Add('markup', Markup);
    AuthToken := EncodeBase64(SyncUser+':'+SyncPass);
    HttpClient := TFPHttpClient.Create(Nil);
    HttpClient.AddHeader('Authorization','Basic '+AuthToken);
    HttpClient.RequestBody := TStringStream.Create(SongData.AsJSON);
    HttpClient.AddHeader('Content-Type','application/json');
    HttpResponse := HttpClient.Post(SyncURL+'/wp-json/songdb/v1/import/0'); // Publishing to song 0 assigns a new number from the database
    if HttpClient.ResponseStatusCode = 200 then
    begin
      SongsData := GetJSON(HttpResponse);
      if Assigned(SongsData) then
      begin
        SongData := TJSONObject(SongsData);
        SongNumber := SongData.Integers['song_number'];
        If RenameFile(SongDirectory + SQLMainQuery.FieldByName('directory').AsString + SQLMainQuery.FieldByName('filename').AsString,
                      SongDirectory+Format('%.4d', [SongNumber])+'.txt') then
        begin
          SQLUpdateQuery.Params.ParamByName('FILENAME').AsString := Format('%.4d', [SongNumber])+'.txt';
          SQLUpdateQuery.Params.ParamByName('SONGID').AsInteger := SongId;
          SQLUpdateQuery.ExecSQL;
          LWarning.Caption := 'Published as song '+Format('%.4d', [SongNumber]);
          FilesList.Items.Delete(FilesList.Items.IndexOf(Filename));
          FilesList.Items.Add(Format('%.4d', [SongNumber])+'.txt');
        end
        else
          LWarning.Caption := 'Unable to rename song file';
      end;
    end
    else
    begin
      if HttpClient.ResponseStatusCode <> 403 then
        LWarning.Caption:= 'Sync returned '+IntToStr(HttpClient.ResponseStatusCode)+' '+HttpResponse;
    end;
    HttpClient.RequestBody.Free;
    HttpClient.Free;
  end;
  SQLMainQuery.Close;
  SQLTransaction1.Commit;
  SongData.Destroy;

  MenuItemSync.Enabled:=true;

end;

procedure TControlForm.CCLRecord;
var
  OffScreenTime: TDateTime;
  FileName: string;
begin
  OffScreenTime := Now;
  if (CCLSong = 1) and (((OffScreenTime - ControlForm.OnScreenTime) * 24 * 30) > 1) and (CCLEvent <> '') then
  begin
    FileName := Copy(SongFileName, Length(SongDirectory) + 1, Length(SongFileName) - Length(SongDirectory));
    CCLRecordSong(FileName);
  end;
end;

procedure TControlForm.CCLRecordSong(Filename: string);
var
  SongFile: TextFile;
  Line, CCLName, CCLCopy, CurrentItem, LocalTitle: string;
  lineno: integer;
begin
  if not FileExists(SongDirectory + FileName) then
    exit;

  SQLMainQuery.SQL.Text := 'SELECT songId FROM songs WHERE filename = :FILENAME AND directory = :DIRECTORY';
  if RPos(PathDelim, FileName) > 0 then
  begin
    SQLMainQuery.ParamByName('FILENAME').AsString := Copy(FileName, RPos(PathDelim, FileName) + 1, Length(FileName) - RPos(PathDelim, FileName));
    SQLMainQuery.ParamByName('DIRECTORY').AsString := Copy(FileName, 1, RPos(PathDelim, FileName));
  end
  else
  begin
    SQLMainQuery.ParamByName('FILENAME').AsString := FileName;
    SQLMainQuery.ParamByName('DIRECTORY').AsString := '';
  end;
  SQLMainQuery.Open;
  if NOT SQLMainQuery.EOF then
  begin

    AssignFile(SongFile, SongDirectory + FileName);
    Reset(SongFile);
    CCLSong := 0;
    CCLName := '';
    CCLCopy := '';
    CurrentItem := '';
    LocalTitle := '';
    LineNo := 1;

    while not EOF(SongFile) do
    begin
      Readln(SongFile, Line);
      Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
      if Copy(Line, 1, 1) = '<' then
      begin
        Line := UpperCase(Line);
        if Copy(Line, 2, 1) = '/' then
          CurrentItem := ''
        else
        begin
          if ((Pos(' ', Line)) > 0) and (Pos(' ', Line) < Pos('>', Line)) then
            CurrentItem := Copy(Line, 2, Pos(' ', Line) - 2)
          else
            CurrentItem := Copy(Line, 2, Pos('>', Line) - 2);

        end;
      end
      else
      begin
        if CurrentItem <> '' then
        begin
          if Copy(Line, 1, 1) = '{' then
            Line := Copy(Line, 2, Length(Line) - 1);
          if Copy(Line, Length(Line), 1) = '}' then
            Line := Copy(Line, 1, Length(Line) - 1);
          if Copy(Line, 1, 1) = '|' then
            Line := Copy(Line, 2, Length(Line) - 1);
          if Copy(Line, Length(Line), 1) = '|' then
            Line := Copy(Line, 1, Length(Line) - 1);

          if Length(Line) > 0 then
          begin
            case CurrentItem of
              'COPY' : CCLCopy := CCLCopy + Line + ' ';

              'CCL' : CCLSong := 1;

              otherwise
              begin
                if LineNo = 1 then
                begin
                  if (CurrentItem = 'V1') or (CurrentItem = 'V') then
                    LocalTitle := Line + ' - ' + LocalTitle;
                  if (CurrentItem = 'C1') or (CurrentItem = 'C') or (CurrentItem = 'CH1') or (CurrentItem = 'CH') then
                    LocalTitle := LocalTitle + Line;
                  if (CurrentItem = 'V1') or (CurrentItem = 'V') or
                    (CurrentItem = 'C1') or (CurrentItem = 'C') or
                    (CurrentItem = 'CH1') or (CurrentItem = 'CH') then
                    CCLName := LocalTitle;
                end;
                LineNo := LineNo + 1;
              end;
            end;
          end;
        end;
      end;
    end;

    CloseFile(SongFile);

    SQLWordFind.SQL.Text := 'SELECT COUNT(*) AS already FROM `cclrecord` WHERE ROUND(ccldate) = ROUND(julianday("now")) AND songId = :SONGID AND cclevent = :CCLEVENT';
    SQLWordFind.Params.ParamByName('SONGID').AsInteger := SQLMainQuery.FieldByName('songId').AsInteger;
    SQLWordFind.Params.ParamByName('CCLEVENT').AsString := CCLEvent;
    SQLWordFind.Open;
    if SQLWordFind.FieldByName('already').AsInteger = 0 then
    begin
      SQLInsertQuery.SQL.Text := 'INSERT INTO `cclrecord` (ccldate, songId, cclevent, cclname, cclcopy) VALUES (julianday("now"), :SONGID, :CCLEVENT, :CCLNAME, :CCLCOPY)';
      SQLInsertQuery.Params.ParamByName('SONGID').AsInteger := SQLMainQuery.FieldByName('songId').AsInteger;
      SQLInsertQuery.Params.ParamByName('CCLEVENT').AsString := CCLEvent;
      SQLInsertQuery.Params.ParamByName('CCLNAME').AsString := CCLName;
      SQLInsertQuery.Params.ParamByName('CCLCOPY').AsString := CCLCopy;
      SQLInsertQuery.ExecSQL;
      SQLTransaction1.Commit;
    end;
    SQLWordFind.Close;
  end;
  SQLMainQuery.Close;
end;

procedure TControlForm.CCLRemoveSong(Filename: string);
begin
  SQLMainQuery.SQL.Text := 'SELECT songId FROM songs WHERE filename = :FILENAME AND directory = :DIRECTORY';
  if RPos(PathDelim, FileName) > 0 then
  begin
    SQLMainQuery.ParamByName('FILENAME').AsString := Copy(FileName, RPos(PathDelim, FileName) + 1, Length(FileName) - RPos(PathDelim, FileName));
    SQLMainQuery.ParamByName('DIRECTORY').AsString := Copy(FileName, 1, RPos(PathDelim, FileName));
  end
  else
  begin
    SQLMainQuery.ParamByName('FILENAME').AsString := FileName;
    SQLMainQuery.ParamByName('DIRECTORY').AsString := '';
  end;
  SQLMainQuery.Open;
  if NOT SQLMainQuery.EOF then
  begin
    SQLInsertQuery.SQL.Text := 'DELETE FROM `cclrecord` WHERE ROUND(ccldate) = ROUND(julianday("now")) AND songId = :SONGID AND cclevent = :CCLEVENT';
    SQLInsertQuery.Params.ParamByName('SONGID').AsInteger := SQLMainQuery.FieldByName('songId').AsInteger;
    SQLInsertQuery.Params.ParamByName('CCLEVENT').AsString := CCLEvent;
    SQLInsertQuery.ExecSQL;
    SQLTransaction1.Commit;
  end;
  SQLMainQuery.Close;
end;

procedure TControlForm.DeleteFromPLClick(Sender: TObject);
var
  Reply, OldIndex: integer;
begin
  if PlayList.ItemIndex > -1 then
  begin
    Reply := Application.MessageBox('Delete from play list?',
      'Confirm Delete', MB_ICONQUESTION + MB_YESNO);
    if Reply = idYes then
    begin
      OldIndex := PlayList.ItemIndex;
      PlayList.Items.Delete(PlayList.ItemIndex);
      if PlayList.Items.Count > OldIndex then
        PlayList.ItemIndex := OldIndex
      else
        PlayList.ItemIndex := PlayList.Items.Count - 1;
    end;
  end;

end;

procedure TControlForm.BIngExpClick(Sender: TObject);
begin
  SaveDialog1.DefaultExt := '.png';
  SaveDialog1.Title := 'Export Images';
  SaveDialog1.Filter := 'PNG Images|*.png';
  if (SaveDialog1.Execute) then
    WordsForm.ExportImages(SaveDialog1.FileName);
end;

procedure TControlForm.DownloadAllButtonClick(Sender: TObject);
begin
  if Application.MessageBox('Really download all songs?  This can take a long time', 'Download All', MB_ICONQUESTION + MB_YESNO) = IDYES then
    SyncSongs(1);
end;


procedure TControlForm.SetupButtonClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

function TControlForm.Encode3to4(const Value, Table: AnsiString): AnsiString;
var
  c: Byte;
  n, l: Integer;
  Count: Integer;
  DOut: array[0..3] of Byte;
begin
  Result := '';
  setlength(Result, ((Length(Value) + 2) div 3) * 4);
  l := 1;
  Count := 1;
  while Count <= Length(Value) do
  begin
    c := Ord(Value[Count]);
    Inc(Count);
    DOut[0] := (c and $FC) shr 2;
    DOut[1] := (c and $03) shl 4;
    if Count <= Length(Value) then
    begin
      c := Ord(Value[Count]);
      Inc(Count);
      DOut[1] := DOut[1] + (c and $F0) shr 4;
      DOut[2] := (c and $0F) shl 2;
      if Count <= Length(Value) then
      begin
        c := Ord(Value[Count]);
        Inc(Count);
        DOut[2] := DOut[2] + (c and $C0) shr 6;
        DOut[3] := (c and $3F);
      end
      else
      begin
        DOut[3] := $40;
      end;
    end
    else
    begin
      DOut[2] := $40;
      DOut[3] := $40;
    end;
    for n := 0 to 3 do
    begin
      if (DOut[n] + 1) <= Length(Table) then
      begin
        Result[l] := Table[DOut[n] + 1];
        Inc(l);
      end;
    end;
  end;
  SetLength(Result, l - 1);
end;

function TControlForm.EncodeBase64(const Value: AnsiString): AnsiString;
begin
  Result := Encode3to4(Value, TableBase64);
end;

constructor THTTPServerThread.Create(APort: Word; const OnRequest: THTTPServerRequestHandler);
begin
   HTTPServer := TFPHTTPServer.Create(Nil);
   HTTPServer.Port:=APort;
   HTTPServer.OnRequest:=OnRequest;
   Inherited Create(False);
end;

procedure THTTPServerThread.Execute;
begin
  try
    HTTPServer.Active := True;
  finally
    FreeAndNil(HTTPServer);
  end;
end;

procedure THTTPServerThread.DoTerminate;
begin
  inherited DoTerminate;
  HTTPServer.Active := False;
end;

procedure TControlForm.DoHandleRequest(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
var
  CurrentSettings : string;
  SongControlHtml : string;
  StatusStr : string;
begin
  HTTPParameter := ARequest.QueryFields.Values['setting'];
  HTTPValue := ARequest.QueryFields.Values['value'];
  ResultsHTMLMarkup := '';
  If Copy(ARequest.URL, 1, 5) = '/api/' then
  begin
    If ShowButton.Caption = 'S&how' then
      StatusStr := 'hidden'
    else
      StatusStr := 'visible';
    SongControlKey := Copy(ARequest.URL, 6);
    FServer.Synchronize(@ProcessSongControlKey);
    AResponse.ContentType:='application/json;charset=utf-8';
    AResponse.Contents.Text:='{"status" : "' + StatusStr + '", "title" : "' + Title + '", "current" : "' + CurrVerseLab.Caption + '"}';
  end
  else
  begin
    If HTTPValue <> '' then
      FServer.Synchronize(@ProcessSettings);
    SongControlKey := ARequest.ContentFields.Values['SearchString'];
    If SongControlKey <> '' then
      FServer.Synchronize(@ProcessSearchString);
    SongControlKey := ARequest.ContentFields.Values['LoadSong'];
    If SongControlKey <> '' then
      FServer.Synchronize(@ProcessLoadSong);
    SongControlKey := ARequest.ContentFields.Values['SongControl'];
    If SongControlKey <> '' then
      FServer.Synchronize(@ProcessSongControlKey);
    AResponse.ContentType:='text/html;charset=utf-8';
    CurrentSettings := '';
    CurrentSettings := CurrentSettings+'<p>LeftMargin: '+IntToStr(LeftMargin)+'</p>';
    CurrentSettings := CurrentSettings+'<p>RightMargin: '+IntToStr(RightMargin)+'</p>';
    CurrentSettings := CurrentSettings+'<p>TopMargin: '+IntToStr(TopMargin)+'</p>';
    CurrentSettings := CurrentSettings+'<p>BottomMargin: '+IntToStr(BottomMargin)+'</p>';
    SongControlHtml := '<p><input type="text" name="SearchString" /><input type="submit" value="Search" name="SearchButton" /></p>';
    If SongFilename <> '' then
    begin
      If ShowButton.Caption = 'S&how' then
        SongControlHtml := SongControlHtml + ' <input type="submit" value="Show" name="SongControl" />'
      else
        SongControlHtml := SongControlHtml + ' <input type="submit" value="Hide" name="SongControl" />';
      SongControlHtml := SongControlHtml + ' <input type="submit" value="Page Up" name="SongControl" /> <input type="submit" value="Page Down" name="SongControl" />';
      SongControlHtml := SongControlHtml + ' <input type="submit" value="Home" name="SongControl" /> <input type="submit" value="End" name="SongControl" />';
    end;
    AResponse.Contents.Text:='<!DOCTYPE html><html><head><title>'+ ControlForm.Title +'</title><style>body {font-family: Helvetica, Arial, san-serif;}  input[type="submit"] {height: 50px} .clickable {cursor: pointer} .clickable:hover {background-color: #FFFFAA}</style></head><body><h1>' + ControlForm.Title + '</h1><form method="POST" action="/" id="ssform"><h2>Song Control</h2>'+SongControlHtml+ResultsHTMLMarkup+'<input type="hidden" name="LoadSong" id="LoadSong" /><h2 class="clickable hover" onclick="document.getElementById(''settings'').style.display=''block''">Settings &rarr;</h2><div id="settings" style="display:none"><h3>Change Setting</h3><form method="POST"><p><label for="setting">Setting </label><input name="setting" id="setting" value="" /></p><p><label for="value">Value </label><input name="value" id="value" value="" /></p><p><input type="submit" value="Update" /></p></form><h3>Current Settings</h3>'+CurrentSettings+'</div><script>function loadSong(no) { document.getElementById("LoadSong").value = no; document.getElementById("ssform").submit(); }</script></body></html>';
  end;
end;

procedure TControlForm.ProcessSettings;
begin
  case HTTPParameter of
    'FontSize' : FontSize := StrToInt(HTTPValue);
    'LeftMargin' : LeftMargin := StrToInt(HTTPValue);
    'RightMargin' : RightMargin := StrToInt(HTTPValue);
    'TopMargin' : TopMargin := StrToInt(HTTPValue);
    'BottomMargin' : BottomMargin := StrToInt(HTTPValue);
  end;
end;

procedure TControlForm.ProcessSongControlKey;
var
  obj : TObject = nil;
  key : Word;
  ss : TShiftState = [];
  keyword : String;
  divpos : integer;
begin
  key := 0;
  If SongFileName <> '' then
  begin
    divpos := Pos('/', SongControlKey);
    If (divpos > 0) then
      keyword := Copy(SongControlKey, 1, divpos - 1)
    else
      keyword := SongControlKey;
    case keyword of
      'Show', 'show' : key := VK_Insert;
      'Hide', 'hide' : key := VK_Delete;
      'Page Up', 'PageUp', 'prev' : key := VK_Prior;
      'Page Down', 'PageDown', 'next' : key := VK_Next;
      'Home', 'home' : key := VK_Home;
      'End', 'end' : key := VK_End;
      'nextsong', 'pl_next' :
        begin
          key := VK_Next;
          ss := [ ssCtrl ];
        end;
      'prevsong', 'pl_prev' :
        begin
          key := VK_Prior;
          ss := [ ssCtrl ];
        end;
      'goto':
        begin
          SongControl.Text := Copy(SongControlKey, divpos + 1, Length(SongControlKey) - divpos);
          key := VK_Return;
        end;
    end;
    if key <> 0 then
      SongControlKeyDown(obj, key, ss);
  end;
end;

procedure TControlForm.ProcessSearchString;
var
  obj : TObject = nil;
  i : integer;
begin
  SearchString.Text := SongControlKey;
  SearchClick(obj);
  ResultsHTMLMarkup := '<table><thead><tr><th>First Line</th><th>Chorus</th></tr><thead><tbody>';
  for i := 1 to ResultGrid.RowCount - 1 do
  begin
    ResultsHTMLMarkup := ResultsHTMLMarkup + ' <tr class="clickable" onclick="loadSong('+ IntToStr(i) + ')"><td>' + ResultGrid.Cells[1,i] + '</td><td>' + ResultGrid.Cells[2, i] + '</td></tr>';
  end;
  ResultsHTMLMarkup := ResultsHTMLMarkup + '</tbody></table>';
end;

procedure TControlForm.ProcessLoadSong;
var
  obj : TObject = nil;
begin
  If StrToInt(SongControlKey) < ResultGrid.RowCount then
  begin
    ResultGrid.Row := StrToInt(SongControlKey);
    ResultGridDblClick(obj);
  end;
end;

{$IFDEF WINDOWS}
procedure TControlForm.WMHotKey(Var MSG: TWMHotKey);
var
  obj : TObject = nil;
  key : Word;
  ss : TShiftState = [];
begin
  Case MSG.HotKey of
    111000:
      ShowButton.Click;
    111001:
      begin
        key := VK_Next;
        SongControlKeyDown(obj, key, ss);
      end;
    111002:
      begin
        key := VK_Prior;
        SongControlKeyDown(obj, key, ss);
      end;
    111003:
      begin
        key := VK_End;
        SongControlKeyDown(obj, key, ss);
      end;
    111004:
      begin
        key := VK_Home;
        SongControlKeyDown(obj, key, ss);
      end;
  end;
end;
{$ENDIF}
end.
