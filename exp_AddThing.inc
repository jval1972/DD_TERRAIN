  function AddThing(const x, y: integer; const angle: smallint;{$IFDEF HEXEN_FORMAT}const height: integer;{$ENDIF} const mtype: word; options: smallint): integer;
  var
    j: integer;
    mthing: {$IFDEF HEXEN_FORMAT}Phmapthing_t{$ELSE}Pmapthing_t{$ENDIF};
  begin
    {$IFDEF HEXEN_FORMAT}
    options := options or (MTF_FIGHTER or MTF_CLERIC or MTF_MAGE or MTF_GSINGLE or MTF_GCOOP or MTF_GDEATHMATCH);
    {$ENDIF}
    for j := 0 to numdoomthings - 1 do
      if (doomthings[j].x = x) and (doomthings[j].y = y) and (doomthings[j].angle = angle) and
         (doomthings[j]._type = mtype) and (doomthings[j].options = options) then
      begin
        result := j;
        exit;
      end;

    ReallocMem(doomthings, (numdoomthings + 1) * SizeOf({$IFDEF HEXEN_FORMAT}hmapthing_t{$ELSE}mapthing_t{$ENDIF}));
    mthing := @doomthings[numdoomthings];

    mthing.x := x;
    mthing.y := y;

    mthing.angle := angle;
    mthing._type := mtype;
    mthing.options := options;
    {$IFDEF HEXEN_FORMAT}
    mthing.tid := 0;
    mthing.height := height;
    mthing.special := 0;
    mthing.arg1 := 0;
    mthing.arg2 := 0;
    mthing.arg3 := 0;
    mthing.arg4 := 0;
    mthing.arg5 := 0;
    {$ENDIF}

    result := numdoomthings;
    inc(numdoomthings);
  end;
