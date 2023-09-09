unit frmTaskGPT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCtrls;

type
  TtaskForm = class(TForm)
    SearchBox1: TSearchBox;
    Label1: TLabel;
    grpTaskAnswer: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function SwitchCustomInstructions: Boolean;
    function RestoreCustomInstructions: Boolean;
    function AskGPT(const query: string): Boolean;
    function GetAccessToken: string;
  end;

var
  taskForm: TtaskForm;

implementation

{$R *.dfm}

uses
  Net.HttpClient, System.JSON;

const
  //GET (to obtain current) or POST, and should return 200 with Authorization: Bearer
  // Content-Type: application/json UA and Cookies
  POST_FETCH_ENDPOINT = 'https://chat.openai.com/backend-api/user_system_messages';

  ABOUT_MODEL_MESSAGE = 'You''re an expert Windows user, and your answers should be in json format in the ' +
  'following manner: ' +
  '{ ' +
  '"task": "Open control panel", ' +
  '"commandLine": "control.exe", ' +
  '"description": "This command line opens de control panel", ' +
  '"evelationRequired": "false", ' +
  '"warningType": "safe", ' +
  '"warningDesc": "The current task is safe, doesn''t modify anything right away, on' +
  'ly after executed depending of what the user does" ' +
  '} ' +
  'Important: if task couldn''t be done, state that as "not possible, but give sugge' +
  'stions", and use Windows'' default environment variables to get special folders, ' +
  'you can use PowerShell inline scripts too. ';

  ABOUT_USER_MESSAGE = 'Give me answers only in json format, not other formatting allowed, never answer ' +
  'in other format. ';
  //Answers like this
  {
    "object": "user_system_message_detail",
    "enabled": true,
    "about_user_message": "Give me answers only in json format, not other formatting allowed, never answer in other format.",
    "about_model_message": "You're an expert ..."
  }

function TtaskForm.AskGPT(const query: string): Boolean;
begin

end;

procedure TtaskForm.Button1Click(Sender: TObject);
begin
  if SwitchCustomInstructions then
  try
    AskGPT(SearchBox1.Text)
  finally
    if not RestoreCustomInstructions then
      raise Exception.Create('Error restoring your custom instructions!');
  end;
end;

function TtaskForm.GetAccessToken: string;
var
  http: THTTPClient;
  resp: IHTTPResponse;
begin
  http := THTTPClient.Create;
  try
    resp := http.Get('');
    if resp.StatusCode = 200 then
    begin
      resp.ContentStream;
    end;
  finally
    http.Free;
  end;
end;

function TtaskForm.RestoreCustomInstructions: Boolean;
begin

end;

function TtaskForm.SwitchCustomInstructions: Boolean;
begin

end;

end.
