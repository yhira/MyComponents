//
// Componentware for Delphi - TrayIcon Component Release 1.17
//   Copyright(C) 1996-1998 Yukio Tsujihara
//
// Module      : トレイアイコンコンポーネント
// Last Update : 10/27/98
// Author      : Yukio Tsujihara
//
// Revision    : Taro Kato
// Last Update : 02/18/2004
//
//
// shell32.dll のバージョン５以降の新機能の追加
//

unit TrayIcon;

interface

uses
  Messages, ShellApi, Windows,
  Classes, Controls, Graphics, ExtCtrls, Forms, Menus, SysUtils ;

const
  NotifyIconErrMessage = 'タスクトレイにアイコンを登録できません。';
  NotifyIconErrChangeVisibleMessage = 'タスクトレイアイコンの表示が切り替えられません。';
  NotifyIconErrBalloonMessage = 'タスクトレイアイコンのバルーンメッセージ表示が切り替えられません。';
  NotifyIconWarnShell32V6Message = 'OnBalloon系イベントはWindows XP/2003などの環境でのみ有効です。'+#13#10+
      '作成アプリケーションの対応OSには充分注意してください。';
  WM_NotifyIconMessage = WM_User + 200;

type
  // ENotifyIconError例外の定義
  ENotifyIconError = class(Exception);

  // TTrayIconMode列挙型の定義
  TTrayIconMode = (tiAddIcon, tiModifyIcon, tiDeleteIcon,
                   tiShowBalloon, tiHideBalloon,
                   tiShowIcon, tiHideIcon);

  // TAnimateMode列挙型の定義
  TAnimateMode = (amAutomatic, amManual);

  // TrayIconアニメーションスレッドクラスの疑似定義
  TTrayIconAnimate = class;


  PNotifyIconDataV5A = ^TNotifyIconDataV5A;
  TNotifyIconDataV5A = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of AnsiChar;

    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of Char;

    uTimeout: UINT; // uVersion を兼ねる

    szInfoTitle: array [0.. 63] of AnsiChar;
    dwInfoFlags: DWORD;
  end;

  TBalloonTimeout = 10..60;
  TBalloonInfoIconFlag = (biifNone, biifInfo, biifWarning, biifError);

{$IFNDEF VER90}
{$IFNDEF VER93}
{$IFNDEF VER100}
{$IFNDEF VER110}
{$DEFINE D4LATER}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

  TTrayIcon = class(TComponent)
  private
    FAnimated: Boolean;
    FAnimateIcons: TImageList;
    FAnimateMode: TAnimateMode;
    FAnimateRate: Integer;
    FAutoPopup: Boolean;
    FEnabled: Boolean;
    FIcon: TIcon;
    FLBPopupMenu: TPopupMenu;
    FRBPopupMenu: TPopupMenu;
    FTipHelp: string;
    FVisible: Boolean;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseDown, FOnMouseUp: TMouseEvent;

    AnimateThread: TTrayIconAnimate;
    IconID: UINT;
    IconRegisted: Boolean;
    //NIconData: PNotifyIconDataA;
    NIconData: PNotifyIconDataV5A;
    SingleClickExec: Boolean;

    FReadStateNext: Boolean;
    FShell32Version: WORD;
    FXPLater: Boolean;
    FBalloonTitle: string;
    FBalloonText: string;
    FBalloonTimeout: TBalloonTimeout;
    FBalloonIcon: TBalloonInfoIconFlag;
    FOnBalloonHide: TNotifyEvent;
    FOnBalloonTimeout: TNotifyEvent;
    FOnBalloonClick: TNotifyEvent;
    FOnBalloonShow: TNotifyEvent;
    FFormActiveByMouseup: Boolean;

    function GetIconHandle: THandle;
    procedure SetBalloonText(const Value: string);
    procedure SetBalloonTitle(const Value: string);
    procedure MessageOfShell32V6AtDesigning;
    procedure SetOnBalloonClick(const Value: TNotifyEvent);
    procedure SetOnBalloonHide(const Value: TNotifyEvent);
    procedure SetOnBalloonShow(const Value: TNotifyEvent);
    procedure SetOnBalloonTimeout(const Value: TNotifyEvent);
  protected
    procedure IconChange(Sender: TObject);

    procedure SetAnimateIcons(Value: TImageList);
    procedure SetAnimateRate(Value: Integer);
    procedure SetEnabled(Value: Boolean);
    procedure SetIcon(Value: TIcon);
    procedure SetLBPopupMenu(Value: TPopupMenu);
    procedure SetRBPopupMenu(Value: TPopupMenu);
    procedure SetTipHelp(Value: string);
    procedure SetTrayIcon(Value: TTrayIconMode);
    procedure SetVisible(Value: Boolean);
    procedure ReadState(Reader: TReader); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
    destructor Destroy; override;
    procedure AnimeteModeChange;
    procedure AnimatePlay(AAnimateMode: TAnimateMode);
    procedure AnimateStep;
    procedure AnimateStop;

    property Animated: Boolean read FAnimated;
    property AnimateMode: TAnimateMode read FAnimateMode;

