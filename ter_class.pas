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

type
  heightbufferitem_t = packed record
    height: smallint;
    dx, dy: smallint;
  end;
  heightbufferitem_p = ^heightbufferitem_t;
  heightbuffer_t = packed array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of heightbufferitem_t;
  heightbuffer_p = ^heightbuffer_t;

type
  TTerrain = class(TObject)
  private
    ftexture: TBitmap;
    ftexturesize: integer;
    fheightmap: heightbuffer_p;
    fheightmapsize: integer;
  protected
    procedure ClearTexture;
    function GetTexture: TBitmap;
    procedure SetTextureSize(const val: integer);
    procedure SetHeightmapSize(const val: integer);
    function GetHeightmap(x, y: integer): heightbufferitem_t;
    procedure SetHeightmap(x, y: integer; val: heightbufferitem_t);
    procedure ValidateHeightmapItem(x, y: integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear(const newt, newh: integer);
    procedure SaveToStream(const strm: TStream; const compressed: boolean = true);
    function LoadFromStream(const strm: TStream): boolean;
    procedure SaveToFile(const fname: string; const compressed: boolean = true);
    function LoadFromFile(const fname: string): boolean;
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
  ter_utils, zBitmap;

constructor TTerrain.Create;
begin
  ftexture := TBitmap.Create;
  ftexturesize := 1024;
  ftexture.Width := ftexturesize;
  ftexture.Height := ftexturesize;
  ftexture.PixelFormat := pf32bit;
  ClearTexture;
  GetMem(fheightmap, SizeOf(heightbuffer_t));
  ZeroMemory(fheightmap, SizeOf(heightbuffer_t));
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

function TTerrain.GetTexture: TBitmap;
begin
  if (ftexturesize <> ftexture.Width) or (ftexturesize <> ftexture.Height) then
    raise Exception.Create(Format('TTerrain.GetTexture(): Invalid Texture Dimentions (%dx%d), should be (%d, %d)', [ftexture.Width, ftexture.Height, ftexturesize, ftexturesize]));
  if ftexture.PixelFormat <> pf32bit then
    raise Exception.Create('TTerrain.GetTexture(): Invalid Texture pixel format');
  result := ftexture;
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
begin
  if (x < 0) or (x > fheightmapsize) then
    Exit;
  if (y < 0) or (y > fheightmapsize) then
    Exit;

  item := @fheightmap[x, y];
  if item.height = val.height then
    if item.dx = val.dx then
      if item.dy = val.dy then
        Exit;

  item^ := val;
  ValidateHeightmapItem(x, y);
end;

procedure TTerrain.ValidateHeightmapItem(x, y: integer);
var
  maxdxdy: integer;
  item: heightbufferitem_p;
begin
  if (x < 0) or (x > fheightmapsize) then
    Exit;
  if (y < 0) or (y > fheightmapsize) then
    Exit;

  maxdxdy := ftexturesize div (fheightmapsize - 1) - 1;
  item := @fheightmap[x, y];

  if (x = 0) or (x = fheightmapsize - 1) then
    if (y = 0) or (y = fheightmapsize - 1) then
    begin
      item.dx := 0;
      item.dy := 0;
      Exit;
    end;

  if (x = 0) or (x = fheightmapsize - 1) then
  begin
    item.dx := 0;
    if item.dy > maxdxdy then
      item.dy := maxdxdy
    else if item.dy < -maxdxdy then
      item.dy := -maxdxdy;
    Exit;
  end;

  if (y = 0) or (y = fheightmapsize - 1) then
  begin
    item.dy := 0;
    if item.dx > maxdxdy then
      item.dx := maxdxdy
    else if item.dx < -maxdxdy then
      item.dx := -maxdxdy;
    Exit;
  end;

  if item.dx > maxdxdy then
    item.dx := maxdxdy
  else if item.dx < -maxdxdy then
    item.dx := -maxdxdy;
  if item.dy > maxdxdy then
    item.dy := maxdxdy
  else if item.dy < -maxdxdy then
    item.dy := -maxdxdy;
end;

procedure TTerrain.Clear(const newt, newh: integer);
begin
  SetTextureSize(newt);
  SetHeightmapSize(newh);
  ClearTexture;
end;

procedure TTerrain.SaveToStream(const strm: TStream; const compressed: boolean = true);
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
  m.Position := 0;
  strm.Write(sz, SizeOf(Integer));
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
    result := false;
    exit;
  end;

  strm.Read(foo, SizeOf(Integer));
  if foo <> 0 then
  begin
    result := false;
    exit;
  end;

  strm.Read(sz, SizeOf(Integer));
  SetTextureSize(sz);
  strm.Read(sz, SizeOf(Integer));
  SetHeightmapSize(sz);

  strm.Read(compressed, SizeOf(Boolean));
  strm.Read(sz, SizeOf(Integer));
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
