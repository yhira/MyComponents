{//////////////////////////////////////////////////////////////////////////////
//	タスクトレイアイコン表示関連ユニット				     //
//	2002.04.15 H.Okamoto						     //
//	最終更新日	2004.02.27					     //
//////////////////////////////////////////////////////////////////////////////}
unit TrShlApi;

{/////////////////////////////////////////////////////////////////////////////}
interface
{/////////////////////////////////////////////////////////////////////////////}

uses
  Windows, Messages, Classes {$IFNDEF NO_USE_CUSTOM_TOOLTIP}, Graphics{$ENDIF};

{************************************************************************}
{* 	定数定義							*}
{************************************************************************}
const
  WM_TaskTrayMessage	= WM_User + 200;
  NotifyIconErrMessage    = 'タスクトレイにアイコンを登録できません。';
  NotifyIconModErrMessage = 'タスクトレイのアイコンを変更できません。';

  {タスクトレイクラス用メッセージ}
  WM_MOUSE_ENTER	= WM_User + 210;	{マウスがトレイのアイコン内に入ったときのメッセージ}
  WM_MOUSE_EXIT		= WM_User + 211;	{　　　〃　　　のアイコン内から出たときのメッセージ}
  WM_MOUSE_CLICK	= WM_User + 212;	{　　　〃　　　のアイコン上でマウスクリックしたときのメッセージ}
  WM_TASKBER_RESTART	= WM_User + 220;	{タスクバーが再起動したメッセージ}

  TRAY_ICON_WINDOW_CLASS_NAME	= 'TaskTrayHandle';

  {Windows XP 対応 タスクトレイにアイコンが表示されないことがあるときのエラー}
  {未定義の識別子エラーになったらコメント解除してください}
  //ERROR_TIMEOUT   = 1460;

{************************************************************************}
{* 	各種定義							*}
{************************************************************************}
type
  {タスクトレイアイコンハンドルのメッセージイベントハンドラ}
  TOnMessage	= procedure (var Message: TMessage) of object;

{*****************************************************************************
	Shell32.dll Ver5.0 以降用(Windows 2000 + IE5.0 以降)
******************************************************************************}
const
  NIM_SETFOCUS		= $0004;
  NIM_SETVERSION	= $0008;

  {TNotifyIconData.uFlags 追加定数}
  {$EXTERNALSYM NIF_STATE}
  NIF_STATE		= $00000008;
  {$EXTERNALSYM NIF_INFO}
  NIF_INFO		= $00000010;

  {TNotifyIconData.dwState}
  NIS_HIDDEN 		= $00000001;
  NIS_SHAREDICON	= $00000002;

  {TNotifyIconData.uTimeoutOrVersion}
  {タスクトレイアイコンに関する動作バージョン:
   通常は０でWin95時代からのメッセージ処理と同じです}
  NOTIFYICON_VERSION	= $00000001;

  {TNotifyIconData.dwInfoFlags Konstanten}
  {バルーンヘルプに表示するアイコンの種類}
  NIIF_NONE		= $00000000;	{アイコンなし}
  NIIF_INFO		= $00000001;	{情報}
  NIIF_WARNING		= $00000002;	{警告}
  NIIF_ERROR		= $00000003;	{エラー}

  {バルーン関連メッセージ Shell32.dll のバージョンが 6.0以降？}
  {(1):タスクトレイアイコンに関する動作バージョンが1のとき用らしい
   (2):Shell32.dll のバージョンが6(Windows XP)以降らしい}
  NIN_SELECT		= WM_USER + 0;		{(1)}
  NINF_KEY		= $1;
  NIN_KEYSELECT		= NIN_SELECT or NINF_KEY;	{(1)=WM_USER + 1}
  NIN_BALLOONSHOW	= WM_USER + 2;		{(2):バルーンヘルプを表示したときのメッセージ}
  NIN_BALLOONHIDE	= WM_USER + 3;		{(2):バルーンヘルプが非表示になったときのメッセージ}
  NIN_BALLOONTIMEOUT	= WM_USER + 4;		{(2):タイムアウトでバルーンヘルプが非表示になるときに発生}
  NIN_BALLOONUSERCLICK	= WM_USER + 5;		{(2):ユーザーがクリックしてバルーンヘルプが非表示になるときに発生}

type
  {タスクトレイにアイコン表示するための構造体 Ver 5 以降}
  PNewNotifyIconData = ^TNewNotifyIconData;
  _NEWNOTIFYICONDATA	= packed record
    cbSize		:DWORD;
    Wnd			:HWND;
    uID			:UINT;
    uFlags		:UINT;
    uCallbackMessage	:UINT;
    hIcon		:HICON;
    szTip		:array [0..127] of AnsiChar;
    {追加分}
    dwState		:DWORD;
    dwStateMask		:DWORD;
    szInfo		:array [0..255] of AnsiChar;
    uTimeout		:UINT;
    szInfoTitle		:array [0.. 63] of AnsiChar;
    dwInfoFlags		:DWORD;
  end;
  TNewNotifyIconData = _NEWNOTIFYICONDATA;

  {DLLのバージョンを得る構造体}
  TDllVersionInfo	= packed record
    cbSize		:DWORD;
    dwMajorVersion	:DWORD;
    dwMinorVersion	:DWORD;
    dwBuildNumber	:DWORD;
    dwPlatformID	:DWORD;
  end;

{************************************************************************}
{* 	カスタムツールチップクラス					*}
{************************************************************************}
{$IFNDEF NO_USE_CUSTOM_TOOLTIP}
const
  MOUSE_BUTTON_LEFT	= 1;
  MOUSE_BUTTON_RIGHT	= 2;
  MOUSE_BUTTON_MIDDLE	= 3;

type
  {マウスの状態}
  TTrayIconMouseState	= (timsLDown, timsRDown, timsMDown, timsEnter);
  TTrayIconMouseStates	= set of TTrayIconMouseState;

  TCustomToolTipStyle	=class(TPersistent)
  protected
    FOwnerHWnd,				{タスクトレイアイコンハンドル}
    FHTooltip		:HWND;		{ツールチップウインドウハンドル}

    FIconRect		:TRect;		{タスクトレイ上のアイコンの領域}
    {FExitMouse		:Boolean;	{True:マウスカーソルがアイコン外にある}
    FThread		:TThread;	{マウスのIn/Outを判定するためのスレッド}
    FMouseStates	:TTrayIconMouseStates;	{マウスカーソルの状態}
    FWaitClick		:Boolean;
    {プロパティ}
    FRequestSglDbl	:Boolean;	{True:シングルクリックとダブルクリックを判定する}
    FUseDefault		:Boolean;	{True:デフォルトのヒント表示を行う}
    FHintFont		:TFont;
    //FDelayTimeAutoPop	:Integer;	{遅延時間}
    //FDelayTimeInitial	:Integer;
    //FDelayTimeReshow	:Integer;
    FBackGrdColor	:TColor;	{背景色}
    //FMaxTipWidth	:Integer;	{TipWiondow最大幅}
    //FMargin		:TRect;		{上下左右マージン}
  public
    constructor Create;
    destructor Destroy; override;

  protected
    {<< プロパティIO >>}
    {オーナーの設定}
    procedure SetOwner(aOwnerHWND	:HWND);

    {指定マウス状態であるか}
    function GetMouseState(aTrayIconMouseState: TTrayIconMouseState): Boolean;
    {待機中のマウスボタン}
    function GetWaitClickButton: TTrayIconMouseState;

    {遅延時間
    function GetDelayTime(aIndex: Integer): Integer;
    procedure SetDelayTime(aIndex: Integer; aValue: Integer);}
    {テキスト・背景色}
    function GetColor(aIndex: Integer): TColor;
    procedure SetColor(aIndex: Integer; aColor: TColor);
    {テキストサイズ
    function GetTextSize: Integer;
    procedure SetTextSize(aValue: Integer);}
    {フォント
    function GetFont: TFont;
    procedure SetFont(aFont: TFont);}
    {TipWindow最大幅
    function GetMaxTipWidth: Integer;
    procedure SetMaxTipWidth(aValue: Integer);}
    {上下左右マージン
    function GetMargin(aIndex: Integer): Integer;
    procedure SetMargin(aIndex: Integer; aValue: Integer);}

  protected
    {メッセージ処理}
    procedure WndProc(var Message: TMessage);

    {ツールチップのハンドルを得る}
    {時計を除くすべてのアイコンは同じツールチップを共有しているらしい}
    function GetTooltipHandle: HWND;

    {マウスがアイコン内に入った時の処理}
    procedure OnMouseEnter;
    {マウスがアイコン外に出た時の処理}
    procedure OnMouseExit;

    {マウスクリック判定}
    procedure OnMouseClick(aMouseButton: TTrayIconMouseState);

    {タスクトレイアイコンのメッセージ処理}
    procedure TrayIconWndProc(var Message: TMessage);

    {トレイアイコン範囲を無効化する}
    procedure DisableTrayIconRect;

  public
    {データの複写}
    procedure Assign(aSource: TPersistent); override;

  protected
    {マウスイベント}
    procedure DoMouseEnter;
    procedure DoMouseExit;
    procedure DoMouseClick(aMouseButton: TTrayIconMouseState);
    procedure DoMouseDblClick(aMouseButton: TTrayIconMouseState);

    {ツールチップ変更}
    procedure SetCustomToolTip;
    {標準に戻す}
    procedure SetDefaultToolTip;

  protected
    property MouseEnter: Boolean index timsEnter read GetMouseState;
    property RequestSglDbl: Boolean read FRequestSglDbl write FRequestSglDbl;

    property UseDefault: Boolean read FUseDefault write FUseDefault;
    {遅延時間
    property DelayTimeAutoPopup: Integer index 1 read GetDelayTime write SetDelayTime default 5000;
    property DelayTimeInitial  : Integer index 2 read GetDelayTime write SetDelayTime default 500;
    property DelayTimeReshow   : Integer index 3 read GetDelayTime write SetDelayTime default 100;}
    {背景色}
    property BackGroundColor: TColor index 1 read GetColor write SetColor;
    {テキスト色とサイズ}
    property TextColor: TColor index 2 read GetColor write SetColor;
    {property TextSize: Integer read GetTextSize write SetTextSize default 9;}

    {フォントインスタンス
    property HintFont: TFont read GetFont write SetFont;}

    {最大幅...効果ないみたいです
    property MaxTipWidth: Integer read GetMaxTipWidth write SetMaxTipWidth default 400;}
    {上下左右マージン
    property MarginTop   : Integer index 1 read GetMargin write SetMargin default 0;
    property MarginLeft  : Integer index 2 read GetMargin write SetMargin default 0;
    property MarginRight : Integer index 3 read GetMargin write SetMargin default 0;
    property MarginBottom: Integer index 4 read GetMargin write SetMargin default 0;}
  end;

  TToolTipStyle	=class(TCustomToolTipStyle)
  public
    property RequestSglDbl;

  published
    property UseDefault;
    {遅延時間...効果ないみたいです
    property DelayTimeAutoPopup default 5000;
    property DelayTimeInitial default 500;
    property DelayTimeReshow default 100;}
    {背景色}
    property BackGroundColor;
    {テキスト色とサイズ}
    property TextColor;
    {...効果ないみたいです
    property TextSize default 9;
    property HintFont;}
    {最大幅...効果ないみたいです
    property MaxTipWidth default 400;}
    {上下左右マージン...効果ないみたいです
    property MarginTop;
    property MarginLeft;
    property MarginRight;
    property MarginBottom;}
  end;

{プロパティ:遅延時間について
DelayTimeAutoPopup
  トレイアイコンに外接する四角形の内側でポインタが停止しているときに
  ツールチップヒントウインドウを表示している時間

DelayTimeInitial
  トレイアイコンに外接する四角形の内側でポインタが停止してからツールチップ
  ヒントウインドウを表示するまでの時間

DelayTimeReshow
  ポインタが別のトレイアイコンに移動してから次のツールチップヒントウインドウを
  表示するまでの時間
}
{$ENDIF}

{************************************************************************}
{* 	タスクトレイアイコン表示用クラス				*}
{************************************************************************}
type
  {バルーンチップヘルプのアイコンタイプ}
  TBalloonIconType	= (bitNone, bitInfo, bitWarning, bitError);
  {タスクトレイアイコンのアイコン状況}
  TOnTrayIconFlag	= (otifRegisted, otifShowing);
  TOnTrayIconFlags	= set of TOnTrayIconFlag;

  TTaskTrayIcon	=class
  private
    {FShellNew		:Boolean;		{True:Shell32.dll がVer5.0以降}
    FShell32Ver		:Integer;		{Shell32.dllのバージョン}
    FUpdateCount	:Integer;
  protected
    FTrayHandle		:HWnd;			{タスクトレイ用 Handle}
    FIconData		:TNewNotifyIconData;	{トレイアイコンデータ}
   {FOnTaskTray		:Boolean;		{True:タスクトレイに表示中}
    FOnTrayIconFlag	:TOnTrayIconFlags;	{タスクトレイへのアイコン表示状態}
    FEnabledHide	:Boolean;		{True: アイコン非表示は隠す処理にする
						 ShellNewVersion = True のときのみ有効}
    FOnMessage		:TOnMessage;		{メッセージ処理}

    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    FToolTipStyle	:TToolTipStyle;		{ツールチップを変化させるクラス}
    {$ENDIF}
  public
    FrontToWindow	:Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    {プロパティ複写}
    procedure Assign(aDest	:TTaskTrayIcon);

  protected
    {タスクトレイ用WindowProcedure}
    procedure TrayWndProc(var Message: TMessage);

    {タスクトレイ登録用ハンドルの取得}
    function GetTrayHandle:HWnd;

    {マウスがアイコン内に入った時の処理}
    procedure DoMouseEnter;
    {マウスがアイコン外に出た時の処理}
    procedure DoMouseExit;

    {タスクトレイにアイコンが登録されているか}
    function GetIconRegisted: Boolean;
    procedure SetIconRegisted(aValue: Boolean);
    {タスクトレイにアイコンが表示されているか}
    function GetOnTaskTray: Boolean;
    procedure SetOnTaskTray(aValue: Boolean);

  public
    {プロパティIO}
    {トレイに登録するアイコンのハンドル}
    function GetIconHandle:HICON;
    procedure SetIconHandle(aIconHandle	:HICON);

    {トレイで表示するテキスト}
    function GetTipHelp:String;
    procedure SetTipHelp(aTipHelp	:String);

    {<<<<< Windows2000 + IE5.0以降 >>>>>}
    {Shell32.dllのバージョンが 5.0以降}
    function GetShellNewVersion: Boolean;

    {バルーンヘルプのタイトル}
    function GetBalloonHelpTitle:String;
    procedure SetBalloonHelpTitle(aHelpTitle	:String);

    {バルーンヘルプのテキスト}
    function GetBalloonHelp:String;
    procedure SetBalloonHelp(aHelpText	:String);

    {トレイで表示するバルーンヘルプのタイムアウト}
    function GetUTimeOut:Integer;
    procedure SetUTimeOut(aValue	:Integer);

    {バルーンヘルプで表示するアイコンの種類}
    function GetBalloonIconType:TBalloonIconType;
    procedure SetBalloonIconType(aValue	:TBalloonIconType);
    {<<<<< ここまで >>>>>}

  public
    {内部情報の更新開始}
    procedure BeginUpdate;
    {内部情報の更新終了}
    procedure EndUpdate;
    {内部情報の更新完了}
    procedure FinishUpdate;

    {更新中判定}
    function Updating: Boolean;	{True:更新中}

    {トレイにアイコン登録}
    function SetTrayIcon:Boolean;

    {トレイからアイコン解除}
    function HideTrayIcon:Boolean;
    function DeleteTrayIcon:Boolean;

    {トレイアイコンの変更}
    function ModifyIcon:Boolean;

    {バルーンヘルプを表示する}
    function ShowBalloonHelpSE(aHelpTitle,			{タイトル}
    			       aHelpText	:String;	{メッセージ}
                               aTimeOut		:Integer;	{タイムアウト(ミリ秒)}
                               aIconType	:TBalloonIconType)
                             			:Boolean;	{True:成功}

    function ShowBalloonHelp: Boolean;	{True:成功}

    {バルーンヘルプを閉じる}
    function HideBalloonHelp: Boolean;	{True:成功}

    {アイコン内にカーソルがあるか}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    function IsCursorInnerRect(aX, aY: Integer): Boolean;
    {$ENDIF}

  public
    {プロパティ}
    property Icon:HICON read GetIconHandle write SetIconHandle;
    property IconRegisted: Boolean read GetIconRegisted write SetIconRegisted;	{True: タスクトレイにアイコン登録済み}
    property OnTaskTray: Boolean read GetOnTaskTray write SetOnTaskTray;	{True: タスクトレイにアイコン表示中}
    property Shell32Version: Integer read FShell32Ver;
    property ShellNewVersion: Boolean read GetShellNewVersion;			{True: Shell32.dllのバージョンが 5.0 以降}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    property ToolTipStyle: TToolTipStyle read FToolTipStyle;
    {$ENDIF}
    property TrayHandle: HWnd read GetTrayHandle;
    {イベント}
    property OnMessage:TOnMessage read FOnMessage write FOnMessage;
  end;

{************************************************************************}
{*	TaskTrayIconClass用MessageHandler				*}
{************************************************************************}
type
  TTrayIconWinProcList	= class(TList)
  protected
    uTaskbarRestart	:UINT;
  public
    {クリエイト}
    constructor Create;
    {破棄}
    destructor Destroy; override;

  protected
    {クラスをWindowsに登録する}
    procedure RegisterClass;
    {クラスをWindowsから削除する}
    procedure UnRegisterClass;

    {メッセージ処理}
    function MessageDeliver(aHWND	:HWND;
    			    var Message	:TMessage)
                          		:Boolean;	{True:処理した}

  public
    {クラスを追加する}
    procedure AddClass(aTaskTrayIcon	:TTaskTrayIcon);
    {クラスを削除する}
    procedure DeleteClass(aTaskTrayIcon	:TTaskTrayIcon);

  end;

{************************************************************************}
{* 	関数定義							*}
{************************************************************************}
{Shell32.dllのバージョンを得る}
function GetShellDllVersion:Longint;

{/////////////////////////////////////////////////////////////////////////////}
implementation
{/////////////////////////////////////////////////////////////////////////////}

uses
  SysUtils, CommCtrl, ShellApi;

{************************************************************************}
{* 	ローカルインスタンス						*}
{************************************************************************}
var
  {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
  {ToolTipClass		:TCustomToolTipStyle;}
  {$ENDIF}
  TrayIconWinProcList	:TTrayIconWinProcList;

{************************************************************************}
{* 	ローカル定数定義						*}
{************************************************************************}
(*...CommCtrl.pas ユニットに定義済み...
const
  TOOLTIPS_CLASS	= 'tooltips_class32';
  TTS_NOPREFIX		= 2;

  {ツールチップ定数}
  TTM_SETTIPBKCOLOR	= WM_USER + 19; // 背景色の設定
  TTM_SETTIPTEXTCOLOR	= WM_USER + 20; // テキスト色の設定
  TTM_GETDELAYTIME	= WM_USER + 21; // 遅延時間の取得
  TTM_GETTIPBKCOLOR	= WM_USER + 22; // 背景色の取得
  TTM_GETTIPTEXTCOLOR	= WM_USER + 23; // テキスト色の取得
  TTM_SETMAXTIPWIDTH	= WM_USER + 24; // チップウィンドウの最大幅の設定
  TTM_GETMAXTIPWIDTH	= WM_USER + 25; // チップウィンドウの最大幅の取得
  TTM_SETMARGIN		= WM_USER + 26; // マージンの設定
  TTM_GETMARGIN		= WM_USER + 27; // マージンの取得
  TTM_POP		= WM_USER + 28; // 強制消去
  TTM_UPDATE		= WM_USER + 29; // 強制再描画  // Tooltip constants
  TTM_SETTITLEA		= WM_USER + 32;

  {遅延時間(DelayTime) の取得設定用}
  TTDT_AUTOMATIC	= 0;
  TTDT_RESHOW		= 1;
  TTDT_AUTOPOP		= 2;
  TTDT_INITIAL		= 3;
*)

{************************************************************************}
{* 	TaskTrayWindowProc						*}
{************************************************************************}
function TaskTrayProc(hWnd	:HWND;
		      aMsg	:Longword;
		      wParam	:Longint;
		      lParam	:Longint)
				:Longint; stdcall;
  var
    msg		:TMessage;
    defProc	:Boolean;
  begin
    Result := 0;
    defProc := True;
    if TrayIconWinProcList <> nil then begin
      msg.Msg := aMsg;
      msg.WParam := wParam;
      msg.LParam := lParam;
      if TrayIconWinProcList.MessageDeliver(hWnd, msg) then begin
        Result := msg.Result;
        defProc := False;
      end;
    end;
    {標準メソッド}
    if defProc then begin
      Result := DefWindowProc(hWnd, aMsg, wParam, lParam);
    end;
  end;

{************************************************************************}
{*	Mouse Enter/Reave イベント発生用Thread				*}
{************************************************************************}
{$IFNDEF NO_USE_CUSTOM_TOOLTIP}
type
  TMouseEventMaker = class(TThread)
  private
    Owner	:TCustomToolTipStyle;
  public
    constructor Create(AOwner	:TCustomToolTipStyle);
    destructor Destroy; override;

  protected
    procedure Execute; override;
    procedure OnMouseExit;
  end;

constructor TMouseEventMaker.Create(aOwner	:TCustomToolTipStyle);
  begin
    inherited Create(True);
    Owner := aOwner;
  end;
destructor TMouseEventMaker.Destroy;
  begin
    inherited Destroy;
  end;
procedure TMouseEventMaker.Execute;
  begin
    while not Terminated do begin
      if (not Owner.MouseEnter) and (not Suspended) then Suspend;
      {待機}
      Sleep(100);
      {マウス外判定}
      Synchronize(OnMouseExit);
    end;
  end;

procedure TMouseEventMaker.OnMouseExit;
  begin
    {マウスのアイコン外判定を行う}
    Owner.OnMouseExit;
  end;
{$ENDIF}

{************************************************************************}
{* 	ローカル関数							*}
{************************************************************************}
CONST
  {タスクトレイのアイコンのサイズ}
  TASKTRAY_ICONSIZE	= {16}32;	{自動で隠れることもあるので倍のサイズで様子見}
  {無効な範囲定数}
  DISABLE_RECT	:TRect=(Left:0; Top:0; Right:0; Bottom:0);

{範囲を無効化する:タスクトレイのアイコンが(0.0)を含む範囲にならないことが前提}
procedure DisableRect(var aRect :TRect);
  begin
    {FillChar(aRect, SizeOf(TRect), #$0);}
    aRect := DISABLE_RECT;
  end;

{矩形範囲を更新する}
procedure UpdateRect(var aRect :TRect; aPos: TPoint);
  begin
    {...2003.05.17
    if (aRect.Left = 0) and (aRect.Top = 0) and
       (aRect.Right = 0) and (aRect.Bottom = 0) then begin
    ...}
    if (aRect.Left  = DISABLE_RECT.Left)  and (aRect.Top = DISABLE_RECT.Top) and
       (aRect.Right = DISABLE_RECT.Right) and (aRect.Bottom = DISABLE_RECT.Bottom) then begin
      aRect.TopLeft     := aPos;
      aRect.BottomRight := aPos;
    end
    else begin
      {左右範囲の更新}
      if aRect.Left > aPos.x then aRect.Left := aPos.x
      else if aRect.Right < aPos.x then aRect.Right := aPos.x;
      {上下範囲の更新}
      if aRect.Top > aPos.y then aRect.Top := aPos.y
      else if aRect.Bottom < aPos.y then aRect.Bottom := aPos.y;
    end;
  end;

{点が範囲内であるか}
function IsInnerRect(aRect :TRect; aPos: TPoint): Boolean;
  begin
    Result := (aRect.Left <= aPos.x) and (aRect.Right  >= aPos.x) and
              (aRect.Top  <= aPos.Y) and (aRect.Bottom >= aPos.y);
  end;

{TrayIconWinProcListに登録}
procedure AddTrayIconWinProcList(aClass	:TTaskTrayIcon);
  begin
    if TrayIconWinProcList = nil then begin
      TrayIconWinProcList := TTrayIconWinProcList.Create;
    end;
    TrayIconWinProcList.AddClass(aClass);
  end;
{TrayIconWinProcListから削除}
procedure DelTrayIconWinProcList(aClass	:TTaskTrayIcon);
  begin
    if TrayIconWinProcList <> nil then begin
      TrayIconWinProcList.DeleteClass(aClass);
      if TrayIconWinProcList.Count = 0 then begin
	TrayIconWinProcList.Free;
	TrayIconWinProcList := nil;
      end;
    end;
  end;

{$IFNDEF NO_USE_CUSTOM_TOOLTIP}
{************************************************************************}
{* 	カスタムツールチップクラス					*}
{************************************************************************}
constructor TCustomToolTipStyle.Create;
  begin
    inherited Create;
    {クリエイト}
    FHintFont		:= TFont.Create;
    {初期化}
    FOwnerHWnd		:= 0;
    FHTooltip		:= GetTooltipHandle;
    FRequestSglDbl	:= True;
    FUseDefault 	:= True;
    {FExitMouse		:= True;}
    FThread		:= nil;
    FMouseStates	:= [];
    DisableTrayIconRect;
    {遅延時間
    FDelayTimeAutoPop	:= 5000;
    FDelayTimeInitial	:= 500;
    FDelayTimeReshow	:= 100;}
    {背景色
    FBackGrdColor	:= GetSysColor(COLOR_INFOBK);}
    {テキスト色
    FHintFont.Color	:= GetSysColor(COLOR_INFOTEXT);}
    {最大幅
    FMaxTipWidth	:= 400;}
    {上下左右マージン
    FillChar(FMargin, SizeOf(TRect), #$0);}

    {ToolTipClass	:= Self;}
  end;

destructor TCustomToolTipStyle.Destroy;
  begin
    if FThread <> nil then begin
      if not FThread.Suspended then begin
        FThread.Terminate;
        FThread.WaitFor;
      end;
      FThread.Free;
    end;
    {デフォルト設定に戻す}
    SetDefaultToolTip;
    {破棄}
    FHintFont.Free;
    inherited Destroy;
  end;

{<< プロパティIO >>}
{オーナーの設定}
procedure TCustomToolTipStyle.SetOwner(aOwnerHWND	:HWND);
  begin
    FOwnerHWnd	:= aOwnerHWND;
  end;

{指定マウス状態であるか}
function TCustomToolTipStyle.GetMouseState(aTrayIconMouseState: TTrayIconMouseState): Boolean;
  begin
    Result := aTrayIconMouseState in FMouseStates;
  end;

{待機中のマウスボタン}
function TCustomToolTipStyle.GetWaitClickButton: TTrayIconMouseState;
  begin
    if 	    timsLDown in FMouseStates then Result := timsLDown
    else if timsRDown in FMouseStates then Result := timsRDown
    else 				   Result := timsMDown;
  end;

{遅延時間
function TCustomToolTipStyle.GetDelayTime(aIndex: Integer): Integer;
  begin
    case aIndex of
      1	:  Result := FDelayTimeAutoPop;
      2	:  Result := FDelayTimeInitial;
      3	:  Result := FDelayTimeReshow;
      else Result := -1;
    end;
  end;
procedure TCustomToolTipStyle.SetDelayTime(aIndex: Integer; aValue: Integer);
  begin
    if aValue < -1 then aValue := -1;
    case aIndex of
      1	:  FDelayTimeAutoPop := aValue;
      2	:  FDelayTimeInitial := aValue;
      3	:  FDelayTimeReshow  := aValue;
    end;
  end;}

{色}
function TCustomToolTipStyle.GetColor(aIndex: Integer): TColor;
  begin
    case aIndex of
      1	:  Result := FBackGrdColor;
      2	:  Result := FHintFont.Color;
      else Result := clBlack;
    end;
  end;
procedure TCustomToolTipStyle.SetColor(aIndex: Integer; aColor: TColor);
  begin
    case aIndex of
      1	:  FBackGrdColor := aColor;
      2	:  FHintFont.Color := aColor;
    end;
  end;

{テキストサイズ
function TCustomToolTipStyle.GetTextSize: Integer;
  begin
    Result := FHintFont.Size;
  end;
procedure TCustomToolTipStyle.SetTextSize(aValue: Integer);
  begin
    FHintFont.Size := aValue;
  end;}

{フォント
function TCustomToolTipStyle.GetFont: TFont;
  begin
    Result := FHintFont;
  end;
procedure TCustomToolTipStyle.SetFont(aFont: TFont);
  begin
    FHintFont.Assign(aFont);
  end;}

{TipWindow最大幅
function TCustomToolTipStyle.GetMaxTipWidth: Integer;
  begin
    Result := FMaxTipWidth;
  end;
procedure TCustomToolTipStyle.SetMaxTipWidth(aValue: Integer);
  begin
    if aValue < -1 then aValue := -1;
    FMaxTipWidth := aValue;
  end;}

{上下左右マージン
function TCustomToolTipStyle.GetMargin(aIndex: Integer): Integer;
  begin
    case aIndex of
      1	:  Result := FMargin.Top;
      2	:  Result := FMargin.Left;
      3	:  Result := FMargin.Right;
      4	:  Result := FMargin.Bottom;
      else Result := 0;
    end;
  end;
procedure TCustomToolTipStyle.SetMargin(aIndex: Integer; aValue: Integer);
  begin
    if aValue < -1 then aValue := -1;
    case aIndex of
      1	:  FMargin.Top	  := aValue;
      2	:  FMargin.Left	  := aValue;
      3	:  FMargin.Right  := aValue;
      4	:  FMargin.Bottom := aValue;
    end;
  end;}

{メッセージ処理}
procedure TCustomToolTipStyle.WndProc(var Message: TMessage);
  {...
  var
    phdr: PNMHdr;
  begin
    case Message.Msg of
      WM_NOTIFY:begin
        phdr := Pointer(Message.LParam);
        case phdr^.code of
          TTN_POP :if Assigned(FOnHide) then FOnHide(AMsg,phdr^);
          TTN_SHOW:if Assigned(FOnShow) then FOnShow(AMsg,phdr^);
        end;
      end;
    end;
  end;
  ...}
  begin

  end;
  
{ツールチップのハンドルを得る}
{時計を除くすべてのアイコンは同じツールチップを共有しているらしい}
function TCustomToolTipStyle.GetTooltipHandle: HWND;
  var
    toolTopWnd,
    hTaskBar		:HWND;
    pidTaskBar,
    pidToolTopWnd	:DWORD;
  begin
    {TaskBar Handle の取得}
    hTaskBar := FindWindowEx(0, 0, 'Shell_TrayWnd', nil);
    {TaskBar の Process ID を取得する}
    GetWindowThreadProcessId(hTaskBar, @pidTaskBar);
    {Tooltip Window の検索}
    toolTopWnd := FindWindowEx(0, 0, TOOLTIPS_CLASS, nil);

    while toolTopWnd <> 0 do begin
      {Tooltip の Process ID を取得}
      GetWindowThreadProcessId(toolTopWnd, @pidToolTopWnd);
      {タスクバーとツールチップの Process ID を比較して、一致していたらタスクバーのツールチップとする}
      if pidTaskBar = pidToolTopWnd then begin
	{ツールチップのウインドウスタイルを調査する}
	if (GetWindowLong(toolTopWnd, GWL_STYLE) and TTS_NOPREFIX) = 0 then begin
	  Break;
	end;
      end;
      {再度 Tooltip Window の検索}
      toolTopWnd := FindWindowEx(0, toolTopWnd, TOOLTIPS_CLASS, nil);
    end;
    {結果}
    Result := toolTopWnd;
  end;

{マウスイベント}
procedure TCustomToolTipStyle.OnMouseEnter;
  var
    cursorPos	:TPoint;
  begin
    {マウスカーソルの位置を取得}
    GetCursorPos(cursorPos);
    {範囲更新}
    UpdateRect(FIconRect, cursorPos);
    {2003.05.17...タスクバーの位置が変更になったとき用}
    if (Abs(FIconRect.Right - FIconRect.Left) > TASKTRAY_ICONSIZE) or
       (Abs(FIconRect.Bottom - FIconRect.Top) > TASKTRAY_ICONSIZE) then begin
      {アイコン領域がアイコンサイズを超えてしまったとき、タスクバーが移動したりしたかな？}
      {領域無効}
      DisableTrayIconRect;
      {再度範囲更新}
      UpdateRect(FIconRect, cursorPos);
    end;
    {マウスINイベント}
    if not MouseEnter then DoMouseEnter;
  end;

procedure TCustomToolTipStyle.OnMouseExit;
  var
    cursorPos	:TPoint;
  begin
    if MouseEnter then begin
      {マウスカーソルの位置を取得}
      GetCursorPos(cursorPos);
      {アイコン領域内にあるか調査}
      if not IsInnerRect(FIconRect, cursorPos) then DoMouseExit;
    end;
  end;

const
  TIMER_ID	= 7;

{マウスクリック判定}
procedure TCustomToolTipStyle.OnMouseClick(aMouseButton: TTrayIconMouseState);
  begin
    if FRequestSglDbl then begin
      if (not FWaitClick) and
         (SetTimer(FOwnerHWnd, TIMER_ID, GetDoubleClickTime, @TaskTrayProc) <> 0) then begin
        FWaitClick := True;
      end;
    end
    else begin
      DoMouseClick(aMouseButton);
      Exclude(FMouseStates, aMouseButton);
    end;
  end;

{タスクトレイアイコンのメッセージ処理}
procedure TCustomToolTipStyle.TrayIconWndProc(var Message: TMessage);
  begin
    if Message.Msg = WM_TaskTrayMessage then begin
      case Message.lParam of
        {マウスイン判定}
        WM_MOUSEMOVE	:OnMouseEnter;
        {クリック待機}
        WM_LBUTTONDOWN	:if Message.WParam >= 0 then Include(FMouseStates, timsLDown);
        WM_RBUTTONDOWN	:if Message.WParam >= 0 then Include(FMouseStates, timsRDown);
        WM_MBUTTONDOWN	:if Message.WParam >= 0 then Include(FMouseStates, timsMDown);
        {クリック判定}
        WM_LBUTTONUP	:OnMouseClick(timsLDown);
        WM_RBUTTONUP	:OnMouseClick(timsRDown);
        WM_MBUTTONUP	:OnMouseClick(timsMDown);
        {ダブルクリック処理}
        WM_LBUTTONDBLCLK:DoMouseDblClick(timsLDown);
        WM_RBUTTONDBLCLK:DoMouseDblClick(timsRDown);
        WM_MBUTTONDBLCLK:DoMouseDblClick(timsMDown);
      end;
    end
    else if Message.Msg = WM_TIMER then begin
      KillTimer(FOwnerHWnd, TIMER_ID);
      if FWaitClick then DoMouseClick(GetWaitClickButton);
    end;
  end;

{トレイアイコン範囲を無効化する}
procedure TCustomToolTipStyle.DisableTrayIconRect;
  begin
    DisableRect(FIconRect);
  end;

{データの複写}
procedure TCustomToolTipStyle.Assign(aSource: TPersistent);
  begin
    inherited Assign(aSource);
    if aSource is TCustomToolTipStyle then begin
      FUseDefault	:= TCustomToolTipStyle(aSource).FUseDefault;	{True:デフォルトのヒント表示を行う}
      FBackGrdColor	:= TCustomToolTipStyle(aSource).FBackGrdColor;
    end;
  end;

procedure TCustomToolTipStyle.DoMouseEnter;
  begin
    {フラグオン}
    Include(FMouseStates, timsEnter);
    {ツールチップヘルプ変更}
    if not FUseDefault then SetCustomToolTip;
    {クリエイト}
    if FThread = nil then FThread := TMouseEventMaker.Create(Self);
    {スレッド開始}
    if FThread.Suspended then FThread.Resume;
    {オーナーに通知}
    if FOwnerHWnd <> 0 then
      SendMessage(FOwnerHWnd, WM_TaskTrayMessage, 0, WM_MOUSE_ENTER);
  end;

procedure TCustomToolTipStyle.DoMouseExit;
  begin
    {フラグオフ}
    Exclude(FMouseStates, timsEnter);
    {ツールチップヘルプを戻す}
    if not FUseDefault then SetDefaultToolTip;
    {タスクトレイアイコン範囲解放
    DisableTrayIconRect;}
    {オーナーに通知}
    if FOwnerHWnd <> 0 then
      SendMessage(FOwnerHWnd, WM_TaskTrayMessage, 0, WM_MOUSE_EXIT);
  end;

{マウスクリック}
procedure TCustomToolTipStyle.DoMouseClick(aMouseButton: TTrayIconMouseState);
  begin
    if (aMouseButton in FMouseStates) and (FOwnerHWnd <> 0) then begin
      SendMessage(FOwnerHWnd, WM_TaskTrayMessage, Ord(aMouseButton), WM_MOUSE_CLICK);
    end;
    {フラグオフ}
    FWaitClick := False;
    Exclude(FMouseStates, aMouseButton);
  end;

{マウスダブルクリック}
procedure TCustomToolTipStyle.DoMouseDblClick(aMouseButton: TTrayIconMouseState);
  begin
    {フラグオフ}
    FWaitClick := False;
    Exclude(FMouseStates, aMouseButton);
    {マウスダウンベント発行}
    case aMouseButton of
      timsLDown:
        PostMessage(FOwnerHWnd, WM_TaskTrayMessage, -1, WM_LBUTTONDOWN);
      timsRDown:
        PostMessage(FOwnerHWnd, WM_TaskTrayMessage, -1, WM_RBUTTONDOWN);
      timsMDown:
        PostMessage(FOwnerHWnd, WM_TaskTrayMessage, -1, WM_MBUTTONDOWN);
    end;
  end;

{ツールチップ変更}
procedure TCustomToolTipStyle.SetCustomToolTip;
  begin
    if FHTooltip = 0 then Exit;
    {フォント設定
    SendMessage(FHTooltip, WM_SETFONT, FHintFont.Handle, 1);}
    {遅延時間
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_AUTOPOP, FDelayTimeAutoPop);
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_INITIAL, FDelayTimeInitial);
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_RESHOW , FDelayTimeReshow);}
    {背景色}
    SendMessage(FHTooltip, TTM_SETTIPBKCOLOR, FBackGrdColor, 0);
    {テキスト色}
    SendMessage(FHTooltip, TTM_SETTIPTEXTCOLOR, FHintFont.Color, 0);
    {最大幅
    SendMessage(FHTooltip, TTM_SETMAXTIPWIDTH, 0, FMaxTipWidth);}
    {上下左右マージン  
    SendMessage(FHTooltip, TTM_SETMARGIN, 0, LParam(@(FMargin)));}
  end;

procedure TCustomToolTipStyle.SetDefaultToolTip;
  begin
    if FHTooltip = 0 then Exit;
    {強制消去}
    SendMessage(FHTooltip, TTM_POP, 0, 0);
    {<< デフォルト設定に戻す >>}
    {フォントの設定
    SendMessage(FHTooltip, WM_SETFONT, 0, 1);}
    {遅延時間
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 0);}
    {背景色}
    SendMessage(FHTooltip, TTM_SETTIPBKCOLOR, GetSysColor(COLOR_INFOBK), 0);
    {テキスト色}
    SendMessage(FHTooltip, TTM_SETTIPTEXTCOLOR, GetSysColor(COLOR_INFOTEXT), 0);
    {最大幅
    SendMessage(FHTooltip, TTM_SETMAXTIPWIDTH, 0, -1);}
    {上下左右マージン
    FillChar(tipRect, SizeOf(TRect), #$0);
    SendMessage(FHTooltip, TTM_SETMARGIN, 0, LParam(@(tipRect)));}
  end;
{$ENDIF}

{************************************************************************}
{* 	各種定義							*}
{************************************************************************}
type
  {ENotifyIconError例外の定義}
  ENotifyIconError = class(Exception);

{************************************************************************}
{* 	タスクトレイアイコン表示用クラス				*}
{************************************************************************}
constructor TTaskTrayIcon.Create;
  begin
    inherited Create;
    {登録}
    AddTrayIconWinProcList(Self);
    {クリエイト}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    FToolTipStyle := TToolTipStyle.Create;
    {$ENDIF}
    {Shell32.dllのバージョンチェック
    FShellNew := GetShellDllVersion >= MakeLong(0, 5);}
    FShell32Ver := GetShellDllVersion;

    {構造体初期化}
    FillChar(FIconData, SizeOf(TNewNotifyIconData), #0);
    {プロパティ等初期化}
    FUpdateCount	:= 0;
    FTrayHandle		:= 0;
    {FOnTaskTray	:= False;}
    FOnTrayIconFlag	:= [];
    FEnabledHide	:= True;
    FOnMessage		:= nil;
    FrontToWindow	:= False;
  end;

destructor TTaskTrayIcon.Destroy;
  begin
    {破棄}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    if FToolTipStyle <> nil then FToolTipStyle.Free;
    {$ENDIF}
    {トレイからアイコン削除}
    DeleteTrayIcon;
    if FTrayHandle <> 0 then DestroyWindow(FTrayHandle);
    {解除}
    DelTrayIconWinProcList(Self);
    inherited Destroy;
  end;

{プロパティ複写}
procedure TTaskTrayIcon.Assign(aDest	:TTaskTrayIcon);

  begin
    FIconData := aDest.FIconData;
    ModifyIcon;
  end;

{タスクトレイ用WindowProcedure}
procedure TTaskTrayIcon.TrayWndProc(var Message: TMessage);
  begin
    if (Message.Msg = TrayIconWinProcList.uTaskbarRestart) then begin
      {タスクトレイアイコンへの再表示}
      if IconRegisted then begin
        if OnTaskTray then begin
          {一度未登録状態に更新し、再登録処理を行う}
	  IconRegisted := False;
	  SetTrayIcon;
        end
        else begin
          {未登録状態に更新する}
          IconRegisted := False;
        end;
      end;
      {タスクバー再起動メッセージの発行}
      Message.Msg := WM_TASKBER_RESTART;
      FOnMessage(Message);
      Message.Msg := TrayIconWinProcList.uTaskbarRestart;
    end;
    {ツールチップ変更クラスへの通知}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    FToolTipStyle.TrayIconWndProc(Message);
    {$ENDIF}
    {標準処理}
    if Assigned(FOnMessage) then begin
      FOnMessage(Message);
    end
    else begin
      with Message do
	Result := DefWindowProc(TrayHandle, Msg, WParam, LParam);
    end;
  end;

{タスクトレイ登録用ハンドルの取得}
function TTaskTrayIcon.GetTrayHandle:HWnd;
  begin
    if FTrayHandle = 0 then begin
      {ウインドウ作成}
      FTrayHandle := CreateWindowEx(WS_EX_TOOLWINDOW, TRAY_ICON_WINDOW_CLASS_NAME,
				    '', WS_POPUP, 0, 0, 0, 0, 0, 0, hInstance, nil);
      {ツールチップクラスの作成}
      {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
      FToolTipStyle.SetOwner(FTrayHandle);
      {$ENDIF}
    end;
    Result := FTrayHandle;
  end;

{マウスがアイコン内に入った時の処理}
procedure TTaskTrayIcon.DoMouseEnter;
  begin
    {Mouse Enter Event}
    if FTrayHandle <> 0 then begin
      SendMessage(FTrayHandle, WM_TaskTrayMessage, 0, WM_MOUSE_ENTER);
    end;
  end;

{マウスがアイコン外に出た時の処理}
procedure TTaskTrayIcon.DoMouseExit;
  begin
    {Mouse Exit Event}
    if FTrayHandle <> 0 then begin
      SendMessage(FTrayHandle, WM_TaskTrayMessage, 0, WM_MOUSE_EXIT);
    end;
  end;

{タスクトレイにアイコンが登録されているか}
function TTaskTrayIcon.GetIconRegisted: Boolean;
  begin
    Result := otifRegisted in FOnTrayIconFlag;
  end;
procedure TTaskTrayIcon.SetIconRegisted(aValue: Boolean);
  begin
    {内部的なフラグの処理のみのため現在の値との比較しない}
    //if GetIconRegisted <> aValue then begin
    if aValue then begin
      Include(FOnTrayIconFlag, otifRegisted);	{登録}
      Include(FOnTrayIconFlag, otifShowing);	{表示}
    end
    else begin
      Exclude(FOnTrayIconFlag, otifRegisted);	{未登録}
      Exclude(FOnTrayIconFlag, otifShowing);	{非表示}
    end;
  end;
{タスクトレイにアイコンが表示されているか}
function TTaskTrayIcon.GetOnTaskTray: Boolean;
  begin
    Result := otifShowing in FOnTrayIconFlag;
  end;
procedure TTaskTrayIcon.SetOnTaskTray(aValue: Boolean);
  begin
    if aValue then begin
      Include(FOnTrayIconFlag, otifShowing);
    end
    else begin
      Exclude(FOnTrayIconFlag, otifShowing);
    end;
  end;

{トレイに登録するアイコンのハンドルを得る}
function TTaskTrayIcon.GetIconHandle:HICON;
  begin
    Result := FIconData.hIcon;
  end;
procedure TTaskTrayIcon.SetIconHandle(aIconHandle	:HICON);
  begin
    FIconData.hIcon := aIconHandle;
  end;

{トレイで表示するテキスト}
function TTaskTrayIcon.GetTipHelp:String;
  begin
    Result := FIconData.szTip;
  end;

procedure TTaskTrayIcon.SetTipHelp(aTipHelp	:String);
  begin
    if aTipHelp = '' then begin
      FIconData.szTip[0] := #0;
    end
    else begin
      {改行文字を含む場合スペースで置換する}
      if not GetShellNewVersion then
        StringReplace(aTipHelp, #$D#$A, ' ', [rfReplaceAll]);
      {チップヘルプの更新}
      if ShellNewVersion then StrPLCopy(@FIconData.szTip, PChar(aTipHelp), 127)
      else                    StrPLCopy(@FIconData.szTip, PChar(aTipHelp),  63);
    end;
  end;

{Shell32.dllのバージョンが 5.0以降}
function TTaskTrayIcon.GetShellNewVersion: Boolean;
  begin
    Result := FShell32Ver >= MakeLong(0, 5);
  end;

{バルーンヘルプのタイトル}
function TTaskTrayIcon.GetBalloonHelpTitle:String;
  begin
    Result := FIconData.szInfoTitle;
  end;
procedure TTaskTrayIcon.SetBalloonHelpTitle(aHelpTitle	:String);
  begin
    if aHelpTitle = '' then begin
      FIconData.szInfoTitle[0] := #0;
    end
    else begin
      StrPLCopy(@FIconData.szInfoTitle, PChar(aHelpTitle), 63);
    end;
  end;

{バルーンヘルプのテキスト}
function TTaskTrayIcon.GetBalloonHelp:String;
  begin
    Result := FIconData.szInfo;
  end;

procedure TTaskTrayIcon.SetBalloonHelp(aHelpText	:String);
  begin
    if aHelpText = '' then begin
      FIconData.szInfo[0] := #0;
    end
    else begin
      StrPLCopy(@FIconData.szInfo, PChar(aHelpText), 255);
    end;
  end;

{トレイで表示するのタイムアウト}
function TTaskTrayIcon.GetUTimeOut:Integer;
  begin
    Result := FIconData.uTimeout;
  end;

procedure TTaskTrayIcon.SetUTimeOut(aValue	:Integer);
  begin
    FIconData.uTimeout := aValue;
  end;

{バルーンヘルプで表示するアイコンの種類}
function TTaskTrayIcon.GetBalloonIconType:TBalloonIconType;
  begin
    Result := TBalloonIconType(FIconData.dwInfoFlags);
  end;
procedure TTaskTrayIcon.SetBalloonIconType(aValue	:TBalloonIconType);
  begin
    case aValue of
      bitInfo   :FIconData.dwInfoFlags := NIIF_INFO;
      bitWarning:FIconData.dwInfoFlags := NIIF_WARNING;
      bitError  :FIconData.dwInfoFlags := NIIF_ERROR;
      else       FIconData.dwInfoFlags := NIIF_NONE;
    end;
  end;

{内部情報の更新開始}
procedure TTaskTrayIcon.BeginUpdate;
  begin
    Inc(FUpdateCount);
  end;
{内部情報の更新終了}
procedure TTaskTrayIcon.EndUpdate;
  begin
    if FUpdateCount > 0 then Dec(FUpdateCount);
  end;
{内部情報の更新完了}
procedure TTaskTrayIcon.FinishUpdate;
  begin
    FUpdateCount := 0;
  end;

{更新中判定}
function TTaskTrayIcon.Updating: Boolean;	{True:更新中}
  begin
    Result := FUpdateCount > 0;
  end;

{トレイにアイコン登録}
function TTaskTrayIcon.SetTrayIcon:Boolean;
  {登録エラー時のリトライ}
  procedure retrySet(var aRetryCount	:Integer);
    begin
      if GetLastError = ERROR_TIMEOUT then begin
        {2秒待機}
	Sleep(2000);
	IconRegisted := True;
	if Shell_NotifyIcon(NIM_MODIFY, @FIconData) then begin
        {最初の登録に成功していたものとする}
	  IconRegisted := True;
	  {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
	  {タスクトレイのアイコン範囲を無効化する}
	  ToolTipStyle.DisableTrayIconRect;
	  {$ENDIF}
	end
        else begin
	{再度チャレンジ}
	  IconRegisted := False;
          if FrontToWindow then SetForegroundWindow(FTrayHandle);
	  if Shell_NotifyIcon(NIM_ADD, @FIconData) then begin
	    IconRegisted := True;
	    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
	    {タスクトレイのアイコン範囲を無効化する}
	    ToolTipStyle.DisableTrayIconRect;
	    {$ENDIF}
	  end
	  else if aRetryCount = 0 then begin
            raise ENotifyIconError.Create(NotifyIconModErrMessage);
          end
          else begin
            Dec(aRetryCount);
          end;
        end;
      end
      else begin
      {TimeOut以外のエラー}
        raise ENotifyIconError.Create(NotifyIconErrMessage);
      end;
    end;
  (*...
  {新バージョン}
  procedure setNewVersionMessage;
    var
      msgInfo	:TNewNotifyIconData;
    begin
      {FillChar(msgInfo, SizeOf(TNewNotifyIconData), #1);}
      msgInfo.uTimeout := NOTIFYICON_VERSION;
      if Shell_NotifyIcon(NIM_SETVERSION, @msgInfo) then begin
        {Windows XP 以降のみ？}
        MessageBox(TrayHandle, 'xxx', 'OK', 0);
      end;
    end;
  ...*)
  var
    retryCount	:Integer;
  begin
    if not OnTaskTray then begin
    {アイコン未登録 or 非表示}
      with FIconData do begin
	if ShellNewVersion then begin
	{Shell32.dll のバージョンが 5 以降}
	  cbSize := SizeOf(TNewNotifyIconData);
	  dwState := NIS_SHAREDICON;
	  dwStateMask := 0;
	  dwInfoFlags := 0;
	end
	else begin
	{Shell32.dll のバージョンが 5 以前}
	  cbSize := SizeOf(TNotifyIconData);
	end;
	uID := 1;
	Wnd := TrayHandle;
	uCallbackMessage := WM_TaskTrayMessage;
        uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
      {新バージョン用に設定
      if ShellNewVersion then setNewVersionMessage;}
      {トレイにアイコン登録}
      Result := FIconData.hIcon > 0;
      if Result then begin
        if FrontToWindow then SetForegroundWindow(FTrayHandle);
        if IconRegisted then begin
        {アイコンは登録済み}
        {タスクトレイのアイコンの非表示解除}
	  FIconData.dwState := 0;
	  FIconData.uFlags := FIconData.uFlags or NIF_STATE;
	  FIconData.dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
	  if Shell_NotifyIcon(NIM_MODIFY, @FIconData) then begin
            OnTaskTray := True;
          end;
        end
        else begin
        {タスクトレイへの登録}
          if Shell_NotifyIcon(NIM_ADD, @FIconData) then begin
            IconRegisted := True;
	    OnTaskTray := True;
            {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
            {タスクトレイのアイコン範囲を無効化する}
            ToolTipStyle.DisableTrayIconRect;
            {$ENDIF}
          end
          else begin
            {リトライ}
            retryCount := 5;
            while (not OnTaskTray) and (retryCount >= 0) do retrySet(retryCount);
          end;
        end;
      end;
    end;
    Result := OnTaskTray;
  end;

{トレイからアイコン解除}
function TTaskTrayIcon.HideTrayIcon:Boolean;
  begin
    if ShellNewVersion and FEnabledHide then begin
      if IconRegisted and OnTaskTray then begin
	{アイコン非表示}
	FIconData.uFlags := NIF_STATE;
	FIconData.dwState := NIS_HIDDEN;
	FIconData.dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
	Result := Shell_NotifyIcon(NIM_MODIFY, @FIconData);
	FIconData.dwState := 0;
	{フラグ変更}
	OnTaskTray := False;
      end
      else begin
	Result := True;
      end;
    end
    else begin
      Result := DeleteTrayIcon;
    end;
  end;
function TTaskTrayIcon.DeleteTrayIcon:Boolean;
  begin
    if IconRegisted then begin
      {アイコン登録解除}
      Result := Shell_NotifyIcon(NIM_DELETE, @FIconData);
      {フラグ変更}
      IconRegisted := False;
    end
    else begin
      Result := True;
    end;
  end;

{トレイアイコンの変更}
function TTaskTrayIcon.ModifyIcon:Boolean;
  begin
    Result := False;
    if Updating then Exit;
    
    if OnTaskTray then begin
      {すでに表示済み}
      if FIconData.hIcon > 0 then begin
      {アイコンハンドルが取得できた}
        if FrontToWindow then SetForegroundWindow(FTrayHandle);
	{表示更新}
	if IconRegisted and not OnTaskTray then begin
	  FIconData.uFlags := NIF_STATE;
	  FIconData.dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
	end;
	if not Shell_NotifyIcon(NIM_MODIFY, @FIconData) then begin
          {raise ENotifyIconError.Create(NotifyIconModErrMessage);}
          {更新に失敗したときトレイからアイコンが消えてしまっている場合を想定し
           追加処理を行う。例外処理は、SetTrayIcon メソッド名部で発生するので
           コメント化しておく...2002.09.18}
      	  if GetLastError <> ERROR_TIMEOUT then begin
          {タイムアウトのエラー以外はトレイ上にアイコンがないものと判定}
            try
              {フラグを消す}
	      IconRegisted := False;
              {新規に登録する}
              SetTrayIcon;
            except
            end;
          end;
        end;
	{リターン}
	Result := OnTaskTray;
      end;
    end
    else begin
      {アイコンの新規登録}
      Result := SetTrayIcon;
    end;
  end;

{バルーンヘルプを表示する}
function TTaskTrayIcon.ShowBalloonHelpSE(aHelpTitle,			{タイトル}
                          	         aHelpText	:String;	{メッセージ}
                          	         aTimeOut	:Integer;	{タイムアウト(ミリ秒)}
                                         aIconType	:TBalloonIconType)
                                       			:Boolean;	{True:成功}
  begin
    if ShellNewVersion then begin
      SetBalloonHelpTitle(aHelpTitle);
      SetBalloonHelp(aHelpText);
      SetUTimeOut(aTimeOut);
      SetBalloonIconType(aIconType);

      HideBalloonHelp;
      Result := ShowBalloonHelp;
    end
    else begin
      Result := False;
    end;
  end;

function TTaskTrayIcon.ShowBalloonHelp: Boolean;	{True:成功}
  begin
    if ShellNewVersion and OnTaskTray then begin
      {フラグ変更}
      FIconData.uFlags := NIF_INFO;
      try
        {表示}
        {HideBalloonHelp;}
        Result := ModifyIcon;
      finally
        {フラグ復元}
        FIconData.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
    end
    else begin
      Result := False;
    end;
  end;

{バルーンヘルプを閉じる}
function TTaskTrayIcon.HideBalloonHelp: Boolean;	{True:成功}
  var
    tempInfo	:String;
  begin
    if ShellNewVersion and OnTaskTray then begin
      {フラグ変更}
      FIconData.uFlags := NIF_INFO;
      try
	tempInfo := GetBalloonHelp;
	SetBalloonHelp('');
	{表示更新}
	Result := ModifyIcon;
	{テキスト復元}
	SetBalloonHelp(tempInfo);
      finally
	{フラグ復元}
	FIconData.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
    end
    else begin
      Result := False;
    end;
  end;

{アイコン内にカーソルがあるか}
{$IFNDEF NO_USE_CUSTOM_TOOLTIP}
function TTaskTrayIcon.IsCursorInnerRect(aX, aY: Integer): Boolean;
  begin
    Result := OnTaskTray;
    if Result then begin
      Result := IsInnerRect(FToolTipStyle.FIconRect, Point(aX, aY));
    end;
  end;
{$ENDIF}

{************************************************************************}
{*	TaskTrayIconClass用MessageHandler				*}
{************************************************************************}
{クリエイト}
constructor TTrayIconWinProcList.Create;
  begin
    inherited Create;
    {Windowクラスの登録}
    RegisterClass;
    {エクスプローラの再起動でタスクトレイのアイコンを再表示するためのもの
     トップレベルのウインドウにブロードキャストされる。
     IE4.0以降なら通知されるのだろうか？ WinNT IE3.02 Opera6.03 環境で
     uTaskbarRestart <> 0 になります}
    uTaskbarRestart := RegisterWindowMessage('TaskbarCreated');
  end;

{破棄}
destructor TTrayIconWinProcList.Destroy;
  begin
    {Windowクラスの解除}
    UnRegisterClass;
    inherited Destroy;
  end;

{クラスをWindowsに登録する}
procedure TTrayIconWinProcList.RegisterClass;
  var
    wndClass	:TWndClass;
  begin
    {ウインドウクラス登録}
    wndClass.style := 0{CS_HREDRAW or CS_VREDRAW};
    wndClass.lpfnWndProc := @TaskTrayProc;
    wndClass.cbClsExtra := 0;
    wndClass.cbWndExtra := 0;
    wndClass.hInstance := hInstance;
    wndClass.hIcon := LoadIcon(hInstance, 'MAINICON');
    wndClass.hCursor := LoadCursor(0, idc_Arrow);
    wndClass.hbrBackground := Color_Window + 1;
    wndClass.lpszMenuName := nil{MAKEINTRESOURCE(1)};
    wndClass.lpszClassName := TRAY_ICON_WINDOW_CLASS_NAME;
    {登録}
    Windows.RegisterClass(wndClass);
  end;

{クラスをWindowsから削除する}
procedure TTrayIconWinProcList.UnRegisterClass;
  begin
    {クラス登録の解除}
    Windows.UnRegisterClass(TRAY_ICON_WINDOW_CLASS_NAME, hInstance);
  end;

{メッセージ処理}
function TTrayIconWinProcList.MessageDeliver(aHWND		:HWND;
                                             var Message	:TMessage)
                          					:Boolean;	{True:処理した}
  var
    idx	:Integer;
  begin
    for idx := 0 to Count - 1 do begin
      if (TObject(Items[idx]) is TTaskTrayIcon) and
         (TTaskTrayIcon(Items[idx]).FTrayHandle = aHWND) then begin
        {メッセージ送信}
        TTaskTrayIcon(Items[idx]).TrayWndProc(Message);
        {結果}
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

{クラスを追加する}
procedure TTrayIconWinProcList.AddClass(aTaskTrayIcon	:TTaskTrayIcon);
  begin
    {登録}
    TrayIconWinProcList.Add(aTaskTrayIcon);
  end;

{クラスを削除する}
procedure TTrayIconWinProcList.DeleteClass(aTaskTrayIcon	:TTaskTrayIcon);
  var
    dataIdx	:Integer;
  begin
    {登録済みのインスタンスのインデックスを得る}
    dataIdx := IndexOf(aTaskTrayIcon);
    {見つからないときはスキップ}
    if dataIdx < -1 then Exit;
    {インデックスでリストから削除する}
    Delete(dataIdx);
  end;

{************************************************************************}
{* 	関数定義							*}
{************************************************************************}
{ファイルのプロパティからバージョンを得る}
function GetFileVersion: Integer;
  const
    coTRANSLATION	= '\\VarFileInfo\\Translation';
    coSTR_FILE_INFO	= '\\StringFileInfo\\';
  var
    fileVarsionInfoSize	:Integer;
    dummy		:DWORD;
    versionInfoSize	:DWORD;
    pFileVarsionInfo,
    translation,
    infoPointer		:Pointer;
    filenmae, varValue	:String;
    major, minor	:WORD;
  begin
    Result := 0;
    
    {システムフォルダを得る}
    GetMem(infoPointer, MAX_PATH);
    GetSystemDirectory(infoPointer, MAX_PATH);
    filenmae := PChar(infoPointer) + '\' + shell32;
    FreeMem(infoPointer);
    infoPointer := nil;

    {バージョン情報サイズを得る}
    fileVarsionInfoSize := GetFileVersionInfoSize(PChar(filenmae), dummy);

    if fileVarsionInfoSize > 0 then begin
      {バージョン情報用メモリ確保}
      GetMem(pFileVarsionInfo, fileVarsionInfoSize);

      try
        {バージョン情報リソース取得}
        GetFileVersionInfo(PChar(filenmae), 0, fileVarsionInfoSize, pFileVarsionInfo);

        {変換テーブルへのポインタ取得}
        VerQueryValue(pFileVarsionInfo, coTRANSLATION, translation, versionInfoSize);

        {バージョン情リクエスト文字列を初期化する}
        varValue := coSTR_FILE_INFO +
                    IntToHex(LoWord(LongInt(translation^)), 4) +
                    IntToHex(HiWord(LongInt(translation^)), 4) + '\\';

        {ファイルバージョン}
        if VerQueryValue(pFileVarsionInfo, PChar(varValue + 'FileVersion'),
                         infoPointer, versionInfoSize) then begin
          varValue := String(PChar(infoPointer));
          try
            {バージョンが9.xxまでは大丈夫（笑）}
            major := StrToInt(varValue[1]);
            minor := StrToInt(Copy(varValue, 3, 2));
            Result := MakeLong(minor, major);
          except
            {念のため}
          end;
        end;
      finally
        FreeMem(pFileVarsionInfo, fileVarsionInfoSize);
      end;{try...}

    end;
  end;

{Shell32.dllのバージョンを得る}
function GetShellDllVersion:Longint;
  var
    hinstDll		:HMODULE;
    dllVersionInfo	:TDllVersionInfo;
    dllGetVerProc	:function (var aDllVersionInfo	:TDllVersionInfo)
							:HRESULT; stdcall;
    hHRESULT		:HRESULT;
  begin
    Result := GetFileVersion;
    {hinstDll := LoadLibrary(Shell32);}
    hinstDll := SafeLoadLibrary(Shell32);	{2002.09.03変更}

    if hinstDll < 32 then begin
      {エラー}
    end
    else begin
      try
	{バージョンを返す関数のロード}
	@dllGetVerProc := GetProcAddress(hinstDll, 'DllGetVersion');

	if Assigned(dllGetVerProc) then begin
	{バージョン5以降なら存在する}
	  {初期化}
	  FillChar(dllVersionInfo, SizeOf(TDllVersionInfo), #0);
	  dllVersionInfo.cbSize := SizeOf(TDllVersionInfo);
	  {バージョン取得}
	  hHRESULT := dllGetVerProc(dllVersionInfo);
	  if SUCCEEDED(hHRESULT) then begin
	    {Result := MakeLong(dllVersionInfo.dwMajorVersion,
			       dllVersionInfo.dwMinorVersion);}
	    Result := MakeLong(dllVersionInfo.dwMinorVersion,
			       dllVersionInfo.dwMajorVersion);
	  end;
	end
        else begin
        {ファイルのプロパティからバージョンを得る}
          Result := GetFileVersion;
        end;
      finally
	{解放}
	FreeLibrary(hinstDll);
      end;
    end;
  end;

{/////////////////////////////////////////////////////////////////////////////}
initialization
{/////////////////////////////////////////////////////////////////////////////}
  TrayIconWinProcList	:= nil;
  {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
  {ToolTipClass		:= nil;}
  {$ENDIF}

end.
