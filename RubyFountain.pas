{
みずほちゃんによって開発されたRubyFountainをsakazukiがメンテナンスを
引き継いでいます。
Date: 2004.2.14
Version: 1.0

以下は本田勝彦さんによって付け加えられたコメントです。
私の手によって修正された部分があるので、
すべての内容が正しいわけではありません。
}

(*********************************************************************

RubyFountain について 2001/09/08

本田勝彦 < katsuhiko.honda@nifty.ne.jp >

このファイルは、みずほちゃん さん < mzh@portnet.ne.jp > が作成された
RubyFountain.pas に本田勝彦が加筆したものである。

FDelimitterOfPluralLinesLiteral を FLiteralDelimiter に置き換えている。

----------------------------------------------------------------------
%q, %Q, %x, %r に続く任意の１文字で囲まれた複数行に渡る文字列を
トークンとして扱えるパーサーを実現する。任意の１文字が (, {, [ の場合、
その囲みを終了させる１文字は ), }, ] とする。

LinesLiteral の文法

%%
LinesLiteral   : %startchar startdelimiter statement lastdelimiter
;
startchar      : q
               | Q
               | x
               | r
;
startdelimiter : CHAR /* #10..#255 */
;
statement      : TOKEN
               | CRLF
               | /* 空 */
;
lastdelimiter  : startdelimiter
                 /*
                   #10..#255
                   startdelimiter が (, {, [ の場合は ), }, ] に変換
                   されたものとする
                 */
;
%%

・% を認識するパーサーを作る。
・% の後に続く文字が q, Q, x の場合は toLiteralString を取得する。
・%r の場合は toLiteralRegexp を取得する。
・以後のトークンの取得は、複数行に渡って lastdelimiter を発見するまで
  行末までを上記トークンとして取得する。このトークンはタブ文字を含む
  場合があるので、IncludeTabToken メソッドの返値に含めること。（＊１）
・パースを実行する際 lastdelimiter を記憶する仕組みが必要になるが、
  Ord(lastdelimiter) をパーサーの FElementIndex に記憶させ、その値が
  10( #10 ) 以上の場合は、LinesLiteral であることにする。
  また、toLiteralString か toLiteralRegexp かどうかを判別するために、
  PrevToken を利用するので、THTMLFountainParser のように、NextToken
  を override し、FPrevToken を更新する。override された NormalTokenProc
  では、FElementIndex を判別し 10 以上の場合は PrevToken で FToken を
  更新している。
・トークンが折り返されているときは、StartToken の仕組みによって処理
  されるが、閉じた toLiteralxxxx が折り返されている場合については、
  下記の方法で処理される。

■閉じた toLiteralxxxx が折り返されている場合の処理について

  %Q[ hogehoge gerogero kkkk <
  kkkkkkk ] arere

  のような場合、１行目をパースする時には２行目のデータも結合した文字列を
  処理することで、２行目をパースする時に必要なデータを取得している。

  %Q[ を取得した時点で [ を ] に変換したものを FLiteralDelimiter
  に格納し、同時に FElementIndex をその Ord 値で更新し、以後 ] を見つける
  までポインタを進め、] を見つけた時点で、FElementIndex を０に初期化して
  いる。

  上記２行に収まる場合では、１行目をパースした時点でこれらの処理が終了
  してしまうので、２行目をパースする際に必要なデータを引き継ぐことが
  出来ない。（ ElementIndex が０になってしまっている）

  toBracket では LastTokenBracket メソッド内で、閉じた toBracket が検出
  された場合の処理が行われている。
  TRubyFounainParser では、LastTokenBracket を override して、同様の
  処理を行う。つまり、閉じた toLiteralxxxx が折り返されている時
  FLiteralDelimiter の Ord 値で FElementIndex を更新することにする。

*********************************************************************)

{
TEditorScreenStrings.UpdateBrackets は完全に整合性が取れるまで
そのプロパティを更新しているわけではないので、
一時的に DataStrings にゴミが残る場合がある。

hoge = <<hoge
dddddddddｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄ<
ｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄ<
ｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄ<
ｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄ<
ｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄｄ<
ｄｄｄｄｄ

hoge

after

のような場合に「ｄ」の続く行を3行ほど消すと、
「after」の行までの DataStrings にhogeが入ってしまう。
本来二つ目の「hoge」の後では DataStrings には
空文字でなければならない。

これは上述のように完全に整合性が取れるまで値が
更新されないからである。区切り文字の「hoge」の直後の行を
編集すれば、正常になるが、「hoge」よりも2つ後の行を
編集した場合はそれ以降のすべての行の FDataStrings に
「hoge」が入る。

今のところ実害はないが、対処は無理っぽい。
}

