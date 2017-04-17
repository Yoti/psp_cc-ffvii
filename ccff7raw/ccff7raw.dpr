program ccff7raw;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes, // TStream*
  Windows; // SetConsoleTitle

var
  i: Cardinal;
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

procedure Dump(From: TFileStream; Name: String; Offset, Size: Cardinal);
var
  TempOffset: Cardinal;
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(Name, fmCreate);
  TempOffset:=From.Position;
  From.Seek(Offset, soFromBeginning);
    OutputFile.CopyFrom(From, Size);
  From.Seek(TempOffset, soFromBeginning);
  OutputFile.Free;
end;

procedure Title;
begin
         //123456789_123456789_123456789_12345
  WriteLn('***********************************');
  WriteLn('* Crisis Core -Final Fantasy VII- *');
  WriteLn('*  Chunk Files Extractor by Yoti  *');
  WriteLn('***********************************');
end;

begin
  SetConsoleTitle(PChar(ExtractFileName(ParamStr(0))));
  Title;

  if not (FileExists(ParamStr(1)))
  then Exit('File not found');

  if not (FileExists(ChangeFileExt(ParamStr(1), '.lst')))
  then Exit('Table not found');

  LST:=TStringList.Create;
  LST.LoadFromFile(ChangeFileExt(ParamStr(1), '.lst'));
  RAW:=TFileStream.Create(ParamStr(1), fmOpenRead);
    //WriteLn(' #' + IntToStr(LST.Count));
    if (LST.Count < 2)
    then Exit('Empty table');

    for i:=0 to LST.Count-1 do begin
      //WriteLn(' >' + LST.Strings[i] + ' (' + IntToStr(Length(LST.Strings[i])) + ')');
      if (Length(LST.Strings[i]) <> 17)
      then Exit('Bad table');

      //WriteLn(' >>' + Copy(LST.Strings[i], 1, 8));
      //WriteLn(' >>' + Copy(LST.Strings[i], 10, 8));
      Dump(RAW,
          ExtractFileNameEx(ParamStr(1)) + '_' + IntToStrEx(i, 8) + '.chk',
          StrToInt('$' + Copy(LST.Strings[i], 1, 8)),
          StrToInt('$' + Copy(LST.Strings[i], 10, 8)));

      WriteLn(ExtractFileNameEx(ParamStr(1)) + '_' + IntToStrEx(i, 8) + '.chk');
    end;
  LST.Free;
  RAW.Free;

  Exit('Done');
end.
