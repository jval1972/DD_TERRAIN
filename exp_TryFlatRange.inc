  function TryFlatRange(const iX1, iY1: integer): boolean;
  var
    p1, p2, p3, p4: point3d_t;
    iX2, iY2: integer;
    iX3, iY3: integer;
    iX4, iY4: integer;
  begin
    Result := False;

    p1 := GetHeightmapCoords3D(iX1, iY1);
    iX2 := iX1 + 1;
    iY2 := iY1;
    p2 := GetHeightmapCoords3D(iX2, iY2);
    if p1.Z <> p2.Z then
      Exit;
    iX3 := iX1 + 1;
    iY3 := iY1 + 1;
    p3 := GetHeightmapCoords3D(iX3, iY3);
    if p1.Z <> p3.Z then
      Exit;
    iX4 := iX1;
    iY4 := iY1 + 1;
    p4 := GetHeightmapCoords3D(iX4, iY4);
    if p1.Z <> p4.Z then
      Exit;
    AddFlatQuad(iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4);
    flat[iX1, iY1] := true;

    Result := True;
  end;
