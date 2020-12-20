  procedure FixBlockingLines;
  var
    ii: integer;
  begin
    for ii := 0 to numdoomlinedefs - 1 do
      if doomlinedefs[ii].sidenum[1] = -1 then
        doomlinedefs[ii].flags := doomlinedefs[ii].flags or ML_BLOCKING;
  end;
