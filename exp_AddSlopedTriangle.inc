  procedure AddSlopedTriangle(const iX1, iY1, iX2, iY2, iX3, iY3: integer);
  var
    v1, v2, v3: integer;
    p1, p2, p3: point3d_t;
    l1, l2, l3: integer;
    sec: integer;
    {$IFDEF HEXEN_FORMAT}
    procedure doaddhexenthing(const p: point3d_p);
    begin
      if options.flags and ETF_HEXENHEIGHT <> 0 then
        AddThing(p.X, -p.Y, 0, p.Z, options.raiseid, MTF_EASY or MTF_NORMAL or MTF_HARD)
      else if p.Z < 0 then
        AddThing(p.X, -p.Y, -p.Z, 0, options.lowerid, MTF_EASY or MTF_NORMAL or MTF_HARD)
      else
        AddThing(p.X, -p.Y, p.Z, 0, options.raiseid, MTF_EASY or MTF_NORMAL or MTF_HARD);
    end;
    {$ENDIF}
  begin
    p1 := GetHeightmapCoords3D(iX1, iY1);
    p2 := GetHeightmapCoords3D(iX2, iY2);
    p3 := GetHeightmapCoords3D(iX3, iY3);
    sec := AddSector(0, options.defceilingheight, True);

    v1 := AddVertex(p1.X, -p1.Y);
    v2 := AddVertex(p2.X, -p2.Y);
    v3 := AddVertex(p3.X, -p3.Y);

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

    l3 := AddLinedef(v3, v1);
    if doomlinedefs[l3].sidenum[0] < 0 then
      doomlinedefs[l3].sidenum[0] := AddSidedef(sec)
    else
    begin
      doomlinedefs[l3].sidenum[1] := AddSidedef(sec);
      doomlinedefs[l3].flags := doomlinedefs[l3].flags and not ML_BLOCKING;
      doomlinedefs[l3].flags := doomlinedefs[l3].flags or ML_TWOSIDED;
    end;

    {$IFDEF UDMF_FORMAT}
    doomvertexes[v1].z := p1.Z;
    doomvertexes[v2].z := p2.Z;
    doomvertexes[v3].z := p3.Z;
    {$ELSE}
    {$IFDEF HEXEN_FORMAT}
    doaddhexenthing(@p1);
    doaddhexenthing(@p2);
    doaddhexenthing(@p3);
    {$ELSE}
    if p1.Z < 0 then
      AddThing(p1.X, -p1.Y, -p1.Z, options.lowerid, MTF_EASY or MTF_NORMAL or MTF_HARD)
    else
      AddThing(p1.X, -p1.Y, p1.Z, options.raiseid, MTF_EASY or MTF_NORMAL or MTF_HARD);
    if p2.Z < 0 then
      AddThing(p2.X, -p2.Y, -p2.Z, options.lowerid, MTF_EASY or MTF_NORMAL or MTF_HARD)
    else
      AddThing(p2.X, -p2.Y, p2.Z, options.raiseid, MTF_EASY or MTF_NORMAL or MTF_HARD);
    if p3.Z < 0 then
      AddThing(p3.X, -p3.Y, -p3.Z, options.lowerid, MTF_EASY or MTF_NORMAL or MTF_HARD)
    else
      AddThing(p3.X, -p3.Y, p3.Z, options.raiseid, MTF_EASY or MTF_NORMAL or MTF_HARD);
    {$ENDIF}
    {$ENDIF}
  end;
