program ffccmbde;

{$APPTYPE CONSOLE}

uses
  SysUtils;

const
  SUCCESS = 0;
  NO_FILE = 1;
  UNKNOWN = 2;

var
  f: file;
  s: string;
  i: integer;
  c: cardinal;
  FileForScriptDump: textfile;
  NumberOfCharsInBlock: cardinal;

function get_4005xxxx(c: cardinal): string;
begin
  get_4005xxxx:=(
    '<choise_' +
    IntToStr(StrToInt('$' + Copy(inttohex(c, 8), 7, 2)) + 1) +
    'vars>'
  );
end;

function reverse(char: cardinal): cardinal;
begin
  reverse:=StrToInt(
    '$' +
    Copy(IntToHex(char, 8), 7, 2) +
    Copy(IntToHex(char, 8), 5, 2) +
    Copy(IntToHex(char, 8), 3, 2) +
    Copy(IntToHex(char, 8), 1, 2)
  );
end;

function translate(c: cardinal): string;
begin
  c:=reverse(c);

  case c of
    $80000000: s:='A';
    $80000100: s:='B';
    $80000200: s:='C';
    $80000300: s:='D';
    $80000400: s:='E';
    $80000500: s:='F';
    $80000600: s:='G';
    $80000700: s:='H';
    $80000800: s:='I';
    $80000900: s:='J';
    $80000A00: s:='K';
    $80000B00: s:='L';
    $80000C00: s:='M';
    $80000D00: s:='N';
    $80000E00: s:='O';
    $80000F00: s:='P';
    $80001000: s:='Q';
    $80001100: s:='R';
    $80001200: s:='S';
    $80001300: s:='T';
    $80001400: s:='U';
    $80001500: s:='V';
    $80001600: s:='W';
    $80001700: s:='X';
    $80001800: s:='Y';
    $80001900: s:='Z';
    $80001A00: s:='a';
    $80001B00: s:='b';
    $80001C00: s:='c';
    $80001D00: s:='d';
    $80001E00: s:='e';
    $80001F00: s:='f';
    $80002000: s:='g';
    $80002100: s:='h';
    $80002200: s:='i';
    $80002300: s:='j';
    $80002400: s:='k';
    $80002500: s:='l';
    $80002600: s:='m';
    $80002700: s:='n';
    $80002800: s:='o';
    $80002900: s:='p';
    $80002A00: s:='q';
    $80002B00: s:='r';
    $80002C00: s:='s';
    $80002D00: s:='t';
    $80002E00: s:='u';
    $80002F00: s:='v';
    $80003000: s:='w';
    $80003100: s:='x';
    $80003200: s:='y';
    $80003300: s:='z';
    $80003400: s:='0';
    $80003500: s:='1';
    $80003600: s:='2';
    $80003700: s:='3';
    $80003800: s:='4';
    $80003900: s:='5';
    $80003A00: s:='6';
    $80003B00: s:='7';
    $80003C00: s:='8';
    $80003D00: s:='9';
    $80003E00: s:='!';
    $80003F00: s:='?';
    $80004000: s:=' '; // пробел
    $80004100: s:='"';
    $80004200: s:=''''; // '
    $80004300: s:=',';
    $80004400: s:='.';
    $80004500: s:=':';
    $80004600: s:=';';
    $80004700: s:='-';
    $80004800: s:='/';
    $80004900: s:='(';
    $80004A00: s:=')';
    $80004B00: s:='&';
    $80004C00: s:='<';
    $80004D00: s:='>';
    $80004E00: s:='%';
    $80004F00: s:='[';
    $80005000: s:=']';
    $80005100: s:='{YENA}';
    $80005200: s:='+';
    $80005300: s:='#';
    $80005400: s:='_';
    $80005500: s:='|';
    $80005600: s:='^';
    $80005700: s:='{GRAD}';
    $80005800: s:='~';
    $80005900: s:='*';
    $80005A00: s:='=';
    $80005B00: s:='{STAR1}';
    $80005C00: s:='{STAR2}';
    $80005D00: s:='{GRADC}';
    $80005E00: s:='{CM}';
    $80005F00: s:='{TRIANGLE}';

    $01000000: s:='<block>'; // блок?
    $0C000000: s:='<begin>'; // текст

    $40020000: s:='<newstr>'+#13#10; // перенос строки
    $40050001..$40050009: s:=get_4005xxxx(c); // варианты ответа
    $40040000: s:='<end>'; // конец
    else s:='<'+inttohex(c, 8)+'>'; // неизвестный код
  end;

  translate:=s;
end;

begin
  WriteLn('Final Fantasy 7: Crisis Core mbd recoder by Yoti');

  if FileExists(ParamStr(1)) = True then
    begin
      AssignFile(f, ParamStr(1));
      Reset(f, 4);
      AssignFile(FileForScriptDump, ChangeFileExt(ParamStr(1), '_Script.txt'));
      ReWrite(FileForScriptDump);

      // читаем заголовок
      BlockRead(f, c, 1);
      if (c <> reverse($4D424400))
      then Halt(UNKNOWN);

      while not EOF(f) do
        begin
          // читаем маркер блока <block> (???)
          BlockRead(f, c, 1); //Write(FileForScriptDump, translate(c));
          // читаем количество символов в файле, включая 400х0000
          BlockRead(f, NumberOfCharsInBlock, 1);
          // читаем начало блока <begin> (<text>)
          BlockRead(f, c, 1); Write(FileForScriptDump, translate(c));

          for i:=1 to NumberOfCharsInBlock do
            begin
              BlockRead(f, c, 1);
              Write(FileForScriptDump, translate(c));
            end;
        end;

      CloseFile(f);
      CloseFile(FileForScriptDump);

      //WriteLn; ReadLn;
    end
  else Halt(NO_FILE);

  Halt(SUCCESS);
end.
