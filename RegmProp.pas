(*
  Property&Component editor for TRegManager ver 1.3

  start  1999/10/15

  copyright (c) 1998,1999 ñ{ìcèüïF <katsuhiko.honda@nifty.ne.jp>
*)
unit RegmProp;

{$I heverdef.inc}

interface

uses
  {$IFDEF COMP6_UP}
    DesignIntf, DesignEditors;
  {$ELSE}
    Dsgnintf;
  {$ENDIF}

type
  TRegItemsPropertyEditor = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TRegItemsComponentEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  end;

implementation

uses
  RegmEdit;

{ TRegItemsComponentEditor }

function TRegItemsComponentEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TRegItemsComponentEditor.GetVerb(Index: Integer): String;
begin
  Result := 'çÄñ⁄ÇÃï“èW(&H)';
end;

procedure TRegItemsComponentEditor.ExecuteVerb(Index: Integer);
begin
  if TFormRegItemEditor.Execute(Component) then
    Designer.Modified;
end;

{ TRegItemsPropertyEditor }

procedure TRegItemsPropertyEditor.Edit;
begin
  if TFormRegItemEditor.Execute(GetComponent(0)) then
    Designer.Modified;
end;

function TRegItemsPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

end.
