unit untIP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Winsock;

const
  ANY_SIZE = 1;

type
  PTMibIPAddrRow = ^TMibIPAddrRow;

  TMibIPAddrRow = packed record
    dwAddr: DWORD;
    dwIndex: DWORD;
    dwMask: DWORD;
    dwBCastAddr: DWORD;
    dwReasmSize: DWORD;
    Unused1, Unused2: WORD;
  end;

  PTMibIPAddrTable = ^TMibIPAddrTable;

  TMibIPAddrTable = packed record
    dwNumEntries: DWORD;
    Table: array [0 .. ANY_SIZE - 1] of TMibIPAddrRow;
  end;

  TIp = class(TObject)
  public
    class procedure Get_IPAddrTable(Tipo: integer; List: TStrings);
  end;

implementation

function GetIpAddrTable(pIpAddrTable: PTMibIPAddrTable; pdwSize: PULONG;
  bOrder: BOOL): DWORD; stdcall; external 'IPHLPAPI.DLL';

{ converts IP-address in network byte order DWORD to dotted decimal string }
function IpAddr2Str(IPAddr: DWORD): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to 4 do
  begin
    Result := Result + Format('%3d.', [IPAddr and $FF]);
    IPAddr := IPAddr shr 8;
  end;
  Delete(Result, Length(Result), 1);
end;

class procedure TIp.Get_IPAddrTable(Tipo: integer; List: TStrings);
var
  IPAddrRow: TMibIPAddrRow;
  TableSize: DWORD;
  ErrorCode: DWORD;
  i: integer;
  pBuf: PChar;
  NumEntries: DWORD;
begin
  if not Assigned(List) then
    EXIT;
  List.Clear;
  TableSize := 0;
  // first call: get table length
  ErrorCode := GetIpAddrTable(PTMibIPAddrTable(pBuf), @TableSize, true);
  if ErrorCode <> ERROR_INSUFFICIENT_BUFFER then
    EXIT;

  GetMem(pBuf, TableSize);
  // get table
  ErrorCode := GetIpAddrTable(PTMibIPAddrTable(pBuf), @TableSize, true);
  if ErrorCode = NO_ERROR then
  begin
    NumEntries := PTMibIPAddrTable(pBuf)^.dwNumEntries;
    if NumEntries > 0 then
    begin
      inc(pBuf, SizeOf(DWORD));
      for i := 1 to NumEntries do
      begin
        Case Tipo of
          1:
            begin
              IPAddrRow := PTMibIPAddrRow(pBuf)^;
              { with IPAddrRow do
                begin
                List.Add(dwAddr.ToString);
                List.Add(dwMask.ToString);
                List.Add(dwBCastAddr.ToString);
                end; }

              List.Add('dwAddr: ' + IPAddrRow.dwAddr.ToString);
              List.Add('dwIndex: ' + IPAddrRow.dwIndex.ToString);
              List.Add('dwMask: ' + IPAddrRow.dwMask.ToString);
              List.Add('dwBCastAddr: ' + IPAddrRow.dwBCastAddr.ToString);
              List.Add('dwReasmSize: ' + IPAddrRow.dwReasmSize.ToString);
              List.Add('');

              {with IPAddrRow do
                List.Add(Format('%8.8x|%15s|%15s|%15s|%8.8d',
                  [dwIndex, IpAddr2Str(dwAddr), IpAddr2Str(dwMask),
                  IpAddr2Str(dwBCastAddr), dwReasmSize])); }
              inc(pBuf, SizeOf(TMibIPAddrRow));
            end;
          2:
            begin
              IPAddrRow := PTMibIPAddrRow(pBuf)^;
              List.Add(Format('%15s', [IpAddr2Str(IPAddrRow.dwAddr)]));
              inc(pBuf, SizeOf(TMibIPAddrRow));
            end;
          // 3 : //;
        end;
      end;
    end
    else
      List.Add('no entries.');
  end
  else
    List.Add(SysErrorMessage(ErrorCode));

  // we must restore pointer!
  dec(pBuf, SizeOf(DWORD) + NumEntries * SizeOf(IPAddrRow));
  FreeMem(pBuf);
end;

end.
