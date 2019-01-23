(***********************************************************

  TEditorEx (2007/01/25)

  Copyright (c) 2001-2007 Km
  http://homepage2.nifty.com/Km/

***********************************************************)
unit EditorEx;

{$BOOLEVAL OFF}

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, Messages, ShellApi,
  HEditor, hOleddEditor, heClasses, heUtils, heRaStrings, hOleddUtils, heFountain,
  Oniguruma, Onig;

const
  // 文字種
  ckSeparator = #$30; // '0':セパレータ
  ckHAnk      = #$31; // '1':半角英数字
  ckHKatakana = #$32; // '2':半角カタカナ
  ckZAnk      = #$33; // '3':全角英数字
  ckZKatakana = #$34; // '4':全角カタカナ
  ckZHiragana = #$35; // '5':ひらがな
  ckZKanji    = #$36; // '6':漢字

type

  TExSearchOption = (
    soMatchCase,      // 英大文字／小文字を区別
    soRegexp,         // 正規表現
    soEscSeq,         // エスケープシーケンス(\t, \r, \n, \0, \1, …)を使用
    soWholeWord);     // 単語のみ
  TExSearchOptions = set of TExSearchOption;

  PSearchInfo = ^TSearchInfo;
  TSearchInfo = record
    Start, Len: Integer;
    MatchList: TStrings;
  end;

  TReplaceInfo = record
    Row: Integer;
    Str, Line: string;
    Wrap: Boolean;
  end;

  TParenInfo = record
    Row, Index: Integer;
    Paren: string;
  end;


  TEditorExMarks = class(TNotifyPersistent)
  private
    FDBSpaceMark: TEditorMark;
    FSpaceMark: TEditorMark;
    FTabMark: TEditorMark;
    FFindMark: TEditorMark;
    FHit: TFountainColor;
    FParenMark: TEditorMark;
    FCurrentLine: TEditorMark;
    FDigitLine: TEditorMark;
    FImageLine: TEditorMark;
    FImg0Line: TEditorMark;
    FImg1Line: TEditorMark;
    FImg2Line: TEditorMark;
    FImg3Line: TEditorMark;
    FImg4Line: TEditorMark;
    FImg5Line: TEditorMark;
    FEvenLine: TEditorMark;
    function  GetIndicated: Boolean;
    procedure SetDBSpaceMark(Value: TEditorMark);
    procedure SetSpaceMark(Value: TEditorMark);
    procedure SetTabMark(Value: TEditorMark);
    procedure SetFindMark(Value: TEditorMark);
    procedure SetHit(Value: TFountainColor);
    procedure SetParenMark(Value: TEditorMark);
    procedure SetCurrentLine(Value: TEditorMark);
    procedure SetDigitLine(Value: TEditorMark);
    procedure SetImageLine(Value: TEditorMark);
    procedure SetImg0Line(Value: TEditorMark);
    procedure SetImg1Line(Value: TEditorMark);
    procedure SetImg2Line(Value: TEditorMark);
    procedure SetImg3Line(Value: TEditorMark);
    procedure SetImg4Line(Value: TEditorMark);
    procedure SetImg5Line(Value: TEditorMark);
    procedure SetEvenLine(Value: TEditorMark);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Indicated: Boolean read GetIndicated;
    property DBSpaceMark: TEditorMark read FDBSpaceMark write SetDBSpaceMark;
    property SpaceMark: TEditorMark read FSpaceMark write SetSpaceMark;
    property TabMark: TEditorMark read FTabMark write SetTabMark;
    property FindMark: TEditorMark read FFindMark write SetFindMark;
    property Hit: TFountainColor read FHit write SetHit;
    property ParenMark: TEditorMark read FParenMark write SetParenMark;
    property CurrentLine: TEditorMark read FCurrentLine write SetCurrentLine;
    property DigitLine: TEditorMark read FDigitLine write SetDigitLine;
    property ImageLine: TEditorMark read FImageLine write SetImageLine;
    property Img0Line: TEditorMark read FImg0Line write SetImg0Line;
    property Img1Line: TEditorMark read FImg1Line write SetImg1Line;
    property Img2Line: TEditorMark read FImg2Line write SetImg2Line;
    property Img3Line: TEditorMark read FImg3Line write SetImg3Line;
    property Img4Line: TEditorMark read FImg4Line write SetImg4Line;
    property Img5Line: TEditorMark read FImg5Line write SetImg5Line;
    property EvenLine: TEditorMark read FEvenLine write SetEvenLine;
  end;


  TVerticalLine = class(TCollectionItem)
  private
    FPosition: Integer;
    FColor: TColor;
    FVisible: Boolean;
    FPrevPosition: Integer;
    procedure SetPosition(Value: Integer);
    procedure SetColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Position: Integer read FPosition write SetPosition;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;


  TVerticalLines = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TVerticalLine;
    procedure SetItem(Index: Integer; Value: TVerticalLine);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TVerticalLine;
    procedure Show;
    procedure Hide;
    property Items[Index: Integer]: TVerticalLine read GetItem write SetItem; default;
  end;


  TEditorEx = class(TOleddEditor)
  private
    FExMarks: TEditorExMarks;
    FDropFileNames: TStrings;
    FFindString: string;
    FFindInfo: TSearchInfo;
    FFindLineFeedCount: Integer;
    FExSearchOptions: TExSearchOptions;
    FSearchInfoList: TList;
    FVerticalLines: TVerticalLines;
    FParen: Boolean;
    FLeftParenInfo: TParenInfo;
    FRightParenInfo: TParenInfo;
    FLastLine: Integer;
    FChanged: Boolean;
    FCaretMoveCount: Integer;
    FOnigEnabled: Boolean;
    procedure SetExMarks(Value: TEditorExMarks);
    procedure SetFindString(const S: string);
    procedure SetFindLineFeedCount(const Value: Integer);
    procedure SetExSearchOptions(Value: TExSearchOptions);
    procedure SetVerticalLines(Value: TVerticalLines);
    procedure ClearSearchInfo;
    function SetSearchInfoList(const ARow: Integer): Integer;
    function SetParenInfo(ARow, Index: Integer): Boolean;
  protected
    procedure DoCaretMoved; override;
    procedure DoChange; override;
    procedure DoDrawLine(ARect: TRect; X, Y: Integer; LineStr: string; Index: Integer; SelectedArea: Boolean); override;
    procedure DoDropFiles(Drop: HDrop; KeyState: Longint; Point: TPoint); override;
    procedure DoTopColChange; override;
    procedure DrawDBSpaceMark(X, Y: Integer; IsLeadByte: Boolean); virtual;
    procedure DrawSpaceMark(X, Y: Integer); virtual;
    procedure DrawTabMark(X, Y: Integer); virtual;
    procedure DrawFindMark(Xp, Xq, Y: Integer); virtual;
    procedure DrawFindString(ARect: TRect; X: Integer; S: string); virtual;
    procedure DrawParenMark(X, Y: Integer; S: string); virtual;
    procedure DrawLineMark(ARect: TRect; X, Y: Integer; S: string; Index: Integer; AColor: TColor); virtual;
    procedure DrawEof(X, Y: Integer); override;
    procedure DrawUnderline(ARow: Integer); override;
    procedure DrawVerticalLine(Index: Integer); virtual;
    procedure DrawVerticalLines; virtual;
    procedure Paint; override;
    function CharKind(const S: string; Index: Integer): Char; virtual;
    function ColToListChar(ARow, ACol: Integer): Integer; virtual;
    function GetLineFirstRow(const ARow: Integer): Integer; virtual;
    function GetLineLastRow(const ARow: Integer): Integer; virtual;
    function IsFindLinefeed: Boolean; virtual;
    function FindFirst(const ARow, Index: Integer): Boolean; virtual;
    function FindLast(const ARow, Index: Integer): Boolean; virtual;
    function GroupEscSeqToString(const S: string; Info: PSearchInfo):string; virtual;
    function ReplaceLine(var RInfo: TReplaceInfo): Integer; virtual;
    function CreateEditorExMarks: TEditorExMarks; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LineString(const ARow: Integer): string;
    function RangeString(const ARow: Integer; Range: Integer): string;
    function CharKindFromCaret: Char;
    function CharKindFromPos(const Pos: TPoint): Char;
    function IsWholeWord(const S: string; const Start, Len: Integer): Boolean;
    function FindNext: Boolean;
    function FindPrev: Boolean;
    function FindNextLinefeed: Boolean;
    function FindPrevLinefeed: Boolean;
    function Replace(const S: string): Boolean;
    function ReplaceAll(const S: string; SpeedUp: Boolean): Integer;
    function EscSeqToString(const S: string): string;
    function IsRowSelected: Boolean;
    function IsRowHit(const ARow: Integer): Boolean;
    function OnigVersion: string; virtual;
    function OnigCopyright: string; virtual;
    procedure GotoParenMark;
    property DropFileNames: TStrings read FDropFileNames;
    property FindString: string read FFindString write SetFindString;
  published
    property ExMarks: TEditorExMarks read FExMarks write SetExMarks;
    property ExSearchOptions: TExSearchOptions read FExSearchOptions write SetExSearchOptions;
    property FindLineFeedCount: Integer read FFindLineFeedCount write SetFindLineFeedCount;
    property VerticalLines: TVerticalLines read FVerticalLines write SetVerticalLines;
  end;


