  procedure PackSidedefs;
  type
    sideshashlist_t = record
      sides: Pmapsidedef_tArray;
      ids: PIntegerArray;
      count: integer;
    end;

  const
    SIDESHASHSIZE = 256;
  var
    j, k: integer;
    newsidedefs: Pmapsidedef_tArray;
    numnewsidedefs: integer;
    hashtable: array[0..SIDESHASHSIZE] of sideshashlist_t;

    function sidesequal(const s1, s2: Pmapsidedef_t): boolean;
    begin
      Result :=
        (s1.textureoffset = s2.textureoffset) and
        (s1.rowoffset = s2.rowoffset) and
        (s1.toptexture = s2.toptexture) and
        (s1.bottomtexture = s2.bottomtexture) and
        (s1.midtexture = s2.midtexture) and
        (s1.sector = s2.sector);
    end;

    function hash(const id: integer): LongWord;
    var
      b: PByte;
      ii: integer;
      ps: Pmapsidedef_t;
    begin
      ps := @doomsidedefs[id];
      b := PByte(ps);

      Result := 5381 * 33 + b^;
      inc(b);

      for ii := 0 to SizeOf(mapsidedef_t) - 2 do
      begin
        Result := result * 33 + b^;
        inc(b);
      end;
      result := result and (SIDESHASHSIZE - 1);
    end;

    function AddSideToHash(const id: integer; const ln: integer): integer;
    var
      ii: integer;
      h: integer;
    begin
      if id = -1 then
      begin
        Result := -1;
        Exit;
      end;

      // Special case, current sector or single sided, do not merge
      if doomlinedefs[ln].flags and ML_DONTPACK <> 0 then
        h := SIDESHASHSIZE
      else
      begin
        h := hash(id);

        for ii := 0 to hashtable[h].count - 1 do
          if sidesequal(@doomsidedefs[id], @hashtable[h].sides[ii]) then
          begin
            Result := hashtable[h].ids[ii];
            Exit;
          end;
      end;

      Result := numnewsidedefs;
      ReallocMem(newsidedefs, (numnewsidedefs + 1) * SizeOf(mapsidedef_t));
      newsidedefs[numnewsidedefs] := doomsidedefs[id];

      ReallocMem(hashtable[h].sides, (hashtable[h].count + 1) * SizeOf(mapsidedef_t));
      ReallocMem(hashtable[h].ids, (hashtable[h].count + 1) * SizeOf(integer));
      hashtable[h].sides[hashtable[h].count] := doomsidedefs[id];
      hashtable[h].ids[hashtable[h].count] := numnewsidedefs;

      inc(hashtable[h].count);
      inc(numnewsidedefs);
    end;

  begin
    FixTextureOffsets;
    FixBlockingLines; // Fix blocking flag
    AddWallTextures;  // Fix all wall textures except the last line

    // Pack sidedefs
    newsidedefs := nil;
    numnewsidedefs := 0;
    for j := 0 to SIDESHASHSIZE do
    begin
      hashtable[j].sides := nil;
      hashtable[j].ids := nil;
      hashtable[j].count := 0;
    end;

    for k := 0 to numdoomlinedefs - 1 do
    begin
      doomlinedefs[k].sidenum[0] := AddSideToHash(doomlinedefs[k].sidenum[0], k);
      doomlinedefs[k].sidenum[1] := AddSideToHash(doomlinedefs[k].sidenum[1], k);
    end;

    FreeMem(doomsidedefs, numdoomsidedefs * SizeOf(mapsidedef_t));
    doomsidedefs := newsidedefs;
    numdoomsidedefs := numnewsidedefs;

    for j := 0 to SIDESHASHSIZE do
    begin
      ReallocMem(hashtable[j].sides, 0);
      ReallocMem(hashtable[j].ids, 0);
    end;
  end;


