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

unit ter_undo;

interface

uses Windows, SysUtils, Classes, ter_binary, zLibPas;

type
  TStreamType = (sstMemory, sstFile);

  PStreamStackNode = ^TStreamStackNode;
  TStreamStackNode = record
    data: TStream;
    PathToStream: string;
    next,
    pred: PStreamStackNode;
  end;

  PBaseStack = ^TBaseStack;
  TBaseStack = class(TObject)
  private
    Compressor: TBinaryData;
    fStreamType: TStreamType;
  protected
    top: PStreamStackNode;
    function GetCompressionLevel: TCompressionLevel; virtual;
    procedure SetCompressionLevel(Value: TCompressionLevel); virtual;
    function GetNewTmpPath: string; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Empty: boolean;
    procedure Push(s: TMemoryStream); virtual;
    procedure Pop(var s: TMemoryStream); overload; virtual;
    function Pop: TMemoryStream; overload; virtual;
    procedure Clear; virtual;
    property CompressionLevel: TCompressionLevel read GetCompressionLevel write SetCompressionLevel;
    property StreamType: TStreamType read fStreamType write fStreamType default sstMemory;
  end;

  TLimitedSizeStack = class(TBaseStack)
  protected
    bottom: PStreamStackNode;
    numItems: word;
    fUndoLimit: word;
    function GetUndoLimit: word; virtual;
    procedure SetUndoLimit(Value: word); virtual;
  public
    constructor Create; override;
    procedure Push(s: TMemoryStream); override;
    procedure Pop(var s: TMemoryStream); overload; override;
    procedure Clear; override;
    property UndoLimit: word read GetUndoLimit write SetUndoLimit default 100;
  end;

  PRedoStack = ^TRedoStack;
  TRedoStack = TBaseStack;

  PUndoStack = ^TUndoStack;
  TUndoStack = TLimitedSizeStack;

  TOnStreamOperationEvent = procedure (s: TStream) of object;

  TUndoRedoManager = class(TObject)
  private
    UndoStack: TUndoStack;
    RedoStack: TRedoStack;
    FOnSaveToStream,
    FOnLoadFromStream: TOnStreamOperationEvent;
  protected
    function GetCompressionLevel: TCompressionLevel; virtual;
    procedure SetCompressionLevel(Value: TCompressionLevel); virtual;
    procedure SaveDataToStream(s: TStream); virtual;
    procedure LoadDataFromStream(s: TStream); virtual;
    function GetUndoLimit: word; virtual;
    procedure SetUndoLimit(Value: word); virtual;
    function GetStreamType: TStreamType; virtual;
    procedure SetStreamType(Value: TStreamType); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Undo; virtual;
    procedure Redo; virtual;
    function CanUndo: boolean; virtual;
    function CanRedo: boolean; virtual;
    procedure SaveUndo; virtual;
  published
    property CompressionLevel: TCompressionLevel read GetCOmpressionLevel write SetCompressionLevel;
    property OnLoadFromStream: TOnStreamOperationEvent read FOnLoadFromStream write FOnLoadFromStream;
    property OnSaveToStream: TOnStreamOperationEvent read FOnSaveToStream write FOnSaveToStream;
    property UndoLimit: word read GetUndoLimit write SetUndoLimit default 10;
    property StreamType: TStreamType read GetStreamType write SetStreamType default sstMemory;
  end;

procedure ClearMemoryStream(m: TMemoryStream);

procedure ClearFileStream(f: TFileStream; const Path: string);

implementation

resourceString
  rsUndo = 'UNDO';
  rsInternalError = 'Multiple Undo-Redo Manager: Internal Error!';

procedure ClearMemoryStream(m: TMemoryStream);
begin
  if m <> nil then
  begin
    m.Size := 0;
    m.Free;
  end;
end;

procedure ClearFileStream(f: TFileStream; const Path: string);
begin
  if f <> nil then
    f.Free;
  if FileExists(Path) then
    if Path <> '' then
      DeleteFile(Path);
end;

procedure ClearStreamStackNode(node: PStreamStackNode);
begin
  if node <> nil then
  begin
    if node.data is TFileStream then
      ClearFileStream(node.data as TFileStream, node.PathToStream)
    else if node.data is TMemoryStream then
      ClearMemoryStream(node.data as TMemoryStream);
  if FileExists(node.PathToStream) then
    if node.PathToStream <> '' then
      DeleteFile(node.PathToStream);
  end;