implementation


function TEditorExMarks.GetIndicated: Boolean;
begin
 Result := FDBSpaceMark.Visible or
           FSpaceMark.Visible   or
           FTabMark.Visible     or
           FFindMark.Visible    or
           FParenMark.Visible   or
           FCurrentLine.Visible or
           FDigitLine.Visible   or
           FImageLine.Visible   or
           FImg0Line.Visible    or
           FImg1Line.Visible    or
           FImg2Line.Visible    or
           FImg3Line.Visible    or
           FImg4Line.Visible    or
           FImg5Line.Visible    or
           FEvenLine.Visible;
end;


procedure TEditorExMarks.SetDBSpaceMark(Value: TEditorMark);
begin
  FDBSpaceMark.Assign(Value);
end;


procedure TEditorExMarks.SetSpaceMark(Value: TEditorMark);
begin
  FSpaceMark.Assign(Value);
end;


procedure TEditorExMarks.SetTabMark(Value: TEditorMark);
begin
  FTabMark.Assign(Value);
end;


procedure TEditorExMarks.SetFindMark(Value: TEditorMark);
begin
  FFindMark.Assign(Value);
end;


procedure TEditorExMarks.SetHit(Value: TFountainColor);
begin
  FHit.Assign(Value);
end;


procedure TEditorExMarks.SetParenMark(Value: TEditorMark);
begin
  FParenMark.Assign(Value);
end;


procedure TEditorExMarks.SetCurrentLine(Value: TEditorMark);
begin
  FCurrentLine.Assign(Value);
end;


procedure TEditorExMarks.SetDigitLine(Value: TEditorMark);
begin
  FDigitLine.Assign(Value);
end;


procedure TEditorExMarks.SetImageLine(Value: TEditorMark);
begin
  FImageLine.Assign(Value);
end;


procedure TEditorExMarks.SetImg0Line(Value: TEditorMark);
begin
  FImg0Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg1Line(Value: TEditorMark);
begin
  FImg1Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg2Line(Value: TEditorMark);
begin
  FImg2Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg3Line(Value: TEditorMark);
begin
  FImg3Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg4Line(Value: TEditorMark);
begin
  FImg4Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg5Line(Value: TEditorMark);
begin
  FImg5Line.Assign(Value);
end;


procedure TEditorExMarks.SetEvenLine(Value: TEditorMark);
begin
  FEvenLine.Assign(Value);
end;


constructor TEditorExMarks.Create;
begin
  FDBSpaceMark     := TEditorMark.Create;
  FSpaceMark       := TEditorMark.Create;
  FTabMark         := TEditorMark.Create;
  FFindMark        := TEditorMark.Create;
  FHit             := TFountainColor.Create;
  FParenMark       := TEditorMark.Create;
  FCurrentLine     := TEditorMark.Create;
  FDigitLine       := TEditorMark.Create;
  FImageLine       := TEditorMark.Create;
  FImg0Line        := TEditorMark.Create;
  FImg1Line        := TEditorMark.Create;
  FImg2Line        := TEditorMark.Create;
  FImg3Line        := TEditorMark.Create;
  FImg4Line        := TEditorMark.Create;
  FImg5Line        := TEditorMark.Create;
  FEvenLine        := TEditorMark.Create;
  FDBSpaceMark.OnChange := ChangedProc;
  FSpaceMark.OnChange   := ChangedProc;
  FTabMark.OnChange     := ChangedProc;
  FFindMark.OnChange    := ChangedProc;
  FHit.OnChange         := ChangedProc;
  FParenMark.OnChange   := ChangedProc;
  FCurrentLine.OnChange := ChangedProc;
  FDigitLine.OnChange   := ChangedProc;
  FImageLine.OnChange   := ChangedProc;
  FImg0Line.OnChange    := ChangedProc;
  FImg1Line.OnChange    := ChangedProc;
  FImg2Line.OnChange    := ChangedProc;
  FImg3Line.OnChange    := ChangedProc;
  FImg4Line.OnChange    := ChangedProc;
  FImg5Line.OnChange    := ChangedProc;
  FEvenLine.OnChange    := ChangedProc;
end;


destructor TEditorExMarks.Destroy;
begin
  FDBSpaceMark.Free;
  FSpaceMark.Free;
  FTabMark.Free;
  FFindMark.Free;
  FHit.Free;
  FParenMark.Free;
  FCurrentLine.Free;
  FDigitLine.Free;
  FImageLine.Free;
  FImg0Line.Free;
  FImg1Line.Free;
  FImg2Line.Free;
  FImg3Line.Free;
  FImg4Line.Free;
  FImg5Line.Free;
  FEvenLine.Free;
  inherited Destroy;
end;


procedure TEditorExMarks.Assign(Source: TPersistent);
begin
  if Source is TEditorExMarks then
  begin
    BeginUpdate;
    try
      FDBSpaceMark.Assign(TEditorExMarks(Source).FDBSpaceMark);
      FSpaceMark.Assign(TEditorExMarks(Source).FSpaceMark);
      FTabMark.Assign(TEditorExMarks(Source).FTabMark);
      FFindMark.Assign(TEditorExMarks(Source).FFindMark);
      FHit.Assign(TEditorExMarks(Source).FHit);
      FParenMark.Assign(TEditorExMarks(Source).FParenMark);
      FCurrentLine.Assign(TEditorExMarks(Source).FCurrentLine);
      FDigitLine.Assign(TEditorExMarks(Source).FDigitLine);
      FImageLine.Assign(TEditorExMarks(Source).FImageLine);
      FImg0Line.Assign(TEditorExMarks(Source).FImg0Line);
      FImg1Line.Assign(TEditorExMarks(Source).FImg1Line);
      FImg2Line.Assign(TEditorExMarks(Source).FImg2Line);
      FImg3Line.Assign(TEditorExMarks(Source).FImg3Line);
      FImg4Line.Assign(TEditorExMarks(Source).FImg4Line);
      FImg5Line.Assign(TEditorExMarks(Source).FImg5Line);
      FEvenLine.Assign(TEditorExMarks(Source).FEvenLine);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;


//------------------------------------------------------------------------------
procedure TVerticalLine.SetPosition(Value: Integer);
begin
  if (FPosition <> Value) and (0 <= Value) and (Value <= MaxLineCharacter) then
  begin
    FPrevPosition := FPosition;
    FPosition := Value;
    Changed(False);
  end;
end;


procedure TVerticalLine.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed(False);
  end;
end;


procedure TVerticalLine.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(False);
  end;
end;


constructor TVerticalLine.Create(Collection: TCollection);
begin
  FPosition := 0;
  FColor    := clBlack;
  FVisible  := True;
  inherited Create(Collection);
end;


procedure TVerticalLine.Assign(Source: TPersistent);
begin
  if Source is TVerticalLine then
  begin
    Position := TVerticalLine(Source).Position;
    Color    := TVerticalLine(Source).Color;
    Visible  := TVerticalLine(Source).Visible;
  end
  else
    inherited Assign(Source);
end;


//------------------------------------------------------------------------------
function TVerticalLines.GetItem(Index: Integer): TVerticalLine;
begin
  Result := TVerticalLine(inherited GetItem(Index));
end;


procedure TVerticalLines.SetItem(Index: Integer; Value: TVerticalLine);
begin
  inherited SetItem(Index, Value);
end;


function TVerticalLines.GetOwner: TPersistent;
begin
  Result := FOwner;
end;


procedure TVerticalLines.Update(Item: TCollectionItem);
begin
  if FOwner is TEditorEx then
    TEditorEx(FOwner).Repaint;
end;


