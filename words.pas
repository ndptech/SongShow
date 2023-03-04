unit Words;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, BGRABitmap, BGRABitmapTypes, BGRAVectorize, BGRAText, Character, math, lazutf8, LCLType;

type

  { TWordsForm }

  TWordsForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    Screens : Array of TBGRABitmap;
    ScreenMade : Array of boolean;
  public
    { public declarations }
    vf: TBGRAVectorizedFont;
    procedure DrawScreen(PLItem: Integer);
    procedure InitialiseScreens();
    procedure SetDimensions();
    procedure Triangles(var bmp: TBGRABitmap; y : integer; fill : boolean);
    function IsRtoL(S: String):boolean;
    procedure DisplayLine(PLItem: integer; y : integer; Line: String; Format: String; Secondary: boolean);
    procedure ExportImages(FileName: String);
    procedure PopulateDefaultBG(FileName: String);
    procedure PopulateSongBG(FileName: String);
end;

var
  WordsForm: TWordsForm;
  DefBGImg : TBGRABitmap;
  SongBGImg : TBGRABitmap;

implementation

uses Control;

{$R *.lfm}

{ TWordsForm }

procedure TWordsForm.FormCreate(Sender: TObject);
begin
  vf := TBGRAVectorizedFont.Create;
  WordsForm.SetDimensions();
  SongBGImg := TBGRABitmap.Create;
end;

procedure TWordsForm.FormDestroy(Sender: TObject);
begin
  vf.Free;
  if DefBGImg <> nil then
    DefBGImg.Free;
  if SongBGImg <> nil then
    SongBGImg.Free;
end;

procedure TWordsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_Prior) or (Key = VK_Next) or (Key = VK_End) or (Key = VK_Home) or (Key = VK_Escape) or (Key = VK_F5) then
  begin
    ControlForm.SongControlKeyDown(Sender, Key, Shift);
    Key := 0;
  end;
end;

procedure TWordsForm.FormPaint(Sender: TObject);
begin
  if ControlForm.Verse.Count > 0 then
  begin
    if ScreenMade[ControlForm.CurrentPLItem] = false then
      DrawScreen(ControlForm.CurrentPLItem);
    Screens[ControlForm.CurrentPLItem].Draw(Canvas, 0, 0, True); // draw the bitmap in opaque mode (faster)
  end;
end;

procedure TWordsForm.FormShow(Sender: TObject);
begin
  SetDimensions();
end;

procedure TWordsForm.DrawScreen(PLItem : integer);
var
  y, y2, y3, i, SecTop, ThirdTop : integer;
  bgwidth, bgheight : longint;
  TmpVerse, TmpVerseFmt, TmpSecVerse, TmpSecVerseFmt, TmpThirdVerse, TmpThirdVerseFmt : TStrings;
  DisplayString, RemainString, ImgFilename : String;
  screenbg: TBGRABitmap;
  background: TBGRABitmap;
