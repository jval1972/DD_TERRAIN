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
//  Doom MAP file definitions
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_doomdata;

interface

uses
  ter_wad;

const
// Skill flags.
  MTF_EASY = 1;
  MTF_NORMAL = 2;
  MTF_HARD = 4;

// Hexen additional flags
  MTF_FIGHTER = 32;
  MTF_CLERIC = 64;
  MTF_MAGE = 128;
  MTF_GSINGLE = 256;
  MTF_GCOOP = 512;
  MTF_GDEATHMATCH = 1024;

type
  mapvertex_t = packed record
    x: smallint;
    y: smallint;
  end;
  Pmapvertex_t = ^mapvertex_t;
  mapvertex_tArray = packed array[0..$FFF] of mapvertex_t;
  Pmapvertex_tArray = ^mapvertex_tArray;

  zmapvertex_t = packed record
    x: smallint;
    y: smallint;
    z: smallint;
  end;
  Pzmapvertex_t = ^zmapvertex_t;
  zmapvertex_tArray = packed array[0..$FFF] of zmapvertex_t;
  Pzmapvertex_tArray = ^zmapvertex_tArray;

  mapsidedef_t = packed record
    textureoffset: smallint;
    rowoffset: smallint;
    toptexture: char8_t;
    bottomtexture: char8_t;
    midtexture: char8_t;
  // Front sector, towards viewer.
    sector: smallint;
  end;
  Pmapsidedef_t = ^mapsidedef_t;
  mapsidedef_tArray = packed array[0..$FFF] of mapsidedef_t;
  Pmapsidedef_tArray = ^mapsidedef_tArray;

  maplinedef_t = packed record
    v1: smallint;
    v2: smallint;
    flags: smallint;
    special: smallint;
    tag: smallint;
  // sidenum[1] will be -1 if one sided
    sidenum: packed array[0..1] of smallint;
  end;
  Pmaplinedef_t = ^maplinedef_t;
  maplinedef_tArray = packed array[0..$FFF] of maplinedef_t;
  Pmaplinedef_tArray = ^maplinedef_tArray;

  hmaplinedef_t = packed record
    v1: smallint;
    v2: smallint;
    flags: smallint;
    special: byte;
    arg1: byte;
    arg2: byte;
    arg3: byte;
    arg4: byte;
    arg5: byte;
    sidenum: packed array[0..1] of smallint;
  end;
  Phmaplinedef_t = ^hmaplinedef_t;
  hmaplinedef_tArray = packed array[0..$FFFF] of hmaplinedef_t;
  Phmaplinedef_tArray = ^hmaplinedef_tArray;

const
// Solid, is an obstacle.
  ML_BLOCKING = 1;

// Blocks monsters only.
  ML_BLOCKMONSTERS = 2;

// Backside will not be present at all
//  if not two sided.
  ML_TWOSIDED = 4;

// If a texture is pegged, the texture will have
// the end exposed to air held constant at the
// top or bottom of the texture (stairs or pulled
// down things) and will move with a height change
// of one of the neighbor sectors.
// Unpegged textures allways have the first row of
// the texture at the top pixel of the line for both
// top and bottom textures (use next to windows).

// upper texture unpegged
  ML_DONTPEGTOP = 8;

// lower texture unpegged
  ML_DONTPEGBOTTOM = 16;

// In AutoMap: don't map as two sided: IT'S A SECRET!
  ML_SECRET = 32;

// Sound rendering: don't let sound cross two of these.
  ML_SOUNDBLOCK = 64;

// Don't draw on the automap at all.
  ML_DONTDRAW = 128;

// Set if already seen, thus drawn in automap.
  ML_MAPPED = 256;

//jff 3/21/98 Set if line absorbs use by player
//allow multiple push/switch triggers to be used on one push
  ML_PASSUSE = 512;
//JVAL: Script Events
//line triggers
  ML_TRIGGERSCRIPTS = 1024;
// Don't pack (Terrain Editor)
  ML_DONTPACK = 2048;

type
// Sector definition, from editing.
  mapsector_t = packed record
    floorheight: smallint;
    ceilingheight: smallint;
    floorpic: char8_t;
    ceilingpic: char8_t;
    lightlevel: smallint;
    special: smallint;
    tag: smallint;
  end;
  Pmapsector_t = ^mapsector_t;
  mapsector_tArray = packed array[0..$FFFF] of mapsector_t;
  Pmapsector_tArray = ^mapsector_tArray;

  mapthing_t = packed record
    x: smallint;
    y: smallint;
    angle: smallint;
    _type: word;
    options: smallint;
  end;
  Pmapthing_t = ^mapthing_t;
  mapthing_tArray = packed array[0..$FFFF] of mapthing_t;
  Pmapthing_tArray = ^mapthing_tArray;

  hmapthing_t = packed record
    tid: smallint;
    x: smallint;
    y: smallint;
    height: smallint;
    angle: smallint;
    _type: word;
    options: smallint;
    special: byte;
    arg1: byte;
    arg2: byte;
    arg3: byte;
    arg4: byte;
    arg5: byte;
  end;
  Phmapthing_t = ^hmapthing_t;
  hmapthing_tArray = packed array[0..$FFFF] of hmapthing_t;
  Phmapthing_tArray = ^hmapthing_tArray;

type
  mappatch_t = packed record
    originx: smallint;
    originy: smallint;
    patch: smallint;
    stepdir: smallint;
    colormap: smallint;
  end;
  Pmappatch_t = ^mappatch_t;

//
// Texture definition.
// A DOOM wall texture is a list of patches
// which are to be combined in a predefined order.
//
  maptexture_t = packed record
    name: char8_t;
    masked: integer;
    width: smallint;
    height: smallint;
    filler: LongWord; // unused
    patchcount: smallint;
    patches: array[0..0] of mappatch_t;
  end;
  Pmaptexture_t = ^maptexture_t;

// posts are runs of non masked source pixels
  post_t = packed record
    topdelta: byte; // -1 is the last post in a column
    length: byte;   // length data bytes follows
  end;
  Ppost_t = ^post_t;

// column_t is a list of 0 or more post_t, (byte)-1 terminated
  column_t = post_t;
  Pcolumn_t = ^column_t;

  patch_t = packed record
    width: smallint; // bounding box size
    height: smallint;
    leftoffset: smallint; // pixels to the left of origin
    topoffset: smallint;  // pixels below the origin
    columnofs: array[0..7] of integer; // only [width] used
    // the [0] is &columnofs[width]
  end;
  Ppatch_t = ^patch_t;

  pnames_t = record
    numentries: LongWord;
    names: array[0..0] of char8_t;
  end;
  Ppnames_t = ^pnames_t;

implementation

end.
