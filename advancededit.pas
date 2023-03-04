unit AdvancedEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SynEdit,
  lconvencoding, Types, LCLType, LCLIntf, Menus;

type

  { TAdvancedEditForm }

  TAdvancedEditForm = class(TForm)
    AddVerseButton: TButton;
    AddChorusButton: TButton;
    AddBridgeButton: TButton;
    AddEndingButton: TButton;
    AddBeginningButton: TButton;
    BGImgButton: TButton;
    CancelButton: TButton;
    SaveButton: TButton;
    CopyButton: TButton;
    CCLButton: TButton;
    MarkEndButton: TButton;
    MarkStartButton: TButton;
    ExistingMenu: TPopupMenu;
    ItemsMenu: TPopupMenu;
    ItemUp: TMenuItem;
    ItemDown: TMenuItem;
    ItemDelete: TMenuItem;
    ItemStart: TMenuItem;
    ItemEnd: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SongMemo: TMemo;
    RepeatExistingButton: TButton;
    SongScreenLB: TListBox;
    procedure AddBeginningButtonClick(Sender: TObject);
    procedure AddBridgeButtonClick(Sender: TObject);
    procedure AddChorusButtonClick(Sender: TObject);
    procedure AddEndingButtonClick(Sender: TObject);
    procedure AddVerseButtonClick(Sender: TObject);
    procedure BGImgButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CCLButtonClick(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ItemDownClick(Sender: TObject);
    procedure ItemUpClick(Sender: TObject);
    procedure MarkEndButtonClick(Sender: TObject);
    procedure MarkStartButtonClick(Sender: TObject);
    procedure RepeatExistingButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure SongMemoChange(Sender: TObject);
    procedure SongScreenLBClick(Sender: TObject);
    procedure SongScreenLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    AESong: array of TStringList;
    AESongIndex: TStringList;
    LastBeginningNo: integer;
    LastVerseNo: integer;
    LastChorusNo: integer;
    LastBridgeNo: integer;
    LastEndNo: integer;
    CurrentItem: string;
    LoopStart : integer;
    LoopEnd : integer;
    EditFileName : string;
    SongChanged : boolean;
    procedure ResetSongAE();
    procedure NewItem(Item: string);
    procedure RepeatItem(Sender: TObject);
    procedure EditItem();
    procedure StoreItem();
    procedure EditSpecialItem(Item: string);
  public
    procedure NewSong();
    procedure EditSong(SongFileName: string);
  end;

var
  AdvancedEditForm: TAdvancedEditForm;

implementation

uses Control;

{$R *.lfm}

{ TAdvancedEditForm }

procedure TAdvancedEditForm.AddVerseButtonClick(Sender: TObject);
begin
  LastVerseNo := LastVerseNo + 1;
  NewItem('V' + IntToStr(LastVerseNo));
end;

procedure TAdvancedEditForm.BGImgButtonClick(Sender: TObject);
var
  i : integer;
begin
  OpenDialog1.FileName := '';
  i := AESongIndex.IndexOf('BGIMG');
  if i >= 0 then
    if AESong[i].Count > 0 then
      OpenDialog1.FileName := AESong[i].Strings[0];
  OpenDialog1.Title:='Select Background Image';
  OpenDialog1.Filter := 'Image Files|*.jpg;*.png;*.bmp';
  if (OpenDialog1.Execute) then
    if i >= 0 then
      if AESong[i].Count > 0 then
        AESong[i].Strings[0] := OpenDialog1.FileName
      else
        AESong[i].Add(OpenDialog1.FileName)
    else
    begin
      i := AESongIndex.Add('BGIMG');
      if (Length(AESong) < (i + 1)) then
        SetLength(AESong, i + 1);
      AESong[i] := TStringList.Create;
      AESong[i].Add(OpenDialog1.FileName);
    end
  else
    if i >= 0 then
      AESong[i].Clear;

end;

procedure TAdvancedEditForm.CancelButtonClick(Sender: TObject);
begin
  SongChanged := false;
  AdvancedEditForm.Close;
end;

procedure TAdvancedEditForm.CCLButtonClick(Sender: TObject);
begin
  EditSpecialItem('CCL');
end;

procedure TAdvancedEditForm.CopyButtonClick(Sender: TObject);
begin
  EditSpecialItem('COPY');
end;

procedure TAdvancedEditForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
  Reply : integer;
begin
  If SongChanged then
  Reply := Application.MessageBox('Song changed - do you want to save the changes?', 'Song changed', MB_ICONQUESTION + MB_YESNO);
  if Reply = IDYES then
    SaveButtonClick(Sender)
end;

procedure TAdvancedEditForm.EditSpecialItem(item: string);
var
  i: integer;
begin
  If SongScreenLB.ItemIndex > -1 then
    SongScreenLB.Selected[SongScreenLB.ItemIndex] := false;
  i := AESongIndex.IndexOf(item);
  if (i < 0) then
  begin
    AESongIndex.Add(item);
    i := AESongIndex.IndexOf(item);
    if (Length(AESong) < (i + 1)) then
      SetLength(AESong, i + 1);
    AESong[i] := TStringList.Create;
  end;
  CurrentItem := item;
  EditItem;
end;

procedure TAdvancedEditForm.AddBeginningButtonClick(Sender: TObject);
begin
  LastBeginningNo := LastBeginningNo + 1;
  If LastBeginningNo = 1 then
    NewItem('BG')
  else
    NewItem('BG' + IntToStr(LastVerseNo));
end;

procedure TAdvancedEditForm.AddBridgeButtonClick(Sender: TObject);
begin
  LastBridgeNo := LastBridgeNo + 1;
  If LastBridgeNo = 1 then
    NewItem('BR')
  else
    NewItem('BR' + IntToStr(LastBridgeNo));
end;

procedure TAdvancedEditForm.AddChorusButtonClick(Sender: TObject);
begin
  LastChorusNo := LastChorusNo + 1;
  If LastChorusNo = 1 then
    NewItem('C')
  else
    NewItem('C' + IntToStr(LastChorusNo));
end;

procedure TAdvancedEditForm.AddEndingButtonClick(Sender: TObject);
begin
  LastEndNo := LastEndNo + 1;
  If LastEndNo = 1 then
    NewItem('END')
  else
    NewItem('END' + IntToStr(LastEndNo))
end;

procedure TAdvancedEditForm.FormCreate(Sender: TObject);
begin
  AESongIndex := TStringList.Create;
end;

procedure TAdvancedEditForm.FormDestroy(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to (Length(AESong) - 1) do
  begin
    AESong[i].Clear;
  end;
  AESongIndex.Clear;
end;

procedure TAdvancedEditForm.ItemDownClick(Sender: TObject);
var
  tmpstr : string;
begin
  If (SongScreenLB.ItemIndex < 0) or (SongScreenLB.ItemIndex = (SongScreenLB.Count - 1)) then
    exit;
  tmpstr := SongScreenLB.Items[SongScreenLB.ItemIndex +1];
  SongScreenLB.Items[SongScreenLB.ItemIndex +1] := SongScreenLB.Items[SongScreenLB.ItemIndex];
  SongScreenLB.Items[SongScreenLB.ItemIndex] := tmpstr;
  SongScreenLB.Selected[SongScreenLB.ItemIndex +1] := true;
end;

procedure TAdvancedEditForm.ItemUpClick(Sender: TObject);
var
  tmpstr : string;
begin
  If SongScreenLB.ItemIndex < 1 then
    exit;
  tmpstr := SongScreenLB.Items[SongScreenLB.ItemIndex -1];
  SongScreenLB.Items[SongScreenLB.ItemIndex -1] := SongScreenLB.Items[SongScreenLB.ItemIndex];
  SongScreenLB.Items[SongScreenLB.ItemIndex] := tmpstr;
  SongScreenLB.Selected[SongScreenLB.ItemIndex -1] := true;
end;

procedure TAdvancedEditForm.MarkEndButtonClick(Sender: TObject);
begin
  If SongScreenLB.ItemIndex > -1 then
    LoopEnd := SongScreenLB.ItemIndex;
  If LoopStart > LoopEnd then
    LoopStart := 0;
  SongScreenLB.Repaint;
end;

procedure TAdvancedEditForm.MarkStartButtonClick(Sender: TObject);
begin
  If SongScreenLB.ItemIndex > -1 then
    LoopStart := SongScreenLB.ItemIndex;
  If LoopEnd < LoopStart then
    LoopEnd := SongScreenLB.Count - 1;
  SongScreenLB.Repaint;
end;

procedure TAdvancedEditForm.RepeatExistingButtonClick(Sender: TObject);
var
  i : integer;
  item : TMenuItem;
begin
  ExistingMenu.Items.Clear;
  for i := 0 to AESongIndex.Count - 1 do
  begin
    if ((AESongIndex.Strings[i] = 'COPY') or (AESongIndex.Strings[i] = 'CCL') or (AESongIndex.Strings[i] = 'BGIMG')) then
      continue;
    item := TMenuItem.Create(ExistingMenu);
    item.Caption := AESongIndex.Strings[i];
    item.OnClick := @RepeatItem;
    ExistingMenu.Items.Add(item);
  end;
  ExistingMenu.PopUp;
end;

procedure TAdvancedEditForm.SaveButtonClick(Sender: TObject);
var
  SongFile : TextFile;
  i, j : integer;
  Reload : boolean;
  Filename, Directory : string;
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

  If EditFileName = '' then
    exit;

  if CurrentItem <> '' then
    StoreItem;

  AssignFile(SongFile, EditFileName);
  Rewrite(SongFile);
  for i := 0 to SongScreenLB.Count - 1 do
  begin
    if i > 0 then
      write (SongFile, ',');
    if (i = LoopStart) and (i > 0) then
      write (SongFile, '[');
    write (SongFile, SongScreenLB.Items[i]);
    if (i = LoopEnd) and (i < (SongScreenLB.Count - 1)) then
      write (SongFile, ']');
  end;
  writeln (SongFile, '');
  for i := 0 to (Length(AESong) - 1) do
  begin
    if ((AESong[i].Count = 0) or (AESongIndex[i] = 'CCL')) then
      continue;
    writeln(SongFile, '<', AESongIndex[i], '>');
    for j := 0 to (AESong[i].Count - 1) do
      writeln(SongFile, AESong[i].Strings[j]);
    writeln(SongFile, '</', AESongIndex[i], '>');
  end;
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

  SongChanged := false;

  ModalResult := mrOK;
  If not (fsModal in FormState) then
    Close;

end;

procedure TAdvancedEditForm.SongMemoChange(Sender: TObject);
begin
  SongChanged := true;
end;


procedure TAdvancedEditForm.RepeatItem(Sender: TObject);
var
  item: string;
begin
  item := (Sender as TMenuItem).Caption;
  SongScreenLB.Items.Add(item);
end;

procedure TAdvancedEditForm.SongScreenLBClick(Sender: TObject);
begin
  if CurrentItem <> '' then
    StoreItem;
  CurrentItem := SongScreenLB.Items[SongScreenLB.ItemIndex];
  EditItem();
end;

procedure TAdvancedEditForm.SongScreenLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  ItemText: string;
begin
  with (Control as TListBox).Canvas do
  begin
    if odSelected In State then
    begin
      Pen.Color := clHighlightText;
      Brush.Color := clHighlight;
    end
    else
    begin
      Pen.Color := (Control as TListBox).Font.Color;
      Brush.Color := (Control as TListBox).Color;
      if ((index >= LoopStart) and (index <= LoopEnd)) then
        Brush.Color := clActiveCaption;
    end;
    FillRect(ARect);
    ItemText := (Control as TListBox).Items[Index];
    InflateRect(ARect, -1, -1);
    inc(ARect.Left,3);
    DrawText(Handle, PChar(ItemText), Length(ItemText), ARect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure TAdvancedEditForm.ResetSongAE();
var
  i : integer;
begin
  for i := 0 to (Length(AESong) - 1) do
  begin
    AESong[i].Clear;
  end;
  If AESongIndex <> nil then
    AESongIndex.Clear;
  LastVerseNo := 0;
  LastChorusNo := 0;
  LastBridgeNo := 0;
  LastEndNo := 0;
  CurrentItem := '';
  EditFileName := '';
  SongChanged := false;
end;

procedure TAdvancedEditForm.NewSong();
begin
  ResetSongAE();
end;

procedure TAdvancedEditForm.NewItem(Item: string);
var
  i : integer;
begin
  If CurrentItem <> '' then
    StoreItem;
  CurrentItem := Item;
  If (LoopEnd = (SongScreenLB.Count - 1)) and (CurrentItem <> 'END') then
    LoopEnd := SongScreenLB.Count;
  SongScreenLB.Items.Add(CurrentItem);
  SongScreenLB.Selected[SongScreenLB.Count - 1] := true;
  AESongIndex.Append(CurrentItem);
  i := Length(AESong);
  SetLength(AESong, i + 1);
  AESong[i] := TStringList.Create;
  EditItem();
  SongChanged := true;
end;

procedure TAdvancedEditForm.EditItem();
var
  i, j : integer;
  IsChanged : boolean;
begin
  i := AESongIndex.IndexOf(CurrentItem);
  IsChanged := SongChanged;
  SongMemo.Lines.Clear();
  for j := 0 to (AESong[i].Count - 1) do
    SongMemo.Lines.Add(AESong[i].Strings[j]);
  SongMemo.SetFocus;
  SongChanged := IsChanged;
end;

procedure TAdvancedEditForm.StoreItem();
var
  i, j : integer;
begin
  i := AESongIndex.IndexOf(CurrentItem);
  AESong[i].Clear();
  for j := 0 to (SongMemo.Lines.Count - 1) do
    AESong[i].Add(SongMemo.Lines[j]);
end;

procedure TAdvancedEditForm.EditSong(SongFileName: string);
var
  SongFile: TextFile;
  Line: string;
  CurrentIndex, i : integer;
  CurrentChar : char;
begin
  ResetSongAE();
  if FileExists(SongFileName) then
  begin
    EditFileName := SongFileName;
    AESongIndex.Clear;
    for i := 0 to (Length(AESong) - 1) do
      AESong[i].Clear;
    SongScreenLB.Items.Clear;
    AssignFile(SongFile, SongFileName);
    Reset(SongFile);
    CurrentItem := '';
    CurrentIndex := -1;
    Readln(SongFile, Line);
    Line := UpperCase(Line);
    LoopStart := 0;
    LoopEnd := -1;
    SongChanged := false;

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
              if AESongIndex.IndexOf(CurrentItem) = -1 then
              begin
                 CurrentIndex := AESongIndex.Add(CurrentItem);
                 If (Length(AESong) < (CurrentIndex + 1)) then
                   SetLength(AESong, CurrentIndex + 1);
                 AESong[CurrentIndex] := TStringList.Create;
              end;
              CurrentIndex := SongScreenLB.Items.Add(CurrentItem);
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
        CurrentIndex := SongScreenLB.Items.Add(CurrentItem);
      // If we haven't set the end of the loop then assume it's the end of the song
      if LoopEnd = -1 then
        LoopEnd := CurrentIndex;
    end;

    CurrentIndex := -1;
    while not EOF(SongFile) do
    begin
      Readln(SongFile, Line);
      Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);
      if Copy(Line, 1, 1) = '<' then
      begin
        Line := UpperCase(Line);
        if Copy(Line, 2, 1) = '/' then
          CurrentIndex := -1
        else
        begin
          CurrentItem := Copy(Line, 2, Pos('>', Line) - 2);
          CurrentIndex := AESongIndex.IndexOf(CurrentItem);
          if (CurrentIndex < 0) then
          begin
            AESongIndex.Add(CurrentItem);
            CurrentIndex := AESongIndex.IndexOf(CurrentItem);
            If (Length(AESong) < (CurrentIndex + 1)) then
              SetLength(AESong, CurrentIndex + 1);
            AESong[CurrentIndex] := TStringList.Create;
          end;
        end;
      end
      else
        if CurrentIndex >= 0 then
          AESong[CurrentIndex].Add(Line);
    end;
    CloseFile(SongFile);

    // If the play order isn't defined then just do everythig in order
    if SongScreenLB.Count = 0 then
    begin
      for i := 0 to AESongIndex.Count - 1 do
      begin
        if ((AESongIndex[i] = 'COPY') or (AESongIndex[i] = 'CCL') or (AESongIndex[i] = 'BGIMG')) then
          continue;
        SongScreenLB.Items.Add(AESongIndex[i]);
      end;
      LoopEnd := SongScreenLB.Count - 1;
    end;

    // Clear play list of items not in the song file
    i := 0;
    while i < SongScreenLB.Items.Count do
    begin
      if AESongIndex.IndexOf(SongScreenLB.Items[i]) = -1 then
      begin
        SongScreenLB.Items.Delete(i);
        if LoopStart > i then
          LoopStart := LoopStart - 1;
        if LoopEnd >= i then
          LoopEnd := LoopEnd - 1;
      end
      else
        i := i + 1;
    end;
    CurrentItem := SongScreenLB.Items[0];
    SongScreenLB.Selected[0] := true;
    EditItem;
  end;
end;

end.