{$IFDEF D4LATER}
    procedure ShowBalloon; overload;
    procedure ShowBalloon(Icon: TBalloonInfoIconFlag); overload;
    procedure ShowBalloon(Icon: TBalloonInfoIconFlag; Title: string); overload;
    procedure ShowBalloon(Icon: TBalloonInfoIconFlag; Title, Text: string); overload;
    procedure ShowBalloon(Icon: TBalloonInfoIconFlag; Title, Text: string; Timeout: TBalloonTimeout); overload;
{$ELSE}
    procedure ShowBalloon;
{$ENDIF}
    procedure HideBalloon;
  published
    property AnimateIcons: TImageList read FAnimateIcons write SetAnimateIcons;
    property AnimateRate: Integer read FAnimateRate write SetAnimateRate
      default 500;
    property AutoPopup: Boolean read FAutoPopup write FAutoPopup default True;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Icon: TIcon read FIcon write SetIcon;
    property LBPopupMenu: TPopupMenu read FLBPopupMenu write SetLBPopupmenu;
    property RBPopupMenu: TPopupMenu read FRBPopupMenu write SetRBPopupmenu;
    property TipHelp: string read FTipHelp write SetTipHelp;  // Balloon時はタイトル
    property Visible: Boolean read FVisible write SetVisible default False;

    property BalloonTitle: string read FBalloonTitle write SetBalloonTitle;
    property BalloonText: string read FBalloonText write SetBalloonText;
    property BalloonIcon: TBalloonInfoIconFlag read FBalloonIcon write FBalloonIcon;
    property BalloonTimeout: TBalloonTimeout read FBalloonTimeout write FBalloonTimeout default 10;
    property FormActiveByMouseup: Boolean read FFormActiveByMouseup write FFormActiveByMouseup default false;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;

    property OnBalloonShow: TNotifyEvent read FOnBalloonShow write SetOnBalloonShow;
    property OnBalloonHide: TNotifyEvent read FOnBalloonHide write SetOnBalloonHide;
    property OnBalloonTimeout: TNotifyEvent read FOnBalloonTimeout write SetOnBalloonTimeout;
    property OnBalloonClick: TNotifyEvent read FOnBalloonClick write SetOnBalloonClick;
  end;

  // シングルクリックスレッドクラスの定義
  TSingleClick = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

  // TrayIconアニメーションスレッドクラスの定義
  TTrayIconAnimate = class(TThread)
  private
    AnimateFrame: Integer;
    Icon: TIcon;
    Owner: TTrayIcon;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TTrayIcon);
    destructor Destroy; override;
  end;

  // Shell_NotifyIcon用非表示ウィンドウクラスの定義
  TCallbackWindow = Class(TWinControl)
  private
    FOwner: TTrayIcon;

    procedure CallbackWndProc(var Msg: TMessage); Message WM_NotifyIconMessage;
    procedure OnClick(Sender: TObject);
  end;

procedure Register;

{$IFDEF D4LATER}
procedure GetSysFileVersion(FileName: string; var Major: WORD; Minor: PWORD = nil; Release: PWORD = nil; Build: PWORD = nil);
procedure GetFileVersion(FileName: string; var Major: WORD; Minor: PWORD = nil; Release: PWORD = nil; Build: PWORD = nil);
{$ELSE}
procedure GetSysFileVersion(FileName: string; var Major: WORD; Minor: PWORD; Release: PWORD; Build: PWORD);
procedure GetFileVersion(FileName: string; var Major: WORD; Minor: PWORD; Release: PWORD; Build: PWORD);
{$ENDIF}

const
  NIF_STATE       = $00000008;  // 状態の変更
  NIF_INFO        = $00000010;  // バルーンメッセージ

  NIIF_NONE       = $00000000;  // アイコンなし
  NIIF_INFO       = $00000001;  // 情報
  NIIF_WARNING    = $00000002;  // 警告
  NIIF_ERROR      = $00000003;  // エラー

  NIS_HIDDEN      = $00000001;  // 非表示アイコン
  NIS_SHAREDICON  = $00000002;  // 共有アイコン

  // バルーン関連メッセージ
  NIN_BALLOONSHOW      = WM_USER + 2;
  NIN_BALLOONHIDE      = WM_USER + 3;
  NIN_BALLOONTIMEOUT   = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;


