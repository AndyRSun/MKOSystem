unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, TaskInterface, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, Vcl.Mask, Vcl.ExtCtrls;

type

TTaskEntry = record
    DLLName: string;
    TaskName: string;
    Description: string;
    Param1Info: string;
    Param2Info: string;
    
  end;


  TfMain = class(TForm)
    dlgOpenDlls: TOpenDialog;
    btnLoadDLLs: TBitBtn;
    lvTasks: TListView;
    edtParam1: TLabeledEdit;
    edtParam2: TLabeledEdit;
    btnExecute: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadDLLsClick(Sender: TObject);
    procedure lvTasksSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);

  private
    FTasks: TList<TTaskEntry>;
   
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
  GetTasks: TGetTasks;
  FreeTasks: TFreeTasks;
  Tasks: PTaskArray;
  TaskEntry: TTaskEntry;
  TaskCount: Integer;
begin
  for DLLFile in DLLFiles do
  begin
    DLLHandle := LoadLibrary(PChar(DLLFile));
    if DLLHandle = 0 then Continue;

    try
    @GetTasks := GetProcAddress(DLLHandle, 'GetTasks');
    @FreeTasks := GetProcAddress(DLLHandle, 'FreeTasks');
      if not (Assigned(GetTasks) and Assigned(FreeTasks)) then
        raise Exception.CreateFmt('Функция GetTasks/FreeTasks не найдена в %s', [DLLFile]);

      if GetTasks(Tasks, TaskCount) <> 0 then 
        raise Exception.CreateFmt('Функция GetTasks вернула ошибку в %s', [DLLFile]);
        
      for var Task in Tasks^ do
      begin
        TaskEntry.DLLName := DLLFile;
        
        TaskEntry.TaskName := string(Task.TaskName);
        TaskEntry.Description := string(Task.Description);
        TaskEntry.Param1Info := string(Task.Param1Info);
        TaskEntry.Param2Info := string(Task.Param2Info); 
        
        FTasks.Add(TaskEntry);
      end;
      
    finally

      FreeTasks(Tasks, TaskCount);  
        
      FreeLibrary(DLLHandle);
    end;
  end;
end;

procedure TfMain.lvTasksSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  FSelectedTaskIndex := Item.Index;
  btnExecute.Enabled := FSelectedTaskIndex >= 0;

  edtParam1.EditLabel.Caption := FTasks[FSelectedTaskIndex].Param1Info;
  edtParam2.EditLabel.Caption := FTasks[FSelectedTaskIndex].Param2Info;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  FTasks := TList<TTaskEntry>.Create;
  FSelectedTaskIndex := -1;
  dlgOpenDlls.InitialDir := ExtractFilePath(Application.ExeName);
end;

procedure TfMain.UnloadAllDLLs;
begin
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