constructor TVerticalLines.Create(AOwner: TPersistent);
begin
  inherited Create(TVerticalLine);
  FOwner := AOwner;
end;


function TVerticalLines.Add: TVerticalLine;
begin
  Result := TVerticalLine(inherited Add);
end;


procedure TVerticalLines.Show;
var
  I :Integer;
begin
  I := 0;
  BeginUpdate;
  try
    while I < Count do
    begin
      Items[I].Visible := True;
      Inc(I);
    end;
  finally
    EndUpdate;
  end;
end;


procedure TVerticalLines.Hide;
var
  I :Integer;
begin
  I := 0;
  BeginUpdate;
  try
    while I < Count do
    begin
      Items[I].Visible := False;
      Inc(I);
    end;
  finally
    EndUpdate;
  end;
end;


//------------------------------------------------------------------------------
procedure TEditorEx.SetExMarks(Value: TEditorExMarks);
begin
  FExMarks.Assign(Value);
end;


procedure TEditorEx.SetFindString(const S: string);
begin
  if FFindString <> S then
  begin
    FFindString := S;
    if FExMarks.FindMark.Visible then
      Refresh;
  end;
end;


procedure TEditorEx.SetFindLineFeedCount(const Value: Integer);
begin
  if Value > 0 then
  begin
    FFindLineFeedCount := Value;
  end;
end;


procedure TEditorEx.SetExSearchOptions(Value: TExSearchOptions);
begin
  if FExSearchOptions <> Value then
  begin
    FExSearchOptions := Value;
    if FExMarks.FindMark.Visible then
      Refresh;
  end;
end;


procedure TEditorEx.SetVerticalLines(Value: TVerticalLines);
begin
  FVerticalLines.Assign(Value);
end;


procedure TEditorEx.ClearSearchInfo;
var
  I: Integer;
begin
  for I := FSearchInfoList.Count - 1 downto 0 do
  begin
    PSearchInfo(FSearchInfoList[I]).MatchList.Free;
    Dispose(PSearchInfo(FSearchInfoList[I]));
    FSearchInfoList.Delete(I);
  end;
end;


function TEditorEx.SetSearchInfoList(const ARow: Integer): Integer;
// 1行文字列中の検索文字列の開始位置と長さと文字をSearchInfoListに格納する。
// ヒットした文字列の長さが0となる場合はヒットしてないようにする。
// 改行を含む正規表現検索は対象外とする。
var
  Line, FindStr, Msg: string;
  IsWholeWordOption: Boolean;
  I, R: Integer;
  Pattern, Start, Range, Str, Str_End: PChar;
  Regexp: OnigRegex;
  ErrInfo: OnigErrorInfo;
  Region: POnigRegion;
  Sp, Sq: PIntegerArray;
  Info: PSearchInfo;
  Option: OnigOptionType;
  Syntax: POnigSyntaxType;
begin
  Result := 0;
  if FOnigEnabled and (FFindString <> '') and not IsFindLinefeed then
  begin
    SetLength(Msg, ONIG_MAX_ERROR_MESSAGE_LEN);
    ClearSearchInfo;

    if soMatchCase in FExSearchOptions then
      Option := ONIG_OPTION_FIND_NOT_EMPTY
    else
      Option := ONIG_OPTION_IGNORECASE or ONIG_OPTION_FIND_NOT_EMPTY;

    if soRegexp in FExSearchOptions then
      Syntax := @ONIG_SYNTAX_RUBY
    else
      Syntax := @ONIG_SYNTAX_ASIS;

    if soEscSeq in FExSearchOptions then
      FindStr := EscSeqToString(FFindString)
    else
      FindStr := FFindString;

    IsWholeWordOption := soWholeWord in FExSearchOptions;

    Pattern := PChar(FindStr);

    R := onig_new(@Regexp,
                  POnigUChar(Pattern),
                  POnigUChar(StrEnd(Pattern)),
                  Option,
                  @ONIG_ENCODING_SJIS,
                  Syntax,
                  @ErrInfo);
    if R <> ONIG_NORMAL then
    begin
      onig_error_code_to_str(POnigUChar(Msg), R, @ErrInfo);
      onig_end;
    end
    else
    begin
      Line := LineString(ARow);

      Region := onig_region_new;
      Str := PChar(Line);
      Str_End := StrEnd(Str);
      Start := Str;
      Range := Str_End;
      R := onig_search(Regexp,
                       POnigUChar(Str),
                       POnigUChar(Str_End),
                       POnigUChar(Start),
                       POnigUChar(Range),
                       Region,
                       ONIG_OPTION_NONE);
      if R >= 0 then
      begin
        while R >= 0 do
        begin
          Sp := PIntegerArray(Region.match_beg);
          Sq := PIntegerArray(Region.match_end);

          if not IsWholeWordOption or
             IsWholeWordOption and IsWholeWord(Str, Sp[0] + 1, Sq[0] - Sp[0]) then
          begin
            New(Info);
            Info^.Start     := Sp[0] + 1;
            Info^.Len       := Sq[0] - Sp[0];
            Info^.MatchList := TStringList.Create;
            for I := 0 to Region.num_regs - 1 do
            begin
              if Sq[I] - Sp[I] > 0 then
                Info^.MatchList.Add(Copy(Str, Sp[I] + 1, Sq[I] - Sp[I]));
            end;
            FSearchInfoList.Add(Info);
          end;

          Start := Str + Region.match_end^;
          R := onig_search(Regexp,
                           POnigUChar(Str),
                           POnigUChar(Str_End),
                           POnigUChar(Start),
                           POnigUChar(Range),
                           Region,
                           ONIG_OPTION_NONE);
        end;
      end
      else
        onig_error_code_to_str(POnigUChar(Msg), R, @ErrInfo);

      onig_region_free(Region, 1);
      onig_free(Regexp);
      onig_end;
      Result :=FSearchInfoList.Count;
    end;
  end;
end;


function TEditorEx.SetParenInfo(ARow, Index: Integer): Boolean;
// ARow、Index(1ベース)位置の括弧とその括弧に対応する括弧を設定する。
// タブ文字展開前で処理するため、ColではなくIndexとしている。
// 括弧でなかったり対応する括弧が無い場合はFalseを返す。
const
  LPAREN = '(<[{‘“（「『【＜≪';
  RPAREN = ')>]}’”）」』】＞≫';
var
  S, T, P, C: string;
  ByteSize, Stack, LPos, RPos, I, R: Integer;
begin
  Result := False;
  FLeftParenInfo.Paren  := '';
  FRightParenInfo.Paren := '';
  if Index <= 0 then
    Index := 1;

  // (ARow, Index)位置の一文字を取得(T)
  S := ListString[ARow];
  // ByteTypeは０ベース
  if ByteType(S, Index) = mbSingleByte then
    ByteSize := 1
  else
  begin
    // Index位置の文字が2バイト文字の2番目の場合はIndexを1つずらす
    if ByteType(S, Index) = mbTrailByte then
      Dec(Index);
    ByteSize := 2;
  end;
  T:= Copy(S, Index, ByteSize);

  // Tが左括弧なのか右括弧なのかを取得
  LPos := AnsiPos(T, LPAREN);
  RPos := AnsiPos(T, RPAREN);

  // 左括弧の場合は右括弧を探す
  if LPos > 0 then
  begin
    // 左括弧の情報を格納
    FLeftParenInfo.Row   := ARow;
    FLeftParenInfo.Index := Index;
    FLeftParenInfo.Paren := T;
    // 左括弧(T)に対応する右括弧(P)
    P := Copy(RPAREN, LPos, ByteSize);
    // 内包する括弧はスタックに積み上げる
    // Stackが0になった時が対応する括弧が見つかった時
    Stack := 0;
    for R := ARow to ListCount - 1 do
    begin
      S := ListString[R];
      for I := Index to Length(S) do
      begin
        // Index位置の文字が2バイト文字の2番目の場合は次
        if ByteType(S, I) = mbTrailByte then
          Continue;
        C := Copy(S, I, ByteSize);
        if T = C then
          Inc(Stack);
        if P = C then
          Dec(Stack);
        if Stack = 0 then
        begin
          FRightParenInfo.Row   := R;
          FRightParenInfo.Index := I;
          FRightParenInfo.Paren := P;
          Result := True;
          Exit;
        end;
      end;
      Index := 1;
    end;
  end;

  // 右括弧の場合は左括弧を探す
  if RPos > 0 then
  begin
    // 右括弧の情報を格納
    FRightParenInfo.Row   := ARow;
    FRightParenInfo.Index := Index;
    FRightParenInfo.Paren := T;
    // 右括弧(T)に対応する左括弧(P)
    P := Copy(LPAREN, RPos, ByteSize);
    // 内包する括弧はスタックに積み上げる
    // Stackが0になった時が対応する括弧が見つかった時
    Stack := 0;
    S := ListString[ARow];
    for R := ARow downto 0 do
    begin
      for I := Index downto 1 do
      begin
        // Index位置の文字が2バイト文字の2番目の場合は次
        if ByteType(S, I) = mbTrailByte then
          Continue;
        C := Copy(S, I, ByteSize);
        if T = C then
          Inc(Stack);
        if P = C then
          Dec(Stack);
        if Stack = 0 then
        begin
          FLeftParenInfo.Row   := R;
          FLeftParenInfo.Index := I;
          FLeftParenInfo.Paren := P;
          Result := True;
          Exit;
        end;
      end;
      S := ListString[R - 1];
      Index := Length(S);
    end;
  end;
