program ccff7unp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes, // TStream*
  Windows; // SetConsoleTitle

const
  SECTOR: Cardinal = $800;

  IN_DIR: String = 'USRDIR\';
  OUT_DIR: String = 'discimg\';
  OUT_EXT: String = '.raw';

  FSE_TABLE: String = 'discimg.fse';
  PKG_FILES: String = 'discimg.pkg';

var
  Start: Cardinal;
  Padding: Cardinal;
  FileSize: Cardinal;

  Count: Integer;
  Files: Cardinal;
  RealCount: Cardinal;

  FSE: TFileStream;
  PKG: TFileStream;

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

function Size(FilePath: String): Cardinal;
var
  f: TFileStream;
begin
  f:=TFileStream.Create(FilePath, fmOpenRead);
    Size:=f.Size;
  f.Free;
end;

procedure Title;
begin
         //123456789_123456789_123456789_12345
  WriteLn('***********************************');
  WriteLn('* Crisis Core -Final Fantasy VII- *');
  WriteLn('* Game Archive Extractor by Yoti  *');
  WriteLn('***********************************');
end;

begin
  SetConsoleTitle(PChar(ExtractFileName(ParamStr(0))));
  Title;

  if not (FileExists(IN_DIR + FSE_TABLE))
  then Exit('Table not found');

  if not (FileExists(IN_DIR + PKG_FILES))
  then Exit('Files not found');

  if (ParamCount = 0) then begin
    if (DirectoryExists(OUT_DIR))
    then Exit('Already unpacked');
  end;

  if not (DirectoryExists(OUT_DIR))
  then MkDir(OUT_DIR);

  if ((Size(IN_DIR + FSE_TABLE) mod 12) <> 0)
  then Exit('Bad table');

  Files:=Round(Size(IN_DIR + FSE_TABLE)/12);

  FSE:=TFileStream.Create(IN_DIR + FSE_TABLE, fmOpenRead);
  PKG:=TFileStream.Create(IN_DIR + PKG_FILES, fmOpenRead);
  RealCount:=0;
  for Count:=0 to Files-1 do begin
    Write('NUM=' + IntToStrEx(Count, 8) + ' ');
    FSE.Read(Start, 4);
    Write('OFF=' + IntToHex(Start, 8) + ' ');
    FSE.Read(FileSize, 4);
    Write('LEN=' + IntToHex(FileSize, 8) + ' ');
    FSE.Read(Padding, 4);
    //Write('PAD=' + IntToHex(Temp, 8));
    WriteLn;

    if (FileSize > 0)
    then begin
      Inc(RealCount);

	  if (ParamCount = 0)
    then Dump(PKG,
          OUT_DIR + IntToStrEx(Count, 8) + OUT_EXT,
          Start * SECTOR,
          FileSize)
    else if (StrToInt(ParamStr(1)) = Count)
    then Dump(PKG,
          OUT_DIR + IntToStrEx(Count, 8) + OUT_EXT,
          Start * SECTOR,
          FileSize);
    end;
  end;
  PKG.Free;
  FSE.Free;

  Exit(IntToStr(RealCount));
end.
