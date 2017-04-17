program ccff7chk;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes, // TStream*
  Windows; // SetConsoleTitle

var
  i: Cardinal;
  CHK: TFileStream;
  RAW: TFileStream;
  LST: TStringList;

function ExtractFileNameEx(filepath: String): String;
begin
  ExtractFileNameEx:=Copy(ExtractFileName(filepath),
                          1,
                          Length(ExtractFileName(filepath)) -
                          Length(ExtractFileExt(filepath)));
end;

function IntToStrEx(int, len: Integer): String;
var
  s: String;
  i: Integer;
begin
  s:=IntToStr(int);
  for i:=Length(s) to len-1 do
    begin
      s:='0'+s;
    end;
  IntToStrEx:=s;
end;

procedure Exit(UserText: String);
begin
  WriteLn(UserText + ', press Enter to close window');
  ReadLn;
  Halt;
end;

procedure Title;
begin
         //123456789_123456789_123456789_12345
  WriteLn('***********************************');
  WriteLn('* Crisis Core -Final Fantasy VII- *');
  WriteLn('*  Chunk Files RePacker by Yoti   *');
  WriteLn('***********************************');
end;

begin
  SetConsoleTitle(PChar(ExtractFileName(ParamStr(0))));
  Title;

  if not (FileExists(ParamStr(1)))
  then Exit('Table not found');

  LST:=TStringList.Create;
  LST.LoadFromFile(ParamStr(1));
  RAW:=TFileStream.Create(ChangeFileExt(ParamStr(1), '_new.raw'), fmCreate);
    for i:=0 to LST.Count-1 do begin
      WriteLn(ExtractFileNameEx(ParamStr(1)) + '_' + IntToStrEx(i, 8) + '.chk');
      CHK:=TFileStream.Create(ExtractFileNameEx(ParamStr(1)) + '_' + IntToStrEx(i, 8) + '.chk', fmOpenRead);
      RAW.CopyFrom(CHK, CHK.Size);
      CHK.Free;
    end;
  RAW.Free;
  LST.Free;

  Exit('Done');
end.
