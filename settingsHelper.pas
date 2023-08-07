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
  TSite = class
  private
    FId: Integer;
    FName: string;
    FUrl: string;
    FAltUrl: string;
    FIcon: string;
    FPosition: Integer;
    FUserScript: string;
    FUserStyle: string;
    FUserScriptEnabled: Boolean;
    FUserStyleEnabled: Boolean;
    FEnabled: Boolean;
    FUA: string;
  published
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Url: string read FUrl write FUrl;
    property AltUrl: string read FAltUrl write FAltUrl;
    property Icon: string read FIcon write FIcon;
    property Position: Integer read FPosition write FPosition;
    property UserStyle: string read FUserStyle write FUserStyle;
    property UserScript: string read FUserScript write FUserScript;
    property UserStyleEnabled: Boolean read FUserStyleEnabled write FUserStyleEnabled;
    property UserScriptEnabled: Boolean read FUserScriptEnabled write FUserScriptEnabled;
    property Enabled: Boolean read FEnabled write FEnabled;
    property UA: string read FUA write FUA;
  end;

  TSettings = class
  private
    FDB: TFDConnection;
    FSites: TObjectList<TSite>;
  public
    procedure CreateTables;
    constructor Create(const settingsPath: string);
    destructor Destroy; override;

    procedure AddSites(const name, url, alturl, svgicon, uscript, ustyle: string;
      uscriptOn, ustyleOn, enabled: Boolean; position: Integer; const UA: string);

    procedure ReadSites;

    property DB: TFDConnection read FDB;
    property Sites: TObjectList<TSite> read FSites write FSites;
  end;

implementation

{ TSettings }

procedure TSettings.AddSites(const name, url, alturl, svgicon, uscript,
  ustyle: string; uscriptOn, ustyleOn, enabled: Boolean; position: Integer; const UA: string);
var
  q: TFDQuery;
begin
  q := TFDQuery.Create(nil);
  try
    q.Connection := FDB;
    q.SQL.Text := 'INSERT OR IGNORE INTO settings (name, url, alturl, svgIcon,' +
                   'userscript, userscriptactive,' +
                   'userstyle, userstyleactive,' +
                   'enabled, position, ua) VALUES (:name, :url, :alturl, :svgIcon,' +
                   ':userscript, :userscriptactive,' +
                   ':userstyle, :userstyleactive,' +
                   ':enabled, :position, :ua)';
    q.Params.ParamByName('name').AsWideString := name;
    q.Params.ParamByName('url').AsWideString := url;
    q.Params.ParamByName('alturl').AsWideString := alturl;
    q.Params.ParamByName('svgIcon').AsWideString := svgicon;
    q.Params.ParamByName('userscript').AsWideString := uscript;
    q.Params.ParamByName('userscriptactive').AsBoolean := uscriptOn;
    q.Params.ParamByName('userstyle').AsWideString := ustyle;
    q.Params.ParamByName('userstyleactive').AsBoolean := ustyleOn;
    q.Params.ParamByName('enabled').AsBoolean := enabled;
    q.Params.ParamByName('position').AsInteger := position;
    q.Params.ParamByName('ua').AsWideString := UA;

    q.ExecSQL;
  finally
    q.Free;
  end;
end;

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

  FSites := TObjectList<TSite>.Create;
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
                   'enabled INTEGER, position INTEGER, ua TEXT)';
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
  FSites.Free;
  FDB.CloneConnection;
  FDB.Free;
end;

procedure TSettings.ReadSites;
var
  q: TFDQuery;
begin
  q := TFDQuery.Create(nil);
  try
    q.Connection := FDB;
    q.SQL.Text := 'SELECT * FROM settings';
    q.Open;
    // clear current FSites if it is filled already
    FSites.Clear;
    while not q.Eof do
    begin
      var site := TSite.Create;
      try
        with site do
        begin
          FId := q.FieldByName('id').AsInteger;
          FName := q.FieldByName('name').AsWideString;
          FUrl := q.FieldByName('url').AsWideString;
          FAltUrl := q.FieldByName('alturl').AsWideString;
          FIcon := q.FieldByName('svgIcon').AsWideString;
          FUserScript := q.FieldByName('userscript').AsWideString;
          FUserScriptEnabled := Boolean(q.FieldByName('userscriptactive').AsInteger);
          FUserStyle := q.FieldByName('userstyle').AsWideString;
          FUserStyleEnabled := Boolean(q.FieldByName('userstyleactive').AsInteger);
          FEnabled := Boolean(q.FieldByName('enabled').AsInteger);
          FPosition := q.FieldByName('position').AsInteger;
          FUA := q.FieldByName('ua').AsWideString;
        end;
        FSites.Add(site);
      finally
        //site.Free; <// do not free, otherwise it won't be accessible anyumore, clear or destroy handles it
      end;
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

end.
