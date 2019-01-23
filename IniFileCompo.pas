unit IniFileCompo;

// IniFileCompo ver.2.2

interface

uses
  Windows, Messages, SysUtils, Classes, IniFiles, Graphics, Forms, Controls,
  ShlObj, ActiveX, ShellAPI;

type
  // ############################################################ �f�[�^�^�̒�`
  TDefaultFolder = (dfAppData, dfApplication, dfUser, dfWindows);
  // ###################################################### �R���|�[�l���g�̒�`
  TIniFileCompo = class(TComponent)
  private
    { Private �錾 }
    // ================ �����g�p�t�B�[���h
    FAppFolder: string;
    FAppName: string;
    FDefaultFileName: string;
    FFolder: string;
    FIni: TMemIniFile;
    // ================ �v���p�e�B�t�B�[���h
    FAutoUpdate: Boolean;
    FDefaultFolder: TDefaultFolder;
    FFileName: string;
    FIniName: string;
    FOnLoad: TNotifyEvent;
    FOnUpdate: TNotifyEvent;
    FUpdateAtOnce: Boolean;
    // ================ �������\�b�h
    function GetPath(const FolderType: TDefaultFolder): string;
    procedure UpdateIni;
    // ================ �v���p�e�B�A�N�Z�X
    procedure SetDefaultFolder(const Value: TDefaultFolder);
    function GetCaseSensitive: Boolean;
    procedure SetCaseSensitive(const Value: Boolean);
    procedure SetFileName(const Value: string);
  protected
    { Protected �錾 }
    // ================ �C�x���g���\�b�h
    procedure DoUpdate; virtual;
    procedure Load; dynamic;
  public
    { Public �錾 }
    // ********************************************** �v���p�e�B(public) ***
    property FullName: string read FIniName;
    // ================ ���\�b�h
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear(const FileUpdate: Boolean);
    procedure Copy(const IniFileName: string);
    procedure DeleteItem(const Section, Item: string);
    procedure EraseSection(const Section: string);
    function ItemExists(const Section, Item: string): Boolean;
    function ReadBool(const Section, Item: string; Default: Boolean): Boolean;
    function ReadCardinal(const Section, Item: string;
        const Default: Cardinal): Cardinal;
    function ReadColor(const Section, Item: string; Default: TColor): TColor;
    function ReadCurr(const Section, Item: string; Default: Currency): Currency;
    function ReadDate(const Section, Item: string; const Default: TDate): TDate;
    function ReadDateTime(const Section, Item: string;
        Default: TDateTime): TDateTime;
    function ReadFloat(const Section, Item: string; Default: Extended): Extended;
    procedure ReadFont(const Section, Item: string; Font: TFont);
    procedure ReadForm(const Section, Item: string; Form: TForm);
    procedure ReadFormEx(const Section, Item: string; Form: TForm);
    function ReadInt(const Section, Item: string; Default: Integer): Integer;
    function ReadInt64(const Section, Item: string; Default: Int64): Int64;
    procedure ReadList(const Section, Item: string; List: TStrings);
    procedure ReadPos(const Section, Item: string; Control: TControl);
    function ReadRect(const Section, Item: string; Default: TRect): TRect;
    procedure ReadSection(const Section: string; List: TStrings);
    procedure ReadSectionName(List: TStrings);
    procedure ReadSize(const Section, Item: string; Control: TControl);
    procedure ReadSizePos(const Section, Item: string; Control: TControl);
    function ReadStr(const Section, Item, Default: string): string;
    function ReadStrWithDecode(const Section, Item, Password,
        Default: string): string;
    function ReadTime(const Section, Item: string; const Default: TTime): TTime;
    procedure ReadWinPos(const Section, Item: string; Form: TForm);
    procedure ReadWinSize(const Section, Item: string; Form: TForm);
    procedure ReadWinSizeEx(const Section, Item: string; Form: TForm);
    procedure Reload;
    procedure Rename(const NewFileName: string);
    function SectionExists(const Section: string): Boolean;
    procedure Update;
    procedure WriteBool(const Section, Item: string; Value: Boolean);
    procedure WriteCardinal(const Section, Item: string; const Value: Cardinal);
    procedure WriteColor(const Section, Item: string; Value: TColor);
    procedure WriteCurr(const Section, Item: string; Value: Currency);
    procedure WriteDate(const Section, Item: string; const Value: TDate);
    procedure WriteDateTime(const Section, Item: string; Value: TDateTime);
    procedure WriteFloat(const Section, Item: string; Value: Extended);
    procedure WriteFont(const Section, Item: string; Font: TFont);
    procedure WriteForm(const Section, Item: string; Form: TForm);
    procedure WriteInt(const Section, Item: string; Value: Integer);
    procedure WriteInt64(const Section, Item: string; Value: Int64);
    procedure WriteList(const Section, Item: string; List: TStrings);
    procedure WriteRect(const Section, Item: string; Value: TRect);
    procedure WriteSizePos(const Section, Item: string; Control: TControl);
    procedure WriteStr(const Section, Item, Value: string);
    procedure WriteStrWithEncode(const Section, Item, Password, Value: string);
    procedure WriteTime(const Section, Item: string; const Value: TTime);
  published
    { Published �錾 }
    // ================ �v���p�e�B
    // ------------ �V�K
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate default True;
    property CaseSensitive: Boolean read GetCaseSensitive
        write SetCaseSensitive;
    property DefaultFolder: TDefaultFolder read FDefaultFolder
        write SetDefaultFolder default dfApplication;
    property FileName: string read FFileName write SetFileName;
    property UpdateAtOnce: Boolean read FUpdateAtOnce
        write FUpdateAtOnce default False;
    // ================ �C�x���g
    property OnLoad: TNotifyEvent read FOnLoad write FOnLoad;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

