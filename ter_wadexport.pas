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

const
  ETF_SLOPED = 1;
  ETF_CALCDXDY = 2;
  ETF_TRUECOLORFLAT = 4;
  ETF_MERGEFLATSECTORS = 8;
  ETF_ADDPLAYERSTART = 16;
  ETF_DONTEXPORTFLAT = 32;

const
  ENGINE_RAD = 0;
  ENGINE_DELHIDOOM = 1;
  ENGINE_DELHIHERETIC = 2;
  ENGINE_DELHIHEXEN = 3;
  ENGINE_DELHISTRIFE = 4;
  ENGINE_UDMF = 5;

type
  exportwadoptions_t = record
    engine: integer;
    levelname: string[8];
    palette: PByteArray;
    defsidetex: string[8];
    deceilingpic: string[8];
    lowerid, raiseid: integer;
    flags: integer;
    defceilingheight: integer;
  end;
  exportwadoptions_p = ^exportwadoptions_t;

procedure ExportTerrainToWADFile(const t: TTerrain; const strm: TStream;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const defceilingtex: string; const _LOWERID, _RAISEID: integer;
  const flags: LongWord; const defceilingheight: integer = 512);

procedure ExportTerrainToHexenFile(const t: TTerrain; const strm: TStream;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const defceilingtex: string; const _LOWERID, _RAISEID: integer;
  const flags: LongWord; const defceilingheight: integer = 512);

procedure ExportTerrainToUDMFFile(const t: TTerrain; const strm: TStream;
  const levelname: string; const defsidetex: string; const defceilingtex: string;
  const flags: LongWord; const defceilingheight: integer = 512);

implementation

uses
  Windows,
  Graphics,
  ter_doomdata,
  ter_wadwriter,
  ter_quantize;

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

