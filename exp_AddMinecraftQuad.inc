  procedure AddMinecraftQuad(const iX1, iY1, iX2, iY2, iX3, iY3, iX4, iY4: integer);
  var
    p1, p2, p3, p4: point3d_t;
    p0, p15, p25, p35, p45: point3d_t;
    boxLeft, boxRight, boxTop, boxBottom: integer;

    function _point_in_points(const p: point3d_p; const pp1, pp2, pp3, pp4: point3d_p): boolean;
    var
      minX, maxX, minY, maxY: integer;
      i, j: integer;
      poly: array[0..3] of point3d_p;
    begin
      poly[0] := pp1;
      poly[1] := pp2;
      poly[2] := pp3;
      poly[3] := pp4;
      minX := poly[0].x;
      maxX := poly[0].x;
      minY := poly[0].Y;
      maxY := poly[0].Y;
      for i := 1 to 3 do
      begin
        minX := MinI(poly[i].x, minX);
        maxX := MaxI(poly[i].x, maxX);
        minY := MinI(poly[i].y, minY);
        maxY := MaxI(poly[i].y, maxY);
      end;

      if (p.x <= minX) or (p.x >= maxX) or (p.y <= minY) or (p.Y >= maxY) then
      begin
        Result := False;
        Exit;
      end;

      Result := False;
      i := 0;
      j := 3;
      while i < 4 do
      begin
        if (poly[i].y >= p.y ) <> (poly[j].y >= p.y) then
          if p.X <= (poly[j].x - poly[i].x) * (p.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x then
            Result := not Result;
        j := i;
        inc(i);
      end;
    end;

    function _calc_minecraft_z(const zz: integer): integer;
    begin
      Result := GetIntInRange(((zz + options.layerstep div 2) div options.layerstep) * options.layerstep, -HEIGHTMAPRANGE, HEIGHTMAPRANGE);
    end;

    procedure _fix_minecraft_side(const ll, ss: integer);
    begin
      if doomlinedefs[ll].sidenum[0] < 0 then
        doomlinedefs[ll].sidenum[0] := AddSidedef(ss)
      else
      begin
        doomlinedefs[ll].sidenum[1] := AddSidedef(ss);
        doomlinedefs[ll].flags := doomlinedefs[ll].flags and not ML_BLOCKING;
        doomlinedefs[ll].flags := doomlinedefs[ll].flags or ML_TWOSIDED;
      end;
    end;

    procedure _add_minecraft_sector_4(const pp1, pp2, pp3, pp4: point3d_p);
    var
      zz: integer;
      vv1, vv2, vv3, vv4: integer;
      ll1, ll2, ll3, ll4: integer;
      sec: integer;
    begin
      zz := _calc_minecraft_z((pp1.Z + pp2.Z + pp3.Z + pp4.Z) div 4);
      sec := AddSector(zz, options.defceilingheight, False);
      vv1 := AddVertex(pp1.X, -pp1.Y);
      vv2 := AddVertex(pp2.X, -pp2.Y);
      vv3 := AddVertex(pp3.X, -pp3.Y);
      vv4 := AddVertex(pp4.X, -pp4.Y);
      ll1 := AddLinedef(vv1, vv2);
      _fix_minecraft_side(ll1, sec);
      ll2 := AddLinedef(vv2, vv3);
      _fix_minecraft_side(ll2, sec);
      ll3 := AddLinedef(vv3, vv4);
      _fix_minecraft_side(ll3, sec);
      ll4 := AddLinedef(vv4, vv1);
      _fix_minecraft_side(ll4, sec);
    end;

    procedure _add_minecraft_sector_5(const pp1, pp2, pp3, pp4, pp5: point3d_p);
    var
      zz: integer;
      vv1, vv2, vv3, vv4, vv5: integer;
      ll1, ll2, ll3, ll4, ll5: integer;
      sec: integer;
    begin
      zz := _calc_minecraft_z((pp1.Z + pp2.Z + pp3.Z + pp4.Z + pp5.Z) div 5);
      sec := AddSector(zz, options.defceilingheight, False);
      vv1 := AddVertex(pp1.X, -pp1.Y);
      vv2 := AddVertex(pp2.X, -pp2.Y);
      vv3 := AddVertex(pp3.X, -pp3.Y);
      vv4 := AddVertex(pp4.X, -pp4.Y);
      vv5 := AddVertex(pp5.X, -pp5.Y);
      ll1 := AddLinedef(vv1, vv2);
      _fix_minecraft_side(ll1, sec);
      ll2 := AddLinedef(vv2, vv3);
      _fix_minecraft_side(ll2, sec);
      ll3 := AddLinedef(vv3, vv4);
      _fix_minecraft_side(ll3, sec);
      ll4 := AddLinedef(vv4, vv5);
      _fix_minecraft_side(ll4, sec);
      ll5 := AddLinedef(vv5, vv1);
      _fix_minecraft_side(ll5, sec);
    end;

    procedure _add_minecraft_sector_6(const pp1, pp2, pp3, pp4, pp5, pp6: point3d_p);
    var
      zz: integer;
      vv1, vv2, vv3, vv4, vv5, vv6: integer;
      ll1, ll2, ll3, ll4, ll5, ll6: integer;
      sec: integer;
    begin
      zz := _calc_minecraft_z((pp1.Z + pp2.Z + pp3.Z + pp4.Z + pp5.Z + pp6.Z) div 6);
      sec := AddSector(zz, options.defceilingheight, False);
      vv1 := AddVertex(pp1.X, -pp1.Y);
      vv2 := AddVertex(pp2.X, -pp2.Y);
      vv3 := AddVertex(pp3.X, -pp3.Y);
      vv4 := AddVertex(pp4.X, -pp4.Y);
      vv5 := AddVertex(pp5.X, -pp5.Y);
      vv6 := AddVertex(pp6.X, -pp6.Y);
      ll1 := AddLinedef(vv1, vv2);
      _fix_minecraft_side(ll1, sec);
      ll2 := AddLinedef(vv2, vv3);
      _fix_minecraft_side(ll2, sec);
      ll3 := AddLinedef(vv3, vv4);
      _fix_minecraft_side(ll3, sec);
      ll4 := AddLinedef(vv4, vv5);
      _fix_minecraft_side(ll4, sec);
      ll5 := AddLinedef(vv5, vv6);
      _fix_minecraft_side(ll5, sec);
      ll6 := AddLinedef(vv6, vv1);
      _fix_minecraft_side(ll6, sec);
    end;

    procedure _add_minecraft_sector_8(const pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8: point3d_p);
    var
      zz: integer;
      vv1, vv2, vv3, vv4, vv5, vv6, vv7, vv8: integer;
      ll1, ll2, ll3, ll4, ll5, ll6, ll7, ll8: integer;
      sec: integer;
    begin
      zz := _calc_minecraft_z((pp1.Z + pp2.Z + pp3.Z + pp4.Z + pp5.Z + pp6.Z + pp7.Z + pp8.Z) div 8);
      sec := AddSector(zz, options.defceilingheight, False);
      vv1 := AddVertex(pp1.X, -pp1.Y);
      vv2 := AddVertex(pp2.X, -pp2.Y);
      vv3 := AddVertex(pp3.X, -pp3.Y);
      vv4 := AddVertex(pp4.X, -pp4.Y);
      vv5 := AddVertex(pp5.X, -pp5.Y);
      vv6 := AddVertex(pp6.X, -pp6.Y);
      vv7 := AddVertex(pp7.X, -pp7.Y);
      vv8 := AddVertex(pp8.X, -pp8.Y);
      ll1 := AddLinedef(vv1, vv2);
      _fix_minecraft_side(ll1, sec);
      ll2 := AddLinedef(vv2, vv3);
      _fix_minecraft_side(ll2, sec);
      ll3 := AddLinedef(vv3, vv4);
      _fix_minecraft_side(ll3, sec);
      ll4 := AddLinedef(vv4, vv5);
      _fix_minecraft_side(ll4, sec);
      ll5 := AddLinedef(vv5, vv6);
      _fix_minecraft_side(ll5, sec);
      ll6 := AddLinedef(vv6, vv7);
      _fix_minecraft_side(ll6, sec);
      ll7 := AddLinedef(vv7, vv8);
      _fix_minecraft_side(ll7, sec);
      ll8 := AddLinedef(vv8, vv1);
      _fix_minecraft_side(ll8, sec);
    end;

    function _inside_box(const p: point3d_p): boolean;
    begin
      Result := (p.X > boxLeft) and (p.X < boxRight) and
                (p.Y > boxTop) and (p.Y < boxBottom);
    end;

  begin
    p1 := GetHeightmapCoords3D(iX1, iY1);
    p2 := GetHeightmapCoords3D(iX2, iY2);
    p3 := GetHeightmapCoords3D(iX3, iY3);
    p4 := GetHeightmapCoords3D(iX4, iY4);
    p15.X := (p1.X + p2.X) div 2;
    p15.Y := (p1.Y + p2.Y) div 2;
    p15.Z := (p1.Z + p2.Z) div 2;
    p25.X := (p2.X + p3.X) div 2;
    p25.Y := (p2.Y + p3.Y) div 2;
    p25.Z := (p2.Z + p3.Z) div 2;
    p35.X := (p3.X + p4.X) div 2;
    p35.Y := (p3.Y + p4.Y) div 2;
    p35.Z := (p3.Z + p4.Z) div 2;
    p45.X := (p4.X + p1.X) div 2;
    p45.Y := (p4.Y + p1.Y) div 2;
    p45.Z := (p4.Z + p1.Z) div 2;

    boxLeft := MaxI(p1.X, p4.X);
    boxRight := MinI(p2.X, p3.X);
    boxTop := MaxI(p1.Y, p2.Y);
    boxBottom := MinI(p3.Y, p4.Y);

    p0.X := (p1.X + p2.X + p3.X + p4.X) div 4;
    p0.Y := (p1.Y + p2.Y + p3.Y + p4.Y) div 4;
    p0.Z := (p1.Z + p2.Z + p3.Z + p4.Z) div 4;

    if not _point_in_points(@p0, @p1, @p2, @p3, @p4) then
    begin
      p0.X := (p1.X + p3.X) div 2;
      p0.Y := (p1.Y + p3.Y) div 2;
      p0.Z := (p1.Z + p3.Z) div 4;
      if not _point_in_points(@p0, @p1, @p2, @p3, @p4) then
      begin
        p0.X := (p2.X + p4.X) div 2;
        p0.Y := (p2.Y + p4.Y) div 2;
        p0.Z := (p2.Z + p4.Z) div 4;
        if not _point_in_points(@p0, @p1, @p2, @p3, @p4) or not _inside_box(@p0) then
        begin
          _add_minecraft_sector_8(@p1, @p15, @p2, @p25, @p3, @p35, @p4, @p45);
          Exit;
        end;
      end;
    end;

    AddVertex(p1.X, -p1.Y);
    AddVertex(p2.X, -p2.Y);
    AddVertex(p3.X, -p3.Y);
    AddVertex(p4.X, -p4.Y);
    AddVertex(p15.X, -p15.Y);
    AddVertex(p25.X, -p25.Y);
    AddVertex(p35.X, -p35.Y);
    AddVertex(p45.X, -p45.Y);
    AddVertex(p0.X, -p0.Y);

    p1.Z := _calc_minecraft_z(p1.Z);
    p2.Z := _calc_minecraft_z(p2.Z);
    p3.Z := _calc_minecraft_z(p3.Z);
    p4.Z := _calc_minecraft_z(p4.Z);
    p15.Z := _calc_minecraft_z(p15.Z);
    p25.Z := _calc_minecraft_z(p25.Z);
    p35.Z := _calc_minecraft_z(p35.Z);
    p45.Z := _calc_minecraft_z(p45.Z);
    p0.Z := _calc_minecraft_z(p0.Z);

    if (p1.Z < p3.Z) and (p1.Z < p4.Z) and (p2.Z < p3.Z) and (p2.Z < p4.Z) then
    begin
      _add_minecraft_sector_6(@p1, @p15, @p2, @p25, @p0, @p45);
      _add_minecraft_sector_6(@p45, @p0, @p25, @p3, @p35, @p4);
    end
    else if (p1.Z > p3.Z) and (p1.Z > p4.Z) and (p2.Z > p3.Z) and (p2.Z > p4.Z) then
    begin
      _add_minecraft_sector_6(@p1, @p15, @p2, @p25, @p0, @p45);
      _add_minecraft_sector_6(@p45, @p0, @p25, @p3, @p35, @p4);
    end
    else if (p1.Z < p2.Z) and (p1.Z < p3.Z) and (p4.Z < p2.Z) and (p4.Z < p3.Z) then
    begin
      _add_minecraft_sector_6(@p1, @p15, @p0, @p35, @p4, @p45);
      _add_minecraft_sector_6(@p35, @p0, @p15, @p2, @p25, @p3);
    end
    else if (p1.Z > p2.Z) and (p1.Z > p3.Z) and (p4.Z > p2.Z) and (p4.Z > p3.Z) then
    begin
      _add_minecraft_sector_6(@p1, @p15, @p0, @p35, @p4, @p45);
      _add_minecraft_sector_6(@p35, @p0, @p15, @p2, @p25, @p3);
    end
    else if (p1.Z = p2.Z) and (p2.Z = p3.Z) and (p3.Z = p4.Z) then
      _add_minecraft_sector_8(@p1, @p15, @p2, @p25, @p3, @p35, @p4, @p45)
    else if (p1.Z = p2.Z) and (p2.Z = p4.Z) then
    begin
      _add_minecraft_sector_5(@p1, @p15, @p2, @p4, @p45);
      _add_minecraft_sector_5(@p4, @p2, @p25, @p3, @p35);
    end
    else if (p1.Z = p2.Z) and (p2.Z = p3.Z) then
    begin
      _add_minecraft_sector_5(@p1, @p15, @p2, @p25, @p3);
      _add_minecraft_sector_5(@p1, @p3, @p35, @p4, @p45);
    end
    else if (p2.Z = p3.Z) and (p3.Z = p4.Z) then
    begin
      _add_minecraft_sector_5(@p2, @p25, @p3, @p35, @p4);
      _add_minecraft_sector_5(@p2, @p4, @p45, @p1, @p15);
    end
    else if (p3.Z = p4.Z) and (p4.Z = p1.Z) then
    begin
      _add_minecraft_sector_5(@p3, @p35, @p4, @p45, @p1);
      _add_minecraft_sector_5(@p3, @p1, @p15, @p2, @p25);
    end
    else
    begin
      _add_minecraft_sector_4(@p1, @p15, @p0, @p45);
      _add_minecraft_sector_4(@p15, @p2, @p25, @p0);
      _add_minecraft_sector_4(@p0, @p25, @p3, @p35);
      _add_minecraft_sector_4(@p45, @p0, @p35, @p4);
    end;
  end;