procedure Register;

implementation

const
  PassStr = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789_!#@./:;+-,=\';

procedure Register;
begin
  RegisterComponents('Samples', [TIniFileCompo]);
end;

{ TIniFileCompo }

// ########################################## Clear���\�b�h[INI�t�@�C���̃N���A]
procedure TIniFileCompo.Clear(const FileUpdate: Boolean);
begin
  FIni.Clear;
  if FileUpdate then Update;
end;

// ########################################### Copy���\�b�h[INI�t�@�C���̃R�s�[]
procedure TIniFileCompo.Copy(const IniFileName: string);
begin
  FIni.Rename(IniFileName, False);
  FIni.UpdateFile;
  FIni.Rename(FIniName, True);
end;

// ############################################## �R���X�g���N�^[Create���\�b�h]
constructor TIniFileCompo.Create(AOwner: TComponent);
begin
  inherited;
  // �t�B�[���h������
  FAppFolder := ExtractFilePath(Application.ExeName);
  FAppName := ChangeFileExt(ExtractFileName(Application.ExeName), '');
  FFolder := FAppFolder;
  FDefaultFolder := dfApplication;
  FFileName := '';
  FDefaultFileName := FAppName + '.ini';
  FAppName := FAppName + PathDelim;
  FIniName := FFolder + FDefaultFileName;
  FUpdateAtOnce := False;
  FAutoUpdate := True;
  // �I�u�W�F�N�g����
  FIni := TMemIniFile.Create(FIniName);
  FIni.CaseSensitive := False;
end;

// ################################ �w��A�C�e���̍폜[DeleteItem���\�b�h] #####
procedure TIniFileCompo.DeleteItem(const Section, Item: string);
var
  Count: Integer;
  Lp: Integer;
  S: string;
begin
  S := FIni.ReadString(Section, Item, '');
  FIni.DeleteKey(Section, Item);
  if SameText(S, 'FORM') then
  begin
    FIni.DeleteKey(Section, Item + '.flags');
    FIni.DeleteKey(Section, Item + '.show');
    FIni.DeleteKey(Section, Item + '.state');
    FIni.DeleteKey(Section, Item + '.maxx');
    FIni.DeleteKey(Section, Item + '.maxy');
    FIni.DeleteKey(Section, Item + '.left');
    FIni.DeleteKey(Section, Item + '.top');
    FIni.DeleteKey(Section, Item + '.width');
    FIni.DeleteKey(Section, Item + '.height');
    FIni.DeleteKey(Section, Item + '.cwidth');
    FIni.DeleteKey(Section, Item + '.cheight');
  end;
  if SameText(S, 'RECT') then
  begin
    FIni.DeleteKey(Section, Item + '.left');
    FIni.DeleteKey(Section, Item + '.top');
    FIni.DeleteKey(Section, Item + '.right');
    FIni.DeleteKey(Section, Item + '.bottom');
  end;
  if SameText(S, 'LIST') then
  begin
    Count := FIni.ReadInteger(Section, Item + '.count', 0);
    FIni.DeleteKey(Section, Item + '.count');
    for Lp := 0 to Count - 1 do
      FIni.DeleteKey(Section, Item + '.' + IntToStr(Lp));
  end;
  if SameText(S, 'BOUNDS') then
  begin
    FIni.DeleteKey(Section, Item + '.left');
    FIni.DeleteKey(Section, Item + '.top');
    FIni.DeleteKey(Section, Item + '.width');
    FIni.DeleteKey(Section, Item + '.height');
  end;
  UpdateIni;
end;

// ############################################### �f�X�g���N�^[Destroy���\�b�h]
destructor TIniFileCompo.Destroy;
begin
  if FAutoUpdate then FIni.UpdateFile;
  // �I�u�W�F�N�g�j��
  FIni.Free;
  inherited;
end;

// ################################## DoUpdate�C�x���g���\�b�h[OnUpdate�C�x���g]
procedure TIniFileCompo.DoUpdate;
begin
  if Assigned(FOnUpdate) then FOnUpdate(Self);
end;

// ###################################### EraseSection���\�b�h[�Z�N�V�����̏���]
procedure TIniFileCompo.EraseSection(const Section: string);
begin
  FIni.EraseSection(Section);
end;

// ########################### CaseSensitive�v���p�e�B�ǂݍ���[GetCaseSensitive]
function TIniFileCompo.GetCaseSensitive: Boolean;
begin
  Result := FIni.CaseSensitive;
end;

// #################################### ItemExists���\�b�h[�A�C�e�������݂��邩]
function TIniFileCompo.ItemExists(const Section, Item: string): Boolean;
begin
  Result := FIni.ValueExists(Section, Item);
end;

// ########################################## ReadBool���\�b�h[�_���l�̓ǂݍ���]
function TIniFileCompo.ReadBool(const Section, Item: string;
  Default: Boolean): Boolean;
begin
  Result := FIni.ReadBool(Section, Item, Default);
end;

// ######################################### ReadColor���\�b�h[TColor�̓ǂݍ���]
function TIniFileCompo.ReadColor(const Section, Item: string;
  Default: TColor): TColor;
var
  C: LongInt;
  H: string;
