unit frameEditSite;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Skia, Skia.Vcl;

type
  TFrame1 = class(TFrame)
    lblName: TLabeledEdit;
    lblURL: TLabeledEdit;
    lblAltURL: TLabeledEdit;
    svgIcon: TSkSvg;
    btnSearchSVG: TButton;
    ckUserScript: TCheckBox;
    ckUserStyle: TCheckBox;
    ckEnabled: TCheckBox;
    txtUserScript: TMemo;
    txtUserStyle: TMemo;
    btnCancel: TButton;
    btnOK: TButton;
    openSVG: TOpenDialog;
    lblUA: TLabeledEdit;
    procedure btnSearchSVGClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrame1.btnSearchSVGClick(Sender: TObject);
begin
  openSVG.Filter := 'SVG Files|*.svg|All Files|*.*';
  if openSVG.Execute then
  begin
    var txt := TStringList.Create;
    try
      txt.LoadFromFile(openSVG.FileName);
      svgIcon.Svg.Source := txt.Text;
    finally
      txt.Free;
    end;
  end;
end;

end.
