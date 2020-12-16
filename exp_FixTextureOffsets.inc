  procedure FixTextureOffsets;
  var
    j: integer;
    v1, v2: integer;
  begin
    for j := 0 to numdoomlinedefs - 1 do
      if doomlinedefs[j].sidenum[1] = -1 then
      begin
        v1 := doomlinedefs[j].v1;
        v2 := doomlinedefs[j].v2;
        if doomvertexes[v1].y = doomvertexes[v2].y then
          doomsidedefs[doomlinedefs[j].sidenum[0]].textureoffset := doomvertexes[v1].x
        else if doomvertexes[v1].x = doomvertexes[v2].x then
          doomsidedefs[doomlinedefs[j].sidenum[0]].textureoffset := doomvertexes[v1].y;
      end;
  end;
