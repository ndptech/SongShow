unit Setup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, LCLtype;

type

  { TSetupForm }

  TSetupForm = class(TForm)
    AutoMerge: TCheckBox;
    AllowRemoteControl: TCheckBox;
    BGImg: TLabel;
    OpenDialog1: TOpenDialog;
    SetBGImg: TButton;
    GlobalHotkeys: TCheckBox;
    DeleteBible: TButton;
    TextFontSample: TLabel;
    SetTextFont: TButton;
    CBDefBible: TComboBox;
    CBTextSize: TComboBox;
    Label4: TLabel;
    LBLDefBib: TLabel;
    SyncPass: TLabeledEdit;
    SyncUser: TLabeledEdit;
    SyncURL: TLabeledEdit;
    TextLinesPerScreen: TLabeledEdit;
    Label3: TLabel;
    LineIndent: TLabeledEdit;
    ShowBorder: TCheckBox;
    Label2: TLabel;
    LinesPerScreen: TLabeledEdit;
    WordWidth: TLabeledEdit;
    WordHeight: TLabeledEdit;
    WordLeft: TLabeledEdit;
    WordTop: TLabeledEdit;
    SetOLColour: TButton;
    SetupSave: TButton;
    Label1: TLabel;
    MargRight: TLabeledEdit;
    MargBot: TLabeledEdit;
    MargLeft: TLabeledEdit;
    MargTop: TLabeledEdit;
    OLColourSample: TShape;
    SongDir: TLabel;
    SetSongDir: TButton;
    CCLNo: TEdit;
    LBLCCL: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SetBGColour: TButton;
    SetFGColour: TButton;
    ChorusFontSample: TLabel;
    CBFontSize: TComboBox;
    ColorDialog1: TColorDialog;
    LblFontSize: TLabel;
    SetChorusFont: TButton;
    FGColourSample: TShape;
    BGColourSample: TShape;
    OLSize: TTrackBar;
    VerseFontSample: TLabel;
    SetVerseFont: TButton;
    FontDialog1: TFontDialog;
    procedure DeleteBibleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SetBGColourClick(Sender: TObject);
    procedure SetBGImgClick(Sender: TObject);
    procedure SetChorusFontClick(Sender: TObject);
    procedure SetFGColourClick(Sender: TObject);
    procedure SetOLColourClick(Sender: TObject);
    procedure SetSongDirClick(Sender: TObject);
    procedure SetTextFontClick(Sender: TObject);
    procedure SetupSaveClick(Sender: TObject);
    procedure SetVerseFontClick(Sender: TObject);
    procedure PopulateBibleList;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

uses Control, Words, Scripture;

{$R *.lfm}

{ TSetupForm }

procedure TSetupForm.FormShow(Sender: TObject);
begin
  SetupForm.Top := ControlForm.Top + 10;
  SetupForm.Left := ControlForm.Left + 10;
  VerseFontSample.Caption := ControlForm.FontName;
  VerseFontSample.Font.Name := ControlForm.FontName;
  ChorusFontSample.Caption := ControlForm.ChorusFont;
  ChorusFontSample.Font.Name := ControlForm.ChorusFont;
  TextFontSample.Caption := ControlForm.TextFont;
  TextFontSample.Font.Name := ControlForm.TextFont;
  CBFontSize.Text := IntToStr(ControlForm.FontSize);
  CBTextSize.Text := IntToStr(ControlForm.TextFontSize);
  FGColourSample.Brush.Color:= ControlForm.FGColour;
  BGColourSample.Brush.Color:= ControlForm.BGColour;
  OLColourSample.Brush.Color := ControlForm.OLColour;
  OLSize.Position:=ControlForm.OLSize;
  BGImg.Caption := ControlForm.BGimage;
  SongDir.Caption:=ControlForm.SongDirectory;
  MargTop.Text:=IntToStr(ControlForm.TopMargin);
  MargLeft.Text:=IntToStr(ControlForm.LeftMargin);
  MargBot.Text:=IntToStr(ControlForm.BottomMargin);
  MargRight.Text:=IntToStr(ControlForm.RightMargin);
  WordTop.Text:=IntToStr(ControlForm.TopWords);
  WordLeft.Text:=IntToStr(ControlForm.LeftWords);
  WordHeight.Text:=IntToStr(ControlForm.HeightWords);
  WordWidth.Text:=IntToStr(ControlForm.WidthWords);
  LinesPerScreen.Text := IntToStr(ControlForm.LinesPerScreen);
  TextLinesPerScreen.Text := IntToStr(ControlForm.TextLinesPerScreen);
  LineIndent.Text := IntToStr(ControlForm.LineIndent);
  ShowBorder.Checked:=ControlForm.ShowBorder;
  AutoMerge.Checked := ControlForm.AutoMerge;
  AllowRemoteControl.Checked := ControlForm.AllowRemoteControl;
  GlobalHotkeys.Checked := ControlForm.GlobalHotkeys;
  CCLNo.Text:=ControlForm.CCLNo;
  SyncURL.Text:=ControlForm.SyncURL;
  SyncUser.Text:=ControlForm.SyncUser;
  SyncPass.Text:=ControlForm.SyncPass;
  PopulateBibleList;
