program ffccpkun;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Classes;

type
  TFileIndex = Record
  	offset: cardinal;
  	length: cardinal;
  	padding: cardinal;
  end;

const
  REAL_FILE_SECTOR_OFFSET:  Word = $33A;
  SECTOR_DATA_SIZE:         Word = $800;
  OUTPUT_CHUNK_SIZE:        Word = 1024;

  file_extension:           String = 'raw';
  input_directory:          String = ''; // 'data\'
  output_directory:         String = 'output\';
  index_filename:           String = 'discimg.fse';
  data_filename:            String = 'discimg.pkg';
  list_filename:            String = 'index.fls';

  SUCCESS = 0;
  NO_FILE = 1;
  UNKNOWN = 2;

var
  FS:                       TFileStream;
  current_filename:         String;
  output_filename:          String;
  output_filepath:          String;
  iIndexF:                  File;
  fListList:                TStringList;
  iDataF:                   File of Byte;
  oFileBuffer:              Array of Byte;
  count:                    Cardinal;
  real_offset:              Cardinal;
  FileIndex:                TFileIndex;
  delphiCount:              Cardinal;

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

begin
  WriteLn('Final Fantasy 7: Crisis Core pkg extractor by Yoti');

  current_filename:=input_directory + index_filename;
  if (FileExists(ExtractFilePath(ParamStr(0)) + current_filename) = False) then
    begin
      WriteLn('error: no "' + current_filename + '" file');
      WriteLn('= press [enter] to exit =');
      ReadLn;
      Halt(NO_FILE);
    end
  else
    begin
      AssignFile(iIndexF, current_filename);
      Reset(iIndexF, 4);
    end;

  current_filename:=input_directory + data_filename;
  if (FileExists(ExtractFilePath(ParamStr(0)) + current_filename) = False) then
    begin
      WriteLn('error: no "' + current_filename + '" file');
      WriteLn('= press [enter] to exit =');
      ReadLn;
      Halt(UNKNOWN);
    end
  else
    begin
      AssignFile(iDataF, current_filename);
      Reset(iDataF); { <- побайтовое чтение из контейнера, МЕДЛЕННО }
      MkDir(ExtractFilePath(ParamStr(0)) + output_directory);
      fListList:=TStringList.Create;
      fListList.Clear;
    end;

  count:=0;
  while not Eof(iIndexF) do { количество файлов неизвестно }
  begin
    output_filename:=IntToStrEx(count, 8) + '.' + file_extension;
    output_filepath:=output_directory + output_filename;
    BlockRead(iIndexF, FileIndex.offset, 1);
    real_offset:=FileIndex.offset * SECTOR_DATA_SIZE;
    BlockRead(iIndexF, FileIndex.length, 1);
    BlockRead(iIndexF, FileIndex.padding, 1);

    if (FileIndex.length > 0) then
      begin
        fListList.Add(output_filepath);

        Write('file: ' + IntToStrEx(count, 8));
        Write(', from: 0x' + IntToHex(real_offset, 8));
        Write(', size: 0x' + IntToHex(FileIndex.length, 8));
        //Write(', pad.: 0x' + IntToHex(FileIndex.padding, 8)); { <- всегда ноли }
        WriteLn;

        SetLength(oFileBuffer, FileIndex.length);
        //WriteLn('debug: oFileBuffer = ' + IntToStr(Length(oFileBuffer)) + '/' + IntToHex(Length(oFileBuffer), 8) + ' byte(s)'); { <- тут всё окей }
        { побайтовое чтение из контейнера в буфер, МЕДЛЕННО }
        for delphiCount:=0 to FileIndex.length-1 do
          begin
            Seek(iDataF, real_offset + delphiCount);
            Read(iDataF, oFileBuffer[delphiCount]);
          end;
        { быстрая запись файла через filestream }
        FS:=TFileStream.Create(ExtractFilePath(ParamStr(0)) + output_filepath, fmCreate);
        FS.WriteBuffer(Pointer(oFileBuffer)^, Length(oFileBuffer));
        FreeAndNil(FS);

        inc(count);
      end
    else
      begin
        fListList.Add('null');
        inc(count); // сохранять нумерацию, сомвместимую с xpert2 плагинами
      end;
  end;

  CloseFile(iIndexF);
  CloseFile(iDataF);
  fListList.SaveToFile(output_directory + list_filename);
  fListList.Destroy;

  WriteLn('All done, press [enter] to exit...');
  ReadLn;
  Halt(SUCCESS);
end.
