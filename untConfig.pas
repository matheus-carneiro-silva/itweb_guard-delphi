pas
unit untConfig;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.JSON;

type
  TConfig = class
  public
    class function read_config_file(): TStringDynArray;
    class procedure write_config_file(applications: TStringDynArray);
    class function read_applications_from_api(): TStringDynArray;
    class procedure write_applications_to_api(applications: TStringDynArray);
  end;

implementation

{ TConfig }

class function TConfig.read_applications_from_api: TStringDynArray;
var
  applicationsText: string;
  applicationsList: TStringDynArray;
begin
  Result := [];
  if FileExists('api_applications.txt') then
  begin
    applicationsText := TFile.ReadAllText('api_applications.txt');
    applicationsList := applicationsText.Split([';']);
    for var i := 0 to High(applicationsList) do
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := applicationsList[i];
    end;
  end
  else
  begin
    TFile.WriteAllText('api_applications.txt', '');
  end;
end;

class function TConfig.read_config_file: TStringDynArray;
var
  jsonText: string;
  jsonObject: TJSONObject;
  jsonArray: TJSONArray;
  i: Integer;
begin
  Result := [];
  if FileExists('config.json') then
  begin
    jsonText := TFile.ReadAllText('config.json');
    jsonObject := TJSONObject.ParseJSONValue(jsonText) as TJSONObject;
    jsonArray := jsonObject.GetValue('monitored_applications') as TJSONArray;

    for i := 0 to jsonArray.Count - 1 do
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := jsonArray.Items[i].Value;
    end;
    jsonObject.Free;
  end
  else
  begin
    write_config_file(['Photoshop.exe', 'AfterFX.exe', 'Adobe Premiere Pro.exe']);
    result := read_config_file();
  end;
end;

class procedure TConfig.write_applications_to_api(applications: TStringDynArray);
var
  i: Integer;
begin
  if FileExists('api_applications.txt') then
  begin
    TFile.Delete('api_applications.txt');
  end;
  for i := 0 to Length(applications) - 1 do
  begin
    TFile.AppendAllText('api_applications.txt', applications[i] + ';');
  end;
  write_config_file(applications);
end;

class procedure TConfig.write_config_file(applications: TStringDynArray);
var
  jsonObject: TJSONObject;
  jsonArray: TJSONArray;
  i: Integer;
begin
  jsonObject := TJSONObject.Create;
  jsonArray := TJSONArray.Create;

  for i := 0 to Length(applications) - 1 do
  begin
    jsonArray.Add(TJSONString.Create(applications[i]));
  end;

  jsonObject.AddPair('monitored_applications', jsonArray);
  TFile.WriteAllText('config.json', jsonObject.ToString);
  jsonObject.Free;
end;

end.