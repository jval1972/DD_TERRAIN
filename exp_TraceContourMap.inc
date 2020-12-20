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
  begin
    ter_tracecontour(t, t.texturesize, 32, 32, clines, numclines);

    if numclines = 0 then
    begin
      // Special case, flat terrain
      v1 := AddVertex(0, 0);
      v2 := AddVertex(t.texturesize - 1, 0);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, false);
      doomlinedefs[ll].sidenum[1] := -1;

      v1 := AddVertex(t.texturesize - 1, 0);
      v2 := AddVertex(t.texturesize - 1, t.texturesize - 1);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, false);
      doomlinedefs[ll].sidenum[1] := -1;

      v1 := AddVertex(t.texturesize - 1, 1 - t.texturesize);
      v2 := AddVertex(0, 1 - t.texturesize);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, false);
      doomlinedefs[ll].sidenum[1] := -1;

      v1 := AddVertex(0, 1 - t.texturesize);
      v2 := AddVertex(0, 0);
      ll := AddLinedef(v1, v2);
      frontsec := AddSector(0, options.defceilingheight, False);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec, false);
      doomlinedefs[ll].sidenum[1] := -1;

      Exit;
    end;

    topN := T2DNumberList.Create;
    topN.Add(0, -1);
    topN.Add(t.texturesize - 1, -1);

    rightN := T2DNumberList.Create;
    rightN.Add(0, -1);
    rightN.Add(1 - t.texturesize, -1);

    bottomN := T2DNumberList.Create;
    bottomN.Add(0, -1);
    bottomN.Add(t.texturesize - 1, -1);

    leftN := T2DNumberList.Create;
    leftN.Add(0, -1);
    leftN.Add(1 - t.texturesize, -1);

    // Base sector
    basesec := AddSector(clines[0].backheight, options.defceilingheight, False);

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
      ll := AddLinedef(v1, v2);
      doomlinedefs[ll].sidenum[0] := AddSidedef(frontsec);
      doomlinedefs[ll].sidenum[1] := AddSidedef(backsec);
      doomlinedefs[ll].flags := doomlinedefs[ll].flags or ML_TWOSIDED;

      // Check if touches top bound (y = 0)
      if doomvertexes[v1].y = 0 then
        topN.Add(doomvertexes[v1].x, backsec)
      else if doomvertexes[v2].y = 0 then
        topN.Add(doomvertexes[v2].x, frontsec);

      // Check if touches right bound (x = t.texturesize - 1)
      if doomvertexes[v1].x = t.texturesize - 1 then
        rightN.Add(doomvertexes[v1].y, backsec)
      else if doomvertexes[v2].x = t.texturesize - 1 then
        rightN.Add(doomvertexes[v2].y, frontsec);

      // Check if touches bottom bound (y = 1 - texturesize)
      if doomvertexes[v1].y = 1 - t.texturesize then
        bottomN.Add(doomvertexes[v1].x, backsec)
      else if doomvertexes[v2].y = 1 - t.texturesize then
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
        if (v1 <> v2) and (v3 <> v4) then
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
      basesec := topN.Numbers[2].num2;

    // Close top of the map
    for ii := 0 to topN.Count - 2 do
    begin
      v1 := AddVertex(topN.Numbers[ii].num1, 0);
      v2 := AddVertex(topN.Numbers[ii + 1].num1, 0);
      ll := AddLinedef(v1, v2);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec, false);
      doomlinedefs[ll].sidenum[1] := -1;
      if topN.Numbers[ii + 1].num2 >= 0 then
        basesec := topN.Numbers[ii + 1].num2;
    end;

    // Close right of the map
    for ii := rightN.Count - 1 downto 1 do
    begin
      v1 := AddVertex(t.texturesize - 1, rightN.Numbers[ii].num1);
      v2 := AddVertex(t.texturesize - 1, rightN.Numbers[ii - 1].num1);
      ll := AddLinedef(v1, v2);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec, false);
      doomlinedefs[ll].sidenum[1] := -1;
      if rightN.Numbers[ii].num2 >= 0 then
        basesec := rightN.Numbers[ii].num2;
    end;

    // Close bottom of the map
    for ii := bottomN.Count - 1 downto 1 do
    begin
      v1 := AddVertex(bottomN.Numbers[ii].num1, 1 - t.texturesize);
      v2 := AddVertex(bottomN.Numbers[ii - 1].num1, 1 - t.texturesize);
      ll := AddLinedef(v1, v2);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec, false);
      doomlinedefs[ll].sidenum[1] := -1;
      if bottomN.Numbers[ii].num2 >= 0 then
        basesec := bottomN.Numbers[ii].num2;
    end;

    // Close left of the map
    for ii := 0 to leftN.Count - 2 do
    begin
      v1 := AddVertex(0, leftN.Numbers[ii].num1);
      v2 := AddVertex(0, leftN.Numbers[ii + 1].num1);
      ll := AddLinedef(v1, v2);
      doomlinedefs[ll].sidenum[0] := AddSidedef(basesec, false);
      doomlinedefs[ll].sidenum[1] := -1;
      if leftN.Numbers[ii + 1].num2 >= 0 then
        basesec := leftN.Numbers[ii + 1].num2;
    end;

    topN.Free;
    rightN.Free;
    bottomN.Free;
    leftN.Free;
  end;
