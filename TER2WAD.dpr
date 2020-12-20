//------------------------------------------------------------------------------
//
//  TER2WAD - Converts DD_TERRAIN terrains to WAD maps
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
//  Main Programm
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

program TER2WAD;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes,
  ter_class in 'ter_class.pas',
  ter_doomdata in 'ter_doomdata.pas',
  ter_wadexport in 'ter_wadexport.pas',
  ter_wadwriter in 'ter_wadwriter.pas',
  zBitmap in 'zBitmap.pas',
  ter_palettes in 'ter_palettes.pas',
  ter_utils in 'ter_utils.pas',
  ter_wad in 'ter_wad.pas',
  ter_quantize in 'ter_quantize.pas',
  pnglang in 'pnglang.pas',
  pngextra in 'pngextra.pas',
  zlibpas in 'zlibpas.pas';

function M_CheckParam(const opt: string; const default: string = ''): string;
var
  i: integer;
begin
  for i := 1 to ParamCount - 1 do
    if UpperCase(ParamStr(i)) = UpperCase(opt) then
    begin
      Result := ParamStr(i + 1);
      Exit;
    end;
  Result := default;
end;

function M_CheckOption(const opt: string): boolean;
var
  i: integer;
begin
  for i := 1 to ParamCount do
    if UpperCase(ParamStr(i)) = UpperCase(opt) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

procedure PressAnyKeyToContinue;
var
  k: byte;
begin
  while True do
    for k := 0 to 255 do
    begin
      GetAsyncKeyState(k);
      if GetAsyncKeyState(k) <> 0 then
        Exit;
    end;
end;

procedure ExitProgram(const code: integer);
begin
  if M_CheckOption('-wait') then
    PressAnyKeyToContinue;
  Halt(code);
end;

procedure Help;
begin
  writeln('TER2WAD is a utility that converts DD_TERRAIN terrains to WAD maps');
  writeln('');
  writeln('Usage:');
  writeln('  TER2WAD -i [..] -o [..] -e [..] -p [..] [options]');
  writeln('');
  writeln('Required Parameters:');
  writeln('  -i [input filename]      Specifies the input filename (*.terrain)');
  writeln('  -o [output filename]     Specifies the output filename (*.wad)');
  writeln('  -e [engine name]         Engine name (RAD/HEXEN/UDMF)');
  writeln('Optional Parameters:');
  writeln('  -g [game]                Game (RADIX/DOOM/HERETIC/HEXEN/STRIFE)');
  writeln('  -l [levelname]           Level name of output WAD');
  writeln('  -stexture [texture]      Default sidedef texture');
  writeln('  -ctexture [texture]      Default ceiling texture');
  writeln('Options:');
  writeln('  -noslope                 Does not create sloped surfaces');
  writeln('  -nodeformation           Ignores deformation data of the terrain');
  writeln('  -notexture               Does not import the terrain texture');
  writeln('  -noplayer                Does not add a player start');
  writeln('Additional Switches:');
  writeln('  -h                       Displays this help screen');
  writeln('  -wait                    Waits for key press when done');
end;

procedure PromptHelp;
begin
  writeln('Type "TER2WAD -h" for help');
end;

var
  fexportoptions: exportwadoptions_t;
  finp, fout: string;
  engine: string;
  game: string;
  t: TTerrain;
  fs: TFileStream;
  stats: wadexportstats_t;
