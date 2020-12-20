  function GetHeightmapCoords3D(const iX, iY: integer): point3d_t;
  begin
    if options.flags and ETF_CALCDXDY <> 0 then
      Result := t.HeightmapCoords3D(iX, iY)
    else
    begin
      Result.X := t.HeightmapToCoord(iX);
      Result.Y := t.HeightmapToCoord(iY);
      Result.Z := t.Heightmap[iX, iY].height;
    end;
  end;