end;

{*** TBaseStack ***}

constructor TBaseStack.Create;
begin
  Inherited;
  top := nil;
  Compressor := TBinaryData.Create;
  CompressionLevel := clNone;
  fStreamType := sstMemory;
end;

function TBaseStack.Empty;
begin
  Empty := (top=nil)
end;

function TBaseStack.GetNewTmpPath: string;
var
  FPath,
  s: array[0..1023] of char;
begin
  result := '';
  FillChar(s, SizeOf(s), Chr(0));
  FillChar(FPath, SizeOf(FPath), Chr(0));
  if GetTempPath(1023, FPath) <> 0 then
    if GetTempFileName(FPath, PChar(rsUndo), 0, s) <> 0 then
      result := s;
end;

procedure TBaseStack.Push(s: TMemoryStream);
var
  temp: PStreamStackNode;
begin
  new(temp);
  if fStreamType = sstFile then
  begin
    temp^.PathToStream := GetNewTmpPath;
    if temp^.PathToStream <> '' then
      temp^.data := TFileStream.Create(temp^.PathToStream, fmCreate or fmOpenReadWrite)
    else
      fStreamType := sstMemory
  end;
  if fStreamType = sstMemory then
  begin
    temp^.data := TMemoryStream.Create;
    temp^.PathToStream := '';
  end;
  s.Seek(0, soFromBeginning);
  Compressor.LoadFromStream(s, false);
  Compressor.SaveToStream(temp^.data, true);
// If we use files to store undo operation we release the file handle,
// we keep information to PathToStream
  if fStreamType = sstFile then
  begin
    temp^.data.Free;
    temp^.data := nil;
  end;
  Compressor.Clear;
  temp^.next := nil;
  temp^.pred := top;
  if top <> nil then top^.next := temp;
  top := temp;
end;

procedure TBaseStack.Pop(var s: TMemoryStream);
var
  temp: PStreamStackNode;
begin
  if not Empty then
  begin
    if s = nil then s := TMemoryStream.Create;
// If s = nil we have a file, so we create the file handle from PathToStream
    if top^.data = nil then
    begin
      if top^.PathToStream <> '' then
        top^.data := TFileStream.Create(top^.PathToStream, fmOpenRead or fmShareDenyWrite)
      else
        raise Exception.Create(rsInternalError);
    end;
    top^.data.Seek(0, soFromBeginning);
    Compressor.LoadFromStream(top^.data, true);
    s.Seek(0, soFromBeginning);
    Compressor.SaveToStream(s, false);
    s.Seek(0, soFromBeginning);
    Compressor.Clear;
    ClearStreamStackNode(top);
    temp := top;
    top := top^.pred;
    dispose(temp);
    if top <> nil then top^.next := nil;
  end;
end;

function TBaseStack.Pop: TMemoryStream;
begin
  result := TMemoryStream.Create;
  Pop(result);
end;

procedure TBaseStack.Clear;
var
  temp: PStreamStackNode;
begin
  while not Empty do
  begin
    ClearStreamStackNode(top);
    temp := top;
    top := top^.pred;
    dispose(temp);
    if top <> nil then top^.next := nil;
  end;
end;

destructor TBaseStack.Destroy;
begin
  Clear;
  Compressor.Free;
  Inherited;
end;

function TBaseStack.GetCompressionLevel: TCompressionLevel;
begin
  result := Compressor.CompressionLevel;
end;

procedure TBaseStack.SetCompressionLevel(Value: TCompressionLevel);
begin
  Compressor.CompressionLevel := Value;
end;

{*** TLimitedSizeStack ***}

constructor TLimitedSizeStack.Create;
begin
  Inherited;
  bottom := nil;
  numItems := 0;
  fUndoLimit := 1000;
end;

function TLimitedSizeStack.GetUndoLimit: word;
begin
  result := fUndoLimit;
end;

procedure TLimitedSizeStack.SetUndoLimit(Value: word);
begin
  if Value <> fUndoLimit then
  begin
    fUndoLimit := Value;
  end;
end;

procedure TLimitedSizeStack.Push(s: TMemoryStream);
var
  wasEmpty: boolean;
  temp: PStreamStackNode;
