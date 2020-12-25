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
//  Voxel stuff
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_voxels;

interface

const
  MAXVOXELSIZE = 256;

type
  voxelview_t = (vv_none, vv_front, vv_back, vv_left, vv_right, vv_top, vv_down);

  voxelitem_t = LongWord;
  voxelitem_p = ^voxelitem_t;
  voxelbuffer_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of voxelitem_t;
  voxelbuffer_p = ^voxelbuffer_t;

  voxelbuffer2d_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of voxelitem_t;
  voxelbuffer2d_p = ^voxelbuffer2d_t;

procedure vox_getviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const outbuf: voxelbuffer2d_p; const vv: voxelview_t);

procedure vox_shrinkyaxis(const buf: voxelbuffer_p; const size: integer;
  const amin, amax: integer);

procedure vox_removenonvisiblecells(const buf: voxelbuffer_p; const size: integer);

procedure VXE_ExportVoxelToSlab6VOX(const voxelbuffer: voxelbuffer_p; const voxelsize: Integer;
  const fname: string);

procedure VXE_ExportVoxelToDDVOX(const voxelbuffer: voxelbuffer_p; const voxelsize: Integer;
  const fname: string);

implementation

uses
  Windows,
  Classes,
  ter_utils,
  ter_quantize,
  ter_palettes;

procedure vox_getviewbuffer(const buf: voxelbuffer_p; const size: integer;
  const outbuf: voxelbuffer2d_p; const vv: voxelview_t);
var
  x, y, z: integer;
  c: voxelitem_t;
begin
  for x := 0 to size - 1 do
    for y := 0 to size - 1 do
      outbuf[x, y] := 0;

  if vv = vv_front then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for z := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, y] := c;
      end;
    Exit;
  end;

  if vv = vv_back then
  begin
    for x := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for z := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, y] := c;
      end;
    Exit;
  end;

  if vv = vv_left then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for x := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[size - 1 - z, y] := c;
      end;
    Exit;
  end;

  if vv = vv_right then
  begin
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
      begin
        c := 0;
        for x := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[z, y] := c;
      end;
    Exit;
  end;

  if vv = vv_top then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        c := 0;
        for y := 0 to size - 1 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, size - 1 - z] := c;
      end;
    Exit;
  end;

  if vv = vv_down then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
      begin
        c := 0;
        for y := size - 1 downto 0 do
          if buf[x, y, z] <> 0 then
          begin
            c := buf[x, y, z];
            Break;
          end;
        outbuf[x, z] := c;
      end;
    Exit;
  end;
end;

procedure vox_shrinkyaxis(const buf: voxelbuffer_p; const size: integer;
  const amin, amax: integer);
var
  bck: voxelbuffer_p;
  mn, mx, tmp: integer;
  x, y, y1, z: integer;
  factor, mne: Extended;
begin
  if amin = 0 then
    if amax = 255 then
      Exit;

  if amax = 0 then
    if amin = 255 then
      Exit;

  GetMem(bck, MAXVOXELSIZE * MAXVOXELSIZE * size * SizeOf(voxelitem_t));
  for x := 0 to size - 1 do
    for y := 0 to size - 1 do
      for z := 0 to size - 1 do
        bck[x, y, z] := buf[x, y, z];

  mn := amin;
  mx := amax;

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

  for x := 0 to size - 1 do
    for z := 0 to size - 1 do
      for y := 0 to size - 1 do
        buf[x, y, z] := 0;

  factor := (mx - mn) / MAXVOXELSIZE;
  if size = MAXVOXELSIZE then
  begin
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
        for y := 0 to size - 1 do
        begin
          y1 := Round(mn + y * factor);
          if y1 < 0 then
            y1 := 0
          else if y1 >= MAXVOXELSIZE then
            y1 := MAXVOXELSIZE;
          if buf[x, y1, z] = 0 then
            buf[x, y1, z] := bck[x, y, z];
        end;
  end
  else
  begin
    mne := mn * size / MAXVOXELSIZE;
    for x := 0 to size - 1 do
      for z := 0 to size - 1 do
        for y := 0 to size - 1 do
        begin
          y1 := Round(mne + y * factor);
          if y1 < 0 then
            y1 := 0
          else if y1 >= size then
            y1 := size;
          if buf[x, y1, z] = 0 then
            buf[x, y1, z] := bck[x, y, z];
        end;
  end;

  FreeMem(bck, MAXVOXELSIZE * MAXVOXELSIZE * size * SizeOf(voxelitem_t));
end;

procedure vox_removenonvisiblecells(const buf: voxelbuffer_p; const size: integer);
type
  flags_t = array[0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1, 0..MAXVOXELSIZE - 1] of boolean;
  flags_p = ^flags_t;