end;


//------------------------------------------------------------------------------
procedure TEditorEx.DoCaretMoved;
// カレント行および括弧の再描画をする。
var
  Index: Integer;

  // 括弧のある行を再描画
  procedure InvalidateParen(L, R: Integer);
  begin
    InvalidateLine(L);
    if L <> R then
      InvalidateLine(R);
  end;
begin
  inherited DoCaretMoved;

  if FExMarks.CurrentLine.Visible and (FLastLine <> Row) then
  begin
    InvalidateLine(FLastLine);
    InvalidateLine(Row);
    FLastLine := Row;
  end;

  if FExMarks.ParenMark.Visible then
  begin
    // 前回の括弧の行を再描画しておく
    if FParen then
      InvalidateParen(FLeftParenInfo.Row, FRightParenInfo.Row);
    // 今回の括弧
    Index  := ColToListChar(Row, Col) + 1;
    FParen := SetParenInfo(Row, Index);
    // キャレット位置が括弧で無い場合、一つ手前も調べる
    if not FParen then
      FParen := SetParenInfo(Row, Index - 1);
    // 今回の括弧の行を再描画する
    if FParen then
      InvalidateParen(FLeftParenInfo.Row, FRightParenInfo.Row);
    // 行をまたぐような入力があった場合、Row,Colの順で2回DoCaretMovedが
    // 呼ばれるため、2回目だけ表示している全行描画する。
    if FChanged then
    begin
      Inc(FCaretMoveCount);
      if FCaretMoveCount = 2 then
      begin
        InvalidateRow(TopRow, TopRow + RowCount);
        FChanged := False;
      end;
    end;
  end;
end;


procedure TEditorEx.DoChange;
begin
  inherited DoChange;
  FChanged := True;
  FCaretMoveCount := 0;
end;


procedure TEditorEx.DoDrawLine(
  ARect: TRect; X, Y: Integer; LineStr: string; Index: Integer; SelectedArea: Boolean);
// 通常の文字列やマークはPaintLine/PaintLineSelectedで描画するため、
// ここでは拡張したマークの描画をおこなう。
var
  DM, SM, TM, FM, PM, CLM, DLM, ELM: Boolean;
  ILM, I0M, I1M, I2M, I3M, I4M, I5M: Boolean;
  S, FindStr: string;
  CW, LMSW, LPos, RPos, I, Xp, Xq, LC, RC, Count, FindLC, FindRC, L: Integer;
  Info: PSearchInfo;
  AColor: TColor;

  // 描画位置の計算(1ベース)
  function DrawPos(I: Integer): Integer;
  begin
    Result := ExpandTabLength(Copy(S, 1, I - 1)) * CW + LMSW;
  end;
  // 描画可能領域かどうかの判定
  function IsDrawArea(Xp: Integer): Boolean;
  begin
    Result := (Xp >= LPos) and (Xp < RPos);
  end;
  // 偶数行を0ベースとするかの判定
  function IsEvenLine: Boolean;
  var
    Even, Zero: Boolean;
  begin
    Even := (Index mod 2) = 0;
    Zero := Leftbar.ZeroBase;
    Result := (Even and Zero) or (not Even and not Zero);
  end;

