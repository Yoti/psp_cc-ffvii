program ccff7ext;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes, // TStream*
  Windows; // SetConsoleTitle

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

  n:='.raw';
  EXT:=TFileStream.Create(ParamStr(1), fmOpenRead);
    EXT.Read(i, SizeOf(Cardinal));

    case i of
      $6C657441: n:='.atl'; // raw:4174656C - кусочковый файл "chunk"
      $464D5350: n:='.pmf'; // raw:50534D46 - видео "video"
      $46464952: n:='.at3'; // raw:52494646 - голоса "voice"
      $46435353: n:='.ssc'; // raw:53534346 - музыка "music"
      $474E5089: n:='.png'; // raw:89504E47 - обычные картинки "image"
      $0044424D: n:='.mbd'; // raw:4D424400 - текстовые файлы "texts"
      $02005447: n:='.gtf'; // raw:47540002 - картинка 256 цветов (1bpp) "image"
      $00000000: n:='.mdl'; // raw:00000000 - модель "model"
      else n:='.raw';
    end;

    if (n = '.raw') then begin
      for k:=1 to 64 do begin
        EXT.Read(i, SizeOf(Cardinal));
        if (i = $00474D49)
        and (k mod 4 = 1)
        then n:='.img'; // "image"
      end;
    end;
  EXT.Free;

  if (n <> '.raw') then begin
    if (ParamStr(2) <> 'verysilent')
    then begin
      Write(ExtractFileName(ParamStr(1)));
      Write(' -> ');
      WriteLn(ChangeFileExt(ParamStr(1), n));
    end;
    RenameFile(ParamStr(1), ChangeFileExt(ParamStr(1), n));
  end;
end.
