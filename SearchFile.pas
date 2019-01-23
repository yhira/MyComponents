(*************************************************************************

  ファイル＆ディレクトリ検索コンポーネント
  TSearchFile & TSearchDir

  (C) Tiny Mouse
  2005.05.29

*************************************************************************)

unit SearchFile;

interface

uses
  Windows, SysUtils, Classes;

type
  TSearchFileData = record
    Name: String;
    ShortName: String;
    Size: Int64;
    ValidCreationTime: Boolean;
    CreationTime: TDateTime;
    ValidLastWriteTime: Boolean;
    LastWriteTime: TDateTime;
    ValidLastAccessTime: Boolean;
    LastAccessTime: TDateTime;
    IsDirectory: Boolean;
    IsReadOnly: Boolean;
    IsHidden: Boolean;
    IsSysFile: Boolean;
    IsVolumeID: Boolean;
    IsArchive: Boolean;
  end;

  TFindFileEvent = procedure(Sender: TObject; Name: String;
    Data: TSearchFileData; var Continue: Boolean) of object;

  TFindDirEvent = procedure(Sender: TObject; Name: String;
    Data: TSearchFileData; var Skip, IgnoreSubdir: Boolean) of object;

  TSearchDirEvent = procedure(Sender: TObject; Name: string;
    Data: TSearchFileData; var IgnoreSubdir, Continue: Boolean) of object;

  TSearchFile = class(TComponent)
  private
    FDirectory: String;
    FRecursive: Boolean;
    FSearchName: String;
    FBusy: Boolean;
    FOnFind: TFindFileEvent;
    FOnFindDir: TFindDirEvent;
    FOnSearchDir: TSearchDirEvent;
  protected
    procedure DoFind(Name: String;
      Data: TSearchFileData; var Continue: Boolean); virtual;
    procedure DoFindDir(Name: String;
      Data: TSearchFileData; var Skip, IgnoreSubDir: Boolean); virtual;
    procedure DoSearchDir(Name: String;
      Data: TSearchFileData; var IgnoreSubdir, Continue: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Search: Boolean;
    property OnSearchDir: TSearchDirEvent read FOnSearchDir write FOnSearchDir;
    property Busy: Boolean read FBusy;
    property Searching: Boolean read FBusy;  { 互換の為 }
  published
    property Directory: String read FDirectory write FDirectory;
    property Recursive: Boolean read FRecursive write FRecursive default False;
    property SearchName: String read FSearchName write FSearchName;
    property OnFind: TFindFileEvent read FOnFind write FOnFind;
    property OnFindDir: TFindDirEvent read FOnFindDir write FOnFindDir;
  end;

  TSearchDir = class(TComponent)
  private
    SearchFile: TSearchFile;
    FBaseDir: String;
    FOnFind: TSearchDirEvent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Search: Boolean;
    function Busy: Boolean;
    function Searching: Boolean;  { 互換の為 }
  published
    property BaseDir: String read FBaseDir write FBaseDir;
    property OnFind: TSearchDirEvent read FOnFind write FOnFind;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TSearchFile, TSearchDir]);
end;

{************************************************************************}

{ TFileTime 型からTDateTime 型へ }

function ConvFileTimeToDateTime(FileTime: TFileTime; var DateTime: TDateTime): Boolean;
var
  LocalFileTime: TFileTime;
  SystemTime: TSystemTime;
begin
  try
    Result := FileTimeToLocalFileTime(FileTime, LocalFileTime);
    Result := Result and FileTimeToSystemTime(LocalFileTime, SystemTime);
    DateTime := SystemTimeToDateTime(SystemTime);
  except
    Result := False;
  end;
end;

{ TWin32FindData 型から TSearchFileData 型へ }

procedure ConvFindDataToFileData(FindData: TWin32FindData; var FileData: TSearchFileData);
begin
  FileData.Name := FindData.cFileName;
  if FindData.cAlternateFileName = '' then FileData.ShortName := FindData.cFileName
  else FileData.ShortName := FindData.cAlternateFileName;
  FileData.Size := FindData.nFileSizeHigh * $100000000 + FindData.nFileSizeLow;
  FileData.ValidCreationTime := ConvFileTimeToDateTime(FindData.ftCreationTime, FileData.CreationTime);
  FileData.ValidLastWriteTime := ConvFileTimeToDateTime(FindData.ftLastWriteTime, FileData.LastWriteTime);
  FileData.ValidLastAccessTime := ConvFileTimeToDateTime(FindData.ftLastAccessTime, FileData.LastAccessTime);
  FileData.IsDirectory := FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0;
  FileData.IsReadOnly := FindData.dwFileAttributes and FILE_ATTRIBUTE_READONLY <> 0;
  FileData.IsHidden := FindData.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN <> 0;
  FileData.IsSysFile := FindData.dwFileAttributes and FILE_ATTRIBUTE_SYSTEM <> 0;
  FileData.IsVolumeID := FindData.dwFileAttributes and 0 <> 0;
  FileData.IsArchive := FindData.dwFileAttributes and FILE_ATTRIBUTE_ARCHIVE <> 0
