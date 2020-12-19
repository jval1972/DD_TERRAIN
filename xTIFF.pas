unit xTIFF;

{$P+,S-,W-,R-,T-,X+,H+}
{$C PRELOAD}

interface

uses
  Windows, Forms, SysUtils, Classes, Graphics;

type
  TTIFFBitmap = class(TBitmap)
  private
    procedure WriteTIFFStreamData(Stream: TStream);
    procedure ReadTIFFStreamData(Stream: TStream);
  protected
    procedure WriteData(Stream: TStream); override;
    procedure ReadData(Stream: TStream); override;
  public
    compression: integer;
    constructor Create; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
  end;

implementation

uses
  LibTiffDelphi;

constructor TTIFFBitmap.Create;
begin
  compression := COMPRESSION_LZW;
  Inherited;
end;

procedure TTIFFBitmap.WriteData(Stream: TStream);
begin
  WriteTIFFStreamData(Stream);
end;

procedure TTIFFBitmap.SaveToStream(Stream: TStream);
begin
  WriteTIFFStreamData(Stream);
end;

procedure TTIFFBitmap.LoadFromStream(Stream: TStream);
begin
  ReadTIFFStreamData(Stream);
end;

procedure TTIFFBitmap.ReadData(Stream: TStream);
begin
  ReadTIFFStreamData(Stream);
end;

type
  uint32array_t = array[0..$FFF] of LongWord;
  uint32array_p = ^uint32array_t;

function RGBSwap(const l: LongWord): LongWord;
var
  A: packed array[0..3] of byte;
  tmp: byte;
begin
  PLongWord(@A)^ := l;
  tmp := A[0];
  A[0] := A[2];
  A[2] := tmp;
  Result := PLongWord(@A)^;
end;

procedure TTIFFBitmap.ReadTIFFStreamData(Stream: TStream);
var
  tif: PTIFF;
  w, h: LongWord;
  aBitmap: TBitmap;
  raster: uint32array_p;
  i, j: integer;
  l1, l2: uint32array_p;
begin
  tif := TIFFOpenStream(Stream, 'r');

  TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, @w);
  TIFFGetField(tif, TIFFTAG_IMAGELENGTH, @h);

  raster := _TIFFmalloc(w * h * SizeOf(LongWord));
  if raster <> nil then
  begin
    if TIFFReadRGBAImage(tif, w, h, raster, 0) <> 0 then
    begin
      for i := 0 to w * h - 1 do
        raster[i] := RGBSwap(raster[i]);

      aBitmap := TBitmap.Create;
      try
        aBitmap.Width := w;
        aBitmap.Height := h;
        aBitmap.PixelFormat := pf32bit;

        l2 := raster;
        for i := aBitmap.Height - 1 downto 0 do
        begin
          l1 := aBitmap.Scanline[i];
          for j := 0 to aBitmap.Width - 1 do
            l1[j] := l2[j];
          l2 := @l2[aBitmap.Width];
        end;

        Assign(aBitmap);
      finally
        aBitmap.Free;
      end;
    end;
    _TIFFfree(raster);
  end;
  TIFFClose(tif);
end;

procedure TTIFFBitmap.WriteTIFFStreamData(Stream: TStream);
var
  aBitmap: TBitmap;
  i, j: integer;
  l1, l2: uint32array_p;
  tif: PTIFF;
  w, h: LongWord;
begin
  aBitmap := TBitmap.Create;
  try
    aBitmap.Assign(self);
    aBitmap.PixelFormat := pf32bit;

    tif := TIFFOpenStream(Stream, 'wl');

    w := aBitmap.Width;
    h := aBitmap.Height;
    TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, w);
    TIFFSetField(tif, TIFFTAG_IMAGELENGTH, h);
    TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE, 8);
    TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, 4);
    TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, 1);
    TIFFSetField(tif, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
    TIFFSetField(tif, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
    TIFFSetField(tif, TIFFTAG_PHOTOMETRIC,  PHOTOMETRIC_RGB); //PHOTOMETRIC_MINISBLACK);
    TIFFSetField(tif, TIFFTAG_SAMPLEFORMAT, SAMPLEFORMAT_UINT);
    TIFFSetField(tif, TIFFTAG_COMPRESSION, compression); //COMPRESSION_NONE);

    GetMem(l2, aBitmap.Width * SizeOf(LongWord));
    for i := 0 to aBitmap.Height - 1 do
    begin
      l1 := aBitmap.ScanLine[i];
      for j := 0 to aBitmap.Width - 1 do
        l2[j] := RGBSwap(l1[j]) or $FF000000;
      TIFFWriteScanline(tif, l2, i, 0);
    end;
    FreeMem(l2, aBitmap.Width * SizeOf(LongWord));

    TIFFClose(tif);

  finally
    aBitmap.Free;
  end;
end;

initialization
  { Register the TTIFFBitmap as a new graphic file format
    now all the TPicture storage stuff can access our new
    TGA graphic format !
  }
  TPicture.RegisterFileFormat('TIF', 'TIF Image', TTIFFBitmap);

finalization
  TPicture.UnregisterGraphicClass(TTIFFBitmap);

end.

