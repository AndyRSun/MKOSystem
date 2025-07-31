library Searcher;
uses
  System.SysUtils,
  ActiveX,
  System.Classes,
  TaskInterface in '_Source\TaskInterface.pas';

{$R *.res}

function GetTasks(var Tasks: PTaskArray; out Count: Integer): Integer; stdcall;
var i: Integer;
    TaskArray: TTaskArray;
begin
  try
    Count := 2;
    SetLength(TaskArray, Count);
    begin
      var Params := TArray<PWideChar>.Create(
        PWideChar(WideString('Маски файлов')),
        PWideChar(WideString('Путь для поиска'))
      );
      TaskArray[0] := TTaskInfo.Create('MaskFileSearch','MaskFileSearch', Params);
    end;
    begin
      var Params := TArray<PWideChar>.Create(
        PWideChar(WideString('Слова для поиска')),
        PWideChar(WideString('Файл поиска'))
      );
      TaskArray[1] := TTaskInfo.Create('TextSearch','TextSearch', Params);
    end;
    New(Tasks);
    Tasks^ := Copy(TaskArray, 0, Count);

    Result := 0;
  except
    Result := -1;
  end;
end;

procedure FreeTasks(Tasks: PTaskArray; Count: Integer); stdcall;
var i: integer;
begin
  if Tasks = nil then Exit;

  for i := 0 to Count -1 do
  begin
     Tasks^[i].FreeResources;
  end;

  FreeMem(Tasks);
end;

exports
  GetTasks,
  FreeTasks;
begin

end.
