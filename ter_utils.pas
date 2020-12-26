//------------------------------------------------------------------------------
//
//  DD_TERRAIN: Terrain Generator
//  Copyright (C) 2020 by Jim Valavanis
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, inc., 59 Temple Place - Suite 330, Boston, MA
//  02111-1307, USA.
//
// DESCRIPTION:
//  Settings(ini file)
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_utils;

interface

uses
  Windows,
  Graphics;

function StretchClipboardToBitmap(const b: TBitmap): boolean;

function GetGray256Color(const c: TColor): integer;

function GetIntInRange(const x: Integer; const amin, amax: Integer): Integer;

function IsIntInRange(const x: Integer; const amin, amax: Integer): Boolean;

function MaxI(const a, b: Integer): Integer;

function MinI(const a, b: Integer): Integer;

function MaxD(const a, b: Double): Double;

function MinD(const a, b: Double): Double;

function CopyFile(const sname, dname: string): boolean;

procedure BackupFile(const fname: string);

function MkShortName(const fname: string; const sz: integer = 30): string;

function I_VersionBuilt(fname: string = ''): string;

function DoubleEqual(const qry1, qry2: double): boolean;

type
  TDNumberList = class
  private
    fList: PIntegerArray;
    fNumItems: integer;
  protected
    function Get(Index: Integer): integer; virtual;
    procedure Put(Index: Integer; const value: integer); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const value: integer): integer; overload; virtual;
    procedure Add(const nlist: TDNumberList); overload; virtual;
    function Delete(const Index: integer): boolean;
    function IndexOf(const value: integer): integer;
    procedure Clear;
    procedure Sort;
    function Sum: integer;
    property Count: integer read fNumItems;
    property Numbers[Index: Integer]: integer read Get write Put; default;
    property List: PIntegerArray read fList;
  end;

type
  twointeger_t = record
    num1, num2: integer;
  end;
  twointeger_tArray = array[0..$FFFF] of twointeger_t;
  Ptwointeger_tArray = ^twointeger_tArray;

  T2DNumberList = class
  private
    fList: Ptwointeger_tArray;
    fNumItems: integer;
    fRealNumItems: integer;
  protected
    function Get(Index: Integer): twointeger_t; virtual;
    procedure Put(Index: Integer; const value: twointeger_t); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const value1, value2: integer): integer; overload; virtual;
    function Add(const value: twointeger_t): integer; overload; virtual;
    procedure Add(const nlist: T2DNumberList); overload; virtual;
    function Delete(const Index: integer): boolean;
    function IndexOf(const value1, value2: integer): integer; virtual;
    function IndexOf1(const value1: integer): integer; virtual;
    function IndexOf2(const value2: integer): integer; virtual;
    procedure Clear;
    procedure FastClear;
    procedure Sort1;
    procedure Sort2;
    property Count: integer read fNumItems;
    property Numbers[Index: Integer]: twointeger_t read Get write Put; default;
    property List: Ptwointeger_tArray read fList;
  end;

type
  TString = class
    str: string;
    constructor Create(const astring: string);
  end;

type
  TLongWordArray = array[0..$FFF] of LongWord;
  PLongWordArray = ^TLongWordArray;

type
  TByteArray = array[0..$FFFF] of Byte;
  PByteArray = ^TByteArray;

procedure SaveImageToDisk(const b: TBitmap; const imgfname: string);

procedure FlipBitmapVertical(const b: TBitmap);

procedure RotateBitmap90DegreesCounterClockwise(var ABitmap: TBitmap);

procedure RotateBitmap90DegreesClockwise(var ABitmap: TBitmap);

implementation

uses
  Classes,
  SysUtils,
  clipbrd,
  PngImage1,
  jpeg,
  xTIFF;

function StretchClipboardToBitmap(const b: TBitmap): boolean;
var
  tempBitmap: TBitmap;
  w, h: integer;
begin
  // if there is an image on clipboard
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    tempBitmap := TBitmap.Create;

    try
      tempBitmap.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(cf_Bitmap), 0);

      w := b.Width;
      h := b.Height;
      b.Canvas.StretchDraw(Rect(0, 0, w, h), tempBitmap);
    finally
      tempBitmap.Free;
    end;
    Result := True;
  end
  else
    Result := False;
end;

function GetGray256Color(const c: TColor): integer;
var
  r, g, b: integer;
begin
  r := GetRValue(c);
  g := GetGValue(c);
  b := GetBValue(c);
  Result := Round((r + g + b) / 3);
  if Result < 0 then
    Result := 0
  else if Result > 255 then
    Result := 255;
end;

function GetIntInRange(const x: Integer; const amin, amax: Integer): Integer;
begin
  Result := x;
  if Result < amin then
    Result := amin
  else if Result > amax then
    Result := amax;
end;

function IsIntInRange(const x: Integer; const amin, amax: Integer): Boolean;
begin
  Result := (x >= amin) and (x <= amax);
end;

function MaxI(const a, b: Integer): Integer;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

function MinI(const a, b: Integer): Integer;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function MaxD(const a, b: Double): Double;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

function MinD(const a, b: Double): Double;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function CopyFile(const sname, dname: string): boolean;
var
  FromF, ToF: file;
  NumRead, NumWritten: Integer;
  Buf: array[1..8192] of Char;
begin
  if FileExists(sname) then
  begin
    AssignFile(FromF, sname);
    Reset(FromF, 1);
    AssignFile(ToF, dname);
    Rewrite(ToF, 1);
    repeat
      BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
      BlockWrite(ToF, Buf, NumRead, NumWritten);
    until (NumRead = 0) or (NumWritten <> NumRead);
    CloseFile(FromF);
    CloseFile(ToF);
    Result := True;
  end
  else
    Result := False;
end;

procedure BackupFile(const fname: string);
var
  fbck: string;
begin
  if not FileExists(fname) then
    Exit;
  fbck := fname + '_bak';
  CopyFile(fname, fbck);
end;

function MkShortName(const fname: string; const sz: integer = 30): string;
var
  i: integer;