unit RubyFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toGlobalVar         = Char(51);
  toClassVar          = Char(52);
  toInstanceVar	      = Char(53);
  toConstant          = Char(54);
  toRubySymbol        = Char(55);
  toMethodDefine      = Char(56);
  toModuleClassDefine = Char(57);
  toStringLiteral     = Char(58);
  toStringLiteralWithEscapeSequence = Char(59);
  toRegexpLiteral     = Char(60);
  toRegexpLiteralWithEscapeSequence = Char(61);
  toHereDocument      = Char(62);
  toUserKeyWord       = Char(63);
  toNumericLiteral    = Char(64);

  RDElement                = 1;
  MethodDefineElement      = 2;
  ModuleClassDefineElement = 3;
  HereDocElement           = 4;
  HereDocWithIndentElement = 5;
  LastDelimiterMin         = 10; {#10}

  (* LastDelimiterMin よりも小さい値の Element しか扱えない仕様 *)


type
  TRubyFountainParser = class(TFountainParser)
  private
    FHereDocumentStartFlag: Integer;
    function ChangeDelimitter(const Delimitter: char): char;
  protected
    FLiteralDelimiter: char;
    FElementMethodTable: array[0..255] of TFountainParseProc;
    FPrevTokenMetodTable: array[toStringLiteral..toRegexpLiteralWithEscapeSequence] of TFountainParseProc;
    procedure InitMethodTable; override;
    procedure WrappedTokenIsReserveWord(var AToken: Char); override;
    procedure SingleQuotationProc1; virtual;
    procedure DoubleQuotationProc1; virtual;
    procedure BackQuotationProc1; virtual;
    procedure AnkProc; override;
    procedure ReserveAnkProc;
    function IncludeTabToken: TCharSet; override;
    procedure AngleBracketProc; virtual;
    function SetHereEndStr(var P: PChar): Boolean;
    function SetHereEndStrOfLiteral(var P: PChar): Boolean;
    procedure UserKeyWordProc; virtual;
    procedure SharpProc; virtual;
    procedure AtMarkProc; virtual;
    procedure DollarProc; virtual;
    procedure ColonProc; virtual;
    procedure EqualProc; virtual;
    procedure SlashProc; virtual;
    procedure OneLineSlashProc;
    procedure PercentProc; virtual;
    procedure LiteralProc; virtual;
    procedure ZeroProc; virtual;
    procedure IntegerProc; override;
    procedure HexProc; virtual;
    procedure BitProc; virtual;
    procedure OctalProc; virtual;
    procedure DecimalProc; virtual;
    procedure StringLiteralProc; virtual;
    procedure OneLineStringLiteralProc; virtual;
    procedure RegexpLiteralProc; virtual;
    procedure OneLineRegexpLiteralProc; virtual;
    procedure InstanceVarProc; virtual;
    procedure ClassVarProc; virtual;
    procedure ConstantProc; virtual;
    procedure RDProc; virtual;
    procedure HereDocumentProc; virtual;
    procedure MethodDefineProc; virtual;
    procedure ModuleClassDefineProc; virtual;
    procedure OrgNormalTokenProc; virtual;
    procedure QuestionProc; virtual;
    procedure BackSlashProc;
    function FindStrictly(const s: string; const strs: TStringList): Boolean;
    function IsReserveWord: Boolean; override;
    function IsUserkeyWord: Boolean; virtual;
    function MatchKeyWordStrictly(const S: String; InitialOnly: Boolean = False): Boolean;
    function MatchKeyWordListStrictly(const strs: TStringList): Boolean;
  public
    function NextToken: Char; override;
    procedure NormalTokenProc; override;
    function TokenToFountainColor: TFountainColor; override;
    procedure LastTokenBracket(Index: Integer; Strings: TRowAttributeStringList;
                               var Data: TRowAttributeData); override;
  end;

  TRubyFountainConfig = class(TNotifyPersistent)
  protected
    FOneLineString: Boolean;
    FOneLineRegexp: Boolean;
    procedure SetOneLineString(Value: Boolean);
    procedure SetOneLineRegexp(Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OneLineRegexp: Boolean read FOneLineRegexp write SetOneLineRegexp;
    property OneLineString: Boolean read FOneLineString write SetOneLineString;
  end;

  TRubyFountain = class(TFountain)
  private
    FConfig: TRubyFountainConfig;
    FUserKeyWordList: TStringList;
    FAnk: TFountainColor;                  // 半角文字
    FComment: TFountainColor;              // コメント部分
    FInt: TFountainColor;                  // 数値
    FStr: TFountainColor;                  // 文字列
    FSymbol: TFountainColor;               // 記号
    FGlobalVar: TFountainColor;            // 大域変数
    FInstanceVar: TFountainColor;          // インスタンス変数
    FClassVar: TFountainColor;             // クラス変数
    FConstant: TFountainColor;             // 定数
    FRubySymbol :TFountainColor;           // Symbolオブジェクトのリテラル
    FRegexp :TFountainColor;               // 正規表現のリテラル
    FDefinition :TFountainColor;           // メソッド・クラス・モジュール定義
    FUserKeyWord: TFountainColor;
    procedure SetAnk(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
    procedure SetGlobalVar(Value: TFountainColor);
    procedure SetInstanceVar(Value: TFountainColor);
    procedure SetClassVar(Value: TFountainColor);
    procedure SetConstant(Value: TFountainColor);
    procedure SetRubySymbol(Value: TFountainColor);
    procedure SetRegexp(Value: TFountainColor);
    procedure SetDefinition(Value: TFountainColor);
    procedure SetUserKeyWord(Value: TFountainColor);
    procedure SetUserKeyWordList(Value: TStringList);
  protected
    function GetParserClass: TFountainParserClass; override;
    //procedure InitBracketItems; override;
    procedure InitReserveWordList; override;
    procedure InitUserKeyWordList; virtual;
    procedure InitFileExtList; override;
    procedure CreateFountainColors; override;
    procedure NotifyEditors(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Config: TRubyFountainConfig read FConfig;
  published
    property Ank: TFountainColor read FAnk write SetAnk;
    property Comment: TFountainColor read FComment write SetComment;
    property Int: TFountainColor read FInt write SetInt;
    property Str: TFountainColor read FStr write SetStr;
    property Symbol: TFountainColor read FSymbol write SetSymbol;
    property GlobalVar: TFountainColor read FGlobalVar write SetGlobalVar;
    property InstanceVar: TFountainColor read FInstanceVar write SetInstanceVar;
    property ClassVar: TFountainColor read FClassVar write SetClassVar;
    property Constant: TFountainColor read FConstant write SetConstant;
    property RubySymbol: TFountainColor read FRubySymbol write SetRubySymbol;
    property Regexp: TFountainColor read FRegexp write SetRegexp;
    property Definition: TFountainColor read FDefinition write SetDefinition;
    property UserKeyWord: TFountainColor read FUserKeyWord write SetUserKeyWord;
    property UserKeyWordList: TStringList read FUserkeyWordList write SetUserKeyWordList;
  end;

procedure Register;

implementation

uses
  heUtils;

const
  RegexpOptionChars = ['i','m','x','o','e','s','u','n'];

// heFountain.pasでも同じ宣言をしている
const
  WordDelimiters: set of Char =
    [#$0..#$FF] - ['0'..'9', 'A'..'Z', '_', 'a'..'z'];


procedure Register;
begin
  RegisterComponents('TEditor', [TRubyFountain]);
end;


/////////////////////////
// TRubyFountainParser //
/////////////////////////
procedure TRubyFountainParser.InitMethodTable;
var
  i: integer;
begin
  inherited InitMethodTable;

  // FMethodTable
  if TRubyFountain(FFountain).Config.OneLineRegexp then
    FMethodTable['/'] := OneLineSlashProc
  else
    FMethodTable['/'] := SlashProc;
  FMethodTable['#'] := SharpProc;
  FMethodTable['$'] := DollarProc;
  FMethodTable['@'] := AtMarkProc;
  FMethodTable[':'] := ColonProc;
  FMethodTable['='] := EqualProc;
  FMethodTable['%'] := PercentProc;
  FMethodTable['"'] := DoubleQuotationProc1;
  FMethodTable[#39] := SingleQuotationProc1;
  FMethodTable['`'] := BackQuotationProc1;
  FMethodTable['<'] := AngleBracketProc;
  FMethodTable['?'] := QuestionProc;
  FMethodTable['0'] := ZeroProc;

  // FTokenMethodTable
  FTokenMethodTable[toGlobalVar] := DollarProc;
  FTokenMethodTable[toInstanceVar] := InstanceVarProc;
  FTokenMethodTable[toClassVar] := ClassVarProc;
  FTokenMethodTable[toConstant] := ConstantProc;
  FTokenMethodTable[toRubySymbol] := ColonProc;
  FTokenMethodtable[toMethodDefine] := MethodDefineProc;
  FTokenMethodtable[toModuleClassDefine] := ModuleClassDefineProc;
  if TRubyFountain(FFountain).Config.OneLineString then
  begin
    FTokenMethodtable[toStringLiteral] := OneLineStringLiteralProc;
    FTokenMethodtable[toStringLiteralWithEscapeSequence] := OneLineStringLiteralProc;
  end
  else
  begin
    FTokenMethodtable[toStringLiteral] := StringLiteralProc;
    FTokenMethodtable[toStringLiteralWithEscapeSequence] := StringLiteralProc;
  end;
  if TRubyFountain(FFountain).Config.OneLineRegexp then
  begin
    FTokenMethodtable[toRegexpLiteral] := OneLineRegexpLiteralProc;
    FTokenMethodtable[toRegexpLiteralWithEscapeSequence] := OneLineRegexpLiteralProc;
  end
  else
  begin
    FTokenMethodtable[toRegexpLiteral] := RegexpLiteralProc;
    FTokenMethodtable[toRegexpLiteralWithEscapeSequence] := RegexpLiteralProc;
  end;
  FTokenMethodtable[toHereDocument] := HereDocumentProc;
  FTokenMethodTable[toUserKeyWord] := UserKeyWordProc;

  FElementMethodTable[NormalElementIndex] := OrgNormalTokenProc;
  FElementMethodTable[RDElement] := RDProc;
  FElementMethodTable[MethodDefineElement] := MethodDefineProc;
  FElementMethodTable[ModuleClassDefineElement] := ModuleClassDefineProc;
  FElementMethodTable[HereDocElement] := HereDocumentProc;
  FElementMethodTable[HereDocWithIndentElement] := HereDocumentProc;
  for i := HereDocWithIndentElement + 1 to LastDelimiterMin - 1do
    FElementMethodTable[i] := OrgNormalTokenProc;
  for i := LastDelimiterMin to 255 do
    FElementMethodTable[i] := LiteralProc;

  if TRubyFountain(FFountain).Config.OneLineString then
  begin
    FPrevTokenMetodTable[toStringLiteral] := OneLineStringLiteralProc;
    FPrevTokenMetodTable[toStringLiteralWithEscapeSequence] := OneLineStringLiteralProc;
  end
  else
  begin
    FPrevTokenMetodTable[toStringLiteral] := StringLiteralProc;
    FPrevTokenMetodTable[toStringLiteralWithEscapeSequence] := StringLiteralProc;
  end;
  if TRubyFountain(FFountain).Config.OneLineRegexp then
  begin
    FPrevTokenMetodTable[toRegexpLiteral] := OneLineRegexpLiteralProc;
    FPrevTokenMetodTable[toRegexpLiteralWithEscapeSequence] := OneLineRegexpLiteralProc;
  end
  else
  begin
    FPrevTokenMetodTable[toRegexpLiteral] := RegexpLiteralProc;
    FPrevTokenMetodTable[toRegexpLiteralWithEscapeSequence] := RegexpLiteralProc;
  end;
end;

procedure TRubyFountainParser.SharpProc;
// '# comment'
begin
  CommenterProc;
end;

procedure TRubyFountainParser.DollarProc;
// '$global' '$_' '$:'
begin
  // 組み込み変数の一部と大域変数
  if (FP + 1)^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_' ] then
  begin
    FToken := toGlobalVar;
    inc(FP);
    while FP^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_' ] do
      Inc(FP);
  end
  // 組み込み変数の一部
  else if (FP + 1)^ in ['&', '~', '`', #39, '+', 'z', '?', '!', '@',
                        '=', '/', '\', ',', ';', '.', '<', '>', '*',
                        '$', ':', '"' ] then
    if (FP + 2)^ in [')', '=', '.', ' ', '[', #0, #10, #13] then
    begin
      FToken := toGlobalVar;
      FP := FP + 2;
    end
    else
    begin
      inc(FP);
      SymbolProc
    end
  // コマンドラインオプションに対応する組み込み変数
  else if (FP + 1)^ = '-' then
    if (FP + 2)^ in ['O', 'a', 'd', 'F', 'i', 'I', 'p', 'v', 'w'] then
    begin
      FToken := toGlobalVar;
      FP := FP + 3;
    end
    else
      SymbolProc
  // Other
  else
    SymbolProc;
end;

procedure TRubyFountainParser.AtMarkProc;
// '@'
begin
  if (FP + 1)^ = '@' then
  begin
    Inc(FP);
    ClassVarProc
  end
  else
    InstanceVarProc;
end;

procedure TRubyFountainParser.InstanceVarProc;
// '@hoge'
begin
  FToken := toInstanceVar;
  if not FIsStartToken then
    Inc(FP);
  while FP^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_' ] do
    Inc(FP);
end;

procedure TRubyFountainParser.ClassVarProc;
// '@@hoge'
begin
  FToken := toClassVar;
  if not FIsStartToken then
    Inc(FP);
  while FP^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_' ] do
    Inc(FP);
end;

procedure TRubyFountainParser.ConstantProc;
// 'Hoge'

// if not FIsStartToken then
//   Inc(FP);
// ConstantProcでは対象とする文字が文字数
// によって変わらないので、上の節は必要ない。
begin
  FToken := toConstant;
  while FP^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_' ] do
    Inc(FP);
end;

procedure TRubyFountainParser.ColonProc;
// ':symbol_obj'
// 日本語ローカル変数のSymbolオブジェクトへの対応?
begin
  // 'Kconv::toeuc' の '::' の部分
  if (FP + 1)^ = ':' then
  begin
    FToken := toSymbol;
    FP := FP + 2
  end
  // ':>' 等
  else if not( (FP + 1)^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_' ] ) then
    SymbolProc
  // Other
  else
  begin
    FToken := toRubySymbol;
    if not FIsStartToken then
      Inc(FP);
    while FP^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_', '=', '-', '+', '/', '*', '<', '>', '?', '!', '%', '&', '|', '@', '$'] do
      Inc(FP);
  end;
end;

procedure TRubyFountainParser.QuestionProc;
//sakazuki add
//?数値リテラル
//?a  文字aのコード(97)
begin
  //if (SourcePos = 0) or ((SourcePos > 0) and ((FP - 1)^ in WordDelimiters)) then
  if (SourcePos > 0) and ((FP - 1)^ in WordDelimiters - [')']) then
  begin
    FToken := toNumericLiteral;
    Inc(FP);
    if FP^ = '\' then
      BackSlashProc
    else if not (FP^ in [#0, #13, #10]) then
      Inc(FP);
  end
  else
  begin
    FToken := toAnk;
    Inc(FP);
  end;
end;

procedure TRubyFountainParser.BackSlashProc;
//?\C-a コントロール a のコード(1)
//?\M-a メタ a のコード(225)
//?\M-\C-a  メタ-コントロール a のコード(129)
begin
  Inc(FP);
  if MatchKeyWordStrictly('M-\C-', True) or
     MatchKeyWordStrictly('M-', True) or
     MatchKeyWordStrictly('C-', True) or
     (FP^ = 'c') then
    if not (FP^ in [#0, #13, #10]) then
     Inc(FP)
  else if FP^ = 'x' then
    if not (FP^ in [#0, #13, #10]) then
      Inc(FP, 3)
  else if FP^ in ['0' .. '7'] then
    if not (FP^ in [#0, #13, #10]) then
     Inc(FP, 3)
  else
    if not (FP^ in [#0, #13, #10]) then
      Inc(FP);
end;


procedure TRubyFountainParser.EqualProc;
// '='
begin
  // RD 組み込みドキュメント
  if ( SourcePos = 0 ) and
     ( FPrevRowAttribute <> raWrapped ) and
     ( MatchKeyWordStrictly('=begin') ) then
  begin
    FToken := toComment;
    FElementIndex := RDElement;
  end
  // Other
  else
    SymbolProc;
end;

procedure TRubyFountainParser.RDProc;
begin
  if ( SourcePos = 0 ) and
     ( FPrevRowAttribute <> raWrapped ) and
     ( MatchKeyWordStrictly('=end') ) then
  begin
    // '=end'の行末
    FElementIndex := NormalElementIndex;
    CommenterProc;
  end
  else
    CommenterProc;
end;

procedure TRubyFountainParser.SlashProc;
// /^hoge\n$/
begin
  if not FIsStartToken and ((FP + 1)^ in [' ', #0]) then
    SymbolProc
  else
  begin
    FElementIndex := Ord('/');
    FLiteralDelimiter := '/';
    if not FIsStartToken then
      Inc(FP);
    //RegexpLiteralProc;
    FPrevTokenMetodTable[toRegexpLiteral]
  end;
end;

procedure TRubyFountainParser.OneLineSlashProc;
begin
  FElementIndex := Ord('/');
  FLiteralDelimiter := '/';
  if not FIsStartToken then
    Inc(FP);
  FPrevTokenMetodTable[toRegexpLiteral]
end;

function TRubyFountainParser.ChangeDelimitter(const Delimitter: char): char;
begin
  case Delimitter of
    '(': Result := ')';
    '{': Result := '}';
    '[': Result := ']';
    '<': Result := '>';
  else
    Result := Delimitter;
  end;
end;

procedure TRubyFountainParser.PercentProc;
// %q(hoge)  %r[\s\w*$]
begin
  // 行末の %[qQrx] は無視される仕様
  if ((FP + 1)^ in ['q', 'Q', 'r', 'x', 'w', 'W', 's']) and ((FP + 2)^ >= #10) then
  begin
    case (FP + 1)^ of
      'q', 'Q', 'x', 'w', 'W', 's':
        begin
          FLiteralDelimiter := ChangeDelimitter( (FP + 2)^ );
          FElementIndex := Ord(FLiteralDelimiter );
          Inc(FP, 3);
          StringLiteralProc;
        end;
      //本当は、処理を分けたいところ。  
      //'w', 'W':
      //'s':
      'r':
        if not( (FP + 2)^ in ['a'..'z', 'A'..'Z', '0'..'9']) and ( (FP + 2)^ <> #0 ) then
        begin
          FLiteralDelimiter := ChangeDelimitter( (FP + 2)^ );
          FElementIndex := Ord(FLiteralDelimiter );
          Inc(FP, 3);
          RegexpLiteralProc;
          //FPrevTokenMetodTable[toRegexpLiteral];
        end
        else
          SymbolProc;
    end;
  end
  else
    //%!STRING!を処理したい場合には、ここに判定を加えて処理を追加する必要がある
    SymbolProc;
end;

procedure TRubyFountainParser.LiteralProc;
begin
  FPrevTokenMetodTable[FPrevToken];
end;


procedure TRubyFountainParser.ZeroProc;
begin
  Inc(FP);
  if (FP^ in ['x', 'X']) then
  begin
    Inc(FP);
    HexProc;
  end
  else if (FP^ in ['b', 'B']) then
  begin
    Inc(FP);
    BitProc;
  end
  else if (FP^ in ['_', 'o', 'O']) then
  begin
    Inc(FP);
    OctalProc;
  end
  else if (FP^ in ['d', 'D']) then
  begin
    Inc(FP);
    DecimalProc;
  end
  else
    IntegerProc;
end;

procedure TRubyFountainParser.IntegerProc;
begin
  FToken := toInteger;
  while FP^ in ['0'..'9'] do
    Inc(FP);
  case FP^ of
{    'e', 'E':
      begin
        FToken := toFloat;
        Inc(FP);
        case FP^ of
          '+', '-':
            begin
              Inc(FP);
              while FP^ in ['0'..'9'] do
                Inc(FP);
            end;
          '0'..'9':
            begin
              Inc(FP);
              while FP^ in ['0'..'9'] do
                Inc(FP);
            end;
        end;
      end;
}
    '.':
      begin
        FToken := toFloat;
        Inc(FP);
        if not (FP^ in ['0'..'9'{, 'e', 'E'}]) then
          Dec(FP)
        else
        case FP^ of
          '0'..'9':
            begin
              Inc(FP);
              while FP^ in ['0'..'9'] do
                Inc(FP);
              if FP^ in ['e', 'E'] then
              begin
                Inc(FP);
                case FP^ of
                  '+', '-':
                    begin
                      Inc(FP);
                      while FP^ in ['0'..'9'] do
                        Inc(FP);
                    end;
                  '0'..'9':
                    begin
                      Inc(FP);
                      while FP^ in ['0'..'9'] do
                        Inc(FP);
                    end;
                end;
              end;
            end;
{          'e', 'E':
            begin
              Inc(FP);
              case FP^ of
                '+', '-':
                  begin
                    Inc(FP);
                    while FP^ in ['0'..'9'] do
                      Inc(FP);
                  end;
                '0'..'9':
                  begin
                    Inc(FP);
                    while FP^ in ['0'..'9'] do
                      Inc(FP);
                  end;
              end;
            end;
}
        end;
      end;
  end;
end;

procedure TRubyFountainParser.HexProc;
begin
  FToken := toHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f', '_'] do
    Inc(FP);
end;

procedure TRubyFountainParser.BitProc;
begin
  FToken := toInteger;
  while FP^ in ['0', '1', '_'] do
    Inc(FP);
end;

procedure TRubyFountainParser.OctalProc;
begin
  FToken := toInteger;
  while FP^ in ['0'..'7', '_'] do
    Inc(FP);
end;

procedure TRubyFountainParser.DecimalProc;
begin
  FToken := toInteger;
  while FP^ in ['0'..'9', '_'] do
    Inc(FP);
end;

procedure TRubyFountainParser.StringLiteralProc;
var
  C: Char;
begin
  FToken := toStringLiteral;
  C := Chr(Byte(FElementIndex));

  while not (FP^ in [#0, #10, #13]) do
  begin
    // 区切り文字が出現したか?
    if FP^ = C then
    begin
      // 先頭に区切り文字があり、前行の最後にエスケープ･シーケンスがある
      if ((FP - FBuffer) = 0) and (FPrevToken = toStringLiteralWithEscapeSequence ) then
        inc(FP)
      else
        // 「'hogehoge'」のように区切り文字の直前に
        // エスケープ･シーケンスがないので、ここでトークンは終わり
        //if not( (FP - 1)^ = '\' ) then
        begin
          Inc(FP);
          FElementIndex := NormalElementIndex;
          Break;
        end
        // 区切り文字があるけど、エスケープ･シーケンスあるので、
        // トークンはまだ続く
        // 分岐でここに来ることは多分無い(case文の「\」で先にはじかれる)
        {else
          Inc(FP);}
    end
    else if FP^ = '\' then
    // エスケープシーケンスなので、2文字分進める。
    begin
      Inc(FP);
      if FP^ <> #0 then
      begin
        if FP^ in LeadBytes then
          Inc(FP);
        Inc(FP);
      end;
    end
    else
    begin
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end;
end;

procedure TRubyFountainParser.RegexpLiteralProc;
var
  C: Char;
begin
  FToken := toRegexpLiteral;
  C := Chr(Byte(FElementIndex));

  while not (FP^ in [#0, #10, #13]) do
  begin
    if FP^ = C then
    begin
      // 区切り文字があるのが行頭で、その前行末がエスケープ・シーケンスだった時
      if ( (FP - FBuffer) = 0 ) and (FPrevToken = toRegexpLiteralWithEscapeSequence) then
        Inc(FP)
      else
        begin
          Inc(FP);
          while (FP^ in RegexpOptionChars) do
            Inc(FP);
          FElementIndex := NormalElementIndex;
          Break;
        end
    end
    else if FP^ = '\' then
    begin
      Inc(FP);
      if FP^ <> #0 then
      begin
        if FP^ in LeadBytes then
          Inc(FP);
        Inc(FP);
      end;
    end
    else
    begin
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end;
end;

procedure TRubyFountainParser.OneLineStringLiteralProc;
var
  C: Char;
begin
  FToken := toStringLiteral;
  C := Chr(Byte(FElementIndex));
  while not (FP^ in [#0, #10, #13]) do
  begin
    if FP^ = C then
    begin
      if ((FP - FBuffer) = 0) and (FPrevToken = toStringLiteralWithEscapeSequence ) then
        inc(FP)
      else
        begin
          Inc(FP);
          FElementIndex := NormalElementIndex;
          Exit;
        end
    end
    else if FP^ = '\' then
    begin
      Inc(FP);
      if FP^ <> #0 then
      begin
        if FP^ in LeadBytes then
          Inc(FP);
        Inc(FP);
      end;
    end
    else
    begin
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end;
end;

procedure TRubyFountainParser.OneLineRegexpLiteralProc;
var
  C: Char;
  P: PChar;
  Indent: Integer;
begin
  FToken := toRegexpLiteral;
  C := Chr(Byte(FElementIndex));
  P := FP;
  Indent := 0;

  if C <> '/' then
  begin
    RegexpLiteralProc;
    Exit;
  end;
  while not (FP^ in [#0, #10, #13]) do
  begin
    if (FP^ = C) and (Indent = 0) then
    begin
      if ((FP - FBuffer) = 0) and (FPrevToken = toRegexpLiteralWithEscapeSequence ) then
        Inc(FP)
      else
        begin
          Inc(FP);
          while (FP^ in RegexpOptionChars) do
            Inc(FP);
          FElementIndex := NormalElementIndex;
          Exit; //Break;
        end
    end
    else if FP^ = '\' then
    begin
      Inc(FP);
      if FP^ <> #0 then
      begin
        if FP^ in LeadBytes then
          Inc(FP);
        Inc(FP);
      end;
    end
    else if FP^ in ['[', '('] then
    begin
      Inc(FP);
      Inc(Indent)
    end
    else if FP^ in [']', ')'] then
    begin
      Inc(FP);
      Dec(Indent);
      if Indent < 0 then
        Break;
    end
    else
    begin
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end;

  if ((FRowAttribute <> raWrapped) or (Indent < 0)) then
  begin
    FElementIndex := NormalElementIndex;
    FP := P;
  end;
end;

procedure TRubyFountainParser.SingleQuotationProc1;
begin
  FElementIndex := Ord(#39);
  FLiteralDelimiter := #39;
  if not FIsStartToken then
    Inc(FP);
  StringLiteralProc;
end;

procedure TRubyFountainParser.DoubleQuotationProc1;
begin
  FElementIndex := Ord('"');
  FLiteralDelimiter := '"';
  if not FIsStartToken then
    Inc(FP);
  StringLiteralProc;
end;

procedure TRubyFountainParser.BackQuotationProc1;
begin
  FElementIndex := Ord('`');
  FLiteralDelimiter := '`';
  if not FIsStartToken then
    Inc(FP);
  StringLiteralProc;
end;

procedure TRubyFountainParser.AnkProc;
// 'A'..'Z', '_', 'a'..'z', '0'..'9'
// ex. 'Ruby', 'hoge', '__send__'
begin
  // Constant, Class, Module
  // ここでやると、予約語のBEGIN, ENDも定数扱いとなる。
  //if FP^ in ['A'..'Z'] then
  //begin
  //  ConstantProc
  //end
  if (((SourcePos = 0)) or ((SourcePos > 0) and ((FP - 1)^ <> '.' ))) and
      (FP^ in  ['d', 'c', 'm']) then
  begin
    if MatchKeyWordStrictly('def') then
    begin
      FToken := toReserve;
      FElementIndex := MethodDefineElement
    end
    else if MatchKeyWordStrictly('class') then
    begin
      FToken := toReserve;
      FElementIndex := ModuleClassDefineElement
    end
    else if MatchKeyWordStrictly('module') then
    begin
      FToken := toReserve;
      FElementIndex := ModuleClassDefineElement
    end
    else
      ReserveAnkProc;
  end
  else if FP^ in ['A'..'Z'] then
  begin
    ConstantProc
  end
  else
    ReserveAnkProc;
end;

procedure TRubyFountainParser.ReserveAnkProc;
begin
  if (((SourcePos = 0)) or ((SourcePos > 0) and ((FP - 1)^ <> '.' ))) and
      MatchKeyWordListStrictly(FFountain.ReserveWordList) then
    FToken := toReserve
  else
  begin
    FToken := toAnk;
    inherited AnkProc;
  end;
end;

procedure TRubyFountainParser.MethodDefineProc;
begin
  FElementIndex := NormalElementIndex;
  FToken := toMethodDefine;
  while FP^ in ['A'..'Z', '_', 'a'..'z', '0'..'9', '=', '-', '+', '/', '*', '<', '>', '?', '!', '%', '&', '|', '$'] do
    Inc(FP);
end;

procedure TRubyFountainParser.ModuleClassDefineProc;
begin
  FElementIndex := NormalElementIndex;

  if ((FP^ = '<') and ((FP + 1)^ = '<')) then
  begin
    FToken := toModuleClassDefine;
    Inc(FP, 2);
  end;
  //SkipBlanks;
  while not (FP^ in [#0, #9, #33..#255]) do
    Inc(FP);

  if FP^ in ['A'..'Z'] then
    FToken := toModuleClassDefine
  else
  begin
    FToken := toSymbol;
    exit;
  end;

  while FP^ in ['A'..'Z', '_', 'a'..'z', '0'..'9'] do
    Inc(FP);
end;

function TRubyFountainParser.MatchKeyWordStrictly(const S: String; InitialOnly: Boolean = False): Boolean;
var
  I, L: Integer;
  P: PChar;
begin
  Result := False;
  L := Length(S);
  if L < 1 then
    Exit;
  P := FP;
  I := 1;
  while P^ = S[I] do
  begin
    if I = L then
    begin
      Inc(P);
      if InitialOnly or (P^ in WordDelimiters) then
      begin
        Result := True;
        FP := P;
      end;
      Break;
    end;
    Inc(I);
    Inc(P);
  end;
end;

function TRubyFountainParser.MatchKeyWordListStrictly(const strs: TStringList): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to strs.Count - 1 do
  begin
    if MatchKeyWordStrictly(strs[i]) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TRubyFountainParser.FindStrictly(const s: string; const strs: TStringList): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := strs.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := AnsiCompareStr(strs[I], S);
    if C < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if strs.Duplicates <> dupAccept then L := I;
      end;
    end;
  end;
end;

function TRubyFountainParser.IsReserveWord: Boolean;
begin
  Result := not FIsStartToken and
            (FElementIndex = NormalElementIndex) and
            not (FToken in [toEof, toBracket, toComment]) and
            FindStrictly(TokenString, FFountain.ReserveWordList);
end;

function TRubyFountainParser.IsUserkeyWord: Boolean;
begin
  Result := not FIsStartToken and
            (FElementIndex = NormalElementIndex) and
            not (FToken in [toEof, toBracket, toComment]) and
            FindStrictly(TokenString, TRubyFountain(FFountain).UserKeyWordList);
end;

procedure TRubyFountainParser.WrappedTokenIsReserveWord(var AToken: Char);
begin
  inherited;

  if IsUserkeyWord then
    AToken := toUserKeyWord;
end;

procedure TRubyFountainParser.UserKeyWordProc;
begin
  FMethodTable[FP^];
  FToken := toUserKeyWord;
end;


function TRubyFountainParser.NextToken: Char;
begin
  Result := inherited NextToken;
  if FToken <> toEof then
    FPrevToken := FToken;
end;

procedure TRubyFountainParser.OrgNormalTokenProc;
begin
  inherited NormalTokenProc;
end;

{*
procedure TRubyFountainParser.NormalTokenProc;
begin
  if FElementIndex >= LastDelimiterMin then
    case FPrevToken of
      toStringLiteral, toStringLiteralWithEscapeSequence:
        StringLiteralProc;
      toRegexpLiteral, toRegexpLiteralWithEscapeSequence:
        RegexpLiteralProc;
    end
  else
    case FElementIndex of
      RDElement:
        RDProc;
      MethodDefineElement:
        MethodDefineProc;
      ModuleClassDefineElement:
        ModuleClassDefineProc;
      HereDocElement, HereDocWithIndentElement:
        HereDocumentProc;
      CommentInHereDocElement:
      begin
        FElementIndex := HereDocElement;
        CommenterProc;
      end;
      CommentInHereDocWithIndentElement:
      begin
        FElementIndex := HereDocElement;
        CommenterProc;
      end
    else
      inherited NormalTokenProc;
    end;
end;
*}

procedure TRubyFountainParser.NormalTokenProc;
begin
  FElementMethodTable[FElementIndex];
end;

procedure TRubyFountainParser.LastTokenBracket(Index: Integer;
  Strings: TRowAttributeStringList; var Data: TRowAttributeData);
var
  L: Integer;
  TmpStr: String;
begin

  { ここでヒアドキュメントの終わりかどうかを判別している。
  ヒアドキュメントの最後の行が折り返されている
  場合は対処できない。
  前行が折り返されていない状態でなければ、
  ヒアドキュメントの区切り文字にはならない。}
  if ((Data.ElementIndex = HereDocElement) and
      (Data.RowAttribute = raCrlf) and
      (Data.DataStr = Strings[Index])) then
  begin
    Data.ElementIndex := NormalElementIndex;
    Data.DataStr := '';
    Exit;
  end
  else if (Data.ElementIndex = HereDocWithIndentElement) and
          (Data.RowAttribute = raCrlf) then
  begin
    if (TrimLeft(Strings[Index]) = Data.DataStr) then
    begin
      Data.ElementIndex := NormalElementIndex;
      Data.DataStr := '';
      Exit;
    end;
  end;

  { 下の方で

  Data.DataStr := FDataStr

  としているが、このままだと空白行の時にData.DataStrを次の行に持ちこめない。
  (TFountainParser.LastTokenBracketでは空白行はすぐにExitするから)
  仕方ないので、ここでTFountainParser.LastTokenBracket
  の空白行の判定を行って、FDataStrを設定する。}
  if (FElementIndex in [HereDocElement, HereDocWithIndentElement]) then
  begin
    if Trim(Strings[Index]) = '' then
      FDataStr := Data.DataStr;
  end;

  FHereDocumentStartFlag := 0;
  inherited LastTokenBracket(Index, Strings, Data);
  //なにはともあれ、前行にヒアドュキメント開始記号があれば、ElementIndexを更新する。
  if FHereDocumentStartFlag <> 0 then
  begin
    Data.ElementIndex := FHereDocumentStartFlag;
    FElementIndex := FHereDocumentStartFlag;
  end;

  { ヒアドキュメントでのみDataStrの更新する。}
  if (FElementIndex in [HereDocElement, HereDocWithIndentElement]) then
  begin
    Data.DataStr := FDataStr;
  end;

  { 文字列・正規表現リテラルが折り返されている }
  if (Data.StartToken in [toStringLiteral, toRegexpLiteral]) and
     (Strings.Rows[Index] = raWrapped) then
  begin
    { 閉じた toxxxxLiteral が折り返されている時のための処理 }
    if (Data.ElementIndex = 0) then
    begin
      // 閉じた toxxxxLiteral
      L := Length(Strings[Index]);
      if (SourcePos < L) and (L < SourcePos + TokenLength) then
        // 分割されている
        Data.ElementIndex := Ord(FLiteralDelimiter);
    end;

    { パースした行の最後にエスケープシーケンスがある時に
    専用のトークンを設定する }
    TmpStr := Strings[Index];
    L := length(TmpStr);
    if (SourcePos < L) and (L < SourcePos + TokenLength) and
      (L > 0) and (TmpStr[L] = '\') then
    begin
      case Data.StartToken of
        toStringLiteral:  Data.PrevToken := toStringLiteralWithEscapeSequence;
        toRegexpLiteral:  Data.PrevToken := toRegexpLiteralWithEscapeSequence;
      end;
    end;

  end;
end;

function TRubyFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TRubyFountain(FFountain) do
    {if IsReserveWord then
      Result := Reserve
    else }if IsUserkeyWord then
      Result := UserKeyWord
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat, toNumericLiteral:
          Result := FInt;
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toComment:
          Result := FComment;
        toReserve:
          Result := Reserve;
        toUserKeyWord:
          Result := UserKeyWord;
        toAnk:
          Result := FAnk;
        toHex:
          Result := FInt;
        toStringLiteral, toHereDocument:
          Result := FStr;
        toRegexpLiteral:
          Result := FRegexp;
        toGlobalVar:
          Result := FGlobalVar;
        toInstanceVar:
          Result := FInstanceVar;
        toClassVar:
          Result := FClassVar;
        toConstant:
          Result := FConstant;
        toRubySymbol:
          Result := FRubySymbol;
        toMethodDefine, toModuleClassDefine:
          Result := FDefinition;
      else
        Result := nil;
      end;
end;

function TRubyFountainParser.IncludeTabToken: TCharSet;
begin
  Result := [toComment, toSingleQuotation, toDoubleQuotation, toStringLiteral,
             toRegexpLiteral, toHereDocument];
end;


procedure TRubyFountainParser.AngleBracketProc;
var
  I: Integer;
  P: PChar;
begin
  if not(((FP + 1)^ = '<') and
          (not((FP + 2)^ in [#0, #10, #13, '<']))) then
    SymbolProc
  else if FPrevToken = toModuleClassDefine then
    SymbolProc
  else
  begin
    if (FP + 2)^ = '-' then
      I := 1
    else
      I := 0;
    case (FP + I + 2)^ of
      '"', '''','`':
        begin
          FLiteralDelimiter := (FP + I + 2)^;
          P := FP + I + 3;
          if not SetHereEndStrOfLiteral(P) then
          begin
            FLiteralDelimiter := #0;
            FElementIndex := NormalElementIndex;
            SymbolProc;
          end
          else
          begin
            FP := P;
            if I = 1 then
              FHereDocumentStartFlag := HereDocWithIndentElement
            else
              FHereDocumentStartFlag := HereDocElement;
            FToken := toHereDocument;
          end;
        end;
    else
      if ( (FP + I + 2)^ in ['a'..'z', 'A'..'Z', '0'..'9']) then
                 //and ( (FP + I + 3)^ <> #0 ) then
      begin
        FLiteralDelimiter := #0;
        P := FP + I + 2;
        if not SetHereEndStr(P) then
        begin
          FLiteralDelimiter := #0;
          FElementIndex := NormalElementIndex;
          SymbolProc;
        end
        else
        begin
          FP := P;
          if I = 1 then
            FHereDocumentStartFlag := HereDocWithIndentElement
          else
            FHereDocumentStartFlag := HereDocElement;
          FToken := toHereDocument;
        end;
      end
      else
        SymbolProc;
    end;
  end;
end;

procedure TRubyFountainParser.HereDocumentProc;
begin
  FToken := toHereDocument;
  while not (FP^ in [#0, #10, #13]) do
    Inc(FP);
end;

function TRubyFountainParser.SetHereEndStr(var P: PChar): Boolean;
{
rubyのソースを見てないので、どういう値が使えるのか分からない
折り返しでバグる(ぉ

この実装では

hoge = <<FOO

や

hoge = <<FOO@

はFOOがヒアドキュメントの終わりの文字になる。
実際、Rubyのパーサーもそうなっているみたい。

varを使っているのはdecするのがなんとなく嫌なので(ぉ
}
var
  S: String;
  OrgP: PChar;
begin
  Result := False;
  OrgP := P;

  // FLiteralDelimiterに入る文字はWordDelimiterに含まれる
  //while not (P^ in (WordDelimiters + [FLiteralDelimiter])) do
  while not (P^ in WordDelimiters) do
  begin
    //if P^ <> FLiteralDelimiter then
    //  S := S + P^;
    inc(P);
  end;

  SetString(S, OrgP, P - OrgP);
  if S <> '' then
  begin
    Result := True;
    FDataStr := S;
  end;
end;

function TRubyFountainParser.SetHereEndStrOfLiteral(var P: PChar): Boolean;
{
hoge = <<"FOO@"

エスケープシーケンスの処理はしないで良いらしい。

折り返すとバグる
}
var
  OrgP: PChar;
  S: string;
begin
  OrgP := P;
  Result := False;

  while not (P^ in [#0, #10, #13]) do
  begin
    // 区切り文字が出現したか?
    if P^ = FLiteralDelimiter then
    begin
      SetString(S, OrgP, P - OrgP);
      if S <> '' then
      begin
        Result := True;
        FDataStr := S;
        Inc(P);
        Break;
      end
      else
        Break;
    end
    else
    begin
      if P^ in LeadBytes then
        Inc(P);
      Inc(P);
    end;
  end;
end;










///////////////////
// TRubyFountain //
///////////////////
procedure TRubyFountain.SetUserKeyWordList(Value: TStringList);
begin
  FUserKeyWordList.Assign(Value);
  //FNotifyEventList.ChangedProc(Self);
end;

destructor TRubyFountain.Destroy;
begin
  FAnk.Free;
  FComment.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  FGlobalVar.Free;
  FInstanceVar.Free;
  FClassVar.Free;
  FConstant.Free;
  FRubySymbol.Free;
  FRegexp.Free;
  FDefinition.Free;
  FUserKeyWord.Free;

  FUserKeyWordList.Free;
  FConfig.Free;
  inherited Destroy;
end;

constructor TRubyFountain.Create(AOwner: TComponent);
begin
  inherited;

  FConfig := TRubyFountainConfig.Create;
  FConfig.OnChange := NotifyEditors;
  FUserKeyWordList := TStringList.Create;
  InitUserKeyWordList;
end;

procedure TRubyFountain.NotifyEditors(Sender: TObject);
begin
  with NotifyEventList do
  begin
    BeginUpdate;
    EndUpdate;
  end;
end;

procedure TRubyFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk := CreateFountainColor;
  FComment := CreateFountainColor;
  FInt := CreateFountainColor;
  FStr := CreateFountainColor;
  FSymbol := CreateFountainColor;
  FGlobalVar := CreateFountainColor;
  FInstanceVar := CreateFountainColor;
  FClassVar := CreateFountainColor;
  FConstant := CreateFountainColor;
  FRubySymbol := CreateFountainColor;
  FRegexp := CreateFountainColor;
  FDefinition := CreateFountainColor;
  FUserKeyWord := CreateFountainColor;
end;

procedure TRubyFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TRubyFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TRubyFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TRubyFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TRubyFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

procedure TRubyFountain.SetGlobalVar(Value: TFountainColor);
begin
  FGlobalVar.Assign(Value);
end;

procedure TRubyFountain.SetInstanceVar(Value: TFountainColor);
begin
  FInstanceVar.Assign(Value);
end;

procedure TRubyFountain.SetClassVar(Value: TFountainColor);
begin
  FClassVar.Assign(Value);
end;

procedure TRubyFountain.SetConstant(Value: TFountainColor);
begin
  FConstant.Assign(Value);
end;

procedure TRubyFountain.SetRubySymbol(Value: TFountainColor);
begin
  FRubySymbol.Assign(Value);
end;

procedure TRubyFountain.SetRegexp(Value: TFountainColor);
begin
  FRegexp.Assign(Value);
end;

procedure TRubyFountain.SetDefinition(Value: TFountainColor);
begin
  FDefinition.Assign(Value);
end;

procedure TRubyFountain.SetUserKeyWord(Value: TFountainColor);
begin
  FUserKeyWord.Assign(Value);
end;


function TRubyFountain.GetParserClass: TFountainParserClass;
begin
  Result := TRubyFountainParser;
end;

{
procedure TRubyFountain.InitBracketItems;
var
  Item : TFountainBracketItem;
begin
  // 文字列リテラル
  Item := Brackets.Add;
  Item.LeftBracket := '"';
  Item.RightBracket := '"';

  // 文字列リテラル
  Item := Brackets.Add;
  Item.LeftBracket := #39;
  Item.RightBracket := #39;
end;
}

procedure TRubyFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.rb');
    Add('.wrb');
    Add('.cgi');
  end;
end;

procedure TRubyFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Sorted := False;
    Duplicates := dupAccept;
    Add('alias');
    Add('and');
    Add('begin');
    Add('BEGIN');
    Add('break');
    Add('case');
    Add('class');
    Add('def');
    Add('defined');
    Add('do');
    Add('else');
    Add('elsif');
    Add('end');
    Add('END');
    Add('ensure');
    Add('false');
    Add('for');
    Add('if');
    Add('in');
    Add('module');
    Add('next');
    Add('nil');
    Add('not');
    Add('or');
    Add('redo');
    Add('rescue');
    Add('retry');
    Add('return');
    Add('self');
    Add('super');
    Add('then');
    Add('true');
    Add('undef');
    Add('unless');
    Add('until');
    Add('when');
    Add('while');
    Add('yield');
  end;
end;

procedure TRubyFountain.InitUserKeyWordList;
begin
  with FUserKeyWordList do
  begin
    Duplicates := dupAccept;
    sorted := True;
{    Add('FOO');
    Add('hoge');
    Add('GOO'); }
  end;
end;

{ TRubyFountainConfig }

procedure TRubyFountainConfig.Assign(Source: TPersistent);
begin
  if Source is TRubyFountainConfig then
  begin
    FOneLineRegexp := TRubyFountainConfig(Source).OneLineRegexp;
    FOneLineString := TRubyFountainConfig(Source).OneLineString;
    Changed;
  end;
end;

constructor TRubyFountainConfig.Create;
begin
  inherited;

  FOneLineRegexp := False;
  FOneLineString := False;
end;

destructor TRubyFountainConfig.Destroy;
begin
  inherited;
end;

procedure TRubyFountainConfig.SetOneLineRegexp(Value: Boolean);
begin
  if FOneLineRegexp <> Value then
  begin
    FOneLineRegexp := Value;
    Changed;
  end;
end;

procedure TRubyFountainConfig.SetOneLineString(Value: Boolean);
begin
  if FOneLineString <> Value then
  begin
    FOneLineString := Value;
    Changed;
  end;
end;


end.

