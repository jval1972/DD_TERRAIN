  procedure RemoveZeroLengthLines;
  var
    j: integer;
    pline: {$IFDEF HEXEN_FORMAT}Phmaplinedef_t{$ELSE}Pmaplinedef_t{$ENDIF};
    v1, v2: integer;
  begin
    for j := numdoomlinedefs - 1 downto 0 do
    begin
      pline := @doomlinedefs[j];
      v1 := pline.v1;
      v2 := pline.v2;
      if v1 = v2 then
      begin
        doomlinedefs[j] := doomlinedefs[numdoomlinedefs - 1];
        ReallocMem(doomlinedefs, (numdoomlinedefs  - 1) * SizeOf({$IFDEF HEXEN_FORMAT}hmaplinedef_t{$ELSE}maplinedef_t{$ENDIF}));
        dec(numdoomlinedefs);
      end;
    end;
    
  end;
