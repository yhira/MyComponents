(*★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・* : ☆. ` ・ ★"
  . `  +・ *  ☆★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・*
   : ☆. ★                                                ` ・* : ☆
    ` ・          Delphi Visual Component Library         ☆. ` ・ ★"
  + `  +・          URL 表示ラベルコンポーネント             : ☆. ` ・
  ☆ . :*    　     　 URLLabel Version 1.00                    ★" .
  . ★" .                                                  . :* ★  '
   ` ・* :         Copyright (c) 1997 ｆｕｍｉｋａ            ☆ . :*
   .   `  +                                              ・ `  +・ *
  ★ﾐ  ・*       e-mail : YRK00111@niftyserve.or.jp       . ` ・ ★"
   ` ・* :       http://www2m.biglobe.ne.jp/~fumika/      ・ ★" . `.
  . :*   `                                                  ☆ . :* ★
  `  +・ *  ☆ . :*   +・ *.  ☆ . :* ★ ` ・* : ☆. ` ・ ★" .
 ` ☆. ` ・ ★" .   `  +・ *   . :*   +  .  .  * ☆ﾐ      + .    :   *)

unit URLLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Controls,
  StdCtrls, ShellAPI;

{$IFNDEF VER100}
{$R *.RES}
const
  crHandPoint = 32761;
{$ENDIF}

type
  TURLLabel = class(TLabel)
  private
    FExecutable: Boolean;
    FHotTrack: Boolean;
    FFontColor: TColor;
    FHotColor: TColor;
    FPushedColor: TColor;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure SetHotTrack(Value: Boolean);
    procedure SetHotColor(Value: TColor);
    procedure SetPushedColor(Value: TColor);
  published
    constructor Create(AOwner: TComponent); override;
    procedure MouseDown(Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer); override;
    property Cursor default crHandPoint;
    property Executable: Boolean read FExecutable write FExecutable;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default True;
    property HotColor: TColor read FHotColor write SetHotColor default clAqua;
    property PushedColor: TColor read FPushedColor write SetPushedColor default clRed;
  end;

procedure Register;

implementation

constructor TURLLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFNDEF VER100}
  Screen.Cursors[crHandPoint] := LoadCursor(HInstance, 'HANDPOINT');
  {$ENDIF}
  FHotColor := clAqua;
  FPushedColor := clRed;
  FHotTrack := True;
  Cursor := crHandPoint;
end;

procedure TURLLabel.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  if FHotTrack then begin
    FFontColor := Font.Color;
    Font.Color := FHotColor;
    Invalidate;
  end;
end;

procedure TURLLabel.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if FHotTrack then begin
    Font.Color := FFontColor;
    Invalidate;
  end;
end;

procedure TURLLabel.MouseDown(Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FHotTrack then begin
    Font.Color := FPushedColor;
    Invalidate;
  end;
  if FExecutable then
    {$IFDEF VER100}
    ShellExecute(MainInstance, 'OPEN', PChar(Caption), '', '', SW_SHOW);
    {$ELSE}
    ShellExecute(hInstance, 'OPEN', PChar(Caption), '', '', SW_SHOW);
    {$ENDIF}
end;

procedure TURLLabel.MouseUp(Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
var
  Cur: TPoint;
begin
  inherited;
  if HotTrack then begin
    GetCursorPos(Cur);
    Cur := ScreenToClient(Cur);
    if PtInRect(ClientRect, Cur) then
      Font.Color := FHotColor
    else
      Font.Color := FFontColor;
    Invalidate;
  end;
end;

procedure TURLLabel.SetHotTrack(Value: Boolean);
begin
  if FHotTrack <> Value then begin
    FHotTrack := Value;
    Invalidate;
  end;
end;

procedure TURLLabel.SetHotColor(Value: TColor);
begin
  if FHotColor <> Value then begin
    FHotColor := Value;
    Invalidate;
  end;
end;

procedure TURLLabel.SetPushedColor(Value: TColor);
begin
  if FPushedColor <> Value then begin
    FPushedColor := Value;
    Invalidate;
  end;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TURLLabel]);
end;


end.
