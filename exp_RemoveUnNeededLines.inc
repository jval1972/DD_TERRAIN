  procedure RemoveUnNeededLines;
  var
    j: integer;
    pline: Pmaplinedef_t;
    side0, side1: integer;
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
          ReallocMem(doomlinedefs, (numdoomlinedefs  - 1) * SizeOf(maplinedef_t));
          dec(numdoomlinedefs);
        end;
    end;
  end;
