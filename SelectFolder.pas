(*************************************************************************

  フォルダの参照ダイアログボックスを表示する  TSelectFolderDialog

  (C) Tiny Mouse
  2004.06.06

*************************************************************************)

unit SelectFolder;

interface

uses
  Windows, Messages, Classes, Controls, Forms, ShlObj;

type

  TSpecialFolder = (sfDesktop, sfInternet, sfPrograms, sfControls, sfPrinters,
    sfPersonal, sfFavorites, sfStartup, sfRecent, sfSendto, sfBitBucket, sfStartMenu,
    sfMyMusic, sfMyVideo,
    sfDesktopDirectory, sfDirives, sfNetwork, sfNetHood, sfFonts, sfTemplates,
    sfCommonStartMenu, sfCommonPrograms, sfCommonStartup, sfCommonDesktopDirectory,
    sfAppData, sfPrintHood, sfLocalAppData, sfAltStartup, sfCommonAltStartup,
    sfCommonFavorites, sfInternetChache, sfCookies, sfHistory, sfCommonAppData,
    sfWindows, sfSystem, sfProgramFiles, sfMyPictures, sfProfile, sfProgramFilesCommon,
    sfCommonTemplates, sfCommonDocuments, sfCommonAdminTools, sfAdminTools, sfConnections,
    sfCommonMusic, sfCommonPictures, sfCommonVideo,
    sfNone);

  TShellFolder = class
  private
    FPIDL: PItemIDList;
    procedure SetPIDL(Value: PItemIDList);
    procedure SetPath(Value: String);
    procedure SetSpecialFolder(Value: TSpecialFolder);
    function GetPath: String;
    function GetSpecialFolder: TSpecialFolder;
  public
    constructor Create;
    destructor Destroy; override;
    property PIDL: PItemIDList read FPIDL write SetPIDL;
    property Path: String read GetPath write SetPath;
    property SpecialFolder: TSpecialFolder read GetSpecialFolder write SetSpecialFolder;
  end;

  TBrowseInfoOption = (bifReturnOnlyFSDirs, bifDontGoBelowDomain, bifStatusText, bifReturnFSAncestors,
    bifEditBox, bifValidate, bifNewDialogStyle, bifUseNewUI, bifBrowseIncludeURLs, bifUAHint, bifNoNewFolderButton,
    bifBrowseForComputer, bifBrowseForPrinter, bifBrowseIncludeFiles, bifShareable);
  TBrowseInfoOptions = set of TBrowseInfoOption;

  TValidateFailedEvent = procedure (Sender: TObject; const FailedFolder: String; CanClose: Boolean) of object;

  TSelectFolderDialog = class(TComponent)
  private
    FParentWindow: HWnd;
    FDefWndProc: Pointer;
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FDisplayName: String;          { 選択されたフォルダ文字列 }
    FSelectFolder: TShellFolder;   { 選択されたフォルダ }
    FRootFolder: TShellFolder;     { ルートフォルダ }
    FTitle: String;                { ダイアログボックスのタイトル文字列 }
    FStatusText: String;           { ダイアログボックスのステータス文字列 }
    FOptions: TBrowseInfoOptions;  { ダイアログボックスのオプション設定 }
    FImageIndex: Integer;          { 選択されたフォルダのアイコンのインデックス値 }
    FCaption: TCaption;
    FOKButtonCaption: TCaption;
    FOnClose: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FOnCanClose: TCloseQueryEvent;
    FOnFolderChange: TNotifyEvent;
    FOnValidateFailed: TValidateFailedEvent;
    procedure SetSelectFolder(Value: String);
    procedure SetSelectSpecialFolder(Value: TSpecialFolder);
    function GetSelectFolder: String;
    function GetSelectSpecialFolder: TSpecialFolder;
    procedure SetRootFolder(Value: String);
    procedure SetRootSpecialFolder(Value: TSpecialFolder);
    function GetRootFolder: String;
    function GetRootSpecialFolder: TSpecialFolder;
    procedure SetStatusText(Value: String);
    procedure SetCaption(Value: TCaption);
    procedure SetOKButtonCaption(Value: TCaption);
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMCommand(var Message: TWmCommand); message WM_COMMAND;
    procedure MainWndProc(var Message: TMessage);
    procedure ChangeSelectFolder;
    procedure ChangeStatusText;
    procedure ChangeCaption;
    procedure ChangeOKButtonCaption;
  protected
    procedure DoClose; dynamic;
    procedure DoShow; dynamic;
    function DoCanClose: Boolean; dynamic;
    procedure DoFolderChange; dynamic;
    function DoValidateFailed(const FailedFolder: String): Boolean;
    procedure WndProc(var Message: TMessage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
    procedure SetEnableOK(Value: Boolean);
    procedure DefaultHandler(var Message); override;
    property ParentWindow: HWnd read FParentWindow write FParentWindow;
    property Handle: HWnd read FHandle;
    property DisplayName: String read FDisplayName;
    property SelectFolder: String read GetSelectFolder write SetSelectFolder;
    property RootFolder: String read GetRootFolder write SetRootFolder;
    property ImageIndex: Integer read FImageIndex;
  published
    property SelectSpecialFolder: TSpecialFolder read GetSelectSpecialFolder write SetSelectSpecialFolder default sfNone;
    property RootSpecialFolder: TSpecialFolder read GetRootSpecialFolder write SetRootSpecialFolder default sfDesktop;
    property Title: String read FTitle write FTitle;
    property StatusText: String read FStatusText write SetStatusText;
    property Options: TBrowseInfoOptions read FOptions write FOptions default [bifReturnOnlyFSDirs];
    property Caption: TCaption read FCaption write SetCaption;
    property OKButtonCaption: TCaption read FOKButtonCaption write SetOKButtonCaption;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnCanClose: TCloseQueryEvent read FOnCanClose write FOnCanClose;
    property OnFolderChange: TNotifyEvent read FOnFolderChange write FOnFolderChange;
    property OnValidateFailed: TValidateFailedEvent read FOnValidateFailed write FOnValidateFailed;
  end;

procedure Register;

implementation

uses
  ComObj, ActiveX;

procedure Register;
begin
  RegisterComponents('Dialogs', [TSelectFolderDialog]);
end;

{************************************************************************}

const
  {$IFNDEF BIF_NEWDIALOGSTYLE}
  BIF_NEWDIALOGSTYLE =$0040;
  {$ENDIF}
  {$IFNDEF BIF_BROWSEINCLUDEURLS}
  BIF_BROWSEINCLUDEURLS = $0080;
  {$ENDIF}
  {$IFNDEF BIF_SHAREABLE}
  BIF_SHAREABLE = $8000;
  {$ENDIF}
  {$IFNDEF BIF_UAHINT}
  BIF_UAHINT = $0100;
  {$ENDIF}
  {$IFNDEF BIF_NONEWFOLDERBUTTON}
  BIF_NONEWFOLDERBUTTON = $0200;
  {$ENDIF}
  {$IFNDEF BIF_USENEWUI}
  BIF_USENEWUI = BIF_NEWDIALOGSTYLE or BIF_EDITBOX;
  {$ENDIF}

  {$IFNDEF CSIDL_MYMUSIC}
  CSIDL_MYMUSIC = $000d;
  {$ENDIF}
  {$IFNDEF CSIDL_MYVIDEO}
  CSIDL_MYVIDEO = $000e;
  {$ENDIF}
  {$IFNDEF CSIDL_LOCAL_APPDATA}
  CSIDL_LOCAL_APPDATA = $001c;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_APPDATA}
  CSIDL_COMMON_APPDATA = $0023;
  {$ENDIF}
  {$IFNDEF CSIDL_WINDOWS}
  CSIDL_WINDOWS = $0024;
  {$ENDIF}
  {$IFNDEF CSIDL_SYSTEM}
  CSIDL_SYSTEM = $0025;
  {$ENDIF}
  {$IFNDEF CSIDL_PROGRAM_FILES}
  CSIDL_PROGRAM_FILES = $0026;
  {$ENDIF}
  {$IFNDEF CSIDL_MYPICTURES}
  CSIDL_MYPICTURES = $0027;
  {$ENDIF}
  {$IFNDEF CSIDL_PROFILE}
  CSIDL_PROFILE = $0028;
  {$ENDIF}
  {$IFNDEF CSIDL_PROGRAM_FILES_COMMON}
  CSIDL_PROGRAM_FILES_COMMON = $002b;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_TEMPLATES}
  CSIDL_COMMON_TEMPLATES = $002d;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_DOCUMENTS}
  CSIDL_COMMON_DOCUMENTS = $002e;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_ADMINTOOLS}
  CSIDL_COMMON_ADMINTOOLS = $002f;
  {$ENDIF}
  {$IFNDEF CSIDL_ADMINTOOLS}
  CSIDL_ADMINTOOLS = $0030;
  {$ENDIF}
  {$IFNDEF CSIDL_CONNECTIONS}
  CSIDL_CONNECTIONS = $0031;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_MUSIC}
  CSIDL_COMMON_MUSIC = $0035;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_PICTURES}
  CSIDL_COMMON_PICTURES = $0036;
  {$ENDIF}
  {$IFNDEF CSIDL_COMMON_VIDEO}
  CSIDL_COMMON_VIDEO = $0037;
  {$ENDIF}
  {$IFNDEF CSIDL_CDBURN_AREA}
  CSIDL_CDBURN_AREA = $003b;
  {$ENDIF}
  CSIDL_NONE = $ffff;