begin
  if Length(fname) < sz then
  begin
    Result := fname;
    Exit;
  end;
  Result := '';
  for i := Length(fname) downto Length(fname) - (sz - 6) do
    Result := fname[i] + Result;
  Result := '...' + Result;
  for i := 3 downto 1 do
    Result := fname[i] + Result;
end;

function I_VersionBuilt(fname: string = ''): string;
var
  vsize: LongWord;
  zero: LongWord;
  buffer: PByteArray;
  res: pointer;
  len: LongWord;
  i: integer;
begin
  if fname = '' then
    fname := ParamStr(0);
  vsize := GetFileVersionInfoSize(PChar(fname), zero);
  if vsize = 0 then
  begin
    Result := '';
    Exit;
  end;

  GetMem(buffer, vsize + 1);
  GetFileVersionInfo(PChar(fname), 0, vsize, buffer);
  VerQueryValue(buffer, '\StringFileInfo\040904E4\FileVersion', res, len);
  Result := '';
  for i := 0 to len - 1 do
  begin
    if PChar(res)^ = #0 then
      break;
    Result := Result + PChar(res)^;
    res := pointer(integer(res) + 1);
  end;
  FreeMem(pointer(buffer), vsize + 1);
end;

function DoubleEqual(const qry1, qry2: double): boolean;
const
  D_EPSILON = 0.00001;
begin
  Result := abs(qry1 - qry2) < D_EPSILON;
end;

// TDNumberList
constructor TDNumberList.Create;
begin
  fList := nil;
  fNumItems := 0;
end;

destructor TDNumberList.Destroy;
begin
  Clear;
end;

function TDNumberList.Get(Index: Integer): integer;
begin
  if (Index < 0) or (Index >= fNumItems) then
    Result := 0
  else
    Result := fList[Index];
end;

procedure TDNumberList.Put(Index: Integer; const value: integer);
begin
  fList[Index] := value;
end;

function TDNumberList.Add(const value: integer): integer;
begin
  ReallocMem(fList, (fNumItems + 1) * SizeOf(integer));
  Put(fNumItems, value);
  Result := fNumItems;
  inc(fNumItems);
end;

procedure TDNumberList.Add(const nlist: TDNumberList);
var
  i: integer;
begin
  for i := 0 to nlist.Count - 1 do
    Add(nlist[i]);
end;

function TDNumberList.Delete(const Index: integer): boolean;
var
  i: integer;
begin
  if (Index < 0) or (Index >= fNumItems) then
  begin
    Result := False;
    Exit;
  end;

  for i := Index + 1 to fNumItems - 1 do
    fList[i - 1] := fList[i];

  ReallocMem(pointer(fList), (fNumItems - 1) * SizeOf(integer));
  dec(fNumItems);

  Result := True;
end;

function TDNumberList.IndexOf(const value: integer): integer;
var
  i: integer;
begin
  for i := 0 to fNumItems - 1 do
    if fList[i] = value then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

procedure TDNumberList.Clear;
begin
  ReallocMem(pointer(fList), 0);
  fList := nil;
  fNumItems := 0;
end;

procedure QSortIntegers(const A: PIntegerArray; const Len: integer);

  procedure qsortI(l, r: Integer);
  var
    i, j: integer;
    t: integer;
    d: integer;
  begin
    repeat
      i := l;
      j := r;
      d := A[(l + r) shr 1];
      repeat
        while A[i] < d do
          inc(i);
        while A[j] > d do
          dec(j);
        if i <= j then
        begin
          t := A[i];
          A[i] := A[j];
          A[j] := t;
          inc(i);
          dec(j);
        end;
      until i > j;
      if l < j then
        qsortI(l, j);
      l := i;
    until i >= r;
  end;

begin
  if Len > 1 then
    qsortI(0, Len - 1);
end;

procedure TDNumberList.Sort;
begin
  QSortIntegers(fList, fNumItems);
end;

function TDNumberList.Sum: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to fNumItems - 1 do
    Result := Result + fList[i];
end;

// T2DNumberList
constructor T2DNumberList.Create;
begin
  fList := nil;
  fNumItems := 0;
  fRealNumItems := 0;
end;

destructor T2DNumberList.Destroy;
begin
  Clear;
end;

function T2DNumberList.Get(Index: Integer): twointeger_t;
begin
  if (Index < 0) or (Index >= fNumItems) then
  begin
    result.num1 := 0;
    result.num2 := 0;
  end
  else
    result := fList[Index];
end;

procedure T2DNumberList.Put(Index: Integer; const value: twointeger_t);
begin
  fList[Index] := value;
end;

function T2DNumberList.Add(const value1, value2: integer): integer;
var
  newrealitems: integer;
  value: twointeger_t;
begin
  if fNumItems >= fRealNumItems then
  begin
    if fRealNumItems < 4 then
      newrealitems := 4
    else if fRealNumItems < 8 then
      newrealitems := 8
    else if fRealNumItems < 32 then
      newrealitems := 32
    else if fRealNumItems < 128 then
      newrealitems := fRealNumItems + 32
    else
      newrealitems := fRealNumItems + 64;
    ReallocMem(fList, newrealitems * SizeOf(twointeger_t));
    fRealNumItems := newrealitems;
  end;
  value.num1 := value1;
  value.num2 := value2;
  Put(fNumItems, value);
  result := fNumItems;
  inc(fNumItems);
end;

function T2DNumberList.Add(const value: twointeger_t): integer;
begin
  result := Add(value.num1, value.num2);
end;

procedure T2DNumberList.Add(const nlist: T2DNumberList);
var
  i: integer;
begin
  for i := 0 to nlist.Count - 1 do
    Add(nlist[i]);
end;

function T2DNumberList.Delete(const Index: integer): boolean;
var
  i: integer;
begin
  if (Index < 0) or (Index >= fNumItems) then
  begin
    result := false;
    exit;
  end;

  for i := Index + 1 to fNumItems - 1 do
    fList[i - 1] := fList[i];

  dec(fNumItems);

  result := true;
end;

function T2DNumberList.IndexOf(const value1, value2: integer): integer;
var
  i: integer;
begin
  for i := 0 to fNumItems - 1 do
    if (fList[i].num1 = value1) and (fList[i].num2 = value2) then
    begin
      result := i;
      exit;
    end;
  result := -1;
