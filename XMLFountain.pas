(*********************************************************************

  XMLFountain.pas

  start  2005/04/08
  update 2005/04/12

  Copyright (C) 2005 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  XML ファイルを表示するための TXMLFountain コンポーネントと
  TXMLFountainParser クラス

  仕様
    ・XML宣言
          <?   ～  ?>
    ・コメント
          <!-- ～ -->
    ・タグ
          < または >
    ・要素名
          <要素名> または </要素名> または <要素名 />
          要素名の命名規則
          1)名前の1文字目に許されている文字
              _ (アンダーバー)
              : (コロン、名前空間との区切り)
              アルファベット (a-z、A-Z)
              日本語 (ひらがな、全角カタカナ、漢字)
          2)名前の2文字目以降に許されている文字
              数字 (半角)
              - (ハイフン)
              . (ピリオド)
          3)許されていない文字
              半角カタカナ
              全角英数字
              全角空白
              xmlという文字の組み合わせ。ただし制御してない。
    ・実態参照
          &amp;
          &lt;
          &gt;
          &quot;
          &apos;
          タグ外のみ。
          本当は小文字のみだが判定しない。
    ・属性と属性値
          <要素名 属性="属性値"> または <要素名 属性='属性値'>
          属性の前には要素名または属性値があるものとする。
          属性値は必ず"または'で囲まれているものとする。
    ・CDATAセクション
          <![CDATA[ ～ ]]>
    ・予約語
          xml

**********************************************************************)
unit XMLFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toTagStart              = Char(50);
  toTagEnd                = Char(51);
  toTagSlash              = Char(52);
  toTagElement            = Char(53);
  toTagAttribute          = Char(54);
  toAmpersand             = Char(55);
  TagBlockElement         = 1;

type
  TXMLFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure AnkProc; override;
    procedure DoubleQuotationProc; override;
    procedure SingleQuotationProc; override;
    procedure DBProc; override;
    procedure DBKanjiProc; override;
    procedure TagStartProc; virtual;
    procedure TagEndProc; virtual;
    procedure SlashProc; virtual;
    procedure ColonProc; virtual;
    procedure TagElementProc; virtual;
    procedure TagAttributeProc; virtual;
    procedure AmpersandProc; virtual;
    procedure UpdateTagToken; virtual;
  public
    function NextToken: Char; override;
    function TokenToFountainColor: TFountainColor; override;
  end;

