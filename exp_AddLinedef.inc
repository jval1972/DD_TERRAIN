  function AddLinedef(const v1, v2: integer): integer;
  var
    j: integer;
    pline: Pmaplinedef_t;
  begin
    for j := 0 to numdoomlinedefs - 1 do
    begin
      pline := @doomlinedefs[j];
      if (pline.v1 = v1) and (pline.v2 = v2) then
        if pline.sidenum[1] < 0 then
        begin
          result := j;
          exit;
        end;
      if (pline.v1 = v2) and (pline.v2 = v1) then
        if pline.sidenum[1] < 0 then
        begin
          result := j;
          exit;
        end;
    end;

    ReallocMem(doomlinedefs, (numdoomlinedefs  + 1) * SizeOf(maplinedef_t));
    pline := @doomlinedefs[numdoomlinedefs];
    pline.v1 := v1;
    pline.v2 := v2;
    pline.flags := 0;
    pline.special := 0;
    pline.tag := 0;
    pline.sidenum[0] := -1;
    pline.sidenum[1] := -1;
    result := numdoomlinedefs;
    inc(numdoomlinedefs);
  end;
