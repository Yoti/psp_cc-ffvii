program ffccchxt;

{$APPTYPE CONSOLE}
//{$R *.res}

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

function GetParamStr(str: string): Boolean;
var
  i: Byte;
  r: Boolean;
begin
  r:=False;

  if (ParamCount() > 1)
  then
    for i:=2 to ParamCount() do
      begin
        if ParamStr(i) = str
        then r:=True;
      end;

  GetParamStr:=r;
end;

begin
  // режимы параметром
  // no_logo - без заголовка
  // no_name - не показывать преобразования имени файла
  // translt - включение хитрого хака только с этим ключом

  if (GetParamStr('no_logo') = False)
  then WriteLn('Final Fantasy 7: Crisis Core file analyzer by Yoti');

  if ParamStr(1) = '' // имя файла не указано
  then
    begin
      WriteLn('usage: ' + ExtractFileName(ParamStr(0)) + ' filename.raw [no_logo] [no_name]');
      Halt(NO_FILE);
    end
  else if FileExists(ParamStr(1)) = True
  then
    begin
      AssignFile(f, ParamStr(1));
      Reset(f, 4);
        BlockRead(f, c, 1);
      CloseFile(f);

      // выборка файла по заголовкам
      case c of
        $6C657441: s:='_chunk.atl'; // raw:4174656C - кусочковый файл
        $464D5350: s:='_video.pmf'; // raw:50534D46 - видео
        $46464952: s:='_voice.at3'; // raw:52494646 - голоса
        $46435353: s:='_music.ssc'; // raw:53534346 - музыка
        $474E5089: s:='_image.png'; // raw:89504E47 - обычные картинки
        $0044424D: s:='_texts.mbd'; // raw:4D424400 - текстовые файлы
        $02005447: s:='_image.gtf'; // raw:47540002 - картинка 256 цветов (1bpp)
        $00000000: s:='_model.mdl'; // raw:00000000 - модель
        else s:='_unknw.raw';
      end;

      // тип файла до сих пор не определён
      // проверка на img с "плавающим" заголовком
      if s = '_unknw.raw' then
        begin
          AssignFile(f, ParamStr(1));
          Reset(f, 4);

          for i:=1 to 64 do
            begin
              if (i < FileSize(f)) // мы не хотим видеть ошибки о чтении за пределами файла
              then BlockRead(f, c, 1)
              else break;

              if (c = $00474D49) // raw:494D4700 - изображение
              and (i mod 4 = 1) // первый блок в строке из 4ёх
              then s:='_image.img';
            end;
          CloseFile(f);
        end;

      // хитрый хак для ПЕРЕВОДА - помечаем неопознанные по заголовку файлы
      // проверка на '_unknw.raw' для того, чтобы исключить обработку jp файлов
      // ВНИМАНИЕ: лучше бы проверять на заголовок, но пока и так сойдёт
      // подходит для любого анпакера, который пропускает пустые файлы
      if GetParamStr('translt') = True
      then
        begin                               // сишный анпакер                               // мой анпакер
          if ((ExtractFileName(ParamStr(1)) = '00001.raw') or (ExtractFileName(ParamStr(1)) = '00000001.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '01419.raw') or (ExtractFileName(ParamStr(1)) = '00001419.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '01427.raw') or (ExtractFileName(ParamStr(1)) = '00001427.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          //
          if ((ExtractFileName(ParamStr(1)) = '01446.raw') or (ExtractFileName(ParamStr(1)) = '00001446.raw')) and (s = '_unknw.raw') then s:='_plain.eng';
          if ((ExtractFileName(ParamStr(1)) = '01447.raw') or (ExtractFileName(ParamStr(1)) = '00001447.raw')) and (s = '_unknw.raw') then s:='_plain.eng';
          //
          if ((ExtractFileName(ParamStr(1)) = '01448.raw') or (ExtractFileName(ParamStr(1)) = '00001448.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '01455.raw') or (ExtractFileName(ParamStr(1)) = '00001455.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '08695.raw') or (ExtractFileName(ParamStr(1)) = '00008695.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '08696.raw') or (ExtractFileName(ParamStr(1)) = '00008696.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '08697.raw') or (ExtractFileName(ParamStr(1)) = '00008697.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '08698.raw') or (ExtractFileName(ParamStr(1)) = '00008698.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '08699.raw') or (ExtractFileName(ParamStr(1)) = '00008699.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
          if ((ExtractFileName(ParamStr(1)) = '08700.raw') or (ExtractFileName(ParamStr(1)) = '00008700.raw')) and (s = '_unknw.raw') then s:='_unknw.eng';
        end;

      if GetParamStr('no_name') = False
      then WriteLn(ExtractFileName(ParamStr(1)) + ' -> ' + ChangeFileExt(ParamStr(1), s));

      if (s <> '_unknw.raw')
      then RenameFile(ParamStr(1), ChangeFileExt(ParamStr(1), s))
      else Halt(UNKNOWN); // не переименовывать неизвестные (прога на один файл)
    end;

  Halt(SUCCESS);
end.
