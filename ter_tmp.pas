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
//   Temporary files managment
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit ter_tmp;

interface

function I_NewTempFile(const name: string): string;

procedure I_DeclareTempFile(const fname: string);

implementation

uses
  Windows, Classes, SysUtils;

var
  tempfiles: TStringList;

procedure I_InitTempFiles;
begin
  tempfiles := TStringList.Create;
end;

procedure I_ShutDownTempFiles;
var
  i: integer;
begin
{$I-}
  for i := 0 to tempfiles.Count - 1 do
    DeleteFile(tempfiles.Strings[i]);
{$I+}
  tempfiles.Free;
end;

function I_NewTempFile(const name: string): string;
var
  buf: array[0..4095] of char;
begin
  ZeroMemory(@buf, SizeOf(buf));
  GetTempPath(SizeOf(buf), buf);
  Result :=  StrPas(buf) + '\' + ExtractFileName(name);
  tempfiles.Add(Result);
end;

procedure I_DeclareTempFile(const fname: string);
begin
  tempfiles.Add(fname);
end;

initialization
  I_InitTempFiles;

finalization
  I_ShutDownTempFiles;

end.

