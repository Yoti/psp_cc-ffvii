program ccff7ext;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes, // TStream*
  Windows; // SetConsoleTitle

const
  IN_EXT: String = '.raw';

var
  n: String;
  i, k: Cardinal;
  EXT: TFileStream;

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
  WriteLn('* Game Resource Analyzer by Yoti  *');
  WriteLn('***********************************');
end;

begin
  SetConsoleTitle(PChar(ExtractFileName(ParamStr(0))));
  if (ParamStr(2) <> 'silent')
  and (ParamStr(2) <> 'verysilent')
  then Title;

  if not (FileExists(ParamStr(1)))
  then Exit('Nothing to do');

  n:=IN_EXT;
  EXT:=TFileStream.Create(ParamStr(1), fmOpenRead);
    EXT.Read(i, SizeOf(Cardinal));

    case i of
      $6C657441: n:='.atl'; // raw:4174656C - ���������� ���� "chunk"
      $464D5350: n:='.pmf'; // raw:50534D46 - ����� "video"
      $46464952: n:='.at3'; // raw:52494646 - ������ "voice"
      $46435353: n:='.ssc'; // raw:53534346 - ������ "music"
      $474E5089: n:='.png'; // raw:89504E47 - ������� �������� "image"
      $0044424D: n:='.mbd'; // raw:4D424400 - ��������� ����� "texts"
      $02005447: n:='.gtf'; // raw:47540002 - �������� 256 ������ (1bpp) "image"
      $00000000: n:='.mdl'; // raw:00000000 - ������ "model"
      else n:=IN_EXT;
    end;

    if (n = IN_EXT) then begin
      for k:=1 to 64 do begin
        EXT.Read(i, SizeOf(Cardinal));
        EXT.Seek(i, soFromBeginning);
        EXT.Read(i, SizeOf(Cardinal));
        if (i = $00474D49) // raw:494D4700
        then n:='.imp'; // "image package"
      end;
    end;
  EXT.Free;

  if (ParamStr(2) <> 'verysilent')
  then begin
    Write(ExtractFileName(ParamStr(1)));
    Write(' -> ');
    if (n = IN_EXT)
    then WriteLn('unknown!')
    else WriteLn(ChangeFileExt(ParamStr(1), n));
  end;

  if (n <> IN_EXT)
  then RenameFile(ParamStr(1), ChangeFileExt(ParamStr(1), n));
end.
