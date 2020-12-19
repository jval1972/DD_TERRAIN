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
//  Trace contour using the meandering triangles algorithm
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_contour;

interface

uses
  ter_class;

type
  countourline_t = record
    x1, y1: integer;
    x2, y2: integer;
    frontside: integer;
    frontheight: integer;
    backside: integer;
    backheight: integer;
    orientation: integer;
  end;
  countourline_p = ^countourline_t;
  countourline_tArray = array[0..$FFF] of countourline_t;
  Pcountourline_tArray = ^countourline_tArray;

procedure ter_tracecontour(
  const t: TTerrain;  // Terrain
  const imgsize: integer; // Size of hi-res heightmap to use
  const tristep: integer; // Size of each triangle to use
  const elevstep: integer;  // Elevation step
  out lines: Pcountourline_tArray;  // Output lines
  out numlines: integer             // Num output lines
);

implementation

type
  tri3d_t = record
    v1, v2, v3: point3d_t;
  end;
  tri3d_p = ^tri3d_t;
  tri3d_tArray = array[0..$FFF] of tri3d_t;
  Ptri3d_tArray = ^tri3d_tArray;

type
  slicetri3d_t = record
    v1, v2, v3: point3d_t;
    numpoints: integer;
  end;
  slicetri3d_p = ^slicetri3d_t;

  edge_t = record
    e1, e2: point3d_t;
  end;
  edge_p = ^edge_t;

procedure ter_tracecontour(
  const t: TTerrain;  // Terrain
  const imgsize: integer; // Size of hi-res heightmap to use
  const tristep: integer; // Size of each triangle to use
  const elevstep: integer;  // Elevation step
  out lines: Pcountourline_tArray;  // Output lines
  out numlines: integer             // Num output lines
);
var
  bmh: bitmapheightmap_p;
  numtrisX, numtrisY: integer;
  numtris: integer;
  triangles: Ptri3d_tArray;
  layer, elevation: integer;
  x, y: integer;

  procedure AddTriangle(const x1, y1, x2, y2, x3, y3: integer);
  begin
    triangles[numtris].v1.X := x1;
    triangles[numtris].v1.Y := y1;
    triangles[numtris].v1.Z := bmh[x1, y1];
    triangles[numtris].v2.X := x2;
    triangles[numtris].v2.Y := y2;
    triangles[numtris].v2.Z := bmh[x2, y2];
    triangles[numtris].v3.X := x3;
    triangles[numtris].v3.Y := y3;
    triangles[numtris].v3.Z := bmh[x3, y3];
    inc(numtris);
  end;

  function AddToSlideTri(const st: slicetri3d_p; const p: point3d_p): boolean;
  begin
    if st.numpoints = 0 then
      st.v1 := p^
    else if st.numpoints = 1 then
      st.v2 := p^
    else if st.numpoints = 2 then
      st.v3 := p^
    else
    begin
      Result := False;
      Exit;
    end;
    Inc(st.numpoints);
    Result := True;
  end;

  // Finds orientation of 3 Points
  // Returns:
  // 0 --> Colinear
  // positive --> Clockwise
  // negative --> Counterclockwise
  function TriOrientation(const x1, y1, x2, y2, x3, y3: integer): integer;
  begin
    Result := (y2 - y1) * (x3 - x2) -
              (x2 - x1) * (y3 - y2);
  end;

  function ProcessLayer: integer;
  var
    above, below: slicetri3d_t;
    minor, major: slicetri3d_p;
    i, j: integer;
    crossed_edges: array[0..1] of edge_t;
    contour_points: array[0..1] of point3d_t;
    f: double;
  begin
    Result := 0;
    for i := 0 to numtris - 1 do
    begin
      above.numpoints := 0;
      below.numpoints := 0;
      if triangles[i].v1.Z < elevation then
        AddToSlideTri(@below, @triangles[i].v1)
      else
        AddToSlideTri(@above, @triangles[i].v1);
      if triangles[i].v2.Z < elevation then
        AddToSlideTri(@below, @triangles[i].v2)
      else
        AddToSlideTri(@above, @triangles[i].v2);
      if triangles[i].v3.Z < elevation then
        AddToSlideTri(@below, @triangles[i].v3)
      else
        AddToSlideTri(@above, @triangles[i].v3);
      if (below.numpoints <> 0) and (above.numpoints <> 0) then
      begin
        if above.numpoints  < below.numpoints then
        begin
          minor := @above;
          major := @below;
        end
        else
        begin
          minor := @below;
          major := @above;
        end;
        crossed_edges[0].e1 := minor.v1;
        crossed_edges[0].e2 := major.v1;
        crossed_edges[1].e1 := minor.v1;
        crossed_edges[1].e2 := major.v2;

        for j := 0 to 1 do
        begin
          f := (elevation - crossed_edges[j].e2.Z) / (crossed_edges[j].e1.Z - crossed_edges[j].e2.Z);
          contour_points[j].X := Round(f * crossed_edges[j].e1.X + (1 - f) * crossed_edges[j].e2.X);
          contour_points[j].Y := Round(f * crossed_edges[j].e1.Y + (1 - f) * crossed_edges[j].e2.Y);
        end;

        if (contour_points[0].X <> contour_points[1].X) or
           (contour_points[0].Y <> contour_points[1].Y) then
        begin
          ReallocMem(lines, (numlines + 1) * SizeOf(countourline_t));
          lines[numlines].x1 := contour_points[0].X;
          lines[numlines].y1 := contour_points[0].Y;
          lines[numlines].x2 := contour_points[1].X;
          lines[numlines].y2 := contour_points[1].Y;
          lines[numlines].frontheight := elevation;
          lines[numlines].frontside := layer;
          lines[numlines].backheight := elevation - elevstep;
          lines[numlines].backside := layer - 1;
          // This will help the WAD generator
          lines[numlines].orientation :=
                TriOrientation(
                  below.v1.X, below.v1.Y,
                  contour_points[0].X, contour_points[0].Y,
                  contour_points[1].X, contour_points[1].Y
                );
          inc(numlines);
          inc(Result);
        end;
      end;
    end;
  end;

begin
  lines := nil;
  numlines := 0;

  // Allocate hi-res heightmap buffer
  GetMem(bmh, SizeOf(bitmapheightmap_t));

  // Generate hi-res heightmap buffer
  t.GenerateBitmapHeightmap(bmh, imgsize);

  // Calculate triangles
  numtrisX := imgsize div tristep;
  numtrisY := numtrisX;
  numtris := 0; // counter

  GetMem(triangles, numtrisX * numtrisY * 2 * SizeOf(tri3d_t));

  // Create triangles
  for x := 0 to numtrisX - 1 do
    for y := 0 to numtrisY - 1 do
    begin
      AddTriangle(x * tristep, y * tristep, (x + 1) * tristep, y * tristep, x * tristep, (y + 1) * tristep);
      AddTriangle((x + 1) * tristep, y * tristep, (x + 1) * tristep, (y + 1) * tristep, x * tristep, (y + 1) * tristep);
    end;

  layer := 0;
  elevation := -HEIGHTMAPRANGE - 1;
  while elevation < HEIGHTMAPRANGE do
  begin
    if ProcessLayer > 0 then
      inc(layer);
    inc(elevation, elevstep);
  end;

  FreeMem(triangles, numtrisX * numtrisY * 2 * SizeOf(tri3d_t));
  FreeMem(bmh, SizeOf(bitmapheightmap_t));
end;

end.

