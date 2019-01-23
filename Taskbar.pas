{//////////////////////////////////////////////////////////////////////////////
//	�^�X�N�g���C�A�C�R���\���R���|�[�l���g				     //
//	2000.07.10 H.Okamoto						     //
//	�O��X�V��	2004.02.27	Ver 1.16r2			     //
//		�� �^�X�N�o�[�ċN���C�x���g�ǉ�				     //
//		�� �^�X�N�o�[�ċN���ł̃A�j���[�V�����ĊJ		     //
//	�ŏI�X�V��	2004.12.08	Ver 1.16r3			     //
//		�� ���\�[�X����̃A�C�R���ǂݍ��݂̉��P 		     //
//////////////////////////////////////////////////////////////////////////////}
unit Taskbar;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Menus, ShellApi,
  TrShlApi;

{************************************************************************}
{*	�^�X�N�g���C�A�C�R���\���R���|�[�l���g				*}
{************************************************************************}
type
  {Forword�錾}
  TIconAnimation = class;

  TTrayIcon = class(TComponent)
  private
    FIconAnimation	:TIconAnimation;	{�A�j���[�V�����p�X���b�h}
    {���\�[�X����̃��[�h�p}
    FResIcon		:TIcon;
  protected
    FAutoPopup		:Boolean;	{True:Popup����}
    FIcon		:TIcon;		{���C���A�C�R��}
    FLPopupMenu,
    FRPopupMenu		:TPopupMenu;	{�|�b�v�A�b�v���j���[}
    FTaskTrayIcon	:TTaskTrayIcon;

    {FTipHelp		:String;	{�g���C�`�b�v�q���g}
    FResourceIconID	:Integer;	{�A�C�R�����\�[�X�C���f�b�N�X}
    FResourceIconList	:TStringList;	{�A�C�R�����\�[�X�����X�g}
    FVisible		:Boolean;	{True:�\������}
    FMinimized		:Boolean;	{True:�ŏ������̂�}
    FHideOnTaskBar	:Boolean;	{True:�^�X�N�o�[�ɕ\�����Ȃ�}
    FInterval		:Cardinal;	{�A�C�R���̎����ύX�C�x���g�����^�C��}
    {�t�b�N�C�x���g}
    OnIconChange	:TNotifyEvent;
    OnAppRestore	:TNotifyEvent;
    OnAppMinimize	:TNotifyEvent;
    {�C�x���g}
    FOnDblClick		:TNotifyEvent;
    FOnRDblClick	:TNotifyEvent;
    FOnMouseMove	:TMouseMoveEvent;
    FOnMouseDown,
    FOnMouseUp		:TMouseEvent;
    FOnTimer		:TNotifyEvent;	{�A�C�R���ύX�^�C�}�[�C�x���g}
    {�Ǝ��̃C�x���g}
    FOnMouseEnter,
    FOnMouseExit	:TNotifyEvent;
    FOnMouseClick	:TMouseEvent;
    FOnRestartTaskbar	:TNotifyEvent;	{�^�X�N�o�[�ċN���C�x���g}
  public
    constructor Create(AOwner	:TComponent); override;
    destructor Destroy; override;

  protected
    procedure Loaded; override;
    
    {�R�[���o�b�N�֐�}
    procedure CallbackWndProc(var Message: TMessage);

    {Notification}
    procedure Notification(aComponent	:TComponent;
			   aOperation	:TOperation);
					override;
    {�ŏ����C�x���g}
    procedure OnAppMinimizeEvent(Sender	:TObject);
    {���X�g�A�C�x���g}
    procedure OnAppRestoreEvent(Sender	:TObject);

    {�A�C�R���ύX���C�x���g}
    procedure OnIconChangeEvent(Sender	:TObject);

    {�g���C�ɃA�C�R����\���ł��邩}
    function CanIconic:Boolean;

    {�g���C�ɓo�^����A�C�R���̃n���h���𓾂�}
    function GetIconHandle:HWND;

    {�g���C�ɃA�C�R���o�^}
    function DoSetTrayIcon: Boolean;	{True:����}
    {�g���C����A�C�R������}
    function DoDeleteTrayIcon: Boolean;	{True:����}

  public
    {�^�X�N�g���C�֓o�^����E�C���h�E�n���h���𓾂�}
    function GetTaskTrayHWND: HWND;

    {�g���C�ɃA�C�R���o�^}
    function SetTrayIcon: Boolean;	{True:����}
    {�g���C����A�C�R������}
    function DeleteTrayIcon: Boolean;	{True:����}

    {�g���C�A�C�R���̕ύX}
    function ModifyIcon:Boolean;	{True:����}

    {�o���[���w���v��\������}
    function ShowBalloonHelpSE(aHelpTitle,			{�^�C�g��}
			       aHelpText	:String;	{���b�Z�[�W}
			       aTimeOut		:Integer;	{�^�C���A�E�g(�~���b)}
			       aIconType	:TBalloonIconType)
						:Boolean;	{True:����}

    function ShowBalloonHelp: Boolean;		{True:����}

    {�o���[���w���v�����}
    function HideBalloonHelp: Boolean;	{True:����}

  protected
    {�A�j���[�V��������}
    procedure BeginIconAnimation;
    procedure EndIconAnimation;

    {�A�C�R���ύX�^�C�}�[�C�x���g}
    procedure OnTrayIconChange;

    {�v���p�e�BIO}
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

    {�N���b�N�ƃ_�u���N���b�N�̔�����s����}
    function GetChackClick: Boolean;
    procedure SetChackClick(aValue	:Boolean);

    {Shell32.dll�̃o�[�W�������o���[���w���v��\���ł���}
    function GetCanBalloonHelp:Boolean;
    {�o���[���w���v�̃^�C�g��}
    function GetBlHelpTitle:String;
    procedure SetBlHelpTitle(aHelpTitle	:String);
    {�o���[���w���v�̃e�L�X�g}
    function GetBalloonHelp:String;
    procedure SetBalloonHelp(aHelpText	:String);
    {�g���C�ŕ\������̃^�C���A�E�g}
    function GetUTimeOut:Integer;
    procedure SetUTimeOut(aValue	:Integer);
    {�o���[���w���v�ŕ\������A�C�R���̎��}
    function GetBalloonIconType:TBalloonIconType;
    procedure SetBalloonIconType(aValue	:TBalloonIconType);

    {�c�[���`�b�v�X�^�C���N���X}
    function GetToolTipStyle: TToolTipStyle;
    procedure SetToolTipStyle(aToolTipStyle: TToolTipStyle);

  protected
    property ResIcon: TIcon read GetResIcon;

  public
    {Windows2000 + IE5.0�ȍ~ >>}
    property CanBalloonHelp: Boolean read GetCanBalloonHelp;
    {<< }

  published
    {�v���p�e�B}
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

    {Windows2000 + IE5.0�ȍ~ >>}
    property BalloonHelpTitle: String read GetBlHelpTitle write SetBlHelpTitle;
    property BalloonHelpText: String read GetBalloonHelp write SetBalloonHelp;
    property BalloonHelpTimeOut: Integer read GetUTimeOut write SetUTimeOut default 5000;
    property BalloonHelpIcon: TBalloonIconType read GetBalloonIconType write SetBalloonIconType Default bitNone;
    {<< }

    {�c�[���`�b�v�N���X}
    property ToolTipStyle: TToolTipStyle read GetToolTipStyle write SetToolTipStyle;


    {���j���[�v���p�e�B}
    property LButtonPopupMenu: TPopupMenu read FLPopupMenu write FLPopupMenu;
    property RButtonPopupMenu: TPopupMenu read FRPopupMenu write FRPopupMenu;
    {�C�x���g}
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
{*	�A�j���[�V�����pThread						*}
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
{*	���W�X�g							*}
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
    {�N���G�C�g}
    FIcon := TIcon.Create;
    FIcon.OnChange := OnIconChangeEvent;
    FResourceIconList := TStringList.Create;
    FTaskTrayIcon := TTaskTrayIcon.Create;
    FTaskTrayIcon.OnMessage := CallbackWndProc;
    FIconAnimation := nil;

    if not (csDesigning in ComponentState) then begin
      {��f�U�C����}
      OnAppRestore := Application.OnRestore;
      Application.OnRestore := OnAppRestoreEvent;
      OnAppMinimize := Application.OnMinimize;
      Application.OnMinimize := OnAppMinimizeEvent;
    end;
    {�v���p�e�B�̃f�t�H���g�l�̐ݒ�}
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
    {�f�U�C�����łȂ��Ƃ�}
    if not (csDesigning in ComponentState) then begin
      DoDeleteTrayIcon;
      Application.OnRestore := OnAppRestore;
      OnAppRestore := nil;
      Application.OnMinimize := OnAppMinimize;
      OnAppMinimize := nil;
    end;
    {�A�j���[�V�����X���b�h�̔j��}
    if FIconAnimation <> nil then begin
      FIconAnimation.Terminate;
      if FIconAnimation.Suspended then FIconAnimation.Resume;
      FIconAnimation.Free;
    end;
    {�j��}
    if FResIcon   <> nil then FResIcon.Free;
    FTaskTrayIcon.Free;
    FIcon.Free;
    FResourceIconList.Free;

    inherited Destroy;
  end;

procedure TTrayIcon.Loaded;
  begin
    {�f�U�C�����łȂ��AVisible�v���p�e�B��True�̂Ƃ�}
    if not (csDesigning in ComponentState) and CanIconic then begin
      {�A�C�R���o�^}
      SetTrayIcon;
    end;
    inherited Loaded;
  end;

{�R�[���o�b�N�֐�}
procedure TTrayIcon.CallbackWndProc(var Message: TMessage);
  var
    cursorPos	:TPoint;
  begin
    if Message.Msg = WM_TaskTrayMessage then begin
      {�}�E�X�J�[�\���̌��݈ʒu�擾}
      GetCursorPos(cursorPos);

      {��������}
      case Message.lParam of
	WM_MOUSEMOVE:begin
	{�A�C�R����̒ʉߎ�}
	  if Assigned(FOnMouseMove) then
	    FOnMouseMove(Self, [], cursorPos.X, cursorPos.Y);
	end;
	WM_LBUTTONDOWN:begin
	{���{�^���̃_�E����}
	  {�|�b�v�A�b�v���j���[�����蓖�ĂĂ���AAutoPopup��True}
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
        {���{�^���̃A�b�v��}
          if Assigned(FOnMouseUp) then
            FOnMouseUp(Self, mbLeft, [ssLeft], cursorPos.X, cursorPos.Y);
        end;
        WM_LBUTTONDBLCLK:begin
        {���{�^���̃_�u���N���b�N��}
          if Assigned(FOnDblClick) then FOnDblClick(Self);
        end;
        WM_MBUTTONDOWN:begin
          {���{�^���̃_�E����}
          if Assigned(FOnMouseDown) then
            FOnMouseDown(Self, mbMiddle, [ssMiddle],  cursorPos.X, cursorPos.Y);
        end;
        WM_MBUTTONUP:begin
        {���{�^���̃A�b�v��}
          if Assigned(FOnMouseUp) then
	    FOnMouseUp(Self, mbMiddle, [ssMiddle],  cursorPos.X, cursorPos.Y);
        end;
        WM_RBUTTONDOWN:begin
        {�E�{�^���̃_�E����}
          {�|�b�v�A�b�v���j���[�����蓖�ĂĂ���AAutoPopup��True}
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
        {�E�{�^���̃A�b�v��}
          if Assigned(FOnMouseUp) then
	    FOnMouseUp(Self, mbRight, [ssRight], cursorPos.X, cursorPos.Y);
        end;
        WM_RBUTTONDBLCLK:begin
        {�E�{�^���̃_�u���N���b�N��}
          if Assigned(FOnRDblClick) then FOnRDblClick(Self);
        end;
	NIN_BALLOONSHOW:begin
	{�o���[���w���v��\�������Ƃ��̃��b�Z�[�W}

	end;
	NIN_BALLOONHIDE:begin
	{�o���[���w���v����\���ɂȂ����Ƃ��̃��b�Z�[�W}

	end;
	NIN_BALLOONTIMEOUT: begin
	{�^�C���A�E�g�Ńo���[���w���v����\���ɂȂ�Ƃ��ɔ���}

	end;
	NIN_BALLOONUSERCLICK:begin
	{���[�U�[���N���b�N���ăo���[���w���v����\���ɂȂ�Ƃ��ɔ���}
	  
	end;
	{�ȉ��Ǝ��C�x���g}
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
    {���̑��̃��b�Z�[�W}
      case  Message.Msg of
        WM_QUERYENDSESSION: begin
	  Message.Result := Integer(True);
	end;
	{�ȉ��Ǝ����b�Z�[�W}
	WM_TASKBER_RESTART:begin
	{�^�X�N�o�[�ċN��}
	  if FIconAnimation <> nil then begin
	    {���ؕs�\�������AWin2000SP3�ł̓X���b�h�̍ĊJ�Ɍ������K�v�ɂȂ���(�͂�)
	     �Ȃ̂ŁA�C���X�^���X��j�������߂č쐬����}
	    FIconAnimation.Free;
	    FIconAnimation := nil;
	    if Visible and (FInterval > 0) then begin
	      {�A�j���[�V�����ĊJ}
	      BeginIconAnimation;
	    end;
	  end;
	  {�C�x���g}
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

{�ŏ����C�x���g}
procedure TTrayIcon.OnAppMinimizeEvent(Sender	:TObject);
  begin
    if Assigned(OnAppMinimize) then OnAppMinimize(Sender);
    if FVisible and FMinimized then begin
      {�g���C�A�C�R���o�^}
      SetTrayIcon;
    end;
    if FVisible and FHideOnTaskBar then begin
      ShowWindow(Application.Handle, SW_HIDE);
    end;
  end;

{���X�g�A�C�x���g}
procedure TTrayIcon.OnAppRestoreEvent(Sender	:TObject);
  begin
    if Assigned(OnAppRestore) then OnAppRestore(Sender);
    if FMinimized then begin
      {�g���C�A�C�R������}
      DoDeleteTrayIcon;
      {���C���t�H�[����O�ʂɏo��}
      if Owner is TWinControl then
	SetForegroundWindow(TWinControl(Owner).Handle);
    end;
  end;

{�A�C�R���ύX���C�x���g}
procedure TTrayIcon.OnIconChangeEvent(Sender	:TObject);
  begin
    if not (csDesigning in ComponentState) and
       not (csLoading in ComponentState) then begin
      {�g���C�̃A�C�R���X�V}
      ModifyIcon;
    end;
  end;

{�g���C�ɃA�C�R����\���ł��邩}
function TTrayIcon.CanIconic:Boolean;
  begin
    Result := FVisible;
    if Result then begin
      if FMinimized then
	Result := IsIconic(Application.Handle);
    end;
  end;

{�g���C�ɓo�^����A�C�R���̃n���h���𓾂�}
function TTrayIcon.GetIconHandle:HWND;
  {�A�C�R�������\�[�X����ǂݍ���}
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
      {�A�C�R�����ݒ肳��Ă��Ȃ��Ƃ�}
      if (ResourceIconList.Count > 0) and (FResourceIconID >= 0) then begin
	resourceName := ResourceIconList.Strings[FResourceIconID];
	(*...2002.03.09...Bitmap�͎g���Ȃ��炵���i�΁j
	{Icon�Ń��[�h����}
	Result := LoadIcon(HInstance, Pchar(resourceName));
	if Result = 0 then begin
	{Icon�łȂ����Bitmap�����[�h���Ă݂�...
	  Result := LoadBitmap(HInstance, Pchar(resourceName));
	end;
	...*)
	{...
	loadIconResource(ResourceIconList.Strings[FResourceIconID]);
	...}
	{...2004.12.08...LoadIcon�͉ߋ���Y�IAPI�炵��
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

{�g���C�ɃA�C�R���o�^}
function TTrayIcon.DoSetTrayIcon: Boolean;	{True:����}
  begin
    FTaskTrayIcon.Icon := GetIconHandle;
    Result := FTaskTrayIcon.SetTrayIcon;
    if Result then begin
      {�A�j���[�V�����J�n}
      BeginIconAnimation;
    end;
  end;
{�g���C����A�C�R������}
function TTrayIcon.DoDeleteTrayIcon: Boolean;	{True:����}
  begin
    {�A�j���[�V�����I��}
    EndIconAnimation;
    {����}
    {Result := FTaskTrayIcon.DeleteTrayIcon;}
    Result := FTaskTrayIcon.HideTrayIcon;
  end;

{�^�X�N�g���C�֓o�^����E�C���h�E�n���h���𓾂�}
function TTrayIcon.GetTaskTrayHWND: HWND;
  begin
    Result := FTaskTrayIcon.TrayHandle;
  end;

{�g���C�ɃA�C�R���o�^}
function TTrayIcon.SetTrayIcon:Boolean;
  begin
    Result := DoSetTrayIcon;
    if Result then FVisible := True;
  end;

{�g���C����A�C�R������}
function TTrayIcon.DeleteTrayIcon:Boolean;
  begin
    Result := DoDeleteTrayIcon;
    if Result then FVisible := False;
  end;

{�g���C�A�C�R���̕ύX}
function TTrayIcon.ModifyIcon:Boolean;
  begin
    FTaskTrayIcon.Icon := GetIconHandle;
    if CanIconic then Result := FTaskTrayIcon.ModifyIcon
    else              Result := False;
  end;

{�o���[���w���v��\������}
function TTrayIcon.ShowBalloonHelpSE(aHelpTitle,		{�^�C�g��}
				     aHelpText	:String;	{���b�Z�[�W}
				     aTimeOut	:Integer;	{�^�C���A�E�g(�~���b)}
				     aIconType	:TBalloonIconType)
						:Boolean;	{True:����}
  begin
    Result := FTaskTrayIcon.ShowBalloonHelpSE(aHelpTitle, aHelpText, aTimeOut, aIconType);
  end;
function TTrayIcon.ShowBalloonHelp: Boolean;	{True:����}
  begin
    Result := FTaskTrayIcon.ShowBalloonHelp;
  end;

{�o���[���w���v�����}
function TTrayIcon.HideBalloonHelp: Boolean;	{True:����}
  begin
    Result := FTaskTrayIcon.HideBalloonHelp;
  end;

{�A�j���[�V��������}
procedure TTrayIcon.BeginIconAnimation;
  begin
    if Visible and (FInterval > 0) then begin
      {�A�j���[�V�����J�n}
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

{�A�C�R���ύX�^�C�}�[�C�x���g}
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
      {�g���C�̃A�C�R���X�V}
      ModifyIcon;
    end;
    ...*)
    {�A�C�R���ύX���C�x���g}
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
      {�f�U�C�����łȂ��A�R���|�[�l���g�����[�h���łȂ��ꍇ�A�\���E��\���̐ؑւ�}
      if not (csDesigning in ComponentState) and
         not (csLoading in ComponentState) then begin
        if CanIconic then SetTrayIcon		{��\�����\��}
	else 		  DoDeleteTrayIcon;	{�\��  ����\��}
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
      {���X�g�̃R�s�[}
      FResourceIconList.Assign(aValue);
      if not (csDesigning in ComponentState) and
         not (csLoading in ComponentState) then begin
        {�A�C�R���X�V}
        if CanIconic then ModifyIcon;
      end;
    end
    else begin
      if FResourceIconID < 0 then Exit;
      current := FResourceIconList.Strings[FResourceIconID];
      {���X�g�̃R�s�[}
      FResourceIconList.Assign(aValue);
      {�A�C�R��ID�̍X�V}
      SetIconID(ResourceIconID);
      if FResourceIconList.Strings[ResourceIconID] <> current then begin
        if not (csDesigning in ComponentState) and
           not (csLoading in ComponentState) then begin
          {�A�C�R���X�V}
          if CanIconic then ModifyIcon;
        end;
      end;
    end;
  end;

procedure TTrayIcon.SetInterval(aValue	:Cardinal);
  begin
    if aValue <> FInterval then begin
      {�Ȃ�ƂȂ�50��菬�����͕̂s����}
      if (aValue < 50) and (aValue > 0) then aValue := 50;
      FInterval := aValue;
      {�A�j���[�V�����J�n}
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

{�N���b�N�ƃ_�u���N���b�N�̔�����s����}
function TTrayIcon.GetChackClick: Boolean;
  begin
    Result := FTaskTrayIcon.ToolTipStyle.RequestSglDbl;
  end;
procedure TTrayIcon.SetChackClick(aValue	:Boolean);
  begin
    FTaskTrayIcon.ToolTipStyle.RequestSglDbl := aValue;
  end;

{Shell32.dll�̃o�[�W�������o���[���w���v��\���ł���}
function TTrayIcon.GetCanBalloonHelp:Boolean;
  begin
    Result := FTaskTrayIcon.ShellNewVersion;
  end;

{�o���[���w���v�̃^�C�g��}
function TTrayIcon.GetBlHelpTitle:String;
  begin
    Result := FTaskTrayIcon.GetBalloonHelpTitle;
  end;
procedure TTrayIcon.SetBlHelpTitle(aHelpTitle	:String);
  begin
    FTaskTrayIcon.SetBalloonHelpTitle(aHelpTitle);
  end;

{�o���[���w���v�̃e�L�X�g}
function TTrayIcon.GetBalloonHelp:String;
  begin
    Result := FTaskTrayIcon.GetBalloonHelp;
  end;
procedure TTrayIcon.SetBalloonHelp(aHelpText	:String);
  begin
    FTaskTrayIcon.SetBalloonHelp(aHelpText);
  end;

{�g���C�ŕ\������̃^�C���A�E�g}
function TTrayIcon.GetUTimeOut:Integer;
  begin
    Result := FTaskTrayIcon.GetUTimeOut;
  end;

procedure TTrayIcon.SetUTimeOut(aValue	:Integer);
  begin
    FTaskTrayIcon.SetUTimeOut(aValue);
  end;

{�o���[���w���v�ŕ\������A�C�R���̎��}
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
{*	�A�j���[�V�����pThread						*}
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
        {�A�C�R���ύX}
	Owner.OnTrayIconChange;
        {�ҋ@}
	Sleep(Owner.Interval);
      end;
    end;
  end;

{************************************************************************}
{*	���W�X�g							*}
{************************************************************************}
procedure Register;
  begin
    RegisterComponents('Samples', [TTrayIcon]);
  end;

end.


