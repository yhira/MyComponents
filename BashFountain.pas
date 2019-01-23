(*********************************************************************

  BashFountain.pas

  start  2004/11/14
  update 2005/05/28

  Copyright (c) 2004, 2005 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  シェル(bash) を表示するための TBashFountain コンポーネントと
  TBashFountainParser クラス

**********************************************************************)

unit BashFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toVariable           = Char(50);
  toBackQuotation      = Char(51);
  toCommand            = Char(52);
  toShellVariable      = Char(53);

type
  TBashFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure ZeroProc; virtual;
    procedure VariableProc; virtual;
    procedure DoubleQuotationProc; override;
    procedure BackQuotationProc; virtual;
    procedure CommandWordProc; virtual;
    procedure ShellVariableWordProc; virtual;
    procedure WrappedTokenIsReserveWord(var AToken: Char); override;
    function IsCommandWord: Boolean; virtual;
    function IsShellVariableWord: Boolean; virtual;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TBashFountain = class(TFountain)
    FAnk:           TFountainColor;     // 半角文字
    FComment:       TFountainColor;     // コメント部分
    FDBCS:          TFountainColor;     // 全角文字と半角カタカナ
    FInt:           TFountainColor;     // 数値
    FStr:           TFountainColor;     // 文字列
    FSymbol:        TFountainColor;     // 記号
    FVariable:      TFountainColor;     // 変数
    FCommand:       TFountainColor;     // 組み込みコマンド
    FShellVariable: TFountainColor;     // シェル変数
    FCommandWordList: TStringList;
    FShellVariableWordList: TStringList;
    procedure SetAnk(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
    procedure SetVariable(Value: TFountainColor);
    procedure SetCommand(Value: TFountainColor);
    procedure SetCommandWordList(Value: TStringList);
    procedure SetShellVariable(Value: TFountainColor);
    procedure SetShellVariableWordList(Value: TStringList);
  protected
    function  GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitReserveWordList; override;
    procedure InitCommandWordList; virtual;
    procedure InitShellVariableWordList; virtual;
    procedure InitFileExtList; override;
    procedure CreateFountainColors; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Ank:           TFountainColor read FAnk write SetAnk;
    property Comment:       TFountainColor read FComment write SetComment;
    property DBCS:          TFountainColor read FDBCS write SetDBCS;
    property Int:           TFountainColor read FInt write SetInt;
    property Str:           TFountainColor read FStr write SetStr;
    property Symbol:        TFountainColor read FSymbol write SetSymbol;
    property Variable:      TFountainColor read FVariable write SetVariable;
    property Command:       TFountainColor read FCommand write SetCommand;
    property ShellVariable: TFountainColor read FShellVariable write SetShellVariable;
    property CommandWordList:       TStringList read FCommandWordList write SetCommandWordList;
    property ShellVariableWordList: TStringList read FShellVariableWordList write SetShellVariableWordList;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TBashFountain]);
end;


{ TBashFountainParser }

procedure TBashFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['0'] := ZeroProc;
  FMethodTable['$'] := VariableProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable['`'] := BackQuotationProc;
  FMethodTable['#'] := CommenterProc;
  // FTokenMethodTable
  FTokenMethodTable[toVariable] := VariableProc;
  FTokenMethodTable[toBackQuotation] := BackQuotationProc;
  FTokenMethodTable[toCommand] := CommandWordProc;
  FTokenMethodTable[toShellVariable] := ShellVariableWordProc;
end;

procedure TBashFountainParser.ZeroProc;
// '0'
begin
  Inc(FP);
  if (FP^ = 'x') or (FP^ = 'X') then
  begin
    Inc(FP);
    HexProc;
  end
  else
    IntegerProc;
end;

procedure TBashFountainParser.VariableProc;
// '$'
begin
  Inc(FP);
  if (FP^ in [ '!', '#', '$', '0'..'9', '?', '*', '@', '-']) then
  begin
    FToken := toVariable;
    Inc(FP);
  end
  else
  begin
    if (FP^ in ['A'..'Z', 'a'..'z']) then
    begin
      FToken := toVariable;
      Inc(FP);
      while FP^ in [ '0'..'9', 'A'..'Z', '_', 'a'..'z'] do
        Inc(FP);
    end
    else
      FToken := toSymbol;
  end;
end;

procedure TBashFountainParser.DoubleQuotationProc;
var
  C: Char;
