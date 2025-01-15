unit frmTaskGPT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCtrls,
  System.Net.HttpClient, System.Actions, Vcl.ActnList;

type
  TtaskForm = class(TForm)
    SearchBox1: TSearchBox;
    Label1: TLabel;
    grpTaskAnswer: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    ToggleSwitch1: TToggleSwitch;
    Label5: TLabel;
    ActionList1: TActionList;
    actHideTask: TAction;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actHideTaskExecute(Sender: TObject);
  private
    FBearer: string;
    FCookies: TCookieManager;
    FUserAgent: string;
    { Private declarations }
  public
    { Public declarations }
    function SwitchCustomInstructions: Boolean;
    function RestoreCustomInstructions: Boolean;
    function AskGPT(const query: string): Boolean;
    function GetAccessToken: string;

    property Bearer: string read FBearer write FBearer;
    property Cookies: TCookieManager read FCookies write FCookies;
    property UserAgent: string read FUserAgent write FUserAgent;
  end;

var
  taskForm: TtaskForm;

implementation

{$R *.dfm}

uses
  System.JSON, frmChatWebView;

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

procedure TtaskForm.actHideTaskExecute(Sender: TObject);
begin
  Hide;
end;

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

procedure TtaskForm.FormCreate(Sender: TObject);
begin
  FUserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.0.0';
  FCookies := TCookieManager.Create;
end;

procedure TtaskForm.FormDestroy(Sender: TObject);
begin
  FCookies.Destroy;
end;

function TtaskForm.GetAccessToken: string;
var
  http: THTTPClient;
  resp: IHTTPResponse;
  data: TStringStream;
begin
  Result := '';
  http := THTTPClient.Create;
  data := TStringStream.Create;
  try
    http.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/117.0';
    //http.CookieManager := frmChatWebView.mainBrowser.GetGPTCookies;
    http.ConnectionTimeout := 3000; // 3 seconds
    http.CustomHeaders['Accept'] := '*/*';
    http.CustomHeaders['Accept-Encoding'] := 'gzip, deflate, br';
    http.CustomHeaders['Cache-Control'] := 'no-cache';
    http.CustomHeaders['Connection'] := 'keep-alive';
    http.CustomHeaders['Host'] := 'chat.openai.com';
    http.CustomHeaders['Pragma'] := 'no-cache';
    http.CustomHeaders['Sec-Fetch-Dest'] := 'emtpy';
    http.CustomHeaders['Sec-Fetch-Mode'] := 'cors';
    http.CustomHeaders['Sec-Fetch-Site'] := 'same-origin';

    resp := http.Get('https://chat.openai.com/api/auth/session', data);
    if resp.StatusCode = 200 then
    begin
      var json := TJSONObject.Create;
      try
        if json.Parse(data.Bytes, 0) > 0 then // valid json
        begin
          if json.FindValue('accessToken') <> nil then
          begin
            Result := json.Values['accessToken'].Value;
          end;
        end;

      finally
        json.Free;
      end;

    end
    else if resp.StatusCode = 403 then
    begin
      ShowMessage('You need to pass the Cloudflare protection. Please open the ChatGPT instance.');
    end

    else
      raise Exception.Create(PChar('Error trying to get the access token, you should login first to ChatGPT:'#13#10#13#10 + data.ToString));
  finally
    data.Free;
    http.Free;
  end;
end;

function TtaskForm.RestoreCustomInstructions: Boolean;
begin

end;

function TtaskForm.SwitchCustomInstructions: Boolean;
var
  http: THTTPClient;
  resp: IHTTPResponse;
  data: TStringStream;
begin
  Result := False;
  http := THTTPClient.Create;
  data := TStringStream.Create;
  try
    http.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/117.0';
    http.CookieManager := frmChatWebView.mainBrowser.GetGPTCookies;
    http.ConnectionTimeout := 3000; // 3 seconds
    http.CustomHeaders['Authorization'] := 'Bearer'+FBearer;

    resp := http.Get('https://chat.openai.com/backend-api/user_system_messages', data);
    if resp.StatusCode = 200 then
    begin
      var json := TJSONObject.Create;
      try
        if json.Parse(data.Bytes, 0) > 0 then // valid json
        begin
          if json.FindValue('about_user_message') <> nil then
          begin
            ShowMessage(json.Values['about_user_message'].Value);
          end;
        end;

      finally
        json.Free;
      end;

    end
    else if resp.StatusCode = 403 then
    begin
      ShowMessage('You need to pass the Cloudflare protection. Please open the ChatGPT instance.');
    end

    else
      raise Exception.Create(PChar('Error trying to get the access token, you should login first to ChatGPT:'#13#10#13#10 + data.ToString));
  finally
    data.Free;
    http.Free;
  end;
end;

end.
