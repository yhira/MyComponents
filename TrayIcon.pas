//
// Componentware for Delphi - TrayIcon Component Release 1.17
//   Copyright(C) 1996-1998 Yukio Tsujihara
//
// Module      : �g���C�A�C�R���R���|�[�l���g
// Last Update : 10/27/98
// Author      : Yukio Tsujihara
//
// Revision    : Taro Kato
// Last Update : 02/18/2004
//
//
// shell32.dll �̃o�[�W�����T�ȍ~�̐V�@�\�̒ǉ�
//

unit TrayIcon;

interface

uses
  Messages, ShellApi, Windows,
  Classes, Controls, Graphics, ExtCtrls, Forms, Menus, SysUtils ;

const
  NotifyIconErrMessage = '�^�X�N�g���C�ɃA�C�R����o�^�ł��܂���B';
  NotifyIconErrChangeVisibleMessage = '�^�X�N�g���C�A�C�R���̕\�����؂�ւ����܂���B';
  NotifyIconErrBalloonMessage = '�^�X�N�g���C�A�C�R���̃o���[�����b�Z�[�W�\�����؂�ւ����܂���B';
  NotifyIconWarnShell32V6Message = 'OnBalloon�n�C�x���g��Windows XP/2003�Ȃǂ̊��ł̂ݗL���ł��B'+#13#10+
      '�쐬�A�v���P�[�V�����̑Ή�OS�ɂ͏[�����ӂ��Ă��������B';
  WM_NotifyIconMessage = WM_User + 200;

type
  // ENotifyIconError��O�̒�`
  ENotifyIconError = class(Exception);

  // TTrayIconMode�񋓌^�̒�`
  TTrayIconMode = (tiAddIcon, tiModifyIcon, tiDeleteIcon,
                   tiShowBalloon, tiHideBalloon,
                   tiShowIcon, tiHideIcon);

  // TAnimateMode�񋓌^�̒�`
  TAnimateMode = (amAutomatic, amManual);

  // TrayIcon�A�j���[�V�����X���b�h�N���X�̋^����`
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

    uTimeout: UINT; // uVersion �����˂�

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
    property TipHelp: string read FTipHelp write SetTipHelp;  // Balloon���̓^�C�g��
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

  // �V���O���N���b�N�X���b�h�N���X�̒�`
  TSingleClick = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

  // TrayIcon�A�j���[�V�����X���b�h�N���X�̒�`
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

  // Shell_NotifyIcon�p��\���E�B���h�E�N���X�̒�`
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
  NIF_STATE       = $00000008;  // ��Ԃ̕ύX
  NIF_INFO        = $00000010;  // �o���[�����b�Z�[�W

  NIIF_NONE       = $00000000;  // �A�C�R���Ȃ�
  NIIF_INFO       = $00000001;  // ���
  NIIF_WARNING    = $00000002;  // �x��
  NIIF_ERROR      = $00000003;  // �G���[

  NIS_HIDDEN      = $00000001;  // ��\���A�C�R��
  NIS_SHAREDICON  = $00000002;  // ���L�A�C�R��

  // �o���[���֘A���b�Z�[�W
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

  // �A�C�R���o�^���̃`�F�b�N
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

  // �v���p�e�B�̃f�t�H���g�l�̐ݒ�
  AnimateThread := nil;
  FAnimated := False;
  FAnimateMode := amAutomatic;
  FAnimateRate := 500;
  FAutoPopup := True;
  FEnabled := True;
  FTipHelp := 'TipHelp';
  FVisible := False;
  FBalloonTimeout := 10;

  // Icon�v���p�e�B�p�A�C�R���f�[�^�̈�m��
  FIcon := TIcon.Create;
  IconRegisted := False;
  // �V���O���N���b�N����p�t���O�̏�����
  SingleClickExec := False;

  // �f�U�C�����łȂ��ꍇ�̏�����
  if not (csDesigning in ComponentState) then
  begin
    // �A�C�R����OnChange�C�x���g��ݒ�
    FIcon.OnChange := IconChange;

    // Shell_NotifyIcon�p��\���R�[���o�b�N�E�B���h�E����������Ă��Ȃ��ꍇ
    if CallbackWindow = nil then
    begin
      CallbackWindow := TCallbackWindow.Create(Owner);
      CallbackWindow.Parent := TWinControl(Owner);
    end;

    // Shell_NotifyIcon�p�f�[�^�̈�m�ۂƏ�����
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
  // �f�U�C�����łȂ��ꍇ�A�A�C�R���̓o�^
  if not (csDesigning in ComponentState) then
    SetTrayIcon(tiAddIcon);

  inherited Loaded;
