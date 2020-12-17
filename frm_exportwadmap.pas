//------------------------------------------------------------------------------
//
//  DD_TERRAIN: Terrain Generator
//  Copyright (C) 2020 by Jim Valavanis
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, inc., 59 Temple Place - Suite 330, Boston, MA
//  02111-1307, USA.
//
// DESCRIPTION:
//  Export WAD Map Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit frm_exportwadmap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ter_wadexport;

type
  TExportWADMapForm = class(TForm)
    BottomPanel: TPanel;
    ButtonPanel: TPanel;
    OKButton1: TButton;
    CancelButton1: TButton;
    MainPanel: TPanel;
    EngineRadioGroup: TRadioGroup;
    OptionsGroupBox: TGroupBox;
    SlopedSectorsCheckBox: TCheckBox;
    DeformmationsCheckBox: TCheckBox;
    TrueColorFlatCheckBox: TCheckBox;
    MergeFlatSectorsCheckBox: TCheckBox;
    AddPlayerStartCheckBox: TCheckBox;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    CeilingTextureLabel: TLabel;
    Edit2: TEdit;
    SideTextureLabel: TLabel;
    Label3: TLabel;
    FileNameEdit: TEdit;
    SelectFileButton: TSpeedButton;
    GroupBox3: TGroupBox;
    Panel3: TPanel;
    PaintBox1: TPaintBox;
    SaveWADDialog: TSaveDialog;
    procedure SelectFileButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateControls;
  public
    { Public declarations }
  end;

function GetWADExportOptions(const options: exportwadoptions_p): boolean;

implementation

{$R *.dfm}

function GetWADExportOptions(const options: exportwadoptions_p): boolean;
var
  f: TExportWADMapForm;
begin
  Result := False;
  f := TExportWADMapForm.Create(nil);
  try

  finally
    f.Free;
  end;
end;

procedure TExportWADMapForm.SelectFileButtonClick(Sender: TObject);
begin
  if SaveWADDialog.Execute then
    FileNameEdit.Text := SaveWADDialog.FileName;
end;

procedure TExportWADMapForm.UpdateControls;
begin
end;

end.
