pascal
unit untDataSender;

interface

uses
  Winapi.Windows, System.SysUtils, ShellAPI;

procedure sendData(ativo: boolean; tempoDecorrido: TTime);

implementation

procedure sendData(ativo: boolean; tempoDecorrido: TTime);
var
  str: string;
  comando: Array [0 .. 1024] of Char;
  argumentos: Array [0 .. 1024] of Char;
begin
  StrPCopy(comando, 'sender.exe');
  str := 'send -a' + LowerCase(BoolToStr(ativo, true)) + ' -t "' + TimeToStr(tempoDecorrido) + '"';

  StrPCopy(argumentos, str);
  ShellExecute(0, nil, comando, argumentos, nil, SW_HIDE);
end;

end.