{ 以上 ShlObj.pas を補足 }

const
  BrowseInfoOptions: array [TBrowseInfoOption] of UINT = (
    BIF_RETURNONLYFSDIRS, BIF_DONTGOBELOWDOMAIN, BIF_STATUSTEXT, BIF_RETURNFSANCESTORS,
    BIF_EDITBOX, BIF_VALIDATE, BIF_NEWDIALOGSTYLE, BIF_USENEWUI, BIF_BROWSEINCLUDEURLS, BIF_UAHINT, BIF_NONEWFOLDERBUTTON,
    BIF_BROWSEFORCOMPUTER, BIF_BROWSEFORPRINTER, BIF_BROWSEINCLUDEFILES, BIF_SHAREABLE);

  SpecialFolders: array [TSpecialFolder] of Integer = (
    CSIDL_DESKTOP, CSIDL_INTERNET, CSIDL_PROGRAMS, CSIDL_CONTROLS, CSIDL_PRINTERS,
    CSIDL_PERSONAL, CSIDL_FAVORITES, CSIDL_STARTUP, CSIDL_RECENT, CSIDL_SENDTO, CSIDL_BITBUCKET, CSIDL_STARTMENU,
    CSIDL_MYMUSIC, CSIDL_MYVIDEO,
    CSIDL_DESKTOPDIRECTORY, CSIDL_DRIVES, CSIDL_NETWORK, CSIDL_NETHOOD, CSIDL_FONTS, CSIDL_TEMPLATES,
    CSIDL_COMMON_STARTMENU, CSIDL_COMMON_PROGRAMS, CSIDL_COMMON_STARTUP, CSIDL_COMMON_DESKTOPDIRECTORY,
    CSIDL_APPDATA, CSIDL_PRINTHOOD, CSIDL_LOCAL_APPDATA, CSIDL_ALTSTARTUP, CSIDL_COMMON_ALTSTARTUP,
    CSIDL_COMMON_FAVORITES, CSIDL_INTERNET_CACHE, CSIDL_COOKIES, CSIDL_HISTORY, CSIDL_COMMON_APPDATA,
    CSIDL_WINDOWS, CSIDL_SYSTEM, CSIDL_PROGRAM_FILES, CSIDL_MYPICTURES, CSIDL_PROFILE, CSIDL_PROGRAM_FILES_COMMON,
    CSIDL_COMMON_TEMPLATES, CSIDL_COMMON_DOCUMENTS, CSIDL_COMMON_ADMINTOOLS, CSIDL_ADMINTOOLS, CSIDL_CONNECTIONS,
    CSIDL_COMMON_MUSIC, CSIDL_COMMON_PICTURES, CSIDL_COMMON_VIDEO,
    CSIDL_NONE);