end;

{ TSearchFile }

constructor TSearchFile.Create(AOwner: TComponent);
begin
  inherited;

  FSearchName := '*.*';
end;

destructor TSearchFile.Destroy;
begin
  inherited;
end;

function TSearchFile.Search: Boolean;

  function ValidHandle(Handle: THandle): Boolean;
  begin
    Result := Handle <> INVALID_HANDLE_VALUE;
  end;

  function ValidSubdir(FileData: TSearchFileData): Boolean;
  begin
    Result := FileData.IsDirectory
      and (FileData.Name <> '.') and (FileData.Name <> '..');
  end;

  procedure DoSearch(TargetDir: String);
  var
    Handle: THandle;
    FindData: TWin32FindData;
    FileData: TSearchFileData;
    Name: String;
    Skip, IgnoreSubdir, Continue: Boolean;
    Found: Boolean;
  begin
    Continue := True;
    try
      { 最初を検索 }
      Handle := FindFirstFile(PChar(IncludeTrailingBackslash(TargetDir) + FSearchName), FindData);
      Found := ValidHandle(Handle);
      while Found do
      begin
        ConvFindDataToFileData(FindData, FileData);
        Name := IncludeTrailingBackslash(TargetDir) + FileData.Name;
        Skip := False;
        IgnoreSubdir := not FRecursive;
        { OnSearchDir イベント }
        if ValidSubdir(FileData) then
          DoSearchDir(Name, FileData, IgnoreSubdir, Continue);
        { OnFindDir イベント }
        if ValidSubdir(FileData) then
          DoFindDir(Name, FileData, Skip, IgnoreSubdir);
        { DoFind イベント }
        if (FileData.Name <> '.') and (FileData.Name <> '..')
          and not Skip then
          DoFind(Name, FileData, Continue);
        { 中断指示されたら }
        if not Continue then
          Abort;
        { サブディレクトリへ }
        if ValidSubdir(FileData)
          and not Skip and not IgnoreSubdir then
          DoSearch(Name);
        { 次を検索 }
        Found := FindNextFile(Handle, FindData);
      end;
    finally
      if ValidHandle(Handle) then Windows.FindClose(Handle);
    end;
  end;

var
  BaseDir: String;
begin
  Result := False;
  if FBusy then Exit;
  if not Assigned(FOnSearchDir) and not Assigned(FOnFindDir) and not Assigned(FOnFind) then Exit;
  BaseDir := ExpandFileName(FDirectory);
  if not DirectoryExists(BaseDir) then Exit;

  try
    FBusy := True;
    try
      Result := True;
      DoSearch(BaseDir);
    except
      on EAbort do Result := False
      else raise;
    end;
  finally
    FBusy := False;
  end;
end;

procedure TSearchFile.DoFind(Name: String;
  Data: TSearchFileData; var Continue: Boolean);
begin
  if Assigned(FOnFind) then FOnFind(Self, Name, Data, Continue);
end;

procedure TSearchFile.DoFindDir(Name: String;
  Data: TSearchFileData; var Skip, IgnoreSubdir: Boolean);
begin
  if Assigned(FOnFindDir) then FOnFindDir(Self, Name, Data, Skip, IgnoreSubdir);
end;

procedure TSearchFile.DoSearchDir(Name: String;
  Data: TSearchFileData; var IgnoreSubdir, Continue: Boolean);
begin
  if Assigned(FOnSearchDir) then FOnSearchDir(Self, Name, Data, IgnoreSubdir, Continue);
end;

{ TSearchDir }

constructor TSearchDir.Create(AOwner: TComponent);
begin
  inherited;
  SearchFile := TSearchFile.Create(Self);
end;

destructor TSearchDir.Destroy;
begin
  SearchFile.Free;
  inherited;
end;

function TSearchDir.Search: Boolean;
begin
  SearchFile.Directory := FBaseDir;
  SearchFile.Recursive := True;
  SearchFile.OnSearchDir := FOnFind;
  Result := SearchFile.Search;
end;

function TSearchDir.Busy: Boolean;
begin
  Result := SearchFile.Busy;
end;

function TSearchDir.Searching: Boolean;
begin
  Result := SearchFile.Searching;
end;

end.
