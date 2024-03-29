{******************************************************************}
{                                                                  }
{  function SearchText                                             }
{                                                                  }
{  Start  : 1997/07/05                                             }
{  UpDate : 2001/07/25                                             }
{                                                                  }
{  Copyright  (C)  本田勝彦  <vyr01647@niftyserve.or.jp>           }
{                                                                  }
{  Delphi 1.0 CD-ROM Delphi\Demos\TextDemo\Search.Pas　を利用      }
{  TextLine: PChar と Start, Length を渡して、                     }
{  見つかった場合は先頭からのバイト数を Start に入れて             }
{  True を返す                                                     }
{                                                                  }
{******************************************************************}

unit HTSearch;

{$I heverdef.inc}

interface

uses
  SysUtils, Windows, Classes, StdCtrls, Dialogs;

const
  WordDelimiters: set of Char = [#$0..#$FF] -
    ['a'..'z','A'..'Z','1'..'9','0',#$81..#$9F,#$E0..#$FC, #$A6..#$DF];

type
  TSearchOption = (sfrDown, sfrMatchCase, sfrWholeWord,
    sfrNoMatchZenkaku, sfrReplace, sfrReplaceAll, sfrReplaceConfirm,
    sfrIncludeCRLF, sfrIncludeSpace, sfrWholeFile);
  TSearchOptions = set of TSearchOption;
  TSearchInfo = record
    Start, Length: Integer;
  end;

function SearchText( TextLine: PChar;
                     var Info: TSearchInfo;
                     const SearchString: String;
                     Options: TSearchOptions): Boolean;

type
  TStringsSearchInfo = record
    Line: Integer;
    Column: Integer;
    Length: Integer;
  end;

function SearchStrings(Strings: TStrings; var Info: TStringsSearchInfo;
  const SearchString: String; Options: TSearchOptions): Boolean;

implementation

type
  TCharMap = array[Char] of Char;
  String2 = String[2];

var
  UpperCharMap: TCharMap;
  Ch: Char; // for initialization section

const
  {$IFDEF COMP2}
  LeadBytes: set of Char = [#$81..#$9F, #$E0..#$FC];
  {$ENDIF}

  DBCSCharArray: array[Char] of String2 =
  (#$00, #$01, #$02, #$03, #$04, #$05, #$06, #$07,  // 00
   #$08, #$09, #$0A, #$0B, #$0C, #$0D, #$0E, #$0F,  // 08
   #$10, #$11, #$12, #$13, #$14, #$15, #$16, #$17,  // 10
   #$18, #$19, #$1A, #$1B, #$1C, #$1D, #$1E, #$1F,  // 18
   '　', '！', '”', '＃', '＄', '％', '＆', '’',  // 20
   '（', '）', '＊', '＋', '，', '−', '．', '／',  // 28
   '０', '１', '２', '３', '４', '５', '６', '７',  // 30
   '８', '９', '：', '；', '＜', '＝', '＞', '？',  // 38
   '＠', 'Ａ', 'Ｂ', 'Ｃ', 'Ｄ', 'Ｅ', 'Ｆ', 'Ｇ',  // 40
   'Ｈ', 'Ｉ', 'Ｊ', 'Ｋ', 'Ｌ', 'Ｍ', 'Ｎ', 'Ｏ',  // 48
   'Ｐ', 'Ｑ', 'Ｒ', 'Ｓ', 'Ｔ', 'Ｕ', 'Ｖ', 'Ｗ',  // 50
   'Ｘ', 'Ｙ', 'Ｚ', '［', '￥', '］', '＾', '＿',  // 58
   '｀', 'ａ', 'ｂ', 'ｃ', 'ｄ', 'ｅ', 'ｆ', 'ｇ',  // 60
   'ｈ', 'ｉ', 'ｊ', 'ｋ', 'ｌ', 'ｍ', 'ｎ', 'ｏ',  // 68
   'ｐ', 'ｑ', 'ｒ', 'ｓ', 'ｔ', 'ｕ', 'ｖ', 'ｗ',  // 70
   'ｘ', 'ｙ', 'ｚ', '｛', '｜', '｝', '￣', #$7F,  // 78
   #$80, #$81, #$82, #$83, #$84, #$85, #$86, #$87,  // 80
   #$88, #$89, #$8A, #$8B, #$8C, #$8D, #$8E, #$8F,  // 88
   #$90, #$91, #$92, #$93, #$94, #$95, #$96, #$97,  // 90
   #$98, #$99, #$9A, #$9B, #$9C, #$9D, #$9E, #$9F,  // 98
   #$A0, '。', '「', '」', '、', '．', 'ヲ', 'ァ',  // A0
   'ィ', 'ゥ', 'ェ', 'ォ', 'ャ', 'ュ', 'ョ', 'ッ',  // A8
   'ー', 'ア', 'イ', 'ウ', 'エ', 'オ', 'カ', 'キ',  // B0
   'ク', 'ケ', 'コ', 'サ', 'シ', 'ス', 'セ', 'ソ',  // B8
   'タ', 'チ', 'ツ', 'テ', 'ト', 'ナ', 'ニ', 'ヌ',  // C0
   'ネ', 'ノ', 'ハ', 'ヒ', 'フ', 'ヘ', 'ホ', 'マ',  // C8
   'ミ', 'ム', 'メ', 'モ', 'ヤ', 'ユ', 'ヨ', 'ラ',  // D0
   'リ', 'ル', 'レ', 'ロ', 'ワ', 'ン', '゛', '゜',  // D8
   #$E0, #$E1, #$E2, #$E3, #$E4, #$E5, #$E6, #$E7,  // E0
   #$E8, #$E9, #$EA, #$EB, #$EC, #$ED, #$EE, #$EF,  // E8
   #$F0, #$F1, #$F2, #$F3, #$F4, #$F5, #$F6, #$F7,  // F0
   #$F8, #$F9, #$FA, #$FB, #$FC, #$FD, #$FE, #$FF); // F8


(*
以下は、瑠瓏さん(KHB05271)作の HenkanJ.pas をモディファイしたもの

(1)
end else if s[1] in [#$a6..#$af,#$b1..#$df] then begin
                                        ↓
end else if s[1] in [#$a6..#$af,#$b1..#$dd] then begin

とし、'ﾞ'(#$DE), 'ﾟ'(#$DF) を記号として処理することで、゛゜に変換
されるようにした。

(2)
よって if Kana[S[1]] = 0 then の処理は削除した。

(3)
「ヴ」の処理を追加

(4)
また、if S[1] in ['0'..'9', 'A'..'Z', 'a'..'z'] then 以下の
カタカナ以外の文字処理は、上記 DBCSCharArray から取得するようにした。
*)

  Kana: array[#$A6..#$DF] of Byte =
  ($72,$21,
   $23,$25,$27,$29,$63,$65,$67,$43,
   $00,$22,$24,$26,$28,$2A,$AB,$AD, // $00 #$B0 ｰ
   $AF,$B1,$B3,$B5,$B7,$B9,$BB,$BD,
   $BF,$C1,$C4,$C6,$C8,$4A,$4B,$4C,
   $4D,$4E,$CF,$D2,$D5,$D8,$DB,$5E,
   $5F,$60,$61,$62,$64,$66,$68,$69,
   $6A,$6B,$6C,$6D,$6F,$73,$00,$00); // $00 #$DE ﾞ  #$DF ﾟ

function JisToSJis(N:WORD):WORD; register; assembler;
asm
    add  ax,0a17eh ; shr  ah,1      ; jb  @1
    cmp  al,0deh   ; sbb  al,5eh
@1: xor  ah,0e0h
end;

function WordToChar(N: Word):String;
begin
  Result := Char(Hi(N)) + Char(Lo(N))
end;

function HankToZen(S: String): String;
var
  W: Word;
begin
  Result := '';
  while Length(S) > 0 do
  begin
    if S[1] in LeadBytes then   // 全角文字
    begin
      Result := Result + Copy(S, 1, 2);
      Delete(S, 1, 2);
    end
    else                                       // 半角文字
      if S[1] in [#$A6..#$AF, #$B1..#$DD] then // ｦ..ｯ, ｱ..ﾝ
      begin
        W := $2500 + (Kana[S[1]] and $7F);
        if (Kana[S[1]] and $80) = 0 then       // ﾟﾞ が意味をなさない
        begin
          if (Length(S) > 1) and (S[1] = #$B3) and (S[2] = #$DE) then
          begin
            Result := Result + 'ヴ';           // ｳﾞ の処理
            Delete(S, 1, 2);
          end
          else
          begin
            Result := Result + DBCSCharArray[S[1]];
            Delete(S, 1, 1);
          end;
        end
        else                                    // ﾟﾞ が意味をなす
        begin
          if (Length(S) > 1) and (S[2] in [#$DE, #$DF]) then
          begin
            W := W + 1 + (Ord(S[2]) and 1);
            Delete(S, 2, 1);
          end;
          Result := Result + WordToChar(JisToSJis(W));
          Delete(S, 1, 1)
        end;
      end
      else
      begin                                     // 記号
        Result := Result + DBCSCharArray[S[1]];
        Delete(S, 1, 1);
      end;
  end;
end;

(*
2001/01/16 AnsiUpperCase にすべての全角文字を１文字ずつ渡して、
異なった文字が返される文字一覧

8281: ａ 8260: Ａ  83BF: α 839F: Α  8470: а 8440: А  EEEF: �� 8754: �T
8282: ｂ 8261: Ｂ  83C0: β 83A0: Β  8471: б 8441: Б  EEF0: �� 8755: �U
8283: ｃ 8262: Ｃ  83C1: γ 83A1: Γ  8472: в 8442: В  EEF1: �� 8756: �V
8284: ｄ 8263: Ｄ  83C2: δ 83A2: Δ  8473: г 8443: Г  EEF2: �� 8757: �W
8285: ｅ 8264: Ｅ  83C3: ε 83A3: Ε  8474: д 8444: Д  EEF3: �� 8758: �X
8286: ｆ 8265: Ｆ  83C4: ζ 83A4: Ζ  8475: е 8445: Е  EEF4: �� 8759: �Y
8287: ｇ 8266: Ｇ  83C5: η 83A5: Η  8476: ё 8446: Ё  EEF5: �� 875A: �Z
8288: ｈ 8267: Ｈ  83C6: θ 83A6: Θ  8477: ж 8447: Ж  EEF6: �� 875B: �[
8289: ｉ 8268: Ｉ  83C7: ι 83A7: Ι  8478: з 8448: З  EEF7: �� 875C: �\
828A: ｊ 8269: Ｊ  83C8: κ 83A8: Κ  8479: и 8449: И  EEF8: �� 875D: �]
828B: ｋ 826A: Ｋ  83C9: λ 83A9: Λ  847A: й 844A: Й
828C: ｌ 826B: Ｌ  83CA: μ 83AA: Μ  847B: к 844B: К
828D: ｍ 826C: Ｍ  83CB: ν 83AB: Ν  847C: л 844C: Л
828E: ｎ 826D: Ｎ  83CC: ξ 83AC: Ξ  847D: м 844D: М
828F: ｏ 826E: Ｏ  83CD: ο 83AD: Ο  847E: н 844E: Н
8290: ｐ 826F: Ｐ  83CE: π 83AE: Π
8291: ｑ 8270: Ｑ  83CF: ρ 83AF: Ρ  8480: о 844F: О
8292: ｒ 8271: Ｒ  83D0: σ 83B0: Σ  8481: п 8450: П
8293: ｓ 8272: Ｓ  83D1: τ 83B1: Τ  8482: р 8451: Р
8294: ｔ 8273: Ｔ  83D2: υ 83B2: Υ  8483: с 8452: С
8295: ｕ 8274: Ｕ  83D3: φ 83B3: Φ  8484: т 8453: Т
8296: ｖ 8275: Ｖ  83D4: χ 83B4: Χ  8485: у 8454: У
8297: ｗ 8276: Ｗ  83D5: ψ 83B5: Ψ  8486: ф 8455: Ф
8298: ｘ 8277: Ｘ  83D6: ω 83B6: Ω  8487: х 8456: Х
8299: ｙ 8278: Ｙ                     8488: ц 8457: Ц
829A: ｚ 8279: Ｚ                     8489: ч 8458: Ч
                                      848A: ш 8459: Ш
                                      848B: щ 845A: Щ
                                      848C: ъ 845B: Ъ
                                      848D: ы 845C: Ы
                                      848E: ь 845D: Ь
                                      848F: э 845E: Э
                                      8490: ю 845F: Ю
                                      8491: я 8460: Я
*)

const
  LDBAlpha2: array[#$81..#$9A] of Char =
  (#$60, #$61, #$62, #$63, #$64, #$65, #$66, #$67, #$68, #$69,
   #$6A, #$6B, #$6C, #$6D, #$6E, #$6F, #$70, #$71, #$72, #$73,
   #$74, #$75, #$76, #$77, #$78, #$79);

  LDBOmega2: array[#$BF..#$D6] of Char =
  (#$9F, #$A0, #$A1, #$A2, #$A3, #$A4, #$A5, #$A6, #$A7, #$A8,
   #$A9, #$AA, #$AB, #$AC, #$AD, #$AE, #$AF, #$B0, #$B1, #$B2,
   #$B3, #$B4, #$B5, #$B6);

  LDBRussia21: array[#$70..#$7E] of Char =
  (#$40, #$41, #$42, #$43, #$44, #$45, #$46, #$47, #$48, #$49,
   #$4A, #$4B, #$4C, #$4D, #$4E);

  LDBRussia22: array[#$80..#$91] of Char =
  (#$4F, #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57, #$58,
   #$59, #$5A, #$5B, #$5C, #$5D, #$5E, #$5F, #$60);

  LDBArabic2: array[#$EF..#$F8] of Char =
  (#$54, #$55, #$56, #$57, #$58, #$59, #$5A, #$5B, #$5C, #$5D);

function EqualWChar(Pattern, Text: PChar): Boolean;
(*
  Pattern, Text から始まる全角１文字が同じかどうかを判別する。

  ・Pattern, Text が LeadBytes かどうかの判別は行っていない。
  ・大文字小文字は区別されない。
  ・Pattern は AnsiUpperCase によって大文字化された全角文字列への
    ポインタであること。
*)
var
  P1, P2, T1, T2: Char;
begin
  Result := False;
  P1 := Pattern^;
  P2 := (Pattern + 1)^;
  T1 := Text^;
  T2 := (Text + 1)^;
  if P1 = T1 then
    if P2 = T2 then
      Result := True
    else
      case T1 of
        #$82: // ａ..ｚ
          if T2 in [#$81..#$9A] then Result := P2 = LDBAlpha2[T2];
        #$83: // α..ω
          if T2 in [#$BF..#$D6] then Result := P2 = LDBOmega2[T2];
        #$84:
          case T2 of
            #$70..#$7E: // а..н
              Result := P2 = LDBRussia21[T2];
            #$80..#$91: // о..я
              Result := P2 = LDBRussia22[T2];
          end;
      end
  else
    if (P1 = #$87) and (T1 = #$EE) and (T2 in [#$EF..#$F8]) then
      // �T.. �]
      Result := P2 = LDBArabic2[T2];
end;

function SearchBuf(  Buf: PChar;
                     var Info: TSearchInfo;
                     SearchString: String;
                     Options: TSearchOptions): PChar;
var
  SC, BufLen, I, P, C, Extend, L, CharLen: Integer;
  Direction: ShortInt;
  Pattern: String;
  S: String2;
  DBCSPattern, DBCSBuffer, MatchChar, IsDakuten: Boolean;
  AttrBuffer: PChar;

  function FindNextWordStart(var BufPtr: PChar): Boolean;
  begin
    // 一語の先頭を見ているときは移動せずに真を返す
    if (Direction = 1) and not (BufPtr^ in WordDelimiters) and
       ((BufPtr = Buf) or
        ((BufPtr > Buf) and (Buf[BufPtr - Buf - 1] in WordDelimiters))) then
    begin
      Result := True;
      Exit;
    end;

    while (SC > 0) and
          ((Direction = 1) xor (BufPtr^ in WordDelimiters)) do
    begin
      Inc(BufPtr, Direction);
      Dec(SC);
    end;
    while (SC > 0) and
          ((Direction = -1) xor (BufPtr^ in WordDelimiters)) do
    begin
      Inc(BufPtr, Direction);
      Dec(SC);
    end;
    Result := SC >= 0;
    if (Direction = -1) and (BufPtr^ in WordDelimiters) then
    begin   { back up one char, to leave ptr on first non delim }
      Dec(BufPtr, Direction);
      Inc(SC);
    end;
    if AttrBuffer[BufPtr - Buf] = '2' then
    begin
      Inc(BufPtr, Direction);
      Dec(SC);
    end;
  end;

begin
  Result := nil;
  BufLen := StrLen(Buf);
  if (Info.Start < 0) or (Info.Start > BufLen) or (Info.Length < 0) then
    Exit;
  Pattern := SearchString;
  if not (sfrMatchCase in Options) then
    Pattern := AnsiUpperCase(Pattern);
  L := Length(Pattern);
  CharLen := 0;
  if sfrNoMatchZenkaku in Options then
  begin
    Pattern := HankToZen(Pattern);
    L := Length(Pattern);
    I := 1;
    while I <= L do
    begin
      if Pattern[I] in LeadBytes then
        Inc(I);
      Inc(I);
      Inc(CharLen);
    end;
  end;

  AttrBuffer := StrAlloc(BufLen + 1);
  try
    I := 0;
    while I < BufLen do
    begin
      if Buf[I] in LeadBytes then
      begin
        Move('12', AttrBuffer[I], 2);
        Inc(I);
      end
      else
        AttrBuffer[I] := '0';
      Inc(I);
    end;

    if sfrDown in Options then
    begin
      Direction := 1;
      Inc(Info.Start, Info.Length);
      if (Info.Start < BufLen) and (AttrBuffer[Info.Start] = '2') then
        Inc(Info.Start);
      if sfrNoMatchZenkaku in Options then
        SC := BufLen - Info.Start - CharLen
      else
        SC := BufLen - Info.Start - L;
      if SC < 0 then
        Exit;
      if Info.Start + SC > BufLen then
        Exit;
    end
    else
    begin
      Direction := -1;
      if not (sfrNoMatchZenkaku in Options) then
        Dec(Info.Start, L)
      else
        while CharLen > 0 do
        begin
          Dec(Info.Start);
          // 全角２バイト目か、ｳ, ｶ..ﾄ, ﾊ..ﾎ + ﾞﾟ
          if (Info.Start > 0) and
             ((AttrBuffer[Info.Start] = '2') or
              ((Buf[Info.Start] in [#$DE..#$DF]) and
               (Buf[Info.Start - 1] in [#$B3, #$B6..#$C4, #$CA..#$CE]))) then
            Dec(Info.Start);
          Dec(CharLen);
        end;
      if (Info.Start >= 0) and (AttrBuffer[Info.Start] = '2') then
        Dec(Info.Start);
      SC := Info.Start;
    end;
    if (Info.Start < 0) or (Info.Start > BufLen) then
      Exit;
    Result := PChar(@Buf[Info.Start]);

    //  search
    while SC >= 0 do
    begin
      // SC = 0 の時
      // Direction =  1 ... 最後の一語
      // Direction = -1 ... バッファの先頭
      if (sfrWholeWord in Options) and (SC > 0) then
        if not FindNextWordStart(Result) then Break;

      I := 0; // hit counter
      C := 0; // crlf, space counter
      P := 1; // pointer to Pattern
      while True do
      begin
        DBCSPattern := Pattern[P] in LeadBytes;
        DBCSBuffer := Result[I + C] in LeadBytes;
        IsDakuten := False;

        if sfrNoMatchZenkaku in Options then // 全角・半角を区別しない
          if sfrMatchCase in Options then    // 大文字小文字を区別する
            if DBCSBuffer then
              MatchChar := (Pattern[P] = Result[I + C]) and
                           (Pattern[P + 1] = Result[I + C + 1])
            else
            begin                            // 全角に変換して判別
              // ｳ, ｶ..ﾄ, ﾊ..ﾎ + ﾞﾟ
              if (Result[I + C] in [#$B3, #$B6..#$C4, #$CA..#$CE]) and
                 (Result[I + C + 1] in [#$DE..#$DF]) then
              begin
                S := HankToZen(Result[I + C] +
                               Result[I + C + 1]);
                IsDakuten := True;
              end
              else
                S := DBCSCharArray[Result[I + C]];
              MatchChar := (Pattern[P] = S[1]) and
                           (Pattern[P + 1] = S[2]);
            end
          else                               // 大文字小文字を区別しない
            if DBCSBuffer then               // 全角同士の判別
              MatchChar := EqualWChar(@Pattern[P], Result + I + C)
            else
            begin                            // 全角に変換して比較
              // ｳ, ｶ..ﾄ, ﾊ..ﾎ + ﾞﾟ
              if (Result[I + C] in [#$B3, #$B6..#$C4, #$CA..#$CE]) and
                 (Result[I + C + 1] in [#$DE..#$DF]) then
              begin
                S := HankToZen(Result[I + C] +
                               Result[I + C + 1]);
                IsDakuten := True;
              end
              else
                S := DBCSCharArray[Result[I + C]];
              // MatchChar := EqualWChar(@Pattern[P], @S);
              if (S[1] = #$82) and           // 大文字マップで判別
                 (S[2] in [#$81..#$9A]) then // ａ..ｚ
                MatchChar := (Pattern[P] = #$82) and
                             (Pattern[P + 1] = LDBAlpha2[S[2]])
              else
                MatchChar := (Pattern[P] = S[1]) and
                             (Pattern[P + 1] = S[2]);
            end
        else                                 // 全角・半角を区別する
          if sfrMatchCase in Options then    // 大文字小文字を区別する
            if DBCSBuffer then
              MatchChar := DBCSPattern and
                           (Pattern[P] = Result[I + C]) and
                           (Pattern[P + 1] = Result[I + C + 1])
            else
              MatchChar := Pattern[P] = Result[I + C]
          else                               // 大文字小文字を区別しない
            if DBCSBuffer then
              MatchChar := EqualWChar(@Pattern[P], Result + I + C)
            else
              MatchChar := Pattern[P] = UpperCharMap[Result[I + C]];
        if not MatchChar then
        begin
          Extend := 0;
          if I > 0 then
            if (sfrIncludeCRLF in Options) and
               (Result[I + C] in [#$0D, #$0A]) then
              Extend := 1
            else
              if (sfrIncludeSpace in Options) and
                 (Result[I + C] in [#$20, #$09]) then
                Extend := 1
              else
                if (sfrIncludeSpace in Options) and
                   (Result[I + C] = #$81) and
                   (Result[I + C + 1] = #$40) then
                  Extend := 2;
          if Extend > 0 then
          begin
            Inc(C, Extend);
            Continue;
          end
          else
            Break;
        end
        else
        begin
          Inc(I, Byte(DBCSBuffer or IsDakuten) + 1);
          Inc(P, Byte(DBCSPattern) + 1);
          if P > L then
            if (not (sfrWholeWord in Options)) or
               (SC = 0) or
               (Result[I + C] in WordDelimiters) then
            begin
              Info.Length := I + C;
              Exit;
            end
            else
              Break;
        end;
      end;
      Inc(Result, Direction);
      Dec(SC);
      if AttrBuffer[Result - Buf] = '2' then
      begin
        Inc(Result, Direction);
        Dec(SC);
      end;
    end;
    Result := nil;
  finally
    StrDispose(AttrBuffer);
  end;
end;

function SearchText( TextLine: PChar;
                     var Info: TSearchInfo;
                     const SearchString: String;
                     Options: TSearchOptions): Boolean;
var
  P: PChar;
begin
  Result := False;
  if (Length(SearchString) = 0) or (StrLen(TextLine) = 0) then
    Exit;
  P := SearchBuf(TextLine, Info, SearchString, Options);
  if P <> nil then
  begin
    //  Info.Length は SearchBuf 内でセットされる
    Info.Start := P - TextLine;
    Result := True;
  end;
end;

function SearchStrings(Strings: TStrings; var Info: TStringsSearchInfo;
  const SearchString: String; Options: TSearchOptions): Boolean;
(*
  TStrings に対して検索を行う関数。
  Info.Line ..... 検索を開始する行番号（０ベース）を指定する。
  Info.Column ... 検索を開始する桁番号（０ベース）を指定する。
                  選択状態の場合は、選択領域終端を渡すこと。
  Info.Length ... 発見したときの文字列長さが格納される。

  上方向検索には対応していない。また sfrIncludeCRLF も無視される。
*)
var
  SearchInfo: TSearchInfo;
//  S: String;
  I: Integer;
begin
  Result := False;
  Options := Options + [sfrDown] - [sfrIncludeCRLF];
  SearchInfo.Length := 0;
  for I := Info.Line to Strings.Count - 1 do
  begin
    if I = Info.Line then
      SearchInfo.Start := Info.Column
    else
      SearchInfo.Start := 0;
    if SearchText(PChar(Strings[I]), SearchInfo, SearchString, Options) then
    begin
      Info.Line := I;
      Info.Column := SearchInfo.Start;
      Info.Length := SearchInfo.Length;
      Result := True;
      Break;
    end;
  end;
end;

initialization
  // 大文字テーブル
  for Ch := Low(UpperCharMap) to High(UpperCharMap) do
    UpperCharMap[Ch] := Ch;
  CharUpperBuff(PChar(@UpperCharMap), SizeOf(UpperCharMap));
end.

