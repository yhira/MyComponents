(***************************************************************

  TextFountain (2003/11/30)

  Copyright (c) 2003 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

***************************************************************)

unit TextFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toQuotation1 = Char(51);
  toQuotation2 = Char(52);
  toQuotation3 = Char(53);
  toQuotation4 = Char(54);

type
  TTextFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure NormalTokenProc; override;
    procedure QuotationProc; virtual;
    procedure CommenterProc; override;
    procedure DBSymbolProc; override;
    function IncludeTabToken: TCharSet; override;
    function EolToken: TCharSet; override;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TTextFountain = class(TFountain)
  private
    FUrl:        TFountainColor;   // URL
    FQuotation1: TFountainColor;   // 引用行1 '>', '＞', '》'
    FQuotation2: TFountainColor;   // 引用行2
    FQuotation3: TFountainColor;   // 引用行3
    FQuotation4: TFountainColor;   // 引用行4
    FComment:    TFountainColor;   // コメント行 '|', '｜', '#'
    FInt:        TFountainColor;   // 数値
    FSymbol:     TFountainColor;   // 記号
    procedure SetUrl(Value: TFountainColor);
    procedure SetQuotation1(Value: TFountainColor);
    procedure SetQuotation2(Value: TFountainColor);
    procedure SetQuotation3(Value: TFountainColor);
    procedure SetQuotation4(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
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
    property Url:        TFountainColor read FUrl write SetUrl;
    property Quotation1: TFountainColor read FQuotation1 write SetQuotation1;
    property Quotation2: TFountainColor read FQuotation2 write SetQuotation2;
    property Quotation3: TFountainColor read FQuotation3 write SetQuotation3;
    property Quotation4: TFountainColor read FQuotation4 write SetQuotation4;
    property Comment:    TFountainColor read FComment write SetComment;
    property Int:        TFountainColor read FInt write SetInt;
    property Symbol:     TFountainColor read FSymbol write SetSymbol;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TTextFountain]);
end;

{ TTextFountainParser }

procedure TTextFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['>'] := QuotationProc;
  FMethodTable['|'] := CommenterProc;
  FMethodTable['#'] := CommenterProc;
  FMethodTable[#$81] := DBSymbolProc;
  // FTokenMethodTable
  FTokenMethodTable[toQuotation1] := QuotationProc;
  FTokenMethodTable[toQuotation2] := QuotationProc;
  FTokenMethodTable[toQuotation3] := QuotationProc;
  FTokenMethodTable[toQuotation4] := QuotationProc;
end;

procedure TTextFountainParser.NormalTokenProc;
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

procedure TTextFountainParser.QuotationProc;
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

procedure TTextFountainParser.CommenterProc;
begin
  if (SourcePos = 0) and (FToken = toEof) or
     (FStartToken = toComment) then
    inherited CommenterProc
  else
    SymbolProc;
end;

procedure TTextFountainParser.DBSymbolProc;
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

function TTextFountainParser.IncludeTabToken: TCharSet;
begin
  Result := [toComment, toQuotation1, toQuotation2, toQuotation3, toQuotation4];
end;

function TTextFountainParser.EolToken: TCharSet;
begin
  Result := [toComment, toQuotation1, toQuotation2, toQuotation3, toQuotation4];
end;

function TTextFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TTextFountain(FFountain) do
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
        toUrl:
          Result := FUrl;
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


{ TTextFountain }

destructor TTextFountain.Destroy;
begin
  FUrl.Free;
  FQuotation1.Free;
  FQuotation2.Free;
  FQuotation3.Free;
  FQuotation4.Free;
  FComment.Free;
  FInt.Free;
  FSymbol.Free;
  inherited Destroy;
end;

procedure TTextFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FUrl        := CreateFountainColor;
  FQuotation1 := CreateFountainColor;
  FQuotation2 := CreateFountainColor;
  FQuotation3 := CreateFountainColor;
  FQuotation4 := CreateFountainColor;
  FComment    := CreateFountainColor;
  FInt        := CreateFountainColor;
  FSymbol     := CreateFountainColor;
end;

procedure TTextFountain.SetUrl(Value: TFountainColor);
begin
  FUrl.Assign(Value);
end;

procedure TTextFountain.SetQuotation1(Value: TFountainColor);
begin
  FQuotation1.Assign(Value);
end;

procedure TTextFountain.SetQuotation2(Value: TFountainColor);
begin
  FQuotation2.Assign(Value);
end;

procedure TTextFountain.SetQuotation3(Value: TFountainColor);
begin
  FQuotation3.Assign(Value);
end;

procedure TTextFountain.SetQuotation4(Value: TFountainColor);
begin
  FQuotation4.Assign(Value);
end;

procedure TTextFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TTextFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TTextFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function TTextFountain.GetParserClass: TFountainParserClass;
begin
  Result := TTextFountainParser;
end;

procedure TTextFountain.InitBracketItems;
//var
//  Item: TFountainBracketItem;
begin
//  Item := Brackets.Add;
//  Item.LeftBracket := '';
//  Item.RightBracket := '';
end;

procedure TTextFountain.InitReserveWordList;
begin
//  with ReserveWordList do
//  begin
//    Add('');
//  end;
end;

procedure TTextFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.txt');
    Add('.csv');
    Add('.dat');
  end;
end;

end.
