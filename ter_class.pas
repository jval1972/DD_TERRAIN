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
//  Terrain class
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_class;

interface

uses
  Windows, SysUtils, Classes, Graphics;

const
  MAXHEIGHTMAPSIZE = 65;
  MAXTEXTURESIZE = 2048;
  HEIGHTMAPRANGE = 359;

const
  HMF_STRETCHTEXTURE = 1;

type
  heightbufferitem_t = packed record
    height: integer;
    dx, dy: integer;
    flags: LongWord;
  end;
  heightbufferitem_p = ^heightbufferitem_t;
  heightbuffer_t = packed array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of heightbufferitem_t;
  heightbuffer_p = ^heightbuffer_t;

const
  MAXBITMAPHEIGHTMAP = MAXTEXTURESIZE;

type
  bitmapheightmap_t = packed array[0..MAXBITMAPHEIGHTMAP - 1, 0..MAXBITMAPHEIGHTMAP - 1] of smallint;
  bitmapheightmap_p = ^bitmapheightmap_t;

type
  point2d_t = record
    X, Y: integer;
  end;
  point2d_p = ^point2d_t;
  
  point3d_t = record
    X, Y, Z: integer;
  end;
  point3d_p = ^point3d_t;

type
  TTerrain = class(TObject)
  private
    ftexture: TBitmap;
    ftexturesize: integer;
    fheightmap: heightbuffer_p;
    fheightmapsize: integer;
  protected
    procedure ClearTexture;
    procedure ClearHeightmap;
    function GetTexture: TBitmap;
    procedure SetTextureSize(const val: integer);
    procedure SetHeightmapSize(const val: integer);
    function GetHeightmap(x, y: integer): heightbufferitem_t;
    procedure SetHeightmap(x, y: integer; val: heightbufferitem_t);
    function DoValidateHeightmapItem(x, y: integer): boolean;
    function ValidateHeightmapItem(x, y: integer): boolean;
    function ValidHeightmapPivotAngle(const x, y: integer): boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear(const newt, newh: integer);
    procedure SaveToStream(const strm: TStream; const compressed: boolean = true; const savebitmap: boolean = true);
    function LoadFromStream(const strm: TStream): boolean;
    procedure SaveToFile(const fname: string; const compressed: boolean = true);
    function LoadFromFile(const fname: string): boolean;
    procedure TerrainToHeightmapIndex(const tX, tY: integer; out hX, hY: integer);
    function MoveHeightmapPoint(const hX, hY: integer; const px, py: integer): boolean;
    function HeightmapToCoord(const h: integer): integer;
    function HeightmapCoords(const x, y: integer): TPoint;
    function HeightmapCoords3D(const x, y: integer): point3d_t;
    function SmoothHeightmap(const x, y: integer; const factorpct: integer): boolean;
    function ResampleHeightMapX2: boolean;
    function CanResampleHeightMapX2: boolean;
    function heightmapblocksize: integer;
    function RenderMeshGL(const sz: single): integer;
    function GenerateBitmapHeightmap(const bmh: bitmapheightmap_p; const bmhsize: integer): boolean;
    property Texture: TBitmap read GetTexture;
    property Heightmap[x, y: integer]: heightbufferitem_t read GetHeightmap write SetHeightmap;
    property texturesize: integer read ftexturesize;
    property heightmapsize: integer read fheightmapsize;
  end;

function ter_validateheightmapsize(const h: integer): integer;

function ter_validatetexturesize(const t: integer): integer;

const
  TERRAIN_MAGIC: integer = 1381254212; // DDTR

implementation

uses
  Math, dglOpenGL, ter_utils, zBitmap;

constructor TTerrain.Create;
begin
  ftexturesize := 1024;

  ftexture := TBitmap.Create;
  ftexture.Width := ftexturesize;
  ftexture.Height := ftexturesize;
  ftexture.PixelFormat := pf32bit;

  ClearTexture;
  GetMem(fheightmap, SizeOf(heightbuffer_t));
  ClearHeightmap;
  fheightmapsize := 17;
  Inherited;
end;

destructor TTerrain.Destroy;
begin
  ftexture.Free;
  FreeMem(fheightmap, SizeOf(heightbuffer_t));
  Inherited
end;

procedure TTerrain.ClearTexture;
var
  i: integer;
  A: PLongWordArray;
begin
  for i := 0 to ftexturesize - 1 do
  begin
    A := PLongWordArray(ftexture.ScanLine[i]);
    ZeroMemory(A, ftexturesize * SizeOf(LongWord));
  end;
end;

procedure TTerrain.ClearHeightmap;
begin
  ZeroMemory(fheightmap, SizeOf(heightbuffer_t));
end;

