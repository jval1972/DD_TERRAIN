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

procedure SaveImageToDisk(const b: TBitmap; const imgfname: string);

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

end.