end;

function T2DNumberList.IndexOf1(const value1: integer): integer;
var
  i: integer;
begin
  for i := 0 to fNumItems - 1 do
    if fList[i].num1 = value1 then
    begin
      result := i;
      exit;
    end;
  result := -1;
end;

function T2DNumberList.IndexOf2(const value2: integer): integer;
var
  i: integer;
begin
  for i := 0 to fNumItems - 1 do
    if fList[i].num2 = value2 then
    begin
      result := i;
      exit;
    end;
  result := -1;
end;

procedure T2DNumberList.Clear;
begin
  ReallocMem(fList, 0);
  fList := nil;
  fNumItems := 0;
  fRealNumItems := 0;
end;

procedure QSort2Integers(const A: Ptwointeger_tArray; const Len: integer; const idx: integer);

  procedure qsortI(l, r: Integer);
  var
    i, j: integer;
    t: twointeger_t;
    d: twointeger_t;
  begin
    repeat
      i := l;
      j := r;
      d := A[(l + r) shr 1];
      repeat
        if idx = 1 then
        begin
          while A[i].num1 < d.num1 do
            inc(i);
          while A[j].num1 > d.num1 do
            dec(j);
        end
        else
        begin
          while A[i].num2 < d.num2 do
            inc(i);
          while A[j].num2 > d.num2 do
            dec(j);
        end;
        if i <= j then
        begin
          t := A[i];
          A[i] := A[j];
          A[j] := t;
          inc(i);
          dec(j);
        end;
      until i > j;
      if l < j then
        qsortI(l, j);
      l := i;
    until i >= r;
  end;

begin
  if Len > 1 then
    qsortI(0, Len - 1);
end;

procedure T2DNumberList.Sort1;
begin
  QSort2Integers(fList, fNumItems, 1);
end;

procedure T2DNumberList.Sort2;
begin
  QSort2Integers(fList, fNumItems, 2);
end;

procedure T2DNumberList.FastClear;
begin
  fNumItems := 0;
end;

// TString
constructor TString.Create(const astring: string);
begin
  str := astring;
end;

procedure SaveImageToDisk(const b: TBitmap; const imgfname: string);
var
  png: TPngObject;
  jpg: TJPEGImage;
  tif: TTIFFBitmap;
  ext: string;
begin
  ext := UpperCase(ExtractFileExt(imgfname));
  if ext = '.PNG' then
  begin
    png := TPngObject.Create;
    png.Assign(b);
    png.SaveToFile(imgfname);
    png.Free;
  end
  else if (ext = '.TIF') or (ext = '.TIFF') then
  begin
    tif := TTIFFBitmap.Create;
    tif.Assign(b);
    tif.SaveToFile(imgfname);
    tif.Free;
  end
  else if (ext = '.JPG') or (ext = '.JPEG') then
  begin
    jpg := TJPEGImage.Create;
    jpg.Assign(b);
    jpg.SaveToFile(imgfname);
    jpg.Free;
  end
  else
    b.SaveToFile(imgfname);
end;

function _min4i(const i1, i2, i3, i4: integer): integer;
begin
  Result := i1;
  if i2 < Result then
    Result := i2;
  if i3 < Result then
    Result := i3;
  if i4 < Result then
    Result := i4;
end;

function _max4i(const i1, i2, i3, i4: integer): integer;
begin
  Result := i1;
  if i2 > Result then
    Result := i2;
  if i3 > Result then
    Result := i3;
  if i4 > Result then
    Result := i4;
end;

procedure FlipBitmapVertical(const b: TBitmap);
var
  i, j: integer;
  tmp: LongWord;
  l1, l2: PLongWordArray;
begin
  b.PixelFormat := pf32bit;

  for j := 0 to b.Height div 2 - 1 do
  begin
    l1 := b.ScanLine[j];
    l2 := b.ScanLine[b.Height - 1 - j];
    for i := 0 to b.Width - 1 do
    begin
      tmp := l1[i];
      l1[i] := l2[i];
      l2[i] := tmp;
    end;
  end;
end;

procedure RotateBitmap90DegreesCounterClockwise(var ABitmap: TBitmap);
const
  BitsPerByte = 8;
var
  {
  A whole pile of variables. Some deal with one- and four-bit bitmaps only,
  some deal with eight- and 24-bit bitmaps only, and some deal with both.
  Any variable that ends in 'R' refers to the rotated bitmap, e.g. MemoryStream
  holds the original bitmap, and MemoryStreamR holds the rotated one.
  }
  PbmpInfoR: PBitmapInfoHeader;
  bmpBuffer, bmpBufferR: PByte;
  MemoryStream, MemoryStreamR: TMemoryStream;
  PbmpBuffer, PbmpBufferR: PByte;
  BytesPerPixel, PixelsPerByte: LongInt;
  BytesPerScanLine, BytesPerScanLineR: LongInt;
  PaddingBytes: LongInt;
  BitmapOffset: LongInt;
  BitCount: LongInt;
  WholeBytes, ExtraPixels: LongInt;
  SignificantBytes, SignificantBytesR: LongInt;
  ColumnBytes: LongInt;
  AtLeastEightBitColor: Boolean;
  T: LongInt;



procedure NonIntegralByteRotate; (* nested *)
{
 This routine rotates bitmaps with fewer than 8 bits of information per pixel,
 namely monochrome (1-bit) and 16-color (4-bit) bitmaps. Note that there are
 no such things as 2-bit bitmaps, though you might argue that Microsoft's bitmap
 format is worth about 2 bits.
}
var
  X, Y: LongInt;
  I: LongInt;
  MaskBits, CurrentBits: Byte;
  FirstMask, LastMask: Byte;
  PFirstScanLine: PByte;
  FirstIndex, CurrentBitIndex: LongInt;
  ShiftRightAmount, ShiftRightStart: LongInt;
