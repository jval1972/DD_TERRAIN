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
//  Color Palettes
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_palettes;

interface

const
  RadixPaletteRaw: array[0..767] of Byte = (
    $00, $00, $00, $C4, $BC, $B8, $BC, $B4, $B0, $B0, $A8, $A4, $AC, $A4, $A4,
    $A4, $9C, $9C, $A0, $98, $94, $98, $90, $8C, $90, $88, $88, $88, $80, $80,
    $84, $7C, $78, $7C, $74, $74, $74, $6C, $6C, $6C, $64, $64, $68, $60, $60,
    $64, $5C, $5C, $60, $58, $58, $5C, $54, $54, $54, $50, $50, $50, $4C, $4C,
    $4C, $48, $48, $48, $44, $44, $44, $40, $40, $40, $3C, $3C, $3C, $38, $38,
    $38, $34, $34, $30, $30, $30, $28, $28, $28, $20, $20, $20, $18, $18, $18,
    $10, $10, $10, $00, $00, $00, $C0, $C0, $CC, $B8, $B8, $C4, $B0, $B0, $BC,
    $AC, $AC, $B4, $A4, $A4, $B0, $98, $98, $A4, $90, $90, $9C, $88, $88, $90,
    $80, $80, $8C, $7C, $7C, $84, $74, $74, $7C, $70, $70, $7C, $6C, $6C, $74,
    $64, $64, $6C, $60, $60, $68, $5C, $5C, $64, $58, $58, $60, $54, $54, $5C,
    $50, $50, $58, $4C, $4C, $54, $48, $48, $4C, $44, $44, $4C, $40, $40, $44,
    $3C, $3C, $40, $38, $38, $3C, $34, $34, $38, $30, $30, $30, $2C, $2C, $30,
    $28, $28, $28, $20, $20, $20, $14, $14, $14, $00, $00, $00, $CC, $B4, $88,
    $C4, $AC, $80, $C0, $A8, $7C, $B8, $A0, $74, $B4, $98, $70, $AC, $94, $68,
    $A8, $8C, $64, $A0, $88, $5C, $9C, $80, $58, $94, $7C, $54, $90, $74, $50,
    $88, $70, $48, $84, $68, $44, $7C, $64, $40, $78, $60, $3C, $70, $58, $38,
    $6C, $54, $34, $64, $4C, $30, $60, $48, $2C, $58, $44, $28, $54, $3C, $24,
    $4C, $38, $20, $48, $34, $1C, $40, $30, $18, $3C, $2C, $14, $38, $24, $14,
    $30, $20, $10, $2C, $1C, $0C, $24, $18, $08, $20, $14, $08, $18, $10, $04,
    $14, $0C, $04, $54, $BC, $AC, $4C, $B0, $A0, $48, $A4, $90, $40, $98, $84,
    $38, $8C, $78, $34, $84, $6C, $2C, $78, $60, $28, $6C, $58, $24, $60, $4C,
    $1C, $54, $40, $18, $4C, $38, $14, $40, $2C, $10, $34, $24, $0C, $28, $1C,
    $08, $1C, $14, $04, $14, $0C, $80, $E8, $64, $74, $D8, $58, $68, $C4, $4C,
    $60, $B4, $44, $54, $A8, $3C, $4C, $98, $34, $44, $88, $2C, $3C, $7C, $24,
    $34, $70, $1C, $2C, $60, $18, $24, $50, $10, $20, $44, $10, $18, $38, $0C,
    $10, $2C, $08, $0C, $20, $04, $08, $14, $04, $FC, $FC, $FC, $FC, $FC, $D0,
    $FC, $FC, $A4, $FC, $FC, $7C, $FC, $FC, $50, $FC, $FC, $24, $FC, $FC, $00,
    $FC, $E8, $00, $F0, $C8, $00, $E4, $B0, $00, $D8, $94, $00, $D0, $7C, $00,
    $C4, $68, $00, $B8, $54, $00, $AC, $40, $00, $A4, $30, $00, $B4, $B8, $FC,
    $A8, $A4, $FC, $8C, $94, $F4, $68, $70, $F4, $58, $5C, $EC, $48, $48, $E4,
    $3C, $38, $DC, $2C, $24, $D4, $1C, $10, $CC, $1C, $08, $C4, $18, $00, $B8,
    $14, $00, $9C, $10, $00, $80, $08, $00, $60, $04, $00, $44, $00, $00, $28,
    $EC, $D8, $D8, $E0, $CC, $CC, $D4, $C0, $C0, $C8, $B4, $B4, $BC, $A8, $A8,
    $B0, $9C, $9C, $A4, $90, $90, $98, $84, $84, $FC, $F4, $78, $F8, $D4, $60,
    $E4, $B8, $4C, $D4, $9C, $3C, $C0, $80, $2C, $B0, $64, $20, $9C, $4C, $14,
    $7C, $30, $10, $A0, $9C, $64, $98, $94, $60, $90, $8C, $58, $84, $80, $54,
    $7C, $78, $4C, $74, $70, $48, $6C, $68, $40, $64, $60, $3C, $58, $54, $34,
    $50, $4C, $30, $48, $44, $28, $40, $3C, $24, $38, $34, $1C, $2C, $28, $18,
    $24, $20, $10, $1C, $18, $0C, $FC, $00, $FC, $E4, $00, $E4, $CC, $00, $CC,
    $B4, $00, $B4, $98, $00, $9C, $80, $00, $84, $68, $00, $6C, $50, $00, $54,
    $FC, $E4, $E4, $FC, $D4, $C4, $FC, $C0, $A8, $FC, $B4, $8C, $FC, $A0, $70,
    $FC, $94, $54, $FC, $80, $38, $FC, $74, $18, $F0, $68, $18, $E8, $64, $10,
    $DC, $5C, $10, $D8, $58, $0C, $CC, $50, $08, $C4, $48, $00, $BC, $40, $00,
    $B4, $3C, $00, $AC, $38, $00, $A0, $34, $00, $98, $30, $00, $8C, $2C, $00,
    $84, $28, $00, $78, $24, $00, $70, $20, $00, $64, $1C, $00, $F0, $BC, $BC,
    $F0, $AC, $AC, $F4, $9C, $9C, $F4, $8C, $8C, $F4, $7C, $7C, $F4, $6C, $6C,
    $F8, $60, $60, $F8, $50, $50, $F8, $40, $40, $F8, $30, $30, $FC, $20, $20,
    $F0, $20, $20, $E0, $1C, $1C, $D4, $1C, $1C, $C4, $18, $18, $B8, $18, $18,
    $A8, $14, $14, $9C, $14, $14, $8C, $10, $10, $80, $10, $10, $70, $0C, $0C,
    $64, $0C, $0C, $54, $08, $08, $48, $08, $08, $38, $04, $04, $2C, $04, $04,
    $1C, $00, $00, $10, $00, $00, $84, $58, $58, $A0, $38, $00, $84, $58, $58,
    $FC, $F8, $FC
  );

  DoomPaletteRaw: array[0..767] of Byte = (
    $00, $00, $00, $1F, $17, $0B, $17, $0F, $07, $4B, $4B, $4B, $FF, $FF, $FF,
    $1B, $1B, $1B, $13, $13, $13, $0B, $0B, $0B, $07, $07, $07, $2F, $37, $1F,
    $23, $2B, $0F, $17, $1F, $07, $0F, $17, $00, $4F, $3B, $2B, $47, $33, $23,
    $3F, $2B, $1B, $FF, $B7, $B7, $F7, $AB, $AB, $F3, $A3, $A3, $EB, $97, $97,
    $E7, $8F, $8F, $DF, $87, $87, $DB, $7B, $7B, $D3, $73, $73, $CB, $6B, $6B,
    $C7, $63, $63, $BF, $5B, $5B, $BB, $57, $57, $B3, $4F, $4F, $AF, $47, $47,
    $A7, $3F, $3F, $A3, $3B, $3B, $9B, $33, $33, $97, $2F, $2F, $8F, $2B, $2B,
    $8B, $23, $23, $83, $1F, $1F, $7F, $1B, $1B, $77, $17, $17, $73, $13, $13,
    $6B, $0F, $0F, $67, $0B, $0B, $5F, $07, $07, $5B, $07, $07, $53, $07, $07,
    $4F, $00, $00, $47, $00, $00, $43, $00, $00, $FF, $EB, $DF, $FF, $E3, $D3,
    $FF, $DB, $C7, $FF, $D3, $BB, $FF, $CF, $B3, $FF, $C7, $A7, $FF, $BF, $9B,
    $FF, $BB, $93, $FF, $B3, $83, $F7, $AB, $7B, $EF, $A3, $73, $E7, $9B, $6B,
    $DF, $93, $63, $D7, $8B, $5B, $CF, $83, $53, $CB, $7F, $4F, $BF, $7B, $4B,
    $B3, $73, $47, $AB, $6F, $43, $A3, $6B, $3F, $9B, $63, $3B, $8F, $5F, $37,
    $87, $57, $33, $7F, $53, $2F, $77, $4F, $2B, $6B, $47, $27, $5F, $43, $23,
    $53, $3F, $1F, $4B, $37, $1B, $3F, $2F, $17, $33, $2B, $13, $2B, $23, $0F,
    $EF, $EF, $EF, $E7, $E7, $E7, $DF, $DF, $DF, $DB, $DB, $DB, $D3, $D3, $D3,
    $CB, $CB, $CB, $C7, $C7, $C7, $BF, $BF, $BF, $B7, $B7, $B7, $B3, $B3, $B3,
    $AB, $AB, $AB, $A7, $A7, $A7, $9F, $9F, $9F, $97, $97, $97, $93, $93, $93,
    $8B, $8B, $8B, $83, $83, $83, $7F, $7F, $7F, $77, $77, $77, $6F, $6F, $6F,
    $6B, $6B, $6B, $63, $63, $63, $5B, $5B, $5B, $57, $57, $57, $4F, $4F, $4F,
    $47, $47, $47, $43, $43, $43, $3B, $3B, $3B, $37, $37, $37, $2F, $2F, $2F,
    $27, $27, $27, $23, $23, $23, $77, $FF, $6F, $6F, $EF, $67, $67, $DF, $5F,
    $5F, $CF, $57, $5B, $BF, $4F, $53, $AF, $47, $4B, $9F, $3F, $43, $93, $37,
    $3F, $83, $2F, $37, $73, $2B, $2F, $63, $23, $27, $53, $1B, $1F, $43, $17,
    $17, $33, $0F, $13, $23, $0B, $0B, $17, $07, $BF, $A7, $8F, $B7, $9F, $87,
    $AF, $97, $7F, $A7, $8F, $77, $9F, $87, $6F, $9B, $7F, $6B, $93, $7B, $63,
    $8B, $73, $5B, $83, $6B, $57, $7B, $63, $4F, $77, $5F, $4B, $6F, $57, $43,
    $67, $53, $3F, $5F, $4B, $37, $57, $43, $33, $53, $3F, $2F, $9F, $83, $63,
    $8F, $77, $53, $83, $6B, $4B, $77, $5F, $3F, $67, $53, $33, $5B, $47, $2B,
    $4F, $3B, $23, $43, $33, $1B, $7B, $7F, $63, $6F, $73, $57, $67, $6B, $4F,
    $5B, $63, $47, $53, $57, $3B, $47, $4F, $33, $3F, $47, $2B, $37, $3F, $27,
    $FF, $FF, $73, $EB, $DB, $57, $D7, $BB, $43, $C3, $9B, $2F, $AF, $7B, $1F,
    $9B, $5B, $13, $87, $43, $07, $73, $2B, $00, $FF, $FF, $FF, $FF, $DB, $DB,
    $FF, $BB, $BB, $FF, $9B, $9B, $FF, $7B, $7B, $FF, $5F, $5F, $FF, $3F, $3F,
    $FF, $1F, $1F, $FF, $00, $00, $EF, $00, $00, $E3, $00, $00, $D7, $00, $00,
    $CB, $00, $00, $BF, $00, $00, $B3, $00, $00, $A7, $00, $00, $9B, $00, $00,
    $8B, $00, $00, $7F, $00, $00, $73, $00, $00, $67, $00, $00, $5B, $00, $00,
    $4F, $00, $00, $43, $00, $00, $E7, $E7, $FF, $C7, $C7, $FF, $AB, $AB, $FF,
    $8F, $8F, $FF, $73, $73, $FF, $53, $53, $FF, $37, $37, $FF, $1B, $1B, $FF,
    $00, $00, $FF, $00, $00, $E3, $00, $00, $CB, $00, $00, $B3, $00, $00, $9B,
    $00, $00, $83, $00, $00, $6B, $00, $00, $53, $FF, $FF, $FF, $FF, $EB, $DB,
    $FF, $D7, $BB, $FF, $C7, $9B, $FF, $B3, $7B, $FF, $A3, $5B, $FF, $8F, $3B,
    $FF, $7F, $1B, $F3, $73, $17, $EB, $6F, $0F, $DF, $67, $0F, $D7, $5F, $0B,
    $CB, $57, $07, $C3, $4F, $00, $B7, $47, $00, $AF, $43, $00, $FF, $FF, $FF,
    $FF, $FF, $D7, $FF, $FF, $B3, $FF, $FF, $8F, $FF, $FF, $6B, $FF, $FF, $47,
    $FF, $FF, $23, $FF, $FF, $00, $A7, $3F, $00, $9F, $37, $00, $93, $2F, $00,
    $87, $23, $00, $4F, $3B, $27, $43, $2F, $1B, $37, $23, $13, $2F, $1B, $0B,
    $00, $00, $53, $00, $00, $47, $00, $00, $3B, $00, $00, $2F, $00, $00, $23,
    $00, $00, $17, $00, $00, $0B, $00, $00, $00, $FF, $9F, $43, $FF, $E7, $4B,
    $FF, $7B, $FF, $FF, $00, $FF, $CF, $00, $CF, $9F, $00, $9B, $6F, $00, $6B,
    $A7, $6B, $6B
  );

implementation

end.
 