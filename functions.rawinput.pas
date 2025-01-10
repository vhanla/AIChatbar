unit functions.rawinput;

interface

uses
Windows, Classes, TlHelp32, PsAPI, SysUtils, Registry, Graphics, DWMApi, PNGImage,
OleAcc, Variants, DirectDraw, ActiveX, ShellAPI, Math, ShlObj;

// RAW INPUT
const
  RIM_TYPEHID      = 2;
  RIM_TYPEKEYBOARD = 1;
  RIM_TYPEMOUSE    = 0;

  RID_INPUT  = $10000003;
  HID_USAGE_PAGE_GENERIC       = $01;
  HID_USAGE_GENERIC_MOUSE      = $02;

  RIDEV_INPUTSINK = $00000100;
type
  HRAWINPUT = THandle;

  tagRAWINPUTDEVICE = record
    usUsagePage: Word;
    usUsage: Word;
    dwFlags: DWORD;
    hwndTarget: HWND;
  end;
  RAWINPUTDEVICE = tagRAWINPUTDEVICE;

  PRAWINPUTDEVICE = ^RAWINPUTDEVICE;

  tagRAWINPUTHEADER = record
    dwType: DWORD;
    dwSize: DWORD;
    hDevice: THandle;
    wParam: WPARAM;
  end;
  RAWINPUTHEADER = tagRAWINPUTHEADER;

  tagRAWKEYBOARD = record
    MakeCode: Word;
    Flags: Word;
    Reserved: Word;
    VKey: Word;
    Message: UINT;
    ExtraInformation: ULONG;
  end;
  RAWKEYBOARD = tagRAWKEYBOARD;

  tagRAWMOUSE = record
    usFlags:  Word;
    case Integer of
      0:  (ulButtons: ULONG);
      1:  (usButtonFlags: Word;
           usButtonsData: Word;
    ulRawButtons: ULONG;
    lLastX: Longint;
    lLastY: Longint;
    ulExtraInformation: ULONG);
  end;
  RAWMOUSE = tagRAWMOUSE;

  tagRAWHID = record
    dwSizeHid: DWORD;
    dwCount: DWORD;
    bRawData: Byte;
  end;

  RAWHID = tagRAWHID;

  tagRAWINPUT = record
    header: RAWINPUTHEADER;
    case Integer of
      RIM_TYPEMOUSE: (mouse: RAWMOUSE);
      RIM_TYPEKEYBOARD:(keyboard: RAWKEYBOARD);
      RIM_TYPEHID: (hid: RAWHID);
  end;

  RAWINPUT = tagRAWINPUT;

function RegisterRawInputDevices(pRawInputDevices: PRAWINPUTDEVICE;
  uiNumDevices: UINT; cbSize: UINT): BOOL; stdcall; external 'user32.dll';
function GetRawInputData(hRawInput: HRAWINPUT; uiCommand: UINT; pData: Pointer; var pcbSize: UINT; cbSizeHeader: UINT): UINT; stdcall;
  external 'user32.dll';
implementation

end.
