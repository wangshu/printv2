
{*****************************************}
{                                         }
{         Report Machine v1.0             }
{              About window               }
{                                         }
{*****************************************}

unit RM_about;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TRMFormAbout = class(TForm)
    btnOK: TButton;
    Label1: TLabel;
    lblVersion: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblDisclaimer: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses ShellAPI, RM_Utils, RM_Const, RM_Const1;

{$R *.DFM}

procedure TRMFormAbout.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 540);
//  RMSetStrProp(lblMemorrySize, 'Caption', rmRes + 541);
  btnOk.Caption := RMLoadStr(SOK);
end;

procedure TRMFormAbout.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

{function GetWindowsVersion: string;
var
  liVer: TOsVersionInfo;
  liPlatform: string;
  liBuildNumber: Integer;
  liVersion: string;
begin
  liVer.dwOSVersionInfoSize := SizeOf(liVer);
  GetVersionEx(liVer);
  with liVer do
  begin
    case dwPlatformId of
      VER_PLATFORM_WIN32_WINDOWS:
        begin
          liBuildNumber := Win32BuildNumber and $0000FFFF;
          liVersion := Format('%d.%.2d.', [dwMajorVersion, dwMinorVersion]);
          if (dwMajorVersion > 4) or ((dwMajorVersion = 4) and (dwMinorVersion >= 10)) then
            liPlatform := '98'
          else
            liPlatform := '95';
        end;
      VER_PLATFORM_WIN32_NT:
        begin
          liPlatform := 'NT';
          liBuildNumber := Win32BuildNumber;
          if Win32MajorVersion = 5.0 then
          begin
            liPlatform := '2000';
            liVersion := 'Build ';
          end
          else
          begin
            liVersion := Format('%d.%.2d.', [dwMajorVersion, dwMinorVersion]);
          end;
        end;
    else
      liPlatform := '';
      liBuildNumber := 0;
      liVersion := '';
    end;

    Result := Trim(Format('Windows %s(%s%.3d %s)', [liPlatform, liVersion, liBuildNumber, szCSDVersion]));
  end;
end;
}
procedure TRMFormAbout.FormCreate(Sender: TObject);
//var
//  MS: TMemoryStatus;
begin
//  OS.Caption := GetWindowsVersion;
//  MS.dwLength := SizeOf(TMemoryStatus);
//  GlobalMemoryStatus(MS);
//  PhysMem.Caption := FormatFloat('#,###" KB"', MS.dwTotalPhys div 1024);

  lblVersion.Caption := RM_Const1.RMCurrentVersionStr;
  Localize;
end;

procedure TRMFormAbout.Label9Click(Sender: TObject);
begin
  ShellExecute(0, nil, 'http://sourceforge.net/projects/tpsystools/', nil, nil, SW_RESTORE);
end;

procedure TRMFormAbout.Label7Click(Sender: TObject);
begin
  try
    ShellExecute(0, nil, PChar('mailto:' + TLabel(Sender).Caption), nil, nil, SW_RESTORE);
  except
  end;
end;

procedure TRMFormAbout.Label4Click(Sender: TObject);
begin
  ShellExecute(0, nil, 'http://www.fast-report.com', nil, nil, SW_RESTORE);
end;

procedure TRMFormAbout.Label8Click(Sender: TObject);
begin
  ShellExecute(0, nil, 'http://home.ccci.org/wolbrink/tnt', nil, nil, SW_RESTORE);
end;

procedure TRMFormAbout.Label10Click(Sender: TObject);
begin
  try
    ShellExecute(0, nil, PChar(TLabel(Sender).Caption), nil, nil, SW_RESTORE);
  except
  end;
end;

procedure TRMFormAbout.Label12Click(Sender: TObject);
begin
  ShellExecute(0, nil, 'http://www.jrsoftware.org/', nil, nil, SW_RESTORE);
end;

end.

