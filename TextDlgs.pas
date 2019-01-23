(*★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・* : ☆. ` ・ ★"
  . `  +・ *  ☆★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・*
   : ☆. ★                                                ` ・* : ☆
    ` ・          Delphi Visual Component Library        ☆. ` ・ ★"
  + `  +・            拡張 テキストダイアログ              : ☆. ` ・
  ☆ . :*     　 TTextOpen/SaveDialog Version 2.00　         ★" .
  . ★" .                                                  . :* ★  '
   ` ・* :   Copyright (c) 1998-2001 pantograph(fumika)     ☆ . :*
   .   `  +            All Rights Reserved.              ・ `  +・ *
  .  + :*                                                   .  ★ + .
  ★ﾐ  ・*           mailto:pantograph@nifty.com          . ` ・ ★"
   ` ・* :       http://homepage1.nifty.com/cosmic/       ・ ★" . `.
  . :*   `                                                  ☆ . :* ★
  `  +・ *  ☆ . :*   +・ *.  ☆ . :* ★ ` ・* : ☆. ` ・ ★" .
 ` ☆. ` ・ ★" .   `  +・ *   . :*   +  .  .  * ☆ﾐ      + .    :   *)
unit TextDlgs;

{$DEFINE D4LATER}

{$IFDEF VER90}
  //This Source is for Delphi 3 Later;
{$ENDIF}
{$IFDEF VER93}
  //This Source is for C++Builder 3 Later;
{$ENDIF}
{$IFDEF VER100}
  {$UNDEF D4LATER}
{$ENDIF}
{$IFDEF VER110}
  {$UNDEF D4LATER}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, CommDlg, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TExtChangeOpenDialog = class(TOpenDialog)
  private
    FAutoExtChange: Boolean;
    FParentHandle: HWND;
    FShowPlacesBar: Boolean;
  protected
    procedure DoShow; override;
    procedure DoTypeChange; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    function Execute: Boolean; override;
    property AutoExtChange: Boolean read FAutoExtChange write FAutoExtChange
      default True;
    property ShowPlacesBar: Boolean read FShowPlacesBar write FShowPlacesBar;
  end;

  TExtChangeSaveDialog = class(TExtChangeOpenDialog)
  public
//    constructor Create(AOwner: TComponent); override;
    function Execute: Boolean; override;
  end;

  TEnhOpenDialog = class(TExtChangeOpenDialog)
  private
    Pnl: TPanel;
  protected
    function GetPnl: TPanel;   //継承したダイアログでPnlにアクセスするときのため
    function TaskModalDialog(DialogFunc: Pointer;
                             var DialogData): Bool; override;
    procedure DoClose; override;
    procedure DoShow; override;
  public
    function Execute: Boolean; override;
  end;

  TCustomMemoClass = class of TCustomMemo;

  TTextOpenDialog = class(TEnhOpenDialog)
  private
    Chk: TCheckBox;
    FMemo: TCustomMemo;
    FPreview: Boolean;
    FCustomMemoClass: TCustomMemoClass;
    procedure ChkClick(Sender: TObject);
    function GetPreviewChecked: Boolean;
    procedure SetCustomMemoClass(const Value: TCustomMemoClass);
    procedure SetPreview(Value: Boolean);
  protected
    procedure DoClose; override;
    procedure DoShow; override;
    procedure DoSelectionChange; override;
    procedure PreviewFile; dynamic;
    property PreviewChecked: Boolean read GetPreviewChecked;
  public
    constructor Create(AOwner: TComponent); override;
    property CustomMemoClass: TCustomMemoClass read FCustomMemoClass
      write SetCustomMemoClass;
    property Memo: TCustomMemo read FMemo;
  published
    property Preview: Boolean read FPreview write SetPreview;
  end;

  TTextSaveDialog = class(TTextOpenDialog)
    function Execute: Boolean; override;
  end;

  function FileExistsEnh(const FileName: string): Boolean;
  function IsWin2000: Boolean;
  function OpenInterceptor(var DialogData: TOpenFileName): Bool; stdcall;
  function SaveInterceptor(var DialogData: TOpenFileName): Bool; stdcall;

var
  CurInstanceShowPlacesBar: Boolean;
  TextDialogPreviewBuffer: Integer = 1024;

procedure Register;

implementation

{$R TextDlgs.res}

function FileExistsEnh(const FileName: string): Boolean;
begin
  if (Pos('*', FileName) <> 0) or (Pos('?', FileName) <> 0) then
    Result := False
  else
    Result := FileExists(FileName);
end;

function GetFilterExt(Filter: string; FilterIndex: Integer;
  var Ext: string): Boolean;
var
  P1, P2: Integer;

  function IdxCharPos(C: Char; const S: string; Count: Integer): Integer;
  var
    I, J: Integer;
  begin
    Result := 0;
    if Length(S) > 0 then begin
      I := 0;
      for J := 1 to Length(S) do begin
        if S[J] = C then begin
          Inc(I);
          if I = Count then begin
            Result := J;
            Break;
          end;
        end;
      end;
    end
  end;

begin
  P1 := IdxCharPos('|', Filter, FilterIndex * 2 -1);
  if P1 <> 0 then begin
    Ext := Copy(Filter, P1+1, Length(Filter));
    P1 := IdxCharPos('|', Ext, 1);
    P2 := IdxCharPos(';', Ext, 1);
    if P1 <> 0 then Delete(Ext, P1, Length(Ext));
    if P2 <> 0 then Ext := Copy(Ext, 1, P2-1);
    P2 := IdxCharPos('.', Ext, 1);
    if P2 = 0 then Ext := '' else
      Delete(Ext, 1, P2-1);
    Result := True;
  end else begin
    Result := False;
  end;
end;

type
  TOpenFileNameEx = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;

function GetOpenFileNameEx(var OpenFile: TOpenFilenameEx): BOOL; stdcall;
  external 'comdlg32.dll' name 'GetOpenFileNameA';
function GetSaveFileNameEx(var OpenFile: TOpenFilenameEx): BOOL; stdcall;
  external 'comdlg32.dll' name 'GetSaveFileNameA';

function OpenInterceptor(var DialogData: TOpenFileName): Bool; stdcall;
var
  DialogDataEx: TOpenFileNameEx;
begin
   Move(DialogData, DialogDataEx, SizeOf(DialogDataEx));
   if CurInstanceShowPlacesBar then
     DialogDataEx.FlagsEx := 0
   else
     DialogDataEx.FlagsEx := 1;
   DialogDataEx.lStructSize := SizeOf(TOpenFileNameEx);
   Result := GetOpenFileNameEx(DialogDataEx);
end;

function SaveInterceptor(var DialogData: TOpenFileName): Bool; stdcall;
var
  DialogDataEx: TOpenFileNameEx;
begin
   Move(DialogData, DialogDataEx, SizeOf(DialogDataEx));
   if CurInstanceShowPlacesBar then
     DialogDataEx.FlagsEx := 0
   else
     DialogDataEx.FlagsEx := 1;
   DialogDataEx.lStructSize := SizeOf(TOpenFileNameEx);
   Result := GetSaveFileNameEx(DialogDataEx);
end;

// Windows2000 かどうかを返す
function IsWin2000: Boolean;
var
  OSVI: TOSVersionInfo;
begin
  Result := False;
  OSVI.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if not GetVersionEx(OSVI) then
    Exit;
  if OSVI.dwPlatformId = VER_PLATFORM_WIN32_NT then
    Result := OSVI.dwMajorVersion >= 5;
end;

// WindowsMe かどうかを返す
function IsWinMe: Boolean;
var
  OSVI: TOSVersionInfo;
begin
  Result := False;
  OSVI.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if not GetVersionEx(OSVI) then
    Exit;
  if OSVI.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
    Result := (OSVI.dwMajorVersion = 4) and (OSVI.dwMinorVersion = 90) ;
end;

{ TExtChangeOpenDialog }

constructor TExtChangeOpenDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoExtChange := True;
  FShowPlacesBar := True;
end;

procedure TExtChangeOpenDialog.DoShow;
begin
  FParentHandle := GetParent(Handle);
  inherited DoShow;
end;

const
  DLGITEM_ID9X   = $480;
  DLGITEM_ID2000 = 1148;

// Satobe氏 nifty:FDELPHI/MES/6/19007による
procedure TExtChangeOpenDialog.DoTypeChange;
var
  Ext, FName: string;
  ItemID: Integer;
  S: array [0..255] of Char;
begin
  if IsWin2000 or IsWinMe then
    ItemID := DLGITEM_ID2000
  else
    ItemID := DLGITEM_ID9X;
  if FAutoExtChange and GetFilterExt(Filter, FilterIndex, Ext) then begin
    if GetDlgItemText(FParentHandle, ItemID, S, 256) = 0 then
      FName := '*' + Ext
    else
      FName := ChangeFileExt(S, Ext);
    SetDlgItemText(FParentHandle, ItemID, PChar(FName));
    DefaultExt := Copy(Ext, 2, Length(Ext)-1);
  end;
end;

function TExtChangeOpenDialog.Execute: Boolean;
var
  Ext: string;
begin
  if FAutoExtChange and GetFilterExt(Filter, FilterIndex, Ext) then begin
    DefaultExt := Copy(Ext, 2, Length(Ext)-1);
  end;
  if IsWin2000 or IsWinMe then begin
    CurInstanceShowPlacesBar := FShowPlacesBar;
    Result := DoExecute(@OpenInterceptor);
  end else
    Result := inherited Execute;
end;

{ TExtChangeSaveDialog }

{constructor TExtChangeSaveDialog.Create(AOwner: TComponent);
begin
  inherited;
  FInterceptor := @SaveInterceptor;
end;}

function TExtChangeSaveDialog.Execute: Boolean;
var
  Ext: string;
begin
  if FAutoExtChange and GetFilterExt(Filter, FilterIndex, Ext) then begin
    DefaultExt := Copy(Ext, 2, Length(Ext)-1);
  end;
  if IsWin2000 or IsWinMe then begin
    CurInstanceShowPlacesBar := FShowPlacesBar;
    Result := DoExecute(@SaveInterceptor);
  end else
    Result := DoExecute(@GetSaveFileName);
end;

{ TEnhOpenDialog }

function TEnhOpenDialog.GetPnl: TPanel;
begin
  Result := Pnl;
end;

// by Satobe氏  nifty:FDELPHI/MES/10/04296 による
function TEnhOpenDialog.TaskModalDialog(DialogFunc: Pointer;
  var DialogData): Bool;
begin
  TOpenFilename(DialogData).hInstance := MainInstance;//SysInit.HInstance;
  Result := inherited TaskModalDialog(DialogFunc, DialogData);
end;

procedure TEnhOpenDialog.DoClose;
begin
  Pnl.Free;  Pnl := nil;
  inherited DoClose;
end;

procedure TEnhOpenDialog.DoShow;
var
  PnlRect, StaticRect: TRect;
begin
  GetClientRect(Handle, PnlRect);
  // 95(98) と NT で GetStaticRect の返値が違うので注意
  StaticRect := GetStaticRect;
  PnlRect.Top := (StaticRect.Bottom - StaticRect.Top) - 10;
  Pnl := TPanel.CreateParented(Handle);
  Pnl.Ctl3D := True;
  Pnl.BoundsRect := PnlRect;
  Pnl.BevelOuter := bvNone;
  inherited DoShow;
end;

function TEnhOpenDialog.Execute: Boolean;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'ENHDLG1'
  else
    Template := nil;
  Result := inherited Execute;
end;

{ TDummyMemo for TTextOpenDialog}

type
  TDummyMemo = class(TCustomMemo);

{ TDummyPanel for TTextOpenDialog}

{$IFDEF D4LATER}
type
  TDummyPanel = class(TPanel);
{$ENDIF}

{ TTextOpenDialog }

constructor TTextOpenDialog.Create(AOwner: TComponent);
begin
  inherited;
  CustomMemoClass := TMemo;
end;

procedure TTextOpenDialog.ChkClick(Sender: TObject);
begin
  FPreview := Chk.Checked;
  PreviewFile;
end;

procedure TTextOpenDialog.DoClose;
begin
  if FMemo <> nil then begin
    FMemo.Free;
    FMemo := nil;
  end;
  Chk.Free;
  Chk := nil;
  inherited DoClose;
end;

procedure TTextOpenDialog.DoShow;
var
  PR: TRect;
 {$IFDEF D4LATER}
  Canvas: TCanvas;
 {$ENDIF}
begin
  inherited DoShow;
  Chk := TCheckBox.Create(Self);
  Chk.Parent := GetPnl;
  Chk.SetBounds(5, 2, 200, 25);
  Chk.Checked := FPreview;
  Chk.Caption := '内容をプレビューする(&P)';
  Chk.OnClick := ChkClick;
  Pr := GetPnl.ClientRect;
  if CustomMemoClass <> nil then begin
    FMemo := CustomMemoClass.Create(Self);
    FMemo.Parent := GetPnl;
    FMemo.SetBounds(5, 25, PR.Right  - PR.Left - 10,
                           PR.Bottom - PR.Top  - 30);
   {$IFDEF D4LATER}
    // サイズ可変の場合、リサイズグラブが被ってしまうので
    // その分幅を狭める。
    if ofEnableSizing in Options then begin
      Canvas := TDummyPanel(Pnl).Canvas;
      Canvas.Font.Charset := DEFAULT_CHARSET;
      Canvas.Font.Name := 'Marlett';
      FMemo.Width := FMemo.Width - Canvas.TextWidth('o');
    end;
   {$ENDIF}
    TDummyMemo(FMemo).Font.Name := 'ＭＳ ゴシック';
    TDummyMemo(FMemo).ReadOnly := True;
  end;
end;

procedure TTextOpenDialog.DoSelectionChange;
begin
  inherited DoSelectionChange;
  PreviewFile;
end;

function TTextOpenDialog.GetPreviewChecked: Boolean;
begin
  Result := Chk.Checked;
end;

procedure TTextOpenDialog.PreviewFile;
var
  FS0: TFileStream;
  MS1, MS2: TMemoryStream;
  Ext: string;
  Size: Integer;
  S: string;
begin
  if FMemo <> nil then begin
    FMemo.Clear;
    if PreviewChecked and FileExistsEnh(FileName) then begin
      // Delphi の dfm ファイルをテキストとして読み込むための
      // おまけ機能(^^;)
      Ext := AnsiLowerCaseFileName(ExtractFileExt(FileName));
      if (Ext = '.dfm') or (Ext = '.~df') or (Ext = '.~dfm')then begin
        MS1 := TMemoryStream.Create;
        MS2 := TMemoryStream.Create;
        try
          MS1.LoadFromFile(FileName);
          MS1.Position := 0;
          try
            ObjectResourceToText(MS1, MS2);
          except
            // D5以降の形式の場合、dfm がリソース形式ではなくテキスト形式
            // になったため、エラーが発生する。そのエラーをトラップして
            // テキストファイルとして読み込む
            on EInvalidImage do
              MS2.LoadFromFile(FileName);
          end;
          if MS2.Size > TextDialogPreviewBuffer then
            MS2.SetSize(TextDialogPreviewBuffer);
          MS2.Position := 0;
          FMemo.Lines.LoadFromStream(MS2);
        finally
          MS2.Free;
          MS1.Free;
        end;
      end else begin
        //通常の読み込み
        FS0 := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
        try
          Size := FS0.Size;
          if Size > TextDialogPreviewBuffer then
            Size := TextDialogPreviewBuffer;
          SetString(S, nil, Size);
          FS0.Read(Pointer(S)^, Size);
          FMemo.Lines.Text := S;
        finally
          FS0.Free;
        end;
      end;
    end;
  end;
end;

procedure TTextOpenDialog.SetCustomMemoClass(const Value: TCustomMemoClass);
begin
  if FCustomMemoClass <> Value then begin
    //Edit が生成されていないときのみクラスの置き換え可能とする。
    if Memo = nil then
      FCustomMemoClass := Value;
  end;
end;

procedure TTextOpenDialog.SetPreview(Value: Boolean);
begin
  if FPreview <> Value then begin
    FPreview := Value;
    if Chk <> nil then Chk.Checked := Value;
  end;
end;

{ TTextSaveDialog }

function TTextSaveDialog.Execute: Boolean;
var
  Ext: string;
begin
  if FAutoExtChange and GetFilterExt(Filter, FilterIndex, Ext) then begin
    DefaultExt := Copy(Ext, 2, Length(Ext)-1);
  end;
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'ENHDLG1'
  else
    Template := nil;
  if IsWin2000 or IsWinMe then begin
    CurInstanceShowPlacesBar := ShowPlacesBar;
    Result := DoExecute(@SaveInterceptor);
  end else
    Result := DoExecute(@GetSaveFileName);
end;

procedure Register;
begin
  RegisterComponents('Dialogs', [TExtChangeOpenDialog, TExtChangeSaveDialog,
                                 TTextOpenDialog, TTextSaveDialog]);
end;

end.
