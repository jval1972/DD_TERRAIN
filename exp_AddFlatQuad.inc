  procedure AddFlatQuad(const iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4: integer);
  var
    v1, v2, v3, v4: integer;
    p1, p2, p3, p4: point3d_t;
    l1, l2, l3, l4: integer;
    sec: integer;
  begin
    p1 := GetHeightmapCoords3D(iX1, iY1);
    p2 := GetHeightmapCoords3D(iX2, iY2);
    p3 := GetHeightmapCoords3D(iX3, iY3);
    p4 := GetHeightmapCoords3D(iX4, iY4);
    sec := AddSector((p1.Z + p2.Z + p3.Z + p4.Z) div 4, options.defceilingheight, False);

    v1 := AddVertex(p1.X, -p1.Y);
    v2 := AddVertex(p2.X, -p2.Y);
    v3 := AddVertex(p3.X, -p3.Y);
    v4 := AddVertex(p4.X, -p4.Y);

    l1 := AddLinedef(v1, v2);
    if doomlinedefs[l1].sidenum[0] < 0 then
      doomlinedefs[l1].sidenum[0] := AddSidedef(sec)
    else
    begin
      doomlinedefs[l1].sidenum[1] := AddSidedef(sec);
      doomlinedefs[l1].flags := doomlinedefs[l1].flags and not ML_BLOCKING;
      doomlinedefs[l1].flags := doomlinedefs[l1].flags or ML_TWOSIDED;
    end;

    l2 := AddLinedef(v2, v3);
    if doomlinedefs[l2].sidenum[0] < 0 then
      doomlinedefs[l2].sidenum[0] := AddSidedef(sec)
    else
    begin
      doomlinedefs[l2].sidenum[1] := AddSidedef(sec);
      doomlinedefs[l2].flags := doomlinedefs[l2].flags and not ML_BLOCKING;
      doomlinedefs[l2].flags := doomlinedefs[l2].flags or ML_TWOSIDED;
    end;

    l3 := AddLinedef(v3, v4);
    if doomlinedefs[l3].sidenum[0] < 0 then
      doomlinedefs[l3].sidenum[0] := AddSidedef(sec)
    else
    begin
      doomlinedefs[l3].sidenum[1] := AddSidedef(sec);
      doomlinedefs[l3].flags := doomlinedefs[l3].flags and not ML_BLOCKING;
      doomlinedefs[l3].flags := doomlinedefs[l3].flags or ML_TWOSIDED;
    end;

    l4 := AddLinedef(v4, v1);
    if doomlinedefs[l4].sidenum[0] < 0 then
      doomlinedefs[l4].sidenum[0] := AddSidedef(sec)
    else
    begin
      doomlinedefs[l4].sidenum[1] := AddSidedef(sec);
      doomlinedefs[l4].flags := doomlinedefs[l4].flags and not ML_BLOCKING;
      doomlinedefs[l4].flags := doomlinedefs[l4].flags or ML_TWOSIDED;
    end;
  end;
