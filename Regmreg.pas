(*
  Register for TRegManager ver 1.3

  start  1999/10/15

  copyright (c) 1998,1999 ñ{ìcèüïF <katsuhiko.honda@nifty.ne.jp>
*)
unit RegmReg;

{$I heverdef.inc}

interface

procedure Register;

implementation

uses
  Classes, RegMng, RegmProp,

  {$IFDEF COMP6_UP}
    DesignIntf;
  {$ELSE}
    Dsgnintf;
  {$ENDIF}

procedure Register;
begin
  RegisterComponents('Samples', [TRegManager]);
  RegisterComponentEditor(TRegManager, TRegItemsComponentEditor);
  RegisterPropertyEditor(TypeInfo(TRegItems), TRegManager, 'RegItems',
    TRegItemsPropertyEditor);
end;

end.
