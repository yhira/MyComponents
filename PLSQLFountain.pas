(*********************************************************************

  PLSQLFountain.pas

  start  2002/05/28
  update

  Copyright (c) 2002 pantograph. <pantograph@nifty.com>

  --------------------------------------------------------------------
  PL/SQL を表示するための TPLSQLFountain コンポーネントと
  TPLSQLFountainParser クラス

**********************************************************************)

unit PLSQLFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

type
  TPLSQLFountainParser = class(TFountainParser)
  protected
    procedure AnkProc; override;
    procedure HyphenProc; virtual;
    procedure SingleQuotationProc; override;
    procedure SymbolProc; override;
    procedure InitMethodTable; override;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TPLSQLFountain = class(TFountain)
  private
    FAnk: TFountainColor;                  // 文字(半角・全角)
    FComment: TFountainColor;              // コメント部分
    FInt: TFountainColor;                  // 数値
    FStr: TFountainColor;                  // 文字列
    FSymbol: TFountainColor;               // 記号
    procedure SetAnk(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
  protected
    function GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitFileExtList; override;
    procedure InitReserveWordList; override;
    procedure CreateFountainColors; override;
  public
    destructor Destroy; override;
  published
    property Ank: TFountainColor read FAnk write SetAnk;
    property Comment: TFountainColor read FComment write SetComment;
    property Int: TFountainColor read FInt write SetInt;
    property Str: TFountainColor read FStr write SetStr;
    property Symbol: TFountainColor read FSymbol write SetSymbol;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TPLSQLFountain]);
end;

const
  SingleQuotationBlockElement  = 1;

{ TPLSQLFountainParser }

