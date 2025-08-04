unit TaskInterface;

interface

type
  TErrorCode = (
    ecSuccess,
    ecTaskNotFound,
    ecInvalidParameters,
    ecUnknown
  );

  TTaskInfo = record
    TaskName: PWideChar;
    Description: PWideChar;
    ParamsInfo: TArray<PWideChar>;
    constructor Create(const ATaskName, ADescription: PWideChar; AParamsInfo: TArray<PWideChar>);
    procedure FreeResources;
  end;

  TTaskArray = TArray<TTaskInfo>;
  PTaskArray = ^TTaskArray;

  TParams = TArray<PWideChar>;
  PParams = ^TParams;

  TResults = TArray<PWideChar>;
  PResults = ^TResults;

  TGetTasks = function(var Arr: PTaskArray; out Count: Integer): TErrorCode; stdcall;
  TFreeTasks  = procedure(var Arr: PTaskArray; Count: Integer); stdcall;

  TRunTask = function(TaskName: PWideChar; Params: PParams; var Results: PResults; out Count: Integer): TErrorCode; stdcall;
  TClearTaskVars = procedure(var Results: PResults; var Count: Integer);

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
