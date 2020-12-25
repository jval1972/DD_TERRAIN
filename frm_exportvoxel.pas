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
//  Export Voxel Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit frm_exportvoxel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons;

type
  TExportVoxelForm = class(TForm)
    MainPanel: TPanel;
    Label3: TLabel;
    SelectFileButton: TSpeedButton;
    Label1: TLabel;
    CeilingHeightLabel: TLabel;
    Label2: TLabel;
    LightLevelLabel: TLabel;
    LayerStepLabel: TLabel;
    Label5: TLabel;
    EngineRadioGroup: TRadioGroup;
    OptionsGroupBox: TGroupBox;
    DeformationsCheckBox: TCheckBox;
    TrueColorFlatCheckBox: TCheckBox;
    MergeFlatSectorsCheckBox: TCheckBox;
    AddPlayerStartCheckBox: TCheckBox;
    ExportFlatCheckBox: TCheckBox;
    FileNameEdit: TEdit;
    PreviewGroupBox: TGroupBox;
    Panel3: TPanel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel2: TPanel;
    StatThingsEdit1: TEdit;
    StatLinedefsEdit1: TEdit;
    StatSidedefsEdit1: TEdit;
    StatVertexesEdit1: TEdit;
    StatSectorsEdit1: TEdit;
    CeilingHeightTrackBar: TTrackBar;
    GameRadioGroup: TRadioGroup;
    ElevationRadioGroup: TRadioGroup;
    LightLevalTrackBar: TTrackBar;
    LayerStepTrackBar: TTrackBar;
    BottomPanel: TPanel;
    ButtonPanel: TPanel;
    OKButton1: TButton;
    CancelButton1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExportVoxelForm: TExportVoxelForm;

implementation

{$R *.dfm}

end.
