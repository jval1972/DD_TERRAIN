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
//  Quantize Color Buffer
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_quantize;

interface

uses
  Windows,
  ter_utils,
  SysUtils,
  Graphics;

procedure ter_quantizebitmap(const bm: TBitmap; const numcolors: integer = 256);

implementation

// Color quantization algorythm from https://rosettacode.org
type
  oct_node_p = ^oct_node_t;
  oct_node_t = record
    /// sum of all colors represented by this node. 64 bit in case of HUGE image */
    r, g, b: int64;
    count, heap_idx: integer;
    kids: array[0..7] of oct_node_p;
    parent: oct_node_p;
    n_kids, kid_idx, flags, depth: byte;
  end;
  oct_node_a = array[0..2047] of oct_node_t;
  oct_node_pa = ^oct_node_a;
  oct_node_ap = array[0..2047] of oct_node_p;
  oct_node_pp = ^oct_node_ap;

type
  node_heap_p = ^node_heap_t;
  node_heap_t = record
	  alloc, n: integer;
	  buf: oct_node_pp;
  end;

// cmp function that decides the ordering in the heap.  This is how we determine
// which octree node to fold next, the heart of the algorithm.
function cmp_node(const a, b: oct_node_p): integer;
var
  ac, bc: integer;
begin
  if a.n_kids < b.n_kids then
  begin
    Result := -1;
    Exit;
  end;
  if a.n_kids > b.n_kids then
  begin
    Result := 1;
    Exit;
  end;

  ac := a.count * (1 + a.kid_idx) shr a.depth;
  bc := b.count * (1 + b.kid_idx) shr b.depth;
  if ac < bc then
    Result := -1 else
  if ac > bc then
    Result := 1
  else
    Result := 0;
end;

procedure down_heap(h: node_heap_p; p: oct_node_p);
var
  n, m: integer;
begin
	n := p.heap_idx;
	while true do
  begin
		m := n * 2;
		if m >= h.n then
      break;
		if (m + 1 < h.n) and (cmp_node(h.buf[m], h.buf[m + 1]) > 0) then
      inc(m);

		if cmp_node(p, h.buf[m]) <= 0 then
      Break;

		h.buf[n] := h.buf[m];
		h.buf[n].heap_idx := n;
		n := m;
	end;
	h.buf[n] := p;
	p.heap_idx := n;
end;

procedure up_heap(h: node_heap_p; p: oct_node_p);
var
  n: integer;
  prev: oct_node_p;
begin
	n := p.heap_idx;

	while n > 1 do
  begin
		prev := h.buf[n div 2];
		if cmp_node(p, prev) >= 0 then
      Break;

		h.buf[n] := prev;
		prev.heap_idx := n;
		n := n div 2;
	end;
	h.buf[n] := p;
	p.heap_idx := n;
end;

const
  ON_INHEAP = 1;

procedure heap_add(h: node_heap_p; p: oct_node_p);
begin
	if p.flags and ON_INHEAP <> 0 then
  begin
		down_heap(h, p);
		up_heap(h, p);
		Exit;
	end;

	p.flags := p.flags or ON_INHEAP;
	if h.n = 0 then
    h.n := 1;
	if h.n >= h.alloc then
  begin
		while h.n >= h.alloc do
      h.alloc := h.alloc + 1024;
    ReallocMem(h.buf, SizeOf(oct_node_p) * h.alloc);
	end;

	p.heap_idx := h.n;
	h.buf[h.n] := p;
  inc(h.n);
	up_heap(h, p);
end;

function pop_heap(h: node_heap_p): oct_node_p;
begin
	if h.n <= 1 then
  begin
    Result := nil;
    Exit;
   end;

	Result := h.buf[1];
  dec(h.n);
	h.buf[1] := h.buf[h.n];

	h.buf[h.n] := nil;

	h.buf[1].heap_idx := 1;
	down_heap(h, h.buf[1]);
end;

var
  pool: oct_node_p = nil;
  nodeslen: integer = 0;

function node_new(const idx, depth: byte; p: oct_node_p): oct_node_p;
var
  x: oct_node_p;
begin
	if nodeslen <= 1 then
  begin
		GetMem(x, SizeOf(oct_node_t) * 2048);
    ZeroMemory(x, SizeOf(oct_node_t) * 2048);
		x.parent := pool;
		pool := x;
		nodeslen := 2048;
	end;

  dec(nodeslen);
  x := @(oct_node_pa(pool)[nodeslen]);
	x.kid_idx := idx;
	x.depth := depth;
	x.parent := p;
	if p <> nil then inc(p.n_kids);
	Result := x;
end;

function bitvalue(const x: integer): byte;
begin
  if x <> 0 then
    Result := 1
  else
    Result := 0;
end;

// adding a color triple to octree
function node_insert(root: oct_node_p; const pix: LongWord): oct_node_p;
const
  // 8: number of significant bits used for tree.  It's probably good enough
  // for most images to use a value of 5.  This affects how many nodes eventually
  // end up in the tree and heap, thus smaller values helps with both speed
  // and memory.
  OCT_DEPTH = 8;
var
  i, bit: byte;
  depth: integer;
  r, g, b: byte;
begin
  r := GetRValue(pix);
  g := GetGValue(pix);
  b := GetBValue(pix);
  bit := 1 shl 7;
  for depth := 0 to OCT_DEPTH - 1 do
  begin
    i := (1 - bitvalue(g and bit)) * 4 + (1 - bitvalue(r and bit)) * 2 + (1 - bitvalue(b and bit));
    if root.kids[i] = nil then
      root.kids[i] := node_new(i, depth, root);

    root := root.kids[i];
    bit := bit shr 1;
  end;

  root.r := root.r + r;
  root.g := root.g + g;
  root.b := root.b + b;
  inc(root.count);
  Result := root;
