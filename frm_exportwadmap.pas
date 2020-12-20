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
  Dialogs, StdCtrls, ExtCtrls, Buttons, ter_class, ter_wadexport, ComCtrls;

type
  TExportWADMapForm = class(TForm)
    BottomPanel: TPanel;
    ButtonPanel: TPanel;
    OKButton1: TButton;
    CancelButton1: TButton;
    MainPanel: TPanel;
    EngineRadioGroup: TRadioGroup;
    OptionsGroupBox: TGroupBox;
    DeformationsCheckBox: TCheckBox;
    TrueColorFlatCheckBox: TCheckBox;
    MergeFlatSectorsCheckBox: TCheckBox;
    AddPlayerStartCheckBox: TCheckBox;
    Label3: TLabel;
    FileNameEdit: TEdit;
    SelectFileButton: TSpeedButton;
    PreviewGroupBox: TGroupBox;
    Panel3: TPanel;
    PaintBox1: TPaintBox;
    SaveWADDialog: TSaveDialog;
    ExportFlatCheckBox: TCheckBox;
    Label1: TLabel;
    CeilingHeightTrackBar: TTrackBar;
    CeilingHeightLabel: TLabel;
    GameRadioGroup: TRadioGroup;
    ElevationRadioGroup: TRadioGroup;
    procedure SelectFileButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure DeformationsCheckBoxClick(Sender: TObject);
    procedure MergeFlatSectorsCheckBoxClick(Sender: TObject);
    procedure FileNameEditChange(Sender: TObject);
    procedure ExportFlatCheckBoxClick(Sender: TObject);
    procedure CeilingHeightTrackBarChange(Sender: TObject);
    procedure ElevationRadioGroupClick(Sender: TObject);
  private
    { Private declarations }
    bm, bmTexture: TBitmap;
    t: TTerrain;
    procedure GeneratePreview;
    procedure GenerateFlatTexture;
  public
    { Public declarations }
    procedure SetTerrain(const aterrain: TTerrain);
  end;

function GetWADExportOptions(const t: TTerrain; const options: exportwadoptions_p; var fname: string): boolean;

implementation

{$R *.dfm}

uses
  ter_wadreader,
  ter_doomdata,
  ter_utils,
  ter_palettes,
  ter_contour;

function GetWADExportOptions(const t: TTerrain; const options: exportwadoptions_p; var fname: string): boolean;
var
  f: TExportWADMapForm;
