(*
  Property&Component editor form for TRegManager ver 1.3

  start  1998/05/31
  update 1999/10/15

  copyright (c) 1998,1999 ñ{ìcèüïF <katsuhiko.honda@nifty.ne.jp>

  usage

  function hogehoge: Boolean;
  begin
    Result := TFormRegItemEditor.Execute(RegManager1);
  end;

  RegManager1 default value
  RetType: rtReg
  RegDir: Software\Honda_Katsuhiko\TRegManager\Component Editor
  RegItems
  item name,            section,     ident,                defaultvalue
    0: CheckDuplicate   TRegManager  Check Duplicate Name  True
    1: CheckInvalidData TRegManager  Check Invalid Data    True
    2: ShowEditor       TRegManager  AlwaysShowEditor      False
    3: Tabs             TRegManager  Tabs                  False
*)
unit RegmEdit;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, RegMng,

  {$IFDEF COMP6_UP}
    DesignIntf;
  {$ELSE}
    Dsgnintf;
  {$ENDIF}

type
  TFormRegItemEditor = class(TForm)
    GridRegItem: TStringGrid;
    btnAdd: TButton;
    btnRemove: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    btnInsert: TButton;
    btnClip: TButton;
    btnClipRow: TButton;
    Bevel1: TBevel;
    RegManager1: TRegManager;
    CheckShowEditor: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    EditReg: TEdit;
    EditIni: TEdit;
    Bevel2: TBevel;
    Label4: TLabel;
    btnHelp: TButton;
    RadioRegType: TRadioGroup;
    CheckTabs: TCheckBox;
    CheckDuplicate: TCheckBox;
    CheckInvalid: TCheckBox;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnClipClick(Sender: TObject);
    procedure btnClipRowClick(Sender: TObject);
    procedure GridRegItemDrawCell(Sender: TObject; Col, Row: Longint;
      Rect: TRect; State: TGridDrawState);
    procedure CheckShowEditorClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure CheckTabsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FRegManager: TRegManager;
    FRegItems: TRegItems;
    procedure WMHelp(var Message: TMessage); message WM_HELP;
    procedure MessageDlgShow(S: String);
    procedure MessageDlgHelpShow(Sender: TObject);
  public
    class function Execute(Component: TPersistent): Boolean;
  end;

implementation

uses
  Clipbrd;

{$R *.DFM}


{ TFormRegItemEditor }

class function TFormRegItemEditor.Execute(Component: TPersistent): Boolean;
var
  Form: TFormRegItemEditor;
begin
  Result := False;
  if (Component <> nil) and (Component is TRegManager) then
  begin
    Form := TFormRegItemEditor.Create(Application);
    try
      Form.FRegManager := Component as TRegManager;
      Form.FRegItems := (Component as TRegManager).RegItems;
      Result := Form.ShowModal = mrOK;
    finally
      Form.Free;
    end;
  end;
end;

procedure TFormRegItemEditor.GridRegItemDrawCell(Sender: TObject; Col,
  Row: Longint; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  if (Col = 0) and (Row <> 0) then
  begin
    OffsetRect(Rect, 3, 2);
    DrawText(GridRegItem.Canvas.Handle, PChar(IntToStr(Row - 1)),
      -1, Rect, DT_LEFT);
  end;
end;

procedure TFormRegItemEditor.CheckShowEditorClick(Sender: TObject);
begin
  if CheckShowEditor.Checked then
    GridRegItem.Options := GridRegItem.Options + [goAlwaysShowEditor]
  else
    GridRegItem.Options := GridRegItem.Options - [goAlwaysShowEditor];
end;

procedure TFormRegItemEditor.CheckTabsClick(Sender: TObject);
begin
  if CheckTabs.Checked then
    GridRegItem.Options := GridRegItem.Options + [goTabs]
  else
    GridRegItem.Options := GridRegItem.Options - [goTabs];
end;

procedure TFormRegItemEditor.MessageDlgShow(S: String);
var
  Form: TForm;
  Button: TComponent;
begin
  Form := CreateMessageDialog(S, mtError, [mbOk, mbHelp]);
  try
    Form.Position := poScreenCenter;
    Button := Form.FindComponent('Help');
    if Button <> nil then
      TButton(Button).OnClick := MessageDlgHelpShow;
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFormRegItemEditor.MessageDlgHelpShow(Sender: TObject);
begin
  WinHelp(Handle, PChar('RegMng.hlp>MesDlg'), HELP_CONTEXT, 2020);
end;

procedure TFormRegItemEditor.FormShow(Sender: TObject);
var
  I: Integer;
begin
  with GridRegItem do
  begin
    if FRegitems.Count = 0 then
      RowCount := 2
    else
      RowCount := FRegItems.Count + 1;
  end;
  for I := 0 to FRegItems.Count - 1 do
  with GridRegItem, FRegItems[I] do
  begin
    Cells[1, I + 1] := Name;
    Cells[2, I + 1] := Section;
    Cells[3, I + 1] := Ident;
    Cells[4, I + 1] := DefaultValue;
  end;
  with GridRegItem do
  begin
    Cells[0, 0] := 'Item';
    Cells[1, 0] := 'Name';
    Cells[2, 0] := 'Section';
    Cells[3, 0] := 'Ident';
    Cells[4, 0] := 'DefaultValue';
    Row := 1;
    Col := 1;
  end;
  Caption := 'TRegManager Component Editor   about ' +
             FRegManager.Owner.Name + '.' + FRegManager.Name;
  RadioRegType.ItemIndex := Ord(FRegManager.RegType);
  EditReg.Text := FRegManager.RegDir;
  EditIni.Text := FRegManager.IniFileName;
  CheckDuplicate.Checked := RegManager1['CheckDuplicate'].AsBoolean;
  CheckInvalid.Checked := RegManager1['CheckInvalidData'].AsBoolean;
  CheckShowEditor.Checked := RegManager1['ShowEditor'].AsBoolean;
  CheckTabs.Checked := RegManager1['Tabs'].AsBoolean;
  if CheckShowEditor.Checked then
    GridRegItem.Options := GridRegItem.Options + [goAlwaysShowEditor]
  else
    GridRegItem.Options := GridRegItem.Options - [goAlwaysShowEditor];
  if CheckTabs.Checked then
    GridRegItem.Options := GridRegItem.Options + [goTabs]
  else
    GridRegItem.Options := GridRegItem.Options - [goTabs];
  GridRegItem.SetFocus;
end;


procedure TFormRegItemEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
    Exit;
  RegManager1['CheckDuplicate'].AsBoolean := CheckDuplicate.Checked;
  RegManager1['CheckInvalidData'].AsBoolean := CheckInvalid.Checked;
  RegManager1['ShowEditor'].AsBoolean := CheckShowEditor.Checked;
  RegManager1['Tabs'].AsBoolean := CheckTabs.Checked;
end;

procedure TFormRegItemEditor.btnOkClick(Sender: TObject);
var
  I, J: Integer;
  S: String;
  Item: TRegItem;
begin
  // check duplicate
  if CheckDuplicate.Checked then
    for I := 1 to GridRegItem.RowCount - 1 do
    begin
      S := AnsiUpperCase(GridRegItem.Cells[1, I]);
      if S = '' then
        Continue;
      for J := I + 1 to GridRegItem.RowCount - 1 do
        if S = AnsiUpperCase(GridRegItem.Cells[1, J]) then
        begin
          ModalResult := mrNone;
          MessageDlgShow('Duplicate Name error Item ' +
                      IntToStr(I - 1) + ' and Item ' +
                      IntToStr(J - 1) + '  ');
          GridRegItem.Row := J;
          GridRegItem.SetFocus;
          Exit;
        end;
    end;
  // check invalid data
  if CheckInvalid.Checked then
    for I := 1 to GridRegItem.RowCount - 1 do
    begin
      // Ignore a row that name is null.
      if GridRegItem.Cells[1, I] = '' then
        Continue;
      for J := 2 to 3 do
        if GridRegItem.Cells[J, I] = '' then
        begin
          ModalResult := mrNone;
          case J of
            2: S := 'Section';
            3: S := 'Ident';
          end;
          MessageDlgShow('You must specify text for ' + S);
          GridRegItem.Row := I;
          GridRegItem.Col := J;
          GridRegItem.SetFocus;
          Exit;
        end;
    end;

  // Assign RegItems
  FRegItems.Clear;
  for I := 1 to GridRegItem.RowCount - 1 do
    if GridRegItem.Cells[1, I] <> '' then
    begin
      Item := TRegItem.Create(FRegItems);
      Item.Name := GridRegItem.Cells[1, I];
      Item.Section := GridRegItem.Cells[2, I];
      Item.Ident := GridRegItem.Cells[3, I];
      Item.DefaultValue := GridRegItem.Cells[4, I];
    end;
  // Assign Others
  with FRegManager do
  begin
    RegType := TRegType(RadioRegType.ItemIndex);
    RegDir := EditReg.Text;
    IniFileName := EditIni.Text;
  end;
end;

procedure TFormRegItemEditor.btnAddClick(Sender: TObject);
begin
  with GridRegItem do
  begin
    RowCount := RowCount + 1;
    Row := RowCount -1;
    Col := 1;
    SetFocus;
  end;
end;

procedure TFormRegItemEditor.btnInsertClick(Sender: TObject);
var
  I, CurrentRow: Integer;
begin
  with GridRegItem do
  begin
    CurrentRow := Row;
    RowCount := RowCount + 1;
    for I := RowCount - 2 downto CurrentRow do
      Rows[I + 1].Assign(Rows[I]);
    Rows[CurrentRow].Clear;
    Row := CurrentRow;
    Col := 1;
    SetFocus;
  end;
end;

procedure TFormRegItemEditor.btnRemoveClick(Sender: TObject);
var
  I, DeleteRow: Integer;
begin
  with GridRegItem do
  begin
    DeleteRow := Row;
    for I := DeleteRow to RowCount - 2 do
      Rows[I].Assign(Rows[I + 1]);
    Rows[RowCount - 1].Clear; // clear memory for next adding.
    if RowCount > 2 then
      RowCount := RowCount - 1;
    SetFocus;
  end;
end;

procedure TFormRegItemEditor.btnClipClick(Sender: TObject);
var
  BufList: TStringList;
  S, Cell: String;
  I, J: Integer;
begin
  BufList := TStringList.Create;
  try
    BufList.Add('{');
    for I := 1 to GridRegItem.RowCount - 1 do
    begin
      for J := 1 to 4 do
      begin
        Cell := GridRegItem.Cells[J, I];
        case J of
          1: if Cell = '' then // skip no name
               Break
             else
               S := FRegManager.Name + '[''' + Cell + '''].   '; // componame['name'].
          2: if Cell <> '' then S := S + '[' + Cell + '] ';      // section
          3: if Cell <> '' then S := S + Cell + '=';             // ident
          4: if Cell <> '' then S := S + Cell;                   // defaultvalue
        end
      end;
      BufList.Add(S);
    end;
    BufList.Add('}');
    Clipboard.AsText := BufList.Text;
  finally
    BufList.Free;
  end;
end;

procedure TFormRegItemEditor.btnClipRowClick(Sender: TObject);
var
  S: String;
begin
  S := '';
  with GridRegItem do
  if Cells[1, Row] <> '' then
    S := FRegManager.Name + '[''' + Cells[1, Row] + '''].   ' +
         '[' + Cells[2, Row] + '] ' + Cells[3, Row] + '=' +
         Cells[4, Row];
  Clipboard.AsText := S;
end;

procedure TFormRegItemEditor.btnHelpClick(Sender: TObject);
begin
  WinHelp(Handle, PChar('RegMng.hlp'), HELP_CONTENTS, 0);
end;

procedure TFormRegItemEditor.WMHelp(var Message: TMessage);
var
  Control: TWinControl;
  ContextID: Integer;
  Buf: array[0..1] of Longint;
begin
  if TWMHelp(Message).HelpInfo.iContextType = HELPINFO_WINDOW then
  with PHelpInfo(Message.LParam)^ do
  begin
    Control := FindControl(hItemHandle);
    if (Control <> nil) and (Control.HelpContext <> 0) then
    begin
      ContextID := Control.HelpContext;
      Buf[0] := hItemHandle;
      Buf[1] := ContextID;
      { HELP_CONTEXTMENU or HELP_WM_HELP needs cotrol handle }
      WinHelp(hItemHandle, PChar('RegMng.hlp'), HELP_WM_HELP, Integer(@Buf[0]));
    end;
  end;
end;

end.