begin
  // TColor��16�i������œǂݏ���
  C := Default;
  H := '$' + IntToHex(C, 8);
  H := FIni.ReadString(Section, Item, H);
  if Length(H) >= 1 then
  begin
    if H[1] = '$' then
      Result := StrToIntDef(H, Default)
    else
      Result := StrToIntDef('$' + H, Default);
  end
  else
    Result := Default;
end;

// ###################################### ReadCurr���\�b�h[Currency�^�̓ǂݍ���]
function TIniFileCompo.ReadCurr(const Section, Item: string;
  Default: Currency): Currency;
var
  S: string;
  C: Currency;
begin
  S := CurrToStr(Default);
  S := FIni.ReadString(Section, Item, S);
  try
    C := StrToCurr(S);
  except
    C := Default;
  end;
  Result := C;
end;

// ########################################### ReadDateTime[TDateTime�̓ǂݍ���]
function TIniFileCompo.ReadDateTime(const Section, Item: string;
  Default: TDateTime): TDateTime;
begin
  Result := FIni.ReadDateTime(Section, Item, Default);
end;

// ################### �f�R�[�h����������̓ǂݍ���[ReadDecodeStr���\�b�h] #####
function TIniFileCompo.ReadStrWithDecode(const Section, Item,
    Password, Default: string): string;
var
  Ch: Integer;                 // �ϊ��p
  Cp: Integer;
  DecodeStr: string;           // �f�R�[�h������
  KeyCp: Integer;
  KeyValue: array of Integer;  // �f�R�[�h�L�[
  Len: Integer;                // ����
  Source: string;              // �Í�������
  SS: string;                  // ���ꕶ��
  Lp: Integer;
begin
  if FIni.ValueExists(Section, Item) then
  begin
    Source := FIni.ReadString(Section, Item, '');
    Len := Length(PassStr);
    // ********************************************************** �L�[�̍쐬
    SetLength(KeyValue, Length(Password));
    for Lp := 1 to Length(Password) do
      KeyValue[Lp - 1] := Pos(Password[Lp], PassStr);
    // ************************************************************** ������
    DecodeStr := '';
    KeyCp := 0;
    Lp := 1;
    // ******************************************************** �f�R�[�h����
    while Lp <= Length(Source) do
    begin
      if Source[Lp] = '$' then
      begin
        SS := '';
        Cp := 1;
        while Cp <= 2 do
        begin
          Inc(Lp);
          Ch := Pos(Source[Lp], PassStr) - KeyValue[KeyCp] - 1;
          if Ch <= 0 then Ch := Ch + Len;
          SS := SS + PassStr[Ch];
          Inc(Cp);
        end;
        DecodeStr := DecodeStr + Chr(Byte(StrToIntDef('$' + SS, Ord('*'))));
      end
      else
      begin
        Ch := Pos(Source[Lp], PassStr) - KeyValue[KeyCp] - 1;
        if Ch <= 0 then Ch := Ch + Len;
        DecodeStr := DecodeStr + PassStr[Ch];
      end;
      // ******************************************************** ���̕�����
      Inc(KeyCp);
      if KeyCp >= Length(KeyValue) then KeyCp := 0;
      Inc(Lp);
    end;
    Result := DecodeStr;
  end
  else
    Result := Default;
end;

// ######################################### ReadFloat���\�b�h[�����^�̓ǂݍ���]
function TIniFileCompo.ReadFloat(const Section, Item: string;
  Default: Extended): Extended;
var
  S: string;
  R: Extended;
begin
  // �����^�͕�����Ƃ��ĕۑ�����
  S := FloatToStr(Default);
  S := FIni.ReadString(Section, Item, S);
  try
    R := StrToFloat(S);
  except
    R := Default;
  end;
  Result := R;
end;

// ########################################### ReadFont���\�b�h[TFont�̓ǂݍ���]
procedure TIniFileCompo.ReadFont(const Section, Item: string; Font: TFont);
var
  Charset: Byte;
  Pitch: SmallInt;
  ItemName: string;
begin
  // �L�����N�^�Z�b�g
  Charset := Font.Charset;
  ItemName := Item + '.charset';
  Font.Charset := Byte(FIni.ReadInteger(Section, ItemName, Charset));
  // �J���[
  ItemName := Item + '.color';
  Font.Color := ReadColor(Section, ItemName, Font.Color);
  // Name
  ItemName := Item + '.name';
  Font.Name := FIni.ReadString(Section, ItemName, Font.Name);
  // Pitch
  ItemName := Item + '.pitch';
  Pitch := FIni.ReadInteger(Section, ItemName, Ord(Font.Pitch));
  case Pitch of
    Ord(fpDefault):  Font.Pitch := fpDefault;
    Ord(fpVariable): Font.Pitch := fpVariable;
    Ord(fpFixed):    Font.Pitch := fpFixed;
  end;
  // Size
  ItemName := Item + '.size';
  Font.Size := FIni.ReadInteger(Section, ItemName, Font.Size);
  // �X�^�C��
  // bold
  ItemName := Item + '.bold';
  if FIni.ReadBool(Section,ItemName, fsBold in Font.Style) then
    Font.Style := Font.Style + [fsBold]
  else
    Font.Style := Font.Style - [fsBold];
  // italic
  ItemName := Item + '.italic';
  if FIni.ReadBool(Section, ItemName, fsItalic in Font.Style) then
    Font.Style := Font.Style + [fsItalic]
  else
    Font.Style := Font.Style - [fsItalic];
  // Underline
  ItemName := Item + '.underline';
  if FIni.ReadBool(Section, ItemName, fsUnderline in Font.Style) then
    Font.Style := Font.Style + [fsUnderline]
  else
    Font.Style := Font.Style - [fsUnderline];
  // StrikeOut
  ItemName := Item + '.strikeout';
  if FIni.ReadBool(Section, ItemName, fsStrikeOut in Font.Style) then
    Font.Style := Font.Style + [fsStrikeOut]
  else
    Font.Style := Font.Style - [fsStrikeOut];