end;

// remove a node in octree and add its count and colors to parent node.
function node_fold(p: oct_node_p): oct_node_p;
var
  q: oct_node_p;
begin
  if p.n_kids > 0 then
  begin
    Result := nil;
    Exit;
  end;
  q := p.parent;
  q.count := q.count + p.count;

  q.r := q.r + p.r;
  q.g := q.g + p.g;
  q.b := q.b + p.b;
  dec(q.n_kids);
  q.kids[p.kid_idx] := nil;
  Result := q;
end;

// traverse the octree just like construction, but this time we replace the pixel
//   color with color stored in the tree node */
function get_color_quantized(root: oct_node_p; const c: LongWord; const allowzero: boolean): LongWord;
var
  i, bit: byte;
  r, g, b: byte;
begin
  r := GetRValue(c);
  g := GetGValue(c);
  b := GetBValue(c);
  bit := 1 shl 7;
  while bit <> 0 do
  begin
    i := (1 - bitvalue(g and bit)) * 4 + (1 - bitvalue(r and bit)) * 2 + (1 - bitvalue(b and bit));
    if root.kids[i] = nil then
      Break;
    root := root.kids[i];
    bit := bit shr 1;
  end;

  r := root.r;
  g := root.g;
  b := root.b;
  Result := RGB(r, g, b);
  if not allowzero then
    if Result = 0 then
      Result := $1;
end;

procedure get_color_entries(root: oct_node_p; const c: LongWord; const lst: TDNumberList;
  const allowzero: boolean);
var
  cn: LongWord;
begin
  cn := get_color_quantized(root, c, allowzero);
  if lst.IndexOf(cn) < 0 then
    lst.Add(cn);
end;

procedure node_free;
var
	p: oct_node_p;
begin
	while pool <> nil do
  begin
		p := pool.parent;
		FreeMem(pool);
		pool := p;
	end;
end;

// Building an octree and keep leaf nodes in a bin heap.  Afterwards remove first node
// in heap and fold it into its parent node (which may now be added to heap), until heap
// contains required number of colors.
procedure color_quantize_list(im: PLongWordArray; const imsize: integer; const n_colors: integer;
  const lst: TDNumberList; const allowzero: boolean);
var
  i: integer;
  heap: node_heap_t;
  got, root: oct_node_p;
  dd: double;
begin
  heap.alloc := 0;
  heap.n := 0;
  heap.buf := nil;

  root := node_new(0, 0, nil);
  for i := 0 to imsize - 1 do
    heap_add(@heap, node_insert(root, im[i]));

  while heap.n > n_colors + 1 do
    heap_add(@heap, node_fold(pop_heap(@heap)));

  for i := 1 to heap.n - 1 do
  begin
    got := heap.buf[i];
    dd := got.count;
    got.r := Round(got.r / dd);
    got.g := Round(got.g / dd);
    got.b := Round(got.b / dd);
    if got.r < 0 then got.r := 0 else if got.r > 255 then got.r := 255;
    if got.g < 0 then got.g := 0 else if got.g > 255 then got.g := 255;
    if got.b < 0 then got.b := 0 else if got.b > 255 then got.b := 255;
  end;

  for i := 0 to imsize - 1 do
    get_color_entries(root, im[i], lst, allowzero);

  node_free;
  FreeMem(heap.buf);
end;

procedure color_quantize_image(im: PLongWordArray; const imsize: integer;
  const n_colors: integer; const allowzero: boolean);
var
  i: integer;
  heap: node_heap_t;
  got, root: oct_node_p;
  dd: double;
begin
  heap.alloc := 0;
  heap.n := 0;
  heap.buf := nil;

  root := node_new(0, 0, nil);
  for i := 0 to imsize - 1 do
    heap_add(@heap, node_insert(root, im[i]));

  while heap.n > n_colors + 1 do
    heap_add(@heap, node_fold(pop_heap(@heap)));

  for i := 1 to heap.n - 1 do
  begin
    got := heap.buf[i];
    dd := got.count;
    got.r := Round(got.r / dd);
    got.g := Round(got.g / dd);
    got.b := Round(got.b / dd);
    if got.r < 0 then got.r := 0 else if got.r > 255 then got.r := 255;
    if got.g < 0 then got.g := 0 else if got.g > 255 then got.g := 255;
    if got.b < 0 then got.b := 0 else if got.b > 255 then got.b := 255;
  end;

  for i := 0 to imsize - 1 do
    im[i] := get_color_quantized(root, im[i], allowzero);

  node_free;
  FreeMem(heap.buf);
end;

procedure ter_quantizebitmap(const bm: TBitmap; const numcolors: integer = 256);
var
  x, y: integer;
  imgsize: integer;
  L, imgdata: PLongWordArray;
begin
  imgsize := bm.Width * bm.Height;

  GetMem(imgdata, imgsize * SizeOf(LongWord));

  bm.PixelFormat := pf32bit;

  imgsize := 0;
  for y := 0 to bm.Height - 1 do
  begin
    L := bm.ScanLine[y];
    for x := 0 to bm.Width - 1 do
    begin
      imgdata[imgsize] := L[x];
      inc(imgsize);
    end;
  end;

  color_quantize_image(imgdata, imgsize, numcolors, True);

  imgsize := 0;
  for y := 0 to bm.Height - 1 do
  begin
    L := bm.ScanLine[y];
    for x := 0 to bm.Width - 1 do
    begin
      L[x] := imgdata[imgsize];
      inc(imgsize);
    end;
  end;

  FreeMem(imgdata, imgsize * SizeOf(LongWord));
end;

end.