{ TShellFolder }

function CreatePIDL(Size: Integer): PItemIDList;
var
  Malloc: IMalloc;
begin
  OleCheck(SHGetMalloc(Malloc));
  Result := Malloc.Alloc(Size);
  if Assigned(Result) then
    FillChar(Result^, Size, 0);
end;

function NextPIDL(PIDL: PItemIDList): PItemIDList;
begin
  Result := PIDL;
  Inc(PChar(Result), PIDL^.mkid.cb);
end;

function GetPIDLSize(PIDL: PItemIDList): Integer;
begin
  Result := 0;
  if Assigned(PIDL) then
  begin
    Result := SizeOf(PIDL^.mkid.cb);
    while PIDL^.mkid.cb <> 0 do
    begin
      Result := Result + PIDL^.mkid.cb;
      PIDL := NextPIDL(PIDL);
    end;
  end;
end;

function CopyPIDL(PIDL: PItemIDList): PItemIDList;
var
  Size: Integer;
begin
  Size := GetPIDLSize(PIDL);
  Result := CreatePIDL(Size);
  if Assigned(Result) then
    CopyMemory(Result, PIDL, Size);
end;

procedure DisposePIDL(PIDL: PItemIDList);
var
  Malloc: IMalloc;
begin
  OleCheck(SHGetMalloc(Malloc));
  Malloc.Free(PIDL);