end;

// ######################################## ReadForm���\�b�h[�t�H�[���̓ǂݍ���]
procedure TIniFileCompo.ReadForm(const Section, Item: string; Form: TForm);
var
  State: Integer;
  Wp: TWindowPlacement;
begin
  // �f�t�H���g�擾
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // �t�H�[���̓ǂݍ���
  Wp.flags := FIni.ReadInteger(Section, Item + '.flags', Wp.flags);
  with Wp do
  begin
    ptMaxPosition.X := FIni.ReadInteger(Section, Item + '.maxx',
                                        ptMaxPosition.X);
    ptMaxPosition.Y := FIni.ReadInteger(Section, Item + '.maxy',
                                        ptMaxPosition.Y);
    with rcNormalPosition do
    begin
      Left := FIni.ReadInteger(Section, Item + '.left', Left);
      Top := FIni.ReadInteger(Section, Item + '.top', Top);
      Right := FIni.ReadInteger(Section, Item + '.width', Right);
      Bottom := FIni.ReadInteger(Section, Item + '.height', Bottom);
    end;
    Wp.showCmd := FIni.ReadInteger(Section, Item + '.show', Wp.showCmd);
    if not Form.Showing then
    begin
      Wp.showCmd := SW_HIDE;
      SetWindowPlacement(Form.Handle, @Wp);
      State := FIni.ReadInteger(Section, Item + '.state', Ord(wsNormal));
      case State of
        Ord(wsNormal)   : Form.WindowState := wsNormal;
        Ord(wsMaximized): Form.WindowState := wsMaximized;
        else
          Form.WindowState := wsNormal;
      end;
    end
    else
      SetWindowPlacement(Form.Handle, @Wp);
  end;
end;

// ############################################# ReadInt���\�b�h[�����̓ǂݍ���]
function TIniFileCompo.ReadInt(const Section, Item: string;
  Default: Integer): Integer;
begin
  Result := FIni.ReadInteger(Section, Item, Default);
end;

// ########################################## ReadInt64���\�b�h[Int64�̓ǂݍ���]
function TIniFileCompo.ReadInt64(const Section, Item: string;
  Default: Int64): Int64;
begin
  Result := StrToInt(FIni.ReadString(Section, Item, IntToStr(Default)));
end;

// #################################### ReadList���\�b�h[�����񃊃X�g�̓ǂݍ���]
procedure TIniFileCompo.ReadList(const Section, Item: string;
  List: TStrings);
var
  Lp, ItemCount: Integer;
  ItemName: string;
begin
  ItemName := Item + '.count';
  ItemCount := FIni.ReadInteger(Section, ItemName, 0);
  List.Clear;
  for Lp := 0 to ItemCount - 1 do begin
    ItemName := Item + '.' + IntToStr(Lp);
    List.Add(FIni.ReadString(Section, ItemName, ''));
  end;
end;

// ################### ReadSection���\�b�h[�Z�N�V�������̃A�C�e�����X�g�ǂݍ���]
procedure TIniFileCompo.ReadSection(const Section: string; List: TStrings);
begin
  FIni.ReadSection(Section, List);
end;

// ######################### ReadSectionName���\�b�h[�Z�N�V�������X�g�̓ǂݍ���]
procedure TIniFileCompo.ReadSectionName(List: TStrings);
begin
  FIni.ReadSections(List);
end;

// ################### ReadSizePos���\�b�h[�R���g���[���̈ʒu�ƃT�C�Y�̓ǂݍ���]
procedure TIniFileCompo.ReadSizePos(const Section, Item: string;
  Control: TControl);
var
  AWidth, AHeight, ALeft, ATop: Integer;
begin
  ALeft := FIni.ReadInteger(Section, Item + '.left', Control.Left);
  ATop := FIni.ReadInteger(Section, Item + '.top', Control.Top);
  AWidth := FIni.ReadInteger(Section, Item + '.width', Control.Width);
  AHeight := FIni.ReadInteger(Section, Item + '.height', Control.Height);
  Control.SetBounds(ALeft, ATop, AWidth, AHeight);
end;

// ########################################### ReadStr���\�b�h[������̓ǂݍ���]
function TIniFileCompo.ReadStr(const Section, Item,
  Default: string): string;
begin
  Result := FIni.ReadString(Section, Item, Default);
end;

// ################################## ReadWinPos���\�b�h[�t�H�[���ʒu�̓ǂݍ���]
procedure TIniFileCompo.ReadWinPos(const Section, Item: string;
  Form: TForm);
begin
  // �ʒu�̓ǂݍ���
  Form.Left := FIni.ReadInteger(Section, Item + '.left', Form.Left);
  Form.Top := FIni.ReadInteger(Section, Item + '.top', Form.Top);
end;

// ############################### ReadWinSize���\�b�h[�t�H�[���T�C�Y�̓ǂݍ���]
procedure TIniFileCompo.ReadWinSize(const Section, Item: string;
  Form: TForm);
var
  ARect: TRect;
  State: Integer;
  Wp: TWindowPlacement;
