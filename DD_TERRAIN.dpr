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
//  Project file
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

program DD_TERRAIN;

uses
  FastMM4 in 'FastMM4.pas',
  FastMM4Messages in 'FastMM4Messages.pas',
  Forms,
  main in 'main.pas' {Form1},
  dglOpenGL in 'dglOpenGL.pas',
  ter_gl in 'ter_gl.pas',
  ter_undo in 'ter_undo.pas',
  ter_binary in 'ter_binary.pas',
  ter_filemenuhistory in 'ter_filemenuhistory.pas',
  ter_utils in 'ter_utils.pas',
  pngextra in 'pngextra.pas',
  pnglang in 'pnglang.pas',
  xTGA in 'xTGA.pas',
  zBitmap in 'zBitmap.pas',
  zlibpas in 'zlibpas.pas',
  ter_slider in 'ter_slider.pas',
  frm_newterrain in 'frm_newterrain.pas' {NewForm},
  ter_class in 'ter_class.pas',
  ter_wadreader in 'ter_wadreader.pas',
  pngimage1 in 'pngimage1.pas',
  ter_defs in 'ter_defs.pas',
  frm_editheightmapitem in 'frm_editheightmapitem.pas' {EditHeightmapItemForm},
  frm_scaleheightmap in 'frm_scaleheightmap.pas' {ScaleHeightmapItemForm},
  ter_wadexport in 'ter_wadexport.pas',
  ter_wadwriter in 'ter_wadwriter.pas',
  ter_wad in 'ter_wad.pas',
  ter_doomdata in 'ter_doomdata.pas',
  ter_palettes in 'ter_palettes.pas',
  ter_pk3 in 'ter_pk3.pas',
  frm_loadimagehelper in 'frm_loadimagehelper.pas' {LoadImageHelperForm},
  ter_colorpickerbutton in 'ter_colorpickerbutton.pas',
  ter_colorpalettebmz in 'ter_colorpalettebmz.pas',
  ter_cursors in 'ter_cursors.pas',
  frm_exportwadmap in 'frm_exportwadmap.pas' {ExportWADMapForm},
  ter_quantize in 'ter_quantize.pas',
  ter_contour in 'ter_contour.pas',
  xTIFF in 'xTIFF.pas',
  LibDelphi in 'LibDelphi.pas',
  LibJpegDelphi in 'LibJpegDelphi.pas',
  LibTiffDelphi in 'LibTiffDelphi.pas',
  ter_tmp in 'ter_tmp.pas',
  ter_voxels in 'ter_voxels.pas',
  ter_voxelexport in 'ter_voxelexport.pas',
  frm_exportvoxel in 'frm_exportvoxel.pas' {ExportVoxelForm},
  ter_doomutils in 'ter_doomutils.pas',
  frm_zeroheightmapvalues in 'frm_zeroheightmapvalues.pas' {ZeroHeightmapValuesForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Terrain Generator';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

