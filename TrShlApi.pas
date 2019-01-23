{//////////////////////////////////////////////////////////////////////////////
//	�^�X�N�g���C�A�C�R���\���֘A���j�b�g				     //
//	2002.04.15 H.Okamoto						     //
//	�ŏI�X�V��	2004.02.27					     //
//////////////////////////////////////////////////////////////////////////////}
unit TrShlApi;

{/////////////////////////////////////////////////////////////////////////////}
interface
{/////////////////////////////////////////////////////////////////////////////}

uses
  Windows, Messages, Classes {$IFNDEF NO_USE_CUSTOM_TOOLTIP}, Graphics{$ENDIF};

{************************************************************************}
{* 	�萔��`							*}
{************************************************************************}
const
  WM_TaskTrayMessage	= WM_User + 200;
  NotifyIconErrMessage    = '�^�X�N�g���C�ɃA�C�R����o�^�ł��܂���B';
  NotifyIconModErrMessage = '�^�X�N�g���C�̃A�C�R����ύX�ł��܂���B';

  {�^�X�N�g���C�N���X�p���b�Z�[�W}
  WM_MOUSE_ENTER	= WM_User + 210;	{�}�E�X���g���C�̃A�C�R�����ɓ������Ƃ��̃��b�Z�[�W}
  WM_MOUSE_EXIT		= WM_User + 211;	{�@�@�@�V�@�@�@�̃A�C�R��������o���Ƃ��̃��b�Z�[�W}
  WM_MOUSE_CLICK	= WM_User + 212;	{�@�@�@�V�@�@�@�̃A�C�R����Ń}�E�X�N���b�N�����Ƃ��̃��b�Z�[�W}
  WM_TASKBER_RESTART	= WM_User + 220;	{�^�X�N�o�[���ċN���������b�Z�[�W}

  TRAY_ICON_WINDOW_CLASS_NAME	= 'TaskTrayHandle';

  {Windows XP �Ή� �^�X�N�g���C�ɃA�C�R�����\������Ȃ����Ƃ�����Ƃ��̃G���[}
  {����`�̎��ʎq�G���[�ɂȂ�����R�����g�������Ă�������}
  //ERROR_TIMEOUT   = 1460;

{************************************************************************}
{* 	�e���`							*}
{************************************************************************}
type
  {�^�X�N�g���C�A�C�R���n���h���̃��b�Z�[�W�C�x���g�n���h��}
  TOnMessage	= procedure (var Message: TMessage) of object;

{*****************************************************************************
	Shell32.dll Ver5.0 �ȍ~�p(Windows 2000 + IE5.0 �ȍ~)
******************************************************************************}
const
  NIM_SETFOCUS		= $0004;
  NIM_SETVERSION	= $0008;

  {TNotifyIconData.uFlags �ǉ��萔}
  {$EXTERNALSYM NIF_STATE}
  NIF_STATE		= $00000008;
  {$EXTERNALSYM NIF_INFO}
  NIF_INFO		= $00000010;

  {TNotifyIconData.dwState}
  NIS_HIDDEN 		= $00000001;
  NIS_SHAREDICON	= $00000002;

  {TNotifyIconData.uTimeoutOrVersion}
  {�^�X�N�g���C�A�C�R���Ɋւ��铮��o�[�W����:
   �ʏ�͂O��Win95���ォ��̃��b�Z�[�W�����Ɠ����ł�}
  NOTIFYICON_VERSION	= $00000001;

  {TNotifyIconData.dwInfoFlags Konstanten}
  {�o���[���w���v�ɕ\������A�C�R���̎��}
  NIIF_NONE		= $00000000;	{�A�C�R���Ȃ�}
  NIIF_INFO		= $00000001;	{���}
  NIIF_WARNING		= $00000002;	{�x��}
  NIIF_ERROR		= $00000003;	{�G���[}

  {�o���[���֘A���b�Z�[�W Shell32.dll �̃o�[�W������ 6.0�ȍ~�H}
  {(1):�^�X�N�g���C�A�C�R���Ɋւ��铮��o�[�W������1�̂Ƃ��p�炵��
   (2):Shell32.dll �̃o�[�W������6(Windows XP)�ȍ~�炵��}
  NIN_SELECT		= WM_USER + 0;		{(1)}
  NINF_KEY		= $1;
  NIN_KEYSELECT		= NIN_SELECT or NINF_KEY;	{(1)=WM_USER + 1}
  NIN_BALLOONSHOW	= WM_USER + 2;		{(2):�o���[���w���v��\�������Ƃ��̃��b�Z�[�W}
  NIN_BALLOONHIDE	= WM_USER + 3;		{(2):�o���[���w���v����\���ɂȂ����Ƃ��̃��b�Z�[�W}
  NIN_BALLOONTIMEOUT	= WM_USER + 4;		{(2):�^�C���A�E�g�Ńo���[���w���v����\���ɂȂ�Ƃ��ɔ���}
  NIN_BALLOONUSERCLICK	= WM_USER + 5;		{(2):���[�U�[���N���b�N���ăo���[���w���v����\���ɂȂ�Ƃ��ɔ���}

type
  {�^�X�N�g���C�ɃA�C�R���\�����邽�߂̍\���� Ver 5 �ȍ~}
  PNewNotifyIconData = ^TNewNotifyIconData;
  _NEWNOTIFYICONDATA	= packed record
    cbSize		:DWORD;
    Wnd			:HWND;
    uID			:UINT;
    uFlags		:UINT;
    uCallbackMessage	:UINT;
    hIcon		:HICON;
    szTip		:array [0..127] of AnsiChar;
    {�ǉ���}
    dwState		:DWORD;
    dwStateMask		:DWORD;
    szInfo		:array [0..255] of AnsiChar;
    uTimeout		:UINT;
    szInfoTitle		:array [0.. 63] of AnsiChar;
    dwInfoFlags		:DWORD;
  end;
  TNewNotifyIconData = _NEWNOTIFYICONDATA;

  {DLL�̃o�[�W�����𓾂�\����}
  TDllVersionInfo	= packed record
    cbSize		:DWORD;
    dwMajorVersion	:DWORD;
    dwMinorVersion	:DWORD;
    dwBuildNumber	:DWORD;
    dwPlatformID	:DWORD;
  end;

{************************************************************************}
{* 	�J�X�^���c�[���`�b�v�N���X					*}
{************************************************************************}
{$IFNDEF NO_USE_CUSTOM_TOOLTIP}
const
  MOUSE_BUTTON_LEFT	= 1;
  MOUSE_BUTTON_RIGHT	= 2;
  MOUSE_BUTTON_MIDDLE	= 3;

type
  {�}�E�X�̏��}
  TTrayIconMouseState	= (timsLDown, timsRDown, timsMDown, timsEnter);
  TTrayIconMouseStates	= set of TTrayIconMouseState;

  TCustomToolTipStyle	=class(TPersistent)
  protected
    FOwnerHWnd,				{�^�X�N�g���C�A�C�R���n���h��}
    FHTooltip		:HWND;		{�c�[���`�b�v�E�C���h�E�n���h��}

    FIconRect		:TRect;		{�^�X�N�g���C��̃A�C�R���̗̈�}
    {FExitMouse		:Boolean;	{True:�}�E�X�J�[�\�����A�C�R���O�ɂ���}
    FThread		:TThread;	{�}�E�X��In/Out�𔻒肷�邽�߂̃X���b�h}
    FMouseStates	:TTrayIconMouseStates;	{�}�E�X�J�[�\���̏��}
    FWaitClick		:Boolean;
    {�v���p�e�B}
    FRequestSglDbl	:Boolean;	{True:�V���O���N���b�N�ƃ_�u���N���b�N�𔻒肷��}
    FUseDefault		:Boolean;	{True:�f�t�H���g�̃q���g�\�����s��}
    FHintFont		:TFont;
    //FDelayTimeAutoPop	:Integer;	{�x������}
    //FDelayTimeInitial	:Integer;
    //FDelayTimeReshow	:Integer;
    FBackGrdColor	:TColor;	{�w�i�F}
    //FMaxTipWidth	:Integer;	{TipWiondow�ő啝}
    //FMargin		:TRect;		{�㉺���E�}�[�W��}
  public
    constructor Create;
    destructor Destroy; override;

  protected
    {<< �v���p�e�BIO >>}
    {�I�[�i�[�̐ݒ�}
    procedure SetOwner(aOwnerHWND	:HWND);

    {�w��}�E�X��Ԃł��邩}
    function GetMouseState(aTrayIconMouseState: TTrayIconMouseState): Boolean;
    {�ҋ@���̃}�E�X�{�^��}
    function GetWaitClickButton: TTrayIconMouseState;

    {�x������
    function GetDelayTime(aIndex: Integer): Integer;
    procedure SetDelayTime(aIndex: Integer; aValue: Integer);}
    {�e�L�X�g�E�w�i�F}
    function GetColor(aIndex: Integer): TColor;
    procedure SetColor(aIndex: Integer; aColor: TColor);
    {�e�L�X�g�T�C�Y
    function GetTextSize: Integer;
    procedure SetTextSize(aValue: Integer);}
    {�t�H���g
    function GetFont: TFont;
    procedure SetFont(aFont: TFont);}
    {TipWindow�ő啝
    function GetMaxTipWidth: Integer;
    procedure SetMaxTipWidth(aValue: Integer);}
    {�㉺���E�}�[�W��
    function GetMargin(aIndex: Integer): Integer;
    procedure SetMargin(aIndex: Integer; aValue: Integer);}

  protected
    {���b�Z�[�W����}
    procedure WndProc(var Message: TMessage);

    {�c�[���`�b�v�̃n���h���𓾂�}
    {���v���������ׂẴA�C�R���͓����c�[���`�b�v�����L���Ă���炵��}
    function GetTooltipHandle: HWND;

    {�}�E�X���A�C�R�����ɓ��������̏���}
    procedure OnMouseEnter;
    {�}�E�X���A�C�R���O�ɏo�����̏���}
    procedure OnMouseExit;

    {�}�E�X�N���b�N����}
    procedure OnMouseClick(aMouseButton: TTrayIconMouseState);

    {�^�X�N�g���C�A�C�R���̃��b�Z�[�W����}
    procedure TrayIconWndProc(var Message: TMessage);

    {�g���C�A�C�R���͈͂𖳌�������}
    procedure DisableTrayIconRect;

  public
    {�f�[�^�̕���}
    procedure Assign(aSource: TPersistent); override;

  protected
    {�}�E�X�C�x���g}
    procedure DoMouseEnter;
    procedure DoMouseExit;
    procedure DoMouseClick(aMouseButton: TTrayIconMouseState);
    procedure DoMouseDblClick(aMouseButton: TTrayIconMouseState);

    {�c�[���`�b�v�ύX}
    procedure SetCustomToolTip;
    {�W���ɖ߂�}
    procedure SetDefaultToolTip;

  protected
    property MouseEnter: Boolean index timsEnter read GetMouseState;
    property RequestSglDbl: Boolean read FRequestSglDbl write FRequestSglDbl;

    property UseDefault: Boolean read FUseDefault write FUseDefault;
    {�x������
    property DelayTimeAutoPopup: Integer index 1 read GetDelayTime write SetDelayTime default 5000;
    property DelayTimeInitial  : Integer index 2 read GetDelayTime write SetDelayTime default 500;
    property DelayTimeReshow   : Integer index 3 read GetDelayTime write SetDelayTime default 100;}
    {�w�i�F}
    property BackGroundColor: TColor index 1 read GetColor write SetColor;
    {�e�L�X�g�F�ƃT�C�Y}
    property TextColor: TColor index 2 read GetColor write SetColor;
    {property TextSize: Integer read GetTextSize write SetTextSize default 9;}

    {�t�H���g�C���X�^���X
    property HintFont: TFont read GetFont write SetFont;}

    {�ő啝...���ʂȂ��݂����ł�
    property MaxTipWidth: Integer read GetMaxTipWidth write SetMaxTipWidth default 400;}
    {�㉺���E�}�[�W��
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
    {�x������...���ʂȂ��݂����ł�
    property DelayTimeAutoPopup default 5000;
    property DelayTimeInitial default 500;
    property DelayTimeReshow default 100;}
    {�w�i�F}
    property BackGroundColor;
    {�e�L�X�g�F�ƃT�C�Y}
    property TextColor;
    {...���ʂȂ��݂����ł�
    property TextSize default 9;
    property HintFont;}
    {�ő啝...���ʂȂ��݂����ł�
    property MaxTipWidth default 400;}
    {�㉺���E�}�[�W��...���ʂȂ��݂����ł�
    property MarginTop;
    property MarginLeft;
    property MarginRight;
    property MarginBottom;}
  end;

{�v���p�e�B:�x�����Ԃɂ���
DelayTimeAutoPopup
  �g���C�A�C�R���ɊO�ڂ���l�p�`�̓����Ń|�C���^����~���Ă���Ƃ���
  �c�[���`�b�v�q���g�E�C���h�E��\�����Ă��鎞��

DelayTimeInitial
  �g���C�A�C�R���ɊO�ڂ���l�p�`�̓����Ń|�C���^����~���Ă���c�[���`�b�v
  �q���g�E�C���h�E��\������܂ł̎���

DelayTimeReshow
  �|�C���^���ʂ̃g���C�A�C�R���Ɉړ����Ă��玟�̃c�[���`�b�v�q���g�E�C���h�E��
  �\������܂ł̎���
}
{$ENDIF}

{************************************************************************}
{* 	�^�X�N�g���C�A�C�R���\���p�N���X				*}
{************************************************************************}
type
  {�o���[���`�b�v�w���v�̃A�C�R���^�C�v}
  TBalloonIconType	= (bitNone, bitInfo, bitWarning, bitError);
  {�^�X�N�g���C�A�C�R���̃A�C�R����}
  TOnTrayIconFlag	= (otifRegisted, otifShowing);
  TOnTrayIconFlags	= set of TOnTrayIconFlag;

  TTaskTrayIcon	=class
  private
    {FShellNew		:Boolean;		{True:Shell32.dll ��Ver5.0�ȍ~}
    FShell32Ver		:Integer;		{Shell32.dll�̃o�[�W����}
    FUpdateCount	:Integer;
  protected
    FTrayHandle		:HWnd;			{�^�X�N�g���C�p Handle}
    FIconData		:TNewNotifyIconData;	{�g���C�A�C�R���f�[�^}
   {FOnTaskTray		:Boolean;		{True:�^�X�N�g���C�ɕ\����}
    FOnTrayIconFlag	:TOnTrayIconFlags;	{�^�X�N�g���C�ւ̃A�C�R���\�����}
    FEnabledHide	:Boolean;		{True: �A�C�R����\���͉B�������ɂ���
						 ShellNewVersion = True �̂Ƃ��̂ݗL��}
    FOnMessage		:TOnMessage;		{���b�Z�[�W����}

    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    FToolTipStyle	:TToolTipStyle;		{�c�[���`�b�v��ω�������N���X}
    {$ENDIF}
  public
    FrontToWindow	:Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    {�v���p�e�B����}
    procedure Assign(aDest	:TTaskTrayIcon);

  protected
    {�^�X�N�g���C�pWindowProcedure}
    procedure TrayWndProc(var Message: TMessage);

    {�^�X�N�g���C�o�^�p�n���h���̎擾}
    function GetTrayHandle:HWnd;

    {�}�E�X���A�C�R�����ɓ��������̏���}
    procedure DoMouseEnter;
    {�}�E�X���A�C�R���O�ɏo�����̏���}
    procedure DoMouseExit;

    {�^�X�N�g���C�ɃA�C�R�����o�^����Ă��邩}
    function GetIconRegisted: Boolean;
    procedure SetIconRegisted(aValue: Boolean);
    {�^�X�N�g���C�ɃA�C�R�����\������Ă��邩}
    function GetOnTaskTray: Boolean;
    procedure SetOnTaskTray(aValue: Boolean);

  public
    {�v���p�e�BIO}
    {�g���C�ɓo�^����A�C�R���̃n���h��}
    function GetIconHandle:HICON;
    procedure SetIconHandle(aIconHandle	:HICON);

    {�g���C�ŕ\������e�L�X�g}
    function GetTipHelp:String;
    procedure SetTipHelp(aTipHelp	:String);

    {<<<<< Windows2000 + IE5.0�ȍ~ >>>>>}
    {Shell32.dll�̃o�[�W������ 5.0�ȍ~}
    function GetShellNewVersion: Boolean;

    {�o���[���w���v�̃^�C�g��}
    function GetBalloonHelpTitle:String;
    procedure SetBalloonHelpTitle(aHelpTitle	:String);

    {�o���[���w���v�̃e�L�X�g}
    function GetBalloonHelp:String;
    procedure SetBalloonHelp(aHelpText	:String);

    {�g���C�ŕ\������o���[���w���v�̃^�C���A�E�g}
    function GetUTimeOut:Integer;
    procedure SetUTimeOut(aValue	:Integer);

    {�o���[���w���v�ŕ\������A�C�R���̎��}
    function GetBalloonIconType:TBalloonIconType;
    procedure SetBalloonIconType(aValue	:TBalloonIconType);
    {<<<<< �����܂� >>>>>}

  public
    {�������̍X�V�J�n}
    procedure BeginUpdate;
    {�������̍X�V�I��}
    procedure EndUpdate;
    {�������̍X�V����}
    procedure FinishUpdate;

    {�X�V������}
    function Updating: Boolean;	{True:�X�V��}

    {�g���C�ɃA�C�R���o�^}
    function SetTrayIcon:Boolean;

    {�g���C����A�C�R������}
    function HideTrayIcon:Boolean;
    function DeleteTrayIcon:Boolean;

    {�g���C�A�C�R���̕ύX}
    function ModifyIcon:Boolean;

    {�o���[���w���v��\������}
    function ShowBalloonHelpSE(aHelpTitle,			{�^�C�g��}
    			       aHelpText	:String;	{���b�Z�[�W}
                               aTimeOut		:Integer;	{�^�C���A�E�g(�~���b)}
                               aIconType	:TBalloonIconType)
                             			:Boolean;	{True:����}

    function ShowBalloonHelp: Boolean;	{True:����}

    {�o���[���w���v�����}
    function HideBalloonHelp: Boolean;	{True:����}

    {�A�C�R�����ɃJ�[�\�������邩}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    function IsCursorInnerRect(aX, aY: Integer): Boolean;
    {$ENDIF}

  public
    {�v���p�e�B}
    property Icon:HICON read GetIconHandle write SetIconHandle;
    property IconRegisted: Boolean read GetIconRegisted write SetIconRegisted;	{True: �^�X�N�g���C�ɃA�C�R���o�^�ς�}
    property OnTaskTray: Boolean read GetOnTaskTray write SetOnTaskTray;	{True: �^�X�N�g���C�ɃA�C�R���\����}
    property Shell32Version: Integer read FShell32Ver;
    property ShellNewVersion: Boolean read GetShellNewVersion;			{True: Shell32.dll�̃o�[�W������ 5.0 �ȍ~}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    property ToolTipStyle: TToolTipStyle read FToolTipStyle;
    {$ENDIF}
    property TrayHandle: HWnd read GetTrayHandle;
    {�C�x���g}
    property OnMessage:TOnMessage read FOnMessage write FOnMessage;
  end;

{************************************************************************}
{*	TaskTrayIconClass�pMessageHandler				*}
{************************************************************************}
type
  TTrayIconWinProcList	= class(TList)
  protected
    uTaskbarRestart	:UINT;
  public
    {�N���G�C�g}
    constructor Create;
    {�j��}
    destructor Destroy; override;

  protected
    {�N���X��Windows�ɓo�^����}
    procedure RegisterClass;
    {�N���X��Windows����폜����}
    procedure UnRegisterClass;

    {���b�Z�[�W����}
    function MessageDeliver(aHWND	:HWND;
    			    var Message	:TMessage)
                          		:Boolean;	{True:��������}

  public
    {�N���X��ǉ�����}
    procedure AddClass(aTaskTrayIcon	:TTaskTrayIcon);
    {�N���X���폜����}
    procedure DeleteClass(aTaskTrayIcon	:TTaskTrayIcon);

  end;

{************************************************************************}
{* 	�֐���`							*}
{************************************************************************}
{Shell32.dll�̃o�[�W�����𓾂�}
function GetShellDllVersion:Longint;

{/////////////////////////////////////////////////////////////////////////////}
implementation
{/////////////////////////////////////////////////////////////////////////////}

uses
  SysUtils, CommCtrl, ShellApi;

{************************************************************************}
{* 	���[�J���C���X�^���X						*}
{************************************************************************}
var
  {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
  {ToolTipClass		:TCustomToolTipStyle;}
  {$ENDIF}
  TrayIconWinProcList	:TTrayIconWinProcList;

{************************************************************************}
{* 	���[�J���萔��`						*}
{************************************************************************}
(*...CommCtrl.pas ���j�b�g�ɒ�`�ς�...
const
  TOOLTIPS_CLASS	= 'tooltips_class32';
  TTS_NOPREFIX		= 2;

  {�c�[���`�b�v�萔}
  TTM_SETTIPBKCOLOR	= WM_USER + 19; // �w�i�F�̐ݒ�
  TTM_SETTIPTEXTCOLOR	= WM_USER + 20; // �e�L�X�g�F�̐ݒ�
  TTM_GETDELAYTIME	= WM_USER + 21; // �x�����Ԃ̎擾
  TTM_GETTIPBKCOLOR	= WM_USER + 22; // �w�i�F�̎擾
  TTM_GETTIPTEXTCOLOR	= WM_USER + 23; // �e�L�X�g�F�̎擾
  TTM_SETMAXTIPWIDTH	= WM_USER + 24; // �`�b�v�E�B���h�E�̍ő啝�̐ݒ�
  TTM_GETMAXTIPWIDTH	= WM_USER + 25; // �`�b�v�E�B���h�E�̍ő啝�̎擾
  TTM_SETMARGIN		= WM_USER + 26; // �}�[�W���̐ݒ�
  TTM_GETMARGIN		= WM_USER + 27; // �}�[�W���̎擾
  TTM_POP		= WM_USER + 28; // ��������
  TTM_UPDATE		= WM_USER + 29; // �����ĕ`��  // Tooltip constants
  TTM_SETTITLEA		= WM_USER + 32;

  {�x������(DelayTime) �̎擾�ݒ�p}
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
    {�W�����\�b�h}
    if defProc then begin
      Result := DefWindowProc(hWnd, aMsg, wParam, lParam);
    end;
  end;

{************************************************************************}
{*	Mouse Enter/Reave �C�x���g�����pThread				*}
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
      {�ҋ@}
      Sleep(100);
      {�}�E�X�O����}
      Synchronize(OnMouseExit);
    end;
  end;

procedure TMouseEventMaker.OnMouseExit;
  begin
    {�}�E�X�̃A�C�R���O������s��}
    Owner.OnMouseExit;
  end;
{$ENDIF}

{************************************************************************}
{* 	���[�J���֐�							*}
{************************************************************************}
CONST
  {�^�X�N�g���C�̃A�C�R���̃T�C�Y}
  TASKTRAY_ICONSIZE	= {16}32;	{�����ŉB��邱�Ƃ�����̂Ŕ{�̃T�C�Y�ŗl�q��}
  {�����Ȕ͈͒萔}
  DISABLE_RECT	:TRect=(Left:0; Top:0; Right:0; Bottom:0);

{�͈͂𖳌�������:�^�X�N�g���C�̃A�C�R����(0.0)���܂ޔ͈͂ɂȂ�Ȃ����Ƃ��O��}
procedure DisableRect(var aRect :TRect);
  begin
    {FillChar(aRect, SizeOf(TRect), #$0);}
    aRect := DISABLE_RECT;
  end;

{��`�͈͂��X�V����}
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
      {���E�͈͂̍X�V}
      if aRect.Left > aPos.x then aRect.Left := aPos.x
      else if aRect.Right < aPos.x then aRect.Right := aPos.x;
      {�㉺�͈͂̍X�V}
      if aRect.Top > aPos.y then aRect.Top := aPos.y
      else if aRect.Bottom < aPos.y then aRect.Bottom := aPos.y;
    end;
  end;

{�_���͈͓��ł��邩}
function IsInnerRect(aRect :TRect; aPos: TPoint): Boolean;
  begin
    Result := (aRect.Left <= aPos.x) and (aRect.Right  >= aPos.x) and
              (aRect.Top  <= aPos.Y) and (aRect.Bottom >= aPos.y);
  end;

{TrayIconWinProcList�ɓo�^}
procedure AddTrayIconWinProcList(aClass	:TTaskTrayIcon);
  begin
    if TrayIconWinProcList = nil then begin
      TrayIconWinProcList := TTrayIconWinProcList.Create;
    end;
    TrayIconWinProcList.AddClass(aClass);
  end;
{TrayIconWinProcList����폜}
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
{* 	�J�X�^���c�[���`�b�v�N���X					*}
{************************************************************************}
constructor TCustomToolTipStyle.Create;
  begin
    inherited Create;
    {�N���G�C�g}
    FHintFont		:= TFont.Create;
    {������}
    FOwnerHWnd		:= 0;
    FHTooltip		:= GetTooltipHandle;
    FRequestSglDbl	:= True;
    FUseDefault 	:= True;
    {FExitMouse		:= True;}
    FThread		:= nil;
    FMouseStates	:= [];
    DisableTrayIconRect;
    {�x������
    FDelayTimeAutoPop	:= 5000;
    FDelayTimeInitial	:= 500;
    FDelayTimeReshow	:= 100;}
    {�w�i�F
    FBackGrdColor	:= GetSysColor(COLOR_INFOBK);}
    {�e�L�X�g�F
    FHintFont.Color	:= GetSysColor(COLOR_INFOTEXT);}
    {�ő啝
    FMaxTipWidth	:= 400;}
    {�㉺���E�}�[�W��
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
    {�f�t�H���g�ݒ�ɖ߂�}
    SetDefaultToolTip;
    {�j��}
    FHintFont.Free;
    inherited Destroy;
  end;

{<< �v���p�e�BIO >>}
{�I�[�i�[�̐ݒ�}
procedure TCustomToolTipStyle.SetOwner(aOwnerHWND	:HWND);
  begin
    FOwnerHWnd	:= aOwnerHWND;
  end;

{�w��}�E�X��Ԃł��邩}
function TCustomToolTipStyle.GetMouseState(aTrayIconMouseState: TTrayIconMouseState): Boolean;
  begin
    Result := aTrayIconMouseState in FMouseStates;
  end;

{�ҋ@���̃}�E�X�{�^��}
function TCustomToolTipStyle.GetWaitClickButton: TTrayIconMouseState;
  begin
    if 	    timsLDown in FMouseStates then Result := timsLDown
    else if timsRDown in FMouseStates then Result := timsRDown
    else 				   Result := timsMDown;
  end;

{�x������
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

{�F}
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

{�e�L�X�g�T�C�Y
function TCustomToolTipStyle.GetTextSize: Integer;
  begin
    Result := FHintFont.Size;
  end;
procedure TCustomToolTipStyle.SetTextSize(aValue: Integer);
  begin
    FHintFont.Size := aValue;
  end;}

{�t�H���g
function TCustomToolTipStyle.GetFont: TFont;
  begin
    Result := FHintFont;
  end;
procedure TCustomToolTipStyle.SetFont(aFont: TFont);
  begin
    FHintFont.Assign(aFont);
  end;}

{TipWindow�ő啝
function TCustomToolTipStyle.GetMaxTipWidth: Integer;
  begin
    Result := FMaxTipWidth;
  end;
procedure TCustomToolTipStyle.SetMaxTipWidth(aValue: Integer);
  begin
    if aValue < -1 then aValue := -1;
    FMaxTipWidth := aValue;
  end;}

{�㉺���E�}�[�W��
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

{���b�Z�[�W����}
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
  
{�c�[���`�b�v�̃n���h���𓾂�}
{���v���������ׂẴA�C�R���͓����c�[���`�b�v�����L���Ă���炵��}
function TCustomToolTipStyle.GetTooltipHandle: HWND;
  var
    toolTopWnd,
    hTaskBar		:HWND;
    pidTaskBar,
    pidToolTopWnd	:DWORD;
  begin
    {TaskBar Handle �̎擾}
    hTaskBar := FindWindowEx(0, 0, 'Shell_TrayWnd', nil);
    {TaskBar �� Process ID ���擾����}
    GetWindowThreadProcessId(hTaskBar, @pidTaskBar);
    {Tooltip Window �̌���}
    toolTopWnd := FindWindowEx(0, 0, TOOLTIPS_CLASS, nil);

    while toolTopWnd <> 0 do begin
      {Tooltip �� Process ID ���擾}
      GetWindowThreadProcessId(toolTopWnd, @pidToolTopWnd);
      {�^�X�N�o�[�ƃc�[���`�b�v�� Process ID ���r���āA��v���Ă�����^�X�N�o�[�̃c�[���`�b�v�Ƃ���}
      if pidTaskBar = pidToolTopWnd then begin
	{�c�[���`�b�v�̃E�C���h�E�X�^�C���𒲍�����}
	if (GetWindowLong(toolTopWnd, GWL_STYLE) and TTS_NOPREFIX) = 0 then begin
	  Break;
	end;
      end;
      {�ēx Tooltip Window �̌���}
      toolTopWnd := FindWindowEx(0, toolTopWnd, TOOLTIPS_CLASS, nil);
    end;
    {����}
    Result := toolTopWnd;
  end;

{�}�E�X�C�x���g}
procedure TCustomToolTipStyle.OnMouseEnter;
  var
    cursorPos	:TPoint;
  begin
    {�}�E�X�J�[�\���̈ʒu���擾}
    GetCursorPos(cursorPos);
    {�͈͍X�V}
    UpdateRect(FIconRect, cursorPos);
    {2003.05.17...�^�X�N�o�[�̈ʒu���ύX�ɂȂ����Ƃ��p}
    if (Abs(FIconRect.Right - FIconRect.Left) > TASKTRAY_ICONSIZE) or
       (Abs(FIconRect.Bottom - FIconRect.Top) > TASKTRAY_ICONSIZE) then begin
      {�A�C�R���̈悪�A�C�R���T�C�Y�𒴂��Ă��܂����Ƃ��A�^�X�N�o�[���ړ������肵�����ȁH}
      {�̈斳��}
      DisableTrayIconRect;
      {�ēx�͈͍X�V}
      UpdateRect(FIconRect, cursorPos);
    end;
    {�}�E�XIN�C�x���g}
    if not MouseEnter then DoMouseEnter;
  end;

procedure TCustomToolTipStyle.OnMouseExit;
  var
    cursorPos	:TPoint;
  begin
    if MouseEnter then begin
      {�}�E�X�J�[�\���̈ʒu���擾}
      GetCursorPos(cursorPos);
      {�A�C�R���̈���ɂ��邩����}
      if not IsInnerRect(FIconRect, cursorPos) then DoMouseExit;
    end;
  end;

const
  TIMER_ID	= 7;

{�}�E�X�N���b�N����}
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

{�^�X�N�g���C�A�C�R���̃��b�Z�[�W����}
procedure TCustomToolTipStyle.TrayIconWndProc(var Message: TMessage);
  begin
    if Message.Msg = WM_TaskTrayMessage then begin
      case Message.lParam of
        {�}�E�X�C������}
        WM_MOUSEMOVE	:OnMouseEnter;
        {�N���b�N�ҋ@}
        WM_LBUTTONDOWN	:if Message.WParam >= 0 then Include(FMouseStates, timsLDown);
        WM_RBUTTONDOWN	:if Message.WParam >= 0 then Include(FMouseStates, timsRDown);
        WM_MBUTTONDOWN	:if Message.WParam >= 0 then Include(FMouseStates, timsMDown);
        {�N���b�N����}
        WM_LBUTTONUP	:OnMouseClick(timsLDown);
        WM_RBUTTONUP	:OnMouseClick(timsRDown);
        WM_MBUTTONUP	:OnMouseClick(timsMDown);
        {�_�u���N���b�N����}
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

{�g���C�A�C�R���͈͂𖳌�������}
procedure TCustomToolTipStyle.DisableTrayIconRect;
  begin
    DisableRect(FIconRect);
  end;

{�f�[�^�̕���}
procedure TCustomToolTipStyle.Assign(aSource: TPersistent);
  begin
    inherited Assign(aSource);
    if aSource is TCustomToolTipStyle then begin
      FUseDefault	:= TCustomToolTipStyle(aSource).FUseDefault;	{True:�f�t�H���g�̃q���g�\�����s��}
      FBackGrdColor	:= TCustomToolTipStyle(aSource).FBackGrdColor;
    end;
  end;

procedure TCustomToolTipStyle.DoMouseEnter;
  begin
    {�t���O�I��}
    Include(FMouseStates, timsEnter);
    {�c�[���`�b�v�w���v�ύX}
    if not FUseDefault then SetCustomToolTip;
    {�N���G�C�g}
    if FThread = nil then FThread := TMouseEventMaker.Create(Self);
    {�X���b�h�J�n}
    if FThread.Suspended then FThread.Resume;
    {�I�[�i�[�ɒʒm}
    if FOwnerHWnd <> 0 then
      SendMessage(FOwnerHWnd, WM_TaskTrayMessage, 0, WM_MOUSE_ENTER);
  end;

procedure TCustomToolTipStyle.DoMouseExit;
  begin
    {�t���O�I�t}
    Exclude(FMouseStates, timsEnter);
    {�c�[���`�b�v�w���v��߂�}
    if not FUseDefault then SetDefaultToolTip;
    {�^�X�N�g���C�A�C�R���͈͉��
    DisableTrayIconRect;}
    {�I�[�i�[�ɒʒm}
    if FOwnerHWnd <> 0 then
      SendMessage(FOwnerHWnd, WM_TaskTrayMessage, 0, WM_MOUSE_EXIT);
  end;

{�}�E�X�N���b�N}
procedure TCustomToolTipStyle.DoMouseClick(aMouseButton: TTrayIconMouseState);
  begin
    if (aMouseButton in FMouseStates) and (FOwnerHWnd <> 0) then begin
      SendMessage(FOwnerHWnd, WM_TaskTrayMessage, Ord(aMouseButton), WM_MOUSE_CLICK);
    end;
    {�t���O�I�t}
    FWaitClick := False;
    Exclude(FMouseStates, aMouseButton);
  end;

{�}�E�X�_�u���N���b�N}
procedure TCustomToolTipStyle.DoMouseDblClick(aMouseButton: TTrayIconMouseState);
  begin
    {�t���O�I�t}
    FWaitClick := False;
    Exclude(FMouseStates, aMouseButton);
    {�}�E�X�_�E���x���g���s}
    case aMouseButton of
      timsLDown:
        PostMessage(FOwnerHWnd, WM_TaskTrayMessage, -1, WM_LBUTTONDOWN);
      timsRDown:
        PostMessage(FOwnerHWnd, WM_TaskTrayMessage, -1, WM_RBUTTONDOWN);
      timsMDown:
        PostMessage(FOwnerHWnd, WM_TaskTrayMessage, -1, WM_MBUTTONDOWN);
    end;
  end;

{�c�[���`�b�v�ύX}
procedure TCustomToolTipStyle.SetCustomToolTip;
  begin
    if FHTooltip = 0 then Exit;
    {�t�H���g�ݒ�
    SendMessage(FHTooltip, WM_SETFONT, FHintFont.Handle, 1);}
    {�x������
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_AUTOPOP, FDelayTimeAutoPop);
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_INITIAL, FDelayTimeInitial);
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_RESHOW , FDelayTimeReshow);}
    {�w�i�F}
    SendMessage(FHTooltip, TTM_SETTIPBKCOLOR, FBackGrdColor, 0);
    {�e�L�X�g�F}
    SendMessage(FHTooltip, TTM_SETTIPTEXTCOLOR, FHintFont.Color, 0);
    {�ő啝
    SendMessage(FHTooltip, TTM_SETMAXTIPWIDTH, 0, FMaxTipWidth);}
    {�㉺���E�}�[�W��  
    SendMessage(FHTooltip, TTM_SETMARGIN, 0, LParam(@(FMargin)));}
  end;

procedure TCustomToolTipStyle.SetDefaultToolTip;
  begin
    if FHTooltip = 0 then Exit;
    {��������}
    SendMessage(FHTooltip, TTM_POP, 0, 0);
    {<< �f�t�H���g�ݒ�ɖ߂� >>}
    {�t�H���g�̐ݒ�
    SendMessage(FHTooltip, WM_SETFONT, 0, 1);}
    {�x������
    SendMessage(FHTooltip, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 0);}
    {�w�i�F}
    SendMessage(FHTooltip, TTM_SETTIPBKCOLOR, GetSysColor(COLOR_INFOBK), 0);
    {�e�L�X�g�F}
    SendMessage(FHTooltip, TTM_SETTIPTEXTCOLOR, GetSysColor(COLOR_INFOTEXT), 0);
    {�ő啝
    SendMessage(FHTooltip, TTM_SETMAXTIPWIDTH, 0, -1);}
    {�㉺���E�}�[�W��
    FillChar(tipRect, SizeOf(TRect), #$0);
    SendMessage(FHTooltip, TTM_SETMARGIN, 0, LParam(@(tipRect)));}
  end;
{$ENDIF}

{************************************************************************}
{* 	�e���`							*}
{************************************************************************}
type
  {ENotifyIconError��O�̒�`}
  ENotifyIconError = class(Exception);

{************************************************************************}
{* 	�^�X�N�g���C�A�C�R���\���p�N���X				*}
{************************************************************************}
constructor TTaskTrayIcon.Create;
  begin
    inherited Create;
    {�o�^}
    AddTrayIconWinProcList(Self);
    {�N���G�C�g}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    FToolTipStyle := TToolTipStyle.Create;
    {$ENDIF}
    {Shell32.dll�̃o�[�W�����`�F�b�N
    FShellNew := GetShellDllVersion >= MakeLong(0, 5);}
    FShell32Ver := GetShellDllVersion;

    {�\���̏�����}
    FillChar(FIconData, SizeOf(TNewNotifyIconData), #0);
    {�v���p�e�B��������}
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
    {�j��}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    if FToolTipStyle <> nil then FToolTipStyle.Free;
    {$ENDIF}
    {�g���C����A�C�R���폜}
    DeleteTrayIcon;
    if FTrayHandle <> 0 then DestroyWindow(FTrayHandle);
    {����}
    DelTrayIconWinProcList(Self);
    inherited Destroy;
  end;

{�v���p�e�B����}
procedure TTaskTrayIcon.Assign(aDest	:TTaskTrayIcon);

  begin
    FIconData := aDest.FIconData;
    ModifyIcon;
  end;

{�^�X�N�g���C�pWindowProcedure}
procedure TTaskTrayIcon.TrayWndProc(var Message: TMessage);
  begin
    if (Message.Msg = TrayIconWinProcList.uTaskbarRestart) then begin
      {�^�X�N�g���C�A�C�R���ւ̍ĕ\��}
      if IconRegisted then begin
        if OnTaskTray then begin
          {��x���o�^��ԂɍX�V���A�ēo�^�������s��}
	  IconRegisted := False;
	  SetTrayIcon;
        end
        else begin
          {���o�^��ԂɍX�V����}
          IconRegisted := False;
        end;
      end;
      {�^�X�N�o�[�ċN�����b�Z�[�W�̔��s}
      Message.Msg := WM_TASKBER_RESTART;
      FOnMessage(Message);
      Message.Msg := TrayIconWinProcList.uTaskbarRestart;
    end;
    {�c�[���`�b�v�ύX�N���X�ւ̒ʒm}
    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
    FToolTipStyle.TrayIconWndProc(Message);
    {$ENDIF}
    {�W������}
    if Assigned(FOnMessage) then begin
      FOnMessage(Message);
    end
    else begin
      with Message do
	Result := DefWindowProc(TrayHandle, Msg, WParam, LParam);
    end;
  end;

{�^�X�N�g���C�o�^�p�n���h���̎擾}
function TTaskTrayIcon.GetTrayHandle:HWnd;
  begin
    if FTrayHandle = 0 then begin
      {�E�C���h�E�쐬}
      FTrayHandle := CreateWindowEx(WS_EX_TOOLWINDOW, TRAY_ICON_WINDOW_CLASS_NAME,
				    '', WS_POPUP, 0, 0, 0, 0, 0, 0, hInstance, nil);
      {�c�[���`�b�v�N���X�̍쐬}
      {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
      FToolTipStyle.SetOwner(FTrayHandle);
      {$ENDIF}
    end;
    Result := FTrayHandle;
  end;

{�}�E�X���A�C�R�����ɓ��������̏���}
procedure TTaskTrayIcon.DoMouseEnter;
  begin
    {Mouse Enter Event}
    if FTrayHandle <> 0 then begin
      SendMessage(FTrayHandle, WM_TaskTrayMessage, 0, WM_MOUSE_ENTER);
    end;
  end;

{�}�E�X���A�C�R���O�ɏo�����̏���}
procedure TTaskTrayIcon.DoMouseExit;
  begin
    {Mouse Exit Event}
    if FTrayHandle <> 0 then begin
      SendMessage(FTrayHandle, WM_TaskTrayMessage, 0, WM_MOUSE_EXIT);
    end;
  end;

{�^�X�N�g���C�ɃA�C�R�����o�^����Ă��邩}
function TTaskTrayIcon.GetIconRegisted: Boolean;
  begin
    Result := otifRegisted in FOnTrayIconFlag;
  end;
procedure TTaskTrayIcon.SetIconRegisted(aValue: Boolean);
  begin
    {�����I�ȃt���O�̏����݂̂̂��ߌ��݂̒l�Ƃ̔�r���Ȃ�}
    //if GetIconRegisted <> aValue then begin
    if aValue then begin
      Include(FOnTrayIconFlag, otifRegisted);	{�o�^}
      Include(FOnTrayIconFlag, otifShowing);	{�\��}
    end
    else begin
      Exclude(FOnTrayIconFlag, otifRegisted);	{���o�^}
      Exclude(FOnTrayIconFlag, otifShowing);	{��\��}
    end;
  end;
{�^�X�N�g���C�ɃA�C�R�����\������Ă��邩}
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

{�g���C�ɓo�^����A�C�R���̃n���h���𓾂�}
function TTaskTrayIcon.GetIconHandle:HICON;
  begin
    Result := FIconData.hIcon;
  end;
procedure TTaskTrayIcon.SetIconHandle(aIconHandle	:HICON);
  begin
    FIconData.hIcon := aIconHandle;
  end;

{�g���C�ŕ\������e�L�X�g}
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
      {���s�������܂ޏꍇ�X�y�[�X�Œu������}
      if not GetShellNewVersion then
        StringReplace(aTipHelp, #$D#$A, ' ', [rfReplaceAll]);
      {�`�b�v�w���v�̍X�V}
      if ShellNewVersion then StrPLCopy(@FIconData.szTip, PChar(aTipHelp), 127)
      else                    StrPLCopy(@FIconData.szTip, PChar(aTipHelp),  63);
    end;
  end;

{Shell32.dll�̃o�[�W������ 5.0�ȍ~}
function TTaskTrayIcon.GetShellNewVersion: Boolean;
  begin
    Result := FShell32Ver >= MakeLong(0, 5);
  end;

{�o���[���w���v�̃^�C�g��}
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

{�o���[���w���v�̃e�L�X�g}
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

{�g���C�ŕ\������̃^�C���A�E�g}
function TTaskTrayIcon.GetUTimeOut:Integer;
  begin
    Result := FIconData.uTimeout;
  end;

procedure TTaskTrayIcon.SetUTimeOut(aValue	:Integer);
  begin
    FIconData.uTimeout := aValue;
  end;

{�o���[���w���v�ŕ\������A�C�R���̎��}
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

{�������̍X�V�J�n}
procedure TTaskTrayIcon.BeginUpdate;
  begin
    Inc(FUpdateCount);
  end;
{�������̍X�V�I��}
procedure TTaskTrayIcon.EndUpdate;
  begin
    if FUpdateCount > 0 then Dec(FUpdateCount);
  end;
{�������̍X�V����}
procedure TTaskTrayIcon.FinishUpdate;
  begin
    FUpdateCount := 0;
  end;

{�X�V������}
function TTaskTrayIcon.Updating: Boolean;	{True:�X�V��}
  begin
    Result := FUpdateCount > 0;
  end;

{�g���C�ɃA�C�R���o�^}
function TTaskTrayIcon.SetTrayIcon:Boolean;
  {�o�^�G���[���̃��g���C}
  procedure retrySet(var aRetryCount	:Integer);
    begin
      if GetLastError = ERROR_TIMEOUT then begin
        {2�b�ҋ@}
	Sleep(2000);
	IconRegisted := True;
	if Shell_NotifyIcon(NIM_MODIFY, @FIconData) then begin
        {�ŏ��̓o�^�ɐ������Ă������̂Ƃ���}
	  IconRegisted := True;
	  {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
	  {�^�X�N�g���C�̃A�C�R���͈͂𖳌�������}
	  ToolTipStyle.DisableTrayIconRect;
	  {$ENDIF}
	end
        else begin
	{�ēx�`�������W}
	  IconRegisted := False;
          if FrontToWindow then SetForegroundWindow(FTrayHandle);
	  if Shell_NotifyIcon(NIM_ADD, @FIconData) then begin
	    IconRegisted := True;
	    {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
	    {�^�X�N�g���C�̃A�C�R���͈͂𖳌�������}
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
      {TimeOut�ȊO�̃G���[}
        raise ENotifyIconError.Create(NotifyIconErrMessage);
      end;
    end;
  (*...
  {�V�o�[�W����}
  procedure setNewVersionMessage;
    var
      msgInfo	:TNewNotifyIconData;
    begin
      {FillChar(msgInfo, SizeOf(TNewNotifyIconData), #1);}
      msgInfo.uTimeout := NOTIFYICON_VERSION;
      if Shell_NotifyIcon(NIM_SETVERSION, @msgInfo) then begin
        {Windows XP �ȍ~�̂݁H}
        MessageBox(TrayHandle, 'xxx', 'OK', 0);
      end;
    end;
  ...*)
  var
    retryCount	:Integer;
  begin
    if not OnTaskTray then begin
    {�A�C�R�����o�^ or ��\��}
      with FIconData do begin
	if ShellNewVersion then begin
	{Shell32.dll �̃o�[�W������ 5 �ȍ~}
	  cbSize := SizeOf(TNewNotifyIconData);
	  dwState := NIS_SHAREDICON;
	  dwStateMask := 0;
	  dwInfoFlags := 0;
	end
	else begin
	{Shell32.dll �̃o�[�W������ 5 �ȑO}
	  cbSize := SizeOf(TNotifyIconData);
	end;
	uID := 1;
	Wnd := TrayHandle;
	uCallbackMessage := WM_TaskTrayMessage;
        uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
      {�V�o�[�W�����p�ɐݒ�
      if ShellNewVersion then setNewVersionMessage;}
      {�g���C�ɃA�C�R���o�^}
      Result := FIconData.hIcon > 0;
      if Result then begin
        if FrontToWindow then SetForegroundWindow(FTrayHandle);
        if IconRegisted then begin
        {�A�C�R���͓o�^�ς�}
        {�^�X�N�g���C�̃A�C�R���̔�\������}
	  FIconData.dwState := 0;
	  FIconData.uFlags := FIconData.uFlags or NIF_STATE;
	  FIconData.dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
	  if Shell_NotifyIcon(NIM_MODIFY, @FIconData) then begin
            OnTaskTray := True;
          end;
        end
        else begin
        {�^�X�N�g���C�ւ̓o�^}
          if Shell_NotifyIcon(NIM_ADD, @FIconData) then begin
            IconRegisted := True;
	    OnTaskTray := True;
            {$IFNDEF NO_USE_CUSTOM_TOOLTIP}
            {�^�X�N�g���C�̃A�C�R���͈͂𖳌�������}
            ToolTipStyle.DisableTrayIconRect;
            {$ENDIF}
          end
          else begin
            {���g���C}
            retryCount := 5;
            while (not OnTaskTray) and (retryCount >= 0) do retrySet(retryCount);
          end;
        end;
      end;
    end;
    Result := OnTaskTray;
  end;

{�g���C����A�C�R������}
function TTaskTrayIcon.HideTrayIcon:Boolean;
  begin
    if ShellNewVersion and FEnabledHide then begin
      if IconRegisted and OnTaskTray then begin
	{�A�C�R����\��}
	FIconData.uFlags := NIF_STATE;
	FIconData.dwState := NIS_HIDDEN;
	FIconData.dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
	Result := Shell_NotifyIcon(NIM_MODIFY, @FIconData);
	FIconData.dwState := 0;
	{�t���O�ύX}
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
      {�A�C�R���o�^����}
      Result := Shell_NotifyIcon(NIM_DELETE, @FIconData);
      {�t���O�ύX}
      IconRegisted := False;
    end
    else begin
      Result := True;
    end;
  end;

{�g���C�A�C�R���̕ύX}
function TTaskTrayIcon.ModifyIcon:Boolean;
  begin
    Result := False;
    if Updating then Exit;
    
    if OnTaskTray then begin
      {���łɕ\���ς�}
      if FIconData.hIcon > 0 then begin
      {�A�C�R���n���h�����擾�ł���}
        if FrontToWindow then SetForegroundWindow(FTrayHandle);
	{�\���X�V}
	if IconRegisted and not OnTaskTray then begin
	  FIconData.uFlags := NIF_STATE;
	  FIconData.dwStateMask := NIS_HIDDEN or NIS_SHAREDICON;
	end;
	if not Shell_NotifyIcon(NIM_MODIFY, @FIconData) then begin
          {raise ENotifyIconError.Create(NotifyIconModErrMessage);}
          {�X�V�Ɏ��s�����Ƃ��g���C����A�C�R���������Ă��܂��Ă���ꍇ��z�肵
           �ǉ��������s���B��O�����́ASetTrayIcon ���\�b�h�����Ŕ�������̂�
           �R�����g�����Ă���...2002.09.18}
      	  if GetLastError <> ERROR_TIMEOUT then begin
          {�^�C���A�E�g�̃G���[�ȊO�̓g���C��ɃA�C�R�����Ȃ����̂Ɣ���}
            try
              {�t���O������}
	      IconRegisted := False;
              {�V�K�ɓo�^����}
              SetTrayIcon;
            except
            end;
          end;
        end;
	{���^�[��}
	Result := OnTaskTray;
      end;
    end
    else begin
      {�A�C�R���̐V�K�o�^}
      Result := SetTrayIcon;
    end;
  end;

{�o���[���w���v��\������}
function TTaskTrayIcon.ShowBalloonHelpSE(aHelpTitle,			{�^�C�g��}
                          	         aHelpText	:String;	{���b�Z�[�W}
                          	         aTimeOut	:Integer;	{�^�C���A�E�g(�~���b)}
                                         aIconType	:TBalloonIconType)
                                       			:Boolean;	{True:����}
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

function TTaskTrayIcon.ShowBalloonHelp: Boolean;	{True:����}
  begin
    if ShellNewVersion and OnTaskTray then begin
      {�t���O�ύX}
      FIconData.uFlags := NIF_INFO;
      try
        {�\��}
        {HideBalloonHelp;}
        Result := ModifyIcon;
      finally
        {�t���O����}
        FIconData.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
    end
    else begin
      Result := False;
    end;
  end;

{�o���[���w���v�����}
function TTaskTrayIcon.HideBalloonHelp: Boolean;	{True:����}
  var
    tempInfo	:String;
  begin
    if ShellNewVersion and OnTaskTray then begin
      {�t���O�ύX}
      FIconData.uFlags := NIF_INFO;
      try
	tempInfo := GetBalloonHelp;
	SetBalloonHelp('');
	{�\���X�V}
	Result := ModifyIcon;
	{�e�L�X�g����}
	SetBalloonHelp(tempInfo);
      finally
	{�t���O����}
	FIconData.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
    end
    else begin
      Result := False;
    end;
  end;

{�A�C�R�����ɃJ�[�\�������邩}
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
{*	TaskTrayIconClass�pMessageHandler				*}
{************************************************************************}
{�N���G�C�g}
constructor TTrayIconWinProcList.Create;
  begin
    inherited Create;
    {Window�N���X�̓o�^}
    RegisterClass;
    {�G�N�X�v���[���̍ċN���Ń^�X�N�g���C�̃A�C�R�����ĕ\�����邽�߂̂���
     �g�b�v���x���̃E�C���h�E�Ƀu���[�h�L���X�g�����B
     IE4.0�ȍ~�Ȃ�ʒm�����̂��낤���H WinNT IE3.02 Opera6.03 ����
     uTaskbarRestart <> 0 �ɂȂ�܂�}
    uTaskbarRestart := RegisterWindowMessage('TaskbarCreated');
  end;

{�j��}
destructor TTrayIconWinProcList.Destroy;
  begin
    {Window�N���X�̉���}
    UnRegisterClass;
    inherited Destroy;
  end;

{�N���X��Windows�ɓo�^����}
procedure TTrayIconWinProcList.RegisterClass;
  var
    wndClass	:TWndClass;
  begin
    {�E�C���h�E�N���X�o�^}
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
    {�o�^}
    Windows.RegisterClass(wndClass);
  end;

{�N���X��Windows����폜����}
procedure TTrayIconWinProcList.UnRegisterClass;
  begin
    {�N���X�o�^�̉���}
    Windows.UnRegisterClass(TRAY_ICON_WINDOW_CLASS_NAME, hInstance);
  end;

{���b�Z�[�W����}
function TTrayIconWinProcList.MessageDeliver(aHWND		:HWND;
                                             var Message	:TMessage)
                          					:Boolean;	{True:��������}
  var
    idx	:Integer;
  begin
    for idx := 0 to Count - 1 do begin
      if (TObject(Items[idx]) is TTaskTrayIcon) and
         (TTaskTrayIcon(Items[idx]).FTrayHandle = aHWND) then begin
        {���b�Z�[�W���M}
        TTaskTrayIcon(Items[idx]).TrayWndProc(Message);
        {����}
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

{�N���X��ǉ�����}
procedure TTrayIconWinProcList.AddClass(aTaskTrayIcon	:TTaskTrayIcon);
  begin
    {�o�^}
    TrayIconWinProcList.Add(aTaskTrayIcon);
  end;

{�N���X���폜����}
procedure TTrayIconWinProcList.DeleteClass(aTaskTrayIcon	:TTaskTrayIcon);
  var
    dataIdx	:Integer;
  begin
    {�o�^�ς݂̃C���X�^���X�̃C���f�b�N�X�𓾂�}
    dataIdx := IndexOf(aTaskTrayIcon);
    {������Ȃ��Ƃ��̓X�L�b�v}
    if dataIdx < -1 then Exit;
    {�C���f�b�N�X�Ń��X�g����폜����}
    Delete(dataIdx);
  end;

{************************************************************************}
{* 	�֐���`							*}
{************************************************************************}
{�t�@�C���̃v���p�e�B����o�[�W�����𓾂�}
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
    
    {�V�X�e���t�H���_�𓾂�}
    GetMem(infoPointer, MAX_PATH);
    GetSystemDirectory(infoPointer, MAX_PATH);
    filenmae := PChar(infoPointer) + '\' + shell32;
    FreeMem(infoPointer);
    infoPointer := nil;

    {�o�[�W�������T�C�Y�𓾂�}
    fileVarsionInfoSize := GetFileVersionInfoSize(PChar(filenmae), dummy);

    if fileVarsionInfoSize > 0 then begin
      {�o�[�W�������p�������m��}
      GetMem(pFileVarsionInfo, fileVarsionInfoSize);

      try
        {�o�[�W������񃊃\�[�X�擾}
        GetFileVersionInfo(PChar(filenmae), 0, fileVarsionInfoSize, pFileVarsionInfo);

        {�ϊ��e�[�u���ւ̃|�C���^�擾}
        VerQueryValue(pFileVarsionInfo, coTRANSLATION, translation, versionInfoSize);

        {�o�[�W������N�G�X�g�����������������}
        varValue := coSTR_FILE_INFO +
                    IntToHex(LoWord(LongInt(translation^)), 4) +
                    IntToHex(HiWord(LongInt(translation^)), 4) + '\\';

        {�t�@�C���o�[�W����}
        if VerQueryValue(pFileVarsionInfo, PChar(varValue + 'FileVersion'),
                         infoPointer, versionInfoSize) then begin
          varValue := String(PChar(infoPointer));
          try
            {�o�[�W������9.xx�܂ł͑��v�i�΁j}
            major := StrToInt(varValue[1]);
            minor := StrToInt(Copy(varValue, 3, 2));
            Result := MakeLong(minor, major);
          except
            {�O�̂���}
          end;
        end;
      finally
        FreeMem(pFileVarsionInfo, fileVarsionInfoSize);
      end;{try...}

    end;
  end;

{Shell32.dll�̃o�[�W�����𓾂�}
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
    hinstDll := SafeLoadLibrary(Shell32);	{2002.09.03�ύX}

    if hinstDll < 32 then begin
      {�G���[}
    end
    else begin
      try
	{�o�[�W������Ԃ��֐��̃��[�h}
	@dllGetVerProc := GetProcAddress(hinstDll, 'DllGetVersion');

	if Assigned(dllGetVerProc) then begin
	{�o�[�W����5�ȍ~�Ȃ瑶�݂���}
	  {������}
	  FillChar(dllVersionInfo, SizeOf(TDllVersionInfo), #0);
	  dllVersionInfo.cbSize := SizeOf(TDllVersionInfo);
	  {�o�[�W�����擾}
	  hHRESULT := dllGetVerProc(dllVersionInfo);
	  if SUCCEEDED(hHRESULT) then begin
	    {Result := MakeLong(dllVersionInfo.dwMajorVersion,
			       dllVersionInfo.dwMinorVersion);}
	    Result := MakeLong(dllVersionInfo.dwMinorVersion,
			       dllVersionInfo.dwMajorVersion);
	  end;
	end
        else begin
        {�t�@�C���̃v���p�e�B����o�[�W�����𓾂�}
          Result := GetFileVersion;
        end;
      finally
	{���}
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