begin
  writeln('TER2WAD version 1.0, (c) 2020 - Jim Valavanis');
  writeln;
  if M_CheckOption('-h') then
  begin
    Help;
    ExitProgram(0);
  end;

  finp := M_CheckParam('-i');
  fout := M_CheckParam('-o');
  engine := UpperCase(M_CheckParam('-e'));

  if finp = '' then
  begin
    writeln('Input file not specified');
    PromptHelp;
    ExitProgram(1);
  end;

  if fout = '' then
  begin
    writeln('Output file not specified');
    PromptHelp;
    ExitProgram(1);
  end;

  if UpperCase(ExpandFileName(finp)) = UpperCase(ExpandFileName(fout)) then
  begin
    writeln('Input and output files can not be the same');
    PromptHelp;
    ExitProgram(1);
  end;

  if not FileExists(finp) then
  begin
    writeln('Input file is unknown');
    PromptHelp;
    ExitProgram(1);
  end;

  if engine = '' then
  begin
    writeln('Engine not specified (RAD/HEXEN/UDMF)');
    PromptHelp;
    ExitProgram(1);
  end;

  if engine <> 'RAD' then
    if engine <> 'HEXEN' then
      if engine <> 'UDMF' then
      begin
        writeln('Invalid engine "' + M_CheckParam('-e') + '"');
        PromptHelp;
        ExitProgram(1);
      end;

  fexportoptions.flags := ETF_CALCDXDY or ETF_TRUECOLORFLAT or ETF_MERGEFLATSECTORS or ETF_ADDPLAYERSTART or ETF_EXPORTFLAT;
  if engine = 'UDMF' then
    fexportoptions.engine := ENGINE_UDMF
  else if engine = 'HEXEN' then
  begin
    fexportoptions.engine := ENGINE_VAVOOM;
    fexportoptions.flags := fexportoptions.flags or ETF_HEXENHEIGHT;
    fexportoptions.raiseid := 1504;
    fexportoptions.lowerid := 1504;
  end
  else
  begin
    fexportoptions.engine := ENGINE_RAD;
    fexportoptions.lowerid := 1255;
    fexportoptions.raiseid := 1254;
  end;

  if engine = 'UDMF' then
    game := 'DOOM'
  else if engine = 'HEXEN' then
    game := 'HEXEN'
  else
    game := 'RADIX';

  game := UpperCase(M_CheckParam('-g', game));

  if game <> 'RADIX' then
    if game <> 'DOOM' then
      if game <> 'HERETIC' then
        if game <> 'HEXEN' then
          if game <> 'STRIFE' then
          begin
            writeln('Invalid game "' + M_CheckParam('-g') + '"');
            PromptHelp;
            ExitProgram(1);
          end;

  if game = 'RADIX' then
  begin
    fexportoptions.palette := @RadixPaletteRaw;
    fexportoptions.defsidetex := 'RDXW0012';
    fexportoptions.defceilingtex := 'F_SKY1';
    fexportoptions.levelname := 'MAP01';
  end
  else if game = 'DOOM' then
  begin
    fexportoptions.palette := @DoomPaletteRaw;
    fexportoptions.levelname := 'MAP01';
    fexportoptions.defsidetex := 'METAL1';
    fexportoptions.defceilingtex := 'F_SKY1';
  end
  else if game = 'HERETIC' then
  begin
    fexportoptions.palette := @HereticPaletteRaw;
    fexportoptions.levelname := 'E1M1';
    fexportoptions.defsidetex := 'CSTLRCK';
    fexportoptions.defceilingtex := 'F_SKY1';
  end
  else if game = 'HEXEN' then
  begin
    fexportoptions.palette := @HexenPaletteRaw;
    fexportoptions.levelname := 'MAP01';
    fexportoptions.defsidetex := 'FOREST02';
    fexportoptions.defceilingtex := 'F_SKY';
  end
  else if game = 'STRIFE' then
  begin
    fexportoptions.palette := @StrifePaletteRaw;
    fexportoptions.levelname := 'MAP01';
    fexportoptions.defsidetex := 'BRKGRY01';
    fexportoptions.defceilingtex := 'F_SKY001';
  end;

  fexportoptions.elevationmethod := ELEVATIONMETHOD_SLOPES;
  if M_CheckOption('-noslope') then
    fexportoptions.elevationmethod := ELEVATIONMETHOD_MINECRAFT;
  if M_CheckOption('-nodeformation') then
    fexportoptions.flags := fexportoptions.flags and not ETF_CALCDXDY;
  if M_CheckOption('-notexture') then
    fexportoptions.flags := fexportoptions.flags and not ETF_EXPORTFLAT;
  if M_CheckOption('-noplayer') then
    fexportoptions.flags := fexportoptions.flags and not ETF_ADDPLAYERSTART;

  fexportoptions.levelname := UpperCase(M_CheckParam('-l', fexportoptions.levelname));
  fexportoptions.defsidetex := UpperCase(M_CheckParam('-stexture', fexportoptions.defsidetex));
  fexportoptions.defceilingtex := UpperCase(M_CheckParam('-ctexture', fexportoptions.defceilingtex));

  fexportoptions.defceilingheight := 512;

  write('Opening file ' + finp + '...');
  t := TTerrain.Create;
  try
    t.LoadFromFile(finp);
    writeln('Done');

    write('Creating WAD file ' + fout + '...');
    BackupFile(fout);
    fs := TFileStream.Create(fout, fmCreate);
    try
      case fexportoptions.engine of
        ENGINE_UDMF:
          ExportTerrainToUDMFFile(
            t,
            fs,
            @fexportoptions,
            @stats
          );
        ENGINE_RAD:
          ExportTerrainToWADFile(
            t,
            fs,
            @fexportoptions,
            @stats
          );
        ENGINE_VAVOOM:
          ExportTerrainToHexenFile(
            t,
            fs,
            @fexportoptions,
            @stats
          );
      end;
    finally
      fs.Free;
    end;
    writeln('Done');
    writeln;
    writeln('# of things = ', stats.numthings);
    writeln('# of linedefs = ', stats.numlinedefs);
    writeln('# of sidedefs = ', stats.numsidedefs);
    writeln('# of vertexes = ', stats.numvertexes);
    writeln('# of sectors = ', stats.numsectors);
  finally
    t.Free;
  end;


  ExitProgram(0);
end.