function TTerrain.GetTexture: TBitmap;
begin
  if (ftexturesize <> ftexture.Width) or (ftexturesize <> ftexture.Height) then
    raise Exception.Create(Format('TTerrain.GetTexture(): Invalid Texture Dimentions (%dx%d), should be (%d, %d)', [ftexture.Width, ftexture.Height, ftexturesize, ftexturesize]));
  if ftexture.PixelFormat <> pf32bit then
    raise Exception.Create('TTerrain.GetTexture(): Invalid Texture pixel format');
  Result := ftexture;
end;

procedure TTerrain.SetTextureSize(const val: integer);
var
  ns: integer;
begin
  ns := ter_validatetexturesize(val);
  if ns <> ftexturesize then
  begin
    ftexturesize := ns;
    ftexture.Width := ftexturesize;
    ftexture.Height := ftexturesize;
  end;
end;

procedure TTerrain.SetHeightmapSize(const val: integer);
begin
  fheightmapsize := ter_validateheightmapsize(val);
end;

function TTerrain.GetHeightmap(x, y: integer): heightbufferitem_t;
begin
  if (x >= 0) and (x < fheightmapsize) then
    if (y >= 0) and (y < fheightmapsize) then
    begin
      Result := fheightmap[x, y];
      Exit;
    end;
  FillChar(Result, SizeOf(Result), 0);
end;

procedure TTerrain.SetHeightmap(x, y: integer; val: heightbufferitem_t);
var
  item: heightbufferitem_p;
  oldx, oldy: integer;
begin
  if (x < 0) or (x > fheightmapsize) then
    Exit;
  if (y < 0) or (y > fheightmapsize) then
    Exit;

  item := @fheightmap[x, y];
  if item.height = val.height then
    if item.dx = val.dx then
      if item.dy = val.dy then
        if item.flags = val.flags then
          Exit;

  oldx := item.dx;
  oldy := item.dy;
  item^ := val;
  if not ValidHeightmapPivotAngle(x, y) then
  begin
    item.dy := oldy;
    if not ValidHeightmapPivotAngle(x, y) then
    begin
      item.dx := oldx;
      item.dy := val.dy;
      if not ValidHeightmapPivotAngle(x, y) then
        item.dy := oldy;
    end;
  end;
  ValidateHeightmapItem(x, y);
end;

type
  fpoint_t = record
    x, y: double;
  end;
  fpoint6_t = array[0..5] of fpoint_t;

function IsPointInPolygon(const p: fpoint_t; const poly: fpoint6_t): boolean;
var
  minX, maxX, minY, maxY: double;
  i, j: integer;