begin
  // *************************************************************** ���� **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // *************************************************************** �擾 **
  with Wp do
  begin
    flags := FIni.ReadInteger(Section, Item + '.flags', flags);
    ptMaxPosition.X := FIni.ReadInteger(Section, Item + '.maxx',
        ptMaxPosition.X);
    ptMaxPosition.Y := FIni.ReadInteger(Section, Item + '.maxy',
        ptMaxPosition.Y);
    with rcNormalPosition do
    begin
      ARect.Left := FIni.ReadInteger(Section, Item + '.left', Left);
      ARect.Top := FIni.ReadInteger(Section, Item + '.top', Top);
      ARect.Right := FIni.ReadInteger(Section, Item + '.width', Right);
      ARect.Bottom := FIni.ReadInteger(Section, Item + '.height', Bottom);
      Right := Left + (ARect.Right - ARect.Left);
      Bottom := Top + (ARect.Bottom - ARect.Top);
    end;
    showCmd := FIni.ReadInteger(Section, Item + '.show', showCmd);
    if not Form.Showing then
    begin
      showCmd := SW_HIDE;
      SetWindowPlacement(Form.Handle, @Wp);
      State := FIni.ReadInteger(Section, Item + '.state', Ord(wsNormal));
      case State of
        Ord(wsNormal)   : Form.WindowState := wsNormal;
        Ord(wsMaximized): Form.WindowState := wsMaximized;
        else
          Form.WindowState := wsNormal;
      end;
    end
    else
      SetWindowPlacement(Form.Handle, @Wp);
  end;
end;

// ################################### Reload���\�b�h[INI�t�@�C���̍ēǍ��葱��]
procedure TIniFileCompo.Reload;
var
  Num: Integer;
  TmpFile: string;
begin
  // ��������ʂ̃t�@�C���Ɋ֘A�Â�
  TmpFile := ChangeFileExt(FIniName, '') + '_';
  Num := 1;
  while FileExists(TmpFile + IntToStr(Num) + ExtractFileExt(FIniName)) do
    Inc(Num);
  TmpFile := TmpFile + IntToStr(Num) + ExtractFileExt(FIniName);
  FIni.Rename(TmpFile, False);
  FIni.Clear;
  FIni.Rename(FIniName, True);
  if FileExists(TmpFile) then DeleteFile(TmpFile);
  Load;
end;

// ######################################### Rename���\�b�h[INI�t�@�C�����̕ύX]
procedure TIniFileCompo.Rename(const NewFileName: string);
var
  F: string;
  isNewFolder: Boolean;
begin
  F := ExtractFilePath(NewFileName);
  if not DirectoryExists(F) then ForceDirectories(F);
  F := ExtractFileName(NewFileName);
  if F = NewFileName then begin
    F := FFolder + F;
    isNewFolder := False;
  end else begin
    F := NewFileName;
    isNewFolder := True;
  end;
  FIni.Rename(F, False);
  FIni.UpdateFile;
  // �v���p�e�B�̐ݒ�
  DeleteFile(FIniName);
  FFileName := NewFileName;
  if isNewFolder then begin
    FDefaultFolder := dfUser;
    FFolder := ExtractFilePath(NewFileName);
  end;
  FIniName := FFolder + FFileName;
end;

// ################################# SectionExists���\�b�h[�Z�N�V�����̑��݊m�F]
function TIniFileCompo.SectionExists(const Section: string): Boolean;
begin
  Result := FIni.SectionExists(Section);
end;

// ############################### CaseSensitive�v���p�e�B�ݒ�[SetCaseSensitive]
procedure TIniFileCompo.SetCaseSensitive(const Value: Boolean);
begin
  FIni.CaseSensitive := Value;
end;

// ##################################### DefaultFolder�v���p�e�B�ݒ�[SetDefault]
procedure TIniFileCompo.SetDefaultFolder(const Value: TDefaultFolder);
var
  F: string;
begin
  FDefaultFolder := Value;
  case FDefaultFolder of
    dfAppData:     FFolder := GetPath(FDefaultFolder) + FAppName;
    dfApplication: FFolder := FAppFolder;
    dfUser:        FFolder := '';
    else
      FFolder := GetPath(FDefaultFolder);
  end;
  FIniName := FFolder + ExtractFileName(FIniName);
  F := ExtractFilePath(FIniName);
  if not DirectoryExists(F) then ForceDirectories(F);
  FIni.Rename(FIniName, True);
  Load;
end;

// ######################################### FileName�v���p�e�B�ݒ�[SetFileName]
procedure TIniFileCompo.SetFileName(const Value: string);
begin
  FFileName := Value;
  if FFileName = '' then
    FIniName := FFolder + FDefaultFileName
  else
    FIniName := FFolder + FFileName;
  FIni.Rename(FIniName, True);
  Load;
end;

// ################################## Update���\�b�h[���������f�B�X�N�ɏ�������]
procedure TIniFileCompo.Update;
begin
  FIni.UpdateFile;
  DoUpdate;
end;

// ##################### UpdateIni�������\�b�h[UpdateAtOnce�ɉ����ăA�b�v�f�[�g]
procedure TIniFileCompo.UpdateIni;
begin
  if FUpdateAtOnce then begin
    FIni.UpdateFile;
    DoUpdate;
  end;
end;

// ######################################### WriteBool���\�b�h[�_���l�̏�������]
procedure TIniFileCompo.WriteBool(const Section, Item: string;
  Value: Boolean);
begin
  FIni.WriteBool(Section, Item, Value);
  UpdateIni;
end;

