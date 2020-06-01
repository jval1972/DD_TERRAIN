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

unit ter_slider;

interface

uses
  Classes, Controls, ExtCtrls;

type
  TSliderHook = class(TObject)
  private
    fPaintBox: TPaintBox;
    fMin, fMax: double;
    fStep: double;
    fPageStep: double;
    fPosition: double;
    fOnSliderHookChange: TNotifyEvent;
    mousedown: boolean;
    paintroverX: integer;
    function PosToScreen(const apos: double): integer;
    function ScreenToPos(const ascreen: integer): double;
  protected
    procedure Changed; virtual;
    procedure SetMin(const aMin: double); virtual;
    procedure SetMax(const aMax: double); virtual;
    procedure SetStep(const aStep: double); virtual;
    procedure SetPageStep(const aPageStep: double); virtual;
    procedure SetPosition(const aPosition: double); virtual;
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); virtual;
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure PaintBoxPaint(Sender: TObject); virtual;
  public
    constructor Create(const aPaintBox: TPaintBox); virtual;
    destructor Destroy; override;
    property PaintBox: TPaintBox read fPaintBox;
    property Min: double read fMin write SetMin;
    property Max: double read fMax write SetMax;
    property Step: double read fStep write SetStep;
    property PageStep: double read fPageStep write SetPageStep;
    property Position: double read fPosition write SetPosition;
    property OnSliderHookChange: TNotifyEvent read fOnSliderHookChange write fOnSliderHookChange;
  end;

implementation

uses
  Windows, Graphics;

constructor TSliderHook.Create(const aPaintBox: TPaintBox);
begin
  Inherited Create;
  fMin := 0.0;
  fMax := 100.0;
  fStep := 1.0;
  fPageStep := 10.0;
  fPosition := 0.0;
  fPaintBox := aPaintBox;
  fPaintBox.OnMouseDown := PaintBoxMouseDown;
  fPaintBox.OnMouseMove := PaintBoxMouseMove;
  fPaintBox.OnMouseUp := PaintBoxMouseUp;
  fPaintBox.OnPaint := PaintBoxPaint;
  fPaintBox.ControlStyle := fPaintBox.ControlStyle - [csOpaque];
  fPaintBox.Invalidate;
  fOnSliderHookChange := nil;
  mousedown := False;
  paintroverX := -1;
end;

destructor TSliderHook.Destroy;
begin
  fPaintBox.OnMouseDown := nil;
  fPaintBox.OnMouseMove := nil;
  fPaintBox.OnMouseUp := nil;
  fPaintBox.OnPaint := nil;
  Inherited;
end;

procedure TSliderHook.Changed;
begin
  if Assigned(fOnSliderHookChange) then
    fOnSliderHookChange(self);
  fPaintBox.Invalidate;
end;

procedure TSliderHook.SetMin(const aMin: double);
begin
  if aMin <= fMax then
    if aMin <> fMin then
    begin
      fMin := aMin;
      if fPosition < fMin then
        fPosition := fMin;
      Changed;
    end;
end;

procedure TSliderHook.SetMax(const aMax: double);
begin
  if aMax >= fMin then
    if aMax <> fMax then
    begin
      fMax := aMax;
      if fPosition > fMax then
        fPosition := fMax;
      Changed;
    end;
end;

procedure TSliderHook.SetStep(const aStep: double);
begin
  if aStep <> fStep then
  begin
    fStep := aStep;
    Changed;
  end;
end;

procedure TSliderHook.SetPageStep(const aPageStep: double);
begin
  if aPageStep <> fPageStep then
  begin
    fPageStep := aPageStep;
    Changed;
  end;
end;

procedure TSliderHook.SetPosition(const aPosition: double);
begin
  if aPosition <> fPosition then
  begin
    fPosition := aPosition;
    Changed;
  end;
end;

function TSliderHook.PosToScreen(const apos: double): integer;
var
  r: integer;
  w: integer;
begin
  if fPaintBox.Width < 2 then
  begin
    Result := 0;
    Exit;
  end;

  if fMin >= fMax then
  begin
    Result := 0;
    Exit;
  end;

  r := fPaintBox.Height div 2;
  if r <= 0 then
    r := 1;

  w := fPaintBox.Width - 2 * r;
  if w <= 0 then
    w := 1;

  Result := r + Round(w * (apos - fMin) / (fMax - fMin));
  if Result < r then
    Result := r;
  if Result > w + r then
    Result := w + r;
end;

function TSliderHook.ScreenToPos(const ascreen: integer): double;
var
  r: integer;
  w: integer;