{$DEFINE DOOM_FORMAT}
{$UNDEF HEXEN_FORMAT}
{$UNDEF UDMF_FORMAT}
procedure ExportTerrainToWADFile(const t: TTerrain; const strm: TStream;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const defceilingtex: string; const _LOWERID, _RAISEID: integer;
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

{$I exp_AddThing.inc}
{$I exp_AddSector.inc}
{$I exp_AddVertex.inc}
{$I exp_AddSidedef.inc}
{$I exp_AddLinedef.inc}
{$I exp_GetHeightmapCoords3D.inc}
{$I exp_AddFlatQuad.inc}
{$I exp_TryFlatRange.inc}
{$I exp_AddSlopedTriangle.inc}
{$I exp_AddHeightmapItem.inc}
{$I exp_RemoveUnNeededLines.inc}
{$I exp_FixTrangleSectors.inc}
{$I exp_FixTextureOffsets.inc}

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

  if flags and ETF_DONTEXPORTFLAT = 0 then
  begin
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
  end;
  
  // Create Map
  for x := 0 to t.heightmapsize - 2 do
    for y := 0 to t.heightmapsize - 2 do
      AddHeightmapItem(x, y);

  // Player start
  if flags and ETF_ADDPLAYERSTART <> 0 then
    AddThing(64, -64, 0, 1, MTF_EASY or MTF_NORMAL or MTF_HARD);

  // Remove unneeded lines
  if flags and ETF_MERGEFLATSECTORS <> 0 then
    RemoveUnNeededLines;

  // Fix flat triangle sectors
  FixTrangleSectors;

  // Fix texture offsets
  FixTextureOffsets;

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

  // Save wad
  wadwriter.SaveToStream(strm);

  wadwriter.Free;

  // Free data
  FreeMem(doomthings, numdoomthings * SizeOf(mapthing_t));
  FreeMem(doomlinedefs, numdoomlinedefs * SizeOf(maplinedef_t));
  FreeMem(doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
  FreeMem(doomvertexes, numdoomvertexes * SizeOf(mapvertex_t));
  FreeMem(doomsectors, numdoomsectors * SizeOf(mapsector_t));
  FreeMem(slopedsectors, numdoomsectors * SizeOf(boolean));

end;

{$UNDEF DOOM_FORMAT}
{$DEFINE HEXEN_FORMAT}
{$UNDEF UDMF_FORMAT}
procedure ExportTerrainToHexenFile(const t: TTerrain; const strm: TStream;
  const levelname: string; const palette: PByteArray; const defsidetex: string;
  const defceilingtex: string; const _LOWERID, _RAISEID: integer;
  const flags: LongWord; const defceilingheight: integer = 512);
var
  doomthings: Phmapthing_tArray;
  numdoomthings: integer;
  doomlinedefs: Phmaplinedef_tArray;
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

{$I exp_AddThing.inc}
{$I exp_AddSector.inc}
{$I exp_AddVertex.inc}
{$I exp_AddSidedef.inc}
{$I exp_AddLinedef.inc}
{$I exp_GetHeightmapCoords3D.inc}
{$I exp_AddFlatQuad.inc}
{$I exp_TryFlatRange.inc}
{$I exp_AddSlopedTriangle.inc}
{$I exp_AddHeightmapItem.inc}
{$I exp_RemoveUnNeededLines.inc}
{$I exp_FixTrangleSectors.inc}
{$I exp_FixTextureOffsets.inc}

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
      AddHeightmapItem(x, y);

  // Player start
  if flags and ETF_ADDPLAYERSTART <> 0 then
    AddThing(64, -64, 0, 1, MTF_EASY or MTF_NORMAL or MTF_HARD);

  // Remove unneeded lines
  if flags and ETF_MERGEFLATSECTORS <> 0 then
    RemoveUnNeededLines;

  // Fix flat triangle sectors
  FixTrangleSectors;

  // Fix texture offsets
  FixTextureOffsets;

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
  wadwriter.AddData('THINGS', doomthings, numdoomthings * SizeOf(hmapthing_t));
  wadwriter.AddData('LINEDEFS', doomlinedefs, numdoomlinedefs * SizeOf(hmaplinedef_t));
  wadwriter.AddData('SIDEDEFS', doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
  wadwriter.AddData('VERTEXES', doomvertexes, numdoomvertexes * SizeOf(mapvertex_t));
  wadwriter.AddSeparator('SEGS');
  wadwriter.AddSeparator('SSECTORS');
  wadwriter.AddSeparator('NODES');
  wadwriter.AddData('SECTORS', doomsectors, numdoomsectors * SizeOf(mapsector_t));
  wadwriter.AddSeparator('REJECT');
  wadwriter.AddSeparator('BLOCKMAP');
  wadwriter.AddSeparator('BEHAVIOR');

  // Save wad
  wadwriter.SaveToStream(strm);

  wadwriter.Free;

  // Free data
  FreeMem(doomthings, numdoomthings * SizeOf(hmapthing_t));
  FreeMem(doomlinedefs, numdoomlinedefs * SizeOf(hmaplinedef_t));
  FreeMem(doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
  FreeMem(doomvertexes, numdoomvertexes * SizeOf(mapvertex_t));
  FreeMem(doomsectors, numdoomsectors * SizeOf(mapsector_t));
  FreeMem(slopedsectors, numdoomsectors * SizeOf(boolean));

end;

{$UNDEF DOOM_FORMAT}
{$UNDEF HEXEN_FORMAT}
{$DEFINE UDMF_FORMAT}
procedure ExportTerrainToUDMFFile(const t: TTerrain; const strm: TStream;
  const levelname: string; const defsidetex: string; const defceilingtex: string; 
  const flags: LongWord; const defceilingheight: integer = 512);
var
  doomlinedefs: Pmaplinedef_tArray;
  numdoomlinedefs: integer;
  doomsidedefs: Pmapsidedef_tArray;
  numdoomsidedefs: integer;
  doomvertexes: Pzmapvertex_tArray;
  numdoomvertexes: integer;
  doomsectors: Pmapsector_tArray;
  slopedsectors: PBooleanArray;
  numdoomsectors: integer;
  wadwriter: TWadWriter;
  i, x, y: integer;
  png: TPngObject;
  bm: TBitmap;
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

{$I exp_AddSector.inc}
{$I exp_AddVertex.inc}
{$I exp_AddSidedef.inc}
{$I exp_AddLinedef.inc}
{$I exp_GetHeightmapCoords3D.inc}
{$I exp_AddFlatQuad.inc}
{$I exp_TryFlatRange.inc}
{$I exp_AddSlopedTriangle.inc}
{$I exp_AddHeightmapItem.inc}
{$I exp_RemoveUnNeededLines.inc}
{$I exp_FixTrangleSectors.inc}
{$I exp_FixTextureOffsets.inc}

  procedure FlashUDMFVertext(const ii: integer);
  begin
    udmfmap.Add('vertex // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('x = ' + IntToStr(doomvertexes[ii].x) + ';');
    udmfmap.Add('y = ' + IntToStr(doomvertexes[ii].y) + ';');
    udmfmap.Add('zfloor = ' + IntToStr(doomvertexes[ii].z) + ';');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

  procedure FlashUDMFLinedef(const ii: integer);
  begin
    udmfmap.Add('linedef // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('v1 = ' + IntToStr(doomlinedefs[ii].v1) + ';');
    udmfmap.Add('v2 = ' + IntToStr(doomlinedefs[ii].v2) + ';');
    if doomlinedefs[ii].sidenum[0] >= 0 then
      udmfmap.Add('sidefront = ' + IntToStr(doomlinedefs[ii].sidenum[0]) + ';');
    if doomlinedefs[ii].sidenum[1] >= 0 then
    begin
      udmfmap.Add('sideback = ' + IntToStr(doomlinedefs[ii].sidenum[1]) + ';');
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
    udmfmap.Add('texturetop = "' + char8tostring(doomsidedefs[ii].toptexture) + '";');
    udmfmap.Add('texturebottom = "' + char8tostring(doomsidedefs[ii].bottomtexture) + '";');
    udmfmap.Add('texturemiddle = "' + char8tostring(doomsidedefs[ii].midtexture) + '";');
    udmfmap.Add('sector = ' + IntToStr(doomsidedefs[ii].sector) + ';');
    udmfmap.Add('offsetx = ' + IntToStr(doomsidedefs[ii].textureoffset) + ';');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

  procedure FlashUDMFSector(const ii: integer);
  begin
    udmfmap.Add('sector // ' + IntToStr(ii));
    udmfmap.Add('{');
    udmfmap.Add('heightfloor = ' + IntToStr(doomsectors[ii].floorheight) + ';');
    udmfmap.Add('heightceiling = ' + IntToStr(doomsectors[ii].ceilingheight) + ';');
    udmfmap.Add('texturefloor = "' + char8tostring(doomsectors[ii].floorpic) + '";');
    udmfmap.Add('textureceiling = "' + char8tostring(doomsectors[ii].ceilingpic) + '";');
    udmfmap.Add('lightlevel = ' + IntToStr(doomsectors[ii].lightlevel) + ';');
    udmfmap.Add('}');
    udmfmap.Add('');
  end;

begin
  sidetex := stringtochar8(defsidetex);
  FillChar(pass, SizeOf(pass), 0);
  FillChar(flat, SizeOf(flat), 0);

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

  // Create flat

  png := TPngObject.Create;
  if flags and ETF_TRUECOLORFLAT = 0 then
  begin
    bm := TBitmap.Create;
    try
      bm.Assign(t.Texture);
      ter_quantizebitmap(bm, 255);
      png.Assign(bm);
    finally
      bm.Free;
    end;
  end
  else
    png.Assign(t.Texture);

  ms := TMemoryStream.Create;

  png.SaveToStream(ms);
  png.Free;

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

  // Create Map
  for x := 0 to t.heightmapsize - 2 do
    for y := 0 to t.heightmapsize - 2 do
      AddHeightmapItem(x, y);

  udmfmap := TStringList.Create;

  // UDMF header
  udmfmap.Add('// Generated by DD_TERRAIN');
  udmfmap.Add('namespace="zdoom";');
  udmfmap.Add('');

  // Player start
  if flags and ETF_ADDPLAYERSTART <> 0 then
    AddPlayerStartToUDMF(64, -64, 0, 1);

  // Remove unneeded lines
  if flags and ETF_MERGEFLATSECTORS <> 0 then
    RemoveUnNeededLines;

  // Fix flat triangle sectors
  FixTrangleSectors;

  // Fix Texture Offsets
  FixTextureOffsets;

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

  for i := 0 to numdoomvertexes - 1 do
    FlashUDMFVertext(i);
  for i := 0 to numdoomlinedefs - 1 do
    FlashUDMFLinedef(i);
  for i := 0 to numdoomsidedefs - 1 do
    FlashUDMFSidedef(i);
  for i := 0 to numdoomsectors - 1 do
    FlashUDMFSector(i);

  wadwriter.AddStringList('TEXTMAP', udmfmap);
  wadwriter.AddSeparator('ENDMAP');

  // Save wad to disk
  wadwriter.SaveToStream(strm);

  wadwriter.Free;
  udmfmap.Free;

  // Free data
  FreeMem(doomlinedefs, numdoomlinedefs * SizeOf(maplinedef_t));
  FreeMem(doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
  FreeMem(doomvertexes, numdoomvertexes * SizeOf(zmapvertex_t));
  FreeMem(doomsectors, numdoomsectors * SizeOf(mapsector_t));
  FreeMem(slopedsectors, numdoomsectors * SizeOf(boolean));

end;

end.