{$IFDEF VER90}
  ERROR_TIMEOUT   = 1460;
{$ENDIF}
{$IFDEF VER93}
  ERROR_TIMEOUT   = 1460;
{$ENDIF}

implementation

var
  CallbackWindow: TCallbackWindow;
  IconIDList: TStringList;

constructor TTrayIcon.Create(AOwner: TComponent);
var
  OSVerInf: TOSVersionInfo;
begin
  inherited Create(AOwner);

  GetSysFileVersion('shell32.dll', FShell32Version, nil, nil, nil);

  OSVerInf.dwOSVersionInfoSize := SizeOf(OSVerInf);
  GetVersionEx(OSVerInf);
  FXPLater := (OSVerInf.dwMajorVersion > 5) or
              ((OSVerInf.dwMajorVersion = 5) and (OSVerInf.dwMinorVersion > 0));

  // アイコン登録数のチェック
  if IconIDList.Count > 99 then
  begin
    IconID := 0;
    raise ENotifyIconError.Create(NotifyIconErrMessage);
  end;
  if IconIDList.Count > 0 then
    IconID := StrToInt(IconIDList[IconIDList.Count - 1]) + 1
  else
    IconID := 1;
  IconIDList.AddObject(IntToStr(IconID), Self);

  // プロパティのデフォルト値の設定
  AnimateThread := nil;
  FAnimated := False;
  FAnimateMode := amAutomatic;
  FAnimateRate := 500;
  FAutoPopup := True;
  FEnabled := True;
  FTipHelp := 'TipHelp';
  FVisible := False;
  FBalloonTimeout := 10;

  // Iconプロパティ用アイコンデータ領域確保
  FIcon := TIcon.Create;
  IconRegisted := False;
  // シングルクリック判定用フラグの初期化
  SingleClickExec := False;

  // デザイン時でない場合の初期化
  if not (csDesigning in ComponentState) then
  begin
    // アイコンのOnChangeイベントを設定
    FIcon.OnChange := IconChange;

    // Shell_NotifyIcon用非表示コールバックウィンドウが生成されていない場合
    if CallbackWindow = nil then
    begin
      CallbackWindow := TCallbackWindow.Create(Owner);
      CallbackWindow.Parent := TWinControl(Owner);
    end;

    // Shell_NotifyIcon用データ領域確保と初期化
    New(NIconData);
    with NIconData^ do
    begin
      if FShell32Version >= 5 then
      begin
        cbSize := Sizeof(TNotifyIconDataV5A);
      end else begin
        cbSize := Sizeof(TNotifyIconDataA);
      end;
      uCallBackMessage := WM_NotifyIconMessage;
      uID := IconID;
    end;
  end;
end;

procedure TTrayIcon.Loaded;
begin
  FReadStateNext := False;
  // デザイン時でない場合、アイコンの登録
  if not (csDesigning in ComponentState) then
    SetTrayIcon(tiAddIcon);

  inherited Loaded;
end;

destructor TTrayIcon.Destroy;
begin
  // アイコン登録数オーバによる例外発生時以外、破棄処理
  if IconID <> 0 then
  begin
    // デザイン時でない場合、破棄処理
    if not (csDesigning in ComponentState) then
    begin
      // アニメーションスレッドの破棄
      if AnimateThread <> nil then
      begin
        AnimateThread.Terminate;
        if AnimateThread.Suspended then
          AnimateThread.Resume;
        AnimateThread.Free;
        FAnimated := False;
      end;

      // トレイにアイコンが表示されている場合、アイコンの破棄
      if IconRegisted then
        SetTrayIcon(tiDeleteIcon);

      // Shell_NotifyIcon用データ領域破棄
      Dispose(NIconData);
    end;

    IconIDList.Delete(IconIDList.IndexOf(IntToStr(IconID)));
    FIcon.Free;
  end;

  inherited Destroy;
end;

procedure TTrayIcon.AnimeteModeChange;
begin
  if FAnimated then
  begin
    // 自動→手動へ切り替えた場合
    if FAnimateMode = amAutomatic then
    begin
      FAnimateMode := amManual;
    end
    // 手動→自動へ切り替えた場合
    else
    begin
      FAnimateMode := amAutomatic;
      AnimateThread.Resume;
    end;
  end;
end;

procedure TTrayIcon.AnimatePlay(AAnimateMode: TAnimateMode);
begin
  // アニメーション中でなく、アニメーションアイコンが設定されている場合
  if (not FAnimated) and (FAnimateIcons <> nil) then
  begin
    // アニメーションアイコンに１つ以上のアイコンが登録されている場合、
    // アニメーションを開始
    if FAnimateIcons.Count > 0 then
    begin
      // アニメーションスレッドが未生成の場合
      if AnimateThread = nil then
      begin
        // アニメーションスレッドの生成
        AnimateThread := TTrayIconAnimate.Create(Self);
      end;
      // アニメーション関連の変数を初期化
      FAnimated := True;
      FAnimateMode := AAnimateMode;
      // アニメーションスレッドの再開
      AnimateThread.Resume;
    end;
  end;