end;

destructor TTrayIcon.Destroy;
begin
  // �A�C�R���o�^���I�[�o�ɂ���O�������ȊO�A�j������
  if IconID <> 0 then
  begin
    // �f�U�C�����łȂ��ꍇ�A�j������
    if not (csDesigning in ComponentState) then
    begin
      // �A�j���[�V�����X���b�h�̔j��
      if AnimateThread <> nil then
      begin
        AnimateThread.Terminate;
        if AnimateThread.Suspended then
          AnimateThread.Resume;
        AnimateThread.Free;
        FAnimated := False;
      end;

      // �g���C�ɃA�C�R�����\������Ă���ꍇ�A�A�C�R���̔j��
      if IconRegisted then
        SetTrayIcon(tiDeleteIcon);

      // Shell_NotifyIcon�p�f�[�^�̈�j��
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
    // �������蓮�֐؂�ւ����ꍇ
    if FAnimateMode = amAutomatic then
    begin
      FAnimateMode := amManual;
    end
    // �蓮�������֐؂�ւ����ꍇ
    else
    begin
      FAnimateMode := amAutomatic;
      AnimateThread.Resume;
    end;
  end;
end;

procedure TTrayIcon.AnimatePlay(AAnimateMode: TAnimateMode);
begin
  // �A�j���[�V�������łȂ��A�A�j���[�V�����A�C�R�����ݒ肳��Ă���ꍇ
  if (not FAnimated) and (FAnimateIcons <> nil) then
  begin
    // �A�j���[�V�����A�C�R���ɂP�ȏ�̃A�C�R�����o�^����Ă���ꍇ�A
    // �A�j���[�V�������J�n
    if FAnimateIcons.Count > 0 then
    begin
      // �A�j���[�V�����X���b�h���������̏ꍇ
      if AnimateThread = nil then
      begin
        // �A�j���[�V�����X���b�h�̐���
        AnimateThread := TTrayIconAnimate.Create(Self);
      end;
      // �A�j���[�V�����֘A�̕ϐ���������
      FAnimated := True;
      FAnimateMode := AAnimateMode;
      // �A�j���[�V�����X���b�h�̍ĊJ
      AnimateThread.Resume;
    end;
  end;
end;

procedure TTrayIcon.AnimateStep;
begin
  // �A�j���[�V�������Ŏ蓮�A�j���[�V�����̏ꍇ
  if FAnimated and (FAnimateMode = amManual) then
    AnimateThread.Resume;
end;

procedure TTrayIcon.AnimateStop;
begin
  // �A�j���[�V�������J�n����Ă���ꍇ�A�A�j���[�V�������~
  if FAnimated then
  begin
    // �A�j���[�V�����X���b�h�̒�~
    FAnimated := False;
    if FAnimateMode = amManual then
      AnimateThread.Resume;
    // �A�j���[�V�����X���b�h�����S�ɒ�~����܂Ń��[�v
    while not AnimateThread.Suspended do;

    // �A�j���[�V�����A�C�R�������Ƃ̃A�C�R���ɕύX
    IconChange(FIcon);  // 2001/01/25 Self->FIcon
  end;
end;

procedure TTrayIcon.IconChange(Sender: TObject);
begin
  // �g���C�ɃA�C�R�����\������Ă���ꍇ�A�A�C�R���̕ύX
  if IconRegisted and (not (FAnimated and (FAnimateMode = amAutomatic))) then
    SetTrayIcon(tiModifyIcon);
end;