begin
  if ScreenMade[PLItem] then
    exit;
  TmpVerse := TStringList.Create;
  TmpVerseFmt := TStringList.Create;

  TmpSecVerse := TStringList.Create;
  TmpSecVerseFmt := TStringList.Create;

  TmpThirdVerse := TStringList.Create;
  TmpThirdVerseFmt := TStringList.Create;

  TmpVerse.Assign(ControlForm.Song[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])]);
  TmpVerseFmt.Assign(ControlForm.SongFmt[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])]);
  If ControlForm.SecondaryBibleId > 0 then
    If Length(ControlForm.SecBible) > ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem]) then
      if ControlForm.SecBible[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])] <> nil then
      begin
        TmpSecVerse.Assign(ControlForm.SecBible[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])]);
        TmpSecVerseFmt.Assign(ControlForm.SecBibleFmt[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])]);
      end;
  If ControlForm.TertiaryBibleId > 0 then
    If Length(ControlForm.ThirdBible) > ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem]) then
      if ControlForm.ThirdBible[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])] <> nil then
      begin
        TmpThirdVerse.Assign(ControlForm.ThirdBible[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])]);
        TmpThirdVerseFmt.Assign(ControlForm.ThirdBibleFmt[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])]);
      end;

  Screens[PLItem] := TBGRABitmap.Create(WordsForm.Width,WordsForm.Height,ControlForm.BGColour); //creates image with black background
  if ControlForm.ShowBorder then
  begin
    Screens[PLItem].Canvas2D.lineWidth:=1;
    Screens[PLItem].Canvas2D.strokeStyle(ControlForm.FGColour);
    Screens[PLItem].Canvas2D.strokeRect(0,0,WordsForm.Width, WordsForm.Height);
  end;

  ImgFilename := ControlForm.ScreenBGImgs[ControlForm.SongIndex.IndexOf(ControlForm.PlayOrder[PLItem])];
  if ImgFilename <> '' then
  begin
    if not FileExists(ImgFilename) then
      ImgFilename := ControlForm.SongDirectory + ImgFilename;
    if FileExists(ImgFilename) then
    begin
      try
        screenbg := TBGRABitmap.Create();
        screenbg.LoadFromFile(ImgFilename);
      except
        ShowMessage('Unable to load screen background');
        screenbg.Free;
        ImgFilename := '';
      end;
    end
    else
      ImgFilename := '';
  end;

  if ImgFilename <> '' then
    background := screenbg
  else
    if ControlForm.CurrentBGimage <> '' then
      background := SongBGImg
    else
      if ControlForm.BGImage <> '' then
        background := DefBGImg
      else
        background := nil;

  if background <> nil then
  begin
    if background.Width > WordsForm.Width then
      bgwidth := WordsForm.Width
    else
      bgwidth := background.Width;
    bgheight := Round(bgwidth * background.Height / background.Width);
    if bgheight > WordsForm.Height then
    begin
      bgheight := WordsForm.Height;
      bgwidth := Round(bgheight * background.Width / background.Height);
    end;
    Screens[PLItem].Canvas2D.drawImage(background, Round((WordsForm.Width - bgwidth)/2), Round((WordsForm.Height - bgheight) / 2), bgwidth, bgheight);
  end;

  if ImgFilename <> '' then
    screenbg.Free;

  Screens[PLItem].Canvas2D.lineWidth:=ControlForm.OLSize;
  Screens[PLItem].Canvas2D.fillStyle(ControlForm.FGColour);
  Screens[PLItem].Canvas2D.strokeStyle(ControlForm.OLColour);

  If (ControlForm.SplitDir = 'V') and (TmpSecVerse.Count > 0) then
  begin // Vertical split - calculate top of secondary display
    y2 := (Height - ControlForm.TopMargin - ControlForm.BottomMargin) div ControlForm.TextFontSize;
    if (y2 > ControlForm.TextLinesPerScreen) then
      y2 := ControlForm.TextLinesPerScreen;
    If (ControlForm.TertiaryBibleId > 0) then
      SecTop := ControlForm.TopMargin + (Round((y2 - 1)/3) + 1) * Round(vf.FullHeight * 1)
    else
      SecTop := ControlForm.TopMargin + (Round((y2 - 1) * ControlForm.BiblePrimarySplit / 100) + 1) * Round(vf.FullHeight * 1);
    ThirdTop := ControlForm.TopMargin + (Round((y2 - 1)/3) * 2 + 1) * Round(vf.FullHeight * 1);
  end;

  if (ControlForm.OLSize > 0) then
  begin
    y := ControlForm.TopMargin;
    If (ControlForm.SplitDir = 'V') and (TmpSecVerse.Count > 0) then
      y2 := SecTop;
    If (ControlForm.SplitDir = 'V') and (TmpThirdVerse.Count > 0) then
      y3 := ThirdTop;
    vf.OutlineMode:=twoFillOverStroke;

    for i := 0 to (TmpVerse.Count - 1) do
    begin
      DisplayLine(PLItem, y, TmpVerse.Strings[i], TmpVerseFmt.Strings[i], false);
      y += round(vf.FullHeight * 1);
    end;
    If (TmpSecVerse.Count > 0) and (ControlForm.SplitDir = 'H') then
      y := ControlForm.TopMargin;

    // Display Second verse
    for i := 0 to (TmpSecVerse.Count - 1) do
    begin
      If ControlForm.SplitDir = 'V' then
      begin
        DisplayLine(PLItem, y2, TmpSecVerse.Strings[i], TmpSecVerseFmt.Strings[i], true);
        y2 += round(vf.FullHeight * 1);
      end
      else
        DisplayLine(PLItem, y, TmpSecVerse.Strings[i], TmpSecVerseFmt.Strings[i], true);
      y += round(vf.FullHeight * 1);
    end;

    // Display Third verse
    for i := 0 to (TmpThirdVerse.Count - 1) do
    begin
      If ControlForm.SplitDir = 'V' then
      begin
        DisplayLine(PLItem, y3, TmpThirdVerse.Strings[i], TmpThirdVerseFmt.Strings[i], true);
        y3 += round(vf.FullHeight * 1);
      end
      else
        DisplayLine(PLItem, y, TmpSecVerse.Strings[i], TmpSecVerseFmt.Strings[i], true);
      y += round(vf.FullHeight * 1);
    end;

    If PLItem = (ControlForm.PlayOrder.Count - 1) then
    begin
      vf.FullHeight:=ControlForm.FontSize / 2;
      vf.Name := ControlForm.FontName;
      vf.Style := [];
      DisplayString := ControlForm.CopyRight;
      repeat
        vf.SplitText(DisplayString, WordsForm.Width - ControlForm.RightMargin, RemainString);
        DisplayString := Trim(DisplayString);
        vf.DrawText(Screens[PLItem].Canvas2D, DisplayString, WordsForm.Width - ControlForm.RightMargin - vf.GetTextSize(DisplayString).x, y, twaTopLeft);
        DisplayString := RemainString;
        y += round(vf.FullHeight * 1);
      until RemainString = '';
    end;
    if (PLItem = ControlForm.LoopEnd) and (PLItem <> (ControlForm.PlayOrder.Count - 1)) then
      Triangles(Screens[PLItem], y, false);
  end;
  y := ControlForm.TopMargin;
  If (ControlForm.SplitDir = 'V') and (TmpSecVerse.Count > 0) then
    y2 := SecTop;
  If (ControlForm.SplitDir = 'V') and (TmpThirdVerse.Count > 0) then
    y3 := ThirdTop;
  vf.OutlineMode:=twoFill;
  for i := 0 to (TmpVerse.Count - 1) do
  begin
    DisplayLine(PLItem, y, TmpVerse.Strings[i], TmpVerseFmt.Strings[i], false);
    y += round(vf.FullHeight * 1);
  end;
  If (ControlForm.SecondaryBibleId > 0) and (TmpSecVerse.Count > 0) and (ControlForm.SplitDir = 'H') then
    y := ControlForm.TopMargin;

  // Display Second Bible
  if (ControlForm.SecondaryBibleId > 0) then
    for i := 0 to (TmpSecVerse.Count - 1) do
    begin
      If ControlForm.SplitDir = 'V' then
      begin
        DisplayLine(PLItem, y2, TmpSecVerse.Strings[i], TmpSecVerseFmt.Strings[i], true);
        y2 += round(vf.FullHeight * 1);
      end
      else
        DisplayLine(PLItem, y, TmpSecVerse.Strings[i], TmpSecVerseFmt.Strings[i], true);
      y += round(vf.FullHeight * 1);
    end;

  // Display Third Bible
  if (ControlForm.TertiaryBibleId > 0) then
    for i := 0 to (TmpThirdVerse.Count - 1) do
    begin
      If ControlForm.SplitDir = 'V' then
      begin
        DisplayLine(PLItem, y3, TmpThirdVerse.Strings[i], TmpThirdVerseFmt.Strings[i], true);
        y3 += round(vf.FullHeight * 1);
      end
      else
        DisplayLine(PLItem, y, TmpSecVerse.Strings[i], TmpSecVerseFmt.Strings[i], true);
      y += round(vf.FullHeight * 1);
    end;

  If PLItem = (ControlForm.PlayOrder.Count - 1) then
  begin
    vf.FullHeight:=ControlForm.FontSize / 2;
    vf.Name := ControlForm.FontName;
    vf.Style := [];
    DisplayString := ControlForm.CopyRight;
    repeat
      vf.SplitText(DisplayString, WordsForm.Width - ControlForm.RightMargin, RemainString);
      DisplayString := Trim(DisplayString);
      vf.DrawText(Screens[PLItem].Canvas2D, DisplayString, WordsForm.Width - ControlForm.RightMargin - vf.GetTextSize(DisplayString).x, y, twaTopLeft);
      DisplayString := RemainString;
      y += round(vf.FullHeight * 1);
    until RemainString = '';
  end;
  if (PLItem = ControlForm.LoopEnd) and (PLItem <> (ControlForm.PlayOrder.Count - 1)) then
    Triangles(Screens[PLItem], y, true);
  ScreenMade[PLItem] := true;
  TmpVerse.Clear;
  TmpVerse.Destroy;
  TmpVerseFmt.Clear;
  TmpVerseFmt.Destroy;

  TmpSecVerse.Clear;
  TmpSecVerse.Destroy;
  TmpSecVerseFmt.Clear;
  TmpSecVerseFmt.Destroy;

  TmpThirdVerse.Clear;
  TmpThirdVerse.Destroy;
  TmpThirdVerseFmt.Clear;
  TmpThirdVerseFmt.Destroy;

