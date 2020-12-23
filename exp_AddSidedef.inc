  function AddSidedef(const sector: smallint; const force_new: boolean = true): integer;
  var
    pside: Pmapsidedef_t;
  begin
    ReallocMem(doomsidedefs, (numdoomsidedefs  + 1) * SizeOf(mapsidedef_t));
    pside := @doomsidedefs[numdoomsidedefs];
    pside.textureoffset := 0;
    pside.rowoffset := 0;
    pside.toptexture := stringtochar8('-');
    pside.bottomtexture := stringtochar8('-');
    pside.midtexture := stringtochar8('-');
    pside.sector := sector;
    Result := numdoomsidedefs;
    inc(numdoomsidedefs);
  end;
