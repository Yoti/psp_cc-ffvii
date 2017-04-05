program ccff7mbd;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes, // TStream*
  Windows; // SetConsoleTitle

const
  BASE_SIG: Cardinal = $4D424400;
  TEXT_SIG: Cardinal = $4D42447E;

var
  SIG: Cardinal;
  IN_: TFileStream;

function Swap(Value: Cardinal): Cardinal;
asm
  bswap eax
end;

procedure Exit(UserText: String);
begin
  WriteLn(UserText + ', press Enter to close window');
  ReadLn;
  Halt;
end;

function Size(FilePath: String): Cardinal;
var
  f: TFileStream;
begin
  f:=TFileStream.Create(FilePath, fmOpenRead);
    Size:=f.Size;
  f.Free;
end;

function set_4005xxxx(s: String): Cardinal;
begin
  set_4005xxxx:=$40050000 + StrToInt(Copy(s, 9, 1));
end;

function get_4005xxxx(c: Cardinal): String;
begin
  get_4005xxxx:=(
    '<choise_' +
    IntToStr(StrToInt('$' + Copy(inttohex(c, 8), 7, 2)) + 1) +
    'vars>'
  );
end;

function Encode(Str: String): Cardinal;
begin
  Encode:=0;
end;

function Decode(Char: Cardinal): String;
begin
  case Swap(Char) of
    $4D424400: Decode:='MBD~';

    $80000000: Decode:='A';
    $80000100: Decode:='B';
    $80000200: Decode:='C';
    $80000300: Decode:='D';
    $80000400: Decode:='E';
    $80000500: Decode:='F';
    $80000600: Decode:='G';
    $80000700: Decode:='H';
    $80000800: Decode:='I';
    $80000900: Decode:='J';
    $80000A00: Decode:='K';
    $80000B00: Decode:='L';
    $80000C00: Decode:='M';
    $80000D00: Decode:='N';
    $80000E00: Decode:='O';
    $80000F00: Decode:='P';
    $80001000: Decode:='Q';
    $80001100: Decode:='R';
    $80001200: Decode:='S';
    $80001300: Decode:='T';
    $80001400: Decode:='U';
    $80001500: Decode:='V';
    $80001600: Decode:='W';
    $80001700: Decode:='X';
    $80001800: Decode:='Y';
    $80001900: Decode:='Z';
    $80001A00: Decode:='a';
    $80001B00: Decode:='b';
    $80001C00: Decode:='c';
    $80001D00: Decode:='d';
    $80001E00: Decode:='e';
    $80001F00: Decode:='f';
    $80002000: Decode:='g';
    $80002100: Decode:='h';
    $80002200: Decode:='i';
    $80002300: Decode:='j';
    $80002400: Decode:='k';
    $80002500: Decode:='l';
    $80002600: Decode:='m';
    $80002700: Decode:='n';
    $80002800: Decode:='o';
    $80002900: Decode:='p';
    $80002A00: Decode:='q';
    $80002B00: Decode:='r';
    $80002C00: Decode:='s';
    $80002D00: Decode:='t';
    $80002E00: Decode:='u';
    $80002F00: Decode:='v';
    $80003000: Decode:='w';
    $80003100: Decode:='x';
    $80003200: Decode:='y';
    $80003300: Decode:='z';
    $80003400: Decode:='0';
    $80003500: Decode:='1';
    $80003600: Decode:='2';
    $80003700: Decode:='3';
    $80003800: Decode:='4';
    $80003900: Decode:='5';
    $80003A00: Decode:='6';
    $80003B00: Decode:='7';
    $80003C00: Decode:='8';
    $80003D00: Decode:='9';
    $80003E00: Decode:='!';
    $80003F00: Decode:='?';
    $80004000: Decode:=' '; // ������
    $80004100: Decode:='"';
    $80004200: Decode:=''''; // '
    $80004300: Decode:=',';
    $80004400: Decode:='.';
    $80004500: Decode:=':';
    $80004600: Decode:=';';
    $80004700: Decode:='-';
    $80004800: Decode:='/';
    $80004900: Decode:='(';
    $80004A00: Decode:=')';
    $80004B00: Decode:='&';
    $80004C00: Decode:='<';
    $80004D00: Decode:='>';
    $80004E00: Decode:='%';
    $80004F00: Decode:='[';
    $80005000: Decode:=']';
    $80005100: Decode:='�'; // ����
    $80005200: Decode:='+';
    $80005300: Decode:='#';
    $80005400: Decode:='_';
    $80005500: Decode:='|';
    $80005600: Decode:='^';
    $80005700: Decode:='�';
    $80005800: Decode:='~';
    $80005900: Decode:='*';
    $80005A00: Decode:='=';
    $80005B00: Decode:='�'; // ������
    $80005C00: Decode:='�'; // ������
    $80005D00: Decode:='�'; // �C
    $80005E00: Decode:='�'; // cm
    $80005F00: Decode:='@'; // �����������

    $40270000: Decode:='<btn_cross>';
    $40290000: Decode:='<btn_triangle>';
    $402A0000: Decode:='<btn_square>';

    $01000000: Decode:='<block>'; // ����?
    $0C000000: Decode:='<begin>'+#13#10; // �����

    $40020000: Decode:=#13#10+'<newstr>'+#13#10; // ������� ������
    $40050001..$40050009: Decode:=get_4005xxxx(Swap(Char))+#13#10; // �������� ������
    $40040000: Decode:='<end>'; // �����

    else Decode:=IntToHex(Char, 8);
  end;
end;

procedure ToText(FilePath: String);
var
  s: String;
  i: Cardinal;
  len: Cardinal;
  out_: TStringList;
  in_Char: Cardinal;
begin
  IN_:=TFileStream.Create(FilePath, fmOpenRead);
  out_:=TStringList.Create;
  while (IN_.Position < IN_.Size) do begin
    IN_.Read(in_Char, SizeOf(Cardinal));
    if (in_Char = Swap($01000000))
    then begin
      out_.Add('<block>');
      IN_.Read(len, SizeOf(Cardinal));
      s:='';
      for i:=0 to len-1 do begin
        IN_.Read(in_Char, SizeOf(Cardinal));
        s:=s+Decode(in_Char);
      end;
      out_.Add(s);
    end
    else out_.Add(Decode(in_Char));
  end;
  out_.SaveToFile(ChangeFileExt(FilePath, '.txt'));
  out_.Free;
  IN_.Free;

  Exit('Done');
end;

procedure Title;
begin
         //123456789_123456789_123456789_12345
  WriteLn('***********************************');
  WriteLn('* Crisis Core -Final Fantasy VII- *');
  WriteLn('*   MDB Database Editor by Yoti   *');
  WriteLn('***********************************');
end;

begin
  SetConsoleTitle(PChar(ExtractFileName(ParamStr(0))));
  Title;

  if (ParamCount() < 1)
  then Exit('No input file');

  if not (FileExists(ParamStr(1)))
  then Exit('No input file');

  IN_:=TFileStream.Create(ParamStr(1), fmOpenRead);
    IN_.Read(SIG, SizeOf(Cardinal));
  IN_.Free;

  if (Swap(SIG) = BASE_SIG)
  then ToText(ParamStr(1))
  else if (Swap(SIG) = TEXT_SIG)
  then WriteLn('debug: text')
  else Exit('Unknown file');

  ReadLn;
end.