end;

procedure TWordsForm.InitialiseScreens();
var
  i : integer;
begin
  For i := 0 to Length(Screens) - 1 do
    screens[i].Free;
  SetLength(Screens, 0);
  SetLength(Screens, ControlForm.PlayOrder.Count );
  SetLength(ScreenMade, ControlForm.PlayOrder.Count );
  For i := 0 to Length(ScreenMade) - 1 do
    ScreenMade[i] := false;
end;

procedure TWordsForm.Triangles(var bmp: TBGRABitmap; y : integer; fill: boolean);
var
  theight : integer;
  xoff : integer;
  x, i : integer;
begin
  theight := ControlForm.FontSize div 2;
  xoff := Round(Sqrt((theight * theight) - ((theight / 2) * (theight / 2))));
  x := WordsForm.Width - ControlForm.RightMargin;
  bmp.Canvas2D.beginPath;
  for i := 0 to 2 do
  begin
    bmp.Canvas2D.moveTo(x, y);
    bmp.Canvas2D.lineTo(x, y + theight);
    bmp.Canvas2D.lineTo(x - xoff, y + (theight / 2));
    bmp.Canvas2D.closePath();
    if (fill) then
      bmp.Canvas2D.fill()
    else
      bmp.Canvas2D.stroke();
    x := x - theight;
  end
