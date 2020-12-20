  function AddVertex(const x, y: smallint): integer;
  var
    j: integer;
  begin
    for j := numdoomvertexes - 1 downto 0 do
      if (doomvertexes[j].x = x) and (doomvertexes[j].y = y) then
      begin
        result := j;
        exit;
      end;
    ReallocMem(doomvertexes, (numdoomvertexes  + 1) * SizeOf({$IFDEF UDMF_FORMAT}zmapvertex_t{$ELSE}mapvertex_t{$ENDIF}));
    doomvertexes[numdoomvertexes].x := x;
    doomvertexes[numdoomvertexes].y := y;
{$IFDEF UDMF_FORMAT}
    doomvertexes[numdoomvertexes].z := 0;
{$ENDIF}
    result := numdoomvertexes;
    inc(numdoomvertexes);
  end;