begin
  if fPaintBox.Width < 2 then
  begin
    Result := (fMax - fMin) / 2;
    Exit;
  end;

  if fMin >= fMax then
  begin
    Result := fMax;
    Exit;
  end;

  r := fPaintBox.Height div 2;
  if r <= 0 then
    r := 1;

  w := fPaintBox.Width - 2 * r;
  if w <= 0 then
    w := 1;

  Result := (ascreen - r) / w * (fMax - fMin) + fMin;
  if Result < fMin then
    Result := fMin;
  if Result > fMax then
    Result := fMax;
end;

procedure TSliderHook.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  paintroverX := -1;
  if Button = mbLeft then
  begin
    mousedown := True;
    Position := ScreenToPos(X);
  end
  else
    mousedown := False;
end;

procedure TSliderHook.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if mousedown then
    Position := ScreenToPos(X);
end;

procedure TSliderHook.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    if mousedown then
    begin
      mousedown := False;
      Position := ScreenToPos(X);
    end;
end;

const
  LINEHEIGHT = 6;

var
  bmLine: TBitmap;
  bmSlider: TBitmap;

procedure TSliderHook.PaintBoxPaint(Sender: TObject);
var
  xMin, xMax, xPos: integer;
  yStart, yEnd: integer;
  bm: TBitmap;
begin
  xMin := PosToScreen(fMin);
  xMax := PosToScreen(fMax);
  xPos := PosToScreen(fPosition);

  bm := TBitmap.Create;
  try
    bm.Width := fPaintBox.Width;
    bm.Height := fPaintBox.Height;
    bm.PixelFormat := pf32bit;

    bm.Transparent := True;
    bm.TransparentColor := RGB(255, 255, 0);

    bm.Canvas.Brush.Color := bm.TransparentColor;
    bm.Canvas.Brush.Style := bsSolid;
    bm.Canvas.Pen.Color := bm.TransparentColor;
    bm.Canvas.Pen.Style := psSolid;
    bm.Canvas.Pen.Width := 1;
    bm.Canvas.Rectangle(0, 0, bm.Width, bm.Height);

    yStart := (bm.Height - LINEHEIGHT) div 2;
    yEnd := yStart + LINEHEIGHT;

    bm.Canvas.StretchDraw(Rect(xMin, yStart, xMax, yEnd), bmLine);

    bm.Canvas.Draw(xPos - bmSlider.Width div 2, (bm.Height - bmSlider.Height) div 2, bmSlider);

    fPaintBox.Canvas.Draw(0, 0, bm);
  finally
    bm.Free;
  end;
end;