end;

procedure TWordsForm.SetDimensions();
begin
  WordsForm.Top := ControlForm.TopWords;
  WordsForm.Left := ControlForm.LeftWords;
  If (ControlForm.HeightWords > 0) then
    WordsForm.Height := ControlForm.HeightWords
  else
    WordsForm.Height := screen.Height;
  If (ControlForm.WidthWords > 0) then
    WordsForm.Width := ControlForm.WidthWords
  else
    WordsForm.Width := screen.Width;
end;

function TWordsForm.IsRtoL(S: String):boolean;
var
  CurP, EndP: PChar;
  Len, CharVal: Integer;
begin
  CurP := PChar(S);
  EndP := CurP + length(S);
  while CurP < EndP do
  begin
    Len := UTF8CodepointSize(CurP);
    if len > 1 then
    begin
      CharVal := pword(CurP)^;
      if CharVal and 255 in [215,216,217] then exit(true);
    end;
    inc(CurP, Len);
  end;
  result := false;
end;

procedure TWordsForm.DisplayLine(PLItem: integer; y : integer; Line: String; Format: String; Secondary: boolean);
var
  x, j: integer;
  RtoL: boolean;
  Super: String;
begin
  RtoL := IsRtoL(Line);

  if Copy(Format, 3, 1) = 'C' then
    vf.Name := ControlForm.ChorusFont
  else
    if Copy(Format, 3, 1) = 'T' then
      vf.Name := ControlForm.TextFont
    else
      vf.Name := ControlForm.FontName;
  If Copy(Format, 2, 1) = 'I' then
    vf.Style := [fsItalic, fsBold]
  else
    vf.Style := [fsBold];
  Case Copy(Format, 1, 1) of
    'L' : begin // Left line
      If RtoL then
        x := Width - ControlForm.RightMargin
      else
        x := ControlForm.LeftMargin;
      end;
    'R' : begin // Indented line
      If RtoL then
        x := Width - ControlForm.RightMargin - ControlForm.LineIndent
      else
        x := ControlForm.LineIndent + ControlForm.LeftMargin;
      end;
    'S' : begin  // Scripture line
      If ControlForm.SecondaryBibleId > 0 then
        j := Round((Width - (ControlForm.LeftMargin + ControlForm.RightMargin + ControlForm.HorizSplitGap)) * ControlForm.BiblePrimarySplit / 100);
      If RtoL then
      begin
        If ControlForm.SecondaryBibleId > 0 then  // We show two bibles
          If Secondary or (ControlForm.SplitDir = 'V') then
            x := Width - ControlForm.RightMargin  // This is the secondary or we're splitting V
          else
            x := ControlForm.LeftMargin + j  // This is the primary and we're splitting H, j being the width of the primary
        else
          x := Width - ControlForm.RightMargin
      end
      else
        If ControlForm.SecondaryBibleId > 0 then // we show two bibles
          If Secondary and (ControlForm.SplitDir = 'H') then
            x := ControlForm.LeftMargin + j + ControlForm.HorizSplitGap // This is the secodary and we're splitting H
          else
            x := ControlForm.LeftMargin  // This is the primary or we're splitting V
        else
        x := ControlForm.LeftMargin;
      end;
  end;

  If RtoL then
  begin
    Screens[PLItem].FontName := vf.Name;
    Screens[PLItem].FontStyle := vf.Style;
  end;

  j := Pos('^', Line);
  While (j > 0) do
  begin
    if (j > 1) then
    begin
      if Copy(Format, 3, 1) = 'T' then
        vf.FullHeight := ControlForm.TextFontSize
      else
        vf.FullHeight := ControlForm.FontSize;
      If RtoL then
      begin
        Screens[PLItem].FontFullHeight:=Round(vf.FullHeight);
        Screens[PLItem].TextOut(x, y, Copy(Line, 1, j - 1), ControlForm.FGColour, taRightJustify);
        x := x - Screens[PLItem].TextSize(Copy(Line, 1, j - 1)).cx;
      end
      else
      begin
        vf.DrawText(Screens[PLItem].Canvas2D, Copy(Line, 1, j - 1), x, y);
        x := x + Round(vf.GetTextSize(Copy(Line, 1, j - 1)).x);
      end;
    end;
    Line := Copy(Line, j + 1, Length(Line) - j);
    Super := '';
    While (IsNumber(WideString(Copy(Line, 1, 1)), 1)) do
    begin
      Super := Super + Copy(Line, 1, 1);
      Line := Copy(Line, 2, Length(Line) - 1);
    end;
    If (Length(Super) > 0) then
    begin
      if Copy(Format, 3, 1) = 'T' then
        vf.FullHeight := ControlForm.TextFontSize / 2
      else
        vf.FullHeight := ControlForm.FontSize / 2;
      if RtoL then
      begin
        Screens[PLItem].FontFullHeight:=Round(vf.FullHeight);
        Screens[PLItem].TextOut(x, y, Super, ControlForm.FGColour, taRightJustify);
        x := x - Ceil(vf.GetTextSize(' ' + Super).x);
      end
      else
      begin
        vf.DrawText(Screens[PLItem].Canvas2D, Super, x, y);
        x := x + Ceil(vf.GetTextSize(Super).x);
      end;
    end;
    j := Pos('^', Line);
  end;

  if Copy(Format, 3, 1) = 'T' then
    vf.FullHeight := ControlForm.TextFontSize
  else
    vf.FullHeight := ControlForm.FontSize;

  if RtoL then
  begin
    Screens[PLItem].FontFullHeight:=Round(vf.FullHeight);
    Screens[PLItem].TextOut(x, y, Line, ControlForm.FGColour, taRightJustify)
  end
  else
    vf.DrawText(Screens[PLItem].Canvas2D, Line, x, y);