end;

procedure TSetupForm.FormCreate(Sender: TObject);
begin

end;

procedure TSetupForm.DeleteBibleClick(Sender: TObject);
var
  Reply, BibleId : integer;
begin
  if (CBDefBible.ItemIndex >= 0) then
  begin
    Reply := Application.MessageBox(PChar('Delete bible - '+CBDefBible.Items.Strings[CBDefBible.ItemIndex]+'?'),
      'Confirm Delete', MB_ICONQUESTION + MB_YESNO);
    if Reply = idYes then
    begin
      ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId` FROM `bibles` WHERE `bibleName` = :BIBLENAME';
      ControlForm.SQLMainQuery.ParamByName('BIBLENAME').AsString := CBDefBible.Items.Strings[CBDefBible.ItemIndex];
      ControlForm.SQLMainQuery.Open;
      BibleId := 0;
      If not(ControlForm.SQLMainQuery.EOF) then
        BibleId := ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger;
      ControlForm.SQLMainQuery.Close;
      If BibleId > 0 then
      begin
        DeleteBible.Caption := 'Deleting...';
        DeleteBible.Enabled := false;
        ControlForm.SQLUpdateQuery.SQL.Text := 'DELETE FROM `bibles` WHERE `bibleId` = :BIBLEID';
        ControlForm.SQLUpdateQuery.ParamByName('BIBLEID').AsInteger := BibleId;
        ControlForm.SQLUpdateQuery.ExecSQL;
        ControlForm.SQLTransaction1.Commit;
        ControlForm.SQLUpdateQuery.SQL.Text := 'DELETE FROM `bibleBooks` WHERE `bibleId` = :BIBLEID';
        ControlForm.SQLUpdateQuery.ParamByName('BIBLEID').AsInteger := BibleId;
        ControlForm.SQLUpdateQuery.ExecSQL;
        ControlForm.SQLTransaction1.Commit;
        ControlForm.SQLUpdateQuery.SQL.Text := 'DELETE FROM `bibleVerse` WHERE `bibleId` = :BIBLEID';
        ControlForm.SQLUpdateQuery.ParamByName('BIBLEID').AsInteger := BibleId;
        ControlForm.SQLUpdateQuery.ExecSQL;
        ControlForm.SQLTransaction1.Commit;
        DeleteBible.Caption := 'Delete Bible';
        DeleteBible.Enabled := true;
        PopulateBibleList;
      end;
    end;
  end;
end;

procedure TSetupForm.SetBGColourClick(Sender: TObject);
begin
  ColorDialog1.Title:= 'Background Colour';
  ColorDialog1.Color:=ControlForm.BGColour;
  if (ColorDialog1.Execute) then
      BGColourSample.Brush.Color := ColorDialog1.Color;
end;

procedure TSetupForm.SetBGImgClick(Sender: TObject);
begin
  OpenDialog1.Title:='Select Background Image';
  OpenDialog1.Filter := 'Image Files|*.jpg;*.png;*.bmp';
  if (OpenDialog1.Execute) then
      BGImg.Caption:=OpenDialog1.FileName
  else
      BGImg.Caption:= '';

end;

procedure TSetupForm.SetChorusFontClick(Sender: TObject);
begin
  FontDialog1.Title := 'Chorus Font';
  FontDialog1.Font.Size := ControlForm.FontSize;
  FontDialog1.Font.Name := ControlForm.ChorusFont;
  FontDialog1.Font.Style := [fsBold, fsItalic];
  if (FontDialog1.Execute) then
  begin
      ChorusFontSample.Caption := FontDialog1.Font.Name;
      ChorusFontSample.Font.Name := FontDialog1.Font.Name;
  end;
end;

procedure TSetupForm.SetFGColourClick(Sender: TObject);
begin
  ColorDialog1.Title:='Text Colour';
  ColorDialog1.Color:=ControlForm.FGColour;
  if (ColorDialog1.Execute) then
  begin
      FGColourSample.Brush.Color := ColorDialog1.Color;
  end;
end;

procedure TSetupForm.SetOLColourClick(Sender: TObject);
begin
  ColorDialog1.Title:='Outline Colour';
  ColorDialog1.Color:=ControlForm.OLColour;
  if (ColorDialog1.Execute) then
      OLColourSample.Brush.Color := ColorDialog1.Color;
end;

procedure TSetupForm.SetSongDirClick(Sender: TObject);
begin
  SelectDirectoryDialog1.Title:='Songs Folder Selection';
  SelectDirectoryDialog1.FileName:=ControlForm.SongDirectory;
  if (SelectDirectoryDialog1.Execute) then
  begin
      SongDir.Caption:=SelectDirectoryDialog1.FileName;
      if (copy(SongDir.Caption, length(SongDir.Caption), 1) <> PathDelim) then
        SongDir.Caption := SongDir.Caption + PathDelim;
  end;
end;

procedure TSetupForm.SetTextFontClick(Sender: TObject);
begin
  FontDialog1.Title := 'Chorus Font';
  FontDialog1.Font.Size := ControlForm.TextFontSize;
  FontDialog1.Font.Name := ControlForm.TextFont;
  FontDialog1.Font.Style := [fsBold];
  if (FontDialog1.Execute) then
  begin
      TextFontSample.Caption := FontDialog1.Font.Name;
      TextFontSample.Font.Name := FontDialog1.Font.Name;
  end;
end;

procedure TSetupForm.SetupSaveClick(Sender: TObject);
begin
  ControlForm.FontName := VerseFontSample.Font.Name;
  ControlForm.ChorusFont := ChorusFontSample.Font.Name;
  ControlForm.TextFont := TextFontSample.Font.Name;
  ControlForm.FontSize := StrToInt(CBFontSize.Text);
  ControlForm.TextFontSize := StrToInt(CBTextSize.Text);
  ControlForm.FGColour := FGColourSample.Brush.Color;
  ControlForm.BGColour := BGColourSample.Brush.Color;
  If ControlForm.SongDirectory <> SongDir.Caption then
  begin
    ControlForm.SongDirectory := SongDir.Caption;
    // Make local song directory if it doesn't exist
    if not DirectoryExists(ControlForm.SongDirectory+'Local') then
      mkdir(ControlForm.SongDirectory+'Local');
  end;
  ControlForm.TopMargin := StrToInt(MargTop.Text);
  ControlForm.LeftMargin := StrToInt(MargLeft.Text);
  ControlForm.BottomMargin := StrToInt(MargBot.Text);
  ControlForm.RightMargin := StrToInt(MargRight.Text);
  ControlForm.BGColour:=BGColourSample.Brush.Color;
  ControlForm.FGColour:=FGColourSample.Brush.Color;
  ControlForm.OLColour:=OLColourSample.Brush.Color;
  ControlForm.OLSize := OLSize.Position;
  ControlForm.BGimage := BGImg.Caption;
  ControlForm.TopWords := StrToInt(WordTop.Text);
  ControlForm.LeftWords := StrToInt(WordLeft.Text);
  ControlForm.HeightWords:= StrToInt(WordHeight.Text);
  ControlForm.WidthWords:= StrToInt(WordWidth.Text);
  ControlForm.LinesPerScreen := StrToInt(LinesPerScreen.Text);
  ControlForm.TextLinesPerScreen := StrToInt(TextLinesPerScreen.Text);
  ControlForm.LineIndent := StrToInt(LineIndent.Text);
  ControlForm.ShowBorder := ShowBorder.Checked;
  ControlForm.AutoMerge := AutoMerge.Checked;
  ControlForm.AllowRemoteControl := AllowRemoteControl.Checked;
  ControlForm.GlobalHotkeys := GlobalHotkeys.Checked;
  ControlForm.CCLNo:=CCLNo.Text;
  ControlForm.SyncURL:=SyncURL.Text;
  if (Copy(SyncURL.Text, Length(SyncURL.Text), 1) = '/') then
    ControlForm.SyncURL := Copy(ControlForm.SyncURL, 0, Length(ControlForm.SyncURL) - 1);
  ControlForm.SyncUser:=SyncUser.Text;
  ControlForm.SyncPass:=SyncPass.Text;
  if (CBDefBible.ItemIndex >= 0) then
  begin
    ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId` FROM `bibles` WHERE `bibleName` = :BIBLENAME';
    ControlForm.SQLMainQuery.ParamByName('BIBLENAME').AsString := CBDefBible.Items.Strings[CBDefBible.ItemIndex];
    ControlForm.SQLMainQuery.Open;
    If not(ControlForm.SQLMainQuery.EOF) then
      ControlForm.DefaultBibleId := ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger;
    ControlForm.SQLMainQuery.Close;
  end;
  WordsForm.SetDimensions();
  WordsForm.InitialiseScreens();
  SetupForm.Close;
  if (WordsForm.Visible) then
  begin
    ControlForm.VerseShow(ControlForm.CurrentPLItem);
  end;
  WordsForm.PopulateDefaultBG(ControlForm.BGImage);
