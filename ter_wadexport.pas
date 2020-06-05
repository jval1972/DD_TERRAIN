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
//  WAD Export
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_wadexport;

interface

uses
  SysUtils,
  Classes,
  ter_class,
  ter_utils,
  ter_wad;

procedure ExportTerrainToWADFile(const t: TTerrain; const fname: string;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const flags: LongWord; const defceilingheight: integer = 512);

const
  ETF_SLOPED = 1;
  ETF_CALCDXDY = 2;

implementation

uses
  Graphics,
  ter_doomdata,
  ter_wadwriter;

function V_FindAproxColorIndex(const pal: PLongWordArray; const c: LongWord;
  const start: integer = 0; const finish: integer = 255): integer;
var
  r, g, b: integer;
  rc, gc, bc: integer;
  dr, dg, db: integer;
  i: integer;
  cc: LongWord;
  dist: LongWord;
  mindist: LongWord;
begin
  r := c and $FF;
  g := (c shr 8) and $FF;
  b := (c shr 16) and $FF;
  result := start;
  mindist := LongWord($ffffffff);
  for i := start to finish do
  begin
    cc := pal[i];
    rc := cc and $FF;
    gc := (cc shr 8) and $FF;
    bc := (cc shr 16) and $FF;
    dr := r - rc;
    dg := g - gc;
    db := b - bc;
    dist := dr * dr + dg * dg + db * db;
    if dist < mindist then
    begin
      result := i;
      if dist = 0 then
        exit
      else
        mindist := dist;
    end;
  end;
end;