end;

constructor TShellFolder.Create;
begin
  FPIDL := nil;
end;

destructor TShellFolder.Destroy;
begin
  if Assigned(FPIDL) then
    DisposePIDL(FPIDL);
  inherited Destroy;
end;

procedure TShellFolder.SetPIDL(Value: PItemIDList);
begin
  if Assigned(FPIDL) then
    DisposePIDL(FPIDL);
  FPIDL := Value;
end;

procedure TShellFolder.SetPath(Value: String);
var
  Desktop: IShellFolder;
  Eaten, Attributes: ULONG;
begin
  if Assigned(FPIDL) then
    DisposePIDL(FPIDL);
  OleCheck(SHGetDesktopFolder(Desktop));
  OleCheck(Desktop.ParseDisplayName(0, nil, PWideChar(WideString(Value)), Eaten, FPIDL, Attributes));
end;

procedure TShellFolder.SetSpecialFolder(Value: TSpecialFolder);
begin
  if Assigned(FPIDL) then
    DisposePIDL(FPIDL);
  if Value = sfNone then
    FPIDL := nil
  else
    OleCheck(SHGetSpecialFolderLocation(0, SpecialFolders[Value], FPIDL));
end;

function TShellFolder.GetPath: String;
var
  buf: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if not Assigned(FPIDL) then
    Exit;
  if not ShGetPathFromIDList(FPIDL, buf) then
    Exit;
  Result := String(buf)
end;

function TShellFolder.GetSpecialFolder: TSpecialFolder;
var
  sf: TSpecialFolder;
  pidl: PItemIDList;
  Desktop: IShellFolder;
begin
  Result := sfNone;
  if not Assigned(FPIDL) then
    Exit;
  for sf := Low(sf) to High(sf) do
  begin
    if FAILED(SHGetSpecialFolderLocation(0, SpecialFolders[sf], pidl)) then
      Continue;
    OleCheck(SHGetDesktopFolder(Desktop));
    if Desktop.CompareIDs(0, FPIDL, pidl) = 0 then
      Result := sf;
    DisposePIDL(pidl);
  end;
end;

{ TSelectFolderDialog }

constructor TSelectFolderDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSelectFolder := TShellFolder.Create;
  FRootFolder := TShellFolder.Create;

  FObjectInstance := Classes.MakeObjectInstance(MainWndProc);
  { プロパティの初期値を設定 }
  if AOwner is TWinControl then
    FParentWindow := TWinControl(AOwner).Handle
  else
    FParentWindow := Application.Handle;
  FHandle := 0;
  FOptions := [bifReturnOnlyFSDirs];
  FSelectFolder.SpecialFolder := sfNone;
  FRootFolder.SpecialFolder := sfDesktop;
end;

destructor TSelectFolderDialog.Destroy;
begin
  if FObjectInstance <> nil then Classes.FreeObjectInstance(FObjectInstance);

  FSelectFolder.Free;
  FRootFolder.Free;
  inherited Destroy;
end;

procedure TSelectFolderDialog.DefaultHandler(var Message);
begin
  if FHandle <> 0 then
    with TMessage(Message) do
      Result := CallWindowProc(FDefWndProc, FHandle, Msg, WParam, LParam)
  else inherited DefaultHandler(Message);
