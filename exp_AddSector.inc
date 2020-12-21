  function AddSector(const hfloor, hceiling: integer; const sloped: boolean): integer;
  var
    j: integer;
    dsec: Pmapsector_t;
  begin
    if not sloped then
      if (options.flags and ETF_MERGEFLATSECTORS <> 0) or (options.elevationmethod = ELEVATIONMETHOD_TRACECONTOUR) then
      begin
        for j := 0 to numdoomsectors - 1 do
          if not slopedsectors[j] then
          begin
            dsec := @doomsectors[j];
            if (dsec.floorheight = hfloor) and (dsec.ceilingheight = hceiling) then
            begin
              Result := j;
              Exit;
            end;
          end;
      end;

    ReallocMem(doomsectors, (numdoomsectors  + 1) * SizeOf(mapsector_t));
    ReallocMem(slopedsectors, (numdoomsectors  + 1) * SizeOf(boolean));
    dsec := @doomsectors[numdoomsectors];
    dsec.floorheight := hfloor;
    dsec.ceilingheight := hceiling;
    dsec.floorpic := stringtochar8(options.levelname + 'TER');
    dsec.ceilingpic := stringtochar8(options.defceilingtex);
    dsec.lightlevel := options.deflightlevel;
    dsec.special := 0;
    dsec.tag := 0;
    slopedsectors[numdoomsectors] := sloped;

    result := numdoomsectors;
    inc(numdoomsectors);
  end;

