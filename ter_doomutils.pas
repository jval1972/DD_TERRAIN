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
//  Doom/WAD file utility functions
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_doomutils;

interface

uses
  Graphics,
  ter_utils;

function IsValidWADPatchImage(const buf: pointer; const size: integer): boolean;

function DoomPatchToBitmap(const buf: pointer; const size: integer;
  const pal: PLongWordArray): TBitmap;

implementation

uses
  ter_doomdata;

function IsValidWADPatchImage(const buf: pointer; const size: integer): boolean;
var
  N: integer;
  patch: Ppatch_t;
  col: integer;
  column: Pcolumn_t;
  desttop: integer;
  dest: integer;
  w, h: integer;
  mx: integer;
  cnt: integer;
  delta, prevdelta: integer;
  tallpatch: boolean;
begin
  Result := True;

  patch := buf;

  w := patch.width;
  h := patch.height;

  N := size;
  if IsIntInRange(w, 0, 8192) and IsIntInRange(h, 0, 1024) then
  begin
    col := 0;
    desttop := 0;
    mx := w * h;

    while col < w do
    begin
      if not Result then
        Break;

      column := Pcolumn_t(integer(patch) + patch.columnofs[col]);
      if not IsIntInRange(integer(column), integer(patch), integer(patch) + N - 3) then
      begin
        if column.topdelta <> $ff then
        begin
          Result := False;
          Break;
        end;
      end;
      if not IsIntInRange(integer(column), integer(patch), integer(patch) + N) then
      begin
        Result := False;
        Break;
      end;

      delta := 0;
      tallpatch := false;

      // step through the posts in a column
      cnt := 0;
      while column.topdelta <> $ff do
      begin
        if not Result then
          Break;

        delta := delta + column.topdelta;
        dest := desttop + (delta + column.length - 1) * w;
        if dest >= mx then
        begin
          Result := False;
          Break;
        end;

        if not tallpatch then
        begin
          prevdelta := column.topdelta;
          column := Pcolumn_t(integer(column) + column.length + 4);
          if column.topdelta > prevdelta then
            delta := 0
          else
            tallpatch := True;
        end
        else
          column := Pcolumn_t(integer(column) + column.length + 4);

        if not IsIntInRange(integer(column), integer(patch), integer(patch) + N - 3) then
          if col < w - 1 then
          begin
            Result := False;
            Break;
          end;

        inc(cnt);
        if cnt >= h then
        begin
          Result := False;
          Break;
        end;
      end;
      inc(col);
      inc(desttop);
    end;

  end
  else
    Result := False;
end;

function DoomPatchToBitmap(const buf: pointer; const size: integer;
  const pal: PLongWordArray): TBitmap;
var
  patch: Ppatch_t;
  bm: TBitmap;
  x, y: integer;
  col, w: integer;
  line: PLongWordArray;
  tallpatch: boolean;
  delta, prevdelta, count: integer;
  column: Pcolumn_t;
  source: PByte;
begin
  patch := buf;
  bm := TBitmap.Create;
  try
    bm.Width := patch.height;
    bm.Height := patch.width;
    bm.PixelFormat := pf32bit;

    x := -patch.leftoffset;
    y := -patch.topoffset;

    w := patch.width;

    col := 0;

    // Flipped draw bitmap
    while col < w do
    begin
      if (col + x >= 0) and (col + x < bm.Height) then
      begin
        line := bm.ScanLine[col + x];
        column := Pcolumn_t(integer(patch) + patch.columnofs[col]);
        source := PByte(integer(column) + 3);
        delta := 0;
        tallpatch := false;
        // step through the posts in a column
        while column.topdelta <> $ff do
        begin
          delta := delta + column.topdelta;
          count := column.length;
          while count > 0 do
          begin
            dec(count);
            if IsIntInRange(delta + count + y, 0, bm.Width - 1) then
              line[delta + count + y] := pal[source^];
            inc(source);
          end;
          if not tallpatch then
          begin
            prevdelta := column.topdelta;
            column := Pcolumn_t(integer(column) + column.length + 4);
            if column.topdelta > prevdelta then
              delta := 0
            else
              tallpatch := true;
          end
          else
            column := Pcolumn_t(integer(column) + column.length + 4);
        end;
      end;
      inc(col);
    end;

    RotateBitmap90DegreesCounterClockwise(bm);

  finally
    Result := bm;
  end;
end;

end.
