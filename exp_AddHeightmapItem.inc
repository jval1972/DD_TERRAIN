  procedure AddHeightmapitem(const iX, iY: integer);
  begin
    if pass[iX, iY] then
      Exit;
    if flags and ETF_SLOPED <> 0 then
    begin
      if not TryFlatRange(iX, iY) then
      begin
        AddSlopedTriangle(iX, iY, iX + 1, iY, iX, iY + 1);
        AddSlopedTriangle(iX, iY + 1, iX + 1, iY, iX + 1, iY + 1);
      end;
    end
    else
      AddFlatQuad(iX, iY, iX + 1, iY, iX + 1, iY + 1, iX, iY + 1);
    pass[iX, iY] := True;
  end;
