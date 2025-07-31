unit TaskInterface;

interface

type
  TTaskInfo = record
    TaskName: PWideChar;
    Description: PWideChar;
    ParamsInfo: TArray<PWideChar>;
    constructor Create(const ATaskName, ADescription: PWideChar; AParamsInfo: TArray<PWideChar>);
    procedure FreeResources;
  end;

  TTaskArray = TArray<TTaskInfo>;
  PTaskArray = ^TTaskArray;

  TTaskExecute = function(const TaskName, Param1, Param2: PWideChar): TArray<string>; stdcall;
  TGetTasks = function(var Arr: PTaskArray; out Count: Integer): Integer; stdcall;
  TFreeTasks  = procedure(var Arr: PTaskArray; Count: Integer); stdcall;

implementation

constructor TTaskInfo.Create(const ATaskName, ADescription: PWideChar; AParamsInfo: TArray<PWideChar>);
begin
  TaskName := ATaskName;
  Description := ADescription;
  ParamsInfo := AParamsInfo;
end;

procedure TTaskInfo.FreeResources;
begin
  if Assigned(TaskName) then FreeMem(TaskName);
  if Assigned(Description) then FreeMem(Description);
  if Assigned(ParamsInfo) then
  begin
    for var param in ParamsInfo do
      FreeMem(param);

    SetLength(ParamsInfo, 0);
  end;
end;

end.