procedure ExportTerrainToWADFile(const t: TTerrain; const fname: string;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const flags: LongWord; const defceilingheight: integer = 512);
var
  doomthings: Pmapthing_tArray;
  numdoomthings: integer;
  doomlinedefs: Pmaplinedef_tArray;
  numdoomlinedefs: integer;
  doomsidedefs: Pmapsidedef_tArray;
  numdoomsidedefs: integer;
  doomvertexes: Pmapvertex_tArray;
  numdoomvertexes: integer;
  doomsectors: Pmapsector_tArray;
  numdoomsectors: integer;
  wadwriter: TWadWriter;
  def_palL: array[0..255] of LongWord;
  i, x, y: integer;
  c, r, g, b: LongWord;
  flat: PByteArray;
  bm: TBitmap;
  sidetex: char8_t;

  function AddThingToWad(const x, y: integer; const angle: smallint; const mtype: word; const options: smallint): integer;
  var
    j: integer;
    mthing: Pmapthing_t;
  begin
    for j := 0 to numdoomthings - 1 do
      if (doomthings[j].x = x) and (doomthings[j].y = y) and (doomthings[j].angle = angle) and
         (doomthings[j]._type = mtype) and (doomthings[j].options = options) then
      begin
        result := j;
        exit;
      end;

    ReallocMem(doomthings, (numdoomthings + 1) * SizeOf(mapthing_t));
    mthing := @doomthings[numdoomthings];

    mthing.x := x;
    mthing.y := y;

    mthing.angle := angle;
    mthing._type := mtype;
    mthing.options := options;

    result := numdoomthings;
    inc(numdoomthings);
  end;

  function AddSectorToWAD(const hfloor, hceiling: integer): integer;
  var
    dsec: Pmapsector_t;
  begin
    ReallocMem(doomsectors, (numdoomsectors  + 1) * SizeOf(mapsector_t));
    dsec := @doomsectors[numdoomsectors];
    dsec.floorheight := hfloor;
    dsec.ceilingheight := hceiling;
    dsec.floorpic := stringtochar8(levelname + 'TER');
    dsec.ceilingpic := stringtochar8('F_SKY1');
    dsec.lightlevel := 192;
    dsec.special := 0;
    dsec.tag := 0;

    result := numdoomsectors;
    inc(numdoomsectors);
  end;

  function AddVertexToWAD(const x, y: smallint): integer;
  var
    j: integer;
  begin
    for j := 0 to numdoomvertexes - 1 do
      if (doomvertexes[j].x = x) and (doomvertexes[j].y = y) then
      begin
        result := j;
        exit;
      end;
    ReallocMem(doomvertexes, (numdoomvertexes  + 1) * SizeOf(mapvertex_t));
    doomvertexes[numdoomvertexes].x := x;
    doomvertexes[numdoomvertexes].y := y;
    result := numdoomvertexes;
    inc(numdoomvertexes);
  end;

  function AddSidedefToWAD(const sector: smallint; const force_new: boolean = true): integer;
  var
    j: integer;
    pside: Pmapsidedef_t;
  begin
    if not force_new then // JVAL: 20200309 - If we pack sidedefs of radix level, the triggers may not work :(
      for j := 0 to numdoomsidedefs - 1 do
        if doomsidedefs[j].sector = sector then
        begin
          result := j;
          exit;
        end;

    ReallocMem(doomsidedefs, (numdoomsidedefs  + 1) * SizeOf(mapsidedef_t));
    pside := @doomsidedefs[numdoomsidedefs];
    pside.textureoffset := 0;
    pside.rowoffset := 0;
    pside.toptexture := stringtochar8('-');
    pside.bottomtexture := stringtochar8('-');
    pside.midtexture := stringtochar8('-');
    pside.sector := sector;
    result := numdoomsidedefs;
    inc(numdoomsidedefs);
  end;

  function AddLinedefToWAD(const v1, v2: integer): integer;
  var
    j: integer;
    pline: Pmaplinedef_t;
  begin
    for j := 0 to numdoomlinedefs - 1 do
    begin
      pline := @doomlinedefs[j];
      if (pline.v1 = v1) and (pline.v2 = v2) then
        if pline.sidenum[1] < 0 then
        begin
          result := j;
          exit;
        end;
      if (pline.v1 = v2) and (pline.v2 = v1) then
        if pline.sidenum[1] < 0 then
        begin
          result := j;
          exit;
        end;
    end;

    ReallocMem(doomlinedefs, (numdoomlinedefs  + 1) * SizeOf(maplinedef_t));
    pline := @doomlinedefs[numdoomlinedefs];
    pline.v1 := v1;
    pline.v2 := v2;
    pline.flags := 0;
    pline.special := 0;
    pline.tag := 0;
    pline.sidenum[0] := -1;
    pline.sidenum[1] := -1;
    result := numdoomlinedefs;
    inc(numdoomlinedefs);
  end;

  function GetHeightmapCoords3D(const iX, iY: integer): point3d_t;
  begin
    if flags and ETF_CALCDXDY <> 0 then
      Result := t.HeightmapCoords3D(iX, iY)
    else
    begin
      Result.X := t.HeightmapToCoord(iX);
      Result.Y := t.HeightmapToCoord(iY);
      Result.Z := t.Heightmap[iX, iY].height;
    end;
  end;

  procedure AddSlopedTriangleToWAD(const iX1, iY1, iX2, iY2, iX3, iY3: integer);
  var
    v1, v2, v3: integer;
    p1, p2, p3: point3d_t;
    l1, l2, l3: integer;
    sec: integer;
  begin
    p1 := GetHeightmapCoords3D(iX1, iY1);
    p2 := GetHeightmapCoords3D(iX2, iY2);
    p3 := GetHeightmapCoords3D(iX3, iY3);
    sec := AddSectorToWAD(0, defceilingheight);
    v1 := AddVertexToWAD(p1.X, -p1.Y);
    v2 := AddVertexToWAD(p2.X, -p2.Y);
    v3 := AddVertexToWAD(p3.X, -p3.Y);
    l1 := AddLinedefToWAD(v1, v2);
    l2 := AddLinedefToWAD(v2, v3);
    l3 := AddLinedefToWAD(v3, v1);
    if doomlinedefs[l1].sidenum[0] < 0 then
      doomlinedefs[l1].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l1].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l1].flags := doomlinedefs[l1].flags or ML_TWOSIDED;
    end;
    if doomlinedefs[l2].sidenum[0] < 0 then
      doomlinedefs[l2].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l2].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l2].flags := doomlinedefs[l2].flags or ML_TWOSIDED;
    end;
    if doomlinedefs[l3].sidenum[0] < 0 then
      doomlinedefs[l3].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l3].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l3].flags := doomlinedefs[l3].flags or ML_TWOSIDED;
    end;
    if p1.Z < 0 then
      AddThingToWad(p1.X, -p1.Y, -p1.Z, 1255, MTF_EASY or MTF_NORMAL or MTF_HARD)
    else if p1.Z > 0 then
      AddThingToWad(p1.X, -p1.Y, p1.Z, 1254, MTF_EASY or MTF_NORMAL or MTF_HARD);
    if p2.Z < 0 then
      AddThingToWad(p2.X, -p2.Y, -p2.Z, 1255, MTF_EASY or MTF_NORMAL or MTF_HARD)
    else if p1.Z > 0 then
      AddThingToWad(p2.X, -p2.Y, p2.Z, 1254, MTF_EASY or MTF_NORMAL or MTF_HARD);
    if p3.Z < 0 then
      AddThingToWad(p3.X, -p3.Y, -p3.Z, 1255, MTF_EASY or MTF_NORMAL or MTF_HARD)
    else if p1.Z > 0 then
      AddThingToWad(p3.X, -p3.Y, p3.Z, 1254, MTF_EASY or MTF_NORMAL or MTF_HARD);
  end;

  procedure AddQuadToWAD(const iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4: integer);
  var
    v1, v2, v3, v4: integer;
    p1, p2, p3, p4: point3d_t;
    l1, l2, l3, l4: integer;
    sec: integer;
  begin
    p1 := GetHeightmapCoords3D(iX1, iY1);
    p2 := GetHeightmapCoords3D(iX2, iY2);
    p3 := GetHeightmapCoords3D(iX3, iY3);
    p4 := GetHeightmapCoords3D(iX4, iY4);
    sec := AddSectorToWAD(p1.Z, defceilingheight);
    v1 := AddVertexToWAD(p1.X, -p1.Y);
    v2 := AddVertexToWAD(p2.X, -p2.Y);
    v3 := AddVertexToWAD(p3.X, -p3.Y);
    v4 := AddVertexToWAD(p4.X, -p4.Y);
    l1 := AddLinedefToWAD(v1, v2);
    l2 := AddLinedefToWAD(v2, v3);
    l3 := AddLinedefToWAD(v3, v4);
    l4 := AddLinedefToWAD(v4, v1);
    if doomlinedefs[l1].sidenum[0] < 0 then
      doomlinedefs[l1].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l1].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l1].flags := doomlinedefs[l1].flags or ML_TWOSIDED;
    end;
    if doomlinedefs[l2].sidenum[0] < 0 then
      doomlinedefs[l2].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l2].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l2].flags := doomlinedefs[l2].flags or ML_TWOSIDED;
    end;
    if doomlinedefs[l3].sidenum[0] < 0 then
      doomlinedefs[l3].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l3].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l3].flags := doomlinedefs[l3].flags or ML_TWOSIDED;
    end;
    if doomlinedefs[l4].sidenum[0] < 0 then
      doomlinedefs[l4].sidenum[0] := AddSidedefToWAD(sec)
    else
    begin
      doomlinedefs[l4].sidenum[1] := AddSidedefToWAD(sec);
      doomlinedefs[l4].flags := doomlinedefs[l4].flags or ML_TWOSIDED;
    end;
  end;

  procedure AddHeightmapitemToWAD(const iX, iY: integer);
  begin
    if flags and ETF_SLOPED <> 0 then
    begin
      AddSlopedTriangleToWAD(iX, iY, iX + 1, iY, iX, iY + 1);
      AddSlopedTriangleToWAD(iX, iY + 1, iX + 1, iY, iX + 1, iY + 1);
    end
    else
      AddQuadToWAD(iX, iY, iX + 1, iY, iX + 1, iY + 1, iX, iY + 1)
  end;

