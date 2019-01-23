(*
  TRegManager ver 1.6

  start  1998/01/30
  update 2001/08/06

  copyright (c) 1998,2001 ñ{ìcèüïF <katsuhiko.honda@nifty.ne.jp>

  usage
  RegManager1['Form1Width'].AsInteger := Form1.Width;
  Edit1.Text := RegManager1['Edit1Text'].AsString;
*)
unit RegMng;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, Registry;

type
  TRegItem = class;
  TRegItems = class;
  TRegManager = class;

  TRegFiler = class
  protected
    FRegItem: TRegItem;
    FRegManager: TRegManager;
    function GetReg: TRegIniFile;
    function GetIni: TIniFile;
    function ReadString(const Section, Ident, Default: String): String; virtual;
    procedure WriteString(const Section, Ident, Value: String); virtual;
    function GetBool: Boolean; virtual;
    procedure SetBool(Value: Boolean); virtual;
    function GetFloat: Extended;
    procedure SetFloat(Value: Extended);
    function GetInteger: Integer; virtual;
    procedure SetInteger(Value: Integer); virtual;
    function GetString: String; virtual;
    procedure SetString(Value: String); virtual;
  public
    constructor Create(RegManager: TRegManager);
    procedure ReadFont(Font: TFont); virtual;
    procedure WriteFont(Font: TFont); virtual;
    procedure ReadStrings(Strings: TStrings); virtual;
    procedure WriteStrings(Strings: TStrings); virtual;
    procedure ReadStream(Stream: TStream); virtual;
    procedure WriteStream(Stream: TStream); virtual;
    procedure ReadComponent(Component: TComponent); virtual;
    procedure WriteComponent(Component: TComponent); virtual;
    procedure DeleteKey(const Section, Ident: String);
    property AsBoolean: Boolean read GetBool write SetBool;
    property AsFloat: Extended read GetFloat write SetFloat;
    property AsInteger: Integer read GetInteger write SetInteger;
    property AsString: String read GetString write SetString;
    property RegItem: TRegItem read FRegItem write FRegItem;
  end;

  TRegItem = class(TCollectionItem)
  protected
    FName: String;
    FSection: String;
    FIdent: String;
    FDefaultValue: String;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Name: String read FName write FName;
    property Section: String read FSection write FSection;
    property Ident: String read FIdent write FIdent;
    property DefaultValue: String read FDefaultValue write FDefaultValue;
  end;

  TRegItems = class(TCollection)
  protected
    function GetItem(Index: Integer): TRegItem; virtual;
    procedure SetItem(Index: Integer; Value: TRegItem); virtual;
    function GetName(aName: String): TRegItem; virtual;
  public
    constructor Create;
    function Add: TRegItem;
    property Items[Index: Integer]: TRegItem read GetItem write SetItem; default;
    property Names[aName: String]: TRegItem read GetName;
  end;

  TRegType = (rtReg, rtIni);

  TRegManager = class(TComponent)
  protected
    FIniFileName: String;
    FRegDir: String;
    FRegItems: TRegItems;
    FRegType: TRegType;
    FRegFiler: TRegFiler;
    function CreateRegFiler: TRegFiler; virtual;
    function GetRegFiler(aName: String): TRegFiler;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Filers[aName: String]: TRegFiler read GetRegFiler; default;
  published
    property IniFileName: String read FIniFileName write FIniFileName;
    property RegDir: String read FRegDir write FRegDir;
    property RegItems: TRegItems read FRegItems write FRegItems;
    property RegType: TRegType read FRegType write FRegType;
  end;

implementation

uses
  HStreamUtils;

  
{ TRegFiler }

constructor TRegFiler.Create(RegManager: TRegManager);
begin
  FRegManager := RegManager;
end;

function TRegFiler.GetReg: TRegIniFile;
begin
  Result := nil;
  if (FRegManager.RegType = rtReg) and (FRegManager.RegDir <> '') then
    Result := TRegIniFile.Create(FRegManager.RegDir)
  else
    MessageDlg('can not create Registry object.', mtError, [mbOk], 0);
end;

function TRegFiler.GetIni: TIniFile;
begin
  Result := nil;
  if (FRegManager.RegType = rtIni) and (FRegManager.IniFileName <> '') then
    Result := TIniFile.Create(FRegManager.IniFileName)
  else
    MessageDlg('can not create Inifile object.', mtError, [mbOk], 0);
end;

function TRegFiler.ReadString(const Section, Ident, Default: String): String;
var
  Ini: TIniFile;
  Reg: TRegIniFile;
begin
  Result := Default;
  if (Section = '') or (Ident = '') then
    Exit;
  case FRegManager.RegType of
    rtReg:
      begin
        Reg := GetReg;
        if Reg <> nil then
        try
          Result := Reg.ReadString(Section, Ident, Default);
        finally
          Reg.Free;
        end;
      end;
    rtIni:
      begin
        Ini := GetIni;
        if Ini <> nil then
        try
          Result := Ini.ReadString(Section, Ident, Default);
        finally
          Ini.Free;
        end;
      end;
  end;
end;

procedure TRegFiler.WriteString(const Section, Ident, Value: String);
var
  Ini: TIniFile;
  Reg: TRegIniFile;
begin
  if (Section = '') or (Ident = '') then
    Exit;
  case FRegManager.RegType of
    rtReg:
      begin
        Reg := GetReg;
        if Reg <> nil then
        try
          Reg.WriteString(Section, Ident, Value);
        finally
          Reg.Free;
        end;
      end;
    rtIni:
      begin
        Ini := GetIni;
        if Ini <> nil then
        try
          Ini.WriteString(Section, Ident, Value);
        finally
          Ini.Free;
        end;
      end;
  end;
end;

procedure TRegFiler.DeleteKey(const Section, Ident: String);
var
  Ini: TIniFile;
  Reg: TRegIniFile;
begin
  if (Section = '') or (Ident = '') then
    Exit;
  case FRegManager.RegType of
    rtReg:
      begin
        Reg := GetReg;
        if Reg <> nil then
        try
          Reg.DeleteKey(Section, Ident);
        finally
          Reg.Free;
        end;
      end;
    rtIni:
      begin
        Ini := GetIni;
        if Ini <> nil then
        try
          Ini.DeleteKey(Section, Ident);
        finally
          Ini.Free;
        end;
      end;
  end;
end;

function TRegFiler.GetBool: Boolean;
var
  S: String;
begin
  Result := False;
  if FRegItem <> nil then
    with FRegItem do
    begin
      S := AnsiUpperCase(DefaultValue);
      if (S = '1') or (S = 'TRUE') or (S = 'YES') then
        S := '1'
      else
        S := '0';
      Result := Boolean(StrToIntDef(ReadString(Section, Ident, S), 0));
    end;
end;

procedure TRegFiler.SetBool(Value: Boolean);
begin
  if FRegItem <> nil then
    with FRegItem do
      WriteString(Section, Ident, IntToStr(Ord(Value)));
end;

function TRegFiler.GetFloat: Extended;
begin
  Result := 0;
  if FRegItem <> nil then
    with FRegItem do
      Result := StrToFloat(ReadString(Section, Ident, DefaultValue));
end;

procedure TRegFiler.SetFloat(Value: Extended);
begin
  if FRegItem <> nil then
    with FRegItem do
      WriteString(Section, Ident, FloatToStr(Value));
end;

function TRegFiler.GetInteger: Integer;
begin
  Result := 0;
  if FRegItem <> nil then
    with FRegItem do
      Result := StrToIntDef(ReadString(Section, Ident, DefaultValue), 0);
end;

procedure TRegFiler.SetInteger(Value: Integer);
begin
  if FRegItem <> nil then
    with FRegItem do
      WriteString(Section, Ident, IntToStr(Value));
end;

function TRegFiler.GetString: String;
begin
  Result := '';
  if FRegItem <> nil then
  begin
    with FRegItem do
      Result := ReadString(Section, Ident, DefaultValue);
  end;
end;

procedure TRegFiler.SetString(Value: String);
begin
  if FRegItem <> nil then
    with FRegItem do
      WriteString(Section, Ident, Value);
end;

procedure TRegFiler.ReadFont(Font: TFont);
var
  FontName, FontSize, FontColor, FontStyle: String;
  {$IFDEF COMP3_UP}
  FontCharset: String;
  {$ENDIF}
begin
  if (Font <> nil) and (FRegItem <> nil) then
  begin
    // use as default value
    FontName := Font.Name;
    FontSize := IntToStr(Font.Size);
    FontColor := ColorToString(Font.Color);
    FontStyle := IntToStr(Byte(Font.Style));
    {$IFDEF COMP3_UP}
    FontCharset := IntToStr(Byte(Font.Charset));
    {$ENDIF}
    with FRegItem do
    begin
      Font.Name := ReadString(Section, Ident + '_FontName', FontName);
      Font.Size := StrToIntDef(ReadString(Section, Ident + '_FontSize', FontSize), Font.Size);
      Font.Color := StringToColor(ReadString(Section, Ident + '_FontColor', FontColor));
      Font.Style := TFontStyles(Byte(StrToIntDef(ReadString(Section, Ident + '_FontStyle', FontStyle), 0)));
      {$IFDEF COMP3_UP}
      Font.Charset := TFontCharset(Byte(StrToIntDef(ReadString(Section, Ident + '_FontCharset', FontCharset), 0)));
      {$ENDIF}
    end;
  end;
end;

procedure TRegFiler.WriteFont(Font: TFont);
var
  FontName, FontSize, FontColor, FontStyle: String;
  {$IFDEF COMP3_UP}
  FontCharset: String;
  {$ENDIF}
begin
  if (Font <> nil) and (FRegItem <> nil) then
  begin
    FontName := Font.Name;
    FontSize := IntToStr(Font.Size);
    FontColor := ColorToString(Font.Color);
    FontStyle := IntToStr(Byte(Font.Style));
    {$IFDEF COMP3_UP}
    FontCharset := IntToStr(Byte(Font.Charset));
    {$ENDIF}
    with FRegItem do
    begin
      WriteString(Section, Ident + '_FontName', FontName);
      WriteString(Section, Ident + '_FontSize', FontSize);
      WriteString(Section, Ident + '_FontColor', FontColor);
      WriteString(Section, Ident + '_FontStyle', FontStyle);
      {$IFDEF COMP3_UP}
      WriteString(Section, Ident + '_FontCharset', FontCharset);
      {$ENDIF}
    end;
  end;
end;

procedure TRegFiler.ReadStrings(Strings: TStrings);
var
  Count, I: Integer;
begin
  if (Strings <> nil) and (FRegItem <> nil) then
  begin
    Strings.BeginUpdate;
    try
      Strings.Clear;
      with FRegItem do
      begin
        Count := StrToIntDef(ReadString(Section, Ident + '_ItemCount', '0'), 0);
        for I := 0 to Count - 1 do
          Strings.Add(ReadString(Section, Ident + '_Item' + IntToStr(I), ''));
      end;
    finally
      Strings.EndUpdate;
    end;
  end;
end;

procedure TRegFiler.WriteStrings(Strings: TStrings);
var
  Count, I: Integer;
begin
  if (Strings <> nil) and (FRegItem <> nil) then
  with FRegItem do
  begin
    Count := StrToIntDef(ReadString(Section, Ident + '_ItemCount', '0'), 0);
    if Count > Strings.Count then
    begin
      for I := Count - 1 downto Strings.Count do
        DeleteKey(Section, Ident + '_Item' + IntToStr(I));
      if Strings.Count = 0 then
        DeleteKey(Section, Ident + '_ItemCount');
    end;
    if Strings.Count > 0 then
    begin
      WriteString(Section, Ident + '_ItemCount', IntToStr(Strings.Count));
      for I := 0 to Strings.Count - 1 do
        WriteString(Section, Ident + '_Item' + IntToStr(I), Strings[I]);
    end;
  end;
end;

procedure TRegFiler.ReadStream(Stream: TStream);
begin
  if (Stream <> nil) and (FRegItem <> nil) then
  case FRegManager.RegType of
    rtReg: RegReadStream(Stream, FRegManager.RegDir,
                           FRegItem.Section, FRegItem.Ident);
    rtIni: IniReadStream(Stream, FRegManager.IniFileName,
                           FRegItem.Section, FRegItem.Ident);
  end;
end;

procedure TRegFiler.WriteStream(Stream: TStream);
begin
  if (Stream <> nil) and (FRegItem <> nil) then
  case FRegManager.RegType of
    rtReg: RegWriteStream(Stream, FRegManager.RegDir,
                           FRegItem.Section, FRegItem.Ident);
    rtIni: IniWriteStream(Stream, FRegManager.IniFileName,
                           FRegItem.Section, FRegItem.Ident);
  end;
end;

procedure TRegFiler.WriteComponent(Component: TComponent);
var
  Ms: TMemoryStream;
begin
  if (Component <> nil) and (FRegItem <> nil) and
     not (Component is TForm) then
  begin
    Ms := TMemoryStream.Create;
    try
      ComponentToStream(Component, Ms);
      Ms.Position := 0;
      WriteStream(Ms);
    finally
      Ms.Free;
    end;
  end;
end;

procedure TRegFiler.ReadComponent(Component: TComponent);
var
  Ms: TMemoryStream;
begin
  if (Component <> nil) and (FRegItem <> nil) then
  begin
    Ms := TMemoryStream.Create;
    try
      ReadStream(Ms);
      Ms.Position := 0;
      if Ms.Size > 0 then
        StreamToComponent(Ms, Component);
    finally
      Ms.Free;
    end;
  end;
end;


{ TRegItem }

procedure TRegItem.Assign(Source: TPersistent);
begin
  if Source is TRegItem then
  begin
    Name := TRegItem(Source).Name;
    Section := TRegItem(Source).Section;
    Ident := TRegItem(Source).Ident;
    DefaultValue := TRegItem(Source).DefaultValue;
    Exit;
  end;
  inherited Assign(Source);
end;


{ TRegItems }

constructor TRegItems.Create;
begin
  inherited Create(TRegItem);
end;

function TRegItems.Add: TRegItem;
begin
  Result := TRegItem(inherited Add);
end;

function TRegItems.GetItem(Index: Integer): TRegItem;
begin
  Result := TRegItem(inherited GetItem(Index));
end;

procedure TRegItems.SetItem(Index: Integer; Value: TRegItem);
begin
  inherited SetItem(Index, Value);
end;

function TRegItems.GetName(aName: String): TRegItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiCompareText(Items[I].Name, aName) = 0 then
    begin
      Result := Items[I];
      Exit;
    end;
end;


{ TRegManager }

constructor TRegManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRegFiler := CreateRegFiler;
  FRegItems := TRegItems.Create;
end;

destructor TRegManager.Destroy;
begin
  FRegItems.Free;
  FRegFiler.Free;
  inherited Destroy;
end;

function TRegManager.CreateRegFiler: TRegFiler;
begin
  Result := TRegFiler.Create(Self);
end;

function TRegManager.GetRegFiler(aName: String): TRegFiler;
var
  Item: TRegItem;
begin
  Item := FRegItems.Names[aName];
  if Item = nil then
    MessageDlg('['' ' + aName + ' ''] is invalid.', mtError,
      [mbOk], 0);
  // return FRegFiler with FRegItem that is nil or not nil.
  FRegFiler.FRegItem := Item;
  Result := FRegFiler;
end;

end.

