program IGuard;

uses
  Vcl.Forms,
  untPrincipal in 'untPrincipal.pas' {frmPrincipal},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'IGuard';
  TStyleManager.TrySetStyle('Windows10');
  Application.Showmainform := False;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