end;

procedure TTrayIcon.AnimateStep;
begin
  // アニメーション中で手動アニメーションの場合
  if FAnimated and (FAnimateMode = amManual) then
    AnimateThread.Resume;
end;

procedure TTrayIcon.AnimateStop;
begin
  // アニメーションが開始されている場合、アニメーションを停止
  if FAnimated then
  begin
    // アニメーションスレッドの停止
    FAnimated := False;
    if FAnimateMode = amManual then
      AnimateThread.Resume;
    // アニメーションスレッドが完全に停止するまでループ
    while not AnimateThread.Suspended do;

    // アニメーションアイコンをもとのアイコンに変更
    IconChange(FIcon);  // 2001/01/25 Self->FIcon
  end;
end;

procedure TTrayIcon.IconChange(Sender: TObject);
begin
  // トレイにアイコンが表示されている場合、アイコンの変更
  if IconRegisted and (not (FAnimated and (FAnimateMode = amAutomatic))) then
    SetTrayIcon(tiModifyIcon);
end;

procedure TTrayIcon.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  // フォーム上の他のコンポーネントが削除された場合
  if (Operation = opRemove) then
  begin
    // 削除されたコンポーネントがTPopupMenuで、
    // LBPopupMenu、RBPopupMenuに設定されていた場合、設定を無効に変更
    if AComponent is TPopupMenu then
    begin
      if AComponent = FLBPopupMenu then
        FLBPopupMenu := nil
      else if AComponent = FRBPopupMenu then
        FRBPopupMenu := nil;
    end
    // 削除されたコンポーネントがTImageListで、
    // AnimateIconsに設定された場合、設定を無効に変更
    else if (AComponent is TImageList) and (AComponent = FAnimateIcons) then
      FAnimateIcons := nil;
  end;
end;

procedure TTrayIcon.ReadState(Reader: TReader);
begin
  if not FReadStateNext then
  begin
    FReadStateNext := True;
    TipHelp := '';
  end;
  inherited;
end;

procedure TTrayIcon.SetAnimateIcons(Value: TImageList);
begin
  if (Value <> FAnimateIcons) and (not FAnimated) then
    FAnimateIcons := Value;
  if FAnimateIcons <> nil then
    Value.FreeNotification(Self);
end;

procedure TTrayIcon.SetAnimateRate(Value: Integer);
begin
  if Value <> FAnimateRate then
  begin
    if Value < 10 then
      Value := 10;
    FAnimateRate := Value;
  end;
end;

procedure TTrayIcon.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    if not Value then
      SingleClickExec := False;
  end;
end;

procedure TTrayIcon.SetIcon(Value: TIcon);
begin
  if Value <> FIcon then
  begin
    // アイコンが設定された場合
    if Value <> nil then
      FIcon.Assign(Value)
    // アイコンがクリア(削除)された場合
    else
    begin
      FIcon.ReleaseHandle;
      FIcon.Handle := 0;
{=====================================
2000.01.25 OwnerForm.Icon, Appliction.Icon で代替可能なため非表示化はしない
      // アイコンを非表示にするため、VisibleプロパティをFalseに設定
      Visible := False;
======================================}
    end;
  end;
end;

procedure TTrayIcon.SetLBPopupMenu(Value: TPopupMenu);
begin
  if Value <> FLBPopupMenu then
    FLBPopupMenu := Value;
  if FLBPopupMenu <> nil then
    Value.FreeNotification(Self);
end;

procedure TTrayIcon.SetRBPopupMenu(Value: TPopupMenu);
begin
  if Value <> FRBPopupMenu then
    FRBPopupMenu := Value;
  if FRBPopupMenu <> nil then
    Value.FreeNotification(Self);
end;

procedure TTrayIcon.SetTipHelp(Value: string);
begin
  if FTipHelp <> Copy(Value, 1, 63) then
  begin
    FTipHelp := Copy(Value, 1, 63);

    // デザイン時でない場合、チップヘルプの変更
    if not (csDesigning in ComponentState) then
      IconChange(Self);
  end;
end;

procedure TTrayIcon.SetTrayIcon(Value: TTrayIconMode);
var
  RetryPhase: Boolean;
  RetryCount: Integer;
label
  RetryMark;
