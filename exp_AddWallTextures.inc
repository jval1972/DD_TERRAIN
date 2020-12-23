  procedure AddWallTextures(start: integer = 0; stop: integer = -1);
  var
    ii: integer;
    notex: char8_t;
  begin
    if stop = -1 then
      stop := numdoomlinedefs - 1;
    notex := stringtochar8('-');
    // Add wall textures
    for ii := start to stop do
    begin
      if doomlinedefs[ii].sidenum[1] < 0 then
      begin
        doomsidedefs[doomlinedefs[ii].sidenum[0]].bottomtexture := notex;
        doomsidedefs[doomlinedefs[ii].sidenum[0]].toptexture := notex;
        doomsidedefs[doomlinedefs[ii].sidenum[0]].midtexture := sidetex
      end
      else
      begin
        doomsidedefs[doomlinedefs[ii].sidenum[0]].bottomtexture := sidetex;
        doomsidedefs[doomlinedefs[ii].sidenum[0]].toptexture := notex;
        doomsidedefs[doomlinedefs[ii].sidenum[0]].midtexture := notex;
        doomsidedefs[doomlinedefs[ii].sidenum[1]].bottomtexture := sidetex;
        doomsidedefs[doomlinedefs[ii].sidenum[1]].toptexture := notex;
        doomsidedefs[doomlinedefs[ii].sidenum[1]].midtexture := notex;
      end;
    end;
  end;
