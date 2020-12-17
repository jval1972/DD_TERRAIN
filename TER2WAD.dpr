//------------------------------------------------------------------------------
//
//  TER2WAD - Converts DD_TERRAIN terrains to WAD map
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
//  Main Programm
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

program TER2WAD;

{$APPTYPE CONSOLE}

uses
  SysUtils;

function M_CheckParam(const opt: string; const default: string): string;
var
  i: integer;
begin
  for i := 1 to ParamCount - 1 do
    if UpperCase(ParamStr(i)) = UpperCase(opt) then
    begin
      Result := ParamStr(i + 1);
      Exit;
    end;
  Result := default;
end;

function M_CheckOption(const opt: string): boolean;
var
  i: integer;
begin
  for i := 1 to ParamCount do
    if UpperCase(ParamStr(i)) = UpperCase(opt) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;


begin
end.
