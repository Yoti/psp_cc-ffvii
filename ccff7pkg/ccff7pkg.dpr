program ccff7pkg;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  StrUtils, // AnsiIndexStr
  Classes,  // TStream*
  Windows;  // SetConsoleTitle

const
  SECTOR: Cardinal = $800;
  PADDING: Cardinal = $00000000;

  IN_EXT: String = '.raw';
  IN_DIR: String = 'output\';
  OUT_FSE_TABLE: String = 'discimg_new.fse';
  OUT_PKG_FILES: String = 'discimg_new.pkg';

var
  NAME: Cardinal;   // us=0..24022, eu=0..11048, jp=0..?????
  COUNT: Cardinal;  // us=8726, eu=8734, jp=????
  REAL_COUNT: Cardinal;

  FNAME: String;
  FSIZE: Cardinal;
  FPADDING: Cardinal;

  OFFSET: Cardinal;
  NUMBER: Cardinal;

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

procedure AddToTable(atStream: TFileStream; atOffset, atSize, atPadding: Cardinal);
begin
  atStream.Write(atOffset, 4);
  atStream.Write(atSize, 4);
  atStream.Write(atPadding, 4);
end;

procedure AddToFiles(atStream: TFileStream; atFile: String; atSize, atPadding: Cardinal);
var
  LoadByte: Array[0..2048] of Byte;
  LoadFile: TFileStream;
begin
  FillChar(LoadByte, SECTOR, $00);

  LoadFile:=TFileStream.Create(atFile, fmOpenRead);
    atStream.CopyFrom(LoadFile, atSize);
    if (atPadding <> 0) // почти уверен, что это так всегда
    then atStream.WriteBuffer(LoadByte, atPadding);
  LoadFile.Free;
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
  WriteLn('* Crisis Core: Final Fantasy VII  *');
  WriteLn('* Game Archive RePackager by Yoti *');
  WriteLn('***********************************');
end;

begin
  SetConsoleTitle(PChar(ExtractFileName(ParamStr(0))));
  Title;

  if (ParamCount < 1)
  then Exit('Region not specified');

  NAME:=0;
  COUNT:=0;
  case AnsiIndexStr(LowerCase(ParamStr(1)), ['eu', 'jp', 'us']) of
    0: begin NAME:=11048; COUNT:=8734; end; // eu
    1: Exit('Unsupported region'); // jp
    2: begin NAME:=24022; COUNT:=8726; end; // us
    else Exit('Unknown region');
  end;

  if not (DirectoryExists(IN_DIR))
  then Exit('Source dir not found');

  OFFSET:=0;
  REAL_COUNT:=0;
  PKG:=TFileStream.Create(OUT_PKG_FILES, fmCreate);
  FSE:=TFileStream.Create(OUT_FSE_TABLE, fmCreate);
  for NUMBER:=0 to NAME do begin
    FNAME:=IN_DIR + IntToStrEx(NUMBER, 8) + IN_EXT;
    if FileExists(FNAME)
    then begin
      Inc(REAL_COUNT);

      Write('NUM=' + IntToStrEx(NUMBER, 8) + ' ');
      Write('OFF=' + IntToHex(OFFSET, 8) + ' ');
      FSIZE:=Size(IN_DIR + IntToStrEx(NUMBER, 8) + IN_EXT);
      Write('LEN=' + IntToHex(FSIZE, 8) + ' ');
      //Write('PAD=' + IntToStrEx(PADDING, 8) + ' ');
      WriteLn;

      AddToTable(FSE, OFFSET, FSIZE, PADDING);

      if ((FSIZE mod $800) <> 0)
      then FPADDING:=(SECTOR * ((FSIZE div $800) + 1)) - FSIZE
      else FPADDING:=0;
      AddToFiles(PKG, FNAME, FSIZE, FPADDING);

      if (FSIZE mod SECTOR = 0)
      then OFFSET:=OFFSET + (FSIZE div SECTOR) // размер ровно в N секторов
      else OFFSET:=OFFSET + ((FSIZE div SECTOR) + 1);
    end
    else begin
      FSIZE:=0;
      Write('NUM=' + IntToStrEx(NUMBER, 8) + ' ');
      Write('OFF=' + IntToHex(OFFSET, 8) + ' ');
      Write('LEN=' + IntToHex(FSIZE, 8) + ' ');
      //Write('PAD=' + IntToStrEx(PADDING, 8) + ' ');
      WriteLn;
      AddToTable(FSE, OFFSET, FSIZE, PADDING);
    end;
  end;
  FSE.Free;
  PKG.Free;

  if (REAL_COUNT <> COUNT)
  then Exit('Error')
  else Exit('Done');
end.