end;

procedure TSelectFolderDialog.MainWndProc(var Message: TMessage);
begin
  try
    WndProc(Message);
  except
    Application.HandleException(Self);
  end;
end;

procedure TSelectFolderDialog.WndProc(var Message: TMessage);
begin
  Dispatch(Message);
end;

procedure TSelectFolderDialog.WMDestroy(var Message: TWMDestroy);
begin
  inherited;
  DoClose;
end;

procedure TSelectFolderDialog.WMNCDestroy(var Message: TWMNCDestroy);
begin
  inherited;
  FHandle := 0;
end;

procedure TSelectFolderDialog.WMCommand(var Message: TWMCommand);
begin
  if Message.ItemID = IDOK then  { [はい] ボタンが押されたとき }
  begin
    if not DoCanClose then  { 閉じてはいけないとき }
      Exit;
  end;
  { それ以外 }
  inherited;
end;

procedure TSelectFolderDialog.DoClose;
begin
  if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TSelectFolderDialog.DoShow;
begin
  if Assigned(FOnShow) then FOnShow(Self);
end;

function TSelectFolderDialog.DoCanClose: Boolean;
begin
  Result := True;
  if Assigned(FOnCanClose) then FOnCanClose(Self, Result);
end;

procedure TSelectFolderDialog.DoFolderChange;
begin
  if Assigned(FOnFolderChange) then FOnFolderChange(Self);
end;

function TSelectFolderDialog.DoValidateFailed(const FailedFolder: String): Boolean;
begin
  Result := True;
  if Assigned(FOnValidateFailed) then FOnValidateFailed(Self, FailedFolder, Result);
end;

procedure TSelectFolderDialog.SetSelectFolder(Value: String);
begin
  FSelectFolder.SetPath(Value);
  ChangeSelectFolder;  { ダイアログボックスへ変更を反映 }
end;

procedure TSelectFolderDialog.SetSelectSpecialFolder(Value: TSpecialFolder);
begin
  FSelectFolder.SetSpecialFolder(Value);
  ChangeSelectFolder;  { ダイアログボックスへ変更を反映 }
end;

function TSelectFolderDialog.GetSelectFolder: String;
begin
  Result := FSelectFolder.GetPath;
end;

function TSelectFolderDialog.GetSelectSpecialFolder: TSpecialFolder;
begin
  Result := FSelectFolder.GetSpecialFolder;
end;

procedure TSelectFolderDialog.SetRootFolder(Value: String);
begin
  FRootFolder.SetPath(Value);
end;

procedure TSelectFolderDialog.SetRootSpecialFolder(Value: TSpecialFolder);
begin
  FRootFolder.SetSpecialFolder(Value);
end;

function TSelectFolderDialog.GetRootFolder: String;
begin
  Result := FRootFolder.GetPath;
end;

function TSelectFolderDialog.GetRootSpecialFolder: TSpecialFolder;
begin
  Result := FRootFolder.GetSpecialFolder;
end;

procedure TSelectFolderDialog.SetStatusText(Value: String);
begin
  FStatusText := Value;
  ChangeStatusText;  { ダイアログボックスへ変更を反映 }
end;

procedure TSelectFolderDialog.SetCaption(Value: TCaption);
begin
  FCaption := Value;
  ChangeCaption;  { ダイアログボックスへ変更を反映 }
end;

procedure TSelectFolderDialog.SetOKButtonCaption(Value: TCaption);
begin
  FOKButtonCaption := Value;
  ChangeOKButtonCaption;  { ダイアログボックスへ変更を反映 }
end;

procedure TSelectFolderDialog.SetEnableOK(Value: Boolean);
begin
  if FHandle = 0 then
    Exit;
  SendMessage(FHandle, BFFM_ENABLEOK, 0, Longint(Value));
end;

{ SHBrowseForFolder のコールバック関数 }

procedure TSelectFolderDialog.ChangeSelectFolder;
begin
  if (FHandle = 0) or (not Assigned(FSelectFolder.PIDL)) then
    Exit;
  SendMessage(FHandle, BFFM_SETSELECTION, Longint(False), Longint(FSelectFolder.PIDL));
end;

