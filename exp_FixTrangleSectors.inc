  procedure FixTrangleSectors;
  var
    j: integer;
    pline: Pmaplinedef_t;
    side0, side1: integer;
    sectorlines: PIntegerArray;
  begin
    if options.elevationmethod = ELEVATIONMETHOD_SLOPES then
    begin
      GetMem(sectorlines, numdoomsectors * SizeOf(integer));
      FillChar(sectorlines^, numdoomsectors * SizeOf(integer), 0);
      for j := 0 to numdoomlinedefs - 1 do
      begin
        pline := @doomlinedefs[j];
        side0 := pline.sidenum[0];
        side1 := pline.sidenum[1];
        if side0 >= 0 then
          inc(sectorlines[doomsidedefs[side0].sector]);
        if side1 >= 0 then
          inc(sectorlines[doomsidedefs[side1].sector]);
      end;

      for j := 0 to numdoomsectors - 1 do
        if not slopedsectors[j] then
          if sectorlines[j] = 3 then
            doomsectors[j].floorheight := 0; // Height will be set by easy slope things

      FreeMem(sectorlines, numdoomsectors * SizeOf(integer));
    end;
  end;