begin
  inherited DoDrawLine(ARect, X, Y, LineStr, Index, SelectedArea);
  DrawVerticalLines;
  if not FExMarks.Indicated then
    Exit;

  DM  := FExMarks.FDBSpaceMark.Visible;
  SM  := FExMarks.FSpaceMark.Visible;
  TM  := FExMarks.FTabMark.Visible;
  FM  := FExMarks.FFindMark.Visible;
  PM  := FExMarks.FParenMark.Visible;
  CLM := FExMarks.FCurrentLine.Visible;
  DLM := FExMarks.FDigitLine.Visible;
  ILM := FExMarks.FImageLine.Visible;
  I0M := FExMarks.FImg0Line.Visible;
  I1M := FExMarks.FImg1Line.Visible;
  I2M := FExMarks.FImg2Line.Visible;
  I3M := FExMarks.FImg3Line.Visible;
  I4M := FExMarks.FImg4Line.Visible;
  I5M := FExMarks.FImg5Line.Visible;
  ELM := FExMarks.FEvenLine.Visible;

  S    := ListStr(Index);
  CW   := ColWidth;
  LMSW := LeftMargin - LeftScrollWidth;
  LPos := ARect.Left;
  RPos := Min(ARect.Right, MaxLineCharacter * CW + LMSW);
  if (CLM or DLM or ILM or I0M or I1M or I2M or I3M or I4M or I5M or ELM) and  not SelectedArea then
  begin
    AColor := clNone;
    if CLM and (Index = Row) then AColor := FExMarks.FCurrentLine.Color
    else if DLM and (ListRowMarks[Index] * [rm0..rm9] <> []) then
      AColor := FExMarks.FDigitLine.Color
    else if I0M and (rm10 in ListRowMarks[Index]) then
      AColor := FExMarks.FImg0Line.Color
    else if I1M and (rm11 in ListRowMarks[Index]) then
      AColor := FExMarks.FImg1Line.Color
    else if I2M and (rm12 in ListRowMarks[Index]) then
      AColor := FExMarks.FImg2Line.Color
    else if I3M and (rm13 in ListRowMarks[Index]) then
      AColor := FExMarks.FImg3Line.Color
    else if I4M and (rm14 in ListRowMarks[Index]) then
      AColor := FExMarks.FImg4Line.Color
    else if I5M and (rm15 in ListRowMarks[Index]) then
      AColor := FExMarks.FImg5Line.Color
    else if ILM and (ListRowMarks[Index] * [rm10..rm15] <> []) then
      AColor := FExMarks.FImageLine.Color
    else if ELM and IsEvenLine then
      AColor := FExMarks.FEvenLine.Color;
    if AColor <> clNone then
      DrawLineMark(ARect, X, Y, LineStr, Index, AColor);
  end;

  if FM then
  begin
    // タブ文字展開前
    //       |1234567890|
    //       +----------+
    //       |*.........|*
    //       +----------+
    //        LC         RC
    //       +----------+
    // 1 ooo |..........|
    // 2   oo|oo........|
    // 3     |...oooo...|
    // 4     |........oo|oo
    // 5    o|oooooooooo|o
    // 6     |..........| ooo
    // 7     |..........|
    //       +----------+
    // パターン2,3,4,5の場合描画する
    //       +----------+
    //       |...oooo...|
    //       |...*...*..|
    //       |...FLC.FRC|
    //       +----------+
    //
    // 描画行領域(１ベース)
    LC := ColToChar(Index, 0) + 1;
    RC := LC + Length(S);
    // 描画行を含む１行文字列の検索情報を設定
    try
      Count := SetSearchInfoList(Index);
      for I := 0 to Count - 1 do
      begin
        Info := FSearchInfoList.Items[I];
        FindLC := Info^.Start;
        FindRC := Info^.Start + Info^.Len;
        // パターン1,6は除く(7は最初から無い)
        if (FindRC <= LC) or (FindLC >= RC) then
          Continue;
        // パターン2,5
        if (FindLC < LC) then
          FindLC := LC;
        // パターン4,5
        if (FindRC > RC) then
          FindRC := RC;
        // 残ったのはパターン3
        Xp := DrawPos(FindLC - LC + 1);
        Xq := DrawPos(FindRC - LC + 1);
        if (Xp < LPos) and (Xq >= LPos) then
          Xp := LPos;
        if (Xp <= RPos) and (Xq > RPos) then
          Xq := RPos;
        if (Xp >= LPos) and (Xq <= RPos) then
        begin
          if not SelectedArea then
          begin
            // タブ文字展開後の描画位置から検索文字列を切り出す
            // 左端 := (Xp - LMSW) div CW + 1;
            // 右端 := (Xq - LMSW) div CW + 1;
            // 文字数 := 右端 - 左端 = (Xq - Xp) div CW;
            // 描画する文字列
            L := (Xp - LMSW) div CW + 1;
            if ByteType(LineStr, L) = mbTrailByte then
            begin
              FindStr := Copy(LineStr, L - 1, (Xq - Xp) div CW + 1);
              DrawFindString(Rect(Xp, Y, Xq, Y + FontHeight), Xp - CW, FindStr);
            end
            else
            begin
              FindStr := Copy(LineStr, L, (Xq - Xp) div CW);
              DrawFindString(Rect(Xp, Y, Xq - 1, Y + FontHeight), Xp, FindStr);
            end;
          end;
          DrawFindMark(Xp, Xq, Y);
        end;
      end;
    except
      //on ERegExpParser do Exit;
    end;
  end;
  // 描画行を一バイトずつ拾ってExMarkの場合は描画する。
  for I := 1 to Length(S) do
  begin
    // 全角空白マーク
    if  DM and (S[I] = #$81) and (S[I+1] = #$40) then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) then
        DrawDBSpaceMark(Xp, Y, True)
      else
        // 全角空白の第2バイト目が描画領域にかかっている場合
        if IsDrawArea(Xp + CW) then
          DrawDBSpaceMark(Xp, Y, False);
      Continue;
    end;
    // 半角空白マーク
    if SM and (S[I] = #$20) then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) then
        DrawSpaceMark(Xp, Y);
      Continue;
    end;
    // タブマーク
    if TM and (S[I] = #09) then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) then
        DrawTabMark(Xp, Y);
      Continue;
    end;
    // 括弧マーク
    if PM and FParen then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) and FParen then
      begin
        if (Index = FLeftParenInfo.Row) and (I = FLeftParenInfo.Index) then
          DrawParenMark(Xp, Y, FLeftParenInfo.Paren);
        if (Index = FRightParenInfo.Row) and (I = FRightParenInfo.Index) then
          DrawParenMark(Xp, Y, FRightParenInfo.Paren);
      end;
    end;
  end;
end;


procedure TEditorEx.DoDropFiles(Drop: HDrop; KeyState: Longint; Point: TPoint);
begin
  HandleToFileNames(Drop, FDropFileNames);
  inherited DoDropFiles(Drop, KeyState, Point);
end;


procedure TEditorEx.DoTopColChange;
begin
  InvalidateRow(TopRow, TopRow + RowCount);
  inherited DoTopColChange;
end;


procedure TEditorEx.DrawDBSpaceMark(X, Y: Integer; IsLeadByte: Boolean);
var
  CW, FH: Integer;
  R: TRect;
begin
  if Showing then
  begin
    CW := ColWidth;
    FH := FontHeight;
    with Canvas do
    begin
      CaretBeginUpdate;
      try
        if IsLeadByte then
        begin
          Brush.Style := bsSolid;
          Brush.Color := FExMarks.FDBSpaceMark.Color;
          R := Rect(X, Y + 1, X + CW * 2 - 1, Y + FH - 2);
          FrameRect(R);
        end
        else
        begin
          Pen.Style := psSolid;
          Pen.Width := 1;
          Pen.Color := FExMarks.FDBSpaceMark.Color;
          MoveTo(X + CW, Y + 1);
          LineTo(X + CW * 2 - 2, Y + 1);
          LineTo(X + CW * 2 - 2, Y + FH - 3);
          LineTo(X + CW - 1, Y + FH - 3);
        end;
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;


procedure TEditorEx.DrawSpaceMark(X, Y: Integer);
var
  R: TRect;
begin
  if Showing then
  begin
    R := Rect(X, Y + 1, X + ColWidth - 1, Y + FontHeight - 2);
    with Canvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := FExMarks.FSpaceMark.Color;
      CaretBeginUpdate;
      try
        FrameRect(R);
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;


procedure TEditorEx.DrawTabMark(X, Y: Integer);
var
  I, J, K: Integer;
begin
  if Showing then
  begin
    Y := Y + FontHeight div 2;
    I := Max(1, FontHeight div 8);
    J := X + ColWidth - 1;
    K := Max(I, 3);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      Pen.Color := FExMarks.FTabMark.Color;
      CaretBeginUpdate;
      try
        MoveTo(X + 1, Y);
        LineTo(J, Y);
        LineTo(J - K, Y - K);
        MoveTo(J, Y);
        LineTo(J - K, Y + K);
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;


procedure TEditorEx.DrawFindMark(Xp, Xq, Y: Integer);
begin
  if Showing then
  begin
    Y := Y + FontHeight - 1;
    with Canvas do
    begin
      CaretBeginUpdate;
      try
        Pen.Width := 1;
        Pen.Style := psSolid;
        Pen.Color := FExMarks.FFindMark.Color;
        MoveTo(Xp, Y);
        LineTo(Xq - 1, Y);
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;


procedure TEditorEx.DrawFindString(ARect: TRect; X: Integer; S: string);
begin
  if Showing then
  begin
    with Canvas do
    begin
      CaretBeginUpdate;
      try
        if FExMarks.FHit.Color = clNone then
        begin
          Font.Style  := Self.FExMarks.FHit.Style;
          Font.Color  := Self.FExMarks.FHit.Color;
        end
        else
        begin
          Font.Style  := FExMarks.FHit.Style;
          Font.Color  := FExMarks.FHit.Color;
        end;
        Brush.Style := bsSolid;
        if FExMarks.FHit.BkColor = clNone then
          Brush.Color := Color
        else
          Brush.Color := FExMarks.FHit.BkColor;
        DrawTextRect(ARect, X, ARect.Top, S, ETO_CLIPPED);
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;


procedure TEditorEx.DrawParenMark(X, Y: Integer; S: string);
var
  R: TRect;
begin
  if Showing then
  begin
    R := Rect(X, Y, X + ColWidth * Length(S), Y + FontHeight);
    with Canvas do
    begin
      Font.Style  := [fsBold];
      Font.Color  := clWhite xor FExMarks.FParenMark.Color;
      Brush.Style := bsSolid;
      Brush.Color := FExMarks.FParenMark.Color;
      CaretBeginUpdate;
      try
        DrawTextRect(R, X, Y, S, ETO_CLIPPED);
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;


procedure TEditorEx.DrawLineMark(
  ARect: TRect; X, Y: Integer; S: string; Index: Integer; AColor: TColor);
var
  CW, LMSW, LPos, RPos, Xp, SL: Integer;
  FountainColor: TFountainColor;
  Style: TFontStyles;
  FontColor: TColor;
  Parser: TFountainParser;
begin
  if Showing then
  begin
    SL   := ExpandTabLength(ListStr(Index));
    CW   := ColWidth;
    LMSW := LeftMargin - LeftScrollWidth;
    LPos := LeftMargin;
    RPos := Min(ARect.Right, Min(X + SL * CW, MaxLineCharacter * CW + LMSW));
    CaretBeginUpdate;
    try
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := AColor;
      Canvas.FillRect(ARect);
      if S <> '' then
      begin
        Style     := Font.Style;
        FontColor := Font.Color;
        Parser    := ActiveFountain.CreateParser;
        try
          Parser.NewData(S, ListData[Index]);
          while Parser.NextToken <> toEof do
          begin
            if Parser.SourcePos >= SL then
              Break;
            FountainColor := Parser.TokenToFountainColor;
            Xp := X + Parser.SourcePos * CW;
            if (LPos <= Xp + Parser.TokenLength * CW) and (Xp <= RPos) then
            begin
              if FountainColor <> nil then
              begin
                Canvas.Font.Style := FountainColor.Style;
                if FountainColor.Color = clNone then
                  Canvas.Font.Color := FontColor
                else
                  Canvas.Font.Color := FountainColor.Color;
              end
              else
              begin
                Canvas.Font.Style := Style;
                Canvas.Font.Color := FontColor;
              end;
              ARect.Right := RPos;
              DrawTextRect(ARect, Xp, Y, Parser.TokenString, ETO_CLIPPED);
            end
            else
              if RPos < Xp then
                Break;
          end;
        finally
          Parser.Free;
        end;
      end;
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawEof(X, Y: Integer);
var
  R: TRect;
  TM, LM: Integer;
begin
  if Showing then
  begin
    TM := TopMargin;
    LM := LeftMargin;
    R  := Rect(Min(Max(LM, X), Width),
               Min(Max(TM, Y), Height),
               Min(Max(LM, X + ColWidth * 6), Width),
               Min(Max(TM, Y + FontHeight), Height));
    Canvas.Font.Assign(Font);
    if Marks.EofMark.Color = clNone then
      Canvas.Font.Color := Font.Color
    else
      Canvas.Font.Color := Marks.EofMark.Color;
    Canvas.Brush.Style := bsClear;
    CaretBeginUpdate;
    try
      DrawTextRect(R, X, Y, '[EOF]', ETO_CLIPPED);
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawUnderline(ARow: Integer);
begin
  inherited DrawUnderline(ARow);
  DrawVerticalLines;
end;


procedure TEditorEx.DrawVerticalLine(Index: Integer);
var
  IX :Integer;
begin
  if HandleAllocated then
  begin
    CaretBeginUpdate;
    try
      if FVerticalLines.Items[Index].Visible then
      begin
        with Canvas do
        begin
          Pen.Color := FVerticalLines.Items[Index].Color;
          IX := LeftMargin - LeftScrollWidth + ColWidth * FVerticalLines.Items[Index].Position;
          if IX >= LeftMargin then
          begin
            MoveTo(IX, FRulerHeight);
            LineTo(IX, Height);
          end;
        end;
      end;
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawVerticalLines;
var
  I :Integer;
begin
  I := 0;
  while I < FVerticalLines.Count do
  begin
    DrawVerticalLine(I);
    Inc(I);
  end;
end;


procedure TEditorEx.Paint;
begin
  inherited Paint;
  DrawVerticalLines;
end;


function TEditorEx.CharKind(const S: string; Index: Integer): Char;
// 文字列中の任意の位置(1ベース)の文字種
const
  // 半角区切り子
  ANKSEP = #9#10#13' !"#$%&''()=~^\|{}[]`@;+:*,<.>/?_､｡･';
  // 全角区切り子
  ZENSEP = '　、。，．・：；？！゛゜´｀¨＾￣＿〇ー―‐／＼～∥｜…‥'+
           '‘’“”（）〔〕［］｛｝〈〉《》「」『』【】＋－±×÷＝≠'+
           '＜＞≦≧∞∴♂♀°′″℃￥＄￠￡％＃＆＊＠§☆★○●◎◇◆'+
           '□■△▲▽';
var
  Code: Integer;
begin
  Result := ckSeparator;
  if (0 < Index) and (Index <= Length(S)) then
  begin
    if ByteType(S, Index) = mbSingleByte then
    begin
      if AnsiPos(S[Index], ANKSEP) = 0 then
      begin
        Code := Ord(S[Index]);
        // 半角英数字
        if (0 < Code) and (Code < $80) then
          Result := ckHAnk
        // 半角カタカナ
        else if Code in [$A1..$DF] then
          Result := ckHKatakana;
      end;
    end
    else
    begin
      if ByteType(S, Index) = mbTrailByte then
        Dec(Index);
      if AnsiPos(Copy(S, Index, 2), ZENSEP) = 0 then
      begin
        Code := Ord(S[Index]) shl 8 + Ord(S[Index + 1]);
        // 全角英数字
        if (Code >= $824F) and (Code <= $829A) then
          Result := ckZAnk
        // 全角カタカナ
        else if (Code >= $8340) and (Code <= $8396) then
          Result := ckZKatakana
        // 全角ひらがな
        else if (Code >= $829F) and (Code <= $82F1) then
          Result := ckZHiragana
        // 全角漢字
        else if Code >= $889F then
          Result := ckZKanji;
      end;
    end;
  end;
end;


function TEditorEx.ColToListChar(ARow, ACol: Integer): Integer;
// 文字インデックスの取得
// ColをRow行上の文字インデックスに変換する(０ベース)
// ColToCharのロジックからraWrappedの処理を抜いたもの。
var
  S, Attr: string;
begin
  if (ARow < 0) or (ListCount < ARow) or (ACol < 0) then
    Result := -1
  else
  begin
    S := ListString[ARow];
    Attr := StrToAttributes(S);
    if IndexChar(Attr, ACol + 1) = caDBCS2 then
      Dec(ACol);
    while IndexChar(Attr, ACol + 1) = caTabSpace do
      Dec(ACol);
    Result := Min(Length(S), ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1));
  end;
end;


function TEditorEx.GetLineFirstRow(const ARow: Integer): Integer;
begin
  Result := ARow;
  if (0 <= ARow) and (ARow <= ListCount) then
  begin
    while (Result > 0) and (ListRow[Result - 1] = raWrapped) do
      Dec(Result);
  end;
end;


function TEditorEx.GetLineLastRow(const ARow: Integer): Integer;
begin
  Result := ARow;
  if (0 <= ARow) and (ARow <= ListCount) then
  begin
    while (Result < ListCount) and (ListRow[Result] = raWrapped) do
      Inc(Result);
  end;
end;


function TEditorEx.IsFindLinefeed: Boolean;
begin
  Result := (AnsiPos('\r\n', FFindString) > 0) and (soRegexp in FExSearchOptions);
end;


function TEditorEx.FindFirst(const ARow, Index: Integer): Boolean;
// 1行文字列の中からIndexバイト目以降にある検索文字列の位置を
// FFindInfoに格納する。
// MaxLineCharacterを超えるような場合は検索不可という仕様とする。
// 検索する場合は折り返しを前提とする。
var
  Count, I: Integer;
  Info: PSearchInfo;
begin
  Result := False;
  Count  := SetSearchInfoList(ARow);
  Info   := nil;
  for I := 0 to Count - 1 do
  begin
    Info := FSearchInfoList.Items[I];
    if Info^.Start > Index then
    begin
      Result := (Info^.Start <= MaxLineCharacter) or WordWrap;
      Break;
    end;
  end;
  if Result then
  begin
    FFindInfo.MatchList.Clear;
    FFindInfo.Start := Info^.Start;
    FFindInfo.Len   := Info^.Len;
    FFindInfo.MatchList.AddStrings(Info^.MatchList);
  end;
end;



function TEditorEx.FindLast(const ARow, Index: Integer): Boolean;
// 1行文字列の中からIndexバイト目以前にある検索文字列の位置を
// FFindInfoに格納する。
// IndexがMaxLineCharacterを超える場合は折り返しを必須とする。
var
  Count, I, Last: Integer;
  Info: PSearchInfo;
begin
  Result := False;
  Count  := SetSearchInfoList(ARow);
  Info   := nil;
  if (Index > MaxLineCharacter) and not WordWrap then
    Last := MaxLineCharacter
  else
    Last := Index;
  for I := Count - 1 downto 0 do
  begin
    Info := FSearchInfoList.Items[I];
    Result := (Info^.Start <= Last);
    if Result then
      Break;
  end;
  if Result then
  begin
    FFindInfo.MatchList.Clear;
    FFindInfo.Start := Info^.Start;
    FFindInfo.Len   := Info^.Len;
    FFindInfo.MatchList.AddStrings(Info^.MatchList);
  end;
end;


function TEditorEx.GroupEscSeqToString(const S: string; Info: PSearchInfo): string;
// 検索オプションでsoRegexp、soEscSeqを指定している場合、
// 後方参照の番号指定参照(\0, \1, \2)を置換する。
var
  R: string;
  I: Integer;
begin
  R := S;
  if (soRegexp in FExSearchOptions) and (soEscSeq in FExSearchOptions) then
  begin
    for I := Info^.MatchList.Count - 1 downto 0 do
      R := StringReplace(R, '\' + IntToStr(I), Info^.MatchList.Strings[I], [rfReplaceAll]);
  end;
  Result := R;
end;


function TEditorEx.ReplaceLine(var RInfo: TReplaceInfo): Integer;
// 1行文字列中の検索文字列を全部置換する。
// 置換文字列に改行を含む置換の場合は折り返しにする。
var
  Info: PSearchInfo;
  T: string;
  I, Start, Len: Integer;
begin
  RInfo.Line := LineString(RInfo.Row);
  RInfo.Wrap := False;
  Result := SetSearchInfoList(RInfo.Row);
  if Result > 0 then
  begin
    Info := FSearchInfoList.Items[0];
    T := Copy(RInfo.Line, 1, Info^.Start - 1) + GroupEscSeqToString(RInfo.Str, Info);
    for I := 1 to Result - 1 do
    begin
      Start := Info^.Start + Info^.Len;
      Info  := FSearchInfoList.Items[I];
      T := T + Copy(RInfo.Line, Start, Info^.Start - Start) + GroupEscSeqToString(RInfo.Str, Info);
    end;
    Start := Info^.Start + Info^.Len;
    Len   := Length(RInfo.Line) - Start + 1;
    RInfo.Wrap := (Len < 0);
    RInfo.Line := T + Copy(RInfo.Line, Start, Len);
  end;
end;


function TEditorEx.CreateEditorExMarks: TEditorExMarks;
begin
  Result := TEditorExMarks.Create;
  Result.OnChange := ViewChanged;
end;


//------------------------------------------------------------------------------
constructor TEditorEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExMarks            := CreateEditorExMarks;
  FDropFileNames      := TStringList.Create;
  Caret.SelDragMode   := dmManual;
  FSearchInfoList     := TList.Create;
  FVerticalLines      := TVerticalLines.Create(self);
  FOnigEnabled        := OnigLoadLibrary;
  FFindInfo.MatchList := TStringList.Create;
  FFindLineFeedCount  := 5;
end;


destructor TEditorEx.Destroy;
begin
  FExMarks.Free;
  FDropFileNames.Free;
  ClearSearchInfo;
  FFindInfo.MatchList.Free;
  FSearchInfoList.Free;
  FVerticalLines.Free;
  if FOnigEnabled then
  begin
    onig_end;
    OnigFreeLibrary;
  end;
  inherited Destroy;
end;


function TEditorEx.LineString(const ARow: Integer): string;
// 1行文字列の取得。
// WordWrap = True の場合、Lines.Strings[RowToLines(Index)]よりも高速。
// WordWrapされている場合は１行文字列の開始行まで遡りながら連結し、
// その後１行文字列の終了行まで進めながら連結する。
//      ....       raWrapped以外
//   -1 .......... raWrapped      ] １行文字列
// ARow .......... raWrapped      ]
//   +1 .......    raWrapped以外  ]
var
  S: string;
  I: Integer;
begin
  Result := '';
  if (0 <= ARow) or (ARow <= ListCount) then
  begin
    if not WordWrap then
      Result := ListStr(ARow)
    else
    begin
      S := '';
      I := ARow - 1;
      while (I >= 0) and (ListRow[I] = raWrapped) do
      begin
        S := ListStr(I) + S;
        Dec(I);
      end;
      I := ARow;
      while ListRow[I] = raWrapped do
      begin
        S := S + ListStr(I);
        Inc(I);
      end;
      Result := S + ListStr(I);
    end;
  end;
end;


function TEditorEx.RangeString(const ARow: Integer; Range: Integer): string;
// 範囲指定して1行文字列を複数行取得する。
// Rangeは1行文字列の行数であってRowではない。
// Range = 0 .. ARow行を含む1行文字列
// LineStringとは違い、改行で終わる場合は#13#10が付く。
var
  S: string;
  I, Index, Er: Integer;
begin
  Index := ARow;
  if Range < 0 then
  begin
    Range := - Range;
    for I := 1 to Range do
      Index := GetLineFirstRow(Index) - 1;
  end;

  Er := GetLineLastRow(Index);
  for I := 0 to Range do
  begin
    S := S + LineString(Index);
    if ListRow[Er] <> raEof then
      S := S + #13#10;
    Index := Er + 1;
    Er := GetLineLastRow(Index);
  end;
  Result := S;
end;


function TEditorEx.CharKindFromCaret: Char;
begin
  Result := CharKind(LineString(Row), ColToChar(Row, Col) + 1);
end;


function TEditorEx.CharKindFromPos(const Pos: TPoint): Char;
var
  R, C: Integer;
begin
  PosToRowCol(Pos.X, Pos.Y, R, C, True);
  Result := CharKind(LineString(R), ColToChar(R, C) + 1);
end;


function TEditorEx.IsWholeWord(const S: string; const Start, Len: Integer): Boolean;
var
  First, Last, Prev, Next: Char;
begin
  Result := False;
  if (0 <= Start) or (Start <= Length(S)) then
  begin
    First := CharKind(S, Start);
    Last  := CharKind(S, Start + Len - 1);
    Prev  := CharKind(S, Start - 1);
    Next  := CharKind(S, Start + Len);
    Result := (First <> Prev) and (Last <> Next);
  end;
end;


function TEditorEx.FindNext: Boolean;
// キャレット位置以降の検索。
// ただし、HitStyle = hsCaretの場合はキャレットの末尾より後ろを検索する。
var
  ARow, Index: Integer;
begin
  if IsFindLinefeed then
    Result := FindNextLinefeed
  else
  begin
    ARow  := Row;
    Index := ColToChar(ARow, Col);
    if HitStyle = hsCaret then
      Index := Index + HitSelLength;
    Result := FindFirst(ARow, Index);
    while not Result and (ARow < ListCount) do
    begin
      ARow := GetLineLastRow(ARow) + 1;
      Result := FindFirst(ARow, 0);
    end;

    if Result then
    begin
      CleanSelection;
      ARow := GetLineFirstRow(ARow);
      SetSelIndex(ARow, FFindInfo.Start - 1);
      HitSelLength := FFindInfo.Len;
    end;
  end;
end;


function TEditorEx.FindPrev: Boolean;
// キャレット位置以前の検索。
// ただし、HitStyle = hsCaretの場合、キャレットの末尾より後ろを検索する。
var
  ARow, Index: Integer;
  Found: Boolean;
begin
  if IsFindLinefeed then
    Result := FindPrevLinefeed
  else
  begin
    Result := False;
    ARow   := Row;
    Index  := ColToChar(ARow, Col);
    Found  := FindLast(ARow, Index);
    while not Found do
    begin
      ARow := GetLineFirstRow(ARow) - 1;
      if ARow < 0 then
        Break;
      Found := FindLast(ARow, Length(LineString(ARow)) + 2);
    end;

    if Found then
    begin
      CleanSelection;
      ARow := GetLineFirstRow(ARow);
      SetSelIndex(ARow, FFindInfo.Start - 1);
      HitSelLength := FFindInfo.Len;
      if HitStyle <> hsCaret then
        SetSelIndex(ARow, FFindInfo.Start - 1);
      Result := True;
    end;
  end;
end;


function TEditorEx.FindNextLinefeed: Boolean;
// 改行を含む正規表現検索(キャレット位置以降)。
// FindLineFeedCount分の改行を含む検索が可能。
var
  FindStr, T: string;
  ARow, ACol, Index, R: Integer;
  Pattern, Str, Str_End, Start, Range: PChar;
  Regexp: OnigRegex;
  ErrInfo: OnigErrorInfo;
  Region: POnigRegion;
  Option: OnigOptionType;
begin
  Result := False;
  ClearSearchInfo;

  if IsFindLinefeed then
  begin
    if soMatchCase in FExSearchOptions then
      Option := ONIG_OPTION_FIND_NOT_EMPTY
    else
      Option := ONIG_OPTION_IGNORECASE or ONIG_OPTION_FIND_NOT_EMPTY;

    if soEscSeq in FExSearchOptions then
      FindStr := EscSeqToString(FFindString)
    else
      FindStr := FFindString;

    Pattern := PChar(FindStr);

    R := onig_new(@Regexp,
                  POnigUChar(Pattern),
                  POnigUChar(StrEnd(Pattern)),
                  Option,
                  @ONIG_ENCODING_SJIS,
                  @ONIG_SYNTAX_RUBY,
                  @ErrInfo);
    if R <> ONIG_NORMAL then
      onig_end
    else
    begin
      Region := onig_region_new;

      if SelLength > 0 then
      begin
        ARow  := SelDrawPosition.Sr;
        ACol  := SelDrawPosition.Sc;
        Index := ColToChar(ARow, ACol) + 1;
        if ByteType(RangeString(ARow, 0), Index + 1) = mbTrailByte then
          Inc(Index);
      end
      else
      begin
        ARow  := Row;
        ACol  := Col;
        Index := ColToChar(ARow, ACol);
      end;

      while ARow <= ListCount do
      begin
        T       := RangeString(ARow, FFindLineFeedCount - 1);
        Str     := PChar(T);
        Str_End := StrEnd(Str);
        Start   := Str + Index;
        Range   := Str_End;

        R := onig_search(Regexp,
                         POnigUChar(Str),
                         POnigUChar(Str_End),
                         POnigUChar(Start),
                         POnigUChar(Range),
                         Region,
                         ONIG_OPTION_NONE);
        if R >= 0 then
        begin
          CaretBeginUpdate;
          try
            SelLength := 0;
            SetRowCol(ARow, 0);
            SelStart  := SelStart - ColToChar(ARow, 0) + Region.match_beg^;
            SelLength := Region.match_end^ - Region.match_beg^;
          finally
            CaretEndUpdate;
          end;
          Break;
        end
        else
        begin
          ARow  := GetLineLastRow(ARow) + 1;
          Index := 0;
        end;
      end;

      onig_region_free(Region, 1);
      onig_free(Regexp);
      onig_end;
      Result := (R >= 0);
    end;
  end;
end;


function TEditorEx.FindPrevLinefeed: Boolean;
// 改行を含む正規表現検索(キャレット位置以前)。
// FindLineFeedCount分の改行を含む検索が可能。
var
  FindStr, T: string;
  ARow, ACol, Index, R: Integer;
  Pattern, Str, Str_End, Start, Range: PChar;
  Regexp: OnigRegex;
  ErrInfo: OnigErrorInfo;
  Region: POnigRegion;
  Option: OnigOptionType;
begin
  Result := False;
  ClearSearchInfo;

  if IsFindLinefeed then
  begin
    if soMatchCase in FExSearchOptions then
      Option := ONIG_OPTION_FIND_NOT_EMPTY
    else
      Option := ONIG_OPTION_IGNORECASE or ONIG_OPTION_FIND_NOT_EMPTY;

    if soEscSeq in FExSearchOptions then
      FindStr := EscSeqToString(FFindString)
    else
      FindStr := FFindString;

    Pattern := PChar(FindStr);

    R := onig_new(@Regexp,
                  POnigUChar(Pattern),
                  POnigUChar(StrEnd(Pattern)),
                  Option,
                  @ONIG_ENCODING_SJIS,
                  @ONIG_SYNTAX_RUBY,
                  @ErrInfo);
    if R <> ONIG_NORMAL then
      onig_end
    else
    begin
      Region := onig_region_new;

      if SelLength > 0 then
      begin
        ARow := SelDrawPosition.Sr;
        ACol := SelDrawPosition.Sc;
      end
      else
      begin
        ARow := Row;
        ACol := Col;
      end;
      Index := ColToChar(ARow, ACol) - 1;
      if Index >= 0 then
      begin
        if ByteType(RangeString(ARow, 0), Index + 1) = mbTrailByte then
          Dec(Index);
      end
      else
      begin
        Dec(ARow);
        Index := Length(RangeString(ARow, 0)) - 1;
      end;

      while ARow >= 0 do
      begin
        T       := RangeString(ARow, FFindLineFeedCount - 1);
        Str     := PChar(T);
        Str_End := StrEnd(Str);
        Start   := Str + Index;
        Range   := Str;

        R := onig_search(Regexp,
                         POnigUChar(Str),
                         POnigUChar(Str_End),
                         POnigUChar(Start),
                         POnigUChar(Range),
                         Region,
                         ONIG_OPTION_NONE);
        if R >= 0 then
        begin
          CaretBeginUpdate;
          try
            SelLength := 0;
            SetRowCol(ARow, 0);
            SelStart  := SelStart - ColToChar(ARow, 0) + Region.match_beg^;
            SelLength := Region.match_end^ - Region.match_beg^;
          finally
            CaretEndUpdate;
          end;
          Break;
        end
        else
        begin
          ARow  := GetLineFirstRow(ARow) - 1;
          Index := Length(RangeString(ARow, 0)) - 1;
        end;
      end;

      onig_region_free(Region, 1);
      onig_free(Regexp);
      onig_end;
      Result := (R >= 0);
    end;
  end;
end;


function TEditorEx.Replace(const S: string): Boolean;
// 事前にFindNext/FindPrevが実行されていること。
begin
  HitToSelected;
  Result := Selected;
  if Result then
  begin
    if soEscSeq in FExSearchOptions then
      SelText := GroupEscSeqToString(EscSeqToString(S), @FFindInfo)
    else
      SelText := S;
  end;
end;


function TEditorEx.ReplaceAll(const S: string; SpeedUp: Boolean): Integer;
// 高速置換時は別リストを使うためUndoの挙動が異なる。
// 改行を含む置換の場合は前の行に追加する。
var
  T: string;
  List: TStringList;
  ARow, Count: Integer;
  Wrapped: Boolean;
  RInfo: TReplaceInfo;
begin
  Result := 0;
  if soEscSeq in FExSearchOptions then
    T := EscSeqToString(S)
  else
    T := S;

  if SpeedUp and not IsFindLinefeed then
  begin
    ARow := 0;
    Wrapped := False;
    List := TStringList.Create;
    while ARow < ListCount do
    begin
      RInfo.Row := ARow;
      RInfo.Str := T;
      Count := ReplaceLine(RInfo);
      Inc(Result, Count);
      if Wrapped then
        List.Strings[List.Count - 1] := List.Strings[List.Count - 1] + RInfo.Line
      else
        List.Add(RInfo.Line);
      Wrapped := RInfo.Wrap;
      ARow := GetLineLastRow(ARow) + 1;
    end;
    Lines.BeginUpdate;
    try
      SelStart := 0;
      SelLength := GetTextLen;
      if (ListRow[ListCount - 1] = raEof) then
        SelText := Copy(List.Text, 1, Length(List.Text) - 2)
      else
        SelText := List.Text;
    finally
      Lines.EndUpdate;
    end;
    List.Free;
  end
  else
  begin
    Lines.BeginUpdate;
    try
      SetRowCol(0, 0);
      while FindNext do
      begin
        Inc(Result);
        HitToSelected;
        SelText := GroupEscSeqToString(T, @FFindInfo);
      end;
    finally
      Lines.EndUpdate;
    end;
  end;
end;


function TEditorEx.EscSeqToString(const S: string): string;
// エスケープシーケンスを対応するキャラクタに変換する。
// \t→#09, \r→#13, \n→#10, \\→\
var
  C, T:  string;
  Index: Integer;
begin
  C := '';
  T := '';
  Index := 1;
  while Index <= Length(S) do
  begin
    if ByteType(S, Index) = mbSingleByte then
    begin
      if C = '' then
      begin
        if S[Index] = '\' then
          C := '\'
        else
          T := T + S[Index];
      end
      else
      begin
        if S[Index] = 't' then
          T := T + #09
        else if S[Index] = 'r' then
          T := T + #13
        else if S[Index] = 'n' then
          T := T + #10
        else if S[Index] = '\' then
          T := T + '\'
        else
          T := T + C + S[Index];
        C := '';
      end;
      Inc(Index);
    end
    else if ByteType(S, Index) = mbLeadByte then
    begin
      T := T + C + Copy(S, Index, 2);
      C := '';
      Inc(Index, 2);
    end
    else
      Inc(Index);
  end;
  if C = '\' then
    T := T + C;
  Result := T;
end;


function TEditorEx.IsRowSelected: Boolean;
begin
  Result := Selected and (SelStrPosition.Ec < 0);
end;


function TEditorEx.IsRowHit(const ARow: Integer): Boolean;
begin
  Result := SetSearchInfoList(ARow) > 0;
end;


function TEditorEx.OnigVersion: string;
begin
  Result := '';
  if FOnigEnabled then
    Result := onig_version;
end;


function TEditorEx.OnigCopyright: string;
begin
  Result := '';
  if FOnigEnabled then
    Result := onig_copyright;
end;


procedure TEditorEx.GotoParenMark;
// カーソル位置またはその直前の文字が括弧の場合、対応する括弧に移動する。
var
  Index, ARow: Integer;
  Paren: Boolean;
begin
  ARow  := Row;
  Index := ColToListChar(ARow, Col) + 1;
  Paren := SetParenInfo(ARow, Index);

  if not Paren then
  begin
    Dec(Index);
    Paren := SetParenInfo(ARow, Index);
  end;

  if Paren then
  begin
    if (ARow = FLeftParenInfo.Row) and (Index = FLeftParenInfo.Index) then
    begin
      ARow  := FRightParenInfo.Row;
      Index := FRightParenInfo.Index;
    end
    else
    begin
      if (ARow = FRightParenInfo.Row) and (Index = FRightParenInfo.Index) then
      begin
        ARow  := FLeftParenInfo.Row;
        Index := FLeftParenInfo.Index;
      end;
    end;
    SetSelIndex(ARow, Index - 1);
  end;
end;


end.
