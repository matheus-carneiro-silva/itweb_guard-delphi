pascal
unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  untConfig, untHooks, untAppDetection, untDataSender,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, System.IOUtils, System.JSON,
  Vcl.Imaging.pngimage, ShellAPI;

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
  tempoDecorrido: TTime;
  MonitoredApplications: TStringDynArray;

implementation

{$R *.dfm}

procedure setMouse(state: boolean);
begin
  mouse := state;
  untDataSender.sendData(mouse and software, tempoDecorrido);
end;

procedure setSoftware(state: boolean);
begin
  software := state;
  untDataSender.sendData(mouse and software, tempoDecorrido);
end;

function ArrayToString(const a: array of Char): string;
var
  i : integer;
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
  setMouse(true);
  setSoftware(false);  
  untHooks.InstallMouseHook;
  untHooks.InstallKeyHook;

  SetWindowLong(Application.Handle, GWL_EXSTYLE,
    GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and
    not WS_EX_APPWINDOW);

  MonitoredApplications := untConfig.TConfig.read_config_file();
  var listApi : TStringDynArray;
  listApi := untConfig.TConfig.read_applications_from_api();
  untConfig.TConfig.write_applications_to_api(listApi);

  tempoDecorrido := StrToTime('00:00:00');
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  untDataSender.sendData(false, tempoDecorrido);
  untHooks.UninstallMouseHook;
  untHooks.UninstallKeyHook;
end;

procedure TfrmPrincipal.tmrSegundoTimer(Sender: TObject);
const
  segundo = '00:00:01';
begin
  if mouse and software then
    tempoDecorrido := tempoDecorrido + StrToTime(segundo);

  lblTempo.caption := TimeToStr(tempoDecorrido);
end;

procedure TfrmPrincipal.TrayIcon1DblClick(Sender: TObject);
begin
  frmPrincipal.Show;
end;

procedure TfrmPrincipal.tmrMouseTimer(Sender: TObject);
begin
  if mouse then
    setMouse(false);
end;

procedure TfrmPrincipal.tmrPrincipalTimer(Sender: TObject);
var
  res: boolean;
begin
  untAppDetection.checkWindows(MonitoredApplications, software, setSoftware);

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
