  procedure FixBlockingLines;
  var
    ii: integer;
  begin
    for ii := 0 to numdoomlinedefs - 1 do
      if doomlinedefs[ii].sidenum[1] = -1 then
      begin
        doomlinedefs[ii].flags := doomlinedefs[ii].flags or ML_BLOCKING;
        doomlinedefs[ii].flags := doomlinedefs[ii].flags and not ML_TWOSIDED;
      end
      else
      begin
        doomlinedefs[ii].flags := doomlinedefs[ii].flags and not ML_BLOCKING;
        doomlinedefs[ii].flags := doomlinedefs[ii].flags or ML_TWOSIDED;
      end;
  end;
