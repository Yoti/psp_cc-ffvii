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

  if (ParamCount <> 1)
  then
    begin
      WriteLn('usage: ' + ExtractFileName(ParamStr(0)) + ' ' + list_filename);
      WriteLn; ReadLn;

      Halt(NO_FILE);
    end
  else
    begin
      if (FileExists(list_filename) = True)
      then
        begin
          FileListFromIndex:=TStringList.Create;
          FileListFromIndex.Clear;
          FileListFromIndex.LoadFromFile(list_filename);

          for i:=0 to FileListFromIndex.Count
          do
            begin
              if (FileExists(FileListFromIndex.Strings[i]) = False)
              then
                begin
                  Halt(UNKNOWN);
                  WriteLn('error: ' + FileListFromIndex.Strings[i] + ' not exists');
                  WriteLn; ReadLn;
                end;
            end;

          FileListFromIndex.Destroy;          
        end
      else
        Halt(NO_FILE);
        WriteLn; ReadLn;
    end;

  Halt(SUCCESS);
  WriteLn; ReadLn;
end.