begin
  // Shell_NotifyIcon用データ領域にプロパティの値を設定
  with NIconData^ do
  begin
    // アニメーション中でないか、手動アニメーション中の場合、
    // Iconプロパティのアイコンを設定
    if not FAnimated then
      hIcon := GetIconHandle
    else
      hIcon := AnimateThread.Icon.Handle;

    if (FShell32Version >= 5) and (Value in [tiShowBalloon, tiHideBalloon])then
    begin
      uFlags := NIF_MESSAGE or NIF_INFO;
      uTimeout := FBalloonTimeout * 1000;
      FillChar(szInfoTitle, SizeOf(szInfoTitle), 0);
      FillChar(szInfo, SizeOf(szInfo), 0);
      if Value = tiShowBalloon then
      begin
        StrLCopy(szInfoTitle, PChar(FBalloonTitle), 63);
        if FBalloonText = '' then
          StrCopy(szInfo, ' ')
        else
          StrLCopy(szInfo, PChar(FBalloonText), 255);
        dwInfoFlags := Ord(FBalloonIcon);
      end;
    end else
    if (FShell32Version >= 5) and (Value in [tiShowIcon, tiHideIcon]) then
    begin
      uFlags := NIF_STATE;
      if Value = tiShowIcon then
      begin
        dwState := 0;
      end else begin
        dwState := NIS_HIDDEN;
      end;
      dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
    end else begin
      StrCopy(szTip, PChar(FTipHelp));
      if FtipHelp <> '' then
        uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP
      else
        uFlags := NIF_MESSAGE or NIF_ICON;
    end;
  end;

  RetryPhase := False;
  RetryCount := 0;

RetryMark:

  case Value of
    tiAddIcon:
    begin
      // VisibleプロパティがTrueの場合、アイコンの登録
      if FVisible then
      begin
        // Shell_NotifyIcon用ウィンドウハンドルの(再)設定
        NIconData^.Wnd := CallbackWindow.Handle;
        if not Shell_NotifyIcon(NIM_ADD, PNotifyIconDataA(NIconData)) then
        begin
          if (not FXPLater) or
             (ERROR_TIMEOUT <> GetLastError) or (RetryCount >= 5) then
            raise ENotifyIconError.Create(NotifyIconErrMessage);

          Sleep(100);
          if not RetryPhase then
          begin
            RetryPhase := True;
            Value := tiModifyIcon;
          end;
          goto RetryMark;
        end;
        IconRegisted := True;
      end;
    end;
    tiModifyIcon:
    begin
      if not Shell_NotifyIcon(NIM_MODIFY, PNotifyIconDataA(NIconData)) then
      begin
        if (not FXPLater) or (not RetryPhase) then
          raise ENotifyIconError.Create(NotifyIconErrMessage);
        Inc(RetryCount);
        Value := tiAddIcon;
        goto RetryMark;
      end;
    end;
    tiShowBalloon,
    tiHideBalloon:
    begin
      if not FVisible then
      begin
        if Value = tiShowBalloon then
        begin
          Visible := True;
          SetTrayIcon(Value);
        end;
      end else begin
        if not Shell_NotifyIcon(NIM_MODIFY, PNotifyIconDataA(NIconData)) then
          raise ENotifyIconError.Create(NotifyIconErrBalloonMessage);
      end;
    end;
    tiShowIcon,
    tiHideIcon:
    begin
      if not Shell_NotifyIcon(NIM_MODIFY, PNotifyIconDataA(NIconData)) then
        raise ENotifyIconError.Create(NotifyIconErrChangeVisibleMessage);
    end;
    tiDeleteIcon:
    begin
      Shell_NotifyIcon(NIM_DELETE, PNotifyIconDataA(NIconData));
      IconRegisted := False;
    end;
  end;
end;

function TTrayIcon.GetIconHandle: THandle;
begin
  Result := FIcon.Handle;
  if Result = 0 then
  begin
    if Owner is TForm then
      Result := TForm(Owner).Icon.Handle;
    if Result = 0 then
      Result := Application.Icon.Handle;
  end;
end;

procedure TTrayIcon.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    // 2001/01/25 Iconプロパティがなければ OwnerForm や Application を利用
    if GetIconHandle <> 0 then
      FVisible := Value
    else
      FVisible := False;

    // デザイン時でなく、コンポーネントをロード中でない場合、表示・非表示の切替え
    if not (csDesigning in ComponentState)
      and not (csLoading in ComponentState) then
    begin
      // シェルが古い場合は登録／抹消の切り替え
      // ※表示時は必ず右端に登録されてしまう。
      // シェルが新しい場合は表示／非表示が切り替えられる。
      // ※トレイアイコンの左端からの相対位置が崩れない

      // 非表示→表示へ切替えた場合
      if FVisible then
      begin
        if (not IconRegisted) or (FShell32Version < 5) then
          SetTrayIcon(tiAddIcon)
        else
          SetTrayIcon(tiShowIcon);

      // 表示→非表示へ切替えた場合
      end else if IconRegisted then
      begin
        if FShell32Version < 5 then
          SetTrayIcon(tiDeleteIcon)
        else
          SetTrayIcon(tiHideIcon);
      end;
    end;
  end;
