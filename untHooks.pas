pascal
unit untHooks;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Forms, untPrincipal;

procedure InstallMouseHook;
procedure UninstallMouseHook;
function MouseHookProc(nCode: Integer; wParam: wParam; lParam: lParam): LRESULT; stdcall;
procedure InstallKeyHook;
procedure UninstallKeyHook;
function KeyHookProc(nCode: Integer; wParam: wParam; lParam: lParam): LRESULT; stdcall;

implementation

uses Winapi.Windows;

var
  MouseHookHandle: HHOOK;
  KeyHookHandle: HHOOK;

procedure InstallMouseHook;
var
  ModuleHandle: HINST;
begin
  ModuleHandle := GetModuleHandle(nil);
  MouseHookHandle := SetWindowsHookEx(WH_MOUSE_LL, @MouseHookProc,
    ModuleHandle, 0);
end;

procedure UninstallMouseHook;
begin
  UnhookWindowsHookEx(MouseHookHandle);
end;

function MouseHookProc(nCode: Integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
var
  CursorPos: TPoint;
begin
  if (nCode >= 0) and (wParam = WM_MOUSEMOVE) then
  begin
    CursorPos := PMouseHookStruct(lParam)^.pt;
    if not mouse then
      setMouse(true);
    RestartTimer(frmPrincipal.tmrMouse);
  end;
  Result := CallNextHookEx(MouseHookHandle, nCode, wParam, lParam);
end;

procedure InstallKeyHook;
var
  ModuleHandle: HINST;
begin
  ModuleHandle := GetModuleHandle(nil);
  KeyHookHandle := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyHookProc,
    ModuleHandle, 0);
end;

procedure UninstallKeyHook;
begin
  UnhookWindowsHookEx(KeyHookHandle);
end;

function KeyHookProc(nCode: Integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
begin
  if (nCode >= 0) and (wParam = WM_KEYDOWN) then
  begin
    if not mouse then
      setMouse(true);
    RestartTimer(frmPrincipal.tmrMouse);
  end;
  Result := CallNextHookEx(KeyHookHandle, nCode, wParam, lParam);
end;

end.