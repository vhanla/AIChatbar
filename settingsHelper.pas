unit settingsHelper;

interface

uses
  FireDAC.Phys.SQLite, Generics.Collections, Classes, SysUtils, JSON,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TSettings = class
  private
    FDB: TFDConnection;
  public
    procedure CreateTables;
    constructor Create(const settingsPath: string);
    destructor Destroy; override;

    property DB: TFDConnection read FDB;
  end;

implementation

{ TSettings }

constructor TSettings.Create(const settingsPath: string);
var
  FileInfo: TSearchRec;
begin
  FDB := TFDConnection.Create(nil);
  FDB.Params.DriverID := 'SQLite';
  FDB.Params.Database := settingsPath;
  FDB.Open;

  if FindFirst(settingsPath, faAnyFile, FileInfo) = 0 then
  begin
    try
      if (FileInfo.Size = 0) then
        CreateTables;
    finally
      FindClose(FileInfo);
    end;
  end;

end;

procedure TSettings.CreateTables;
var
  qr: TFDQuery;
begin
  qr := TFDQuery.Create(nil);
  try
    qr.Connection := FDB;
    qr.SQL.Text := 'CREATE TABLE IF NOT EXISTS settings(id INTEGER PRIMARY KEY,' +
                   'name TEXT, url TEXT, alturl TEXT, svgIcon TEXT,' +
                   'userscript TEXT, userscriptactive INTEGER,' +
                   'userstyle TEXT, userstyleactive INTEGER,' +
                   'enabled INTEGER, position INTEGER)';
    qr.ExecSQL;
    qr.SQL.Text := 'CREATE UNIQUE INDEX IF NOT EXISTS name_index on settings(name)';
    qr.ExecSQL;
  finally
    qr.Free;
  end;
end;

destructor TSettings.Destroy;
begin
  inherited;
  FDB.CloneConnection;
  FDB.Free;
end;

end.