end;

constructor TSingleClick.Create;
begin
  inherited Create(False);

  // Executeメソッド終了後、TSingleClickスレッドクラスの自動破棄設定
  FreeOnterminate := True;
end;

procedure TSingleClick.Execute;
begin
  // シングルクリックの判定時間中、スレッドの停止
  Sleep(GetDoubleClickTime + 50);
end;

constructor TTrayIconAnimate.Create(AOwner: TTrayIcon);
begin
  inherited Create(True);

  // スレッド所有TrayIconコンポーネントの設定
  Owner := AOwner;
  // アニメーションフレームの初期化
  AnimateFrame := 0;
  // アニメーションアイコン用アイコンデータ領域確保
  Icon := TIcon.Create;
end;

destructor TTrayIconAnimate.Destroy;
begin
  // アニメーションアイコン用アイコンデータ領域の解放
  Icon.Free;

  inherited Destroy;
end;

procedure TTrayIconAnimate.Execute;
begin
  while not Terminated do
  begin
    if Owner.FAnimated then
    begin
      // AnimateIconsの内容が変更され、次に表示するアイコンがなくなった場合
      // 最初のアイコンに戻る
      if AnimateFrame > (Owner.FAnimateIcons.Count - 1) then
        AnimateFrame := 0;

      // アイコンの変更
      Owner.FAnimateIcons.GetIcon(AnimateFrame, Icon);
      // トレイにアイコンが表示されている場合、アイコンの反映
      if Owner.IconRegisted then
      begin
        with Owner.NIconData^ do
        begin
          hIcon := Icon.Handle;
          StrCopy(szTip, PChar(Owner.FTipHelp));
          if Owner.FTipHelp <> '' then
            uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP
          else
            uFlags := NIF_MESSAGE or NIF_ICON;
        end;
        Shell_NotifyIcon(NIM_MODIFY, PNotifyIconDataA(Owner.NIconData));
      end;

      // 次に表示するアイコンのフレーム設定
      if AnimateFrame < (Owner.FAnimateIcons.Count - 1) then
        Inc(AnimateFrame)
      else
        AnimateFrame := 0;

      // アニメーションモードが自動の場合、指定されたミリ秒だけスレッドを停止
      if Owner.AnimateMode = amAutomatic then
        Sleep(Owner.FAnimateRate)
      else
        Suspend;
    end
    else
    begin
      AnimateFrame := 0;
      Suspend;
    end;
  end;
end;

procedure TCallbackWindow.CallbackWndProc(var Msg: TMessage);
var
  cursorpos: TPoint;
  objindex: Integer;
  procedure CurrentProcessActivate;
  begin
    if Assigned(Screen.ActiveForm) and (FOwner.FFormActiveByMouseup) then
    begin
      SetForegroundWindow(Screen.ActiveForm.Handle);
    end;
  end;
