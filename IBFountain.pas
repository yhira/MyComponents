(*********************************************************************

  IBFountain.pas

  start  2002/05/05
  update 2002/05/05

  Copyright (c) 2002 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  InterBase の SQL を表示するための TIBFountain コンポーネントと
  TIBFountainParser クラス

**********************************************************************)

unit IBFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

type
  TIBFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TIBFountain = class(TFountain)
    FAnk:     TFountainColor;           // 半角文字
    FDBCS:    TFountainColor;           // 全角文字と半角カタカナ
    FInt:     TFountainColor;           // 数値
    FStr:     TFountainColor;           // 文字列
    FSymbol:  TFountainColor;           // 記号
    procedure SetAnk(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
  protected
    function  GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitReserveWordList; override;
    procedure InitFileExtList; override;
    procedure CreateFountainColors; override;
  public
    destructor Destroy; override;

  published
    property Ank:           TFountainColor read FAnk write SetAnk;
    property DBCS:          TFountainColor read FDBCS write SetDBCS;
    property Int:           TFountainColor read FInt write SetInt;
    property Str:           TFountainColor read FStr write SetStr;
    property Symbol:        TFountainColor read FSymbol write SetSymbol;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TIBFountain]);
end;


{ TIBFountainParser }

procedure TIBFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable[#39] := SingleQuotationProc;
end;


function TIBFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TIBFountain(FFountain) do
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
        toReserve:
          Result := Reserve;
        toAnk:
          Result := FAnk;
        toDBSymbol, toDBInt, toDBAlph, toDBHira, toDBKana, toDBKanji, toKanaSymbol, toKana:
          Result := FDBCS;
        toSingleQuotation:
          Result := FStr;
      else
        Result := nil;
      end;
end;


{ TIBFountain }

destructor TIBFountain.Destroy;
begin
  FAnk.Free;
  FDBCS.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  inherited Destroy;
end;

procedure TIBFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk          := CreateFountainColor;
  FDBCS         := CreateFountainColor;
  FInt          := CreateFountainColor;
  FStr          := CreateFountainColor;
  FSymbol       := CreateFountainColor;
end;

procedure TIBFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TIBFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TIBFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TIBFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TIBFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function TIBFountain.GetParserClass: TFountainParserClass;
begin
  Result := TIBFountainParser;
end;

procedure TIBFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '/*';
  Item.RightBracket := '*/';
end;

procedure TIBFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('ACTION');
    Add('ACTIVE');
    Add('ADD');
    Add('ADMIN');
    Add('AFTER');
    Add('ALL');
    Add('ALTER');
    Add('AND');
    Add('ANY');
    Add('AS');
    Add('ASC');
    Add('ASCENDI');
    Add('AT');
    Add('AUTO');
    Add('AUTODDL');
    Add('AVG');
    Add('BASED');
    Add('BASENAM');
    Add('BASE_NA');
    Add('BEFORE');
    Add('BEGIN');
    Add('BETWEEN');
    Add('BLOB');
    Add('BLOBEDI');
    Add('BUFFER');
    Add('BY');
    Add('CACHE');
    Add('CASCADE');
    Add('CAST');
    Add('CHAR');
    Add('CHARACT');
    Add('CHARACT');
    Add('CHAR_LE');
    Add('CHECK');
    Add('CHECK_P');
    Add('CHECK_P');
    Add('COLLATE');
    Add('COLLATI');
    Add('COLUMN');
    Add('COMMIT');
    Add('COMMITT');
    Add('COMPILE');
    Add('COMPUTE');
    Add('CLOSE');
    Add('CONDITI');
    Add('CONNECT');
    Add('CONSTRA');
    Add('CONTAIN');
    Add('CONTINU');
    Add('COUNT');
    Add('CREATE');
    Add('CSTRING');
    Add('CURRENT');
    Add('CURRENT');
    Add('CURRENT');
    Add('CURRENT');
    Add('CURSOR');
    Add('DATABAS');
    Add('DATE');
    Add('DAY');
    Add('DB_KEY');
    Add('DEBUG');
    Add('DEC');
    Add('DECIMAL');
    Add('DECLARE');
    Add('DEFAULT');
    Add('DELETE');
    Add('DESC');
    Add('DESCEND');
    Add('DESCRIB');
    Add('DESCRIP');
    Add('DISCONN');
    Add('DISPLAY');
    Add('DISTINC');
    Add('DO');
    Add('DOMAIN');
    Add('DOUBLE');
    Add('DROP');
    Add('ECHO');
    Add('EDIT');
    Add('ELSE');
    Add('END');
    Add('ENTRY_P');
    Add('ESCAPE');
    Add('EVENT');
    Add('EXCEPTI');
    Add('EXECUTE');
    Add('EXISTS');
    Add('EXIT');
    Add('EXTERN');
    Add('EXTERNA');
    Add('EXTRACT');
    Add('FETCH');
    Add('FILE');
    Add('FILTER');
    Add('FLOAT');
    Add('FOR');
    Add('FOREIGN');
    Add('FOUND');
    Add('FREE_IT');
    Add('FROM');
    Add('FULL');
    Add('FUNCTIO');
    Add('GDSCODE');
    Add('GENERAT');
    Add('GEN_ID');
    Add('GLOBAL');
    Add('GOTO');
    Add('GRANT');
    Add('GROUP');
    Add('GROUP_C');
    Add('GROUP_C');
    Add('HAVING');
    Add('HELP');
    Add('HOUR');
    Add('IF');
    Add('IMMEDIA');
    Add('IN');
    Add('INACTIV');
    Add('INDEX');
    Add('INDICAT');
    Add('INIT');
    Add('INNER');
    Add('INPUT');
    Add('INPUT_T');
    Add('INSERT');
    Add('INT');
    Add('INTEGER');
    Add('INTO');
    Add('IS');
    Add('ISOLATI');
    Add('ISQL');
    Add('JOIN');
    Add('KEY');
    Add('LC_MESS');
    Add('LC_TYPE');
    Add('LEFT');
    Add('LENGTH');
    Add('LEV');
    Add('LEVEL');
    Add('LIKE');
    Add('LOGFILE');
    Add('LOG_BUF');
    Add('LOG_BUF');
    Add('LONG');
    Add('MANUAL');
    Add('MAX');
    Add('MAXIMUM');
    Add('MAXIMUM');
    Add('MAX_SEG');
    Add('MERGE');
    Add('MESSAGE');
    Add('MIN');
    Add('MINIMUM');
    Add('MINUTE');
    Add('MODULE_');
    Add('MONTH');
    Add('NAMES');
    Add('NATIONA');
    Add('NATURAL');
    Add('NCHAR');
    Add('NO');
    Add('NOAUTO');
    Add('NOT');
    Add('NULL');
    Add('NUMERIC');
    Add('NUM_LOG');
    Add('NUM_LOG');
    Add('OCTET_L');
    Add('OF');
    Add('ON');
    Add('ONLY');
    Add('OPEN');
    Add('OPTION');
    Add('OR');
    Add('ORDER');
    Add('OUTER');
    Add('OUTPUT');
    Add('OUTPUT_');
    Add('OVERFLO');
    Add('PAGE');
    Add('PAGELEN');
    Add('PAGES');
    Add('PAGE_SI');
    Add('PARAMET');
    Add('PASSWOR');
    Add('PLAN');
    Add('POSITIO');
    Add('POST_EV');
    Add('PRECISI');
    Add('PREPARE');
    Add('PROCEDU');
    Add('PROTECT');
    Add('PRIMARY');
    Add('PRIVILE');
    Add('PUBLIC');
    Add('QUIT');
    Add('RAW_PAR');
    Add('RDB');
    Add('READ');
    Add('REAL');
    Add('RECORD_');
    Add('REFEREN');
    Add('RELEASE');
    Add('RESERV');
    Add('RESERVI');
    Add('RESTRIC');
    Add('RETAIN');
    Add('RETURN');
    Add('RETURNI');
    Add('RETURNS');
    Add('REVOKE');
    Add('RIGHT');
    Add('ROLE');
    Add('ROLLBAC');
    Add('RUNTIME');
    Add('SCHEMA');
    Add('SECOND');
    Add('SEGMENT');
    Add('SELECT');
    Add('SET');
    Add('SHADOW');
    Add('SHARED');
    Add('SHELL');
    Add('SHOW');
    Add('SINGULA');
    Add('SIZE');
    Add('SMALLIN');
    Add('SNAPSHO');
    Add('SOME');
    Add('SORT');
    Add('SQLCODE');
    Add('SQLERRO');
    Add('SQLWARN');
    Add('STABILI');
    Add('STARTIN');
    Add('STARTS');
    Add('STATEME');
    Add('STATIC');
    Add('STATIST');
    Add('SUB_TYP');
    Add('SUM');
    Add('SUSPEND');
    Add('TABLE');
    Add('TERMINA');
    Add('THEN');
    Add('TIME');
    Add('TIMESTA');
    Add('TO');
    Add('TRANSAC');
    Add('TRANSLA');
    Add('TRANSLA');
    Add('TRIGGER');
    Add('TRIM');
    Add('TYPE');
    Add('UNCOMMI');
    Add('UNION');
    Add('UNIQUE');
    Add('UPDATE');
    Add('UPPER');
    Add('USER');
    Add('USING');
    Add('VALUE');
    Add('VALUES');
    Add('VARCHAR');
    Add('VARIABL');
    Add('VARYING');
    Add('VERSION');
    Add('VIEW');
    Add('WAIT');
    Add('WEEKDAY');
    Add('WHEN');
    Add('WHENEVE');
    Add('WHERE');
    Add('WHILE');
    Add('WITH');
    Add('WORK');
    Add('WRITE');
    Add('YEAR');
    Add('YEARDAY');
  end;
end;

procedure TIBFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.sql');
  end;
end;

end.
