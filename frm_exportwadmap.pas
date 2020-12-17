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
  Dialogs, StdCtrls, ExtCtrls, Buttons, ter_class, ter_wadexport;

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
    DeformationsCheckBox: TCheckBox;
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
    PreviewGroupBox: TGroupBox;
    Panel3: TPanel;
    PaintBox1: TPaintBox;
    SaveWADDialog: TSaveDialog;
    procedure SelectFileButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure DeformationsCheckBoxClick(Sender: TObject);
    procedure MergeFlatSectorsCheckBoxClick(Sender: TObject);
    procedure FileNameEditChange(Sender: TObject);
  private
    { Private declarations }
    bm, bmTexture: TBitmap;
    t: TTerrain;
    fneedstexturerecalc: boolean;
    fneedslinesrecalc: boolean;
    procedure UpdateControls;
    procedure GeneratePreview;
  public
    { Public declarations }
    procedure SetTerrain(const aterrain: TTerrain);
  end;

function GetWADExportOptions(const options: exportwadoptions_p): boolean;

implementation

{$R *.dfm}

uses
  ter_wadreader,
  ter_doomdata,
  ter_utils;

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
  begin
    FileNameEdit.Text := SaveWADDialog.FileName;
    OKButton1.Enabled := True;
  end;
end;

procedure TExportWADMapForm.UpdateControls;
begin
end;

procedure TExportWADMapForm.FormCreate(Sender: TObject);
begin
  bm := TBitmap.Create;
  bm.Width := PaintBox1.Width;
  bm.Height := PaintBox1.Height;
  bm.PixelFormat := pf32bit;

  bmTexture := TBitmap.Create;
  bmTexture.Width := PaintBox1.Width;
  bmTexture.Height := PaintBox1.Height;
  bmTexture.PixelFormat := pf32bit;

  fneedstexturerecalc := true;
  fneedslinesrecalc := true;

  t := nil;
end;

procedure TExportWADMapForm.FormDestroy(Sender: TObject);
begin
  bm.Free;
  bmTexture.Free;
end;

procedure TExportWADMapForm.GeneratePreview;
var
  strm: TMemoryStream;
  flags: LongWord;
  wadreader: TWADReader;
  p: pointer;
  vsize: integer;
  vertexes: Pmapvertex_tArray;
  numvertexes: integer;
  lsize: integer;
  linedefs: Pmaplinedef_tArray;
  numlinedefs: integer;
  scalex, scaley: double;
  i: integer;
  v1, v2: integer;
  x1, y1, x2, y2: integer;
begin
  if t = nil then
    Exit;

  strm := TMemoryStream.Create;

  flags := ETF_DONTEXPORTFLAT;
  if DeformmationsCheckBox.Checked then
    flags := flags or ETF_CALCDXDY;
  if MergeFlatSectorsCheckBox.Checked then
    flags := flags or ETF_MERGEFLATSECTORS;

  ExportTerrainToWADFile(t, strm, 'MAP01', nil, '', '', 0, 0, flags);

  wadreader := TWADReader.Create;
  wadreader.LoadFromStream(strm);
  strm.Free;

  bm.Canvas.Draw(0, 0, bmTexture);

  wadreader.ReadEntry('VERTEXES', p, vsize);
  vertexes := p;
  numvertexes := vsize div SizeOf(mapvertex_t);

  wadreader.ReadEntry('LINEDEFS', p, lsize);
  linedefs := p;
  numlinedefs := lsize div SizeOf(maplinedef_t);

  wadreader.Free;

  scalex := PaintBox1.Width / t.heightmapsize;
  scaley := PaintBox1.Height / t.heightmapsize;

  bm.Canvas.Pen.Color := RGB(0, 255, 0);
  bm.Canvas.Pen.Style := psSolid;
  for i := 0 to numlinedefs - 1 do
  begin
    v1 := linedefs[i].v1;
    v2 := linedefs[i].v2;
    x1 := vertexes[v1].x;
    y1 := vertexes[v1].y;
    x2 := vertexes[v2].x;
    y2 := vertexes[v2].y;
    x1 := GetIntInRange(Round(x1 * scalex), 0, bm.Width);
    y1 := GetIntInRange(-Round(y1 * scaley), 0, bm.Height);
    x2 := GetIntInRange(Round(x2 * scalex), 0, bm.Width);
    y2 := GetIntInRange(-Round(y2 * scaley), 0, bm.Height);
    bm.Canvas.MoveTo(x1, y1);
    bm.Canvas.LineTo(x2, y2);
  end;

  // Draw 2d map here ////////
  FreeMem(vertexes, vsize);
  FreeMem(linedefs, lsize);
end;

procedure TExportWADMapForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, bm);
end;

procedure TExportWADMapForm.SetTerrain(const aterrain: TTerrain);
var
  r: TRect;
begin
  t := aterrain;
  r := Rect(0, 0, bm.Width, bm.Height);
  if t <> nil then
    bm.Canvas.StretchDraw(r, t.Texture)
  else
  begin
    bm.Canvas.Brush.Color := RGB(255, 255, 255);
    bm.Canvas.Brush.Style := bsSolid;
    bm.Canvas.Pen.Style := psClear;
    bm.Canvas.FillRect(r);
  end;
  GeneratePreview;
end;

procedure TExportWADMapForm.DeformationsCheckBoxClick(Sender: TObject);
begin
  fneedslinesrecalc := true;
  GeneratePreview;
  PaintBox1.Invalidate;
end;

procedure TExportWADMapForm.MergeFlatSectorsCheckBoxClick(Sender: TObject);
begin
  fneedslinesrecalc := true;
  GeneratePreview;
  PaintBox1.Invalidate;
end;

procedure TExportWADMapForm.FileNameEditChange(Sender: TObject);
begin
    OKButton1.Enabled := Trim(FileNameEdit.Text) <> '';
end;

end.