begin
  // TTrayIconオブジェクトのインデックス位置の設定
  objindex := IconIDList.IndexOf(IntToStr(Msg.wParam));
  if objindex >= 0 then
  begin
    FOwner := TTrayIcon(IconIDList.Objects[objindex]);
    // EnabledプロパティがFalseの場合、直にプロシージャから抜け出す
    if not FOwner.FEnabled then
      Exit;
  end
  else
    Exit;

  // マウスカーソルの現在位置取得
  GetCursorPos(cursorpos);

  // マウスのメッセージにより処理分岐
  case Msg.lParam of
    // アイコン上の通過時
    WM_MOUSEMOVE:
    begin
      if Assigned(FOwner.OnMouseMove) then
        FOwner.OnMouseMove(FOwner, [], cursorpos.X, cursorpos.Y);
    end;
    // 左ボタンのダウン時
    WM_LBUTTONDOWN:
    begin
      // 左ボタンにポップアップメニューを割り当てて、AutoPopupがTrueの場合
      if Assigned(FOwner.LBPopupMenu) and FOwner.AutoPopup then
      begin
        if FOwner.Owner is TForm then
        begin
          SetForegroundWindow(TForm(FOwner.Owner).Handle);
          Application.ProcessMessages;
        end;
        FOwner.LBPopupMenu.Popup(cursorpos.X, cursorpos.Y);
      end
      else if Assigned(FOwner.OnMouseDown) then
        FOwner.OnMouseDown(FOwner, mbLeft, [ssLeft], cursorpos.X, cursorpos.Y);
    end;
    // 左ボタンのアップ時
    WM_LBUTTONUP:
    begin
      CurrentProcessActivate;
      if Assigned(FOwner.OnMouseUp) then
        FOwner.OnMouseUp(FOwner, mbLeft, [ssLeft], cursorpos.X, cursorpos.Y)
      else if Assigned(FOwner.OnClick) then
      begin
        if not FOwner.SingleClickExec then
        begin
          FOwner.SingleClickExec := True;
          with TSingleClick.Create do
            OnTerminate := OnClick;
        end
        else
        begin
          FOwner.SingleClickExec := False;
        end;
      end
      else
        FOwner.SingleClickExec := False;
    end;
    // 左ボタンのダブルクリック時
    WM_LBUTTONDBLCLK:
    begin
      FOwner.SingleClickExec := True;
      if Assigned(FOwner.OnDblClick) then
        FOwner.OnDblClick(FOwner);
    end;
    // 中ボタンのダウン時
    WM_MBUTTONDOWN:
    begin
      if Assigned(FOwner.OnMouseDown) then
        FOwner.OnMouseDown(FOwner, mbMiddle, [ssMiddle],
          cursorpos.X, cursorpos.Y);
    end;
    // 中ボタンのアップ時
    WM_MBUTTONUP:
    begin
      CurrentProcessActivate;
      if Assigned(FOwner.OnMouseUp) then
        FOwner.OnMouseUp(FOwner, mbMiddle, [ssMiddle],
          cursorpos.X, cursorpos.Y);
    end;
    // 右ボタンのダウン時
    WM_RBUTTONDOWN:
    begin
      // 右ボタンにポップアップメニューを割り当てて、AutoPopupがTrueの場合
      if Assigned(FOwner.RBPopupMenu) and FOwner.AutoPopup then
      begin
        if FOwner.Owner is TForm then
        begin
          SetForegroundWindow(TForm(FOwner.Owner).Handle);
          Application.ProcessMessages;
        end;
        FOwner.RBPopupMenu.Popup(cursorpos.X, cursorpos.Y);
      end
      else if Assigned(FOwner.OnMouseDown) then
        FOwner.OnMouseDown(FOwner, mbRight, [ssRight],
          cursorpos.X, cursorpos.Y);
    end;
    // 右ボタンのアップ時
    WM_RBUTTONUP:
    begin
      CurrentProcessActivate;
      if Assigned(FOwner.OnMouseUp) then
        FOwner.OnMouseUp(FOwner, mbRight, [ssRight],
          cursorpos.X, cursorpos.Y);
    end;
    // バルーン表示イベント
    NIN_BALLOONSHOW:
    begin
      if Assigned(FOwner.FOnBalloonShow) then
        FOwner.FOnBalloonShow(FOwner);
    end;
    // バルーン非表示イベント（Timeout,UserClick後にくる）
    NIN_BALLOONHIDE:
    begin
      if Assigned(FOwner.FOnBalloonHide) then
        FOwner.FOnBalloonHide(FOwner);
    end;
    // バルーンタイムアウトイベント(自然に閉じた場合)
    NIN_BALLOONTIMEOUT:
    begin
      if Assigned(FOwner.FOnBalloonTimeout) then
        FOwner.FOnBalloonTimeout(FOwner);
    end;
    // バルーンクリックイベント(ユーザが閉じた場合)
    NIN_BALLOONUSERCLICK:
    begin
      if Assigned(FOwner.FOnBalloonClick) then
        FOwner.FOnBalloonClick(FOwner);
    end;
  end;
end;

procedure TCallbackWindow.OnClick(Sender: TObject);
begin
  if Assigned(FOwner.OnClick) and FOwner.SingleClickExec then
    FOwner.OnClick(FOwner);
  FOwner.SingleClickExec := False;
end;

procedure GetSysFileVersion(FileName: string; var Major: WORD; Minor, Release, Build: PWORD);
var
  Path: array [0..MAX_PATH] of AnsiChar;
  FilePath: string;
begin
  GetSystemDirectory(@Path, SizeOf(Path));
  FilePath := Path;
  if FilePath[Length(FilePath)] <> '\' then FilePath := FilePath + '\';
  FileName := FilePath + FileName;
  GetFileVersion(FileName, Major, Minor, Release, Build);
end;

procedure GetFileVersion(FileName: string; var Major: WORD; Minor, Release, Build: PWORD);
var
  Dumy: DWORD;
  Size: DWORD;
  Inf: PChar;
  VInf: PVSFixedFileInfo;
