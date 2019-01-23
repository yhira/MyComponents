(*★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・* : ☆. ` ・ ★"
  . `  +・ *  ☆★ ` ・* : ☆. ` ・ ★" . `  +・ *  ☆ . :* ★ ` ・*
   : ☆. ★                                                ` ・* : ☆
    ` ・          Delphi Visual Component Library        ☆. ` ・ ★"
  + `  +・             拡張 ヒント コンポーネント          : ☆. ` ・
  ☆ . :*         　 TAppHint Version 3.00                 ★" .
  . ★" .                                                  . :* ★  '
   ` ・* :   Copyright (c) 1997-2000 pantograph(fumika)     ☆ . :*
   .   `  +            All Rights Reserved.              ・ `  +・ *
  .  + :*                                                   .  ★ + .
  ★ﾐ  ・*           mailto:pantograph@nifty.com          . ` ・ ★"
   ` ・* :       http://homepage1.nifty.com/cosmic/       ・ ★" . `.
  . :*   `                                                  ☆ . :* ★
  `  +・ *  ☆ . :*   +・ *.  ☆ . :* ★ ` ・* : ☆. ` ・ ★" .
 ` ☆. ` ・ ★" .   `  +・ *   . :*   +  .  .  * ☆ﾐ      + .    :   *)

unit NewHint;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  THintPaintEvent = procedure (HintStr: string; Canvas: TCanvas;
                      Width, Height: Integer) of object;

  THintStyle = (hsFukidashi, hsRoundRect, hsLineString, hsOwnerDraw);

  TAppHint = class(TComponent)
  private
    { Private 宣言 }
    FBGColor: TColor;
    FBrush: TBrush;
    FFont: TFont;
    FHintStyle: THintStyle;
    FPen: TPen;
    FShadowColor: TColor;
    FShadowVisible: Boolean;
    FOnHint: TNotifyEvent;
    FOnPaint: THintPaintEvent;
    FOnShowHint: TShowHintEvent;
    function GetHidePause: Integer;
    function GetHintPause: Integer;
    function GetShortPause: Integer;
    procedure SetHidePause(const Value: Integer);
    procedure SetHintPause(const Value: Integer);
    procedure SetHintStyle(const Value: THintStyle);
    procedure SetShortPause(const Value: Integer);
    procedure FontChange(Sender: TObject);
    procedure SetFont(const Value: TFont);
  protected
    { Protected 宣言 }
  public
    { Public 宣言 }
    constructor Create(AOwner : TComponent); override;
    procedure Loaded; override;
    destructor Destroy; override;
    procedure DoHint(Sender: TObject);
    procedure ShowHint(var HintStr: string; var CanShow: Boolean;
                       var HintInfo: THintInfo);
  published
    { Published 宣言 }
    property BGColor: TColor read FBGColor write FBGColor;
    property Brush: TBrush read FBrush write FBrush;
    property Font: TFont read FFont write SetFont;
    property HintPause: Integer read GetHintPause write SetHintPause;
    property HintHidePause: Integer read GetHidePause write SetHidePause;
    property HintShortPause: Integer read GetShortPause write SetShortPause;
    property HintStyle: THintStyle read FHintStyle write SetHintStyle;
    property Pen: TPen read FPen write FPen;
    property ShadowColor: TColor read FShadowColor write FShadowColor default clBlue;
    property ShadowVisible: Boolean read FShadowVisible write FShadowVisible;
    property OnHint: TNotifyEvent read FOnHint write FOnHint;
    property OnPaint: THintPaintEvent read FOnPaint write FOnPaint;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
  end;

type
  THintEx = class(THintWindow)
  private
    FR: TRect;
    Rgn: HRgn;
    HintPoly: array [0..7] of TPoint;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    procedure Paint; override;
  public
    constructor Create(AOwner : TComponent); override;
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
  end;

procedure Register;

implementation

var
  AppHint: TAppHint;

constructor TAppHint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBGColor := clBlack;
  FBrush := TBrush.Create;
  FBrush.Color := clNavy;
  FBrush.Style := bsSolid;
  FFont := TFont.Create;
  FFont.Color := clLime;
  FFont.OnChange := FontChange;
  FPen := TPen.Create;
  ShadowColor := clBlue;
  ShadowVisible := True;
  if not(csDesigning in ComponentState) then begin
    HintWindowClass := THintEx;
    Application.ShowHint := False;
    Application.ShowHint := True;
    AppHint := Self;
  end else begin
    if AppHint = nil then begin
      AppHint := Self;
    end else begin
      //設計時に自分と同じコンポを２つ作成できないように。
      MessageBeep(MB_ICONWARNING);
      raise Exception.Create('TAppHint コンポーネントは一つしか作成できません。');
    end;
  end;
end;

procedure TAppHint.Loaded;
begin
  inherited Loaded;
  if not(csDesigning in ComponentState) then begin
    HintWindowClass := THintEx;
    Application.ShowHint := False;
    Application.ShowHint := True;
    Application.OnHint := DoHint;
    Application.OnShowHint := ShowHint;
  end;
end;

destructor TAppHint.Destroy;
begin
  FBrush.Free;
  FFont.Free;
  FPen.Free;
  if AppHint = Self then
    AppHint := nil;
  inherited Destroy;
end;

procedure TAppHint.FontChange(Sender: TObject);
begin
  if not(csDesigning in ComponentState) then begin
    Application.ShowHint := False;
    Application.ShowHint := True;
  end;
end;

procedure TAppHint.SetFont(const Value: TFont);
begin
  FFont.Assign(VAlue);
end;

function TAppHint.GetHintPause: Integer;
begin
  Result := Application.HintPause;
end;

procedure TAppHint.SetHintPause(const Value: Integer);
begin
  Application.HintPause := Value;
end;

function TAppHint.GetHidePause: Integer;
begin
  Result := Application.HintHidePause;
end;

procedure TAppHint.SetHidePause(const Value: Integer);
begin
  Application.HintHidePause := Value;
end;

procedure TAppHint.SetHintStyle(const Value: THintStyle);
begin
  if FHintStyle <> Value then begin
    FHintStyle := Value;
    if not(csDesigning in ComponentState) then begin
      Application.ShowHint := False;
      Application.ShowHint := True;
    end;
  end;
end;


function TAppHint.GetShortPause: Integer;
begin
  Result := Application.HintShortPause;
end;

procedure TAppHint.SetShortPause(const Value: Integer);
begin
  Application.HintShortPause := Value;
end;

procedure TAppHint.DoHint(Sender: TObject);
begin
  if Assigned(FOnHint) then FOnHint(Sender);
end;

procedure TAppHint.ShowHint(var HintStr: string; var CanShow: Boolean;
  var HintInfo: THintInfo);
begin
  HintInfo.HintPos.Y := HintInfo.HintPos.Y - 8;
  if Assigned(FOnShowHint) then
    FOnShowHint(HintStr, CanShow, HintInfo);
end;

{  THintEx  }

constructor THintEx.Create(AOwner: TComponent);
begin
  inherited;
  if AppHint <> nil then begin
    Canvas.Font.Assign(AppHint.Font);
  end;
end;

procedure THintEx.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP or WS_DISABLED;
end;

procedure THintEx.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  if AppHint <> nil then
    if AppHint.FHintStyle <> hsLineString then inherited;
end;

procedure THintEx.Paint;
const
  DT_HINT_DRAW = DT_LEFT or DT_NOPREFIX or DT_WORDBREAK;
var
  R: TRect;

  procedure PaintFukidashi;
  begin
    with Canvas do begin
      FillRect(ClipRect);
      Brush.Style := bsClear;
      if AppHint.ShadowVisible then begin
        R := ClientRect;
        OffsetRect(R, 4, 10);
        Font.Color := AppHint.FShadowColor;
        DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
      end;
      R := ClientRect;
      OffsetRect(R, 3, 9);
      Font.Color := AppHint.FFont.Color;
      DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
      Polygon(HintPoly);
    end;
  end;

  procedure PaintRoundRect;
  begin
    with Canvas do begin
      FillRect(ClipRect);
      Brush.Style := bsClear;
      if AppHint.ShadowVisible then begin
        R := ClientRect;
        OffsetRect(R, 2, 2);
        Font.Color := AppHint.FShadowColor;
        DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
      end;
      R := ClientRect;
      OffsetRect(R, 1, 1);
      Font.Color := AppHint.FFont.Color;
      DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
      RoundRect(0, 0, FR.Right - FR.Left, FR.Bottom - FR.Top, 8, 8);
    end;
  end;

  procedure PaintLineString;
  begin
    with Canvas do begin
      Brush.Style := bsClear;
      if AppHint.ShadowVisible then begin
        R := ClientRect;
        Font.Color := AppHint.FShadowColor;
        OffsetRect(R, 19, 10);
        DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
        OffsetRect(R,  0,  2);
        DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
        OffsetRect(R, -1, -1);
        DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
        OffsetRect(R,  2,  0);
        DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
      end;
      R := ClientRect;
      OffsetRect(R, 19, 11);
      Font.Color := AppHint.FFont.Color;
      DrawText(Handle, PChar(Caption), -1, R, DT_HINT_DRAW);
      MoveTo(1, 1);
      LineTo(17, FR.Bottom - FR.Top-2);
      LineTo(FR.Right - FR.Left, FR.Bottom - FR.Top-2);
    end;
  end;

  procedure OwnerDraw;
  begin
    if Assigned(AppHint.FOnPaint) then
      AppHint.FOnPaint(Caption, Canvas, Width, Height);
  end;

begin
  if AppHint <> nil then begin
    with Canvas do begin
      Font.Assign(AppHint.FFont);
      Brush.Color := AppHint.Brush.Color;
      Brush.Style := AppHint.Brush.Style;
      // Win95 のバグへの対処 ここを抜かすとブラシが bsSolid 以外の時、
      //　背景色がブラシの反転色になる。NT4.0 では常に黒
      if Brush.Style = bsSolid then begin
        SetBkColor(Handle, ColorToRGB(Brush.Color));
        SetBkMode(Handle, OPAQUE);
      end else begin
        SetBkColor(Handle, ColorToRGB(AppHint.BGColor));
        SetBkMode(Handle, TRANSPARENT);
      end;
      Pen := AppHint.Pen;

      case AppHint.HintStyle of
        hsFukidashi  : PaintFukidashi;
        hsRoundRect  : PaintRoundRect;
        hsLineString : PaintLineString;
        hsOwnerDraw  : OwnerDraw;
      else
        inherited Paint;
      end;
    end;
  end;
end;

procedure THintEx.ActivateHint(Rect: TRect; const AHint: string);
var
  RH, RW: Integer;

  procedure SetFukidashiRgn;
  begin
    Inc(Rect.Bottom, 9);
    RH := Rect.Bottom - Rect.Top;
    RW := Rect.Right - Rect.Left;
    HintPoly[0] := Point(14,  0);
    HintPoly[1] := Point( 8,  9);
    HintPoly[2] := Point( 0,  9);
    HintPoly[3] := Point( 0, RH);
    HintPoly[4] := Point(RW, RH);
    HintPoly[5] := Point(RW,  9);
    HintPoly[6] := Point(14,  9);
    Rgn := CreatePolygonRgn(HintPoly, 7, Winding);
    SetWindowRgn(Handle, Rgn, True);
    HintPoly[1] := Point(   9,    9);
    HintPoly[3] := Point(   0, RH-1);
    HintPoly[4] := Point(RW-1, RH-1);
    HintPoly[5] := Point(RW-1,    9);
    HintPoly[6] := Point(  13,    9);
    HintPoly[7] := Point(  13,    0);
  end;

  procedure SetRoundRectRgn;
  begin
    FR := Rect;
    RH := Rect.Bottom - Rect.Top + 1;
    RW := Rect.Right - Rect.Left + 1;
    Rgn := CreateRoundRectRgn(0, 0, RW, RH, 8, 8);
    SetWindowRgn(Handle, Rgn, True);
  end;

  procedure SetLineStringRgn;
  begin
    Inc(Rect.Right , 21);
    Inc(Rect.Bottom, 12);
    FR := Rect;
    RH := Rect.Bottom - Rect.Top;
    RW := Rect.Right - Rect.Left;
    Rgn := CreateRectRgn(1, 1, RW-1, RH-1);
    SetWindowRgn(Handle, Rgn, True);
  end;

begin
  if Rgn <> 0 then begin
    //リージョンを破棄する前にハンドルの有無を確認する。
    if HandleAllocated then begin
      SetWindowRgn(Handle, 0 ,False);
      DeleteObject(Rgn);
    end;
  end;
  HandleNeeded;
  if AppHint <> nil then begin
    case AppHint.FHintStyle of
      hsFukidashi  : SetFukidashiRgn;
      hsRoundRect  : SetRoundRectRgn;
      hsLineString : SetLineStringRgn;
    end;
  end;
  inherited ActivateHint(Rect, AHint);
end;

procedure THintEx.DestroyWindowHandle;
begin
  SetWindowRgn(Handle, 0, False);
  DeleteObject(Rgn);
  inherited DestroyWindowHandle;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TAppHint]);
end;

end.