begin
  Inc(PbmpBuffer, BytesPerScanLine * (PbmpInfoR^.biHeight - 1) );
  { PFirstScanLine advances along the first scan line of bmpBufferR. }
  PFirstScanLine := bmpBufferR;
  { Set up the indexing. }
  FirstIndex := BitsPerByte - BitCount;
  {
  Set up the bit masks:
  For a monochrome bitmap,
  LastMask := 00000001 and
  FirstMask := 10000000
  For a 4-bit bitmap,
  LastMask := 00001111 and
  FirstMask := 11110000
  We'll shift through these such that the CurrentBits and the MaskBits will go
  For a monochrome bitmap:
  10000000, 01000000, 00100000, 00010000, 00001000, 00000100, 00000010, 00000001
  For a 4-bit bitmap:
  11110000, 00001111
  The CurrentBitIndex denotes how far over the right-most bit would need to
  shift to get to the position of CurrentBits. For example, if we're on the
  eleventh column of a monochrome bitmap, then CurrentBits will equal
  11 mod 8 := 3, or the 3rd-to-the-leftmost bit. Thus, the right-most bit
  would need to shift four places over to get anded correctly with
  CurrentBits. CurrentBitIndex will store this value.
  }
  LastMask := 1 shl BitCount - 1;
  FirstMask := LastMask shl FirstIndex;
  CurrentBits := FirstMask;
  CurrentBitIndex := FirstIndex;
  ShiftRightStart := BitCount * (PixelsPerByte - 1);
  { Here's the meat. Loop through the pixels and rotate appropriately. }
  { Remember that DIBs have their origins opposite from DDBs. }
  { The Y counter holds the current row of the source bitmap. }
  for Y := 1 to PbmpInfoR^.biHeight do begin
  PbmpBufferR := PFirstScanLine;
  {
  The X counter holds the current column of the source bitmap. We only
  deal with completely filled bytes here. Should there be an extra 'partial'
  byte, we'll deal with that below.
  }

  for X := 1 to WholeBytes do begin
  {
  Pick out the bits, starting with 10000000 for monochromes and
  11110000 for 4-bit guys.
  }
  MaskBits := FirstMask;
  {
  ShiftRightAmount is the amount we need to shift the current bit all
  the way to the right.
  }
  ShiftRightAmount := ShiftRightStart;
  for I := 1 to PixelsPerByte do begin
  {
  Here's the doozy. Take the rotated bitmap's current byte and mask it
  with not CurrentBits. This zeros out the CurrentBits only, and leaves
  everything else unchanged. Example: For a monochrome bitmap, if we
  were on the 11th column as above, we would need to zero out the
  3rd-to-left bit, so we would take PbmpBufferR^ and 11011111.
  Now consider our current source byte. For monochrome bitmaps, we're
  going to loop through each bit, for a total of eight pixels. For
  4-bit bitmaps, we're going to loop through the bits four at a time,
  for a total of two pixels. Either way, we do this by masking it with
  MaskBits ('PbmpBuffer^ and MaskBits'). Now we need to get the bit(s)
  into the same column(s) that CurrentBits reflects. We do this by
  shifting them to the right-most part of the byte ('shr
  ShiftRightAmount'), and then shifting left by our aforementioned
  CurrentBitIndex ('shl CurrentBitIndex'). This is because, although a
  right-shift of -n should just be a left-shift of +n, it doesn't work
  that way, at least in Delphi. So we just start from scratch by putting
  everything as far right as we can.
  Finally, we have our source bit(s) shifted to the appropriate place,
  with nothing but zeros around. Simply or it with PbmpBufferR^ (which
  had its CurrentBits zeroed out, remember?) and we're done.
  Yeah, sure. "Simply". Duh.
  }
  PbmpBufferR^ := ( PbmpBufferR^ and not CurrentBits ) or
  ( (PbmpBuffer^ and MaskBits) shr ShiftRightAmount shl CurrentBitIndex );
  { Move the MaskBits over for the next iteration. }
  MaskBits := MaskBits shr BitCount;
  { Move our pointer to the rotated-bitmap buffer up one scan line. }
  Inc(PbmpBufferR, BytesPerScanLineR);
  { We don't need to shift as far to the right the next time around. }
  Dec(ShiftRightAmount, BitCount);
  end;
  Inc(PbmpBuffer);
  end;
  { If there's a partial byte, take care of it now. }
  if ExtraPixels <> 0 then begin
  { Do exactly the same crap as in the loop above. }
  MaskBits := FirstMask;
  ShiftRightAmount := ShiftRightStart;
  for I := 1 to ExtraPixels do begin
  PbmpBufferR^ := ( PbmpBufferR^ and not CurrentBits ) or
  ( (PbmpBuffer^ and MaskBits) shr ShiftRightAmount shl CurrentBitIndex );
  MaskBits := MaskBits shr BitCount;
  Inc(PbmpBufferR, BytesPerScanLineR);
  Dec(ShiftRightAmount, BitCount);
  end;
  Inc(PbmpBuffer);
  end;
  { Skip the padding. }
  Inc(PbmpBuffer, PaddingBytes);
  {
  Back up the scan line you just traversed, and go one more to get set for
  the next row.
  }
  Dec(PbmpBuffer, BytesPerScanLine shl 1);
  if CurrentBits = LastMask then begin
  { We're at the end of this byte. Start over on another column. }
  CurrentBits := FirstMask;
  CurrentBitIndex := FirstIndex;
  { Go to the bottom of the rotated bitmap's column, but one column over. }
  (*$IFDEF Win32*)

  Inc(PFirstScanLine);

  (*$ELSE*)

  Win16Inc( Pointer(PFirstScanLine), 1 );

  (*$ENDIF*)

  end

  else begin

  { Continue filling this byte. }

  CurrentBits := CurrentBits shr BitCount;

  Dec(CurrentBitIndex, BitCount);

  end;

  end;

end; { procedure NonIntegralByteRotate (* nested *) }

 

procedure IntegralByteRotate; (* nested *)

var

  X, Y: LongInt;

  (*$IFNDEF Win32*)

  I: Integer;

  (*$ENDIF*)

 

begin

  { Advance PbmpBufferR to the last column of the first scan line of bmpBufferR. }

  (*$IFDEF Win32*)

  Inc(PbmpBufferR, SignificantBytesR - BytesPerPixel);

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBufferR), SignificantBytesR - BytesPerPixel );

  (*$ENDIF*)

 

  { Here's the meat. Loop through the pixels and rotate appropriately. }

  { Remember that DIBs have their origins opposite from DDBs. }

  for Y := 1 to PbmpInfoR^.biHeight do begin

  for X := 1 to PbmpInfoR^.biWidth do begin

  { Copy the pixels. }

  (*$IFDEF Win32*)

  Move(PbmpBuffer^, PbmpBufferR^, BytesPerPixel);

  Inc(PbmpBuffer, BytesPerPixel);

  Inc(PbmpBufferR, BytesPerScanLineR);

  (*$ELSE*)

  for I := 1 to BytesPerPixel do begin

  PbmpBufferR^ := PbmpBuffer^;

  Win16Inc( Pointer(PbmpBuffer), 1 );

  Win16Inc( Pointer(PbmpBufferR), 1 );

  end;

  Win16Inc( Pointer(PbmpBufferR), BytesPerScanLineR - BytesPerPixel);

  (*$ENDIF*)

  end;

  (*$IFDEF Win32*)

  { Skip the padding. }

  Inc(PbmpBuffer, PaddingBytes);

  { Go to the top of the rotated bitmap's column, but one column over. }

  Dec(PbmpBufferR, ColumnBytes + BytesPerPixel);

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBuffer), PaddingBytes);

  Win16Dec( Pointer(PbmpBufferR), ColumnBytes + BytesPerPixel);

  (*$ENDIF*)

  end;

end;

 

{ This is the body of procedure RotateBitmap90DegreesCounterClockwise. }

begin

  { Don't *ever* call GetDIBSizes! It screws up your bitmap. }

 

  MemoryStream := TMemoryStream.Create;

 

  {

  To do: Set the size before-hand. This will eliminate ReAlloc overhead

  for the MemoryStream. Calling GetDIBSizes would be nice, but, as mentioned

  above, it corrupts the Bitmap in some cases. Some API calls will probably

  take care of things, but I'm not going to mess with it right now.

  }

 

  { An undocumented method. Nice to have around, though. }

  ABitmap.SaveToStream(MemoryStream);

 

  { Don't need you anymore. We'll make a new one when the time comes. }

  ABitmap.Free;

 

  bmpBuffer := MemoryStream.Memory;

  { Get the offset bits. This may or may not include palette information. }

  BitmapOffset := PBitmapFileHeader(bmpBuffer)^.bfOffBits;

 

  { Set PbmpInfoR to point to the source bitmap's info header. }

  { Boy, these headers are getting annoying. }

  (*$IFDEF Win32*)

  Inc( bmpBuffer, SizeOf(TBitmapFileHeader) );

  (*$ELSE*)

  Win16Inc( Pointer(bmpBuffer), SizeOf(TBitmapFileHeader) );

  (*$ENDIF*)

  PbmpInfoR := PBitmapInfoHeader(bmpBuffer);

 

  { Set bmpBuffer and PbmpBuffer to point to the original bitmap bits. }

  bmpBuffer := MemoryStream.Memory;

  (*$IFDEF Win32*)

  Inc(bmpBuffer, BitmapOffset);

  (*$ELSE*)

  Win16Inc( Pointer(bmpBuffer), BitmapOffset );

  (*$ENDIF*)

  PbmpBuffer := bmpBuffer;

 

  {

  Note that we don't need to worry about version 4 vs. version 3 bitmaps,

  because the fields we use -- namely biWidth, biHeight, and biBitCount --

  occur in exactly the same place in both structs. So we're a bit lucky. OS/2

  bitmaps, by the way, cause this to crash heinously. Sorry.

  }

  with PbmpInfoR^ do begin

  { ShowMessage('Compression := ' + IntToStr(biCompression)); }

  BitCount := biBitCount;

  { ShowMessage('BitCount := ' + IntToStr(BitCount)); }

 

  { ScanLines are DWORD aligned. }

  BytesPerScanLine := ((((biWidth * BitCount) + 31) div 32) * SizeOf(DWORD));

  BytesPerScanLineR := ((((biHeight * BitCount) + 31) div 32) * SizeOf(DWORD));

 

  AtLeastEightBitColor := BitCount >= BitsPerByte;

  if AtLeastEightBitColor then begin

  { Don't have to worry about bit-twiddling. Cool. }

  BytesPerPixel := biBitCount shr 3;

  SignificantBytes := biWidth * BitCount shr 3;

  SignificantBytesR := biHeight * BitCount shr 3;

  { Extra bytes required for DWORD aligning. }

  PaddingBytes := BytesPerScanLine - SignificantBytes;

  ColumnBytes := BytesPerScanLineR * biWidth;

  end

  else begin

  { One- or four-bit bitmap. Ugh. }

  PixelsPerByte := SizeOf(Byte) * BitsPerByte div BitCount;

  { The number of bytes entirely filled with pixel information. }

  WholeBytes := biWidth div PixelsPerByte;

  {

  Any extra bits that might partially fill a byte. For instance, a

  monochrome bitmap that is 14 pixels wide has one whole byte and a

  partial byte which has six bits actually used (the rest are garbage).

  }

  ExtraPixels := biWidth mod PixelsPerByte;

  {

  The number of extra bytes -- if any -- required to DWORD-align a

  scanline.

  }

  PaddingBytes := BytesPerScanLine - WholeBytes;

  {

  If there are extra bits (i.e., they run over into a 'partial byte'),

  then one of the padding bytes has already been accounted for.

  }

  if ExtraPixels <> 0 then Dec(PaddingBytes);

  end; { if AtLeastEightBitColor then }

 

  { The TMemoryStream that will hold the rotated bits. }

  MemoryStreamR := TMemoryStream.Create;

  {

  Set size for rotated bitmap. Might be different from source size

  due to DWORD aligning.

  }

  MemoryStreamR.SetSize(BitmapOffset + BytesPerScanLineR * biWidth);

  end; { with PbmpInfoR^ do }

 

  { Copy the headers from the source bitmap. }

  MemoryStream.Seek(0, soFromBeginning);

  MemoryStreamR.CopyFrom(MemoryStream, BitmapOffset);

 

  { Here's the buffer we're going to rotate. }

  bmpBufferR := MemoryStreamR.Memory;

  { Skip the headers, yadda yadda yadda... }

  (*$IFDEF Win32*)

  Inc(bmpBufferR, BitmapOffset);

  (*$ELSE*)

  Win16Inc( Pointer(bmpBufferR), BitmapOffset );

  (*$ENDIF*)

  PbmpBufferR := bmpBufferR;

 

  { Do it. }

  if AtLeastEightBitColor then

  IntegralByteRotate

  else

  NonIntegralByteRotate;

 

  { Done with the source bits. }

  MemoryStream.Free;

 

  { Now set PbmpInfoR to point to the rotated bitmap's info header. }

  PbmpBufferR := MemoryStreamR.Memory;

  (*$IFDEF Win32*)

  Inc( PbmpBufferR, SizeOf(TBitmapFileHeader) );

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBufferR), SizeOf(TBitmapFileHeader) );

  (*$ENDIF*)

  PbmpInfoR := PBitmapInfoHeader(PbmpBufferR);

 

  { Swap the width and height of the rotated bitmap's info header. }

  with PbmpInfoR^ do begin

  T := biHeight;

  biHeight := biWidth;

  biWidth := T;

  biSizeImage := 0;

  end;

 

  ABitmap := TBitmap.Create;

 

  { Spin back to the very beginning. }

  MemoryStreamR.Seek(0, soFromBeginning);

  { Load it back into ABitmap. }

  ABitmap.LoadFromStream(MemoryStreamR);

 

  MemoryStreamR.Free;

end;

 

procedure RotateBitmap90DegreesClockwise(var ABitmap: TBitmap);

const

  BitsPerByte = 8;

 

var

  {

  A whole pile of variables. Some deal with one- and four-bit bitmaps only,

  some deal with eight- and 24-bit bitmaps only, and some deal with both.

  Any variable that ends in 'R' refers to the rotated bitmap, e.g. MemoryStream

  holds the original bitmap, and MemoryStreamR holds the rotated one.

  }

  PbmpInfoR: PBitmapInfoHeader;

  bmpBuffer, bmpBufferR: PByte;

  MemoryStream, MemoryStreamR: TMemoryStream;

  PbmpBuffer, PbmpBufferR: PByte;

  BytesPerPixel, PixelsPerByte: LongInt;

  BytesPerScanLine, BytesPerScanLineR: LongInt;

  PaddingBytes: LongInt;

  BitmapOffset: LongInt;

  BitCount: LongInt;

  WholeBytes, ExtraPixels: LongInt;

  SignificantBytes: LongInt;

  ColumnBytes: LongInt;

  AtLeastEightBitColor: Boolean;

  T: LongInt;

 

procedure NonIntegralByteRotate; (* nested *)

{

 This routine rotates bitmaps with fewer than 8 bits of information per pixel,

 namely monochrome (1-bit) and 16-color (4-bit) bitmaps. Note that there are

 no such things as 2-bit bitmaps, though you might argue that Microsoft's bitmap

 format is worth about 2 bits.

}

var

  X, Y: LongInt;

  I: LongInt;

  MaskBits, CurrentBits: Byte;

  FirstMask, LastMask: Byte;

  PLastScanLine: PByte;

  FirstIndex, CurrentBitIndex: LongInt;

  ShiftRightAmount, ShiftRightStart: LongInt;

 

begin

  { Advance PLastScanLine to the first column of the last scan line of bmpBufferR. }

  PLastScanLine := bmpBufferR; (*$IFDEF Win32*) Inc(PLastScanLine, BytesPerScanLineR *

  (PbmpInfoR^.biWidth - 1) ); (*$ELSE*) Win16Inc( Pointer(PLastScanLine),

  BytesPerScanLineR * (PbmpInfoR^.biWidth - 1) ); (*$ENDIF*)

 

  { Set up the indexing. }

  FirstIndex := BitsPerByte - BitCount;

 

  {

  Set up the bit masks:

 

  For a monochrome bitmap,

  LastMask := 00000001 and

  FirstMask := 10000000

 

  For a 4-bit bitmap,

  LastMask := 00001111 and

  FirstMask := 11110000

 

  We'll shift through these such that the CurrentBits and the MaskBits will go

  For a monochrome bitmap:

  10000000, 01000000, 00100000, 00010000, 00001000, 00000100, 00000010, 00000001

  For a 4-bit bitmap:

  11110000, 00001111

 

  The CurrentBitIndex denotes how far over the right-most bit would need to

  shift to get to the position of CurrentBits. For example, if we're on the

  eleventh column of a monochrome bitmap, then CurrentBits will equal

  11 mod 8 := 3, or the 3rd-to-the-leftmost bit. Thus, the right-most bit

  would need to shift four places over to get anded correctly with

  CurrentBits. CurrentBitIndex will store this value.

  }

  LastMask := 1 shl BitCount - 1;

  FirstMask := LastMask shl FirstIndex;

 

  CurrentBits := FirstMask;

  CurrentBitIndex := FirstIndex;

 

  ShiftRightStart := BitCount * (PixelsPerByte - 1);

 

  { Here's the meat. Loop through the pixels and rotate appropriately. }

  { Remember that DIBs have their origins opposite from DDBs. }

 

  { The Y counter holds the current row of the source bitmap. }

  for Y := 1 to PbmpInfoR^.biHeight do begin

  PbmpBufferR := PLastScanLine;

 

  {

  The X counter holds the current column of the source bitmap. We only

  deal with completely filled bytes here. Should there be an extra 'partial'

  byte, we'll deal with that below.

  }

  for X := 1 to WholeBytes do begin

  {

  Pick out the bits, starting with 10000000 for monochromes and

  11110000 for 4-bit guys.

  }

  MaskBits := FirstMask;

  {

  ShiftRightAmount is the amount we need to shift the current bit all

  the way to the right.

  }

  ShiftRightAmount := ShiftRightStart;

  for I := 1 to PixelsPerByte do begin

  {

  Here's the doozy. Take the rotated bitmap's current byte and mask it

  with not CurrentBits. This zeros out the CurrentBits only, and leaves

  everything else unchanged. Example: For a monochrome bitmap, if we

  were on the 11th column as above, we would need to zero out the

  3rd-to-left bit, so we would take PbmpBufferR^ and 11011111.

 

  Now consider our current source byte. For monochrome bitmaps, we're

  going to loop through each bit, for a total of eight pixels. For

  4-bit bitmaps, we're going to loop through the bits four at a time,

  for a total of two pixels. Either way, we do this by masking it with

  MaskBits ('PbmpBuffer^ and MaskBits'). Now we need to get the bit(s)

  into the same column(s) that CurrentBits reflects. We do this by

  shifting them to the right-most part of the byte ('shr

  ShiftRightAmount'), and then shifting left by our aforementioned

  CurrentBitIndex ('shl CurrentBitIndex'). This is because, although a

  right-shift of -n should just be a left-shift of +n, it doesn't work

  that way, at least in Delphi. So we just start from scratch by putting

  everything as far right as we can.

 

  Finally, we have our source bit(s) shifted to the appropriate place,

  with nothing but zeros around. Simply or it with PbmpBufferR^ (which

  had its CurrentBits zeroed out, remember?) and we're done.

 

  Yeah, sure. "Simply". Duh.

  }

 

  PbmpBufferR^ := ( PbmpBufferR^ and not CurrentBits ) or

  ( (PbmpBuffer^ and MaskBits) shr ShiftRightAmount shl CurrentBitIndex );



  { Move the MaskBits over for the next iteration. }

  MaskBits := MaskBits shr BitCount;

  (*$IFDEF Win32*)

  { Move our pointer to the rotated-bitmap buffer up one scan line. }

  Dec(PbmpBufferR, BytesPerScanLineR);

  (*$ELSE*)

  Win16Dec( Pointer(PbmpBufferR), BytesPerScanLineR );

  (*$ENDIF*)

  { We don't need to shift as far to the right the next time around. }

  Dec(ShiftRightAmount, BitCount);

  end;

  (*$IFDEF Win32*)

  Inc(PbmpBuffer);

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBuffer), 1 );

  (*$ENDIF*)

  end;

 

  { If there's a partial byte, take care of it now. }

  if ExtraPixels <> 0 then begin

  { Do exactly the same crap as in the loop above. }

  MaskBits := FirstMask;

  ShiftRightAmount := ShiftRightStart;

  for I := 1 to ExtraPixels do begin

  PbmpBufferR^ := ( PbmpBufferR^ and not CurrentBits ) or

  ( (PbmpBuffer^ and MaskBits) shr ShiftRightAmount shl CurrentBitIndex );

 

  MaskBits := MaskBits shr BitCount;

  (*$IFDEF Win32*)

  Dec(PbmpBufferR, BytesPerScanLineR);

  (*$ELSE*)

  Win16Dec( Pointer(PbmpBufferR), BytesPerScanLineR );

  (*$ENDIF*)

  Dec(ShiftRightAmount, BitCount);

  end;

  (*$IFDEF Win32*)

  Inc(PbmpBuffer);

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBuffer), 1 );

  (*$ENDIF*)

  end;

 

  { Skip the padding. }

  (*$IFDEF Win32*)

  Inc(PbmpBuffer, PaddingBytes);

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBuffer), PaddingBytes );

  (*$ENDIF*)

 

  if CurrentBits = LastMask then begin

  { We're at the end of this byte. Start over on another column. }

  CurrentBits := FirstMask;

  CurrentBitIndex := FirstIndex;

  { Go to the bottom of the rotated bitmap's column, but one column over. }

  (*$IFDEF Win32*)

  Inc(PLastScanLine);

  (*$ELSE*)

  Win16Inc( Pointer(PLastScanLine), 1 );

  (*$ENDIF*)

  end

  else begin

  { Continue filling this byte. }

  CurrentBits := CurrentBits shr BitCount;

  Dec(CurrentBitIndex, BitCount);

  end;

  end;

end; { procedure NonIntegralByteRotate (* nested *) }

 

procedure IntegralByteRotate; (* nested *)

var

  X, Y: LongInt;

  (*$IFNDEF Win32*)

  I: Integer;

  (*$ENDIF*)

 

begin

  { Advance PbmpBufferR to the first column of the last scan line of bmpBufferR. }

  (*$IFDEF Win32*)

  Inc( PbmpBufferR, BytesPerScanLineR * (PbmpInfoR^.biWidth - 1) );

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBufferR) , BytesPerScanLineR * (PbmpInfoR^.biWidth - 1) );

  (*$ENDIF*)

 

  { Here's the meat. Loop through the pixels and rotate appropriately. }

  { Remember that DIBs have their origins opposite from DDBs. }

  for Y := 1 to PbmpInfoR^.biHeight do begin

  for X := 1 to PbmpInfoR^.biWidth do begin

  { Copy the pixels. }

  (*$IFDEF Win32*)

  Move(PbmpBuffer^, PbmpBufferR^, BytesPerPixel);

  Inc(PbmpBuffer, BytesPerPixel);

  Dec(PbmpBufferR, BytesPerScanLineR);

  (*$ELSE*)

  for I := 1 to BytesPerPixel do begin

  PbmpBufferR^ := PbmpBuffer^;

  Win16Inc( Pointer(PbmpBuffer), 1 );

  Win16Inc( Pointer(PbmpBufferR), 1 );

  end;

  Win16Dec( Pointer(PbmpBufferR), BytesPerScanLineR + BytesPerPixel);

  (*$ENDIF*)

  end;

  (*$IFDEF Win32*)

  { Skip the padding. }

  Inc(PbmpBuffer, PaddingBytes);

  { Go to the top of the rotated bitmap's column, but one column over. }

  Inc(PbmpBufferR, ColumnBytes + BytesPerPixel);

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBuffer), PaddingBytes );

  Win16Inc( Pointer(PbmpBufferR), ColumnBytes + BytesPerPixel );

  (*$ENDIF*)

  end;

end;

 

{ This is the body of procedure RotateBitmap90DegreesCounterClockwise. }

begin

  { Don't *ever* call GetDIBSizes! It screws up your bitmap. }



  MemoryStream := TMemoryStream.Create;

 

  {

  To do: Set the size before-hand. This will eliminate ReAlloc overhead

  for the MemoryStream. Calling GetDIBSizes would be nice, but, as mentioned

  above, it corrupts the Bitmap in some cases. Some API calls will probably

  take care of things, but I'm not going to mess with it right now.

  }

 

  { An undocumented method. Nice to have around, though. }

  ABitmap.SaveToStream(MemoryStream);

 

  { Don't need you anymore. We'll make a new one when the time comes. }

  ABitmap.Free;

 

  bmpBuffer := MemoryStream.Memory;

  { Get the offset bits. This may or may not include palette information. }

  BitmapOffset := PBitmapFileHeader(bmpBuffer)^.bfOffBits;

 

  { Set PbmpInfoR to point to the source bitmap's info header. }

  { Boy, these headers are getting annoying. }

  (*$IFDEF Win32*)

  Inc( bmpBuffer, SizeOf(TBitmapFileHeader) );

  (*$ELSE*)

  Win16Inc( Pointer(bmpBuffer), SizeOf(TBitmapFileHeader) );

  (*$ENDIF*)

  PbmpInfoR := PBitmapInfoHeader(bmpBuffer);

 

  { Set bmpBuffer and PbmpBuffer to point to the original bitmap bits. }

  bmpBuffer := MemoryStream.Memory;

  (*$IFDEF Win32*)

  Inc(bmpBuffer, BitmapOffset);

  (*$ELSE*)

  Win16Inc( Pointer(bmpBuffer), BitmapOffset );

  (*$ENDIF*)

  PbmpBuffer := bmpBuffer;

 

  {

  Note that we don't need to worry about version 4 vs. version 3 bitmaps,

  because the fields we use -- namely biWidth, biHeight, and biBitCount --

  occur in exactly the same place in both structs. So we're a bit lucky. OS/2

  bitmaps, by the way, cause this to crash heinously. Sorry.

  }

  with PbmpInfoR^ do begin

  { ShowMessage('Compression := ' + IntToStr(biCompression)); }

  BitCount := biBitCount;

  { ShowMessage('BitCount := ' + IntToStr(BitCount)); }

 

  { ScanLines are DWORD aligned. }

  BytesPerScanLine := ((((biWidth * BitCount) + 31) div 32) * SizeOf(DWORD));

  BytesPerScanLineR := ((((biHeight * BitCount) + 31) div 32) * SizeOf(DWORD));



  AtLeastEightBitColor := BitCount >= BitsPerByte;

  if AtLeastEightBitColor then begin

  { Don't have to worry about bit-twiddling. Cool. }

  BytesPerPixel := biBitCount shr 3;

  SignificantBytes := biWidth * BitCount shr 3;

  { Extra bytes required for DWORD aligning. }

  PaddingBytes := BytesPerScanLine - SignificantBytes;

  ColumnBytes := BytesPerScanLineR * biWidth;

  end

  else begin

  { One- or four-bit bitmap. Ugh. }

  PixelsPerByte := SizeOf(Byte) * BitsPerByte div BitCount;

  { The number of bytes entirely filled with pixel information. }

  WholeBytes := biWidth div PixelsPerByte;

  {

  Any extra bits that might partially fill a byte. For instance, a

  monochrome bitmap that is 14 pixels wide has one whole byte and a

  partial byte which has six bits actually used (the rest are garbage).

  }

  ExtraPixels := biWidth mod PixelsPerByte;

  {

  The number of extra bytes -- if any -- required to DWORD-align a

  scanline.

  }

  PaddingBytes := BytesPerScanLine - WholeBytes;

  {

  If there are extra bits (i.e., they run over into a 'partial byte'),

  then one of the padding bytes has already been accounted for.

  }

  if ExtraPixels <> 0 then Dec(PaddingBytes);

  end; { if AtLeastEightBitColor then }

 

  { The TMemoryStream that will hold the rotated bits. }

  MemoryStreamR := TMemoryStream.Create;

  {

  Set size for rotated bitmap. Might be different from source size

  due to DWORD aligning.

  }

  MemoryStreamR.SetSize(BitmapOffset + BytesPerScanLineR * biWidth);

  end; { with PbmpInfoR^ do }

 

  { Copy the headers from the source bitmap. }

  MemoryStream.Seek(0, soFromBeginning);

  MemoryStreamR.CopyFrom(MemoryStream, BitmapOffset);

 

  { Here's the buffer we're going to rotate. }

  bmpBufferR := MemoryStreamR.Memory;

  { Skip the headers, yadda yadda yadda... }

  (*$IFDEF Win32*)

  Inc(bmpBufferR, BitmapOffset);

  (*$ELSE*)

  Win16Inc( Pointer(bmpBufferR), BitmapOffset );

  (*$ENDIF*)

  PbmpBufferR := bmpBufferR;

 

  { Do it. }

  if AtLeastEightBitColor then

  IntegralByteRotate

  else

  NonIntegralByteRotate;

 

  { Done with the source bits. }

  MemoryStream.Free;

 

  { Now set PbmpInfoR to point to the rotated bitmap's info header. }

  PbmpBufferR := MemoryStreamR.Memory;

  (*$IFDEF Win32*)

  Inc( PbmpBufferR, SizeOf(TBitmapFileHeader) );

  (*$ELSE*)

  Win16Inc( Pointer(PbmpBufferR), SizeOf(TBitmapFileHeader) );

  (*$ENDIF*)

  PbmpInfoR := PBitmapInfoHeader(PbmpBufferR);

 

  { Swap the width and height of the rotated bitmap's info header. }

  with PbmpInfoR^ do begin

  T := biHeight;

  biHeight := biWidth;

  biWidth := T;

  biSizeImage := 0;

  end;

 

  ABitmap := TBitmap.Create;

 

  { Spin back to the very beginning. }

  MemoryStreamR.Seek(0, soFromBeginning);

  { Load it back into ABitmap. }

  ABitmap.LoadFromStream(MemoryStreamR);

 

  MemoryStreamR.Free;

end;


end.
