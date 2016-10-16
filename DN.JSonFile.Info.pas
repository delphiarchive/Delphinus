{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile.Info;

interface

uses
  Classes,
  Types,
  SysUtils,
  Generics.Collections,
  DN.Version,
  DN.Types,
  DN.JSon,
  DN.JSonFile,
  DN.Compiler.Intf;

type
  TInfoDependency = record
    ID: TGUID;
    Version: TDNVersion;
  end;

  TInfoFile = class(TJSonFile)
  private
    FID: TGUID;
    FPicture: string;
    FFirstVersion: string;
    FPackageCompilerMax: TCompilerVersion;
    FPackageCompilerMin: TCompilerVersion;
    FCompilerMin: TCompilerVersion;
    FCompilerMax: TCompilerVersion;
    FName: string;
    FLicenseFile: string;
    FLicenseType: string;
    FPlatforms: TDNCompilerPlatforms;
    FDependencies: TList<TInfoDependency>;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
    procedure LoadPlatforms(const APlatforms: string);
    procedure LoadDependencies(const ADependencies: TJSONArray);
    procedure SaveDependencies(const ADependencies: TJSONArray);
    function GetPlatformString: string;
    function ReadID(const AObject: TJSONObject): TGUID;
  public
    constructor Create;
    destructor Destroy; override;
    property Picture: string read FPicture;
    property ID: TGUID read FID write FID;
    property Name: string read FName write FName;
    property LicenseType: string read FLicenseType write FLicenseType;
    property LicenseFile: string read FLicenseFile write FLicenseFile;
    property FirstVersion: string read FFirstVersion;
    property PackageCompilerMin: TCompilerVersion read FPackageCompilerMin;
    property PackageCompilerMax: TCompilerVersion read FPackageCompilerMax;
    property CompilerMin: TCompilerVersion read FCompilerMin;
    property CompilerMax: TCompilerVersion read FCompilerMax;
    property Platforms: TDNCompilerPlatforms read FPlatforms;
    property Dependencies: TList<TInfoDependency> read FDependencies;
  end;

implementation

uses
  StrUtils,
  DN.Utils;

{ TInfoFile }

constructor TInfoFile.Create;
begin
  inherited Create();
  FDependencies := TList<TInfoDependency>.Create();
end;

destructor TInfoFile.Destroy;
begin
  FDependencies.Free;
  inherited;
end;

function TInfoFile.GetPlatformString: string;
var
  LPlatform: TDNCompilerPlatform;
  LNeedsSeperator: Boolean;
begin
  Result := '';
  LNeedsSeperator := False;
  for LPlatform in FPlatforms do
  begin
    if LNeedsSeperator then
      Result := Result + ';';
    Result := Result + TDNCompilerPlatformName[LPlatform];
    LNeedsSeperator := True;
  end;
end;

procedure TInfoFile.Load(const ARoot: TJSONObject);
var
  LDependencies: TJSONArray;
begin
  inherited;
  FPicture := ReadString(ARoot, 'picture');
  FID := ReadID(ARoot);
  FName := ReadString(ARoot, 'name');
  FLicenseType := ReadString(ARoot, 'license_type');
  FLicenseFile := ReadString(ARoot, 'license_file');
  FFirstVersion := ReadString(ARoot, 'first_version');
  FCompilerMin := ReadFloat(ARoot, 'compiler_min');
  FCompilerMax := ReadFloat(ARoot, 'compiler_max');
  FPackageCompilerMax := ReadFloat(ARoot, 'package_compiler_max', FCompilerMax);
  FPackageCompilerMin := ReadFloat(ARoot, 'package_compiler_min', FCompilerMin);
  LoadPlatforms(ReadString(ARoot, 'platforms'));
  if ARoot.TryGetValue<TJSONArray>('dependencies', LDependencies) then
    LoadDependencies(LDependencies);
end;

procedure TInfoFile.LoadDependencies(const ADependencies: TJSONArray);
var
  LValue: TJSONValue;
  LObject: TJSONObject;
  LDependency: TInfoDependency,
  LVersion: TDNVersion;
begin
  for LValue in ADependencies do
  begin
    LObject := LValue as TJSONObject;
    if TDNVersion.TryParse(ReadString(LObject, 'version_min'), LVersion) then
    begin
      LDependency.ID := ReadID(LObject);
      LDependency.Version := LVersion;
      FDependencies.Add(LDependency);
    end;
  end;
end;

procedure TInfoFile.LoadPlatforms(const APlatforms: string);
var
  LPlatforms: TStringDynArray;
  LPlatformString: string;
  LPlatform: TDNCompilerPlatform;
begin
  FPlatforms := [];
  LPlatforms := SplitString(APlatforms, ';');
  for LPlatformString in LPlatforms do
  begin
    if TryPlatformNameToCompilerPlatform(LPlatformString, LPlatform) then
      Include(FPlatforms, LPlatform);
  end;
  if FPlatforms = [] then
    Include(FPlatforms, cpWin32);
end;

function TInfoFile.ReadID(const AObject: TJSONObject): TGUID;
var
  LID: string;
begin
  LID := ReadString(AObject, 'id');
  try
    if LID <> '' then
      Result := StringToGUID(LID)
    else
      Result := TGUID.Empty;
  except
    Result := TGUID.Empty;
  end;
end;

procedure TInfoFile.Save(const ARoot: TJSONObject);
var
  LDependencies: TJSONArray;
begin
  inherited;
  WritePath(ARoot, 'picture', FPicture);
  WriteString(ARoot, 'id', FID.ToString);
  WriteString(ARoot, 'name', FName);
  WriteString(ARoot, 'license_type', FLicenseType);
  WritePath(ARoot, 'license_file', FLicenseFile);
  WriteString(ARoot, 'first_version', FFirstVersion);
  WriteFloat(ARoot, 'package_compiler_max', FPackageCompilerMax);
  WriteFloat(ARoot, 'package_compiler_min', FPackageCompilerMin);
  WriteFloat(ARoot, 'compiler_min', FCompilerMin);
  WriteFloat(ARoot, 'compiler_max', FCompilerMax);
  WriteString(ARoot, 'platforms', GetPlatformString());
  LDependencies := WriteArray(ARoot, 'dependencies');
  SaveDependencies(LDependencies);
end;

procedure TInfoFile.SaveDependencies(const ADependencies: TJSONArray);
var
  LObject: TJSONObject;
  LDependency: TInfoDependency;
begin
  for LDependency in FDependencies do
  begin
    LObject := WriteArrayObject(ADependencies);
    WriteString(LObject, 'id', LDependency.ID.ToString);
    WriteString(LObject, 'version_min', LDependency.Version.ToString);
  end;
end;

end.
