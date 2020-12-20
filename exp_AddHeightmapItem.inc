  procedure AddHeightmapitem(const iX, iY: integer);
  begin
    if pass[iX, iY] then
      Exit;
    if options.elevationmethod = ELEVATIONMETHOD_SLOPES then
    begin
      if not TryFlatRange(iX, iY) then
      begin
        AddSlopedTriangle(iX, iY, iX + 1, iY, iX, iY + 1);
        AddSlopedTriangle(iX, iY + 1, iX + 1, iY, iX + 1, iY + 1);
      end;
    end
    else if options.elevationmethod = ELEVATIONMETHOD_MINECRAFT then
    begin
      AddMinecraftQuad(iX, iY, iX + 1, iY, iX + 1, iY + 1, iX, iY + 1);
    end
    else  // ELEVATIONMETHOD_FLATSECTORS
    begin
      AddFlatTriangle(iX, iY, iX + 1, iY, iX, iY + 1);
      AddFlatTriangle(iX, iY + 1, iX + 1, iY, iX + 1, iY + 1);
    end;
    pass[iX, iY] := True;
  end;
