(***************************************************************

  TEditorEx ver 3.03 (Yellow) (2007/01/25)

  Copyright (c) 2001-2007 Km
  http://homepage2.nifty.com/Km/

***************************************************************)
unit EditorExReg;

{$I heverdef.inc}

interface

uses
  Classes,

  {$IFDEF COMP6_UP}
    DesignIntf, DesignEditors;
  {$ELSE}
    Dsgnintf;
  {$ENDIF}

procedure Register;

implementation

uses
  EditorEx, EditorExProp;

procedure Register;
begin
  // components
  RegisterComponents('TEditor', [TEditorEx, TEditorExProp]);
end;

end.
