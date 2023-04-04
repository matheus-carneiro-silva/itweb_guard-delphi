unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.Imaging.pngimage;

type
  TMouseHookProc = function(nCode: Integer; wParam: wParam; lParam: lParam)
    : LRESULT; stdcall;

  TKeyHookProc = function(nCode: Integer; wParam: wParam; lParam: lParam)
    : LRESULT; stdcall;

  TfrmPrincipal = class(TForm)
    Label1: TLabel;
    lblSoftware: TLabel;
    tmrPrincipal: TTimer;
    Label2: TLabel;
    lblMouse: TLabel;
    tmrMouse: TTimer;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Fechar1: TMenuItem;
    lblTempo: TLabel;
    tmrSegundo: TTimer;
    Image1: TImage;
    lblTitulo: TLabel;
    Image2: TImage;
    procedure tmrPrincipalTimer(Sender: TObject);
    procedure tmrMouseTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Fechar1Click(Sender: TObject);
    procedure tmrSegundoTimer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  WH_MOUSE_LL = 14;
  WM_MOUSEMOVE = $200;
  WH_KEYBOARD_LL = 13;
  WM_KEYDOWN = $100;

var
  frmPrincipal: TfrmPrincipal;
  software: boolean;
  mouse: boolean;
  MouseHookHandle: HHOOK;
  KeyHookHandle: HHOOK;
  tempoRestante: TTime;
implementation

{$R *.dfm}


function ArrayToString(const a: array of Char): string;
begin
  if Length(a) > 0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

procedure RestartTimer(Timer: TTimer);
begin
  Timer.Enabled := false;
  Timer.Enabled := true;
end;

function EnumWindowsFunc(Handle: THandle): boolean; stdcall;
var
  caption: array [0 .. 256] of Char;
  texto: string;
begin
  if GetWindowText(Handle, caption, SizeOf(caption) - 1) <> 0 then
  begin
    texto := ArrayToString(caption);
    if texto.Contains('Photoshop.exe') or texto.Contains('AfterFX.exe') or
      texto.Contains('Adobe Premiere Pro.exe') then
      software := true;
  end;

  Result := true;
end;

function KeyHookProc(nCode: Integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
begin
  if (nCode >= 0) and (wParam = WM_KEYDOWN) then
  begin
    mouse := true;
    RestartTimer(frmPrincipal.tmrMouse);
  end;
  Result := CallNextHookEx(KeyHookHandle, nCode, wParam, lParam);
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

function MouseHookProc(nCode: Integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
var
  CursorPos: TPoint;
begin
  if (nCode >= 0) and (wParam = WM_MOUSEMOVE) then
  begin
    CursorPos := PMouseHookStruct(lParam)^.pt;
    mouse := true;
    RestartTimer(frmPrincipal.tmrMouse);
  end;
  Result := CallNextHookEx(MouseHookHandle, nCode, wParam, lParam);
end;

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

procedure TfrmPrincipal.Fechar1Click(Sender: TObject);
begin
  Application.Terminate;
end;


procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;
  Self.Hide;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  mouse := true;
  InstallMouseHook;
  InstallKeyHook;

  SetWindowLong(Application.Handle, GWL_EXSTYLE,GetWindowLong(Application.Handle, GWL_EXSTYLE) or
WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);

  tempoRestante := StrToTime('08:00:00');
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  UninstallMouseHook;
  UninstallKeyHook;
end;

procedure TfrmPrincipal.tmrSegundoTimer(Sender: TObject);
const
  segundo = '00:00:01';
begin
  if mouse and software then
    tempoRestante := tempoRestante - StrToTime(segundo);

  lblTempo.Caption := TimeToStr(tempoRestante);
end;

procedure TfrmPrincipal.TrayIcon1DblClick(Sender: TObject);
begin
  frmPrincipal.Show;
end;

procedure TfrmPrincipal.tmrMouseTimer(Sender: TObject);
begin
  mouse := false;
end;

procedure TfrmPrincipal.tmrPrincipalTimer(Sender: TObject);
begin
  software := false;
  EnumWindows(@EnumWindowsFunc, 0);
  if software then
    lblSoftware.caption := 'Sim'
  else
    lblSoftware.caption := 'N�o';

  if mouse then
    lblMouse.caption := 'Sim'
  else
    lblMouse.caption := 'N�o';
end;

end.
