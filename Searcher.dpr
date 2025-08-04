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
        PWideChar(WideString('Маски файлов'))
        , PWideChar(WideString('Путь для поиска'))
        , PWideChar(WideString('Искать в подкаталогах (не пусто)'))
      );
      TaskArray[0] := TTaskInfo.Create('MaskFileSearch','MaskFileSearch', Params);
    end;
    begin
      var Params := TArray<PWideChar>.Create(
        PWideChar(WideString('Слова для поиска'))
        , PWideChar(WideString('Файл поиска'))
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

 ///////////////////////////////////////////////////

function RunMaskFileSearch(Params: PParams; var Results: PResults; out count: Integer): TErrorCode;

procedure SearchFiles(const pPath, Mask: string; var FileList: TStringList; pRecursive: Boolean);
var
  SearchRec: TSearchRec;
  SearchPath: string;
begin
  // Убедимся, что путь заканчивается на разделитель
  SearchPath := IncludeTrailingPathDelimiter(pPath);

  // Поиск файлов по маске
  if FindFirst(SearchPath + Mask, faAnyFile and not faDirectory, SearchRec) = 0 then
  begin
    repeat
      // Исключаем текущий и родительский каталоги
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        FileList.Add(SearchPath + SearchRec.Name);
    until FindNext(SearchRec) <> 0;
    System.SysUtils.FindClose(SearchRec);
  end;

  // Если рекурсия включена, ищем подкаталоги и вызываем рекурсивно
  if pRecursive then
  begin
    if FindFirst(SearchPath + '*', faDirectory, SearchRec) = 0 then
    begin
      repeat
        if ((SearchRec.Attr and faDirectory) <> 0) and
           (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          // Рекурсивный вызов для подкаталога
          SearchFiles(SearchPath + SearchRec.Name, Mask, FileList, True);
        end;
      until FindNext(SearchRec) <> 0;
      System.SysUtils.FindClose(SearchRec);
    end;
  end;
end;

var
  pFileMask, pPath, pRecursive: string;
  MaskArray: TArray<string>;
  I: Integer;
  FileArray: TStringList;
begin
  Result := ecSuccess;
  Count := 0;
  FileArray := TStringList.Create;

  try
    if not Assigned(Params) or not Assigned(Params^) or (Length(Params^) < 3) then
    begin
      Result := ecInvalidParameters;
      Exit;
    end;

    pFileMask := string(Params^[0]);
    pPath := string(Params^[1]);
    pRecursive  := string(Params^[2]);

    MaskArray := pFileMask.Split([';'], TStringSplitOptions.ExcludeEmpty);

    for I := 0 to High(MaskArray) do
    begin
      var Mask := Trim(MaskArray[I]);
      if Mask = '' then Continue;

      FileArray.Add('Поиск маски: "' + Mask + '", По пути: ' + pPath);

      SearchFiles(pPath, Mask, FileArray, pRecursive <> '');
    end;

    Count := FileArray.Count;
    if Count > 0 then
    begin
      New(Results);
      SetLength(Results^, Count);
      for I := 0 to Count - 1 do
      begin
        Results^[I] := StrNew(PWideChar(FileArray[I]));
      end;
    end;

  except
    on E: Exception do
    begin
      Result := ecUnknown;
      Count := 0;
    end;
  end;
  FileArray.Free;
end;


function RunTextSearch(Params: PParams; var Results: PResults; out Count: Integer): TErrorCode; stdcall;
begin

end;

////////////////////////////////////////////////////


function RunTask(TaskName: PWideChar; Params: PParams; var Results: PResults; out Count: Integer): TErrorCode; stdcall;
begin
  Result := ecSuccess;
  Count := 0;

  try
    var Task := string(TaskName);

    if SameText(Task, 'MaskFileSearch')  then Result := RunMaskFileSearch(Params, Results, Count)
    else if SameText(Task, 'TextSearch')  then RunTextSearch(Params, Results, Count)
    else Result := ecTaskNotFound;

  except
    Result := ecUnknown;
  end;
end;

procedure ClearTaskVars(var Results: PResults; var Count: Integer);
var
  I: Integer;
begin

  if Assigned(Results) and Assigned(Results^) then
  begin
    for I := 0 to Count - 1 do
      if Results^[I] <> nil then
        StrDispose(Results^[I]);
    SetLength(Results^, 0);
    FreeMem(Results);
    Results := nil;
  end;
end;

exports
  GetTasks
  , FreeTasks
  , RunTask
  , ClearTaskVars
  ;
begin
  IsMultiThread := True;
end.
