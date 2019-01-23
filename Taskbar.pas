{//////////////////////////////////////////////////////////////////////////////
//	タスクトレイアイコン表示コンポーネント				     //
//	2000.07.10 H.Okamoto						     //
//	前回更新日	2004.02.27	Ver 1.16r2			     //
//		※ タスクバー再起動イベント追加				     //
//		※ タスクバー再起動でのアニメーション再開		     //
//	最終更新日	2004.12.08	Ver 1.16r3			     //
//		※ リソースからのアイコン読み込みの改善 		     //
//////////////////////////////////////////////////////////////////////////////}
unit Taskbar;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Menus, ShellApi,
  TrShlApi;

{************************************************************************}
{*	タスクトレイアイコン表示コンポーネント				*}
{************************************************************************}
type
  {Forword宣言}
  TIconAnimation = class;

  TTrayIcon = class(TComponent)
  private
    FIconAnimation	:TIconAnimation;	{アニメーション用スレッド}
    {リソースからのロード用}
    FResIcon		:TIcon;
  protected
    FAutoPopup		:Boolean;	{True:Popupする}
    FIcon		:TIcon;		{メインアイコン}
    FLPopupMenu,
    FRPopupMenu		:TPopupMenu;	{ポップアップメニュー}
    FTaskTrayIcon	:TTaskTrayIcon;

    {FTipHelp		:String;	{トレイチップヒント}
    FResourceIconID	:Integer;	{アイコンリソースインデックス}
    FResourceIconList	:TStringList;	{アイコンリソース名リスト}
    FVisible		:Boolean;	{True:表示する}
    FMinimized		:Boolean;	{True:最小化時のみ}
    FHideOnTaskBar	:Boolean;	{True:タスクバーに表示しない}
    FInterval		:Cardinal;	{アイコンの自動変更イベント発生タイム}
    {フックイベント}
    OnIconChange	:TNotifyEvent;
    OnAppRestore	:TNotifyEvent;
    OnAppMinimize	:TNotifyEvent;
    {イベント}
    FOnDblClick		:TNotifyEvent;
    FOnRDblClick	:TNotifyEvent;
    FOnMouseMove	:TMouseMoveEvent;
    FOnMouseDown,
    FOnMouseUp		:TMouseEvent;
    FOnTimer		:TNotifyEvent;	{アイコン変更タイマーイベント}
    {独自のイベント}
    FOnMouseEnter,
    FOnMouseExit	:TNotifyEvent;
    FOnMouseClick	:TMouseEvent;
    FOnRestartTaskbar	:TNotifyEvent;	{タスクバー再起動イベント}
  public
    constructor Create(AOwner	:TComponent); override;
    destructor Destroy; override;

  protected
    procedure Loaded; override;
    
    {コールバック関数}
    procedure CallbackWndProc(var Message: TMessage);

    {Notification}
    procedure Notification(aComponent	:TComponent;
			   aOperation	:TOperation);
					override;
    {最小化イベント}
    procedure OnAppMinimizeEvent(Sender	:TObject);
    {リストアイベント}
    procedure OnAppRestoreEvent(Sender	:TObject);

    {アイコン変更時イベント}
    procedure OnIconChangeEvent(Sender	:TObject);

    {トレイにアイコンを表示できるか}
    function CanIconic:Boolean;

    {トレイに登録するアイコンのハンドルを得る}
    function GetIconHandle:HWND;

    {トレイにアイコン登録}
    function DoSetTrayIcon: Boolean;	{True:成功}
    {トレイからアイコン解除}
    function DoDeleteTrayIcon: Boolean;	{True:成功}

  public
    {タスクトレイへ登録するウインドウハンドルを得る}
    function GetTaskTrayHWND: HWND;

    {トレイにアイコン登録}
    function SetTrayIcon: Boolean;	{True:成功}
    {トレイからアイコン解除}
    function DeleteTrayIcon: Boolean;	{True:成功}

    {トレイアイコンの変更}
    function ModifyIcon:Boolean;	{True:成功}

    {バルーンヘルプを表示する}
    function ShowBalloonHelpSE(aHelpTitle,			{タイトル}
			       aHelpText	:String;	{メッセージ}
			       aTimeOut		:Integer;	{タイムアウト(ミリ秒)}
			       aIconType	:TBalloonIconType)
						:Boolean;	{True:成功}

    function ShowBalloonHelp: Boolean;		{True:成功}

    {バルーンヘルプを閉じる}
    function HideBalloonHelp: Boolean;	{True:成功}

  protected
    {アニメーション処理}
    procedure BeginIconAnimation;
    procedure EndIconAnimation;

    {アイコン変更タイマーイベント}
    procedure OnTrayIconChange;

    {プロパティIO}
    {protected}
    function GetResIcon: TIcon;
    function IconAnimation: TIconAnimation;

    {published}
    procedure SetAutoPopup(aValue	:Boolean);

    procedure SetIcon(aValue	:TIcon);

    function  GetTipHelp: String;
    procedure SetTipHelp(aValue	:String);

    procedure SetMinimized(aValue	:Boolean);

    procedure SetVisible(aValue	:Boolean);

    procedure SetIconID(aValue	:Integer);

    function  GetIconID:Integer;
    procedure SetIconIDList(aValue	:TStringList);

    procedure SetInterval(aValue	:Cardinal);

    function GetFWindow: Boolean;
    procedure SetFWindow(aValue	:Boolean);

    {クリックとダブルクリックの判定を行うか}
    function GetChackClick: Boolean;
    procedure SetChackClick(aValue	:Boolean);

    {Shell32.dllのバージョンがバルーンヘルプを表示できる}
    function GetCanBalloonHelp:Boolean;
    {バルーンヘルプのタイトル}
    function GetBlHelpTitle:String;
    procedure SetBlHelpTitle(aHelpTitle	:String);
    {バルーンヘルプのテキスト}
    function GetBalloonHelp:String;
    procedure SetBalloonHelp(aHelpText	:String);
    {トレイで表示するのタイムアウト}
    function GetUTimeOut:Integer;
    procedure SetUTimeOut(aValue	:Integer);
    {バルーンヘルプで表示するアイコンの種類}
    function GetBalloonIconType:TBalloonIconType;
    procedure SetBalloonIconType(aValue	:TBalloonIconType);

    {ツールチップスタイルクラス}
    function GetToolTipStyle: TToolTipStyle;
    procedure SetToolTipStyle(aToolTipStyle: TToolTipStyle);

  protected
    property ResIcon: TIcon read GetResIcon;

  public
    {Windows2000 + IE5.0以降 >>}
    property CanBalloonHelp: Boolean read GetCanBalloonHelp;
    {<< }

  published
    {プロパティ}
    property AutoPopup: Boolean read FAutoPopup write SetAutoPopup default True;
    property Icon: TIcon read FIcon write SetIcon;
    property TipHelp: String read GetTipHelp write SetTipHelp;
    property Minimized: Boolean read FMinimized write SetMinimized default False;
    property Visible: Boolean read FVisible write SetVisible default True;
    property HideOnTaskBar: Boolean read FHideOnTaskBar write FHideOnTaskBar default False;
    property ResourceIconID: Integer read GetIconID write SetIconID;
    property ResourceIconList: TStringList read FResourceIconList write SetIconIDList;
    property Interval: Cardinal read FInterval write SetInterval default 0;
    property DoForegroundWindow: Boolean read GetFWindow write SetFWindow default False;
    property CheckSingleDoubleClick :Boolean read GetChackClick write SetChackClick default False;

    {Windows2000 + IE5.0以降 >>}
    property BalloonHelpTitle: String read GetBlHelpTitle write SetBlHelpTitle;
    property BalloonHelpText: String read GetBalloonHelp write SetBalloonHelp;
    property BalloonHelpTimeOut: Integer read GetUTimeOut write SetUTimeOut default 5000;
    property BalloonHelpIcon: TBalloonIconType read GetBalloonIconType write SetBalloonIconType Default bitNone;
    {<< }

    {ツールチップクラス}
    property ToolTipStyle: TToolTipStyle read GetToolTipStyle write SetToolTipStyle;


    {メニュープロパティ}
    property LButtonPopupMenu: TPopupMenu read FLPopupMenu write FLPopupMenu;
    property RButtonPopupMenu: TPopupMenu read FRPopupMenu write FRPopupMenu;
    {イベント}
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnRDblClick: TNotifyEvent read FOnRDblClick write FOnRDblClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseExit: TNotifyEvent read FOnMouseExit write FOnMouseExit;
    property OnMouseClick: TMouseEvent read FOnMouseClick write FOnMouseClick;
    property OnRestartTaskbar: TNotifyEvent read FOnRestartTaskbar write FOnRestartTaskbar;

    property OnIconAnimation: TNotifyEvent read FOnTimer write FOnTimer;
  end;

{************************************************************************}
{*	アニメーション用Thread						*}
{************************************************************************}
  TIconAnimation = class(TThread)
  private
    Owner	:TTrayIcon;
  public
    constructor Create(AOwner	:TTrayIcon);
    destructor Destroy; override;

  protected
    procedure Execute; override;

  end;

{************************************************************************}
{*	レジスト							*}
{************************************************************************}
procedure Register;

{/////////////////////////////////////////////////////////////////////////////}
implementation
{/////////////////////////////////////////////////////////////////////////////}

uses
  Forms, Consts;

constructor TTrayIcon.Create(AOwner	:TComponent);
  begin
    inherited Create(AOwner);
    {クリエイト}
    FIcon := TIcon.Create;
    FIcon.OnChange := OnIconChangeEvent;
    FResourceIconList := TStringList.Create;
    FTaskTrayIcon := TTaskTrayIcon.Create;
    FTaskTrayIcon.OnMessage := CallbackWndProc;
    FIconAnimation := nil;

    if not (csDesigning in ComponentState) then begin
      {非デザイン時}
      OnAppRestore := Application.OnRestore;
      Application.OnRestore := OnAppRestoreEvent;
      OnAppMinimize := Application.OnMinimize;
      Application.OnMinimize := OnAppMinimizeEvent;
    end;
    {プロパティのデフォルト値の設定}
    FResIcon		:= nil;
    FAutoPopup 		:= True;
    FTaskTrayIcon.SetTipHelp('TipHelp');
    FVisible 		:= True;
    FResourceIconID	:= -1;
    FMinimized 		:= False;
    FHideOnTaskBar 	:= False;
    FInterval		:= 0;
  end;

destructor TTrayIcon.Destroy;
  begin
    {デザイン時でないとき}
    if not (csDesigning in ComponentState) then begin
      DoDeleteTrayIcon;
      Application.OnRestore := OnAppRestore;
      OnAppRestore := nil;
      Application.OnMinimize := OnAppMinimize;
      OnAppMinimize := nil;
    end;
    {アニメーションスレッドの破棄}
    if FIconAnimation <> nil then begin
      FIconAnimation.Terminate;
      if FIconAnimation.Suspended then FIconAnimation.Resume;
      FIconAnimation.Free;
    end;
    {破棄}
    if FResIcon   <> nil then FResIcon.Free;
    FTaskTrayIcon.Free;
    FIcon.Free;
    FResourceIconList.Free;

    inherited Destroy;
  end;

procedure TTrayIcon.Loaded;
  begin
    {デザイン時でなく、VisibleプロパティがTrueのとき}
    if not (csDesigning in ComponentState) and CanIconic then begin
      {アイコン登録}
      SetTrayIcon;
    end;
    inherited Loaded;
  end;

{コールバック関数}
procedure TTrayIcon.CallbackWndProc(var Message: TMessage);
  var
    cursorPos	:TPoint;
  begin
    if Message.Msg = WM_TaskTrayMessage then begin
      {マウスカーソルの現在位置取得}
      GetCursorPos(cursorPos);

      {処理分岐}
      case Message.lParam of
	WM_MOUSEMOVE:begin
	{アイコン上の通過時}
	  if Assigned(FOnMouseMove) then
	    FOnMouseMove(Self, [], cursorPos.X, cursorPos.Y);
	end;
	WM_LBUTTONDOWN:begin
	{左ボタンのダウン時}
	  {ポップアップメニューを割り当ててあり、AutoPopupがTrue}
	  if Assigned(FLPopupMenu) and FAutoPopup then begin
            SetForegroundWindow(Application.Handle);
            Application.ProcessMessages;
            FLPopupMenu.PopupComponent := Self;
            FLPopupMenu.Popup(cursorPos.X, cursorPos.Y);
          end
          else if Assigned(FOnMouseDown) then
            FOnMouseDown(Self, mbLeft, [ssLeft], cursorPos.X, cursorPos.Y);
        end;
        WM_LBUTTONUP:begin
        {左ボタンのアップ時}
          if Assigned(FOnMouseUp) then
            FOnMouseUp(Self, mbLeft, [ssLeft], cursorPos.X, cursorPos.Y);
        end;
        WM_LBUTTONDBLCLK:begin
        {左ボタンのダブルクリック時}
          if Assigned(FOnDblClick) then FOnDblClick(Self);
        end;
        WM_MBUTTONDOWN:begin
          {中ボタンのダウン時}
          if Assigned(FOnMouseDown) then
            FOnMouseDown(Self, mbMiddle, [ssMiddle],  cursorPos.X, cursorPos.Y);
        end;
        WM_MBUTTONUP:begin
        {中ボタンのアップ時}
          if Assigned(FOnMouseUp) then
	    FOnMouseUp(Self, mbMiddle, [ssMiddle],  cursorPos.X, cursorPos.Y);
        end;
        WM_RBUTTONDOWN:begin
        {右ボタンのダウン時}
          {ポップアップメニューを割り当ててあり、AutoPopupがTrue}
          if Assigned(FRPopupMenu) and FAutoPopup then begin
            SetForegroundWindow(Application.Handle);
            Application.ProcessMessages;
            FRPopupMenu.PopupComponent := Self;
            FRPopupMenu.Popup(cursorPos.X, cursorPos.Y);
          end
          else if Assigned(FOnMouseDown) then
	    FOnMouseDown(Self, mbRight, [ssRight], cursorPos.X, cursorPos.Y);
        end;
        WM_RBUTTONUP:begin
        {右ボタンのアップ時}
          if Assigned(FOnMouseUp) then
	    FOnMouseUp(Self, mbRight, [ssRight], cursorPos.X, cursorPos.Y);
        end;
        WM_RBUTTONDBLCLK:begin
        {右ボタンのダブルクリック時}
          if Assigned(FOnRDblClick) then FOnRDblClick(Self);
        end;
	NIN_BALLOONSHOW:begin
	{バルーンヘルプを表示したときのメッセージ}

	end;
	NIN_BALLOONHIDE:begin
	{バルーンヘルプが非表示になったときのメッセージ}

	end;
	NIN_BALLOONTIMEOUT: begin
	{タイムアウトでバルーンヘルプが非表示になるときに発生}

	end;
	NIN_BALLOONUSERCLICK:begin
	{ユーザーがクリックしてバルーンヘルプが非表示になるときに発生}
	  
	end;
	{以下独自イベント}
	WM_MOUSE_ENTER: if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
	WM_MOUSE_EXIT : if Assigned(FOnMouseExit ) then FOnMouseExit (Self);
        WM_MOUSE_CLICK:begin
          if Assigned(FOnMouseClick) then begin
            FOnMouseClick(Self, TMouseButton(Message.WParam), [], cursorPos.X, cursorPos.Y);
          end;
	end;
      end;
    end
    else begin
    {その他のメッセージ}
      case  Message.Msg of
        WM_QUERYENDSESSION: begin
	  Message.Result := Integer(True);
	end;
	{以下独自メッセージ}
	WM_TASKBER_RESTART:begin
	{タスクバー再起動}
	  if FIconAnimation <> nil then begin
	    {検証不十分だが、Win2000SP3ではスレッドの再開に権限が必要になった(はず)
	     なので、インスタンスを破棄し改めて作成する}
	    FIconAnimation.Free;
	    FIconAnimation := nil;
	    if Visible and (FInterval > 0) then begin
	      {アニメーション再開}
	      BeginIconAnimation;
	    end;
	  end;
	  {イベント}
	  if Assigned(FOnRestartTaskbar) then FOnRestartTaskbar(Self);
	end;
      end;
    end;
  end;

{Notification}
procedure TTrayIcon.Notification(aComponent	:TComponent;
				 aOperation	:TOperation);
  begin
    inherited Notification(aComponent, aOperation);
    case aOperation of
      opRemove:begin
	if aComponent = FLPopupMenu then      FLPopupMenu := nil
	else if aComponent = FLPopupMenu then FRPopupMenu := nil;
      end;
    end;
  end;

{最小化イベント}
procedure TTrayIcon.OnAppMinimizeEvent(Sender	:TObject);
  begin
    if Assigned(OnAppMinimize) then OnAppMinimize(Sender);
    if FVisible and FMinimized then begin
      {トレイアイコン登録}
      SetTrayIcon;
    end;
    if FVisible and FHideOnTaskBar then begin
      ShowWindow(Application.Handle, SW_HIDE);
    end;
  end;

{リストアイベント}
procedure TTrayIcon.OnAppRestoreEvent(Sender	:TObject);
  begin
    if Assigned(OnAppRestore) then OnAppRestore(Sender);
    if FMinimized then begin
      {トレイアイコン解除}
      DoDeleteTrayIcon;
      {メインフォームを前面に出す}
      if Owner is TWinControl then
	SetForegroundWindow(TWinControl(Owner).Handle);
    end;
  end;

{アイコン変更時イベント}
procedure TTrayIcon.OnIconChangeEvent(Sender	:TObject);
  begin
    if not (csDesigning in ComponentState) and
       not (csLoading in ComponentState) then begin
      {トレイのアイコン更新}
      ModifyIcon;
    end;
  end;

{トレイにアイコンを表示できるか}
function TTrayIcon.CanIconic:Boolean;
  begin
    Result := FVisible;
    if Result then begin
      if FMinimized then
	Result := IsIconic(Application.Handle);
    end;
  end;

{トレイに登録するアイコンのハンドルを得る}
function TTrayIcon.GetIconHandle:HWND;
  {アイコンをリソースから読み込む}
  procedure loadIconResource(aResName	:String);
    var
      resStream: TResourceStream;
    begin
      resStream := TResourceStream.Create(hInstance, aResName, RT_ICON);
      try
	ResIcon.LoadFromStream(resStream);
      finally
	resStream.Free;
      end;
    end;
  var
    resourceName	:String;
  begin
    Result := FIcon.Handle;
    if Result = 0 then begin
      {アイコンが設定されていないとき}
      if (ResourceIconList.Count > 0) and (FResourceIconID >= 0) then begin
	resourceName := ResourceIconList.Strings[FResourceIconID];
	(*...2002.03.09...Bitmapは使えないらしい（笑）
	{Iconでロードする}
	Result := LoadIcon(HInstance, Pchar(resourceName));
	if Result = 0 then begin
	{IconでなければBitmapをロードしてみる...
	  Result := LoadBitmap(HInstance, Pchar(resourceName));
	end;
	...*)
	{...
	loadIconResource(ResourceIconList.Strings[FResourceIconID]);
	...}
	{...2004.12.08...LoadIconは過去遺産的APIらしい
	ResIcon.Handle := LoadIcon(HInstance, Pchar(resourceName));
	...}
	ResIcon.Handle := LoadImage(HInstance, PChar(resourceName), IMAGE_ICON, 16, 16, LR_SHARED);
	Result := ResIcon.Handle;
      end
      else begin
	Result := Application.Icon.Handle;
      end;
    end;
  end;

{トレイにアイコン登録}
function TTrayIcon.DoSetTrayIcon: Boolean;	{True:成功}
  begin
    FTaskTrayIcon.Icon := GetIconHandle;
    Result := FTaskTrayIcon.SetTrayIcon;
    if Result then begin
      {アニメーション開始}
      BeginIconAnimation;
    end;
  end;
{トレイからアイコン解除}
function TTrayIcon.DoDeleteTrayIcon: Boolean;	{True:成功}
  begin
    {アニメーション終了}
    EndIconAnimation;
    {解除}
    {Result := FTaskTrayIcon.DeleteTrayIcon;}
    Result := FTaskTrayIcon.HideTrayIcon;
  end;

{タスクトレイへ登録するウインドウハンドルを得る}
function TTrayIcon.GetTaskTrayHWND: HWND;
  begin
    Result := FTaskTrayIcon.TrayHandle;
  end;

{トレイにアイコン登録}
function TTrayIcon.SetTrayIcon:Boolean;
  begin
    Result := DoSetTrayIcon;
    if Result then FVisible := True;
  end;

{トレイからアイコン解除}
function TTrayIcon.DeleteTrayIcon:Boolean;
  begin
    Result := DoDeleteTrayIcon;
    if Result then FVisible := False;
  end;

{トレイアイコンの変更}
function TTrayIcon.ModifyIcon:Boolean;
  begin
    FTaskTrayIcon.Icon := GetIconHandle;
    if CanIconic then Result := FTaskTrayIcon.ModifyIcon
    else              Result := False;
  end;

{バルーンヘルプを表示する}
function TTrayIcon.ShowBalloonHelpSE(aHelpTitle,		{タイトル}
				     aHelpText	:String;	{メッセージ}
				     aTimeOut	:Integer;	{タイムアウト(ミリ秒)}
				     aIconType	:TBalloonIconType)
						:Boolean;	{True:成功}
  begin
    Result := FTaskTrayIcon.ShowBalloonHelpSE(aHelpTitle, aHelpText, aTimeOut, aIconType);
  end;
function TTrayIcon.ShowBalloonHelp: Boolean;	{True:成功}
  begin
    Result := FTaskTrayIcon.ShowBalloonHelp;
  end;

{バルーンヘルプを閉じる}
function TTrayIcon.HideBalloonHelp: Boolean;	{True:成功}
  begin
    Result := FTaskTrayIcon.HideBalloonHelp;
  end;

{アニメーション準備}
procedure TTrayIcon.BeginIconAnimation;
  begin
    if Visible and (FInterval > 0) then begin
      {アニメーション開始}
      IconAnimation.Resume;
    end
    else begin
      if FIconAnimation <> nil then begin
	if not FIconAnimation.Suspended then FIconAnimation.Suspend;
      end;
    end;
  end;
procedure TTrayIcon.EndIconAnimation;
  begin
    if FIconAnimation <> nil then begin
      if not FIconAnimation.Suspended then FIconAnimation.Suspend;
    end;
  end;

{アイコン変更タイマーイベント}
procedure TTrayIcon.OnTrayIconChange;
  begin
    if Assigned(FOnTimer) then begin
      FOnTimer(Self);
      ModifyIcon;
    end
    else begin
      if (FResourceIconID + 1) >= FResourceIconList.Count then begin
	ResourceIconID := 0;
      end
      else begin
	ResourceIconID := FResourceIconID + 1;
      end;
    end;
  end;

{protected}
function TTrayIcon.GetResIcon: TIcon;
  begin
    if FResIcon = nil then FResIcon := TIcon.Create;
    Result := FResIcon;
  end;

function TTrayIcon.IconAnimation: TIconAnimation;
  begin
    if FIconAnimation = nil then begin
      FIconAnimation := TIconAnimation.Create(Self);
    end;
    Result := FIconAnimation;
  end;

{published}
procedure TTrayIcon.SetAutoPopup(aValue	:Boolean);
  begin
    if FAutoPopup <> aValue then FAutoPopup := aValue;
  end;

procedure TTrayIcon.SetIcon(aValue	:TIcon);
  begin
    if aValue <> nil then
      FIcon.Assign(aValue)
    else begin
      FIcon.ReleaseHandle;
      FIcon.Handle := 0;
    end;
    (*...2002.08.18
    if not (csDesigning in ComponentState) and
       not (csLoading in ComponentState) then begin
      {トレイのアイコン更新}
      ModifyIcon;
    end;
    ...*)
    {アイコン変更時イベント}
    OnIconChangeEvent(nil);
  end;

function  TTrayIcon.GetTipHelp: String;
  begin
    Result := FTaskTrayIcon.GetTipHelp;
  end;

procedure TTrayIcon.SetTipHelp(aValue	:String);
  begin
    FTaskTrayIcon.SetTipHelp(aValue);
    if not (csDesigning in ComponentState) and
       not (csLoading in ComponentState) then begin
      ModifyIcon;
    end;
  end;

procedure TTrayIcon.SetMinimized(aValue	:Boolean);
  begin
    if FMinimized <> aValue then begin
      FMinimized := aValue;
      if not (csDesigning in ComponentState) and
         not (csLoading in ComponentState) then begin
        if CanIconic then ModifyIcon
        else 		  DoDeleteTrayIcon;
      end;
    end;
  end;

procedure TTrayIcon.SetVisible(aValue	:Boolean);
  begin
    if FVisible <> aValue then begin
      FVisible := aValue;
      {デザイン時でなく、コンポーネントをロード中でない場合、表示・非表示の切替え}
      if not (csDesigning in ComponentState) and
         not (csLoading in ComponentState) then begin
        if CanIconic then SetTrayIcon		{非表示→表示}
	else 		  DoDeleteTrayIcon;	{表示  →非表示}
      end;
    end;
  end;

procedure TTrayIcon.SetIconID(aValue	:Integer);
  begin
    //if (FResourceIconList.Count <= aValue) or (aValue < 0) then aValue := 0;
    if (FResourceIconID <> aValue) or (aValue = 0) then begin
      FIcon.Handle := 0;
      if csLoading in ComponentState then begin
	FResourceIconID := aValue;
      end
      else begin
        if FResourceIconList.Count <= aValue then begin
          FResourceIconID := FResourceIconList.Count -1;
        end
        else if aValue < 0 then begin
          FResourceIconID := -1;
        end
        else begin
          FResourceIconID := aValue;
        end;
      end;
      if not (csDesigning in ComponentState) and
         not (csLoading in ComponentState) then begin
	if CanIconic then ModifyIcon;
      end;
    end;
  end;

function TTrayIcon.GetIconID:Integer;
  begin
    if (FResourceIconList.Count <= FResourceIconID) or
       (FResourceIconID = 0) then FResourceIconID := 0;
    Result := FResourceIconID;
  end;

procedure TTrayIcon.SetIconIDList(aValue	:TStringList);
  var
    current	:String;
  begin
    if FResourceIconList.Count = 0 then begin
      {リストのコピー}
      FResourceIconList.Assign(aValue);
      if not (csDesigning in ComponentState) and
         not (csLoading in ComponentState) then begin
        {アイコン更新}
        if CanIconic then ModifyIcon;
      end;
    end
    else begin
      if FResourceIconID < 0 then Exit;
      current := FResourceIconList.Strings[FResourceIconID];
      {リストのコピー}
      FResourceIconList.Assign(aValue);
      {アイコンIDの更新}
      SetIconID(ResourceIconID);
      if FResourceIconList.Strings[ResourceIconID] <> current then begin
        if not (csDesigning in ComponentState) and
           not (csLoading in ComponentState) then begin
          {アイコン更新}
          if CanIconic then ModifyIcon;
        end;
      end;
    end;
  end;

procedure TTrayIcon.SetInterval(aValue	:Cardinal);
  begin
    if aValue <> FInterval then begin
      {なんとなく50より小さいのは不許可}
      if (aValue < 50) and (aValue > 0) then aValue := 50;
      FInterval := aValue;
      {アニメーション開始}
      BeginIconAnimation;
    end;
  end;

function TTrayIcon.GetFWindow: Boolean;
  begin
    Result := FTaskTrayIcon.FrontToWindow;
  end;

procedure TTrayIcon.SetFWindow(aValue	:Boolean);
  begin
    FTaskTrayIcon.FrontToWindow := aValue;
  end;

{クリックとダブルクリックの判定を行うか}
function TTrayIcon.GetChackClick: Boolean;
  begin
    Result := FTaskTrayIcon.ToolTipStyle.RequestSglDbl;
  end;
procedure TTrayIcon.SetChackClick(aValue	:Boolean);
  begin
    FTaskTrayIcon.ToolTipStyle.RequestSglDbl := aValue;
  end;

{Shell32.dllのバージョンがバルーンヘルプを表示できる}
function TTrayIcon.GetCanBalloonHelp:Boolean;
  begin
    Result := FTaskTrayIcon.ShellNewVersion;
  end;

{バルーンヘルプのタイトル}
function TTrayIcon.GetBlHelpTitle:String;
  begin
    Result := FTaskTrayIcon.GetBalloonHelpTitle;
  end;
procedure TTrayIcon.SetBlHelpTitle(aHelpTitle	:String);
  begin
    FTaskTrayIcon.SetBalloonHelpTitle(aHelpTitle);
  end;

{バルーンヘルプのテキスト}
function TTrayIcon.GetBalloonHelp:String;
  begin
    Result := FTaskTrayIcon.GetBalloonHelp;
  end;
procedure TTrayIcon.SetBalloonHelp(aHelpText	:String);
  begin
    FTaskTrayIcon.SetBalloonHelp(aHelpText);
  end;

{トレイで表示するのタイムアウト}
function TTrayIcon.GetUTimeOut:Integer;
  begin
    Result := FTaskTrayIcon.GetUTimeOut;
  end;

procedure TTrayIcon.SetUTimeOut(aValue	:Integer);
  begin
    FTaskTrayIcon.SetUTimeOut(aValue);
  end;

{バルーンヘルプで表示するアイコンの種類}
function TTrayIcon.GetBalloonIconType:TBalloonIconType;
  begin
    Result := FTaskTrayIcon.GetBalloonIconType;
  end;
procedure TTrayIcon.SetBalloonIconType(aValue	:TBalloonIconType);
  begin
    FTaskTrayIcon.SetBalloonIconType(aValue);
  end;

function TTrayIcon.GetToolTipStyle: TToolTipStyle;
  begin
    Result := FTaskTrayIcon.ToolTipStyle;
  end;

procedure TTrayIcon.SetToolTipStyle(aToolTipStyle: TToolTipStyle);
  begin
    FTaskTrayIcon.ToolTipStyle.Assign(aToolTipStyle);
  end;

{************************************************************************}
{*	アニメーション用Thread						*}
{************************************************************************}
constructor TIconAnimation.Create(aOwner	:TTrayIcon);
  begin
    inherited Create(True);
    Owner := aOwner;
  end;
destructor TIconAnimation.Destroy;
  begin
    inherited Destroy;
  end;
procedure TIconAnimation.Execute;
  begin
    while not Terminated do begin
      if (Owner.Interval = 0) or
         (not Owner.Visible)  then begin
        if not Suspended then Suspend;
      end;

      if Owner.Visible then begin
        {アイコン変更}
	Owner.OnTrayIconChange;
        {待機}
	Sleep(Owner.Interval);
      end;
    end;
  end;

{************************************************************************}
{*	レジスト							*}
{************************************************************************}
procedure Register;
  begin
    RegisterComponents('Samples', [TTrayIcon]);
  end;

end.


