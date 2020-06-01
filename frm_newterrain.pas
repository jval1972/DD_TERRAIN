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
//  New Terrain Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit frm_newterrain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TNewForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    TextureSizeRadioGroup: TRadioGroup;
    HeightmapSizeRadioGroup: TRadioGroup;
    OKButton: TButton;
    CancelButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure TextureSizeRadioGroupClick(Sender: TObject);
    procedure HeightmapSizeRadioGroupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateControls;
  public
    { Public declarations }
    function TextureSize: integer;
    procedure SetTextureSize(const tsize: integer);
    function HeightmapSize: integer;
    procedure SetHeightmapSize(const hsize: integer);
  end;

function GetNewTerrainSize(var tsize, hsize: integer): boolean;

implementation

{$R *.dfm}

uses
  ter_class;

function GetNewTerrainSize(var tsize, hsize: integer): boolean;
var
  f: TNewForm;
begin
  Result := False;
  f := TNewForm.Create(nil);
  try
    f.SetTextureSize(tsize);
    f.SetHeightmapSize(hsize);
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      tsize := f.TextureSize;
      hsize := f.HeightmapSize;
      Result := True;
    end;
  finally
    f.Free;
  end;
end;

procedure TNewForm.UpdateControls;
begin
  Label1.Caption := Format('Mesh quad size: %d', [TextureSize div (HeightmapSize - 1)]);
  Label2.Caption := Format('Resulting mesh triangles: %d', [2 * sqr(HeightmapSize - 1)]);
end;

function TNewForm.TextureSize: integer;
begin
  if TextureSizeRadioGroup.ItemIndex >= 0 then
  begin
    Result := StrToInt(TextureSizeRadioGroup.Items[TextureSizeRadioGroup.ItemIndex]);
    Exit;
  end;
  Result := 1024;
end;

procedure TNewForm.SetTextureSize(const tsize: integer);
var
  sz: integer;
begin
  sz := ter_validatetexturesize(tsize);
  TextureSizeRadioGroup.ItemIndex := TextureSizeRadioGroup.Items.IndexOf(IntToStr(sz));
end;

function TNewForm.HeightmapSize: integer;
begin
  if HeightmapSizeRadioGroup.ItemIndex >= 0 then
  begin
    Result := StrToInt(HeightmapSizeRadioGroup.Items[HeightmapSizeRadioGroup.ItemIndex]);
    Exit;
  end;
  Result := 17;
end;

procedure TNewForm.SetHeightmapSize(const hsize: integer);
var
  sz: integer;
begin
  sz := ter_validateheightmapsize(hsize);
  HeightmapSizeRadioGroup.ItemIndex := HeightmapSizeRadioGroup.Items.IndexOf(IntToStr(sz));
end;

procedure TNewForm.TextureSizeRadioGroupClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TNewForm.HeightmapSizeRadioGroupClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TNewForm.FormCreate(Sender: TObject);
begin
  UpdateControls;
end;

procedure TNewForm.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

end.
