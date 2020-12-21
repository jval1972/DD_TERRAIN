  procedure MergeLines;
  var
    j, k: integer;
    v1, v2, v3, v4: integer;
    vertexhit: PIntegerArray;
    merges: integer;
    xZero, yZero: boolean;
    x1, y1: integer;
    x2, y2: integer;
    dx1, dy1: integer;
    v0: integer;
  begin
    GetMem(vertexhit, numdoomvertexes * SizeOf(integer));

    ZeroMemory(vertexhit, numdoomvertexes * SizeOf(integer));
    for j := 0 to numdoomlinedefs - 1 do
    begin
      inc(vertexhit[doomlinedefs[j].v1]);
      inc(vertexhit[doomlinedefs[j].v2]);
    end;

    v0 := AddVertex(-10000, -10000);

    repeat
      merges := 0;
      for j := 0 to numdoomlinedefs - 1 do
      begin
        v1 := doomlinedefs[j].v1;
        v2 := doomlinedefs[j].v2;
        if (v1 <> v2) and (vertexhit[doomlinedefs[j].v2] = 2) then
        begin
          x1 := doomvertexes[v1].x;
          y1 := doomvertexes[v1].y;
          dx1 := x1 - doomvertexes[v2].x;
          dy1 := y1 - doomvertexes[v2].y;
          xZero := dx1 = 0;
          yZero := dy1 = 0;
          x2 := doomvertexes[v2].x;
          y2 := doomvertexes[v2].y;
          for k := 0 to numdoomlinedefs - 1 do
            if k <> j then
            begin
              v3 := doomlinedefs[k].v1;
              v4 := doomlinedefs[k].v2;
              if v3 = v2 then
                if (xZero and (x1 = doomvertexes[v4].x)) or
                   (yZero and (y1 = doomvertexes[v4].y)) or
                   ((dx1 = x2 - doomvertexes[v4].x) and (dy1 = y2 - doomvertexes[v4].y)) then
                begin
                  doomlinedefs[j].v2 := v4;
                  doomlinedefs[k].v1 := v0;
                  doomlinedefs[k].v2 := v0;
                  inc(merges);
                end;
            end;
        end;
      end;
    until merges = 0;

    FreeMem(vertexhit, numdoomvertexes * SizeOf(integer));
  end;
