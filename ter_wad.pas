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
//  WAD file definitions
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_wad;

interface

type
  char8_t = array[0..7] of char;
  Pchar8_t = ^char8_t;

  wadinfo_t = packed record
    // Should be "IWAD" or "PWAD".
    identification: integer;
    numlumps: integer;
    infotableofs: integer;
  end;
  Pwadinfo_t = ^wadinfo_t;

  filelump_t = packed record
    filepos: integer;
    size: integer;
    name: char8_t;
  end;
  Pfilelump_t = ^filelump_t;
  Tfilelump_tArray = packed array[0..$FFFF] of filelump_t;
  Pfilelump_tArray = ^Tfilelump_tArray;

const
  IWAD = integer(Ord('I') or
                (Ord('W') shl 8) or
                (Ord('A') shl 16) or
                (Ord('D') shl 24));

  PWAD = integer(Ord('P') or
                (Ord('W') shl 8) or
                (Ord('A') shl 16) or
                (Ord('D') shl 24));

function char8tostring(src: char8_t): string;

function stringtochar8(src: string): char8_t;

implementation

function char8tostring(src: char8_t): string;
var
  i: integer;
begin
  Result := '';
  i := 0;
  while (i < 8) and (src[i] <> #0) do
  begin
    Result := Result + src[i];
    inc(i);
  end;
end;

function stringtochar8(src: string): char8_t;
var
  i: integer;
  len: integer;
begin
  len := length(src);
  if len > 8 then
    len := 8;

  i := 1;
  while (i <= len) do
  begin
    Result[i - 1] := src[i];
    inc(i);
  end;

  for i := len to 7 do
    Result[i] := #0;
end;


end.
 
