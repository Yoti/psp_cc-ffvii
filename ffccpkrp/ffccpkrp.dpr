program ffccpkrp;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Classes;

const
  // halt результаты
  SUCCESS = 0;
  NO_FILE = 1;
  UNKNOWN = 2;

  // имена файлов и папок, нет нужды использовать переменные
  list_filename: String = 'index.fls';

var
  i: Integer; // универсальный счётчик
  FileListFromIndex: TStringList;

begin
  WriteLn('Crisis Core -Final Fantasy VII- pkg repacker by Yoti');

  if (FileExists(list_filename) = False)
  then
    begin
      WriteLn('[e]: ' + list_filename + ' not exists');
      WriteLn; ReadLn;
      Halt(NO_FILE);
    end
  else
    begin
      FileListFromIndex:=TStringList.Create;
      FileListFromIndex.Clear;
      FileListFromIndex.LoadFromFile(list_filename);

      for i:=0 to FileListFromIndex.Count-1
      do
        begin
          if (FileExists(FileListFromIndex.Strings[i]) = False)
          and(FileListFromIndex.Strings[i] <> 'null')
          then
            begin
              WriteLn('[e]: ' + FileListFromIndex.Strings[i] + ' not exists');
              WriteLn; ReadLn;
              Halt(UNKNOWN);
            end
          else
            begin
              WriteLn('[i]: ' + FileListFromIndex.Strings[i] + ' found');
            end;
        end;

      FileListFromIndex.Destroy;
    end;

  WriteLn('[i]: All done!');
  WriteLn; ReadLn;
  Halt(SUCCESS);
end.