begin
  minX := poly[0].x;
  maxX := poly[0].x;
  minY := poly[0].Y;
  maxY := poly[0].Y;
  for i := 1 to 5 do
  begin
    minX := MinD(poly[i].x, minX);
    maxX := MaxD(poly[i].x, maxX);
    minY := MinD(poly[i].y, minY);
    maxY := MaxD(poly[i].y, maxY);
  end;

  if (p.x < minX) or (p.x > maxX) or (p.y < minY) or (p.Y > maxY) then
  begin
    Result := False;
    Exit;
  end;

  Result := False;
  i := 0;
  j := 5;
  while i < 6 do
  begin
    if (poly[i].y > p.y ) <> (poly[j].y > p.y) then
      if p.X < (poly[j].x - poly[i].x) * (p.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x then
        Result := not Result;
    j := i;
    inc(i);
  end;
end;

function TTerrain.DoValidateHeightmapItem(x, y: integer): boolean;
const
  EPSILON = 1.0;
  MAXITERS = 100;
var
  maxedgedxdy: integer;
  maxdxdy: integer;
  item: heightbufferitem_p;
  poly: fpoint6_t;
  point: fpoint_t;
  fdx, fdy: double;
  frac: double;
  iters: integer;
  savedx, savedy: integer;
begin
  Result := False;
  if (x < 0) or (x > fheightmapsize) then
    Exit;
  if (y < 0) or (y > fheightmapsize) then
    Exit;

  maxedgedxdy := (ftexturesize div (fheightmapsize - 1)) div 2 - 1;
  item := @fheightmap[x, y];

  savedx := item.dx;
  savedy := item.dy;
  if (x = 0) or (x = fheightmapsize - 1) then
    if (y = 0) or (y = fheightmapsize - 1) then
    begin
      item.dx := 0;
      item.dy := 0;
      Result := (item.dx <> savedx) or (item.dy <> savedy);
      Exit;
    end;

  if (x = 0) or (x = fheightmapsize - 1) then
  begin
    item.dx := 0;
    if item.dy > maxedgedxdy then
      item.dy := maxedgedxdy
    else if item.dy < -maxedgedxdy then
      item.dy := -maxedgedxdy;
    Result := (item.dx <> savedx) or (item.dy <> savedy);
    Exit;
  end;

  if (y = 0) or (y = fheightmapsize - 1) then
  begin
    item.dy := 0;
    if item.dx > maxedgedxdy then
      item.dx := maxedgedxdy
    else if item.dx < -maxedgedxdy then
      item.dx := -maxedgedxdy;
    Result := (item.dx <> savedx) or (item.dy <> savedy);
    Exit;
  end;

  maxdxdy := ftexturesize div (fheightmapsize - 1) - 1;
  if item.dx > maxdxdy then
    item.dx := maxdxdy
  else if item.dx < -maxdxdy then
    item.dx := -maxdxdy;
  if item.dy > maxdxdy then
    item.dy := maxdxdy
  else if item.dy < -maxdxdy then
    item.dy := -maxdxdy;

  poly[0].x := HeightmapToCoord(x) + fheightmap[x, y - 1].dx;
  poly[0].y := HeightmapToCoord(y - 1) + fheightmap[x, y - 1].dy + EPSILON;

  poly[1].x := HeightmapToCoord(x + 1) + fheightmap[x + 1, y - 1].dx - EPSILON;
  poly[1].y := HeightmapToCoord(y - 1) + fheightmap[x + 1, y - 1].dy + EPSILON;

  poly[2].x := HeightmapToCoord(x + 1) + fheightmap[x + 1, y].dx - EPSILON;
  poly[2].y := HeightmapToCoord(y) + fheightmap[x + 1, y].dy;

  poly[3].x := HeightmapToCoord(x) + fheightmap[x, y + 1].dx;
  poly[3].y := HeightmapToCoord(y + 1) + fheightmap[x, y + 1].dy - EPSILON;

  poly[4].x := HeightmapToCoord(x - 1) + fheightmap[x - 1, y + 1].dx + EPSILON;
  poly[4].y := HeightmapToCoord(y + 1) + fheightmap[x - 1, y + 1].dy - EPSILON;

  poly[5].x := HeightmapToCoord(x - 1) + fheightmap[x - 1, y].dx + EPSILON;
  poly[5].y := HeightmapToCoord(y) + fheightmap[x - 1, y].dy;

  fdx := fheightmap[x, y].dx;
  fdy := fheightmap[x, y].dy;
  point.x := HeightmapToCoord(x) + fdx;
  point.y := HeightmapToCoord(y) + fdy;

  iters := 0;
  frac := (heightmapblocksize - 1) / heightmapblocksize;
  while not IsPointInPolygon(point, poly) do
  begin
    fdx := fdx * frac;
    fdy := fdy * frac;
    point.x := HeightmapToCoord(x) + fdx;
    point.y := HeightmapToCoord(y) + fdy;
    inc(iters);
    if iters >= MAXITERS then
      break;
  end;

  fheightmap[x, y].dx := trunc(fdx);
  fheightmap[x, y].dy := trunc(fdy);

  Result := (item.dx <> savedx) or (item.dy <> savedy);
end;

function TTerrain.ValidHeightmapPivotAngle(const x, y: integer): boolean;
var
  angles: array[0..5] of Double;
  dangles: array[0..5] of Double;
  i: integer;
  dx, dy: integer;
  sum: double;
begin
  if (x <= 0) or (x >= fheightmapsize - 1) or (y = 0) or (y >= fheightmapsize - 1) then
  begin
    Result := True;
    Exit;
  end;

  dx := HeightmapCoords(x, y).X - HeightmapCoords(x - 1, y).X;
  dy := HeightmapCoords(x, y).Y - HeightmapCoords(x - 1, y).Y;
  angles[0] := Arctan2(dy, dx) * 180 / pi;
  dx := HeightmapCoords(x, y).X - HeightmapCoords(x - 1, y + 1).X;
  dy := HeightmapCoords(x, y).Y - HeightmapCoords(x - 1, y + 1).Y;
  angles[1] := Arctan2(dy, dx) * 180 / pi;
  dx := HeightmapCoords(x, y).X - HeightmapCoords(x, y + 1).X;
  dy := HeightmapCoords(x, y).Y - HeightmapCoords(x, y + 1).Y;
  angles[2] := Arctan2(dy, dx) * 180 / pi;
  dx := HeightmapCoords(x, y).X - HeightmapCoords(x + 1, y).X;
  dy := HeightmapCoords(x, y).Y - HeightmapCoords(x + 1, y).Y;
  angles[3] := Arctan2(dy, dx) * 180 / pi;
  dx := HeightmapCoords(x, y).X - HeightmapCoords(x + 1, y - 1).X;
  dy := HeightmapCoords(x, y).Y - HeightmapCoords(x + 1, y - 1).Y;
  angles[4] := Arctan2(dy, dx) * 180 / pi;
  dx := HeightmapCoords(x, y).X - HeightmapCoords(x, y - 1).X;
  dy := HeightmapCoords(x, y).Y - HeightmapCoords(x, y - 1).Y;
  angles[5] := Arctan2(dy, dx) * 180 / pi;

  dangles[0] := angles[5] - angles[0];
  for i := 1 to 5 do
    dangles[i] := angles[i - 1] - angles[i];
  sum := 0;
  for i := 0 to 5 do
  begin
    if dangles[i] < 0 then
      sum := sum + dangles[i] + 360
    else
      sum := sum + dangles[i];
  end;
  Result := abs(sum - 360) < 1.0;
end;

function TTerrain.ValidateHeightmapItem(x, y: integer): boolean;
var
  iX, iY: integer;
  ret: boolean;
begin
//  Result := DoValidateHeightmapItem(x, y);
  Result := False;
  for iX := GetIntInRange(x - 2, 0, fheightmapsize - 1) to GetIntInRange(x + 2, 0, fheightmapsize - 1) do
    for iY := GetIntInRange(y - 2, 0, fheightmapsize - 1) to GetIntInRange(y + 2, 0, fheightmapsize - 1) do
      if (iX <> x) and (iY <> y) then
      begin
        ret := DoValidateHeightmapItem(iX, iY);
        Result := Result or ret;
      end;
  ret := DoValidateHeightmapItem(x, y);
  Result := Result or ret;
  fheightmap[x, y].height := GetIntInRange(fheightmap[x, y].height, -HEIGHTMAPRANGE, HEIGHTMAPRANGE);
end;

procedure TTerrain.Clear(const newt, newh: integer);
begin
  SetTextureSize(newt);
  SetHeightmapSize(newh);
  ClearTexture;
  ClearHeightmap;
end;

procedure TTerrain.SaveToStream(const strm: TStream; const compressed: boolean = true; const savebitmap: boolean = true);
var
  magic: integer;
  foo: integer;
  sz: integer;
  m: TMemoryStream;
  z: TZBitmap;
  i, j: integer;
begin
  magic := TERRAIN_MAGIC;
  strm.Write(magic, SizeOf(Integer));
  foo := 0; // Reserved for future use
  strm.Write(foo, SizeOf(Integer));
  sz := ftexturesize;
  strm.Write(sz, SizeOf(Integer));
  sz := fheightmapsize;
  strm.Write(sz, SizeOf(Integer));

  strm.Write(compressed, SizeOf(Boolean));

  m := TMemoryStream.Create;
  if savebitmap then
  begin
    if compressed then
    begin
      z := TZBitmap.Create;
      z.Assign(ftexture);
      z.PixelFormat := pf24bit;
      z.SaveToStream(m);
      z.Free;
    end
    else
      ftexture.SaveToStream(m);
    sz := m.Size;
  end
  else
    sz := 0;
  m.Position := 0;
  strm.Write(sz, SizeOf(Integer));
  if sz > 0 then
    strm.CopyFrom(m, sz);
  m.Free;

  for i := 0 to fheightmapsize - 1 do
    for j := 0 to fheightmapsize - 1 do
      strm.Write(fheightmap[i, j], SizeOf(fheightmap[i, j]));
end;

function TTerrain.LoadFromStream(const strm: TStream): boolean;
var
  magic: integer;
  foo: integer;
  sz: integer;
  m: TMemoryStream;
  z: TZBitmap;
  compressed: boolean;
  i, j: integer;
begin
  strm.Read(magic, SizeOf(Integer));
  if magic <> TERRAIN_MAGIC then
  begin
    Result := False;
    Exit;
  end;

  strm.Read(foo, SizeOf(Integer));
  if foo <> 0 then
  begin
    Result := False;
    Exit;
  end;

  strm.Read(sz, SizeOf(Integer));
  SetTextureSize(sz);
  strm.Read(sz, SizeOf(Integer));
  SetHeightmapSize(sz);

  strm.Read(compressed, SizeOf(Boolean));
  strm.Read(sz, SizeOf(Integer));
  if sz > 0 then
  begin
    m := TMemoryStream.Create;
    m.CopyFrom(strm, sz);
    m.Position := 0;
    if compressed then
    begin
      z := TZBitmap.Create;
      z.LoadFromStream(m);
      z.PixelFormat := pf32bit;
      ftexture.Assign(z);
      z.Free;
    end
    else
      ftexture.LoadFromStream(m);
    m.free;
  end;

  for i := 0 to fheightmapsize - 1 do
    for j := 0 to fheightmapsize - 1 do
      strm.Read(fheightmap[i, j], SizeOf(fheightmap[i, j]));

  Result := True;
end;

procedure TTerrain.SaveToFile(const fname: string; const compressed: boolean = true);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(fname, fmCreate);
  try
    SaveToStream(fs, compressed);
  finally
    fs.Free;
  end;
end;

function TTerrain.LoadFromFile(const fname: string): boolean;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
  try
    Result := LoadFromStream(fs);
  finally
    fs.Free;
  end;
end;

procedure TTerrain.TerrainToHeightmapIndex(const tX, tY: integer; out hX, hY: integer);
var
  centerx, centery: integer;
  blocksize: integer;
  x, y: integer;
  mindist: double;
  dist: double;
begin
  centerx := tX * (fheightmapsize - 1) div ftexturesize;
  centery := tY * (fheightmapsize - 1) div ftexturesize;


  hX := GetIntInRange(centerx, 0, fheightmapsize - 1);
  hY := GetIntInRange(centery, 0, fheightmapsize - 1);

  mindist := 1000000000.0;

  blocksize := ftexturesize div (fheightmapsize - 1);
  for x := GetIntInRange(centerx - 2, 0, fheightmapsize - 1) to GetIntInRange(centerx + 2, 0, fheightmapsize - 1) do
    for y := GetIntInRange(centery - 2, 0, fheightmapsize - 1) to GetIntInRange(centery + 2, 0, fheightmapsize - 1) do
    begin
      dist := sqr(x * blocksize + fheightmap[x, y].dx - tX) + sqr(y * blocksize + fheightmap[x, y].dy - tY);
      if dist < mindist then
      begin
        hX := x;
        hY := y;
        mindist := dist;
      end;
    end;
end;

function TTerrain.MoveHeightmapPoint(const hX, hY: integer; const px, py: integer): boolean;
var
  blocksize: integer;
  curx, cury: integer;
  oldx, oldy: integer;
begin
  Result := False;
  if (hX < 0) or (hX > fheightmapsize) then
    Exit;
  if (hY < 0) or (hY > fheightmapsize) then
    Exit;

  blocksize := ftexturesize div (fheightmapsize - 1);
  curx := hX * blocksize + fheightmap[hX, hY].dx;
  cury := hY * blocksize + fheightmap[hX, hY].dy;

  oldx := fheightmap[hX, hY].dx;
  oldy := fheightmap[hX, hY].dy;
  fheightmap[hX, hY].dx := px - hX * blocksize;
  fheightmap[hX, hY].dy := py - hY * blocksize;
  if not ValidHeightmapPivotAngle(hX, hY) then
  begin
    fheightmap[hX, hY].dx := oldx;
    fheightmap[hX, hY].dy := oldy;
  end;

  ValidateHeightmapItem(hX, hY);

  Result := (curx <> hX * blocksize + fheightmap[hX, hY].dx) or (cury <> hY * blocksize + fheightmap[hX, hY].dy);
end;

function TTerrain.HeightmapToCoord(const h: integer): integer;
var
  h1: integer;
begin
  h1 := GetIntInRange(h, 0, fheightmapsize - 1);
  Result := h1 * (ftexturesize div (fheightmapsize - 1));
end;

function TTerrain.HeightmapCoords(const x, y: integer): TPoint;
begin
  Result.X := HeightmapToCoord(x) + fheightmap[x, y].dx;
  Result.Y := HeightmapToCoord(y) + fheightmap[x, y].dy;
end;

function TTerrain.HeightmapCoords3D(const x, y: integer): point3d_t;
begin
  Result.X := HeightmapToCoord(x) + fheightmap[x, y].dx;
  Result.Y := HeightmapToCoord(y) + fheightmap[x, y].dy;
  Result.Z := fheightmap[x, y].height;
end;

function TTerrain.SmoothHeightmap(const x, y: integer; const factorpct: integer): boolean;
var
  hsum: integer;
  cnt: integer;
  iX, iY: integer;
  mean: double;
  oldh: integer;
begin
  Result := False;

  if factorpct = 0 then
    Exit;

  hsum := 0;
  cnt := 0;
  for iX := GetIntInRange(x - 1, 0, fheightmapsize - 1) to GetIntInRange(x + 1, 0, fheightmapsize - 1) do
    for iY := GetIntInRange(y - 1, 0, fheightmapsize - 1) to GetIntInRange(y + 1, 0, fheightmapsize - 1) do
      if (iX <> x) or (iY <> y) then
      begin
        hsum := hsum + fheightmap[iX, iY].height;
        inc(cnt);
      end;

  if cnt = 0 then
    Exit;

  mean := hsum / cnt;

  oldh := fheightmap[x, y].height;
  fheightmap[x, y].height := Round(fheightmap[x, y].height * (100 - factorpct) / 100 + mean * factorpct / 100);
  Result := fheightmap[x, y].height <> oldh;
end;

function TTerrain.ResampleHeightMapX2: boolean;
var
  fnewheightmap: heightbuffer_p;
  fnewheightmapsize: integer;
  oX, oY: integer;  // Old heightmap x & y
  nX, nY: integer;  // New heightmap x & y
begin
  Result := CanResampleHeightMapX2;
  if not Result then
    Exit;

  GetMem(fnewheightmap, SizeOf(heightbuffer_t));
  ZeroMemory(fnewheightmap, SizeOf(heightbuffer_t));

  for oX := 0 to fheightmapsize - 1 do
    for oY := 0 to fheightmapsize - 1 do
      fnewheightmap[2 * oX, 2 * oY] := fheightmap[oX, oY];

  fnewheightmapsize := fheightmapsize * 2 - 1;

  for nX := 0 to fnewheightmapsize - 1 do
  begin
    oX := nX div 2;
    for nY := 0 to fnewheightmapsize - 1 do
    begin
      oY := nY div 2;
      if Odd(nX) and Odd(nY) then
      begin
        fnewheightmap[nX, nY].height :=
          (
            fheightmap[oX + 1, oY + 1].height +
            fheightmap[oX + 1, oY    ].height +
            fheightmap[oX    , oY    ].height +
            fheightmap[oX    , oY + 1].height
          ) div 4;
        fnewheightmap[nX, nY].dx :=
          (
            fheightmap[oX + 1, oY + 1].dx +
            fheightmap[oX + 1, oY    ].dx +
            fheightmap[oX    , oY    ].dx +
            fheightmap[oX    , oY + 1].dx
          ) div 4;
        fnewheightmap[nX, nY].dy :=
          (
            fheightmap[oX + 1, oY + 1].dy +
            fheightmap[oX + 1, oY    ].dy +
            fheightmap[oX    , oY    ].dy +
            fheightmap[oX    , oY + 1].dy
          ) div 4;
      end
      else if Odd(nX) and not Odd(nY) then
      begin
        fnewheightmap[nX, nY].height :=
          (
            fheightmap[oX + 1, oY    ].height +
            fheightmap[oX    , oY    ].height
          ) div 2;
        fnewheightmap[nX, nY].dx :=
          (
            fheightmap[oX + 1, oY    ].dx +
            fheightmap[oX    , oY    ].dx
          ) div 2;
        fnewheightmap[nX, nY].dy :=
          (
            fheightmap[oX + 1, oY    ].dy +
            fheightmap[oX    , oY    ].dy
          ) div 2;
      end
      else if not Odd(nX) and Odd(nY) then
      begin
        fnewheightmap[nX, nY].height :=
          (
            fheightmap[oX    , oY + 1].height +
            fheightmap[oX    , oY    ].height
          ) div 2;
        fnewheightmap[nX, nY].dx :=
          (
            fheightmap[oX    , oY + 1].dx +
            fheightmap[oX    , oY    ].dx
          ) div 2;
        fnewheightmap[nX, nY].dy :=
          (
            fheightmap[oX    , oY + 1].dy +
            fheightmap[oX    , oY    ].dy
          ) div 2;
      end
    end;
  end;

  SetHeightMapSize(fnewheightmapsize);
  for nX := 0 to fheightmapsize - 1 do
    for nY := 0 to fheightmapsize - 1 do
      fheightmap[nX, nY] := fnewheightmap[nX, nY];

  for nX := 0 to fheightmapsize - 1 do
    for nY := 0 to fheightmapsize - 1 do
      ValidateHeightmapItem(nX, nY);

  FreeMem(fnewheightmap, SizeOf(heightbuffer_t));
end;

function TTerrain.CanResampleHeightMapX2: boolean;
var
  iX, iY: integer;
  testedgedxdy: integer;
  item: heightbufferitem_p;
begin
  Result := fheightmapsize <= 33;

  if Result then
  begin
    testedgedxdy := (ftexturesize div (fheightmapsize - 1)) div 4 - 1;
    for iX := 0 to fheightmapsize - 1 do
      for iY := 0 to fheightmapsize - 1 do
      begin
        item := @fheightmap[iX, iY];
        if (item.dx > testedgedxdy) or
           (item.dx < -testedgedxdy) or
           (item.dy > testedgedxdy) or
           (item.dy < -testedgedxdy) then
        begin
          Result := False;
          Exit;
        end;
      end;
  end;
end;

function TTerrain.heightmapblocksize: integer;
begin
  Result := ftexturesize div (fheightmapsize - 1);
end;

function TTerrain.RenderMeshGL(const sz: single): integer;
var
  iX, iY: integer;
  numTris: integer;

  procedure vertexGL(const hX, hY: integer);
  var
    it: heightbufferitem_p;
    pp: TPoint;
    xx, yy, zz: single;
    uu, vv: single;
  begin
    it := @fheightmap[hX, hY];
    pp := HeightmapCoords(hX, hY);
    xx := (pp.X - ftexturesize / 2) * sz / ftexturesize;
    yy := it.height * sz / ftexturesize;
    zz := (pp.Y - ftexturesize / 2) * sz / ftexturesize;
    if it.flags and HMF_STRETCHTEXTURE <> 0 then
    begin
      uu := -hX / fheightmapsize;
      vv := -hY / fheightmapsize;
    end
    else
    begin
      uu := -pp.X / ftexturesize;
      vv := -pp.Y / ftexturesize;
    end;
    glTexCoord2f(uu, vv);
    glVertex3f(xx, yy, zz);
  end;

begin
  numTris := 0;
  glDisable(GL_CULL_FACE);

  glBegin(GL_TRIANGLES);

    for iX := 0 to fheightmapsize - 2 do
      for iY := 0 to fheightmapsize - 2 do
      begin
        vertexGL(iX, iY);
        vertexGL(iX + 1, iY);
        vertexGL(iX, iY + 1);
        vertexGL(iX + 1, iY);
        vertexGL(iX, iY + 1);
        vertexGL(iX + 1, iY + 1);
        inc(numTris);
      end;

  glEnd;

  Result := numTris;
end;

function TTerrain.GenerateBitmapHeightmap(const bmh: bitmapheightmap_p; const bmhsize: integer): boolean;
type
  point3df_t = record
    X, Y, Z: single;
  end;
  point3df_p = ^point3df_t;

  triangle3df_t = record
    points: array[0..2] of point3df_t;
    fa, fb, fic, fd: single;
    left, right, top, bottom: integer;
    flat: boolean;
    z: single;
  end;
  triangle3df_p = ^triangle3df_t;

  procedure calc_plane(
    const tri: triangle3df_p);
  var
    x1, y1, z1: single;
    x2, y2, z2: single;
    x3, y3, z3: single;
    a1, b1, c1: single;
    a2, b2, c2: single;
    fa, fb, fc, fd: single;
  begin
    x1 := tri.points[0].X;
    y1 := tri.points[0].Y;
    z1 := tri.points[0].Z;
    x2 := tri.points[1].X;
    y2 := tri.points[1].Y;
    z2 := tri.points[1].Z;
    x3 := tri.points[2].X;
    y3 := tri.points[2].Y;
    z3 := tri.points[2].Z;
    a1 := x2 - x1;
    b1 := y2 - y1;
    c1 := z2 - z1;
    a2 := x3 - x1;
    b2 := y3 - y1;
    c2 := z3 - z1;
    fa := b1 * c2 - b2 * c1;
    fb := a2 * c1 - a1 * c2;
    fc := a1 * b2 - b1 * a2;
    fd := -(fa * x1 + fb * y1 + fc * z1);
    tri.fa := fa;
    tri.fb := fb;
    tri.fic := -1 / fc;
    tri.fd := fd;
    tri.flat := (z1 = z2) and (z1 = z3);
    if tri.flat then
      tri.z := z1;
  end;

  procedure calc_box(
    const tri: triangle3df_p);
  var
    l, r, t, b: single;
  begin
    // Left
    l := tri.points[0].X;
    if tri.points[1].X < l then
      l := tri.points[1].X;
    if tri.points[2].X < l then
      l := tri.points[2].X;
    // Right
    r := tri.points[0].X;
    if tri.points[1].X > r then
      r := tri.points[1].X;
    if tri.points[2].X > r then
      r := tri.points[2].X;
    // Top
    t := tri.points[0].Y;
    if tri.points[1].Y < t then
      t := tri.points[1].Y;
    if tri.points[2].Y < t then
      t := tri.points[2].Y;
    // Bottom
    b := tri.points[0].Y;
    if tri.points[1].Y > b then
      b := tri.points[1].Y;
    if tri.points[2].Y > b then
      b := tri.points[2].Y;

    tri.left := GetIntInRange(Trunc(l), 0, bmhsize - 1);
    tri.right := GetIntInRange(Trunc(r + 0.5), 0, bmhsize - 1);
    tri.top := GetIntInRange(Trunc(t), 0, bmhsize - 1);
    tri.bottom := GetIntInRange(Trunc(b), 0, bmhsize - 1);
  end;

  procedure GetTris(const x, y: integer; const tri1, tri2: triangle3df_p);
  var
    p1, p2, p3, p4: point3d_t;
  begin
    p1 := HeightmapCoords3D(x, y);
    p2 := HeightmapCoords3D(x + 1, y);
    p3 := HeightmapCoords3D(x + 1, y + 1);
    p4 := HeightmapCoords3D(x, y + 1);

    tri1.points[0].X := p1.X * bmhsize / ftexturesize;
    tri1.points[0].Y := p1.Y * bmhsize / ftexturesize;
    tri1.points[0].Z := p1.Z;
    tri1.points[1].X := p2.X * bmhsize / ftexturesize;
    tri1.points[1].Y := p2.Y * bmhsize / ftexturesize;
    tri1.points[1].Z := p2.Z;
    tri1.points[2].X := p4.X * bmhsize / ftexturesize;
    tri1.points[2].Y := p4.Y * bmhsize / ftexturesize;
    tri1.points[2].Z := p4.Z;
    calc_plane(tri1);
    calc_box(tri1);

    tri2.points[0].X := p4.X * bmhsize / ftexturesize;
    tri2.points[0].Y := p4.Y * bmhsize / ftexturesize;
    tri2.points[0].Z := p4.Z;
    tri2.points[1].X := p2.X * bmhsize / ftexturesize;
    tri2.points[1].Y := p2.Y * bmhsize / ftexturesize;
    tri2.points[1].Z := p2.Z;
    tri2.points[2].X := p3.X * bmhsize / ftexturesize;
    tri2.points[2].Y := p3.Y * bmhsize / ftexturesize;
    tri2.points[2].Z := p3.Z;
    calc_plane(tri2);
    calc_box(tri2);
  end;

  function sign(const x, y: integer; const p2, p3: point3df_p): single;
  begin
    result := (x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (y - p3.y);
  end;

  function PointInTriangle(const x, y: integer; const tri: triangle3df_p): boolean;
  var
    d1, d2, d3: single;
    has_neg, has_pos: boolean;
  begin
    d1 := sign(x, y, @tri.points[0], @tri.points[1]);
    d2 := sign(x, y, @tri.points[1], @tri.points[2]);
    d3 := sign(x, y, @tri.points[2], @tri.points[0]);

    has_neg := (d1 < 0) or (d2 < 0) or (d3 < 0);
    has_pos := (d1 > 0) or (d2 > 0) or (d3 > 0);

    result := not (has_neg and has_pos);
  end;

  function ZatPoint(const x, y: integer; const tri: triangle3df_p): single;
  begin
    if tri.flat then
      Result := tri.z
    else
      Result := (tri.fa * x + tri.fb * y + tri.fd) * tri.fic;
  end;

var
  hX, hY: integer;
  bX, bY: integer;
  tri1, tri2: triangle3df_t;
begin
  if not IsIntInRange(bmhsize, 1, MAXBITMAPHEIGHTMAP) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;

  for hX := 0 to fheightmapsize - 2 do
    for hY := 0 to fheightmapsize - 2 do
    begin
      GetTris(hX, hY, @tri1, @tri2);
      for bX := tri1.left to tri1.right do
        for bY := tri1.top to tri1.bottom do
        begin
          if PointInTriangle(bX, bY, @tri1) then
            bmh[bX, bY] := Round(ZatPoint(bX, bY, @tri1));
        end;
      for bX := tri2.left to tri2.right do
        for bY := tri2.top to tri2.bottom do
        begin
          if PointInTriangle(bX, bY, @tri2) then
            bmh[bX, bY] := Round(ZatPoint(bX, bY, @tri2));
        end;
    end;

end;

////////////////////////////////////////////////////////////////////////////////
function ter_validatetexturesize(const t: integer): integer;
begin
  if (t = 256) or (t = 512) or (t = 1024) or (t = 2048) then
  begin
    Result := t;
    Exit;
  end;
  if t < 256 then
    Result := 256
  else if t < 512 then
    Result := 512
  else if t < 1024 then
    Result := 1024
  else
    Result := 2048;
end;

function ter_validateheightmapsize(const h: integer): integer;
begin
  if (h = 5) or  (h = 9) or (h = 17) or (h = 33) or (h = 65) then
  begin
    Result := h;
    Exit;
  end;
  if h < 5 then
    Result := 5
  else if h < 9 then
    Result := 9
  else if h < 17 then
    Result := 17
  else if h < 33 then
    Result := 33
  else
    Result := 65;
end;

type
  resampleitem_t = record
    height: integer;
    heightmapX, heightmapY: integer;
  end;
  resampleitem_p = ^resampleitem_t;

const
  MAXRESAMPLEITEMS = 4;

type
  resampleitems_t = record
    cnt: integer;
    sample: array[0..MAXRESAMPLEITEMS - 1] of resampleitem_t;
  end;
  resampleitems_p = ^resampleitems_t;

const
  RESAMPLEMATRIXSIZE = 512;

type
  resamplematrix_t = array[0..RESAMPLEMATRIXSIZE - 1, 0..RESAMPLEMATRIXSIZE - 1] of resampleitems_t;
  resamplematrix_p = ^resamplematrix_t;


end.
