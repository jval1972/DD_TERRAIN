  procedure ExportFlatTexture;
  var
    ii, xx, yy: integer;
  begin
    // Create Palette
    for ii := 0 to 255 do
    begin
      r := options.palette[3 * ii];
      if r > 255 then r := 255;
      g := options.palette[3 * ii + 1];
      if g > 255 then g := 255;
      b := options.palette[3 * ii + 2];
      if b > 255 then b := 255;
      def_palL[ii] := (r shl 16) + (g shl 8) + (b);
    end;

    if options.flags and ETF_TRUECOLORFLAT <> 0 then
    begin
      // Create flat - 32 bit color - inside HI_START - HI_END namespace
      png := TPngObject.Create;
      png.Assign(t.Texture);

      ms := TMemoryStream.Create;

      png.SaveToStream(ms);

      wadwriter.AddSeparator('HI_START');
      wadwriter.AddData(options.levelname + 'TER', ms.Memory, ms.Size);
      wadwriter.AddSeparator('HI_END');

      if options.engine = ENGINE_VAVOOM then
      begin
        wadwriter.AddString('TEXTURES',
          'flat ' + options.levelname + 'TER,' + IntToStr(png.Width) + ',' + IntToStr(png.Height) + #13#10 +
          '{' + #13#10 +
          '   XScale 1.0' + #13#10 +
          '   YScale 1.0' + #13#10 +
          '   Patch ' + options.levelname + 'TER, 0, 0' + #13#10 +
          '}' + #13#10
        );
      end;
      ms.Free;
      png.Free;
    end;

    // Create flat - 8 bit
    bm := t.Texture;
    GetMem(flattexture, bm.Width * bm.Height);

    ii := 0;
    for yy := 0 to t.texturesize - 1 do
    begin
      scanline := t.Texture.ScanLine[yy];
      for xx := 0 to t.texturesize - 1 do
      begin
        c := scanline[xx];
        flattexture[ii] := V_FindAproxColorIndex(@def_palL, c);
        inc(ii);
      end;
    end;

    wadwriter.AddSeparator('F_START');
    wadwriter.AddData(options.levelname + 'TER', flattexture, bm.Width * bm.Height);
    wadwriter.AddSeparator('F_END');

    if (options.engine = ENGINE_RAD) and (options.game <> GAME_RADIX) then
      wadwriter.AddString('FLATINFO',
        'flat ' + options.levelname + 'TER'#13#10 + #13#10 +
        '{' + #13#10 +
        '   SIZE ' + IntToStr(t.texturesize) + #13#10 +
        '}' + #13#10
      );

    FreeMem(flattexture, bm.Width * bm.Height);
  end;

