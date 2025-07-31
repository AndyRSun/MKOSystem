unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, TaskInterface, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.Grids;

type

TTaskEntry = record
    DLLName: string;
    TaskName: string;
    Description: string;
    ParamsInfo: TArray<string>;
  end;

TfMain = class(TForm)
    dlgOpenDlls: TOpenDialog;
    btnLoadDLLs: TBitBtn;
    lvTasks: TListView;
    btnExecute: TBitBtn;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadDLLsClick(Sender: TObject);
    procedure lvTasksSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormDestroy(Sender: TObject);

  private
    FTasks: TList<TTaskEntry>;
    FHandleList: TList<HMODULE>;

    FSelectedTaskIndex: Integer;

    procedure UpdateTasksList;
    procedure UnloadAllDLLs;
    procedure LoadTasksFromDLLs(const DLLFiles: TArray<string>);

  public
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.btnLoadDLLsClick(Sender: TObject);
begin
if dlgOpenDlls.Execute then
  begin
    try
      LoadTasksFromDLLs(dlgOpenDlls.Files.ToStringArray);
      UpdateTasksList;
    except
      on E: Exception do
        ShowMessage('Ошибка загрузки DLL: ' + E.Message);
    end;
  end;
end;

procedure TfMain.LoadTasksFromDLLs(const DLLFiles: TArray<string>);
var
  DLLFile: string;
  DLLHandle: HMODULE;
 { GetTasks: TGetTasks;
  FreeTasks: TFreeTasks;
  Tasks: PTaskArray;
  TaskCount: Integer;}
  TaskEntry: TTaskEntry;
begin
  for DLLFile in DLLFiles do
  begin
    DLLHandle := LoadLibrary(PChar(DLLFile));
    if DLLHandle = 0 then Continue;

    var GetTasks: TGetTasks := nil;
    var FreeTasks: TFreeTasks := nil;
    var Tasks: PTaskArray;
    var TaskCount: Integer := 0;

    try

      @GetTasks := GetProcAddress(DLLHandle, 'GetTasks');
      @FreeTasks := GetProcAddress(DLLHandle, 'FreeTasks');

      if not (Assigned(GetTasks) and Assigned(FreeTasks)) then
        raise Exception.CreateFmt('Функция GetTasks/FreeTasks не найдена в %s', [DLLFile]);

      if GetTasks(Tasks, TaskCount) <> 0 then
        raise Exception.CreateFmt('Функция GetTasks вернула ошибку в %s', [DLLFile]);

      FHandleList.Add(DLLHandle);

      for var Task in Tasks^ do
      begin
        TaskEntry.DLLName := DLLFile;

        TaskEntry.TaskName := string(Task.TaskName);
        TaskEntry.Description := string(Task.Description);

        var ParamsInfo := TArray<string>.Create();
        SetLength(ParamsInfo, Length(Task.ParamsInfo));

        for var i := Low(Task.ParamsInfo) to High(Task.ParamsInfo) do
          ParamsInfo[i] := string(Task.ParamsInfo[i]);

        TaskEntry.ParamsInfo := ParamsInfo;

        FTasks.Add(TaskEntry);
      end;

    finally
      if Assigned(FreeTasks) then
        try
          FreeTasks(Tasks, TaskCount);
        except
          raise Exception.CreateFmt('Функция FreeTasks не найдена в %s', [DLLFile]);
        end;
    end;
  end;
end;

procedure TfMain.lvTasksSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  FSelectedTaskIndex := Item.Index;
  btnExecute.Enabled := FSelectedTaskIndex >= 0;

  var ParamCount := Length(FTasks[FSelectedTaskIndex].ParamsInfo);

  StringGrid1.RowCount := ParamCount + 1;

  for var i := 1 to StringGrid1.RowCount - 1 do
  begin
    StringGrid1.Cells[0, i] := FTasks[FSelectedTaskIndex].ParamsInfo[i - 1];
    StringGrid1.Cells[1, i] := '';
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  FTasks := TList<TTaskEntry>.Create;
  FHandleList := TList<HMODULE>.Create;
  FSelectedTaskIndex := -1;
  dlgOpenDlls.InitialDir := ExtractFilePath(Application.ExeName);

  StringGrid1.ColCount := 2;
  StringGrid1.FixedCols := 1;
  StringGrid1.FixedRows := 1;
  StringGrid1.ColWidths[0] := 250;
  StringGrid1.ColWidths[1] := 450;

  StringGrid1.Cells[0, 0] := 'Наименование';
  StringGrid1.Cells[1, 0] := 'Значение';
  StringGrid1.Options := StringGrid1.Options + [goEditing];

end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  UnloadAllDLLs();
end;

procedure TfMain.UnloadAllDLLs;
begin
  try
    for var DLLHandle in FHandleList do
      FreeLibrary(DLLHandle);
  finally
    FHandleList.Free;
  end;
end;


procedure TfMain.UpdateTasksList;
var
  Task: TTaskEntry;
  Item: TListItem;
begin
  lvTasks.Items.BeginUpdate;
  try
    lvTasks.Items.Clear;
    for Task in FTasks do
    begin
      Item := lvTasks.Items.Add;
      Item.Caption := Task.TaskName;
      Item.SubItems.Add(Task.Description);
      Item.SubItems.Add(Task.DLLName);
    end;
  finally
    lvTasks.Items.EndUpdate;
  end;
end;

end.