begin
  if Minor <> nil then Minor^ := 0;
  if Release <> nil then Release^ := 0;
  if Build <> nil then Build^ := 0;

  // ﾊﾞｰｼﾞｮﾝ情報
  Dumy := 0;
  Size := GetFileVersionInfoSize(PAnsiChar(FileName), Dumy);
  if Size <> 0 then
  begin
    GetMem(Inf, Size);
    GetFileVersionInfo(PChar(FileName), Dumy, Size, Inf);
    try
      if VerQueryValue(Inf, '\', Pointer(VInf), Size) then
      begin
        Major := WORD(VInf^.dwFileVersionMS shr 16);
        if Minor <> nil then
          Minor^ := WORD(VInf^.dwFileVersionMS and $FFFF);
        if Release <> nil then
          Release^ := WORD(VInf^.dwFileVersionLS shr 16);
        if Build <> nil then
          Build^ := WORD(VInf^.dwFileVersionLS and $FFFF);
      end;
    finally
      FreeMem(Inf);
    end;
  end;
end;

procedure TTrayIcon.SetBalloonTitle(const Value: string);
begin
  if FBalloonTitle <> Copy(Value, 1, 63) then
  begin
    FBalloonTitle := Copy(Value, 1, 63);
  end;
end;

procedure TTrayIcon.SetBalloonText(const Value: string);
begin
  if FBalloonText <> Copy(Value, 1, 255) then
  begin
    FBalloonText := Copy(Value, 1, 255);
  end;
end;

procedure TTrayIcon.ShowBalloon;
begin
{$IFDEF D4LATER}
  ShowBalloon(FBalloonIcon, FBalloonTitle, FBalloonText, FBalloonTimeout);
{$ELSE}
  SetTrayIcon(tiHideBalloon);
  SetTrayIcon(tiShowBalloon);
{$ENDIF}
end;

{$IFDEF D4LATER}
procedure TTrayIcon.ShowBalloon(Icon: TBalloonInfoIconFlag);
begin
  ShowBalloon(Icon, FBalloonTitle, FBalloonText, FBalloonTimeout);
end;

procedure TTrayIcon.ShowBalloon(Icon: TBalloonInfoIconFlag; Title: string);
begin
  ShowBalloon(Icon, Title, FBalloonText, FBalloonTimeout);
end;

procedure TTrayIcon.ShowBalloon(Icon: TBalloonInfoIconFlag; Title,
  Text: string);
begin
  ShowBalloon(Icon, Title, Text, FBalloonTimeout);
end;

procedure TTrayIcon.ShowBalloon(Icon: TBalloonInfoIconFlag; Title,
  Text: string; Timeout: TBalloonTimeout);
begin
  BalloonIcon := Icon;
  BalloonTitle := Title;
  BalloonText := Text;
  BalloonTimeout := Timeout;
  SetTrayIcon(tiHideBalloon);
  SetTrayIcon(tiShowBalloon);
end;
{$ENDIF}

procedure TTrayIcon.HideBalloon;
begin
  SetTrayIcon(tiHideBalloon);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TTrayIcon]);
end;

var
  DoneNotifyNotifyIconWarnShell32V6Message: Boolean;

procedure TTrayIcon.MessageOfShell32V6AtDesigning;
begin
  if [csDesigning, csReading, csLoading] * ComponentState = [csDesigning] then
  begin
    if not DoneNotifyNotifyIconWarnShell32V6Message then
    begin
      DoneNotifyNotifyIconWarnShell32V6Message := True;
      MessageBox(GetForegroundWindow,
        NotifyIconWarnShell32V6Message, '注意', MB_ICONEXCLAMATION);
    end;
  end;
end;

procedure TTrayIcon.SetOnBalloonClick(const Value: TNotifyEvent);
begin
  FOnBalloonClick := Value;
  if not Assigned(FOnBalloonClick) then MessageOfShell32V6AtDesigning;
end;

procedure TTrayIcon.SetOnBalloonHide(const Value: TNotifyEvent);
begin
  FOnBalloonHide := Value;
  if not Assigned(FOnBalloonHide) then MessageOfShell32V6AtDesigning;
end;

procedure TTrayIcon.SetOnBalloonShow(const Value: TNotifyEvent);
begin
  FOnBalloonShow := Value;
  if not Assigned(FOnBalloonShow) then MessageOfShell32V6AtDesigning;
end;

procedure TTrayIcon.SetOnBalloonTimeout(const Value: TNotifyEvent);
begin
  FOnBalloonTimeout := Value;
  if not Assigned(FOnBalloonTimeout) then MessageOfShell32V6AtDesigning;
end;

initialization
  // Shell_NotifyIcon用非表示ウィンドウクラスの初期化
  CallbackWindow := nil;

  // Shell_NotifyIcon用Icon IDリストの生成
  IconIDList := TStringList.Create;
  IconIDList.Sorted := False;

finalization
  // Shell_NotifyIcon用Icon IDリストの解放
  IconIDList.Free;

end.