begin
  Result := False;
  f := TExportWADMapForm.Create(nil);
  try
    f.FileNameEdit.Text := fname;
    f.EngineRadioGroup.ItemIndex := options.engine;
    f.GameRadioGroup.ItemIndex := options.game;
    f.ElevationRadioGroup.ItemIndex := options.elevationmethod;
    f.CeilingHeightTrackBar.Position := GetIntInRange(options.defceilingheight, f.CeilingHeightTrackBar.Min, f.CeilingHeightTrackBar.Max);
    f.CeilingHeightLabel.Caption := IntToStr(f.CeilingHeightTrackBar.Position);
    f.DeformationsCheckBox.Checked := options.flags and ETF_CALCDXDY <> 0;
    f.TrueColorFlatCheckBox.Checked := options.flags and ETF_TRUECOLORFLAT <> 0;
    f.MergeFlatSectorsCheckBox.Checked := options.flags and ETF_MERGEFLATSECTORS <> 0;
    f.AddPlayerStartCheckBox.Checked := options.flags and ETF_ADDPLAYERSTART <> 0;
    f.ExportFlatCheckBox.Checked := options.flags and ETF_EXPORTFLAT <> 0;

    f.SetTerrain(t);

    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      Result := True;
      fname := f.FileNameEdit.Text;
      options.engine := f.EngineRadioGroup.ItemIndex;
      options.game := f.GameRadioGroup.ItemIndex;
      options.elevationmethod := f.ElevationRadioGroup.ItemIndex;
      options.defceilingheight := f.CeilingHeightTrackBar.Position;
      options.flags := 0;
      if f.DeformationsCheckBox.Checked then
        options.flags := options.flags or ETF_CALCDXDY;
      if f.TrueColorFlatCheckBox.Checked then
        options.flags := options.flags or ETF_TRUECOLORFLAT;
      if f.MergeFlatSectorsCheckBox.Checked then
        options.flags := options.flags or ETF_MERGEFLATSECTORS;
      if f.AddPlayerStartCheckBox.Checked then
        options.flags := options.flags or ETF_ADDPLAYERSTART;
      if f.ExportFlatCheckBox.Checked then
        options.flags := options.flags or ETF_EXPORTFLAT;

      case options.game of
      GAME_RADIX:
        begin
          options.palette := @RadixPaletteRaw;
          options.levelname := 'E1M1';
          options.defsidetex := 'RDXW0012';
          options.defceilingtex := 'F_SKY1';
        end;
      GAME_DOOM:
        begin
          options.palette := @DoomPaletteRaw;
          options.levelname := 'MAP01';
          options.defsidetex := 'METAL1';
          options.defceilingtex := 'F_SKY1';
        end;
      GAME_HERETIC:
        begin
          options.palette := @HereticPaletteRaw;
          options.levelname := 'E1M1';
          options.defsidetex := 'CSTLRCK';
          options.defceilingtex := 'F_SKY1';
        end;
      GAME_HEXEN:
        begin
          options.palette := @HexenPaletteRaw;
          options.levelname := 'MAP01';
          options.defsidetex := 'FOREST02';
          options.defceilingtex := 'F_SKY';
        end;
      GAME_STRIFE:
        begin
          options.palette := @StrifePaletteRaw;
          options.levelname := 'MAP01';
          options.defsidetex := 'BRKGRY01';
          options.defceilingtex := 'F_SKY001';
        end;
      end;

      case options.engine of
      ENGINE_RAD:
        begin
          if options.game = GAME_RADIX then
          begin
            options.lowerid := 1255;
            options.raiseid := 1254;
          end
          else
          begin
            options.lowerid := 1155;
            options.raiseid := 1154;
          end;
        end;
      ENGINE_UDMF:
        begin
        end;
      ENGINE_VAVOOM:
        begin
          options.flags := options.flags or ETF_HEXENHEIGHT;
          options.raiseid := 1504;
          options.lowerid := 1504;
        end;
      end;
    end;
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
  tmpoptions: exportwadoptions_t;
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
  bm.Canvas.Draw(0, 0, bmTexture);

  if t <> nil then
  begin
    strm := TMemoryStream.Create;

    ZeroMemory(@tmpoptions, SizeOf(exportwadoptions_t));
    tmpoptions.elevationmethod := ElevationRadioGroup.ItemIndex;
    tmpoptions.flags := 0;
    if DeformationsCheckBox.Checked then
      tmpoptions.flags := tmpoptions.flags or ETF_CALCDXDY;
    if MergeFlatSectorsCheckBox.Checked then
      tmpoptions.flags := tmpoptions.flags or ETF_MERGEFLATSECTORS;

    ExportTerrainToWADFile(t, strm, @tmpoptions);

    wadreader := TWADReader.Create;
    strm.Position := 0;
    wadreader.LoadFromStream(strm);
    strm.Free;

    wadreader.ReadEntry('VERTEXES', p, vsize);
    vertexes := p;
    numvertexes := vsize div SizeOf(mapvertex_t);

    wadreader.ReadEntry('LINEDEFS', p, lsize);
    linedefs := p;
    numlinedefs := lsize div SizeOf(maplinedef_t);

    wadreader.Free;

    scalex := PaintBox1.Width / t.texturesize;
    scaley := PaintBox1.Height / t.texturesize;

    bm.Canvas.Pen.Color := RGB(0, 255, 0);
    bm.Canvas.Pen.Style := psSolid;
    // Draw 2d map
    for i := 0 to numlinedefs - 1 do
    begin
      v1 := linedefs[i].v1;
      v2 := linedefs[i].v2;
      if IsIntInRange(v1, 0, numvertexes - 1) and IsIntInRange(v2, 0, numvertexes - 1) then
      begin
        x1 := vertexes[v1].x;
        y1 := vertexes[v1].y;
        x2 := vertexes[v2].x;
        y2 := vertexes[v2].y;
        x1 := GetIntInRange(Round(x1 * scalex), 0, bm.Width - 1);
        y1 := GetIntInRange(-Round(y1 * scaley), 0, bm.Height - 1);
        x2 := GetIntInRange(Round(x2 * scalex), 0, bm.Width - 1);
        y2 := GetIntInRange(-Round(y2 * scaley), 0, bm.Height - 1);
        bm.Canvas.MoveTo(x1, y1);
        bm.Canvas.LineTo(x2, y2);
      end;
    end;

    FreeMem(vertexes, vsize);
    FreeMem(linedefs, lsize);
  end;
end;

procedure TExportWADMapForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, bm);
end;

procedure TExportWADMapForm.GenerateFlatTexture;
var
  r: TRect;
begin
  r := Rect(0, 0, bm.Width, bm.Height);
  if (t <> nil) and ExportFlatCheckBox.Checked then
    bmTexture.Canvas.StretchDraw(r, t.Texture)
  else
  begin
    bmTexture.Canvas.Brush.Color := RGB(255, 255, 255);
    bmTexture.Canvas.Brush.Style := bsSolid;
    bmTexture.Canvas.Pen.Style := psClear;
    bmTexture.Canvas.FillRect(r);
  end;
end;

procedure TExportWADMapForm.SetTerrain(const aterrain: TTerrain);
begin
  t := aterrain;
  GenerateFlatTexture;
  GeneratePreview;
  PaintBox1.Invalidate;
end;

procedure TExportWADMapForm.DeformationsCheckBoxClick(Sender: TObject);
begin
  GeneratePreview;
  PaintBox1.Invalidate;
end;

procedure TExportWADMapForm.MergeFlatSectorsCheckBoxClick(Sender: TObject);
begin
  GeneratePreview;
  PaintBox1.Invalidate;
end;

procedure TExportWADMapForm.FileNameEditChange(Sender: TObject);
begin
  OKButton1.Enabled := Trim(FileNameEdit.Text) <> '';
end;

procedure TExportWADMapForm.ExportFlatCheckBoxClick(Sender: TObject);
begin
  GenerateFlatTexture;
  GeneratePreview;
  PaintBox1.Invalidate;
end;

procedure TExportWADMapForm.CeilingHeightTrackBarChange(Sender: TObject);
begin
  CeilingHeightLabel.Caption := IntToStr(CeilingHeightTrackBar.Position);
  CeilingHeightTrackBar.Hint := IntToStr(CeilingHeightTrackBar.Position);
end;

procedure TExportWADMapForm.ElevationRadioGroupClick(Sender: TObject);
begin
  GeneratePreview;
  PaintBox1.Invalidate;
end;

end.
