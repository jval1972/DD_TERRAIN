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
// DESCRIPTION:
//  Edit heightmap item Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit frm_editheightmapitem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, ter_class;

type
  TEditHeightmapItemForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    OKButton: TButton;
    CancelButton: TButton;
    Label1: TLabel;
    HeightSpinEdit: TSpinEdit;
    Label2: TLabel;
    DXSpinEdit: TSpinEdit;
    Label3: TLabel;
    DYSpinEdit: TSpinEdit;
    StretchCheckBox: TCheckBox;
    procedure SpinEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetItemHeight: integer;
    procedure SetItemHeight(const h: integer);
    function GetDX: integer;
    procedure SetDX(const dx: integer);
    function GetDY: integer;
    procedure SetDY(const dy: integer);
    function GetStretchTexture: boolean;
    procedure SetStretchTexture(const b: boolean);
  end;

function EditHeightmapItem(var it: heightbufferitem_t): boolean;

implementation

{$R *.dfm}

function EditHeightmapItem(var it: heightbufferitem_t): boolean;
var
  f: TEditHeightmapItemForm;
begin
  Result := False;
  f := TEditHeightmapItemForm.Create(nil);
  try
    f.HeightSpinEdit.MinValue := -HEIGHTMAPRANGE;
    f.HeightSpinEdit.MaxValue := HEIGHTMAPRANGE;
    f.DXSpinEdit.MinValue := -1024;
    f.DXSpinEdit.MaxValue := 1024;
    f.DYSpinEdit.MinValue := -1024;
    f.DYSpinEdit.MaxValue := 1024;
    f.SetItemHeight(it.height);
    f.SetDX(it.dx);
    f.SetDY(it.dy);
    f.SetStretchTexture(it.flags and HMF_STRETCHTEXTURE <> 0);
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      it.height := f.GetItemHeight;
      it.dx := f.GetDX;
      it.dy := f.GetDY;
      it.flags := 0;
      if f.GetStretchTexture then
        it.flags := it.flags or HMF_STRETCHTEXTURE;
      Result := True;
    end;
  finally
    f.Free;
  end;
end;

function TEditHeightmapItemForm.GetItemHeight: integer;
begin
  Result := HeightSpinEdit.Value;
end;

procedure TEditHeightmapItemForm.SetItemHeight(const h: integer);
begin
  HeightSpinEdit.Value := h;
end;

function TEditHeightmapItemForm.GetDX: integer;
begin
  Result := DXSpinEdit.Value;
end;

procedure TEditHeightmapItemForm.SetDX(const dx: integer);
begin
  DXSpinEdit.Value := dx;
end;

function TEditHeightmapItemForm.GetDY: integer;
begin
  Result := DYSpinEdit.Value;
end;

procedure TEditHeightmapItemForm.SetDY(const dy: integer);
begin
  DYSpinEdit.Value := dy;
end;

function TEditHeightmapItemForm.GetStretchTexture: boolean;
begin
  Result := StretchCheckBox.Checked;
end;

procedure TEditHeightmapItemForm.SetStretchTexture(const b: boolean);
begin
  StretchCheckBox.Checked := b;
end;

procedure TEditHeightmapItemForm.SpinEditKeyDown(Sender: TObject;
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

procedure TEditHeightmapItemForm.FormCreate(Sender: TObject);
begin
  StretchCheckBox.Visible := False; // Set to false, since Doom engine does not support this
end;

end.
