pascal
unit untAppDetection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes;

procedure checkWindows(MonitoredApplications: TStringDynArray; var software : boolean; setSoftware : procedure(state : boolean));

implementation

uses untConfig, untPrincipal;

function EnumWindowsFunc(Handle: THandle; var achou: boolean; MonitoredApplications: TStringDynArray): boolean; stdcall;
var
  caption: array [0 .. 256] of Char;
  texto: string;
  i: integer;

begin
  if GetWindowText(Handle, caption, SizeOf(caption) - 1) <> 0 then
  begin
    texto := ArrayToString(caption);
    for i := 0 to High(MonitoredApplications) do
      if texto.Contains(MonitoredApplications[i]) then
        achou := true;
  end;

  Result := true;
end;

procedure checkWindows(MonitoredApplications: TStringDynArray; var software : boolean; setSoftware : procedure(state : boolean));
var
  achou: boolean;
begin
  achou := false;

  EnumWindows(@EnumWindowsFunc, LParam(@achou), LParam(@MonitoredApplications));

  if achou then
  begin
    if not software then
      setSoftware(true);
  end
  else
  begin
    if software then
      setSoftware(false);
  end;
end;

end.