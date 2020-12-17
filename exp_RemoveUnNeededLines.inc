  procedure RemoveUnNeededLines;
  var
    j, k: integer;
    pline: {$IFDEF HEXEN_FORMAT}Phmaplinedef_t{$ELSE}Pmaplinedef_t{$ENDIF};
    side0, side1: integer;
    sidedefhit: PIntegerArray;
    vertexhit: PIntegerArray;
  begin
    for j := numdoomlinedefs - 2 downto 0 do
    begin
      pline := @doomlinedefs[j];
      side0 := pline.sidenum[0];
      side1 := pline.sidenum[1];
      if (side0 >= 0) and (side1 >= 0) then
        if doomsidedefs[side0].sector = doomsidedefs[side1].sector then
        begin
          doomlinedefs[j] := doomlinedefs[numdoomlinedefs - 1];
          ReallocMem(doomlinedefs, (numdoomlinedefs  - 1) * SizeOf({$IFDEF HEXEN_FORMAT}hmaplinedef_t{$ELSE}maplinedef_t{$ENDIF}));
          dec(numdoomlinedefs);
        end;
    end;
    GetMem(sidedefhit, numdoomsidedefs * SizeOf(Integer));
    ZeroMemory(sidedefhit, numdoomsidedefs * SizeOf(Integer));
    // Mark unused sidedefs
    for j := 0 to numdoomlinedefs - 1 do
    begin
      pline := @doomlinedefs[j];
      side0 := pline.sidenum[0];
      if side0 >= 0 then
        inc(sidedefhit[side0]);
      side1 := pline.sidenum[1];
      if side1 >= 0 then
        inc(sidedefhit[side1]);
    end;
    // Remove unused sidedefs
    for k := numdoomsidedefs - 1 downto 0 do
    begin
      if sidedefhit[k] = 0 then
      begin
        if k < numdoomsidedefs - 1 then
        begin
          for j := 0 to numdoomlinedefs - 1 do
          begin
            pline := @doomlinedefs[j];
            if pline.sidenum[0] = numdoomsidedefs - 1 then
            begin
              pline.sidenum[0] := k;
              inc(sidedefhit[k]); // mark as used
            end;
            if pline.sidenum[1] = numdoomsidedefs - 1 then
            begin
              pline.sidenum[1] := k;
              inc(sidedefhit[k]); // mark as used
            end;
          end;
        end;
        dec(numdoomsidedefs);
        doomsidedefs[k] := doomsidedefs[numdoomsidedefs];
      end;
    end;
    ReallocMem(doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
    FreeMem(sidedefhit, numdoomsidedefs * SizeOf(Integer));
    // Mark unused vertexes
    GetMem(vertexhit, numdoomvertexes * SizeOf(Integer));
    ZeroMemory(vertexhit, numdoomvertexes * SizeOf(Integer));
    for j := 0 to numdoomlinedefs - 1 do
    begin
      inc(vertexhit[doomlinedefs[j].v1]);
      inc(vertexhit[doomlinedefs[j].v2]);
    end;
    // Remove unused vertexes
    for k := numdoomvertexes - 1 downto 0 do
    begin
      if vertexhit[k] = 0 then
      begin
        if k < numdoomvertexes - 1 then
        begin
          for j := 0 to numdoomlinedefs - 1 do
          begin
            if doomlinedefs[j].v1 = numdoomvertexes - 1 then
            begin
              doomlinedefs[j].v1 := k;
              inc(vertexhit[k]); // mark as used
            end;
            if doomlinedefs[j].v2 = numdoomvertexes - 1 then
            begin
              doomlinedefs[j].v2 := k;
              inc(vertexhit[k]); // mark as used
            end;
          end;
        end;
        dec(numdoomvertexes);
        doomvertexes[k] := doomvertexes[numdoomvertexes];
      end;
    end;
    ReallocMem(doomvertexes, numdoomvertexes * SizeOf({$IFDEF UDMF_FORMAT}zmapvertex_t{$ELSE}mapvertex_t{$ENDIF}));
    FreeMem(vertexhit, numdoomvertexes * SizeOf(Integer));
  end;
