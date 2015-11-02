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
  // ������ ����������
  // no_logo - ��� ���������
  // no_name - �� ���������� �������������� ����� �����
  // translt - ��������� ������� ���� ������ � ���� ������

  if (GetParamStr('no_logo') = False)
  then WriteLn('Final Fantasy 7: Crisis Core file analyzer by Yoti');

  if ParamStr(1) = '' // ��� ����� �� �������
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

      // ������� ����� �� ����������
      case c of
        $6C657441: s:='_chunk.atl'; // raw:4174656C - ���������� ����
        $464D5350: s:='_video.pmf'; // raw:50534D46 - �����
        $46464952: s:='_voice.at3'; // raw:52494646 - ������
        $46435353: s:='_music.ssc'; // raw:53534346 - ������
        $474E5089: s:='_image.png'; // raw:89504E47 - ������� ��������
        $0044424D: s:='_texts.mbd'; // raw:4D424400 - ��������� �����
        $02005447: s:='_image.gtf'; // raw:47540002 - �������� 256 ������ (1bpp)
        $00000000: s:='_model.mdl'; // raw:00000000 - ������
        else s:='_unknw.raw';
      end;

      // ��� ����� �� ��� ��� �� ��������
      // �������� �� img � "���������" ����������
      if s = '_unknw.raw' then
        begin
          AssignFile(f, ParamStr(1));
          Reset(f, 4);

          for i:=1 to 64 do
            begin
              if (i < FileSize(f)) // �� �� ����� ������ ������ � ������ �� ��������� �����
              then BlockRead(f, c, 1)
              else break;

              if (c = $00474D49) // raw:494D4700 - �����������
              and (i mod 4 = 1) // ������ ���� � ������ �� 4��
              then s:='_image.img';
            end;
          CloseFile(f);
        end;

      // ������ ��� ��� �������� - �������� ������������ �� ��������� �����
      // �������� �� '_unknw.raw' ��� ����, ����� ��������� ��������� jp ������
      // ��������: ����� �� ��������� �� ���������, �� ���� � ��� �����
      // �������� ��� ������ ��������, ������� ���������� ������ �����
      if GetParamStr('translt') = True
      then
        begin                               // ������ �������                               // ��� �������
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
      else Halt(UNKNOWN); // �� ��������������� ����������� (����� �� ���� ����)
    end;

  Halt(SUCCESS);
end.