begin
  sidetex := stringtochar8(defsidetex);

  doomthings := nil;
  numdoomthings := 0;
  doomlinedefs := nil;
  numdoomlinedefs := 0;
  doomsidedefs := nil;
  numdoomsidedefs := 0;
  doomvertexes := nil;
  numdoomvertexes := 0;
  doomsectors := nil;
  numdoomsectors := 0;

  wadwriter := TWadWriter.Create;

  // Create Palette
  for i := 0 to 255 do
  begin
    r := palette[3 * i];
    if r > 255 then r := 255;
    g := palette[3 * i + 1];
    if g > 255 then g := 255;
    b := palette[3 * i + 2];
    if b > 255 then b := 255;
    def_palL[i] := (r shl 16) + (g shl 8) + (b);
  end;

  // Create flat
  bm := t.Texture;
  GetMem(flat, bm.Width * bm.Height);

  i := 0;
  for y := 0 to t.texturesize - 1 do
    for x := 0 to t.texturesize - 1 do
    begin
      c := bm.Canvas.Pixels[x, y];
      flat[i] := V_FindAproxColorIndex(@def_palL, c);
      inc(i);
    end;

  wadwriter.AddSeparator('F_START');
  wadwriter.AddData(levelname + 'TER', flat, bm.Width * bm.Height);
  wadwriter.AddSeparator('F_END');

  FreeMem(flat, bm.Width * bm.Height);

  // Create Map
  for x := 0 to t.heightmapsize - 2 do
    for y := 0 to t.heightmapsize - 2 do
      AddHeightmapitemToWAD(x, y);

  // Add wall textures
  for i := 0 to numdoomlinedefs - 1 do
  begin
    if doomlinedefs[i].flags and ML_TWOSIDED = 0 then
      doomsidedefs[doomlinedefs[i].sidenum[0]].midtexture := sidetex
    else
    begin
      doomsidedefs[doomlinedefs[i].sidenum[0]].bottomtexture := sidetex;
      doomsidedefs[doomlinedefs[i].sidenum[1]].bottomtexture := sidetex;
    end;
  end;

  // Flash data to wad
  wadwriter.AddSeparator(levelname);
  wadwriter.AddData('THINGS', doomthings, numdoomthings * SizeOf(mapthing_t));
  wadwriter.AddData('LINEDEFS', doomlinedefs, numdoomlinedefs * SizeOf(maplinedef_t));
  wadwriter.AddData('SIDEDEFS', doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
  wadwriter.AddData('VERTEXES', doomvertexes, numdoomvertexes * SizeOf(mapvertex_t));
  wadwriter.AddSeparator('SEGS');
  wadwriter.AddSeparator('SSECTORS');
  wadwriter.AddSeparator('NODES');
  wadwriter.AddData('SECTORS', doomsectors, numdoomsectors * SizeOf(mapsector_t));
  wadwriter.AddSeparator('REJECT');
  wadwriter.AddSeparator('BLOCKMAP');

  // Save wad to disk
  wadwriter.SaveToFile(fname);

  wadwriter.Free;

  // Free data
  FreeMem(doomthings, numdoomthings * SizeOf(mapthing_t));
  FreeMem(doomlinedefs, numdoomlinedefs * SizeOf(maplinedef_t));
  FreeMem(doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
  FreeMem(doomvertexes, numdoomvertexes * SizeOf(mapvertex_t));
  FreeMem(doomsectors, numdoomsectors * SizeOf(mapsector_t));
end;

end.