//------------------------------------------------------------------------------
  TXMLFountain = class(TFountain)
  private
    FTagColor: TFountainColor;
    FTagElement: TFountainColor;
    FTagAttribute: TFountainColor;
    FTagAttributeValue: TFountainColor;
    FAmpersand: TFountainColor;
    FSymbol: TFountainColor;
    FAnk: TFountainColor;
    FInt: TFountainColor;
    FDBCS: TFountainColor;
    procedure SetTagColor(Value: TFountainColor);
    procedure SetTagElement(Value: TFountainColor);
    procedure SetTagAttribute(Value: TFountainColor);
    procedure SetTagAttributeValue(Value: TFountainColor);
    procedure SetAmpersand(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
    procedure SetAnk(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
  protected
    procedure CreateFountainColors; override;
    procedure InitBracketItems; override;
    procedure InitFileExtList; override;
    procedure InitReserveWordList; override;
    function GetParserClass: TFountainParserClass; override;
  public
    destructor Destroy; override;
  published
    property TagColor: TFountainColor read FTagColor write SetTagColor;
    property TagElement: TFountainColor read FTagElement write SetTagElement;
    property TagAttribute: TFountainColor read FTagAttribute write SetTagAttribute;
    property TagAttributeValue: TFountainColor read FTagAttributeValue write SetTagAttributeValue;
    property Ampersand: TFountainColor read FAmpersand write SetAmpersand;
    property Symbol: TFountainColor read FSymbol write SetSymbol;
    property Ank: TFountainColor read FAnk write SetAnk;
    property Int: TFountainColor read FInt write SetInt;
    property DBCS: TFountainColor read FDBCS write SetDBCS;
  end;

procedure Register;

implementation

uses
  heUtils;

procedure Register;
begin
  RegisterComponents('TEditor', [TXMLFountain]);
end;


{ TXMLFountainParser }

procedure TXMLFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['<'] := TagStartProc;
  FMethodTable['>'] := TagEndProc;
  FMethodTable['/'] := SlashProc;
  FMethodTable[':'] := ColonProc;
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['&'] := AmpersandProc;

  // FTokenMethodTable
  FTokenMethodTable[toTagElement] := TagElementProc;
  FTokenMethodTable[toTagAttribute] := TagAttributeProc;
  FTokenMethodTable[toAmpersand] := AmpersandProc;
end;

procedure TXMLFountainParser.AnkProc;
begin
  if FElementIndex = TagBlockElement then
  begin
    FToken := toAnk;
    if FPrevToken in [toTagStart, toTagSlash] then
      TagElementProc
    else
      TagAttributeProc;
  end
  else
    inherited AnkProc;
end;

procedure TXMLFountainParser.DoubleQuotationProc;
begin
  if FElementIndex = TagBlockElement then
    inherited DoubleQuotationProc
  else
    SymbolProc;
end;

procedure TXMLFountainParser.SingleQuotationProc;
begin
  if FElementIndex = TagBlockElement then
    inherited SingleQuotationProc
  else
    SymbolProc;
end;

procedure TXMLFountainParser.DBProc;
var
  IsDBHira, IsDBKana, IsDBSymbol: Boolean;
begin
  IsDBHira   := (FP^ = #$82) and ((FP + 1)^ in [#$9F..#$F1]);
  IsDBKana   := (FP^ = #$83) and ((FP + 1)^ in [#$40..#$96]);
  IsDBSymbol := (FP^ = #$81) and ((FP + 1)^ in [#$5B]);     // 'ー'
  FToken     := toDBSymbol;
  if (FElementIndex = TagBlockElement) and (IsDBHira or IsDBKana or IsDBSymbol) then
  begin
    if FPrevToken in [toTagStart, toTagSlash] then
      TagElementProc
    else
      TagAttributeProc;
  end
  else
    inherited DBProc;
end;

procedure TXMLFountainParser.DBKanjiProc;
begin
  if FElementIndex = TagBlockElement then
  begin
    FToken := toDBKanji;
    if FPrevToken in [toTagStart, toTagSlash] then
      TagElementProc
    else
      TagAttributeProc;
  end
  else
    inherited DBKanjiProc;
end;

procedure TXMLFountainParser.TagStartProc;
begin
  FToken := toTagStart;
  Inc(FP);
  FElementIndex := TagBlockElement;
end;

procedure TXMLFountainParser.TagEndProc;
begin
  FToken := toTagEnd;
  Inc(FP);
  FElementIndex := NormalElementIndex;
end;

procedure TXMLFountainParser.SlashProc;
begin
  if FElementIndex = TagBlockElement then
  begin
    FToken := toTagSlash;
    Inc(FP);
  end
  else
    SymbolProc;
end;

procedure TXMLFountainParser.ColonProc;
begin
  if FElementIndex = TagBlockElement then
  begin
    if FPrevToken in [toTagStart, toTagSlash] then
      TagElementProc
    else
      TagAttributeProc;
  end
  else
    inherited SymbolProc;
end;

procedure TXMLFountainParser.TagElementProc;
var
  IsDBHira, IsDBKana, IsDBSymbol, IsDBKanji: Boolean;
begin
  // 1文字目　
  if (FP^ in ['_', ':', 'A'..'Z', 'a'..'z']) then
  begin
    Inc(FP);
    FToken := toTagElement;
  end
  else
  begin
    IsDBHira  := (FP^ = #$82) and ((FP + 1)^ in [#$9F..#$F1]);
    IsDBKana  := (FP^ = #$83) and ((FP + 1)^ in [#$40..#$96]);
    IsDBKanji := (FP^ in [#$88..#$9F, #$E0..#$FC]) and ((FP + 1)^ in [#$40..#$FF]);
    if IsDBHira or IsDBKana or IsDBKanji then
    begin
      Inc(FP, 2);
      FToken := toTagElement;
    end
    else
    begin
      if FP^ in LeadBytes then
        Inc(FP);
      if FP^ <> #0 then
        Inc(FP);
    end;
  end;
  // 2文字目以降
  if FToken = toTagElement then
  begin
    while not (FP^ in [#0, #10, #13]) do
    begin
      if FP^ in [ '-', '.', '0'..'9', 'A'..'Z', '_', ':', 'a'..'z'] then
        Inc(FP)
      else
      begin
        IsDBHira   := (FP^ = #$82) and ((FP + 1)^ in [#$9F..#$F1]);
        IsDBKana   := (FP^ = #$83) and ((FP + 1)^ in [#$40..#$96]);
        IsDBKanji  := (FP^ in [#$88..#$9F, #$E0..#$FC]) and ((FP + 1)^ in [#$40..#$FF]);
        IsDBSymbol := (FP^ = #$81) and ((FP + 1)^ in [#$5B]);
        if IsDBHira or IsDBKana or IsDBKanji or IsDBSymbol then
          Inc(FP, 2)
        else
          Break;
      end;
    end;
  end;
end;

procedure TXMLFountainParser.TagAttributeProc;
begin
  TagElementProc;
  if FToken = toTagElement then
    FToken := toTagAttribute;
end;

procedure TXMLFountainParser.AmpersandProc;
begin
  if FElementIndex = TagBlockElement then
    SymbolProc
  else
  begin
    FToken := toAmpersand;
    if not FIsStartToken then
      Inc(FP);
    if (IsKeyWord('amp') or
        IsKeyWord('lt') or
        IsKeyWord('gt') or
        IsKeyWord('quot') or
        IsKeyWord('apos')) and (FP^ = ';') then
      Inc(FP)
    else
      inherited AnkProc;
  end;
end;

procedure TXMLFountainParser.UpdateTagToken;
begin
  if (FToken <> toEof) and (FElementIndex = TagBlockElement) then
  begin
    case FPrevToken of
      toTagElement, toSingleQuotation, toDoubleQuotation:
        if FToken = toTagElement then
          FToken := toTagAttribute;
      toTagAttribute:
        if FToken = toTagElement then
          FToken := toTagAttribute;
    end;
  end;
end;

function TXMLFountainParser.NextToken: Char;
begin
  inherited NextToken;
  UpdateTagToken;
  if FToken <> toEof then
    FPrevToken := FToken;
  Result := FToken;
end;

function TXMLFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TXMLFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toReserve:
          Result := Reserve;
        toTagStart, toTagEnd, toTagSlash:
          Result := FTagColor;
        toTagElement:
          Result := FTagElement;
        toTagAttribute:
          Result := FTagAttribute;
        toDoubleQuotation, toSingleQuotation:
          Result := FTagAttributeValue;
        toAmpersand:
          Result := FAmpersand;
        toSymbol:
          Result := FSymbol;
        toAnk, toKanaSymbol, toKana:
          Result := FAnk;
        toInteger, toFloat:
          Result := FInt;
        toDBSymbol, toDBInt, toDBAlph, toDBHira, toDBKana, toDBKanji:
          Result := FDBCS;
      else
          Result := nil;
      end;
end;

//------------------------------------------------------------------------------
{ TXMLFountain }

procedure TXMLFountain.SetTagColor(Value: TFountainColor);
begin
  FTagColor.Assign(Value);
end;

procedure TXMLFountain.SetTagElement(Value: TFountainColor);
begin
  FTagElement.Assign(Value);
end;

procedure TXMLFountain.SetTagAttribute(Value: TFountainColor);
begin
  FTagAttribute.Assign(Value);
end;

procedure TXMLFountain.SetTagAttributeValue(Value: TFountainColor);
begin
  FTagAttributeValue.Assign(Value);
end;

procedure TXMLFountain.SetAmpersand(Value: TFountainColor);
begin
  FAmpersand.Assign(Value);
end;

procedure TXMLFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

procedure TXMLFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TXMLFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TXMLFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TXMLFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FTagColor := CreateFountainColor;
  FTagElement := CreateFountainColor;
  FTagAttribute := CreateFountainColor;
  FTagAttributeValue := CreateFountainColor;
  FAmpersand := CreateFountainColor;
  FSymbol := CreateFountainColor;
  FAnk := CreateFountainColor;
  FInt := CreateFountainColor;
  FDBCS := CreateFountainColor;
end;

procedure TXMLFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '<?';
  Item.RightBracket := '?>';
  Item := Brackets.Add;
  Item.LeftBracket := '<!--';
  Item.RightBracket := '-->';
  Item := Brackets.Add;
  Item.LeftBracket := '<![CDATA[';
  Item.RightBracket := ']]>';
end;

procedure TXMLFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.xml');
  end;
end;

procedure TXMLFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('xml');
  end;
end;

function TXMLFountain.GetParserClass: TFountainParserClass;
begin
  Result := TXMLFountainParser;
end;

destructor TXMLFountain.Destroy;
begin
  FTagColor.Free;
  FTagElement.Free;
  FTagAttribute.Free;
  FTagAttributeValue.Free;
  FAmpersand.Free;
  FSymbol.Free;
  FAnk.Free;
  FInt.Free;
  FDBCS.Free;
  inherited Destroy;
end;

end.

