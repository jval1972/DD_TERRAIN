//------------------------------------------------------------------------------
//
//  DD_TERRAIN: Terrain Generator
//  Copyright (C) 2020-2021 by Jim Valavanis
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
//  Voxel export
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_voxelexport;

interface

uses
  ter_class,
  ter_voxels;

type
  exportvoxeloptions_t = record
    size: integer;
    minz, maxz: byte;
  end;
  exportvoxeloptions_p = ^exportvoxeloptions_t;

procedure ExportTerrainToVoxel(const t: TTerrain; const buf: voxelbuffer_p;
  const options: exportvoxeloptions_p);

implementation

uses
  Windows,
  Classes,
  Graphics,
  ter_gl,
  ter_utils;

procedure ExportTerrainToVoxel(const t: TTerrain; const buf: voxelbuffer_p;
  const options: exportvoxeloptions_p);
var
  bmh: bitmapheightmap_p;
  i, j, k: integer;
  vmap: array[0..255, 0..255] of integer;
  fscale1: Extended;
  c: LongWord;
  bm: TBitmap;
  line: PLongWordArray;
begin
  // Allocate hi-res heightmap buffer
  GetMem(bmh, SizeOf(bitmapheightmap_t));

  // Logical check of size
  if options.size > MAXVOXELSIZE then
    options.size := MAXVOXELSIZE;

  // Generate hi-res heightmap buffer
  t.GenerateBitmapHeightmap(bmh, options.size);

  // Generate heightmap lookup
  if options.size = MAXVOXELSIZE then
  begin
    for i := 0 to 255 do
      for j := 0 to 255 do
      begin
        k := GetIntInRange(Round(128 + bmh[i, 255 - j] * 128 / HEIGHTMAPRANGE), 0, 255);
        vmap[i, j] := k;
      end;
  end
  else
  begin
    fscale1 := options.size / 256;
    for i := 0 to options.size - 1 do
      for j := 0 to options.size - 1 do
      begin
        k := GetIntInRange(Round(128 + bmh[i, options.size - j] * 128 / HEIGHTMAPRANGE), 0, 255);
        vmap[i, j] := round(k * fscale1);
        if vmap[i, j] >= options.size then
          vmap[i, j] := options.size - 1
        else if vmap[i, j] < 0 then
          vmap[i, j] := 0;
      end;
  end;

  bm := TBitmap.Create;
  bm.Width := options.size;
  bm.Height := options.size;
  bm.PixelFormat := pf32bit;
  bm.Canvas.StretchDraw(Rect(0, 0, options.size, options.size), t.Texture);
  FlipBitmapVertical(bm);

  for j := 0 to options.size - 1 do
  begin
    line := bm.ScanLine[j];
    for i := 0 to options.size - 1 do
    begin
      c := RGBSwap(line[i]);
      if c = 0 then
        c := $1;
      for k := 0 to vmap[i, j] do
        buf[i, options.size - k - 1, j] := c
    end;
  end;

  bm.Free;

  // Scale elevation data
  vox_shrinkyaxis(buf, options.size, options.minz, options.maxz);

  // Remove non visible voxels
  vox_removenonvisiblecells(buf, options.size);

  FreeMem(bmh, SizeOf(bitmapheightmap_t));
end;

end.