// ######################################## WriteColor���\�b�h[TColor�̏�������]
procedure TIniFileCompo.WriteColor(const Section, Item: string;
  Value: TColor);
var
  C: LongInt;
  H: string;
begin
  C := Value;
  H := '$' + IntToHex(C, 8);
  FIni.WriteString(Section, Item, H);
  UpdateIni;
end;

// ##################################### WriteCurr���\�b�h[Currency�^�̏�������]
procedure TIniFileCompo.WriteCurr(const Section, Item: string;
  Value: Currency);
var
  S: string;
begin
  S := CurrToStr(Value);
  FIni.WriteString(Section, Item, S);
  UpdateIni;
end;

// ########################################## WriteDateTime[TDateTime�̏�������]
procedure TIniFileCompo.WriteDateTime(const Section, Item: string;
  Value: TDateTime);
begin
  FIni.WriteDateTime(Section, Item, Value);
  UpdateIni;
end;

// #################### �G���R�[�h������̏�������[WriteEncodeStr���\�b�h] #####
procedure TIniFileCompo.WriteStrWithEncode(const Section, Item, Password,
  Value: string);
var
  Ch: Integer;                    // �ϊ��p
  Cp: Integer;
  EncodeStr: string;              // �Í���������
  KeyCp: Integer;                 // �g�p����L�[
  KeyValue: array of Integer;     // �L�[
  Len: Integer;                   // ����
  SS: string;                     // ���ꕶ��
  Lp: Integer;
begin
  // ************************************************************ �L�[�̍쐬
  SetLength(KeyValue, Length(Password));
  for Lp := 1 to Length(Password) do
    KeyValue[Lp - 1] := Pos(Password[Lp], PassStr);
  // **************************************************************** ������
  Len := Length(PassStr);
  EncodeStr := '';
  KeyCp := 0;
  // ************************************************************ �G���R�[�h
  for Lp := 1 to Length(Value) do
  begin
    if Pos(Value[Lp], PassStr) >= 1 then
    begin
      Ch := (Pos(Value[Lp], PassStr) + KeyValue[KeyCp]) mod Len + 1;
      EncodeStr := EncodeStr + PassStr[Ch];
    end
    else
    begin
      SS := IntToHex(Ord(Value[Lp]), 2);
      Cp := 1;
      EncodeStr := EncodeStr + '$';
      while Cp <= 2 do
      begin
        Ch := (Pos(SS[Cp], PassStr) + KeyValue[KeyCp]) mod Len + 1;
        EncodeStr := EncodeStr + PassStr[Ch];
        Inc(Cp);
      end;
    end;
    Inc(KeyCp);
    if KeyCp >= Length(KeyValue) then KeyCp := 0;
  end;
  FIni.WriteString(Section, Item, EncodeStr);
  UpdateIni;
end;

// ######################################## WriteFloat���\�b�h[�����^�̏�������]
procedure TIniFileCompo.WriteFloat(const Section, Item: string;
  Value: Extended);
var
  S: string;
begin
  S := FloatToStr(Value);
  FIni.WriteString(Section, Item, S);
  UpdateIni;
end;

// ########################################## WriteFont���\�b�h[TFont�̏�������]
procedure TIniFileCompo.WriteFont(const Section, Item: string;
  Font: TFont);
var
  Charset: Byte;
  Color: LongInt;
  ItemName: string;
begin
  FIni.WriteString(Section, Item, 'FONT');
  // Charset
  ItemName := Item + '.charset';
  Charset := Font.Charset;
  FIni.WriteInteger(Section, ItemName, Charset);
  // Color
  ItemName := Item + '.color';
  Color := Font.Color;
  FIni.WriteString(Section, ItemName, IntToHex(Color, 8));
  // Name
  ItemName := Item + '.name';
  FIni.WriteString(Section, ItemName, Font.Name);
  // Pitch
  ItemName := Item + '.pitch';
  FIni.WriteInteger(Section, ItemName, Ord(Font.Pitch));
  // Size
  ItemName := Item + '.size';
  FIni.WriteInteger(Section, ItemName, Font.Size);
  // Style
  // Bold
  ItemName := Item + '.bold';
  FIni.WriteBool(Section, ItemName, fsBold in Font.Style);
  // Italic
  ItemName := Item + '.italic';
  FIni.WriteBool(Section, ItemName, fsItalic in Font.Style);
  // Underline
  ItemName := Item + '.underline';
  FIni.WriteBool(Section, ItemName, fsUnderline in Font.Style);
  // StrikeOut
  ItemName := Item + '.strikeout';
  FIni.WriteBool(Section, ItemName, fsStrikeOut in Font.Style);
  UpdateIni;
end;

// ####################################### WriteForm���\�b�h[�t�H�[���̏�������]
procedure TIniFileCompo.WriteForm(const Section, Item: string;
  Form: TForm);
var
  Wp: TWindowPlacement;
begin
  //  �E�B���h�E���̎擾
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  FIni.WriteString(Section, Item, 'FORM');
  with Wp do
  begin
    // ��������
    FIni.WriteInteger(Section, Item + '.flags', Flags);
    FIni.WriteInteger(Section, Item + '.show', showcmd);
    FIni.WriteInteger(Section, Item + '.maxx', ptMaxPosition.X);
    FIni.WriteInteger(Section, Item + '.maxy', ptMaxPosition.Y);
    with rcNormalPosition do
    begin
      FIni.WriteInteger(Section, Item + '.left', Left);
      FIni.WriteInteger(Section, Item + '.top', Top);
      FIni.WriteInteger(Section, Item + '.width', Right);
      FIni.WriteInteger(Section, Item + '.height', Bottom);
    end;
  end;
  //  WindowState
  FIni.WriteInteger(Section, Item + '.state', Ord(Form.WindowState));
  FIni.WriteInteger(Section, Item + '.cwidth', Form.ClientWidth);
  FIni.WriteInteger(Section, Item + '.cheight', Form.ClientHeight);
  UpdateIni;
