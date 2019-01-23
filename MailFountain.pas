(*********************************************************************

  MailFountain.pas

  start  2003/07/26
  update 2003/08/13

  Copyright (c) 2003 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  Mail 表示するための TMailFountain コンポーネントと
  TMailFountainParser クラス

**********************************************************************)

unit MailFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toPlatformDependent = Char(50);
  toQuotation1        = Char(51);
  toQuotation2        = Char(52);
  toQuotation3        = Char(53);
  toQuotation4        = Char(54);

type
  TMailFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure NormalTokenProc; override;
    procedure PlatformDependentProc; virtual;
    procedure QuotationProc; virtual;
    procedure CommenterProc; override;
    procedure DBSymbolProc; override;
    function IncludeTabToken: TCharSet; override;
    function EolToken: TCharSet; override;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TMailFountain = class(TFountain)
  private
    FUrl:               TFountainColor;   // URL
    FMail:              TFountainColor;   // Mail
    FKana:              TFountainColor;   // 半角カナ
    FPlatformDependent: TFountainColor;   // 機種依存文字
    FQuotation1:        TFountainColor;   // 引用行1 '>', '＞', '》'
    FQuotation2:        TFountainColor;   // 引用行2
    FQuotation3:        TFountainColor;   // 引用行3
    FQuotation4:        TFountainColor;   // 引用行4
    FComment:           TFountainColor;   // コメント行 '|', '｜'
    procedure SetMail(Value: TFountainColor);
    procedure SetUrl(Value: TFountainColor);
    procedure SetKana(Value: TFountainColor);
    procedure SetPlatformDependent(Value: TFountainColor);
    procedure SetQuotation1(Value: TFountainColor);
    procedure SetQuotation2(Value: TFountainColor);
    procedure SetQuotation3(Value: TFountainColor);
    procedure SetQuotation4(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
  protected
    function  GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitReserveWordList; override;
    procedure InitFileExtList; override;
    procedure CreateFountainColors; override;
  public
    destructor Destroy; override;

  published
    property Mail:              TFountainColor read FMail write SetMail;
    property Url:               TFountainColor read FUrl write SetUrl;
    property Kana:              TFountainColor read FKana write SetKana;
    property PlatformDependent: TFountainColor read FPlatformDependent write SetPlatformDependent;
    property Quotation1:        TFountainColor read FQuotation1 write SetQuotation1;
    property Quotation2:        TFountainColor read FQuotation2 write SetQuotation2;
    property Quotation3:        TFountainColor read FQuotation3 write SetQuotation3;
    property Quotation4:        TFountainColor read FQuotation4 write SetQuotation4;
    property Comment:           TFountainColor read FComment write SetComment;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TMailFountain]);
end;

{ TMailFountainParser }