procedure TPLSQLFountainParser.AnkProc;
  procedure NormalProc;
  begin
    while True do
      if (FP^ in [ '0'..'9', 'A'..'Z', '_', 'a'..'z', '$', '#']) then
        Inc(FP)
      else if (FP^ in LeadBytes) then
        Inc(FP, 2)
      else if (FP^ in [#$A1..#$DF]) then //半角カナ
        Inc(FP)
      else
        Break;
  end;
begin
  if FElementIndex = SingleQuotationBlockElement then begin
    SingleQuotationProc;
  end else begin
    FToken := toAnk;
    NormalProc;
  end;
end;

procedure TPLSQLFountainParser.HyphenProc;
// '-'
begin
  if FElementIndex = SingleQuotationBlockElement then
    SingleQuotationProc
  else
  if (FP + 1)^ = '-' then
    CommenterProc
  else
    SymbolProc;
end;

procedure TPLSQLFountainParser.SingleQuotationProc;
// PL*SQLでは文字列中の改行も許すためoverrideして処理
var
  C: Char;
begin
  FToken := toSingleQuotation;
  if FElementIndex <> SingleQuotationBlockElement then begin
    FElementIndex := SingleQuotationBlockElement;
    if not FIsStartToken then
      Inc(FP);
  end;
  C := '''';
  while not (FP^ = #0) do begin
    if FP^ = C then begin
      Inc(FP);
      if FP^ <> C then begin
        FElementIndex := NormalElementIndex;
        Break;
      end;
    end;
    if FP^ in LeadBytes then
      Inc(FP);
    Inc(FP);
  end;
end;

procedure TPLSQLFountainParser.SymbolProc;
begin
  if FElementIndex = SingleQuotationBlockElement then
    SingleQuotationProc
  else
    inherited SymbolProc;
end;

procedure TPLSQLFountainParser.InitMethodTable;
var
  C: Char;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['-'] := HyphenProc;
  for C := #$81 to #$FC do begin
    FMethodTable[C] := AnkProc;
  end;
  FMethodTable[#$A0] := SymbolProc;
end;

function TPLSQLFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TPLSQLFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat:
          Result := FInt;
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toComment:
          Result := FComment;
        toReserve:
          Result := Reserve;
        toAnk, toDBSymbol, toDBInt, toDBAlph, toDBHira, toDBKana, toDBKanji, toKanaSymbol, toKana:
          Result := FAnk;
        toSingleQuotation:
          Result := FStr;
      else
        Result := nil;
      end;
end;


{ TPLSQLFountain }

destructor TPLSQLFountain.Destroy;
begin
  FAnk.Free;
  FComment.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  inherited Destroy;
end;

procedure TPLSQLFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk := CreateFountainColor;
  FComment := CreateFountainColor;
  FInt := CreateFountainColor;
  FStr := CreateFountainColor;
  FSymbol := CreateFountainColor;
end;

procedure TPLSQLFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TPLSQLFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TPLSQLFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TPLSQLFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TPLSQLFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function TPLSQLFountain.GetParserClass: TFountainParserClass;
begin
  Result := TPLSQLFountainParser;
end;

procedure TPLSQLFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '/*';
  Item.RightBracket := '*/';
end;

procedure TPLSQLFountain.InitFileExtList;
begin
  FileExtList.Append('.sql');
end;

procedure TPLSQLFountain.InitReserveWordList;
begin
  with ReserveWordList do begin
    Append('ABORT');
    Append('ACCEPT');
    Append('ACCESS');
    Append('ADD');
    Append('ALL');
    Append('ALTER');
    Append('AND');
    Append('ANY');
    Append('ARRAY');
    Append('ARRAYLEN');
    Append('AS');
    Append('ASC');
    Append('ASSERT');
    Append('ASSIGN');
    Append('AT');
    Append('AUDIT');
    Append('AUTHORIZATION');
    Append('AVG');
    Append('BASE_TABLE');
    Append('BEGIN');
    Append('BETWEEN');
    Append('BINARY_ARRAY');
    Append('BODY');
    Append('BOOLEAN');
    Append('BY');
    Append('CASE');
    Append('CHAR');
    Append('CHAR_BASE');
    Append('CHECK');
    Append('CLOSE');
    Append('CLUSTER');
    Append('CLUSTERS');
    Append('COLAUTH');
    Append('COLUMN');
    Append('COMMENT');
    Append('COMMIT');
    Append('COMPRESS');
    Append('CONNECT');
    Append('CONSTANT');
    Append('CRASH');
    Append('CREATE');
    Append('CURRENT');
    Append('CURRVAL');
    Append('CURSOR');
    Append('DATABASE');
    Append('DATA_BASE');
    Append('DATE');
    Append('DBA');
    Append('DEBUGOFF');
    Append('DEBUGON');
    Append('DECIMAL');
    Append('DECLARE');
    Append('DEFAULT');
    Append('DEFINITION');
    Append('DELAY');
    Append('DELETE');
    Append('DESC');
    Append('DIGITS');
    Append('DISPOSE');
    Append('DISTINCT');
    Append('DO');
    Append('DROP');
    Append('ELSE');
    Append('ELSIF');
    Append('END');
    Append('ENTRY');
    Append('EXCEPTION');
    Append('EXCEPTION_INIT');
    Append('EXCLUSIVE');
    Append('EXISTS');
    Append('EXIT');
    Append('FALSE');
    Append('FETCH');
    Append('FILE');
    Append('FLOAT');
    Append('FOR');
    Append('FORM');
    Append('FROM');
    Append('FUNCTION');
    Append('GENERIC');
    Append('GOTO');
    Append('GRANT');
    Append('GROUP');
    Append('HAVING');
    Append('IDENTIFIED');
    Append('IF');
    Append('IMMEDIATE');
    Append('IN');
    Append('INCREMENT');
    Append('INDEX');
    Append('INDEXES');
    Append('INDICATOR');
    Append('INITIAL');
    Append('INSERT');
    Append('INTEGER');
    Append('INTERFACE');
    Append('INTERSECT');
    Append('INTO');
    Append('IS');
    Append('LEVEL');
    Append('LIKE');
    Append('LIMITED');
    Append('LOCK');
    Append('LONG');
    Append('LOOP');
    Append('MAX');
    Append('MAXEXTENTS');
    Append('MIN');
    Append('MINUS');
    Append('MLSLABEL');
    Append('MOD');
    Append('MODE');
    Append('NATURAL');
    Append('NATURALN');
    Append('NEW');
    Append('NEXTVAL');
    Append('NOAUDIT');
    Append('NOCOMPRESS');
    Append('NOT');
    Append('NOWAIT');
    Append('NULL');
    Append('NUMBER');
    Append('NUMBER_BASE');
    Append('OF');
    Append('OFFLINE');
    Append('ON');
    Append('ONLINE');
    Append('OPEN');
    Append('OPTION');
    Append('OR');
    Append('ORDER');
    Append('OTHERS');
    Append('OUT');
    Append('PACKAGE');
    Append('PARTITION');
    Append('PCTFREE');
    Append('PLS_INTEGER');
    Append('POSITIVE');
    Append('POSITIVEN');
    Append('PRAGMA');
    Append('PRIOR');
    Append('PRIVATE');
    Append('PRIVILEGES');
    Append('PROCEDURE');
    Append('PUBLIC');
    Append('RAW');
    Append('RAISE');
    Append('RANGE');
    Append('REAL');
    Append('RECORD');
    Append('REF');
    Append('RELEASE');
    Append('REMR');
    Append('RENAME');
    Append('RESOURCE');
    Append('RETURN');
    Append('REVERSE');
    Append('REVOKE');
    Append('ROLLBACK');
    Append('ROW');
    Append('ROWID');
    Append('ROWLABEL');
    Append('ROWNUM');
    Append('ROWS');
    Append('ROWTYPE');
    Append('RUN');
    Append('SAVEPOINT');
    Append('SCHEMA');
    Append('SELECT');
    Append('SEPARATE');
    Append('SET');
    Append('SHARE');
    Append('SMALLINT');
    Append('SPACE');
    Append('SQL');
    Append('SQLCODE');
    Append('SQLERRM');
    Append('STATE');
    Append('STATEMENT');
    Append('STDDEV');
    Append('SUBTYPE');
    Append('SUCCESSFUL');
    Append('SUM');
    Append('SYNONYM');
    Append('SYSDATE');
    Append('TABAUTH');
    Append('TABLE');
    Append('TABLES');
    Append('TASK');
    Append('TERMINATE');
    Append('THEN');
    Append('TO');
    Append('TRIGGER');
    Append('TRUE');
    Append('TYPE');
    Append('UID');
    Append('UNION');
    Append('UNIQUE');
    Append('UPDATE');
    Append('USE');
    Append('USER');
    Append('VALIDATE');
    Append('VALUES');
    Append('VARCHAR');
    Append('VARCHAR2');
    Append('VARIANCE');
    Append('VIEW');
    Append('VIEWS');
    Append('WHEN');
    Append('WHENEVER');
    Append('WHERE');
    Append('WHILE');
    Append('WITH');
    Append('WORK');
    Append('WRITE');
    Append('XOR');
    //以下はPL/SQLの予約語ではないがDDL文で強調表示したいために追加
    Append('ADMIN');
    Append('CASCADE');
    Append('CONTENTS');
    Append('CONSTRAINT');
    Append('CONSTRAINTS');
    Append('DATAFILE');
    Append('DATAFILES');
    Append('DEFINE');
    Append('EXECUTE');
    Append('FOREIGN');
    Append('INCLUDING');
    Append('KEY');
    Append('PRIMARY');
    Append('REFERENCES');
    Append('REPLACE');
    Append('SEQUENCE');
    Append('SIZE');
    Append('START');
    Append('TABLESPACE');
  end;
end;

end.