end;

// ############################################ WriteInt���\�b�h[�����̏�������]
procedure TIniFileCompo.WriteInt(const Section, Item: string;
  Value: Integer);
begin
  FIni.WriteInteger(Section, Item, Value);
  UpdateIni;
end;

// ######################################### WriteInt64���\�b�h[Int64�̏�������]
procedure TIniFileCompo.WriteInt64(const Section, Item: string;
  Value: Int64);
var
  S: string;
begin
  // Int64�͕�����Ƃ��ĕۑ�����
  S := IntToStr(Value);
  FIni.WriteString(Section, Item, S);
  UpdateIni;
end;

// ################################### WriteList���\�b�h[�����񃊃X�g�̏�������]
procedure TIniFileCompo.WriteList(const Section, Item: string;
  List: TStrings);
var
  Lp, ItemCount: Integer;
  ItemName: string;
begin
  FIni.WriteString(Section, Item, 'LIST');
  ItemName := Item + '.count';
  ItemCount := FIni.ReadInteger(Section, ItemName, 0);
  // ���X�g�̃A�C�e�����̏�������
  FIni.WriteInteger(Section, ItemName, List.Count);
  // ���X�g�̏�������
  for Lp := 0 to List.Count - 1 do begin
    ItemName := Item + '.' + IntToStr(Lp);
    FIni.WriteString(Section, ItemName, List.Strings[Lp]);
  end;
  // ���X�g�̂悯���ȕ������폜
  if List.Count < ItemCount then
    for Lp := List.Count to ItemCount - 1 do begin
      ItemName := Item + '.' + IntToStr(Lp);
      FIni.DeleteKey(Section, ItemName);
    end;
  UpdateIni;
end;

// ################## WriteSizePos���\�b�h[�R���g���[���̈ʒu�ƃT�C�Y�̏�������]
procedure TIniFileCompo.WriteSizePos(const Section, Item: string;
  Control: TControl);
begin
  FIni.WriteString(Section, Item, 'BOUNDS');
  FIni.WriteInteger(Section, Item + '.left', Control.Left);
  FIni.WriteInteger(Section, Item + '.top', Control.Top);
  FIni.WriteInteger(Section, Item + '.width', Control.Width);
  FIni.WriteInteger(Section, Item + '.height', Control.Height);
  UpdateIni;
end;

// ########################################## WriteStr���\�b�h[������̏�������]
procedure TIniFileCompo.WriteStr(const Section, Item, Value: string);
begin
  FIni.WriteString(Section, Item, Value);
  UpdateIni;
end;

// ########################## �t�H�[���T�C�Y�̓ǂݍ���[ReadFormEx���\�b�h] #####
procedure TIniFileCompo.ReadFormEx(const Section, Item: string;
  Form: TForm);
var
  State: Integer;
  Wp: TWindowPlacement;
begin
  // �f�t�H���g�擾
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // �t�H�[���̓ǂݍ���
  Wp.flags := FIni.ReadInteger(Section, Item + '.flags', Wp.flags);
  Wp.showCmd := FIni.ReadInteger(Section, Item + '.show', Wp.showCmd);
  with Wp do
  begin
    ptMaxPosition.X := FIni.ReadInteger(Section, Item + '.maxx',
                                        ptMaxPosition.X);
    ptMaxPosition.Y := FIni.ReadInteger(Section, Item + '.maxy',
                                        ptMaxPosition.Y);
    with rcNormalPosition do
    begin
      Left := FIni.ReadInteger(Section, Item + '.left', Left);
      Top := FIni.ReadInteger(Section, Item + '.top', Top);
      Right := FIni.ReadInteger(Section, Item + '.width', Right);
      Bottom := FIni.ReadInteger(Section, Item + '.height', Bottom);
    end;
  end;
  // �ݒ�
  if not Form.Showing then
  begin
    Wp.showCmd := SW_HIDE;
    SetWindowPlacement(Form.Handle, @Wp);
    State := FIni.ReadInteger(Section, Item + '.state', Ord(wsNormal));
    if State = Ord(wsMaximized) then
      Form.WindowState := wsMaximized
    else
      Form.WindowState := wsNormal;
  end
  else
    SetWindowPlacement(Form.Handle, @Wp);
  //  �N���C�A���g�T�C�Y�̓ǂݍ���
  if Form.WindowState = wsNormal then
  begin
    Form.ClientWidth := FIni.ReadInteger(Section, Item + '.cwidth',
                                         Form.ClientWidth);
    Form.ClientHeight :=FIni.ReadInteger(Section, Item + '.cheight',
                                         Form.ClientHeight);
  end;
end;

// ################### �N���C�A���g�T�C�Y�̓ǂݍ���[ReadWinSizeEx���\�b�h] #####
procedure TIniFileCompo.ReadWinSizeEx(const Section, Item: string;
  Form: TForm);
begin
  ReadWinSize(Section, Item, Form);
  Form.ClientWidth := FIni.ReadInteger(Section, Item + '.cwidth',
                                       Form.ClientWidth);
  Form.ClientHeight := FIni.ReadInteger(Section, Item + '.cheight',
                                        Form.ClientHeight);
