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

type
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
    function heightmapblocksize: integer;
    function RenderMeshGL(const sz: single): integer;
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

end.