var
  i, j, k: integer;
  flags: flags_p;
begin
  GetMem(flags, SizeOf(flags_t));
  FillChar(flags^, SizeOf(flags_t), Chr(0));

  for i := 1 to size - 2 do
  begin
    for j := 1 to size - 2 do
      for k := 1 to size - 2 do
        if buf[i, j, k] <> 0 then
          if buf[i - 1, j, k] <> 0 then
            if buf[i + 1, j, k] <> 0 then
              if buf[i, j - 1, k] <> 0 then
                if buf[i, j + 1, k] <> 0 then
                  if buf[i, j, k - 1] <> 0 then
                    if buf[i, j, k + 1] <> 0 then
                      flags^[i, j, k] := true;
  end;

  for i := 1 to size - 2 do
  begin
    for j := 1 to size - 2 do
      for k := 1 to size - 2 do
        if flags^[i, j, k] then
          buf[i, j, k] := 0;
  end;

  FreeMem(flags, SizeOf(flags_t));
end;

procedure VXE_ExportVoxelToSlab6VOX(const voxelbuffer: voxelbuffer_p; const voxelsize: Integer;
  const fname: string);
var
  i: integer;
  fvoxelsize: Integer;
  x, y, z: integer;
  x1, x2, y1, y2, z1, z2: integer;
  voxdata: PByteArray;
  voxsize: integer;
  dpal: array[0..767] of byte;
  vpal: array[0..255] of LongWord;
  fs: TFileStream;
  c: LongWord;
begin
  BackupFile(fname);
  if voxelsize >= 256 then
  begin
    x1 := 1; x2 := 255;
    y1 := 1; y2 := 255;
    z1 := 1; z2 := 255;
    fvoxelsize := 255
  end
  else
  begin
    x1 := 0; x2 := voxelsize - 1;
    y1 := 0; y2 := voxelsize - 1;
    z1 := 0; z2 := voxelsize - 1;
    fvoxelsize := voxelsize;
  end;
  voxsize := fvoxelsize * fvoxelsize * fvoxelsize;
  GetMem(voxdata, voxsize);

  for i := 0 to 255 do
    vpal[i] := 0;

  if vxe_getquantizevoxelpalette(voxelbuffer, voxelsize, @vpal, 255) then
  begin
    for i := 0 to 255 do
    begin
      c := vpal[i];
      dpal[3 * i] := GetRValue(c);
      dpal[3 * i + 1] := GetGValue(c);
      dpal[3 * i + 2] := GetBValue(c);
    end;
  end
  else
  begin
    for i := 0 to 764 do
      dpal[i] := DoomPaletteRaw[i + 3];
    for i := 765 to 767 do
      dpal[i] := 0;
    for i := 0 to 254 do
      vpal[i] := RGB(dpal[3 * i], dpal[3 * i + 1], dpal[3 * i + 2]);
  end;

  fs := TFileStream.Create(fname, fmCreate);
  try
    for i := 0 to 2 do
      fs.Write(fvoxelsize, SizeOf(integer));
    i := 0;
    for x := x1 to x2 do
      for y := y1 to y2 do
        for z := z1 to z2 do
        begin
          c := voxelbuffer[x, z, fvoxelsize - 1 - y];
          if c = 0 then
            voxdata[i] := 255
          else
            voxdata[i] := V_FindAproxColorIndex(@vpal, c, 0, 254);
          inc(i);
        end;
    fs.Write(voxdata^, voxsize);
    fs.Write(dpal, 768);
  finally
    fs.Free;
  end;

  FreeMem(voxdata, voxsize);
end;

procedure VXE_ExportVoxelToDDVOX(const voxelbuffer: voxelbuffer_p; const voxelsize: Integer;
  const fname: string);
var
  t: TextFile;
  xx, yy, zz: integer;
  skip: integer;
begin
  BackupFile(fname);
  AssignFile(t, fname);
  Rewrite(t);
  Writeln(t, voxelsize);
  for xx := 0 to voxelsize - 1 do
    for yy := 0 to voxelsize - 1 do
    begin
      skip := 0;
      for zz := 0 to voxelsize - 1 do
      begin
        if voxelbuffer[xx, yy, zz] = 0 then
        begin
          Inc(skip);
          if zz = voxelsize - 1 then
            Writeln(t, 'skip ', skip);
        end
        else
        begin
          if skip > 0 then
          begin
            Write(t, 'skip ', skip, ', ');
            skip := 0;
          end;
          if zz = voxelsize - 1 then
            Writeln(t, voxelbuffer[xx, yy, zz])
          else
            Write(t, voxelbuffer[xx, yy, zz], ', ');
        end;
      end;
    end;

  CloseFile(t);
end;

end.

