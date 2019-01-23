(*★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・* : ☆. ` ・ ★"
  . `  +・ *  ☆★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・*
   : ☆. ★                                                ` ・* : ☆
    ` ・    Delphi / C++Builder Visual Component Library  ☆. ` ・ ★"
  + `  +・         拡張 エディットコンポーネント           : ☆. ` ・
  ☆ . :*        TCuteEdit,TCuteMemo Version 1.20β           ★" .
  . ★" .                                                  . :* ★  '
   ` ・* :      Copyright (c) 1998-2000 ｆｕｍｉｋａ         ☆ . :*
   .   `  +            All Rights Reserved.              ・ `  +・ *
  .  + :*                                                   .  ★ + .
  ★ﾐ  ・*           mailto:YRK00111@nifty.ne.jp          . ` ・ ★"
   ` ・* :       http://homepage1.nifty.com/cosmic/       ・ ★" . `.
  . :*   `                                                  ☆ . :* ★
  `  +・ *  ☆ . :*   +・ *.  ☆ . :* ★ ` ・* : ☆. ` ・ ★" .
 ` ☆. ` ・ ★" .   `  +・ *   . :*   +  .  .  * ☆ﾐ      + .    :   *)
unit CuteEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TCuteEdit = class(TEdit)
  private
    FOnMouseEnter: TMouseMoveEvent;
    FOnMouseExit:  TMouseMoveEvent;
    FBrush: TBrush;
    FTransparent: Boolean;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CNCtlColorEdit(var Msg: TWMCtlColorEdit); message CN_CTLCOLOREDIT;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure SetBrush(const Value: TBrush);
    procedure SetTransparent(const Value: Boolean);
  protected
    procedure BrushChanged(Sender: TObject);
    procedure MouseEnter(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseLeave(Shift: TShiftState; X, Y: Integer); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Brush: TBrush read FBrush write SetBrush;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property OnMouseEnter: TMouseMoveEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TMouseMoveEvent read FOnMouseExit write FOnMouseExit;
  end;

  TCuteMemo = class(TMemo)
  private
    FOnMouseEnter: TMouseMoveEvent;
    FOnMouseExit:  TMouseMoveEvent;
    FBrush: TBrush;
    FTransparent: Boolean;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CNCtlColorEdit(var Msg: TWMCtlColorEdit); message CN_CTLCOLOREDIT;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure SetBrush(const Value: TBrush);
    procedure SetTransparent(const Value: Boolean);
  protected
    procedure BrushChanged(Sender: TObject);
    procedure MouseEnter(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseLeave(Shift: TShiftState; X, Y: Integer); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Brush: TBrush read FBrush write SetBrush;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property OnMouseEnter: TMouseMoveEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TMouseMoveEvent read FOnMouseExit write FOnMouseExit;
  end;

procedure Register;

implementation

function GetShiftState: TShiftState;
var
  KeyState: TKeyboardState;
begin
  GetKeyboardState(KeyState);
  Result := [];
  if KeyState[VK_MENU]    shr 7 = 1 then Include(Result, ssAlt);
  if KeyState[VK_SHIFT]   shr 7 = 1 then Include(Result, ssShift);
  if KeyState[VK_CONTROL] shr 7 = 1 then Include(Result, ssCtrl);
  if KeyState[VK_LBUTTON] shr 7 = 1 then Include(Result, ssLeft);
  if KeyState[VK_RBUTTON] shr 7 = 1 then Include(Result, ssRight);
  if KeyState[VK_MBUTTON] shr 7 = 1 then Include(Result, ssMiddle);
end;

{ TCuteEdit }

constructor TCuteEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBrush := TBrush.Create;
  FBrush.OnChange := BrushChanged;
end;

destructor TCuteEdit.Destroy;
begin
  FBrush.Free;
  inherited Destroy;
end;

procedure TCuteEdit.SetBrush(const Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TCuteEdit.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then begin
    FTransparent := Value;
    if Value then
      Brush.Style := bsClear
    else
      Brush.Style := bsSolid;
    Invalidate;
  end;
end;

procedure TCuteEdit.CMMouseEnter(var Msg: TMessage);
var
  Shift: TShiftState;
  Pos: TPoint;
begin
  inherited;
  Shift := GetShiftState;
  GetCursorPos(Pos);
  Pos := ScreenToClient(Pos);
  MouseEnter(Shift, Pos.X, Pos.Y);
end;

procedure TCuteEdit.CMMouseLeave(var Msg: TMessage);
var
  Shift: TShiftState;
  Pos: TPoint;
begin
  inherited;
  Shift := GetShiftState;
  GetCursorPos(Pos);
  Pos := ScreenToClient(Pos);
  MouseLeave(Shift, Pos.X, Pos.Y);
end;

procedure TCuteEdit.CNCtlColorEdit(var Msg: TWMCtlColorEdit);
begin
  inherited;
  Msg.Result := Brush.Handle;
  SetBkColor(Msg.ChildDC, ColorToRGB(Color));
  SetBkMode(Msg.ChildDC, Windows.TRANSPARENT);
end;

procedure TCuteEdit.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  if Transparent then begin
    Msg.Result := 1;
  end else
    inherited;
end;


procedure TCuteEdit.WMPaint(var Msg: TWMPaint);
var
  R: TRect;
begin
  if Transparent then begin
    SetWindowPos(Handle, 0, 0, 0, 0, 0,
                 SWP_NOZORDER or SWP_NOSIZE or SWP_NOMOVE
                   or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    GetWindowRect(Handle, R);
    InvalidateRect(Parent.Handle, @R, True);
    UpdateWindow(Parent.Handle);
    SetWindowPos(Handle, 0, 0, 0, 0, 0,
                 SWP_NOZORDER or SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE
                   or SWP_SHOWWINDOW or SWP_NOCOPYBITS);
  end;
  inherited;
end;

procedure TCuteEdit.BrushChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCuteEdit.MouseEnter(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self, Shift, X, Y);
end;

procedure TCuteEdit.MouseLeave(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseExit) then FOnMouseExit(Self, Shift, X, Y);
end;

{ TCuteMemo }

constructor TCuteMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBrush := TBrush.Create;
  FBrush.OnChange := BrushChanged;
end;

destructor TCuteMemo.Destroy;
begin
  FBrush.Free;
  inherited Destroy;
end;

procedure TCuteMemo.SetBrush(const Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TCuteMemo.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then begin
    FTransparent := Value;
    Invalidate;
  end;
end;

procedure TCuteMemo.CMMouseEnter(var Msg: TMessage);
var
  Shift: TShiftState;
  Pos: TPoint;
begin
  inherited;
  Shift := GetShiftState;
  GetCursorPos(Pos);
  Pos := ScreenToClient(Pos);
  MouseEnter(Shift, Pos.X, Pos.Y);
end;

procedure TCuteMemo.CMMouseLeave(var Msg: TMessage);
var
  Shift: TShiftState;
  Pos: TPoint;
begin
  inherited;
  Shift := GetShiftState;
  GetCursorPos(Pos);
  Pos := ScreenToClient(Pos);
  MouseLeave(Shift, Pos.X, Pos.Y);
end;

procedure TCuteMemo.CNCtlColorEdit(var Msg: TWMCtlColorEdit);
begin
  inherited;
  Msg.Result := FBrush.Handle;
  SetBkColor(Msg.ChildDC, ColorToRGB(Color));
  SetBkMode(Msg.ChildDC, Windows.TRANSPARENT);
end;

procedure TCuteMemo.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
var
  Canvas: TCanvas;
begin
  Msg.Result := 1;
  Canvas := TCanvas.Create;
  Canvas.Handle := Msg.DC;
  Canvas.Brush.Assign(Brush);
  SetBkColor(Canvas.Handle, ColorToRGB(Color));
  SetBkMode(Canvas.Handle, Windows.TRANSPARENT);
  if not FTransparent then
    Canvas.FillRect(ClientRect);
  Canvas.Handle := 0;
  Canvas.Free;
  //inherited; //しない
end;

procedure TCuteMemo.WMPaint(var Msg: TWMPaint);
var
  R: TRect;
begin
  if Transparent then begin
    SetWindowPos(Handle, 0, 0, 0, 0, 0,
                 SWP_NOZORDER or SWP_NOSIZE or SWP_NOMOVE
                   or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    GetWindowRect(Handle, R);
    InvalidateRect(Parent.Handle, @R, True);
    UpdateWindow(Parent.Handle);
    SetWindowPos(Handle, 0, 0, 0, 0, 0,
                 SWP_NOZORDER or SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE
                   or SWP_SHOWWINDOW or SWP_NOCOPYBITS);
  end;
  inherited;
end;

procedure TCuteMemo.WMMove(var Msg: TWMMove);
begin
  if Transparent then Repaint;
  inherited;
end;

procedure TCuteMemo.BrushChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCuteMemo.MouseEnter(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self, Shift, X, Y);
end;

procedure TCuteMemo.MouseLeave(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseExit) then FOnMouseExit(Self, Shift, X, Y);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TCuteEdit, TCuteMemo]);
end;

end.