initialization
  bmLine := TBitmap.Create;
  bmLine.Width := 2;
  bmLine.Height := LINEHEIGHT;
  bmLine.Canvas.Pixels[0, 0] := RGB(210, 210, 210);
  bmLine.Canvas.Pixels[1, 0] := RGB(210, 210, 210);
  bmLine.Canvas.Pixels[0, 1] := RGB(111, 111, 111);
  bmLine.Canvas.Pixels[1, 1] := RGB(111, 111, 111);
  bmLine.Canvas.Pixels[0, 2] := RGB(129, 129, 129);
  bmLine.Canvas.Pixels[1, 2] := RGB(129, 129, 129);
  bmLine.Canvas.Pixels[0, 3] := RGB(159, 159, 159);
  bmLine.Canvas.Pixels[1, 3] := RGB(159, 159, 159);
  bmLine.Canvas.Pixels[0, 4] := RGB(179, 179, 179);
  bmLine.Canvas.Pixels[1, 4] := RGB(179, 179, 179);
  bmLine.Canvas.Pixels[0, 5] := RGB(229, 229, 229);
  bmLine.Canvas.Pixels[1, 5] := RGB(229, 229, 229);

  bmSlider := TBitmap.Create;
  bmSlider.Width := 10;
  bmSlider.Height := 10;
  bmSlider.Transparent := True;
  bmSlider.TransparentColor := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[0, 0] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[0, 1] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[0, 2] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[0, 3] := RGB(117, 117, 117);
  bmSlider.Canvas.Pixels[0, 4] := RGB(101, 101, 101);
  bmSlider.Canvas.Pixels[0, 5] := RGB(101, 101, 101);
  bmSlider.Canvas.Pixels[0, 6] := RGB(117, 117, 117);
  bmSlider.Canvas.Pixels[0, 7] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[0, 8] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[0, 9] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[1, 0] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[1, 1] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[1, 2] := RGB(114, 113, 114);
  bmSlider.Canvas.Pixels[1, 3] := RGB(183, 183, 183);
  bmSlider.Canvas.Pixels[1, 4] := RGB(219, 218, 219);
  bmSlider.Canvas.Pixels[1, 5] := RGB(219, 218, 219);
  bmSlider.Canvas.Pixels[1, 6] := RGB(183, 183, 183);
  bmSlider.Canvas.Pixels[1, 7] := RGB(114, 113, 114);
  bmSlider.Canvas.Pixels[1, 8] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[1, 9] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[2, 0] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[2, 1] := RGB(130, 129, 129);
  bmSlider.Canvas.Pixels[2, 2] := RGB(200, 198, 199);
  bmSlider.Canvas.Pixels[2, 3] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[2, 4] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[2, 5] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[2, 6] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[2, 7] := RGB(200, 198, 199);
  bmSlider.Canvas.Pixels[2, 8] := RGB(130, 129, 129);
  bmSlider.Canvas.Pixels[2, 9] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[3, 0] := RGB(132, 132, 132);
  bmSlider.Canvas.Pixels[3, 1] := RGB(173, 172, 172);
  bmSlider.Canvas.Pixels[3, 2] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[3, 3] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[3, 4] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[3, 5] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[3, 6] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[3, 7] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[3, 8] := RGB(173, 172, 172);
  bmSlider.Canvas.Pixels[3, 9] := RGB(132, 132, 132);
  bmSlider.Canvas.Pixels[4, 0] := RGB(111, 111, 111);
  bmSlider.Canvas.Pixels[4, 1] := RGB(197, 195, 196);
  bmSlider.Canvas.Pixels[4, 2] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[4, 3] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[4, 4] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[4, 5] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[4, 6] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[4, 7] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[4, 8] := RGB(197, 195, 196);
  bmSlider.Canvas.Pixels[4, 9] := RGB(111, 111, 111);
  bmSlider.Canvas.Pixels[5, 0] := RGB(111, 111, 111);
  bmSlider.Canvas.Pixels[5, 1] := RGB(197, 195, 196);
  bmSlider.Canvas.Pixels[5, 2] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[5, 3] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[5, 4] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[5, 5] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[5, 6] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[5, 7] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[5, 8] := RGB(197, 195, 196);
  bmSlider.Canvas.Pixels[5, 9] := RGB(111, 111, 111);
  bmSlider.Canvas.Pixels[6, 0] := RGB(132, 132, 132);
  bmSlider.Canvas.Pixels[6, 1] := RGB(173, 172, 172);
  bmSlider.Canvas.Pixels[6, 2] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[6, 3] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[6, 4] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[6, 5] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[6, 6] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[6, 7] := RGB(212, 210, 211);
  bmSlider.Canvas.Pixels[6, 8] := RGB(173, 172, 172);
  bmSlider.Canvas.Pixels[6, 9] := RGB(132, 132, 132);
  bmSlider.Canvas.Pixels[7, 0] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[7, 1] := RGB(130, 129, 129);
  bmSlider.Canvas.Pixels[7, 2] := RGB(200, 198, 199);
  bmSlider.Canvas.Pixels[7, 3] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[7, 4] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[7, 5] := RGB(225, 224, 225);
  bmSlider.Canvas.Pixels[7, 6] := RGB(218, 217, 218);
  bmSlider.Canvas.Pixels[7, 7] := RGB(200, 198, 199);
  bmSlider.Canvas.Pixels[7, 8] := RGB(130, 129, 129);
  bmSlider.Canvas.Pixels[7, 9] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[8, 0] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[8, 1] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[8, 2] := RGB(114, 113, 114);
  bmSlider.Canvas.Pixels[8, 3] := RGB(183, 183, 183);
  bmSlider.Canvas.Pixels[8, 4] := RGB(219, 218, 219);
  bmSlider.Canvas.Pixels[8, 5] := RGB(219, 218, 219);
  bmSlider.Canvas.Pixels[8, 6] := RGB(183, 183, 183);
  bmSlider.Canvas.Pixels[8, 7] := RGB(114, 113, 114);
  bmSlider.Canvas.Pixels[8, 8] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[8, 9] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[9, 0] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[9, 1] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[9, 2] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[9, 3] := RGB(117, 117, 117);
  bmSlider.Canvas.Pixels[9, 4] := RGB(101, 101, 101);
  bmSlider.Canvas.Pixels[9, 5] := RGB(101, 101, 101);
  bmSlider.Canvas.Pixels[9, 6] := RGB(117, 117, 117);
  bmSlider.Canvas.Pixels[9, 7] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[9, 8] := RGB(255, 255, 0);
  bmSlider.Canvas.Pixels[9, 9] := RGB(255, 255, 0);

finalization
  bmLine.Free;
  bmSlider.Free;

end.