end;

procedure TSetupForm.SetVerseFontClick(Sender: TObject);
begin
  FontDialog1.Title := 'Verse Font';
  FontDialog1.Font.Size := ControlForm.FontSize;
  FontDialog1.Font.Name := ControlForm.FontName;
  FontDialog1.Font.Style := [fsBold];
  if (FontDialog1.Execute) then
  begin
      VerseFontSample.Caption := FontDialog1.Font.Name;
      VerseFontSample.Font.Name := FontDialog1.Font.Name;
  end;
end;

procedure TSetupForm.PopulateBibleList;
var
  itemNo : integer;
begin
  CBDefBible.Clear;
  ScriptureForm.CBPrimaryBible.Clear;
  ScriptureForm.CBSecondaryBible.Clear;
  ScriptureForm.CBSecondaryBible.Items.Add('');
  ScriptureForm.CBSecondaryBible.ItemIndex := 0;
  ScriptureForm.CBTertiaryBible.Clear;
  ScriptureForm.CBTertiaryBible.Items.Add('');
  ScriptureForm.CBTertiaryBible.ItemIndex := 0;
  ControlForm.SQLMainQuery.SQL.Text := 'SELECT `bibleId`, `bibleName` FROM `bibles` ORDER BY `bibleName`';
  ControlForm.SQLMainQuery.Open;
  itemNo := 0;
  while not(ControlForm.SQLMainQuery.EOF) do
  begin
    CBDefBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    ScriptureForm.CBPrimaryBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    ScriptureForm.CBSecondaryBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    ScriptureForm.CBTertiaryBible.Items.Add(ControlForm.SQLMainQuery.FieldByName('bibleName').AsString);
    if (ControlForm.DefaultBibleId = 0) then // Set a default bible is there is none set
      ControlForm.DefaultBibleId := ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger;
    if (ControlForm.DefaultBibleId = ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger) then
    begin
      CBDefBible.ItemIndex:=itemNo;
      ScriptureForm.CBPrimaryBible.ItemIndex:=itemNo;
    end;
    if (ControlForm.SecondaryBibleId = ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger) then
      ScriptureForm.CBSecondaryBible.ItemIndex := itemNo + 1; //Secondary bible has an extra blank entry at the start
    if (ControlForm.TertiaryBibleId = ControlForm.SQLMainQuery.FieldByName('bibleId').AsInteger) then
      ScriptureForm.CBTertiaryBible.ItemIndex := itemNo + 1; //Tertiary bible has an extra blank entry at the start
    itemNo := itemNo + 1;
    ControlForm.SQLMainQuery.Next;
  end;
  ControlForm.SQLMainQuery.Close;

  ControlForm.SQLMainQuery.SQL.Text := 'SELECT COUNT(*) AS books FROM bibleBooks';
  ControlForm.SQLMainQuery.Open;
  if (ControlForm.SQLMainQuery.FieldByName('books').AsInteger > 0) then
    ControlForm.ScriptureButton.Visible := true
  else
    ControlForm.ScriptureButton.Visible := false;
  ControlForm.SQLMainQuery.Close;

end;

end.

