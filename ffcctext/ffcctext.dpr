program ffcctext;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes;

var
  c: char;
  i, k: integer;
  FileAsFile: File;
  FileAsText: TextFile;
  FileAsByte: File of Byte;
  ByteForFileAsByte: Byte;
  NumberOfStringsInFile: Cardinal;
  StringOffset: Cardinal;
  Length_Cardinal: Cardinal;
  TempStringForList: String;
  StringsListOffset: TStringList;

begin
  WriteLn('Final Fantasy 7: Crisis Core text recoder by Yoti');

  if (ParamStr(1) = '') then
    begin
      WriteLn('usage: drag-n-drop raw/eng or txt');
      WriteLn('error: no file');
      WriteLn('= press [enter] to exit =');
      ReadLn;
      Halt(1); // no file
    end
  else if ((ExtractFileExt(ParamStr(1)) = '.eng')
       or (ExtractFileExt(ParamStr(1)) = '.raw')) then
    begin
      WriteLn('Mode: raw/eng -> txt');
      AssignFile(FileAsFile, ParamStr(1));
      Reset(FileAsFile, 4);
      BlockRead(FileAsFile, NumberOfStringsInFile, 1);
      WriteLn('Lines in file: ' + IntToStr(NumberOfStringsInFile));

      StringsListOffset:=TStringList.Create;
      StringsListOffset.Clear;
      for i:=0 to NumberOfStringsInFile-1 do
        begin
          BlockRead(FileAsFile, StringOffset, 1);
          StringsListOffset.Add(IntToStr(StringOffset));
        end;
      CloseFile(FileAsFile);

      AssignFile(FileAsFile, ParamStr(1));
      Reset(FileAsFile, 1);
      AssignFile(FileAsText, ChangeFileExt(ParamStr(1), '_utf8.txt'));
      ReWrite(FileAsText);
      for i:=0 to NumberOfStringsInFile-1 do
        begin
          k:=0;
          c:=Chr(0);
          TempStringForList:='';
          repeat
            Seek(FileAsFile, StrToInt(StringsListOffset[i]) + k);
            BlockRead(FileAsFile, c, 1);
            TempStringForList:=TempStringForList+c;
            inc(k);
          until c = Chr(0);

          if (i = 0)
          then
            begin
              // Добавим utf8 сигнатуру
              if ((TempStringForList[1] <> Chr($EF))
              and(TempStringForList[2] <> Chr($BB))
              and(TempStringForList[3] <> Chr($BF)))
              then TempStringForList:=#$EF#$BB#$BF + TempStringForList;
            end;

          Length_Cardinal:=i; // fix
          if (Length_Cardinal < NumberOfStringsInFile - 1)
          then WriteLn(FileAsText, Copy(TempStringForList, 0, Length(TempStringForList) - 1)) // copy - удаление последнего chr(0)
          else Write(FileAsText, Copy(TempStringForList, 0, Length(TempStringForList) - 1)); // copy - удаление последнего chr(0)
        end;
      CloseFile(FileAsFile);
      CloseFile(FileAsText);

      StringsListOffset.Free;
    end
  else if (ExtractFileExt(ParamStr(1)) = '.txt') then
    begin
      WriteLn('Mode: txt -> raw');
      AssignFile(FileAsText, ParamStr(1));
      Reset(FileAsText);
      StringsListOffset:=TStringList.Create;
      StringsListOffset.Clear;

      StringsListOffset.LoadFromFile(ParamStr(1));
      NumberOfStringsInFile:=StringsListOffset.Count;
      WriteLn('Lines in file: ' + IntToStr(NumberOfStringsInFile));
      CloseFile(FileAsText);

      if (NumberOfStringsInFile > 0)
      then
        begin
          AssignFile(FileAsFile, ChangeFileExt(ParamStr(1), '.raw'));
          ReWrite(FileAsFile, 4);

          BlockWrite(FileAsFile, NumberOfStringsInFile, 1); // первый оффсет - количество записей

          for i:=0 to NumberOfStringsInFile-1 do // -1 из-за того, что начало с 0
            begin
              if (i = 0)
              then
                begin
                  // Фикс utf8 сигнатуры
                  if ((StringsListOffset.Strings[0][1] = Chr($EF)) and
                     (StringsListOffset.Strings[0][2] = Chr($BB))  and
                     (StringsListOffset.Strings[0][3] = Chr($BF)))
                  then StringsListOffset.Strings[0]:=Copy(StringsListOffset.Strings[0], 4, Length(StringsListOffset.Strings[0]));

                  //WriteLn(StringsListOffset.Strings[0]); ReadLn; <- отладка
                  Length_Cardinal:=4 + 4 * NumberOfStringsInFile;
                  StringOffset:=Length_Cardinal;
                  BlockWrite(FileAsFile, StringOffset, 1);
                end
              else
                begin
                  Length_Cardinal:=Length(StringsListOffset.Strings[i-1]); // получаем длину предыдущей строки, т.к. оффсет идёт на начало
                  StringOffset:=StringOffset + Length_Cardinal + 1; // старый оффсет + длина + chr(0)
                  BlockWrite(FileAsFile, StringOffset, 1);
                end;
              //WriteLn('debug: #' + IntToStr(i) + ' [' + StringsListOffset.Strings[i] + '] len is ' + IntToStr(Length(StringsListOffset.Strings[i])) + ' block is ' + IntToHex(StringOffset, 8));
            end;
          CloseFile(FileAsFile);

          AssignFile(FileAsByte, ChangeFileExt(ParamStr(1), '.raw'));
          Reset(FileAsByte);
          Seek(FileAsByte, FileSize(FileAsByte));
          for i:=0 to NumberOfStringsInFile-1 do // -1 из-за того, что начало с 0
            begin
              k:=1;
              repeat
                ByteForFileAsByte:=Ord(StringsListOffset.Strings[i][k]);
                Write(FileAsByte, ByteForFileAsByte);
                inc(k);
              until k > Length(StringsListOffset.Strings[i]);

              ByteForFileAsByte:=$00;
              Write(FileAsByte, ByteForFileAsByte);
            end;
          CloseFile(FileAsByte);
        end;

      StringsListOffset.Free;
    end
  else
    begin
      WriteLn('usage: drag-n-drop raw/eng or txt');
      WriteLn('error: wrong file type or extension');
      WriteLn('= press [enter] to exit =');
      ReadLn;
      Halt(2); // error in file
    end;

  WriteLn('= press [enter] to exit =');
  ReadLn;
  Halt(0); // no error
end.
