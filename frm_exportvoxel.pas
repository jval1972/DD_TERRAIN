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
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, ter_class, ter_voxelexport,
  ter_voxels;

type
  TExportVoxelForm = class(TForm)
    BottomPanel: TPanel;
    ButtonPanel: TPanel;
    OKButton1: TButton;
    CancelButton1: TButton;
    MainPanel: TPanel;
    ConstrainsGroupBox: TGroupBox;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    PreviewGroupBox: TGroupBox;
    Image1: TImage;
    Panel1: TPanel;
    Bevel2: TBevel;
    Label3: TLabel;
    FileNameEdit: TEdit;
    SelectFileButton: TSpeedButton;
    SaveVoxelDialog: TSaveDialog;
    SizeRadioGroup: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FileNameEditChange(Sender: TObject);
    procedure SelectFileButtonClick(Sender: TObject);
  private
    { Private declarations }
    amin, amax: integer;
    sample: TBitmap;
    destroying: boolean;
  protected
    procedure SetMinMax(mn, mx: Integer);
    procedure SetSample(const asample: TBitmap);
    procedure UpdateControls;
  public
    { Public declarations }
  end;

function GetVoxelExportOptions(const t: TTerrain; const buf: voxelbuffer_p;
  const options: exportvoxeloptions_p; var fname: string): boolean;

implementation

{$R *.dfm}

uses
  ter_gl,
  ter_utils;

function GetVoxelExportOptions(const t: TTerrain; const buf: voxelbuffer_p;
  const options: exportvoxeloptions_p; var fname: string): boolean;
var
  f: TExportVoxelForm;
  bm: TBitmap;
  tmpoptions: exportvoxeloptions_t;
  frontview: voxelbuffer2d_p;
  line: PLongWordArray;
  i, j: integer;
begin
  Result := False;
  f := TExportVoxelForm.Create(nil);
  try
    f.FileNameEdit.Text := fname;
    f.TrackBar1.Position := options.minz;
    f.TrackBar2.Position := options.maxz;
    f.SizeRadioGroup.ItemIndex := options.size shr 5;

    tmpoptions.size := 256;
    tmpoptions.minz := 0;
    tmpoptions.maxz := 255;

    Screen.Cursor := crHourglass;
    try
      ExportTerrainToVoxel(t, buf, @tmpoptions);

      bm := TBitmap.Create;
      bm.Width := 256;
      bm.Height := 256;
      bm.PixelFormat := pf32bit;

      GetMem(frontview, SizeOf(voxelbuffer2d_t));
      vox_getviewbuffer(buf, tmpoptions.size, frontview, vv_front);

      for j := 0 to tmpoptions.size - 1 do
      begin
        line := bm.ScanLine[j];
        for i := 0 to tmpoptions.size - 1 do
          line[i] := RGBSwap(frontview[i, j]);
      end;
      FreeMem(frontview, SizeOf(voxelbuffer2d_t));
      f.SetSample(bm);
      bm.Free;
    finally
      Screen.Cursor := crDefault;
    end;

    f.SetMinMax(options.minz, options.maxz);

    if f.ShowModal = mrOK then
    begin
      options.size := 256;
      options.minz := f.amin;
      options.maxz := f.amax;
      options.size := 32 shl f.SizeRadioGroup.ItemIndex;
      fname := f.FileNameEdit.Text;
      Result := True;
    end;
  finally
    f.Free;
  end;
end;

procedure TExportVoxelForm.FormCreate(Sender: TObject);
begin
  destroying := false;
  sample := TBitmap.Create;
  sample.Width := 256;
  sample.Height := 256;
  sample.PixelFormat := pf32bit;
  sample.Canvas.Brush.Style := bsSolid;
  sample.Canvas.Brush.Color := clBlack;
  sample.Canvas.Pen.Style := psSolid;
  sample.Canvas.Pen.Color := clBlack;
  sample.Canvas.FillRect(Rect(0, 0, 255, 255));
  amin := 0;
  amax := 255;
  Image1.Picture.Bitmap.PixelFormat := pf32bit;
  UpdateControls;
end;

procedure TExportVoxelForm.TrackBarChange(Sender: TObject);
var
  mn, mx: integer;
begin
  mn := TrackBar1.Position;
  mx := TrackBar2.Position;
  SetMinMax(mn, mx);
end;

procedure TExportVoxelForm.SetMinMax(mn, mx: Integer);
var
  tmp: integer;
begin
  if mn < 0 then
    mn := 0
  else if mn > 255 then
    mn := 255;

  if mx < 0 then
    mx := 0
  else if mx > 255 then
    mx := 255;

  if mn > mx then
  begin
    tmp := mn;
    mn := mx;
    mx := tmp;
  end;

  if (mn = amin) and (mx = amax) then
    exit;

  amin := mn;
  amax := mx;

  UpdateControls;
end;

procedure TExportVoxelForm.SetSample(const asample: TBitmap);
begin
  if asample = nil then
    Exit;

  sample.Canvas.StretchDraw(Rect(0, 0, 255, 255), asample);
  UpdateControls;
end;

procedure TExportVoxelForm.UpdateControls;
var
  b: TBitmap;
begin
  Label1.Caption := Format('Top: %.*d/255', [3, amin]);
  Label2.Caption := Format('Bottom: %.*d/255', [3, amax]);

  b := TBitmap.Create;
  try
    b.Width := 256;
    b.Height := 256;
    b.PixelFormat := pf32bit;
    b.Canvas.Brush.Style := bsSolid;
    b.Canvas.Brush.Color := clBlack;
    b.Canvas.Pen.Style := psSolid;
    b.Canvas.Pen.Color := clBlack;
    b.Canvas.FillRect(Rect(0, 0, 255, 255));
    if not destroying then
      b.Canvas.StretchDraw(Rect(0, amin, 255, amax), sample);
    b.Canvas.Brush.Style := bsDiagCross;
    b.Canvas.Brush.Color := clBlue;
    b.Canvas.FillRect(Rect(0, 0, 255, amin));
    b.Canvas.FillRect(Rect(0, amax, 255, 255));
    b.Canvas.Pen.Color := clYellow;
    b.Canvas.MoveTo(0, amin);
    b.Canvas.LineTo(255, amin);
    b.Canvas.MoveTo(0, amax);
    b.Canvas.LineTo(255, amax);
    Image1.Picture.Bitmap.Canvas.Draw(0, 0, b);
    Image1.Invalidate;
  finally
    b.Free;
  end;
end;

procedure TExportVoxelForm.FormDestroy(Sender: TObject);
begin
  destroying := true;
  sample.Free;
end;

procedure TExportVoxelForm.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

procedure TExportVoxelForm.FileNameEditChange(Sender: TObject);
var
  uName, uExt: string;
  e: boolean;
begin
  uName := Trim(FileNameEdit.Text);
  e := uName <> '';
  if e then
  begin
    uExt := UpperCase(ExtractFileExt(uName));
    e := (uExt = '.DDVOX') or (uExt = '.VOX');
  end;
  OKButton1.Enabled := e;
end;

procedure TExportVoxelForm.SelectFileButtonClick(Sender: TObject);
begin
  if SaveVoxelDialog.Execute then
  begin
    FileNameEdit.Text := SaveVoxelDialog.FileName;
    OKButton1.Enabled := True;
  end;
end;

end.