begin
  FToken := toDoubleQuotation;
  if not FIsStartToken then
    Inc(FP);
  C := '"';
  while not (FP^ in [#0, #10, #13]) do
  begin
    if (FP^ = '\') and ((FP + 1)^ = C) then
      Inc(FP)
    else
      if FP^ = C then
      begin
        Inc(FP);
        if FP^ <> C then
          Break;
      end;
    if FP^ in LeadBytes then
      Inc(FP);
    Inc(FP);
  end;
end;

procedure TBashFountainParser.BackQuotationProc;
var
  C: Char;
begin
  FToken := toBackQuotation;
  if not FIsStartToken then
    Inc(FP);
  C := '`';
  while not (FP^ in [#0, #10, #13]) do
  begin
    if (FP^ = '\') and ((FP + 1)^ = C) then
      Inc(FP)
    else
      if FP^ = C then
      begin
        Inc(FP);
        if FP^ <> C then
          Break;
      end;
    if FP^ in LeadBytes then
      Inc(FP);
    Inc(FP);
  end;
end;

procedure TBashFountainParser.CommandWordProc;
begin
  FMethodTable[FP^];
  FToken := toCommand;
end;

procedure TBashFountainParser.ShellVariableWordProc;
begin
  FMethodTable[FP^];
  FToken := toShellVariable;
end;

procedure TBashFountainParser.WrappedTokenIsReserveWord(var AToken: Char);
begin
  if IsReserveWord then
    AToken := toReserve
  else
    if IsCommandWord then
      AToken := toCommand
    else
      if IsShellVariableWord then
        AToken := toShellVariable;
end;

function TBashFountainParser.IsCommandWord: Boolean;
var
  I: Integer;
begin
  Result := not FIsStartToken and
            not (FToken in [toEof, toBracket, toComment]) and
            TBashFountain(FFountain).CommandWordList.Find(TokenString, I);
end;

function TBashFountainParser.IsShellVariableWord: Boolean;
var
  I: Integer;
begin
  Result := not FIsStartToken and
            not (FToken in [toEof, toBracket, toComment]) and
            TBashFountain(FFountain).ShellVariableWordList.Find(TokenString, I);
end;

function TBashFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TBashFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      if IsCommandWord then
        Result := Command
      else
        if IsShellVariableWord then
          Result := ShellVariable
        else
          case FToken of
            toSymbol:
              Result := FSymbol;
            toVariable:
              Result := FVariable;
            toInteger, toFloat, toHex:
              Result := FInt;
            toBracket:
              Result := Brackets[FDrawBracketIndex].ItemColor;
            toComment:
              Result := FComment;
            toReserve:
              Result := Reserve;
            toCommand, toBackQuotation:
              Result := Command;
            toShellVariable:
              Result := ShellVariable;
            toAnk:
              Result := FAnk;
            toDBSymbol, toDBInt, toDBAlph, toDBHira, toDBKana, toDBKanji, toKanaSymbol, toKana:
              Result := FDBCS;
            toSingleQuotation, toDoubleQuotation:
              Result := FStr;
          else
            Result := nil;
          end;
end;


{ TBashFountain }

constructor TBashFountain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommandWordList := CreateSortedList;
  FShellVariableWordList := CreateSortedList;
  InitCommandWordList;
  InitShellVariableWordList
end;

destructor TBashFountain.Destroy;
begin
  FCommandWordList.Free;
  FShellVariableWordList.Free;
  FAnk.Free;
  FComment.Free;
  FDBCS.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  FVariable.Free;
  FCommand.Free;
  FShellVariable.Free;
  inherited Destroy;
end;

procedure TBashFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk           := CreateFountainColor;
  FComment       := CreateFountainColor;
  FDBCS          := CreateFountainColor;
  FInt           := CreateFountainColor;
  FStr           := CreateFountainColor;
  FSymbol        := CreateFountainColor;
  FVariable      := CreateFountainColor;
  FCommand       := CreateFountainColor;
  FShellVariable := CreateFountainColor;
end;

procedure TBashFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TBashFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TBashFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TBashFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TBashFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TBashFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

procedure TBashFountain.SetVariable(Value: TFountainColor);
begin
  FVariable.Assign(Value);
end;

procedure TBashFountain.SetCommand(Value: TFountainColor);
begin
  FCommand.Assign(Value);
end;

procedure TBashFountain.SetShellVariable(Value: TFountainColor);
begin
  FShellVariable.Assign(Value);
end;

procedure TBashFountain.SetCommandWordList(Value: TStringList);
begin
  FCommandWordList.Assign(Value);
  NotifyEventList.ChangedProc(Self);
end;

procedure TBashFountain.SetShellVariableWordList(Value: TStringList);
begin
  FShellVariableWordList.Assign(Value);
  NotifyEventList.ChangedProc(Self);
end;

function TBashFountain.GetParserClass: TFountainParserClass;
begin
  Result := TBashFountainParser;
end;

procedure TBashFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '${';
  Item.RightBracket := '}';
  Item := Brackets.Add;
  Item.LeftBracket := '$(';
  Item.RightBracket := ')';
end;

procedure TBashFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    // 予約語
    Add('case');
    Add('do');
    Add('done');
    Add('elif');
    Add('else');
    Add('esac');
    Add('fi');
    Add('for');
    Add('function');
    Add('if');
    Add('in');
    Add('select');
    Add('then');
    Add('time');
    Add('until');
    Add('while');
  end;
end;

procedure TBashFountain.InitCommandWordList;
begin
  with CommandWordList do
  begin
    // 組み込みコマンド
    Add('alias');
    Add('bg');
    Add('bind');
    Add('break');
    Add('builtin');
    Add('cd');
    Add('command');
    Add('compgen');
    Add('complete');
    Add('continue');
    Add('dirs');
    Add('disown');
    Add('echo');
    Add('enable');
    Add('eval');
    Add('exec');
    Add('exit');
    Add('export');
    Add('fc');
    Add('fg');
    Add('getopts');
    Add('hash');
    Add('help');
    Add('history');
    Add('jobs');
    Add('kill');
    Add('let');
    Add('local');
    Add('logout');
    Add('popd');
    Add('printf');
    Add('pushd');
    Add('pwd');
    Add('read');
    Add('readonly');
    Add('return');
    Add('set');
    Add('shift');
    Add('shopt');
    Add('source');
    Add('suspend');
    Add('times');
    Add('trap');
    Add('type');
    Add('typeset');
    Add('ulimit');
    Add('umask');
    Add('unalias');
    Add('unset');
    Add('wait');
  end;
end;

procedure TBashFountain.InitShellVariableWordList;
begin
  with ShellVariableWordList do
  begin
    // シェル変数
    Add('auto_resume');
    Add('BASH');
    Add('BASH_ENV');
    Add('BASH_VERSINFO');
    Add('BASH_VERSION');
    Add('CDPATH');
    Add('COLUMNS');
    Add('COMP_CWORD');
    Add('COMP_LINE');
    Add('COMP_POINT');
    Add('COMP_WORDS');
    Add('COMPREPLY');
    Add('DIRSTACK');
    Add('EUID');
    Add('FCEDIT');
    Add('FIGNORE');
    Add('FUNCNAME');
    Add('GLOBIGNORE');
    Add('GROUPS');
    Add('histchars');
    Add('HISTCMD');
    Add('HISTCONTROL');
    Add('HISTFILE');
    Add('HISTFILESIZE');
    Add('HISTIGNORE');
    Add('HISTSIZE');
    Add('HOME');
    Add('HOSTFILE');
    Add('HOSTNAME');
    Add('HOSTTYPE');
    Add('IFS');
    Add('IGNOREEOF');
    Add('INPUTRC');
    Add('LANG');
    Add('LC_ALL');
    Add('LC_COLLATE');
    Add('LC_CTYPE');
    Add('LC_MESSAGES');
    Add('LC_NUMERIC');
    Add('LINENO');
    Add('LINES');
    Add('MACHTYPE');
    Add('MAIL');
    Add('MAILCHECK');
    Add('MAILPATH');
    Add('OLDPWD');
    Add('OPTARG');
    Add('OPTERR');
    Add('OPTIND');
    Add('OSTYPE');
    Add('PATH');
    Add('PIPESTATUS');
    Add('PPID');
    Add('PS1');
    Add('PS2');
    Add('PS3');
    Add('PS4');
    Add('PWD');
    Add('RANDOM');
    Add('REPLY');
    Add('SECONDS');
    Add('SHELLOPTS');
    Add('SHLVL');
    Add('TIMEFORMAT');
    Add('TMOUT');
    Add('UID');     
  end;
end;

procedure TBashFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.sh');
  end;
end;

end.