end;

// ############################# ����t�H���_�̃p�X���擾<GetPath���\�b�h> #####
function TIniFileCompo.GetPath(const FolderType: TDefaultFolder): string;
var
  IMem: IMalloc;
  PathStr: array[0..256] of Char;
  PBuf: PChar;
  PItem: PItemIDList;
begin
  case FolderType of
    dfAppData:
    begin
      SHGetMalloc(IMem);
      PBuf := IMem.Alloc(MAX_PATH);
      SHGetSpecialFolderLocation(Application.Handle, CSIDL_APPDATA, PItem);
      SHGetPathFromIDList(PItem, PBuf);
      Result := PBuf;
      IMem.Free(PBuf);
      IMem.Free(PItem);
    end;
    dfWindows:
    begin
      GetWindowsDirectory(PathStr, SizeOf(PathStr));
      Result := PathStr;
    end;
    else
      Result := '';
  end;
  if Result <> '' then Result := IncludeTrailingPathDelimiter(Result);
end;

// ################################### TRect�^�̓ǂݎ��<ReadRect���\�b�h> #####
function TIniFileCompo.ReadRect(const Section, Item: string;
  Default: TRect): TRect;
var
  ItemExistsFlag: Boolean;
begin
  ItemExistsFlag := FIni.ValueExists(Section, Item + '.left')
                    and FIni.ValueExists(Section, Item + '.top')
                    and FIni.ValueExists(Section, Item + '.right')
                    and FIni.ValueExists(Section, Item + '.bottom');
  if ItemExistsFlag then
  begin
    Result.Left := FIni.ReadInteger(Section, Item + '.left', Default.Left);
    Result.Top := FIni.ReadInteger(Section, Item + '.top', Default.Top);
    Result.Right := FIni.ReadInteger(Section, Item + '.right', Default.Right);
    Result.Bottom := FIni.ReadInteger(Section, Item + '.bottom', Default.Bottom);
  end
  else
    Result := Default;
end;

// ################################## TRect�^�̏�������<WriteRect���\�b�h> #####
procedure TIniFileCompo.WriteRect(const Section, Item: string;
  Value: TRect);
begin
  FIni.WriteString(Section, Item, 'RECT');
  FIni.WriteInteger(Section, Item + '.left', Value.Left);
  FIni.WriteInteger(Section, Item + '.top', Value.Top);
  FIni.WriteInteger(Section, Item + '.right', Value.Right);
  FIni.WriteInteger(Section, Item + '.bottom', Value.Bottom);
  UpdateIni;
end;

// ################################### TDate�^�̏�������<WriteDate���\�b�h> ####
procedure TIniFileCompo.WriteDate(const Section, Item: string;
  const Value: TDate);
begin
  FIni.WriteDate(Section, Item, Value);
  UpdateIni;
end;

// #################################### TDate�^�̓ǂݎ��<ReadDate���\�b�h> ####
function TIniFileCompo.ReadDate(const Section, Item: string;
  const Default: TDate): TDate;
begin
  Result := FIni.ReadDate(Section, Item, Default);
end;

// #################################### TTime�^�̓ǂݎ��<ReadTime���\�b�h> ####
function TIniFileCompo.ReadTime(const Section, Item: string;
  const Default: TTime): TTime;
begin
  Result := FIni.ReadTime(Section, Item, Default);
end;

// ################################### TTime�^�̏�������<WriteTime���\�b�h> ####
procedure TIniFileCompo.WriteTime(const Section, Item: string;
  const Value: TTime);
begin
  FIni.WriteTime(Section, Item, Value);
  UpdateIni;
end;

// ############################ Cardinal�^�̏�������<WriteCardinal���\�b�h> ####
procedure TIniFileCompo.WriteCardinal(const Section, Item: string;
  const Value: Cardinal);
begin
  FIni.WriteString(Section, Item, IntToStr(Value));
  UpdateIni;
end;

// ############################# Cardinal�^�̓ǂݎ��<ReadCardinal���\�b�h> ####
function TIniFileCompo.ReadCardinal(const Section, Item: string;
  const Default: Cardinal): Cardinal;
begin
  if FIni.ValueExists(Section, Item) then
    Result := StrToIntDef(FIni.ReadString(Section, Item, IntToStr(Default)),
              Default)
  else
    Result := Default;
end;

// ########################### �R���g���[���̃T�C�Y���擾<ReadSize���\�b�h> ####
procedure TIniFileCompo.ReadSize(const Section, Item: string;
  Control: TControl);
var
  AWidth, AHeight: Integer;
begin
  AWidth := FIni.ReadInteger(Section, Item + '.width', Control.Width);
  AHeight := FIni.ReadInteger(Section, Item + '.height', Control.Height);
  Control.SetBounds(Control.Left, Control.Top, AWidth, AHeight);
end;

// ############################## �R���g���[���̈ʒu���擾<ReadPos���\�b�h> ####
procedure TIniFileCompo.ReadPos(const Section, Item: string;
  Control: TControl);
var
  ALeft, ATop: Integer;
begin
  ALeft := FIni.ReadInteger(Section, Item + '.left', Control.Left);
  ATop := FIni.ReadInteger(Section, Item + '.top', Control.Top);
  Control.SetBounds(ALeft, ATop, Control.Width, Control.Height);
end;

// ############################# OnLoad�C�x���g�̔���<Load�C�x���g���\�b�h> ####
procedure TIniFileCompo.Load;
begin
  if Assigned(FOnLoad) then FOnLoad(Self);
end;

end.
 