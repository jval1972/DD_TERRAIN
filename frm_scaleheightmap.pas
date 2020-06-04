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
//  Scale heightmap Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit frm_scaleheightmap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, ter_class;

type
  TScaleHeightmapItemForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    OKButton: TButton;
    CancelButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MulEdit: TEdit;
    DivEdit: TEdit;
    AddEdit: TEdit;
    procedure SpinEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MulEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DivEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AddEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetScaleHeightmapInfo(var amul, adiv, aadd: integer): boolean;

implementation

{$R *.dfm}

function GetScaleHeightmapInfo(var amul, adiv, aadd: integer): boolean;
var
  f: TScaleHeightmapItemForm;
begin
  Result := False;
  f := TScaleHeightmapItemForm.Create(nil);
  try
    f.MulEdit.Text := IntToStr(amul);
    f.DivEdit.Text := IntToStr(adiv);
    f.AddEdit.Text := IntToStr(aadd);
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      amul := StrToIntDef(f.MulEdit.Text, 1);
      adiv := StrToIntDef(f.DivEdit.Text, 1);
      if adiv = 0 then
        adiv := 1;
      aadd := StrToIntDef(f.AddEdit.Text, 0);
      Result := True;
    end;
  finally
    f.Free;
  end;
end;

procedure TScaleHeightmapItemForm.SpinEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  ch: char;
begin
  ch := Chr(Key);
  if not (ch in [#8, '0'..'9']) then
  begin
    Key := 0;
    Exit;
  end;
end;

procedure TScaleHeightmapItemForm.MulEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  ch: char;
begin
  ch := Chr(Key);
  if not (ch in [#8, '0'..'9']) then
  begin
    Key := 0;
    Exit;
  end;
end;

procedure TScaleHeightmapItemForm.DivEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  ch: char;
begin
  ch := Chr(Key);
  if not (ch in [#8, '0'..'9']) then
  begin
    Key := 0;
    Exit;
  end;
end;

procedure TScaleHeightmapItemForm.AddEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  ch: char;
  p: integer;
begin
  ch := Chr(Key);
  p := Pos(AddEdit.Text, '-');
  if p = 0 then
  begin
    if not (ch in ['-', #8, '0'..'9']) then
    begin
      Key := 0;
      Exit;
    end;
  end
  else
  begin
    if not (ch in [#8, '0'..'9']) then
    begin
      Key := 0;
      Exit;
    end;
  end
end;

end.