end;

procedure TWordsForm.ExportImages(FileName: String);
var
  i : integer;
  BaseFileName, FullFileName : String;
begin
  If (Pos('.png', FileName) > 0) then
    BaseFileName := Copy(FileName, 1, Pos('.png', FileName) -1)
  else
    BaseFileName := FileName;
  for i := 0 to ControlForm.PlayOrder.Count - 1 do
  begin
    if ScreenMade[i] = false then
      DrawScreen(i);
    FullFileName := BaseFileName + Format('%.3d', [i]) + '.png';
    Screens[i].SaveToFile(FullFileName);
  end;
end;

procedure TWordsForm.PopulateDefaultBG(FileName: String);
begin
  if DefBGImg <> nil then
  begin
    DefBGImg.Free;
    DefBGImg := nil;
  end;
  if not FileExists(FileName) then
    FileName := ControlForm.SongDirectory + FileName;
  if FileExists(FileName) then
  begin
    try
      DefBGImg := TBGRABitmap.Create();
      DefBGImg.LoadFromFile(FileName);
    except
      ShowMessage('Unable to load default background');
      DefBGImg.Free;
    end;
  end;
end;

procedure TWordsForm.PopulateSongBG(FileName: String);
begin
  if SongBGImg <> nil then
  begin
    SongBGImg.Free;
    SongBGImg := nil;
  end;
  If FileName = '' then
    exit;
  if not FileExists(FileName) then
    FileName := ControlForm.SongDirectory + FileName;
  if FileExists(FileName) then
  begin
    try
      SongBGImg := TBGRABitmap.Create();
      SongBGImg.LoadFromFile(FileName);
    except
      ShowMessage('Unable to load default background');
      DefBGImg.Free;
    end;
  end;
end;

end.

