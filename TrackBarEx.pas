unit TrackBarEx;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, CommCtrl;

type
  TTrackBarEx = class(TTrackBar)
  private
    FSelectRange: Boolean;
    procedure SetSelectRange(const Value: Boolean);
    { Private �錾 }
  protected
    { Protected �錾 }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public �錾 }
  published
    { Published �錾 }
    property SelectRange: Boolean read FSelectRange write SetSelectRange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TTrackBarEx]);
end;

{ TTrackBarEx }

procedure TTrackBarEx.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if not SelectRange then
    Params.Style := Params.Style and not TBS_ENABLESELRANGE;
end;

procedure TTrackBarEx.SetSelectRange(const Value: Boolean);
begin
  FSelectRange := Value;
  RecreateWnd;
end;

end.
