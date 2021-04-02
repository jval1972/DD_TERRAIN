//------------------------------------------------------------------------------
//
//  DD_TERRAIN: Terrain Generator
//  Copyright (C) 2020-2021 by Jim Valavanis
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
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit frm_zeroheightmapvalues;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls;

type
  TZeroHeightmapValuesForm = class(TForm)
    Panel1: TPanel;
    OKButton: TButton;
    CancelButton: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Z1SpinEdit: TSpinEdit;
    Z2SpinEdit: TSpinEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetZeroHeightmapValues(var z1, z2: integer): boolean;

implementation

{$R *.dfm}

uses
  ter_utils;

function GetZeroHeightmapValues(var z1, z2: integer): boolean;
var
  f: TZeroHeightmapValuesForm;
begin
  Result := False;
  f := TZeroHeightmapValuesForm.Create(nil);
  try
    f.Z1SpinEdit.Value := GetIntInRange(z1, f.Z1SpinEdit.MinValue, f.Z1SpinEdit.MaxValue);
    f.Z2SpinEdit.Value := GetIntInRange(z2, f.Z2SpinEdit.MinValue, f.Z2SpinEdit.MaxValue);
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      z1 := f.Z1SpinEdit.Value;
      z2 := f.Z2SpinEdit.Value;
      Result := True;
    end;
  finally
    f.Free;
  end;
end;

end.
