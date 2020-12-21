  procedure TraceContourMap;
  var
    clines: Pcountourline_tArray;
    numclines: integer;
    ii, jj: integer;
    v1, v2, v3, v4: integer;
    ll: integer;
    frontsec, backsec: integer;
    basesec: integer;
    topN, rightN, bottomN, leftN: T2DNumberList;
    merges: integer;
    mapxmax, mapymax: integer;
    dx1, dx2, dy1, dy2: integer;
    lastline: integer;
    lastside: integer;

    function findbasesec(const s1, s2: integer; const vv: integer): integer;
    var
      k: integer;
      ln: integer;
      ss0, ss1: integer;
    begin
      ln := -1;
      for k := 0 to numdoomlinedefs - 1 do
        if (doomlinedefs[k].v1 = vv) or (doomlinedefs[k].v2 = vv) then
        begin
          ln := k;
          lastline := k;
          break;
        end;
      if (ln = -1) or (doomlinedefs[ln].sidenum[1] = -1) then
      begin
        Result := s2;
        Exit;
      end;
      ss0 := doomsidedefs[doomlinedefs[ln].sidenum[0]].sector;
      ss1 := doomsidedefs[doomlinedefs[ln].sidenum[1]].sector;
      if s2 = ss0 then
        Result := ss1
      else
        Result := ss0;
    end;

    function findnextsec(const ss: integer; const vv: integer): integer;
    var
      k: integer;
      ln: integer;
      lss0, lss1: integer;
      ss0, ss1: integer;
    begin
      ln := -1;
      for k := 0 to numdoomlinedefs - 1 do
        if (doomlinedefs[k].v1 = vv) or (doomlinedefs[k].v2 = vv) then
        begin
          ln := k;
          break;
        end;
        topn.sort1;
      if (ln = -1) or (doomlinedefs[ln].sidenum[1] = -1) then
      begin
        Result := ss;
        Exit;
      end;
        topn.sort1;
      lss0 := doomsidedefs[doomlinedefs[lastline].sidenum[0]].sector;
      lss1 := doomsidedefs[doomlinedefs[lastline].sidenum[1]].sector;
      ss0 := doomsidedefs[doomlinedefs[ln].sidenum[0]].sector;
      ss1 := doomsidedefs[doomlinedefs[ln].sidenum[1]].sector;

      if lastside = 1 then // last back sector
      begin
        if lss1 = ss0 then
          Result := ss1
        else
        begin
          Result := ss0;
          lastside := 0;
        end
      end
      else  // last front sector
      begin
        if lss0 = ss0 then
        begin
          Result := ss1;
          lastside := 1;
        end
        else
          Result := ss0;
      end;
      lastline := ln;
    end;

  begin
    ter_tracecontour(t, t.texturesize, 32, options.layerstep,  bmh, clines,numclines);

    if numclines = 0 then
    begin
      // Special case, flat terrain
      v1 := AddVertex(0, 0);
      v2 := AddVertex(t.texturesize, 0);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, False);
      doomlinedefs[ll].sidenum[1] := -1;

      v1 := AddVertex(t.texturesize, 0);
      v2 := AddVertex(t.texturesize, t.texturesize);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, False);
      doomlinedefs[ll].sidenum[1] := -1;

      v1 := AddVertex(t.texturesize, -t.texturesize);
      v2 := AddVertex(0, 1 - t.texturesize);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, False);
      doomlinedefs[ll].sidenum[1] := -1;

      v1 := AddVertex(0, -t.texturesize);
      v2 := AddVertex(0, 0);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, False);
      doomlinedefs[ll].sidenum[1] := -1;

      Exit;
    end;

    // Base sector
    basesec := AddSector(clines[0].backheight, options.defceilingheight, False);

    mapxmax := t.texturesize - 1;
    mapymax := t.texturesize - 1;
    for ii := 0 to numclines - 1 do
    begin
      if clines[ii].x1 > mapxmax then
        mapxmax := clines[ii].x1;
      if clines[ii].x2 > mapxmax then
        mapxmax := clines[ii].x2;
      if clines[ii].y1 > mapymax then
        mapymax := clines[ii].y1;
      if clines[ii].y2 > mapymax then
        mapymax := clines[ii].y2;
    end;

    for ii := 0 to numclines - 1 do
    begin
      if clines[ii].x1 >= t.texturesize - 1 then
        clines[ii].x1 := mapxmax;
      if clines[ii].x2 >= t.texturesize - 1 then
        clines[ii].x2 := mapxmax;
      if clines[ii].y1 >= t.texturesize - 1 then
        clines[ii].y1 := mapymax;
      if clines[ii].y2 >= t.texturesize - 1 then
        clines[ii].y2 := mapymax;
    end;

    topN := T2DNumberList.Create;
    topN.Add(0, -1);
    topN.Add(mapxmax, -1);

    rightN := T2DNumberList.Create;
    rightN.Add(0, -1);
    rightN.Add(-mapymax, -1);

    bottomN := T2DNumberList.Create;
    bottomN.Add(0, -1);
    bottomN.Add(mapxmax, -1);

    leftN := T2DNumberList.Create;
    leftN.Add(0, -1);
    leftN.Add(-mapymax, -1);


    for ii := 0 to numclines - 1 do
    begin
      frontsec := AddSector(clines[ii].frontheight, options.defceilingheight, False);
      backsec := AddSector(clines[ii].backheight, options.defceilingheight, False);
      if clines[ii].orientation > 0 then
      begin
        v1 := AddVertex(clines[ii].x1, -clines[ii].y1);
        v2 := AddVertex(clines[ii].x2, -clines[ii].y2);
      end
      else
      begin
        v2 := AddVertex(clines[ii].x1, -clines[ii].y1);
        v1 := AddVertex(clines[ii].x2, -clines[ii].y2);
      end;
      if v1 = v2 then
        Continue;

      // Discard lines that will be set on the perimeter trace
      if (doomvertexes[v1].x = mapxmax) and (doomvertexes[v2].x = mapxmax) then
        Continue;
      if (doomvertexes[v1].y = -mapymax) and (doomvertexes[v2].y = -mapymax) then
        Continue;
      if (doomvertexes[v1].x = 0) and (doomvertexes[v2].x = 0) then
        Continue;
      if (doomvertexes[v1].y = 0) and (doomvertexes[v2].y = 0) then
        Continue;

      ll := AddLinedef(v1, v2);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec);
      doomlinedefs[ll].sidenum[1] := AddSidedef(backsec);
      doomlinedefs[ll].flags := doomlinedefs[ll].flags or ML_TWOSIDED;

      // Check if touches top bound (y = 0)
      if doomvertexes[v1].y = 0 then
        topN.Add(doomvertexes[v1].x, backsec)
      else if doomvertexes[v2].y = 0 then
        topN.Add(doomvertexes[v2].x, frontsec);

      // Check if touches right bound (x = mapxmax)
      if doomvertexes[v1].x = mapxmax then
        rightN.Add(doomvertexes[v1].y, backsec)
      else if doomvertexes[v2].x = mapxmax then
        rightN.Add(doomvertexes[v2].y, frontsec);

      // Check if touches bottom bound (y = -mapymax)
      if doomvertexes[v1].y = -mapymax then
        bottomN.Add(doomvertexes[v1].x, backsec)
      else if doomvertexes[v2].y = -mapymax then
        bottomN.Add(doomvertexes[v2].x, frontsec);

      // Check if touches left bound (x = 0)
      if doomvertexes[v1].x = 0 then
        leftN.Add(doomvertexes[v1].y, backsec)
      else if doomvertexes[v2].x = 0 then
        leftN.Add(doomvertexes[v2].y, frontsec);
    end;

    FreeMem(clines, numclines * SizeOf(countourline_t));

    // Merge co-linear lines
    merges := 0;
    for ii := numdoomlinedefs - 1 downto 1 do
      for jj := ii - 1 downto 0 do
      begin
        v1 := doomlinedefs[ii].v1;
        v2 := doomlinedefs[ii].v2;
        v3 := doomlinedefs[jj].v1;
        v4 := doomlinedefs[jj].v2;
        if (v1 = v4) and (v2 = v3) then
        begin
          // discard both lines
          doomlinedefs[ii].v2 := v1;
          doomlinedefs[jj].v2 := v3;
        end
        else if (v1 <> v2) and (v3 <> v4) then
        begin
          if v2 = v3 then
          begin
            if (doomvertexes[v1].x = doomvertexes[v2].x) and
               (doomvertexes[v1].x = doomvertexes[v4].x) then
            begin
              doomlinedefs[ii].v2 := v4;
              doomlinedefs[jj].v2 := v3;  // discard this line
              inc(merges);
            end
            else if (doomvertexes[v1].y = doomvertexes[v2].y) and
                    (doomvertexes[v1].y = doomvertexes[v4].y) then
            begin
              doomlinedefs[ii].v2 := v4;
              doomlinedefs[jj].v2 := v3;  // discard this line
              inc(merges);
            end
            else
            begin
              dx1 := doomvertexes[v3].x - doomvertexes[v4].x;
              dy1 := doomvertexes[v3].y - doomvertexes[v4].y;
              dx2 := doomvertexes[v1].x - doomvertexes[v2].x;
              dy2 := doomvertexes[v1].y - doomvertexes[v2].y;
              if (dy1 <> 0) and (dy2 <> 0) then
                if abs(dx1 / dy1 - dx2 / dy2) <= 0.1 then
                begin
                  doomlinedefs[ii].v2 := v4;
                  doomlinedefs[jj].v2 := v3;  // discard this line
                end;
            end;
          end;
          if v1 = v4 then
          begin
            if (doomvertexes[v1].x = doomvertexes[v2].x) and
               (doomvertexes[v2].x = doomvertexes[v3].x) then
            begin
              doomlinedefs[ii].v2 := v1;  // discard this line
              doomlinedefs[jj].v2 := v2;
              inc(merges);
            end
            else if (doomvertexes[v1].y = doomvertexes[v2].y) and
                    (doomvertexes[v1].y = doomvertexes[v3].y) then
            begin
              doomlinedefs[ii].v2 := v1;  // discard this line
              doomlinedefs[jj].v2 := v2;
              inc(merges);
            end
            else
            begin
              dx1 := doomvertexes[v3].x - doomvertexes[v4].x;
              dy1 := doomvertexes[v3].y - doomvertexes[v4].y;
              dx2 := doomvertexes[v1].x - doomvertexes[v2].x;
              dy2 := doomvertexes[v1].y - doomvertexes[v2].y;
              if (dy1 <> 0) and (dy2 <> 0) then
                if abs(dx1 / dy1 - dx2 / dy2) < 0.1 then
                begin
                  doomlinedefs[ii].v2 := v1;  // discard this line
                  doomlinedefs[jj].v2 := v2;
                end;
            end;
          end;
        end;
      end;

    topN.Sort1;
    rightN.Sort1;
    bottomN.Sort1;
    leftN.Sort1;

    // Fix first sector of the perimeter
    if topN.Count > 2 then
      basesec := topN.Numbers[1].num2;

    v1 := AddVertex(topN.Numbers[0].num1, 0);
    v2 := AddVertex(topN.Numbers[1].num1, 0);
    ll := AddLinedef(v1, v2);
    lastline := ll;
    basesec := findbasesec(basesec, topN.Numbers[1].num2, v2);
    lastside := 1; // back
    doomlinedefs[ll].sidenum[0] := AddSidedef(basesec);
    doomlinedefs[ll].sidenum[1] := -1;

    // Close top of the map
    for ii := 1 to topN.Count - 2 do
    begin
      v1 := AddVertex(topN.Numbers[ii].num1, 0);
      v2 := AddVertex(topN.Numbers[ii + 1].num1, 0);
      ll := AddLinedef(v1, v2);
      basesec := findnextsec(basesec, v1);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec);
      doomlinedefs[ll].sidenum[1] := -1;
    end;

    // Close right of the map
    for ii := rightN.Count - 1 downto 1 do
    begin
      v1 := AddVertex(mapxmax, rightN.Numbers[ii].num1);
      v2 := AddVertex(mapxmax, rightN.Numbers[ii - 1].num1);
      ll := AddLinedef(v1, v2);
      basesec := findnextsec(basesec, v1);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec);
      doomlinedefs[ll].sidenum[1] := -1;
    end;
            topn.sort2;
    // Close bottom of the map
    for ii := bottomN.Count - 1 downto 1 do
    begin
      v1 := AddVertex(bottomN.Numbers[ii].num1, -mapymax);
      v2 := AddVertex(bottomN.Numbers[ii - 1].num1, -mapymax);
      ll := AddLinedef(v1, v2);
      basesec := findnextsec(basesec, v1);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec);
      doomlinedefs[ll].sidenum[1] := -1;
    end;

    // Close left of the map
    for ii := 0 to leftN.Count - 2 do
    begin
      v1 := AddVertex(0, leftN.Numbers[ii].num1);
      v2 := AddVertex(0, leftN.Numbers[ii + 1].num1);
      ll := AddLinedef(v1, v2);
      basesec := findnextsec(basesec, v1);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec);
      doomlinedefs[ll].sidenum[1] := -1;
    end;

    topN.Free;
    rightN.Free;
    bottomN.Free;
    leftN.Free;
  end;