begin
// If we reach the maximum number of undo's we reduce the stack size.
// If fUndoLimit = 0 there is no limit to the number of undo operations.
  if (numItems >= fUndoLimit) and (fUndoLimit <> 0) then
  begin
    ClearStreamStackNode(bottom);
    temp := bottom;
    bottom := bottom^.next;
    if bottom <> nil then bottom^.pred := nil;
    dispose(temp);
  end
  else
    inc(numItems);
  wasEmpty := Empty;
  Inherited;
  if wasEmpty then bottom := top;
end;

procedure TLimitedSizeStack.Pop(var s: TMemoryStream);
begin
  if not Empty then
  begin
    dec(numItems);
    Inherited;
  end;
end;

procedure TLimitedSizeStack.Clear;
begin
  Inherited;
  numItems := 0;
end;

{*** TUndoRedoManager ***}

constructor TUndoRedoManager.Create;
begin
  Inherited;
  UndoStack := TUndoStack.Create;
  RedoStack := TRedoStack.Create;
  CompressionLevel := clNone;
  StreamType := sstFile;
end;

destructor TUndoRedoManager.Destroy;
begin
  Clear;
  UndoStack.Free; UndoStack := nil;
  RedoStack.Free; RedoSTack := nil;
  Inherited;
end;

function TUndoRedoManager.GetUndoLimit: word;
begin
  if Assigned(UndoStack) then
    result := UndoStack.UndoLimit
  else
    result := 0;
end;

procedure TUndoRedoManager.SetUndoLimit(Value: word);
begin
  if Assigned(UndoStack) then
    UndoStack.UndoLimit := Value
end;

function TUndoRedoManager.GetCompressionLevel: TCompressionLevel;
begin
  result := UndoStack.CompressionLevel;
end;

procedure TUndoRedoManager.SetCompressionLevel(Value: TCompressionLevel);
begin
  UndoStack.CompressionLevel := Value;
  RedoStack.CompressionLevel := Value;
end;

procedure TUndoRedoManager.Clear;
begin
  UndoStack.Clear;
  RedoStack.Clear;
end;

procedure TUndoRedoManager.Undo;
var
  mRedo, mUndo: TMemoryStream;
begin
  if CanUndo then
  begin
    mUndo := TMemoryStream.Create;
    mRedo := TMemoryStream.Create;
    try
      SaveDataToStream(mRedo);
      RedoStack.Push(mRedo);
      UndoStack.Pop(mUndo);
      LoadDataFromStream(mUndo);
    finally
      ClearMemoryStream(mUndo);
      ClearMemoryStream(mRedo);
    end;
  end;
end;

procedure TUndoRedoManager.Redo;
var
  mRedo, mUndo: TMemoryStream;
begin
  if CanRedo then
  begin
    mUndo := TMemoryStream.Create;
    mRedo := TMemoryStream.Create;
    try
      SaveDataToStream(mUndo);
      UndoStack.Push(mUndo);
      RedoStack.Pop(mRedo);
      LoadDataFromStream(mRedo);
    finally
      ClearMemoryStream(mUndo);
      ClearMemoryStream(mRedo);
    end;
  end;
end;

function TUndoRedoManager.GetStreamType: TStreamType;
begin
  result := UndoStack.StreamType;
end;

procedure TUndoRedoManager.SetStreamType(Value: TStreamType);
begin
  UndoStack.StreamType := Value;
  RedoStack.StreamType := Value;
end;

function TUndoRedoManager.CanUndo: boolean;
begin
  result := not UndoStack.Empty
end;

function TUndoRedoManager.CanRedo: boolean;
begin
  result := not RedoStack.Empty
end;

procedure TUndoRedoManager.SaveUndo;
var
  m: TMemoryStream;
begin
  m := TMemoryStream.Create;
  try
    SaveDataToStream(m);
    UndoStack.Push(m);
  finally
    ClearMemoryStream(m);
  end;
  RedoStack.Clear;
end;

procedure TUndoRedoManager.SaveDataToStream(s: TStream);
begin
  if Assigned(FOnSaveToStream) then FOnSaveToStream(s);
end;

procedure TUndoRedoManager.LoadDataFromStream(s: TStream);
begin
  if Assigned(FOnLoadFromStream) then FOnLoadFromStream(s);
end;

end.