procedure TSelectFolderDialog.ChangeStatusText;
begin
  if FHandle = 0 then
    Exit;
  if bifStatusText in FOptions then
    SendMessage(FHandle, BFFM_SETSTATUSTEXT, 0, Longint(PChar(FStatusText)));
end;

procedure TSelectFolderDialog.ChangeCaption;
begin
  if FHandle = 0 then
    Exit;
  if FCaption <> '' then
    SendMessage(FHandle, WM_SETTEXT, 0, Longint(PChar(FCaption)));
end;

procedure TSelectFolderDialog.ChangeOKButtonCaption;
var
  hButton: HWnd;
begin
  if FHandle = 0 then
    Exit;
  hButton := GetDlgItem(FHandle, 1);
  if hButton = 0 then
    Exit;
  if FOKButtonCaption <> '' then
    SendMessage(hButton, WM_SETTEXT, 0, Longint(PChar(FOKButtonCaption)));
end;

function BrowseCallbackProc(hwnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer; stdcall;
begin
  Result := 0;

  with (TObject(lpData) as TSelectFolderDialog) do
  begin
    if uMsg = BFFM_INITIALIZED then
    begin
      { ダイアログボックスのウィンドウハンドルを設定 }
      FHandle := hwnd;
      { ダイアログボックスのサブクラス化 }
      FDefWndProc := Pointer(SetWindowLong(hwnd, GWL_WNDPROC, Longint(FObjectInstance)));
      { 初期選択フォルダを設定 }
      ChangeSelectFolder;
      { ステータス文字列を表示 }
      ChangeStatusText;
      { ダイアログボックスのキャプション文字列を表示 }
      ChangeCaption;
      { [OK] ボタンのキャプション文字列を表示 }
      ChangeOKButtonCaption;
      { イベントを発生 }
      DoShow;
    end
    else
    if uMsg = BFFM_SELCHANGED then
    begin
      if FHandle = 0 then  { ダイアログボックスボックスが初期化されていなければ }
        Exit;  { 終了 }
      { 選択されたフォルダを保持 }
      FSelectFolder.PIDL := CopyPIDL(PItemIDList(lParam));
      { イベントを発生 }
      DoFolderChange;
    end
    else
    if uMsg = BFFM_VALIDATEFAILED then
    begin
      { イベントを発生、終了していいか確認 }
      if not DoValidateFailed(String(lParam)) then
        Result := 1;  { 終了させない }
    end;
  end;
end;

{ ダイアログボックスを出す }

function TSelectFolderDialog.Execute: Boolean;
var
  BrowseInfo: TBrowseInfo;
  Option: TBrowseInfoOption;
  PDisplayName: array [0..MAX_PATH] of Char;
  ActiveWindow: HWnd;
  WindowList: Pointer;
  FocusState: TFocusState;
  pidl: PItemIDList;
begin
  Result := False;

  { BROWSEINFO を設定 }
  with BrowseInfo do
  begin
    hwndOwner := FParentWindow;
    pidlRoot := FRootFolder.PIDL;
    pszDisplayName := PDisplayName;
    lpszTitle := PChar(FTitle);

    { オプションを設定 }
    ulFlags := 0;
    for Option := Low(Option) to High(Option) do
      if Option in FOptions then
        ulFlags := ulFlags or BrowseInfoOptions[Option];

    lpfn := @BrowseCallbackProc;
    lParam := Longint(Self);
  end;

  { ダイアログボックスを出す }
  try
    ActiveWindow := GetActiveWindow;
    WindowList := DisableTaskWindows(0);
    FocusState := SaveFocusState;
    pidl := SHBrowseForFolder(BrowseInfo);
  finally
    EnableTaskWindows(WindowList);
    SetActiveWindow(ActiveWindow);
    RestoreFocusState(FocusState);
  end;

  { フォルダが選択されていなければ }
  if not Assigned(pidl) then
    Exit;  { 終了 }

  { プロパティを設定 }
  FSelectFolder.PIDL := CopyPIDL(pidl);
  FDisplayName := String(PDisplayName);
  FImageIndex := BrowseInfo.iImage;
  DisposePIDL(pidl);
  Result := True;
end;

initialization
  OleInitialize(nil);

finalization
  OleUninitialize;

end.