procedure TTrayIcon.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  // �t�H�[����̑��̃R���|�[�l���g���폜���ꂽ�ꍇ
  if (Operation = opRemove) then
  begin
    // �폜���ꂽ�R���|�[�l���g��TPopupMenu�ŁA
    // LBPopupMenu�ARBPopupMenu�ɐݒ肳��Ă����ꍇ�A�ݒ�𖳌��ɕύX
    if AComponent is TPopupMenu then
    begin
      if AComponent = FLBPopupMenu then
        FLBPopupMenu := nil
      else if AComponent = FRBPopupMenu then
        FRBPopupMenu := nil;
    end
    // �폜���ꂽ�R���|�[�l���g��TImageList�ŁA
    // AnimateIcons�ɐݒ肳�ꂽ�ꍇ�A�ݒ�𖳌��ɕύX
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
    // �A�C�R�����ݒ肳�ꂽ�ꍇ
    if Value <> nil then
      FIcon.Assign(Value)
    // �A�C�R�����N���A(�폜)���ꂽ�ꍇ
    else
    begin
      FIcon.ReleaseHandle;
      FIcon.Handle := 0;
{=====================================
2000.01.25 OwnerForm.Icon, Appliction.Icon �ő�։\�Ȃ��ߔ�\�����͂��Ȃ�
      // �A�C�R�����\���ɂ��邽�߁AVisible�v���p�e�B��False�ɐݒ�
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

    // �f�U�C�����łȂ��ꍇ�A�`�b�v�w���v�̕ύX
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
  // Shell_NotifyIcon�p�f�[�^�̈�Ƀv���p�e�B�̒l��ݒ�
  with NIconData^ do
  begin
    // �A�j���[�V�������łȂ����A�蓮�A�j���[�V�������̏ꍇ�A
    // Icon�v���p�e�B�̃A�C�R����ݒ�
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
      // Visible�v���p�e�B��True�̏ꍇ�A�A�C�R���̓o�^
      if FVisible then
      begin
        // Shell_NotifyIcon�p�E�B���h�E�n���h����(��)�ݒ�
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
    // 2001/01/25 Icon�v���p�e�B���Ȃ���� OwnerForm �� Application �𗘗p
    if GetIconHandle <> 0 then
      FVisible := Value
    else
      FVisible := False;

    // �f�U�C�����łȂ��A�R���|�[�l���g�����[�h���łȂ��ꍇ�A�\���E��\���̐ؑւ�
    if not (csDesigning in ComponentState)
      and not (csLoading in ComponentState) then
    begin
      // �V�F�����Â��ꍇ�͓o�^�^�����̐؂�ւ�
      // ���\�����͕K���E�[�ɓo�^����Ă��܂��B
      // �V�F�����V�����ꍇ�͕\���^��\�����؂�ւ�����B
      // ���g���C�A�C�R���̍��[����̑��Έʒu������Ȃ�

      // ��\�����\���֐ؑւ����ꍇ
      if FVisible then
      begin
        if (not IconRegisted) or (FShell32Version < 5) then
          SetTrayIcon(tiAddIcon)
        else
          SetTrayIcon(tiShowIcon);

      // �\������\���֐ؑւ����ꍇ
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

  // Execute���\�b�h�I����ATSingleClick�X���b�h�N���X�̎����j���ݒ�
  FreeOnterminate := True;
end;

procedure TSingleClick.Execute;
begin
  // �V���O���N���b�N�̔��莞�Ԓ��A�X���b�h�̒�~
  Sleep(GetDoubleClickTime + 50);
end;

constructor TTrayIconAnimate.Create(AOwner: TTrayIcon);
begin
  inherited Create(True);

  // �X���b�h���LTrayIcon�R���|�[�l���g�̐ݒ�
  Owner := AOwner;
  // �A�j���[�V�����t���[���̏�����
  AnimateFrame := 0;
  // �A�j���[�V�����A�C�R���p�A�C�R���f�[�^�̈�m��
  Icon := TIcon.Create;
end;

destructor TTrayIconAnimate.Destroy;
begin
  // �A�j���[�V�����A�C�R���p�A�C�R���f�[�^�̈�̉��
  Icon.Free;

  inherited Destroy;
end;

procedure TTrayIconAnimate.Execute;
begin
  while not Terminated do
  begin
    if Owner.FAnimated then
    begin
      // AnimateIcons�̓��e���ύX����A���ɕ\������A�C�R�����Ȃ��Ȃ����ꍇ
      // �ŏ��̃A�C�R���ɖ߂�
      if AnimateFrame > (Owner.FAnimateIcons.Count - 1) then
        AnimateFrame := 0;

      // �A�C�R���̕ύX
      Owner.FAnimateIcons.GetIcon(AnimateFrame, Icon);
      // �g���C�ɃA�C�R�����\������Ă���ꍇ�A�A�C�R���̔��f
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

      // ���ɕ\������A�C�R���̃t���[���ݒ�
      if AnimateFrame < (Owner.FAnimateIcons.Count - 1) then
        Inc(AnimateFrame)
      else
        AnimateFrame := 0;

      // �A�j���[�V�������[�h�������̏ꍇ�A�w�肳�ꂽ�~���b�����X���b�h���~
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
  // TTrayIcon�I�u�W�F�N�g�̃C���f�b�N�X�ʒu�̐ݒ�
  objindex := IconIDList.IndexOf(IntToStr(Msg.wParam));
  if objindex >= 0 then
  begin
    FOwner := TTrayIcon(IconIDList.Objects[objindex]);
    // Enabled�v���p�e�B��False�̏ꍇ�A���Ƀv���V�[�W�����甲���o��
    if not FOwner.FEnabled then
      Exit;
  end
  else
    Exit;

  // �}�E�X�J�[�\���̌��݈ʒu�擾
  GetCursorPos(cursorpos);

  // �}�E�X�̃��b�Z�[�W�ɂ�菈������
  case Msg.lParam of
    // �A�C�R����̒ʉߎ�
    WM_MOUSEMOVE:
    begin
      if Assigned(FOwner.OnMouseMove) then
        FOwner.OnMouseMove(FOwner, [], cursorpos.X, cursorpos.Y);
    end;
    // ���{�^���̃_�E����
    WM_LBUTTONDOWN:
    begin
      // ���{�^���Ƀ|�b�v�A�b�v���j���[�����蓖�ĂāAAutoPopup��True�̏ꍇ
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
    // ���{�^���̃A�b�v��
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
    // ���{�^���̃_�u���N���b�N��
    WM_LBUTTONDBLCLK:
    begin
      FOwner.SingleClickExec := True;
      if Assigned(FOwner.OnDblClick) then
        FOwner.OnDblClick(FOwner);
    end;
    // ���{�^���̃_�E����
    WM_MBUTTONDOWN:
    begin
      if Assigned(FOwner.OnMouseDown) then
        FOwner.OnMouseDown(FOwner, mbMiddle, [ssMiddle],
          cursorpos.X, cursorpos.Y);
    end;
    // ���{�^���̃A�b�v��
    WM_MBUTTONUP:
    begin
      CurrentProcessActivate;
      if Assigned(FOwner.OnMouseUp) then
        FOwner.OnMouseUp(FOwner, mbMiddle, [ssMiddle],
          cursorpos.X, cursorpos.Y);
    end;
    // �E�{�^���̃_�E����
    WM_RBUTTONDOWN:
    begin
      // �E�{�^���Ƀ|�b�v�A�b�v���j���[�����蓖�ĂāAAutoPopup��True�̏ꍇ
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
    // �E�{�^���̃A�b�v��
    WM_RBUTTONUP:
    begin
      CurrentProcessActivate;
      if Assigned(FOwner.OnMouseUp) then
        FOwner.OnMouseUp(FOwner, mbRight, [ssRight],
          cursorpos.X, cursorpos.Y);
    end;
    // �o���[���\���C�x���g
    NIN_BALLOONSHOW:
    begin
      if Assigned(FOwner.FOnBalloonShow) then
        FOwner.FOnBalloonShow(FOwner);
    end;
    // �o���[����\���C�x���g�iTimeout,UserClick��ɂ���j
    NIN_BALLOONHIDE:
    begin
      if Assigned(FOwner.FOnBalloonHide) then
        FOwner.FOnBalloonHide(FOwner);
    end;
    // �o���[���^�C���A�E�g�C�x���g(���R�ɕ����ꍇ)
    NIN_BALLOONTIMEOUT:
    begin
      if Assigned(FOwner.FOnBalloonTimeout) then
        FOwner.FOnBalloonTimeout(FOwner);
    end;
    // �o���[���N���b�N�C�x���g(���[�U�������ꍇ)
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

  // �ް�ޮݏ��
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
        NotifyIconWarnShell32V6Message, '����', MB_ICONEXCLAMATION);
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
  // Shell_NotifyIcon�p��\���E�B���h�E�N���X�̏�����
  CallbackWindow := nil;

  // Shell_NotifyIcon�pIcon ID���X�g�̐���
  IconIDList := TStringList.Create;
  IconIDList.Sorted := False;

finalization
  // Shell_NotifyIcon�pIcon ID���X�g�̉��
  IconIDList.Free;

end.

