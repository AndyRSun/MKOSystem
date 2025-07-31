unit TaskInterface;

interface

type
  TTaskInfo = record
    TaskName: PWideChar;
    Description: PWideChar;
    Param1Info: PWideChar;
    Param2Info: PWideChar;
    constructor Create(const ATaskName, ADescription, AParam1Info, AParam2Info: PWideChar);
    procedure FreeResources;
  end;

  TTaskArray = TArray<TTaskInfo>;
  PTaskArray = ^TTaskArray;

  TTaskExecute = function(const TaskName, Param1, Param2: PWideChar): TArray<string>; stdcall;
  TGetTasks = function(out Arr: PTaskArray; out Count: Integer): Integer; stdcall;
  TFreeTasks  = procedure(var Arr: PTaskArray; Count: Integer); stdcall;

implementation

constructor TTaskInfo.Create(const ATaskName, ADescription, AParam1Info, AParam2Info: PWideChar);
begin
  TaskName := ATaskName;
  Description := ADescription;
  Param1Info := AParam1Info;
  Param2Info := AParam2Info;
end;

procedure TTaskInfo.FreeResources;
begin
  if Assigned(TaskName) then FreeMem(TaskName);
  if Assigned(Description) then FreeMem(Description);
  if Assigned(Param1Info) then FreeMem(Param1Info);
  if Assigned(Param2Info) then FreeMem(Param2Info);
end;

end.
