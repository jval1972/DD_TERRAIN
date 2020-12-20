  function AddSidedef(const sector: smallint; const force_new: boolean = true): integer;
  var
    j: integer;
    pside: Pmapsidedef_t;
  begin
    if not force_new or (numdoomsidedefs > 32000) then // JVAL: 20200309 - If we pack sidedefs of radix level, the triggers may not work :(
      for j := 0 to numdoomsidedefs - 1 do
        if doomsidedefs[j].sector = sector then
        begin
          result := j;
          exit;
        end;

    ReallocMem(doomsidedefs, (numdoomsidedefs  + 1) * SizeOf(mapsidedef_t));
    pside := @doomsidedefs[numdoomsidedefs];
    pside.textureoffset := 0;
    pside.rowoffset := 0;
    pside.toptexture := stringtochar8('-');
    pside.bottomtexture := stringtochar8('-');
    pside.midtexture := stringtochar8('-');
    pside.sector := sector;
    result := numdoomsidedefs;
    inc(numdoomsidedefs);
  end;