procedure TMailFountainParser.InitMethodTable;
var
  C: Char;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['>'] := QuotationProc;
  FMethodTable['|'] := CommenterProc;
  FMethodTable[#$81] := DBSymbolProc;
  for C := #$85 to #$88 do
    FMethodTable[C] := PlatformDependentProc;
  for C := #$EB to #$EF do
    FMethodTable[C] := PlatformDependentProc;
  for C := #$F0 to #$FF do
    FMethodTable[C] := PlatformDependentProc;
  // FTokenMethodTable
  FTokenMethodTable[toPlatformDependent] := PlatformDependentProc;
  FTokenMethodTable[toQuotation1] := QuotationProc;
  FTokenMethodTable[toQuotation2] := QuotationProc;
  FTokenMethodTable[toQuotation3] := QuotationProc;
  FTokenMethodTable[toQuotation4] := QuotationProc;
end;

procedure TMailFountainParser.NormalTokenProc;
begin
  if (FBracketIndex = NormalBracketIndex) and IsBracketProc then
    BracketProc
  else
    if IsUrlProc then
      UrlProc
    else
      if IsMailProc then
        MailProc
      else
        FMethodTable[FP^];
end;

procedure TMailFountainParser.PlatformDependentProc;
// #$8540..#$889E 機種依存文字の主なエリア
// #$EB40..#$EFFC 第２水準漢字の後部（MacOS では縦書用文字、Windows では特殊な外字）
// #$F040..       JIS外字エリア
begin
  if ((FP^ = #$85) and ((FP + 1)^ >= #$40) or (FP^ in [#$86, #$87]) or (FP^ = #$88) and ((FP + 1)^ <= #$9E)) or
     ((FP^ = #$EB) and ((FP + 1)^ >= #$40) or (FP^ in [#$EC..#$EE]) or (FP^ = #$EF) and ((FP + 1)^ <= #$FC)) or
     ((FP^ = #$F0) and ((FP + 1)^ >= #$40) or (FP^ in [#$F1..#$FF])) then
    FToken := toPlatformDependent;
  Inc(FP, 2);
end;

procedure TMailFountainParser.QuotationProc;
  function InQuotation: Boolean;
  begin
    Result := FStartToken in [toQuotation1, toQuotation2, toQuotation3, toQuotation4];
  end;

  function IsQuotation: Boolean;
  begin
    Result := (FP^ = '>') or (FP^ = #$81) and ((FP + 1)^ in [#$74, #$84]);
  end;

  procedure Skip;
  begin
    if FP^ in LeadBytes then
      Inc(FP);
    Inc(FP);
    while (FP^ = #$20) do
      Inc(FP);
  end;

begin
  if (SourcePos = 0) and (FToken = toEof) or InQuotation then
  begin
    if InQuotation then
    begin
      FToken := FStartToken;
      while not (FP^ in [#0, #10, #13]) do
        Inc(FP);
      Exit;
    end;

    if IsQuotation then
    begin
      FToken := toQuotation1;
      Skip;
      if IsQuotation then
      begin
        FToken := toQuotation2;
        Skip;
        if IsQuotation then
        begin
          FToken := toQuotation3;
          Skip;
          if IsQuotation then
          begin
            FToken := toQuotation4;
            Skip;
          end;
        end;
      end;
    end;

    while not (FP^ in [#0, #10, #13]) do
      Inc(FP);
  end
  else
    SymbolProc;
end;

procedure TMailFountainParser.CommenterProc;
begin
  if (SourcePos = 0) and (FToken = toEof) or
     (FStartToken = toComment) then
    inherited CommenterProc
  else
    SymbolProc;
end;

procedure TMailFountainParser.DBSymbolProc;
begin
  if (SourcePos = 0) and (FToken = toEof) then
    if (FP + 1)^ = #$62 then
      // '｜'
      CommenterProc
    else
      if (FP + 1)^ in [#$74, #$84] then
        // '》' '＞'
        QuotationProc
      else
        inherited DBSymbolProc
  else
    inherited DBSymbolProc;
end;

function TMailFountainParser.IncludeTabToken: TCharSet;
begin
  Result := [toComment, toQuotation1, toQuotation2, toQuotation3, toQuotation4];
end;

function TMailFountainParser.EolToken: TCharSet;
begin
  Result := [toComment, toQuotation1, toQuotation2, toQuotation3, toQuotation4];
end;

function TMailFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TMailFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toReserve:
          Result := Reserve;
        toUrl:
          Result := FUrl;
        toMail:
          Result := FMail;
        toKanaSymbol, toKana:
          Result := FKana;
        toPlatformDependent:
          Result := FPlatformDependent;
        toQuotation1:
          Result := FQuotation1;
        toQuotation2:
          Result := FQuotation2;
        toQuotation3:
          Result := FQuotation3;
        toQuotation4:
          Result := FQuotation4;
        toComment:
          Result := FComment;
      else
        Result := nil;
      end;
end;


{ TMailFountain }

destructor TMailFountain.Destroy;
begin
  FMail.Free;
  FUrl.Free;
  FKana.Free;
  FPlatformDependent.Free;
  FQuotation1.Free;
  FQuotation2.Free;
  FQuotation3.Free;
  FQuotation4.Free;
  FComment.Free;
  inherited Destroy;
end;

procedure TMailFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FMail              := CreateFountainColor;
  FUrl               := CreateFountainColor;
  FKana              := CreateFountainColor;
  FPlatformDependent := CreateFountainColor;
  FQuotation1        := CreateFountainColor;
  FQuotation2        := CreateFountainColor;
  FQuotation3        := CreateFountainColor;
  FQuotation4        := CreateFountainColor;
  FComment           := CreateFountainColor;
end;

procedure TMailFountain.SetUrl(Value: TFountainColor);
begin
  FUrl.Assign(Value);
end;

procedure TMailFountain.SetMail(Value: TFountainColor);
begin
  FMail.Assign(Value);
end;

procedure TMailFountain.SetKana(Value: TFountainColor);
begin
  FKana.Assign(Value);
end;

procedure TMailFountain.SetPlatformDependent(Value: TFountainColor);
begin
  FPlatformDependent.Assign(Value);
end;

procedure TMailFountain.SetQuotation1(Value: TFountainColor);
begin
  FQuotation1.Assign(Value);
end;

procedure TMailFountain.SetQuotation2(Value: TFountainColor);
begin
  FQuotation2.Assign(Value);
end;

procedure TMailFountain.SetQuotation3(Value: TFountainColor);
begin
  FQuotation3.Assign(Value);
end;

procedure TMailFountain.SetQuotation4(Value: TFountainColor);
begin
  FQuotation4.Assign(Value);
end;

procedure TMailFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

function TMailFountain.GetParserClass: TFountainParserClass;
begin
  Result := TMailFountainParser;
end;

procedure TMailFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '=?';
  Item.RightBracket := '?=';
end;

procedure TMailFountain.InitReserveWordList;
begin
//  with ReserveWordList do
//  begin
//    Add('');
//  end;
end;

procedure TMailFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.log');
  end;
end;

end.
