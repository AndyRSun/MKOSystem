library Searcher;
uses
  System.SysUtils,
  ActiveX,
  System.Classes,
  TaskInterface in '_Source\TaskInterface.pas';

{$R *.res}

{
function Execute_MaskFileSearch(const Param1, Param2: string): TArray<string>; stdcall;
begin

end;

function Execute_TextSearch(const Param1, Param2: string): TArray<string>; stdcall;
begin

end;}

function GetTasks(out Tasks: PTaskArray; out Count: Integer): Integer; stdcall;
var i: Integer;
    TaskArray: TTaskArray;
begin
  try
    Count := 2;
    SetLength(TaskArray, Count);

    TaskArray[0] := TTaskInfo.Create('MaskFileSearch','MaskFileSearch','Маски файлов','Путь для поиска');
    TaskArray[1] := TTaskInfo.Create('TextSearch','TextSearch','Слова для поиска','Файл поиска');

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
