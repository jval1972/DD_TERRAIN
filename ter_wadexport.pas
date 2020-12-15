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
  pngimage1,
  ter_class,
  ter_utils,
  ter_wad;

procedure ExportTerrainToWADFile(const t: TTerrain; const fname: string;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const _LOWERID, _RAISEID: integer;
  const flags: LongWord; const defceilingheight: integer = 512);

procedure ExportTerrainToUDMFFile(const t: TTerrain; const fname: string;
  const levelname: string; const defsidetex: string;
  const flags: LongWord; const defceilingheight: integer = 512);

const
  ETF_SLOPED = 1;
  ETF_CALCDXDY = 2;
  ETF_TRUECOLORFLAT = 3;
  ETF_MERGEFLATSECTORS = 4;

implementation

uses
  Windows,
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

type
  TBooleanArray = packed array[0..$FFF] of boolean;
  PBooleanArray = ^TBooleanArray;

procedure ExportTerrainToWADFile(const t: TTerrain; const fname: string;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const _LOWERID, _RAISEID: integer;
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
  slopedsectors: PBooleanArray;
  numdoomsectors: integer;
  wadwriter: TWadWriter;
  def_palL: array[0..255] of LongWord;
  scanline: PLongWordArray;
  i, x, y: integer;
  c, r, g, b: LongWord;
  png: TPngObject;
  ms: TMemoryStream;
  flattexture: PByteArray;
  bm: TBitmap;
  sidetex: char8_t;
  pass: array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of boolean;
  flat: array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of boolean;

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

  function AddSectorToWAD(const hfloor, hceiling: integer; const sloped: boolean): integer;
  var
    j: integer;
    dsec: Pmapsector_t;
  begin
    if not sloped then
    begin
      for j := 0 to numdoomsectors - 1 do
        if not slopedsectors[j] then
        begin
          dsec := @doomsectors[j];
          if (dsec.floorheight = hfloor) and (dsec.ceilingheight = hceiling) then
          begin
            Result := j;
            Exit;
          end;
        end;
    end;

    ReallocMem(doomsectors, (numdoomsectors  + 1) * SizeOf(mapsector_t));
    ReallocMem(slopedsectors, (numdoomsectors  + 1) * SizeOf(boolean));
    dsec := @doomsectors[numdoomsectors];
    dsec.floorheight := hfloor;
    dsec.ceilingheight := hceiling;
    dsec.floorpic := stringtochar8(levelname + 'TER');
    dsec.ceilingpic := stringtochar8('F_SKY1');
    dsec.lightlevel := 192;
    dsec.special := 0;
    dsec.tag := 0;
    slopedsectors[numdoomsectors] := sloped;

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

  procedure AddFlatQuadToWAD(const iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4: integer);
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
    sec := AddSectorToWAD((p1.Z + p2.Z + p3.Z + p4.Z) div 4, defceilingheight, False);
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

  function TryFlatRange(const iX1, iY1: integer): boolean;
  var
    p1, p2, p3, p4: point3d_t;
    iX2, iY2: integer;
    iX3, iY3: integer;
    iX4, iY4: integer;
  begin
    Result := False;

    p1 := GetHeightmapCoords3D(iX1, iY1);
    iX2 := iX1 + 1;
    iY2 := iY1;
    p2 := GetHeightmapCoords3D(iX2, iY2);
    if p1.Z <> p2.Z then
      Exit;
    iX3 := iX1 + 1;
    iY3 := iY1 + 1;
    p3 := GetHeightmapCoords3D(iX3, iY3);
    if p1.Z <> p3.Z then
      Exit;
    iX4 := iX1;
    iY4 := iY1 + 1;
    p4 := GetHeightmapCoords3D(iX4, iY4);
    if p1.Z <> p4.Z then
      Exit;
    AddFlatQuadToWAD(iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4);
    flat[iX1, iY1] := true;

    Result := True;
  end;

  procedure AddSlopedTriangleToWAD(const iX1, iY1, iX2, iY2, iX3, iY3: integer);
  var
    v1, v2, v3: integer;
    p1, p2, p3: point3d_t;
    l1, l2, l3: integer;
    sec: integer;
    issloped: boolean;
  begin
    p1 := GetHeightmapCoords3D(iX1, iY1);
    p2 := GetHeightmapCoords3D(iX2, iY2);
    p3 := GetHeightmapCoords3D(iX3, iY3);
    issloped := (p1.Z <> p2.Z) or (p1.Z <> p3.Z);
    if issloped then
      sec := AddSectorToWAD(0, defceilingheight, True)
    else
      sec := AddSectorToWAD(p1.Z, defceilingheight, False);
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
    if issloped then
    begin
      if p1.Z < 0 then
        AddThingToWad(p1.X, -p1.Y, -p1.Z, _LOWERID {1255}, MTF_EASY or MTF_NORMAL or MTF_HARD)
      else
        AddThingToWad(p1.X, -p1.Y, p1.Z, _RAISEID {1254}, MTF_EASY or MTF_NORMAL or MTF_HARD);
      if p2.Z < 0 then
        AddThingToWad(p2.X, -p2.Y, -p2.Z, _LOWERID {1255}, MTF_EASY or MTF_NORMAL or MTF_HARD)
      else
        AddThingToWad(p2.X, -p2.Y, p2.Z, _RAISEID {1254}, MTF_EASY or MTF_NORMAL or MTF_HARD);
      if p3.Z < 0 then
        AddThingToWad(p3.X, -p3.Y, -p3.Z, _LOWERID {1255}, MTF_EASY or MTF_NORMAL or MTF_HARD)
      else
        AddThingToWad(p3.X, -p3.Y, p3.Z, _RAISEID {1254}, MTF_EASY or MTF_NORMAL or MTF_HARD);
    end;
  end;

  procedure AddHeightmapitemToWAD(const iX, iY: integer);
  begin
    if pass[iX, iY] then
      Exit;
    if flags and ETF_SLOPED <> 0 then
    begin
      if not TryFlatRange(iX, iY) then
      begin
        AddSlopedTriangleToWAD(iX, iY, iX + 1, iY, iX, iY + 1);
        AddSlopedTriangleToWAD(iX, iY + 1, iX + 1, iY, iX + 1, iY + 1);
      end;
    end
    else
      AddFlatQuadToWAD(iX, iY, iX + 1, iY, iX + 1, iY + 1, iX, iY + 1);
    pass[iX, iY] := True;
  end;

  procedure RemoveUnNeededLines;
  var
    j: integer;
    pline: Pmaplinedef_t;
    side0, side1: integer;
  begin
    for j := numdoomlinedefs - 2 downto 0 do
    begin
      pline := @doomlinedefs[j];
      side0 := pline.sidenum[0];
      side1 := pline.sidenum[1];
      if (side0 >= 0) and (side1 >= 0) then
        if doomsidedefs[side0].sector = doomsidedefs[side1].sector then
        begin
          doomlinedefs[j] := doomlinedefs[numdoomlinedefs - 1];
          ReallocMem(doomlinedefs, (numdoomlinedefs  - 1) * SizeOf(maplinedef_t));
          dec(numdoomlinedefs);
        end;
    end;
  end;

  procedure FixTrangleSectors;
  var
    j: integer;
    pline: Pmaplinedef_t;
    side0, side1: integer;
    sectorlines: PIntegerArray;
  begin
    GetMem(sectorlines, numdoomsectors * SizeOf(integer));
    FillChar(sectorlines^, numdoomsectors * SizeOf(integer), 0);
    for j := 0 to numdoomlinedefs - 1 do
    begin
      pline := @doomlinedefs[j];
      side0 := pline.sidenum[0];
      side1 := pline.sidenum[1];
      if side0 >= 0 then
        inc(sectorlines[doomsidedefs[side0].sector]);
      if side1 >= 0 then
        inc(sectorlines[doomsidedefs[side1].sector]);
    end;

    for j := 0 to numdoomsectors - 1 do
      if not slopedsectors[j] then
        if sectorlines[j] = 3 then
          doomsectors[j].floorheight := 0; // Height will be set by easy slope things

    FreeMem(sectorlines, numdoomsectors * SizeOf(integer));
  end;

begin
  sidetex := stringtochar8(defsidetex);
  FillChar(pass, SizeOf(pass), 0);
  FillChar(flat, SizeOf(flat), 0);

  doomthings := nil;
  numdoomthings := 0;
  doomlinedefs := nil;
  numdoomlinedefs := 0;
  doomsidedefs := nil;
  numdoomsidedefs := 0;
  doomvertexes := nil;
  numdoomvertexes := 0;
  doomsectors := nil;
  slopedsectors := nil;
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

  if flags and ETF_TRUECOLORFLAT <> 0 then
  begin
    // Create flat - 32 bit color - inside HI_START - HI_END namespace
    png := TPngObject.Create;
    png.Assign(t.Texture);

    ms := TMemoryStream.Create;

    png.SaveToStream(ms);

    wadwriter.AddSeparator('HI_START');
    wadwriter.AddData(levelname + 'TER', ms.Memory, ms.Size);
    wadwriter.AddSeparator('HI_END');

    ms.Free;
    png.Free;
  end;

  // Create flat - 8 bit
  bm := t.Texture;
  GetMem(flattexture, bm.Width * bm.Height);

  i := 0;
  for y := 0 to t.texturesize - 1 do
  begin
    scanline := t.Texture.ScanLine[y];
    for x := 0 to t.texturesize - 1 do
    begin
      c := scanline[x];
      flattexture[i] := V_FindAproxColorIndex(@def_palL, c);
      inc(i);
    end;
  end;

  wadwriter.AddSeparator('F_START');
  wadwriter.AddData(levelname + 'TER', flattexture, bm.Width * bm.Height);
  wadwriter.AddSeparator('F_END');

  FreeMem(flattexture, bm.Width * bm.Height);

  // Create Map
  for x := 0 to t.heightmapsize - 2 do
    for y := 0 to t.heightmapsize - 2 do
      AddHeightmapitemToWAD(x, y);

  // Player start
  AddThingToWad(64, -64, 0, 1, MTF_EASY or MTF_NORMAL or MTF_HARD);

  // Remove unneeded lines
  if flags and ETF_MERGEFLATSECTORS <> 0 then
    RemoveUnNeededLines;

  // Fix flat triangle sectors
  FixTrangleSectors;

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
  FreeMem(slopedsectors, numdoomsectors * SizeOf(boolean));

end;

procedure ExportTerrainToUDMFFile(const t: TTerrain; const fname: string;
  const levelname: string; const defsidetex: string;
  const flags: LongWord; const defceilingheight: integer = 512);
var
  zdoomlinedefs: Pmaplinedef_tArray;
  numzdoomlinedefs: integer;
  zdoomsidedefs: Pmapsidedef_tArray;
  numzdoomsidedefs: integer;
  zdoomvertexes: Pzmapvertex_tArray;
  numzdoomvertexes: integer;
  zdoomsectors: Pmapsector_tArray;
  zslopedsectors: PBooleanArray;
  numzdoomsectors: integer;
  wadwriter: TWadWriter;
  i, x, y: integer;
  png: TPngObject;
  ms: TMemoryStream;
  sidetex: char8_t;
  pass: array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of boolean;
  flat: array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of boolean;
  udmfmap: TStringList;

  procedure AddPlayerStartToUDMF(const x, y: integer; const angle: smallint; const pno: integer);
  begin
    udmfmap.Add('thing // ' + IntToStr(pno));
    udmfmap.Add('{');
    udmfmap.Add('x = ' + IntToStr(x) + ';');
    udmfmap.Add('y = ' + IntToStr(y) + ';');
    udmfmap.Add('angle = ' + IntToStr(angle) + ';');
    udmfmap.Add('type = ' + IntToStr(pno) + ';');
    udmfmap.Add('skill1 = true;');
    udmfmap.Add('skill2 = true;');
    udmfmap.Add('skill3 = true;');
    udmfmap.Add('skill4 = true;');
    udmfmap.Add('skill5 = true;');
    udmfmap.Add('skill6 = true;');
    udmfmap.Add('skill7 = true;');
    udmfmap.Add('skill8 = true;');
    udmfmap.Add('single = true;');
    udmfmap.Add('coop = true;');
    udmfmap.Add('dm = true;');
    udmfmap.Add('class1 = true;');
    udmfmap.Add('class2 = true;');
    udmfmap.Add('class3 = true;');
    udmfmap.Add('class4 = true;');
    udmfmap.Add('class5 = true;');
    udmfmap.Add('class6 = true;');
    udmfmap.Add('class7 = true;');
    udmfmap.Add('class8 = true;');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

  function AddSectorToUDMF(const hfloor, hceiling: integer; const sloped: boolean): integer;
  var
    j: integer;
    dsec: Pmapsector_t;
  begin
    if not sloped then
    begin
      for j := 0 to numzdoomsectors - 1 do
        if not zslopedsectors[j] then
        begin
          dsec := @zdoomsectors[j];
          if (dsec.floorheight = hfloor) and (dsec.ceilingheight = hceiling) then
          begin
            Result := j;
            Exit;
          end;
        end;
    end;

    ReallocMem(zdoomsectors, (numzdoomsectors  + 1) * SizeOf(mapsector_t));
    ReallocMem(zslopedsectors, (numzdoomsectors  + 1) * SizeOf(boolean));
    dsec := @zdoomsectors[numzdoomsectors];
    dsec.floorheight := hfloor;
    dsec.ceilingheight := hceiling;
    dsec.floorpic := stringtochar8(levelname + 'TER');
    dsec.ceilingpic := stringtochar8('F_SKY1');
    dsec.lightlevel := 192;
    dsec.special := 0;
    dsec.tag := 0;
    zslopedsectors[numzdoomsectors] := sloped;

    result := numzdoomsectors;
    inc(numzdoomsectors);
  end;

  function AddVertexToUDMF(const x, y: smallint): integer;
  var
    j: integer;
  begin
    for j := 0 to numzdoomvertexes - 1 do
      if (zdoomvertexes[j].x = x) and (zdoomvertexes[j].y = y) then
      begin
        result := j;
        exit;
      end;
    ReallocMem(zdoomvertexes, (numzdoomvertexes  + 1) * SizeOf(zmapvertex_t));
    zdoomvertexes[numzdoomvertexes].x := x;
    zdoomvertexes[numzdoomvertexes].y := y;
    zdoomvertexes[numzdoomvertexes].z := 0;
    result := numzdoomvertexes;
    inc(numzdoomvertexes);
  end;

  function AddSidedefToUDMF(const sector: smallint; const force_new: boolean = true): integer;
  var
    j: integer;
    pside: Pmapsidedef_t;
  begin
    if not force_new then // JVAL: 20200309 - If we pack sidedefs of radix level, the triggers may not work :(
      for j := 0 to numzdoomsidedefs - 1 do
        if zdoomsidedefs[j].sector = sector then
        begin
          result := j;
          exit;
        end;

    ReallocMem(zdoomsidedefs, (numzdoomsidedefs  + 1) * SizeOf(mapsidedef_t));
    pside := @zdoomsidedefs[numzdoomsidedefs];
    pside.textureoffset := 0;
    pside.rowoffset := 0;
    pside.toptexture := stringtochar8('-');
    pside.bottomtexture := stringtochar8('-');
    pside.midtexture := stringtochar8('-');
    pside.sector := sector;
    result := numzdoomsidedefs;
    inc(numzdoomsidedefs);
  end;

  function AddLinedefToUDMF(const v1, v2: integer): integer;
  var
    j: integer;
    pline: Pmaplinedef_t;
  begin
    for j := 0 to numzdoomlinedefs - 1 do
    begin
      pline := @zdoomlinedefs[j];
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

    ReallocMem(zdoomlinedefs, (numzdoomlinedefs  + 1) * SizeOf(maplinedef_t));
    pline := @zdoomlinedefs[numzdoomlinedefs];
    pline.v1 := v1;
    pline.v2 := v2;
    pline.flags := 0;
    pline.special := 0;
    pline.tag := 0;
    pline.sidenum[0] := -1;
    pline.sidenum[1] := -1;
    result := numzdoomlinedefs;
    inc(numzdoomlinedefs);
  end;

  function GetHeightmapCoords3DUDMF(const iX, iY: integer): point3d_t;
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

  procedure AddFlatQuadToUDMF(const iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4: integer);
  var
    v1, v2, v3, v4: integer;
    p1, p2, p3, p4: point3d_t;
    l1, l2, l3, l4: integer;
    sec: integer;
  begin
    p1 := GetHeightmapCoords3DUDMF(iX1, iY1);
    p2 := GetHeightmapCoords3DUDMF(iX2, iY2);
    p3 := GetHeightmapCoords3DUDMF(iX3, iY3);
    p4 := GetHeightmapCoords3DUDMF(iX4, iY4);
    sec := AddSectorToUDMF((p1.Z + p2.Z + p3.Z + p4.Z) div 4, defceilingheight, False);
    v1 := AddVertexToUDMF(p1.X, -p1.Y);
    v2 := AddVertexToUDMF(p2.X, -p2.Y);
    v3 := AddVertexToUDMF(p3.X, -p3.Y);
    v4 := AddVertexToUDMF(p4.X, -p4.Y);
    l1 := AddLinedefToUDMF(v1, v2);
    l2 := AddLinedefToUDMF(v2, v3);
    l3 := AddLinedefToUDMF(v3, v4);
    l4 := AddLinedefToUDMF(v4, v1);
    if zdoomlinedefs[l1].sidenum[0] < 0 then
      zdoomlinedefs[l1].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l1].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l1].flags := zdoomlinedefs[l1].flags or ML_TWOSIDED;
    end;
    if zdoomlinedefs[l2].sidenum[0] < 0 then
      zdoomlinedefs[l2].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l2].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l2].flags := zdoomlinedefs[l2].flags or ML_TWOSIDED;
    end;
    if zdoomlinedefs[l3].sidenum[0] < 0 then
      zdoomlinedefs[l3].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l3].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l3].flags := zdoomlinedefs[l3].flags or ML_TWOSIDED;
    end;
    if zdoomlinedefs[l4].sidenum[0] < 0 then
      zdoomlinedefs[l4].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l4].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l4].flags := zdoomlinedefs[l4].flags or ML_TWOSIDED;
    end;
  end;

  function TryFlatRangeUDMF(const iX1, iY1: integer): boolean;
  var
    p1, p2, p3, p4: point3d_t;
    iX2, iY2: integer;
    iX3, iY3: integer;
    iX4, iY4: integer;
  begin
    Result := False;

    p1 := GetHeightmapCoords3DUDMF(iX1, iY1);
    iX2 := iX1 + 1;
    iY2 := iY1;
    p2 := GetHeightmapCoords3DUDMF(iX2, iY2);
    if p1.Z <> p2.Z then
      Exit;
    iX3 := iX1 + 1;
    iY3 := iY1 + 1;
    p3 := GetHeightmapCoords3DUDMF(iX3, iY3);
    if p1.Z <> p3.Z then
      Exit;
    iX4 := iX1;
    iY4 := iY1 + 1;
    p4 := GetHeightmapCoords3DUDMF(iX4, iY4);
    if p1.Z <> p4.Z then
      Exit;
    AddFlatQuadToUDMF(iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4);
    flat[iX1, iY1] := true;

    Result := True;
  end;

  procedure AddSlopedTriangleToUDMF(const iX1, iY1, iX2, iY2, iX3, iY3: integer);
  var
    v1, v2, v3: integer;
    p1, p2, p3: point3d_t;
    l1, l2, l3: integer;
    sec: integer;
    issloped: boolean;
  begin
    p1 := GetHeightmapCoords3DUDMF(iX1, iY1);
    p2 := GetHeightmapCoords3DUDMF(iX2, iY2);
    p3 := GetHeightmapCoords3DUDMF(iX3, iY3);
    issloped := (p1.Z <> p2.Z) or (p1.Z <> p3.Z);
    if issloped then
      sec := AddSectorToUDMF(0, defceilingheight, True)
    else
      sec := AddSectorToUDMF(p1.Z, defceilingheight, False);
    v1 := AddVertexToUDMF(p1.X, -p1.Y);
    v2 := AddVertexToUDMF(p2.X, -p2.Y);
    v3 := AddVertexToUDMF(p3.X, -p3.Y);
    l1 := AddLinedefToUDMF(v1, v2);
    l2 := AddLinedefToUDMF(v2, v3);
    l3 := AddLinedefToUDMF(v3, v1);
    if zdoomlinedefs[l1].sidenum[0] < 0 then
      zdoomlinedefs[l1].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l1].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l1].flags := zdoomlinedefs[l1].flags or ML_TWOSIDED;
    end;
    if zdoomlinedefs[l2].sidenum[0] < 0 then
      zdoomlinedefs[l2].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l2].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l2].flags := zdoomlinedefs[l2].flags or ML_TWOSIDED;
    end;
    if zdoomlinedefs[l3].sidenum[0] < 0 then
      zdoomlinedefs[l3].sidenum[0] := AddSidedefToUDMF(sec)
    else
    begin
      zdoomlinedefs[l3].sidenum[1] := AddSidedefToUDMF(sec);
      zdoomlinedefs[l3].flags := zdoomlinedefs[l3].flags or ML_TWOSIDED;
    end;
    if issloped then
    begin
      zdoomvertexes[v1].z := p1.Z;
      zdoomvertexes[v2].z := p2.Z;
      zdoomvertexes[v3].z := p3.Z;
    end;
  end;

  procedure AddHeightmapitemToUDMF(const iX, iY: integer);
  begin
    if pass[iX, iY] then
      Exit;
    if flags and ETF_SLOPED <> 0 then
    begin
      if not TryFlatRangeUDMF(iX, iY) then
      begin
        AddSlopedTriangleToUDMF(iX, iY, iX + 1, iY, iX, iY + 1);
        AddSlopedTriangleToUDMF(iX, iY + 1, iX + 1, iY, iX + 1, iY + 1);
      end;
    end
    else
      AddFlatQuadToUDMF(iX, iY, iX + 1, iY, iX + 1, iY + 1, iX, iY + 1);
    pass[iX, iY] := True;
  end;

  procedure RemoveUnNeededLinesUDMF;
  var
    j, k: integer;
    pline: Pmaplinedef_t;
    side0, side1: integer;
    sidedefhit: PIntegerArray;
    vertexhit: PIntegerArray;
  begin
    for j := numzdoomlinedefs - 2 downto 0 do
    begin
      pline := @zdoomlinedefs[j];
      side0 := pline.sidenum[0];
      side1 := pline.sidenum[1];
      if (side0 >= 0) and (side1 >= 0) then
        if zdoomsidedefs[side0].sector = zdoomsidedefs[side1].sector then
        begin
          zdoomlinedefs[j] := zdoomlinedefs[numzdoomlinedefs - 1];
          ReallocMem(zdoomlinedefs, (numzdoomlinedefs  - 1) * SizeOf(maplinedef_t));
          dec(numzdoomlinedefs);
        end;
    end;
    // UDMF maps seeps to dislike unassigned sidedefs
    GetMem(sidedefhit, numzdoomsidedefs * SizeOf(Integer));
    ZeroMemory(sidedefhit, numzdoomsidedefs * SizeOf(Integer));
    // Mark unused sidedefs
    for j := 0 to numzdoomlinedefs - 1 do
    begin
      pline := @zdoomlinedefs[j];
      side0 := pline.sidenum[0];
      if side0 >= 0 then
        inc(sidedefhit[side0]);
      side1 := pline.sidenum[1];
      if side1 >= 0 then
        inc(sidedefhit[side1]);
    end;
    // Remove unused sidedefs
    for k := numzdoomsidedefs - 1 downto 0 do
    begin
      if sidedefhit[k] = 0 then
      begin
        if k < numzdoomsidedefs - 1 then
        begin
          for j := 0 to numzdoomlinedefs - 1 do
          begin
            pline := @zdoomlinedefs[j];
            if pline.sidenum[0] = numzdoomsidedefs - 1 then
            begin
              pline.sidenum[0] := k;
              inc(sidedefhit[k]); // mark as used
            end;
            if pline.sidenum[1] = numzdoomsidedefs - 1 then
            begin
              pline.sidenum[1] := k;
              inc(sidedefhit[k]); // mark as used
            end;
          end;
        end;
        dec(numzdoomsidedefs);
        zdoomsidedefs[k] := zdoomsidedefs[numzdoomsidedefs];
      end;
    end;
    ReallocMem(zdoomsidedefs, numzdoomsidedefs * SizeOf(mapsidedef_t));
    FreeMem(sidedefhit, numzdoomsidedefs * SizeOf(Integer));
    // Mark unused vertexes
    GetMem(vertexhit, numzdoomvertexes * SizeOf(Integer));
    ZeroMemory(vertexhit, numzdoomvertexes * SizeOf(Integer));
    for j := 0 to numzdoomlinedefs - 1 do
    begin
      inc(vertexhit[zdoomlinedefs[j].v1]);
      inc(vertexhit[zdoomlinedefs[j].v2]);
    end;
    // Remove unused vertexes
    for k := numzdoomvertexes - 1 downto 0 do
    begin
      if vertexhit[k] = 0 then
      begin
        if k < numzdoomvertexes - 1 then
        begin
          for j := 0 to numzdoomlinedefs - 1 do
          begin
            if zdoomlinedefs[j].v1 = numzdoomvertexes - 1 then
            begin
              zdoomlinedefs[j].v1 := k;
              inc(vertexhit[k]); // mark as used
            end;
            if zdoomlinedefs[j].v2 = numzdoomvertexes - 1 then
            begin
              zdoomlinedefs[j].v2 := k;
              inc(vertexhit[k]); // mark as used
            end;
          end;
        end;
        dec(numzdoomvertexes);
        zdoomvertexes[k] := zdoomvertexes[numzdoomvertexes];
      end;
    end;
    ReallocMem(zdoomvertexes, numzdoomvertexes * SizeOf(zmapvertex_t));
    FreeMem(vertexhit, numzdoomvertexes * SizeOf(Integer));
  end;

  procedure FixTrangleSectorsUDMF;
  var
    j: integer;
    pline: Pmaplinedef_t;
    side0, side1: integer;
    sectorlines: PIntegerArray;
  begin
    GetMem(sectorlines, numzdoomsectors * SizeOf(integer));
    FillChar(sectorlines^, numzdoomsectors * SizeOf(integer), 0);
    for j := 0 to numzdoomlinedefs - 1 do
    begin
      pline := @zdoomlinedefs[j];
      side0 := pline.sidenum[0];
      side1 := pline.sidenum[1];
      if side0 >= 0 then
        inc(sectorlines[zdoomsidedefs[side0].sector]);
      if side1 >= 0 then
        inc(sectorlines[zdoomsidedefs[side1].sector]);
    end;

    for j := 0 to numzdoomsectors - 1 do
      if not zslopedsectors[j] then
        if sectorlines[j] = 3 then
          zdoomsectors[j].floorheight := 0; // Height will be set by easy slope things

    FreeMem(sectorlines, numzdoomsectors * SizeOf(integer));
  end;

  procedure FlashUDMFVertext(const ii: integer);
  begin
    udmfmap.Add('vertex // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('x = ' + IntToStr(zdoomvertexes[ii].x) + ';');
    udmfmap.Add('y = ' + IntToStr(zdoomvertexes[ii].y) + ';');
    udmfmap.Add('zfloor = ' + IntToStr(zdoomvertexes[ii].z) + ';');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

  procedure FlashUDMFLinedef(const ii: integer);
  begin
    udmfmap.Add('linedef // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('v1 = ' + IntToStr(zdoomlinedefs[ii].v1) + ';');
    udmfmap.Add('v2 = ' + IntToStr(zdoomlinedefs[ii].v2) + ';');
    if zdoomlinedefs[ii].sidenum[0] >= 0 then
      udmfmap.Add('sidefront = ' + IntToStr(zdoomlinedefs[ii].sidenum[0]) + ';');
    if zdoomlinedefs[ii].sidenum[1] >= 0 then
    begin
      udmfmap.Add('sideback = ' + IntToStr(zdoomlinedefs[ii].sidenum[1]) + ';');
      udmfmap.Add('twosided = true;');
    end
    else
      udmfmap.Add('blocking = true;');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

  procedure FlashUDMFSidedef(const ii: integer);
  begin
    udmfmap.Add('sidedef // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('texturetop = "' + char8tostring(zdoomsidedefs[ii].toptexture) + '";');
    udmfmap.Add('texturebottom = "' + char8tostring(zdoomsidedefs[ii].bottomtexture) + '";');
    udmfmap.Add('texturemiddle = "' + char8tostring(zdoomsidedefs[ii].midtexture) + '";');
    udmfmap.Add('sector = ' + IntToStr(zdoomsidedefs[ii].sector) + ';');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

  procedure FlashUDMFSector(const ii: integer);
  begin
    udmfmap.Add('sector // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('heightfloor = ' + IntToStr(zdoomsectors[ii].floorheight) + ';');
    udmfmap.Add('heightceiling = ' + IntToStr(zdoomsectors[ii].ceilingheight) + ';');
    udmfmap.Add('texturefloor = "' + char8tostring(zdoomsectors[ii].floorpic) + '";');
    udmfmap.Add('textureceiling = "' + char8tostring(zdoomsectors[ii].ceilingpic) + '";');
    udmfmap.Add('lightlevel = ' + IntToStr(zdoomsectors[ii].lightlevel) + ';');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

begin
  sidetex := stringtochar8(defsidetex);
  FillChar(pass, SizeOf(pass), 0);
  FillChar(flat, SizeOf(flat), 0);

  zdoomlinedefs := nil;
  numzdoomlinedefs := 0;
  zdoomsidedefs := nil;
  numzdoomsidedefs := 0;
  zdoomvertexes := nil;
  numzdoomvertexes := 0;
  zdoomsectors := nil;
  zslopedsectors := nil;
  numzdoomsectors := 0;

  wadwriter := TWadWriter.Create;

  // Create flat

  png := TPngObject.Create;
  png.Assign(t.Texture);

  ms := TMemoryStream.Create;

  png.SaveToStream(ms);

  wadwriter.AddString('TEXTURES',
    'flat ' + levelname + 'TER,' + IntToStr(png.Width) + ',' + IntToStr(png.Height) + #13#10 +
    '{' + #13#10 +
    '   XScale 1.0' + #13#10 +
    '   YScale 1.0' + #13#10 +
    '   Patch ' + levelname + 'TER, 0, 0' + #13#10 +
    '}' + #13#10
  );
  wadwriter.AddSeparator('P_START');
  wadwriter.AddData(levelname + 'TER', ms.Memory, ms.Size);
  wadwriter.AddSeparator('P_END');

  ms.Free;
  png.Free;

  // Create Map
  for x := 0 to t.heightmapsize - 2 do
    for y := 0 to t.heightmapsize - 2 do
      AddHeightmapitemToUDMF(x, y);

  udmfmap := TStringList.Create;

  // UDMF header
  udmfmap.Add('// Generated by DD_TERRAIN');
  udmfmap.Add('namespace="zdoom";');
  udmfmap.Add('');

  // Player start
  AddPlayerStartToUDMF(64, -64, 0, 1);

  // Remove unneeded lines
  if flags and ETF_MERGEFLATSECTORS <> 0 then
    RemoveUnNeededLinesUDMF;

  // Fix flat triangle sectors
  FixTrangleSectorsUDMF;

  // Add wall textures
  for i := 0 to numzdoomlinedefs - 1 do
  begin
    if zdoomlinedefs[i].flags and ML_TWOSIDED = 0 then
      zdoomsidedefs[zdoomlinedefs[i].sidenum[0]].midtexture := sidetex
    else
    begin
      zdoomsidedefs[zdoomlinedefs[i].sidenum[0]].bottomtexture := sidetex;
      zdoomsidedefs[zdoomlinedefs[i].sidenum[1]].bottomtexture := sidetex;
    end;
  end;

  // Flash data to wad
  wadwriter.AddSeparator(levelname);

  for i := 0 to numzdoomvertexes - 1 do
    FlashUDMFVertext(i);
  for i := 0 to numzdoomlinedefs - 1 do
    FlashUDMFLinedef(i);
  for i := 0 to numzdoomsidedefs - 1 do
    FlashUDMFSidedef(i);
  for i := 0 to numzdoomsectors - 1 do
    FlashUDMFSector(i);

  wadwriter.AddStringList('TEXTMAP', udmfmap);
  wadwriter.AddSeparator('ENDMAP');

  // Save wad to disk
  wadwriter.SaveToFile(fname);

  wadwriter.Free;
  udmfmap.Free;

  // Free data
  FreeMem(zdoomlinedefs, numzdoomlinedefs * SizeOf(maplinedef_t));
  FreeMem(zdoomsidedefs, numzdoomsidedefs * SizeOf(mapsidedef_t));
  FreeMem(zdoomvertexes, numzdoomvertexes * SizeOf(zmapvertex_t));
  FreeMem(zdoomsectors, numzdoomsectors * SizeOf(mapsector_t));
  FreeMem(zslopedsectors, numzdoomsectors * SizeOf(boolean));

end;

end.

