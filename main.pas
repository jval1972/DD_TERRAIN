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
//  Main Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/DD-TERRAIN/
//------------------------------------------------------------------------------

unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xTGA, jpeg, zBitmap, ComCtrls, ExtCtrls, Buttons, Menus,
  StdCtrls, AppEvnts, ExtDlgs, clipbrd, ToolWin, dglOpenGL, ter_class, ter_undo,
  ter_filemenuhistory, ter_slider, PngImage1;

type
  drawlayeritem_t = packed record
    pass: byte;
  end;

  drawlayer_t = packed array[0..MAXTEXTURESIZE - 1, 0..MAXTEXTURESIZE - 1] of drawlayeritem_t;
  drawlayer_p = ^drawlayer_t;

type
  colorbuffer_t = array[0..MAXTEXTURESIZE - 1, 0..MAXTEXTURESIZE - 1] of LongWord;
  colorbuffer_p = ^colorbuffer_t;

const
  MAXPENSIZE = 128;

type
  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Open2: TMenuItem;
    Save1: TMenuItem;
    Savesa1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    OpenDialog1: TOpenDialog;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    Options1: TMenuItem;
    SavePictureDialog1: TSavePictureDialog;
    N4: TMenuItem;
    Export1: TMenuItem;
    ExportObjModel1: TMenuItem;
    SaveDialog1: TSaveDialog;
    N5: TMenuItem;
    N8: TMenuItem;
    Copy1: TMenuItem;
    OpenPictureDialog2: TOpenPictureDialog;
    ToolBar1: TToolBar;
    PropertiesPanel: TPanel;
    Splitter1: TSplitter;
    SaveAsButton1: TSpeedButton;
    SaveButton1: TSpeedButton;
    OpenButton1: TSpeedButton;
    NewButton1: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    UndoButton1: TSpeedButton;
    RedoButton1: TSpeedButton;
    ToolButton4: TToolButton;
    AboutButton1: TSpeedButton;
    N7: TMenuItem;
    HistoryItem0: TMenuItem;
    HistoryItem1: TMenuItem;
    HistoryItem2: TMenuItem;
    HistoryItem3: TMenuItem;
    HistoryItem4: TMenuItem;
    HistoryItem5: TMenuItem;
    HistoryItem6: TMenuItem;
    HistoryItem7: TMenuItem;
    HistoryItem8: TMenuItem;
    HistoryItem9: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ExportScreenshot1: TMenuItem;
    Wireframe1: TMenuItem;
    Renderenviroment1: TMenuItem;
    Label2: TLabel;
    SaveDialog2: TSaveDialog;
    PageControl2: TPageControl;
    TabSheet4: TTabSheet;
    PaintScrollBox: TScrollBox;
    PaintBox1: TPaintBox;
    TabSheet5: TTabSheet;
    OpenGLScrollBox: TScrollBox;
    OpenGLPanel: TPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel6: TPanel;
    Panel3: TPanel;
    Label23: TLabel;
    WADFileNameEdit: TEdit;
    SelectWADFileButton: TSpeedButton;
    Panel4: TPanel;
    OpenWADDialog: TOpenDialog;
    Panel5: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    FlatPreviewImage: TImage;
    Panel10: TPanel;
    FlatsListBox: TListBox;
    Panel11: TPanel;
    FlatSizeLabel: TLabel;
    OpacityPaintBox: TPaintBox;
    OpacityLabel: TLabel;
    Panel12: TPanel;
    PenSpeedButton1: TSpeedButton;
    PenSpeedButton2: TSpeedButton;
    PenSpeedButton3: TSpeedButton;
    Label3: TLabel;
    PenSizePaintBox: TPaintBox;
    PenSizeLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NewButton1Click(Sender: TObject);
    procedure SaveButton1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AboutButton1Click(Sender: TObject);
    procedure SaveAsButton1Click(Sender: TObject);
    procedure ExitButton1Click(Sender: TObject);
    procedure OpenButton1Click(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure OpenGLPanelResize(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure OpenGLPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OpenGLPanelDblClick(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Wireframe1Click(Sender: TObject);
    procedure TrunkImageDblClick(Sender: TObject);
    procedure TwigImageDblClick(Sender: TObject);
    procedure Renderenviroment1Click(Sender: TObject);
    procedure SeedEditKeyPress(Sender: TObject; var Key: Char);
    procedure ExportObjModel1Click(Sender: TObject);
    procedure ExportScreenshot1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SelectWADFileButtonClick(Sender: TObject);
    procedure FlatsListBoxClick(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    ffilename: string;
    fwadfilename: string;
    layer: drawlayer_p;
    colorbuffersize: integer;
    colorbuffer: colorbuffer_p;
    changed: Boolean;
    terrain: TTerrain;
    rc: HGLRC;   // Rendering Context
    dc: HDC;     // Device Context
    glpanx, glpany: integer;
    glmousedown: integer;
    undoManager: TUndoRedoManager;
    filemenuhistory: TFileMenuHistory;
    glneedsupdate: boolean;
    needsrecalc: boolean;
    fopacity: integer;
    fpensize: integer;
    foldopacity: integer;
    foldpensize: integer;
    OpacitySlider: TSliderHook;
    PenSizeSlider: TSliderHook;
    closing: boolean;
    lmousedown: boolean;
    lmousedownx, lmousedowny: integer;
    pen2hit: array[-MAXPENSIZE div 2..MAXPENSIZE div 2, -MAXPENSIZE div 2..MAXPENSIZE div 2] of integer;
    pen3hit: array[-MAXPENSIZE div 2..MAXPENSIZE div 2, -MAXPENSIZE div 2..MAXPENSIZE div 2] of integer;
    procedure Idle(Sender: TObject; var Done: Boolean);
    function CheckCanClose: boolean;
    procedure DoNewTerrain(const tsize, hsize: integer);
    procedure DoSaveTerrain(const fname: string);
    function DoLoadTerrain(const fname: string): boolean;
    procedure SetFileName(const fname: string);
    procedure DoLoadTerrainBinaryUndo(s: TStream);
    procedure DoSaveTerrainBinaryUndo(s: TStream);
    procedure SaveUndo;
    procedure UpdateStausbar;
    procedure UpdateEnable;
    procedure OnLoadTerrainFileMenuHistory(Sender: TObject; const fname: string);
    procedure DoRenderGL;
    procedure Get3dPreviewBitmap(const b: TBitmap);
    procedure SlidersToLabels;
    procedure TerrainToControls;
    procedure UpdateSliders;
    procedure UpdateFromSliders(Sender: TObject);
    procedure PopulateFlatsListBox(const wadname: string);
    procedure NotifyFlatsListBox;
    function GetWADFlatAsBitmap(const fwad: string; const flat: string): TBitmap;
    procedure LLeftMousePaintAt(const X, Y: integer);
    procedure LLeftMousePaintTo(const X, Y: integer);
    procedure CalcPenHit;
    procedure DoRefreshPaintBox(const r: TRect);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  ter_gl,
  ter_defs,
  ter_utils,
  frm_newterrain,
  ter_wadreader;

{$R *.dfm}

resourcestring
  rsTitle = 'Terrain Generator';

procedure TForm1.FormCreate(Sender: TObject);
var
  pfd: TPIXELFORMATDESCRIPTOR;
  pf: Integer;
  doCreate: boolean;
begin
  Randomize;

  DoubleBuffered := True;

  ter_LoadSettingFromFile(ChangeFileExt(ParamStr(0), '.ini'));

  fwadfilename := bigstringtostring(@opt_lastwadfile);

  closing := False;

  PageControl1.ActivePageIndex := 0;
  PageControl2.ActivePageIndex := 0;

  GetMem(layer, SizeOf(drawlayer_t));
  GetMem(colorbuffer, SizeOf(colorbuffer_t));
  FillChar(colorbuffer^, SizeOf(colorbuffer_t), 255);
  colorbuffersize := 128;

  lmousedown := false;
  lmousedownx := 0;
  lmousedowny := 0;

  fopacity := 100;
  fpensize := 64;
  foldopacity := -1;
  foldpensize := -1;

  CalcPenHit;
  
  NotifyFlatsListBox;

  undoManager := TUndoRedoManager.Create;
  undoManager.UndoLimit := 100;
  undoManager.OnLoadFromStream := DoLoadTerrainBinaryUndo;
  undoManager.OnSaveToStream := DoSaveTerrainBinaryUndo;

  filemenuhistory := TFileMenuHistory.Create(self);
  filemenuhistory.MenuItem0 := HistoryItem0;
  filemenuhistory.MenuItem1 := HistoryItem1;
  filemenuhistory.MenuItem2 := HistoryItem2;
  filemenuhistory.MenuItem3 := HistoryItem3;
  filemenuhistory.MenuItem4 := HistoryItem4;
  filemenuhistory.MenuItem5 := HistoryItem5;
  filemenuhistory.MenuItem6 := HistoryItem6;
  filemenuhistory.MenuItem7 := HistoryItem7;
  filemenuhistory.MenuItem8 := HistoryItem8;
  filemenuhistory.MenuItem9 := HistoryItem9;
  filemenuhistory.OnOpen := OnLoadTerrainFileMenuHistory;

  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory9));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory8));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory7));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory6));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory5));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory4));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory3));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory2));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory1));
  filemenuhistory.AddPath(bigstringtostring(@opt_filemenuhistory0));

  terrain := TTerrain.Create;

  Scaled := False;

  OpenGLPanel.Width := 3 * Screen.Width div 4;
  OpenGLPanel.Height := 3 * Screen.Height div 4;
  OpenGLPanel.DoubleBuffered := True;

  glpanx := 0;
  glpany := 0;
  glmousedown := 0;

  InitOpenGL;
  ReadExtensions;
  ReadImplementationProperties;

  // OpenGL initialisieren
  dc := GetDC(OpenGLPanel.Handle);

  // PixelFormat
  pfd.nSize := SizeOf(pfd);
  pfd.nVersion := 1;
  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType := PFD_TYPE_RGBA;      // PFD_TYPE_RGBA or PFD_TYPEINDEX
  pfd.cColorBits := 32;

  pf := ChoosePixelFormat(dc, @pfd);   // Returns format that most closely matches above pixel format
  SetPixelFormat(dc, pf, @pfd);

  rc := wglCreateContext(dc);    // Rendering Context = window-glCreateContext
  wglMakeCurrent(dc, rc);        // Make the DC (Form1) the rendering Context

  // Initialize GL environment variables

  glInit;

  ResetCamera;

  OpenGLPanelResize(sender);    // sets up the perspective

//  trunktexture := gld_CreateTexture(TrunkImage.Picture, False);
//  twigtexture := gld_CreateTexture(TwigImage.Picture, True);

  glneedsupdate := True;

  needsrecalc := True;

  TabSheet1.DoubleBuffered := True;

  OpacitySlider := TSliderHook.Create(OpacityPaintBox);
  OpacitySlider.Min := 1;
  OpacitySlider.Max := 100;

  PenSizeSlider := TSliderHook.Create(PenSizePaintBox);
  PenSizeSlider.Min := 1;
  PenSizeSlider.Max := MAXPENSIZE;

  doCreate := True;
  if ParamCount > 0 then
    if DoLoadTerrain(ParamStr(1)) then
      doCreate := False;

  if DoCreate then
  begin
    SetFileName('');
    DoNewTerrain(1024, 33);
    glneedsupdate := True;
    needsrecalc := True;
    undoManager.Clear;
  end;

  WADFileNameEdit.Text := ExtractFileName(fwadfilename);
  PopulateFlatsListBox(fwadfilename);

  // when the app has spare time, render the GL scene
  Application.OnIdle := Idle;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CheckCanClose;
end;

function TForm1.CheckCanClose: boolean;
var
  ret: integer;
begin
  if changed then
  begin
    ret := MessageBox(Handle, 'Do you want to save changes?', PChar(rsTitle), MB_YESNOCANCEL or MB_ICONQUESTION or MB_APPLMODAL);
    if ret = IDCANCEL	then
    begin
      Result := False;
      exit;
    end;
    if ret = IDNO	then
    begin
      Result := True;
      exit;
    end;
    if ret = IDYES then
    begin
      SaveButton1Click(self);
      Result := not changed;
      exit;
    end;
  end;
  Result := True;
end;

procedure TForm1.NewButton1Click(Sender: TObject);
var
  tsize, hsize: integer;
begin
  if not CheckCanClose then
    Exit;

  tsize := terrain.texturesize;
  hsize := terrain.heightmapsize;
  if GetNewTerrainSize(tsize, hsize) then
  begin
    DoNewTerrain(tsize, hsize);
    ResetCamera;
  end;
end;

procedure TForm1.DoNewTerrain(const tsize, hsize: integer);
begin
  SetFileName('');
  changed := False;
  terrain.Clear(tsize, hsize);
  PaintBox1.Width := tsize;
  PaintBox1.Height := tsize;
  TerrainToControls;
  glneedsupdate := True;
  needsrecalc := True;
  undoManager.Clear;
end;

procedure TForm1.SetFileName(const fname: string);
begin
  ffilename := fname;
  Caption := rsTitle;
  if ffilename <> '' then
    Caption := Caption + ' - ' + MkShortName(ffilename);
end;

procedure TForm1.SaveButton1Click(Sender: TObject);
begin
  if ffilename = '' then
  begin
    if SaveDialog1.Execute then
    begin
      ffilename := SaveDialog1.FileName;
      filemenuhistory.AddPath(ffilename);
    end
    else
    begin
      Beep;
      Exit;
    end;
  end;
  BackupFile(ffilename);
  DoSaveTerrain(ffilename);
end;

procedure TForm1.DoSaveTerrain(const fname: string);
begin
  SetFileName(fname);

  terrain.SaveToFile(fname);

  changed := False;
end;

function TForm1.DoLoadTerrain(const fname: string): boolean;
var
  s: string;
begin
  if not FileExists(fname) then
  begin
    s := Format('File %s does not exist!', [MkShortName(fname)]);
    MessageBox(Handle, PChar(s), PChar(rsTitle), MB_OK or MB_ICONEXCLAMATION or MB_APPLMODAL);
    Result := False;
    exit;
  end;

  undoManager.Clear;

  terrain.LoadFromFile(fname);
  PaintBox1.Width := terrain.texturesize;
  PaintBox1.Height := terrain.texturesize;

  TerrainToControls;
  filemenuhistory.AddPath(fname);
  SetFileName(fname);
  glneedsupdate := True;
  needsrecalc := True;
  Result := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  closing := True;
  Timer1.Enabled := False;
  undoManager.Free;
  wglMakeCurrent(0, 0);
  wglDeleteContext(rc);

  glDeleteTextures(1, @trunktexture);
  glDeleteTextures(1, @twigtexture);

  stringtobigstring(filemenuhistory.PathStringIdx(0), @opt_filemenuhistory0);
  stringtobigstring(filemenuhistory.PathStringIdx(1), @opt_filemenuhistory1);
  stringtobigstring(filemenuhistory.PathStringIdx(2), @opt_filemenuhistory2);
  stringtobigstring(filemenuhistory.PathStringIdx(3), @opt_filemenuhistory3);
  stringtobigstring(filemenuhistory.PathStringIdx(4), @opt_filemenuhistory4);
  stringtobigstring(filemenuhistory.PathStringIdx(5), @opt_filemenuhistory5);
  stringtobigstring(filemenuhistory.PathStringIdx(6), @opt_filemenuhistory6);
  stringtobigstring(filemenuhistory.PathStringIdx(7), @opt_filemenuhistory7);
  stringtobigstring(filemenuhistory.PathStringIdx(8), @opt_filemenuhistory8);
  stringtobigstring(filemenuhistory.PathStringIdx(9), @opt_filemenuhistory9);
  stringtobigstring(fwadfilename, @opt_lastwadfile);
  ter_SaveSettingsToFile(ChangeFileExt(ParamStr(0), '.ini'));

  filemenuhistory.Free;

  OpacitySlider.Free;
  PenSizeSlider.Free;
  terrain.Free;
  Freemem(layer, SizeOf(drawlayer_t));
  Freemem(colorbuffer, SizeOf(colorbuffer_t));
end;

resourcestring
  copyright = 'Copyright (c) 2020, Jim Valavanis';

procedure TForm1.AboutButton1Click(Sender: TObject);
begin
  MessageBox(
    Handle,
    PChar(Format('%s'#13#10 +
    'Version ' + I_VersionBuilt + #13#10 +
    'Copyright (c) 2020, jvalavanis@gmail.com'#13#10 +
    #13#10'A tool to create Terrains.'#13#10#13#10,
        [rsTitle])),
    PChar(rsTitle),
    MB_OK or MB_ICONINFORMATION or MB_APPLMODAL);
end;

procedure TForm1.SaveAsButton1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    filemenuhistory.AddPath(SaveDialog1.FileName);
    BackupFile(SaveDialog1.FileName);
    DoSaveTerrain(SaveDialog1.FileName);
  end;
end;

procedure TForm1.ExitButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.OpenButton1Click(Sender: TObject);
begin
  if not CheckCanClose then
    Exit;

  if OpenDialog1.Execute then
  begin
    DoLoadTerrain(OpenDialog1.FileName);
    ResetCamera;
  end;
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  r: TRect;
  z: glfloat;
begin
  pt := OpenGLPanel.Parent.ScreenToClient(MousePos);
  r := OpenGLPanel.ClientRect;
  if r.Right > OpenGLScrollBox.Width then
    r.Right := OpenGLScrollBox.Width;
  if r.Bottom > OpenGLScrollBox.Height then
    r.Bottom := OpenGLScrollBox.Height;
  if PtInRect(r, pt) then
  begin
    z := camera.z - 0.5;
    z := z / 0.99;
    camera.z := z + 0.5;
    if camera.z < -20.0 then
      camera.z := -20.0;
    glneedsupdate := True;
  end;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  r: TRect;
  z: glfloat;
begin
  pt := OpenGLPanel.Parent.ScreenToClient(MousePos);
  r := OpenGLPanel.ClientRect;
  if r.Right > OpenGLScrollBox.Width then
    r.Right := OpenGLScrollBox.Width;
  if r.Bottom > OpenGLScrollBox.Height then
    r.Bottom := OpenGLScrollBox.Height;
  if PtInRect(r, pt) then
  begin
    z := camera.z - 0.5;
    z := z * 0.99;
    camera.z := z + 0.5;
    if camera.z > 0.5 then
      camera.z := 0.5;
    glneedsupdate := True;
  end;
end;

procedure TForm1.OpenGLPanelResize(Sender: TObject);
begin
  glViewport(0, 0, OpenGLPanel.Width, OpenGLPanel.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity;                     // Reset View
  gluPerspective(45.0, OpenGLPanel.Width / OpenGLPanel.Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glneedsupdate := True;
end;

procedure TForm1.Idle(Sender: TObject; var Done: Boolean);
begin
  if closing then
    Exit;
    
  UpdateEnable;

  Done := False;

  Sleep(1);
  if needsrecalc then
    glneedsupdate := True;

  if not glneedsupdate then
    // jval: We don't need to render
    Exit;

  UpdateStausbar;

  DoRenderGL;

  glneedsupdate := False;
end;

procedure TForm1.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
  Idle(Sender, Done);
end;

procedure TForm1.OpenGLPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button in [mbLeft, mbRight] then
  begin
    glpanx := X;
    glpany := Y;
    if Button = mbLeft then
      glmousedown := 1
    else
      glmousedown := 2;
    SetCapture(OpenGLPanel.Handle);
  end;
end;

procedure TForm1.OpenGLPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  glmousedown := 0;
  ReleaseCapture;
end;

procedure TForm1.OpenGLPanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if glmousedown = 0 then
    exit;

  if glmousedown = 1 then
  begin
    camera.ay := camera.ay + (glpanx - X) ;/// OpenGLPanel.Width {* 2 * pi};
    camera.ax := camera.ax + (glpany - Y) ; // / OpenGLPanel.Height {* 2 * pi};
  end
  else
  begin
    camera.x := camera.x + (glpanx - X) / OpenGLPanel.Width * (camera.z - 1.0);/// OpenGLPanel.Width {* 2 * pi};
    if camera.x < -6.0 then
      camera.x := -6.0
    else if camera.x > 6.0 then
      camera.x := 6.0;

    camera.y := camera.y - (glpany - Y) / OpenGLPanel.Width * (camera.z - 1.0); // / OpenGLPanel.Height {* 2 * pi};
    if camera.y < -6.0 then
      camera.y := -6.0
    else if camera.y > 6.0 then
      camera.y := 6.0;
  end;

  glneedsupdate := True;

  glpanx := X;
  glpany := Y;
end;

procedure TForm1.OpenGLPanelDblClick(Sender: TObject);
begin
  ResetCamera;
  glneedsupdate := True;
end;

procedure TForm1.Edit1Click(Sender: TObject);
begin
  Undo1.Enabled := undoManager.CanUndo;
  Redo1.Enabled := undoManager.CanRedo;
end;

procedure TForm1.Undo1Click(Sender: TObject);
begin
  if undoManager.CanUndo then
  begin
    undoManager.Undo;
    glneedsupdate := True;
    needsrecalc := True;
  end;
end;

procedure TForm1.Redo1Click(Sender: TObject);
begin
  if undoManager.CanRedo then
  begin
    undoManager.Redo;
    glneedsupdate := True;
    needsrecalc := True;
  end;
end;

procedure TForm1.DoSaveTerrainBinaryUndo(s: TStream);
begin
  terrain.SaveToStream(s);
end;

procedure TForm1.DoLoadTerrainBinaryUndo(s: TStream);
begin
  terrain.LoadFromStream(s);
  TerrainToControls;
  glneedsupdate := True;
  needsrecalc := True;
end;

procedure TForm1.SaveUndo;
begin
  undoManager.SaveUndo;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  glneedsupdate := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  glneedsupdate := True;
end;

procedure TForm1.UpdateStausbar;
begin
  StatusBar1.Panels[2].Text := Format('Camera(x=%2.2f, y=%2.2f, z=%2.2f)', [camera.x, camera.y, camera.z]);
  StatusBar1.Panels[3].Text := Format('Rendered triangles = %d', [pt_rendredtriangles]);
end;

procedure TForm1.UpdateEnable;
begin
  Undo1.Enabled := undoManager.CanUndo;
  Redo1.Enabled := undoManager.CanRedo;
  UndoButton1.Enabled := undoManager.CanUndo;
  RedoButton1.Enabled := undoManager.CanRedo;
end;

procedure TForm1.OnLoadTerrainFileMenuHistory(Sender: TObject; const fname: string);
begin
  if not CheckCanClose then
    Exit;

  DoLoadTerrain(fname);
  ResetCamera;
end;

procedure TForm1.File1Click(Sender: TObject);
begin
  filemenuhistory.RefreshMenuItems;
end;

procedure TForm1.DoRenderGL;
begin
  if glneedsupdate then
  begin
    glBeginScene(OpenGLPanel.Width, OpenGLPanel.Height);
    try
      if needsrecalc then
      begin
  // generate texture      tree.generate;
        needsrecalc := False;
      end;
      glRenderEnviroment;
//      glRenderTree(tree);
    finally
      glEndScene(dc);
    end;
  end;
end;

procedure TForm1.Get3dPreviewBitmap(const b: TBitmap);
type
  long_a = array[0..$FFFF] of LongWord;
  Plong_a = ^long_a;
var
  L, buf: Plong_a;
  w, h: integer;
  i, j: integer;
  idx: integer;
begin
  w := OpenGLPanel.Width;
  h := OpenGLPanel.Height;
  b.Width := w;
  b.Height := h;
  b.PixelFormat := pf32bit;

  GetMem(L, w * h * SizeOf(LongWord));
  glReadPixels(0, 0, w, h, GL_BGRA, GL_UNSIGNED_BYTE, L);

  idx := 0;
  for j := 0 to h - 1 do
  begin
    buf := b.ScanLine[h - j - 1];
    for i := 0 to w - 1 do
    begin
      buf[i] := L[idx];
      Inc(idx);
    end;
  end;

  FreeMem(L, w * h * SizeOf(LongWord));
end;

procedure TForm1.Copy1Click(Sender: TObject);
var
  b: TBitmap;
begin
  b := TBitmap.Create;
  try
    DoRenderGL; // JVAL: For some unknown reason this must be called before glReadPixels
    Get3dPreviewBitmap(b);
    Clipboard.Assign(b);
  finally
    b.Free;
  end;
end;

procedure TForm1.Options1Click(Sender: TObject);
begin
  Renderenviroment1.Checked := opt_renderevniroment;
  Wireframe1.Checked := opt_renderwireframe;
end;

procedure TForm1.Wireframe1Click(Sender: TObject);
begin
  opt_renderwireframe := not opt_renderwireframe;
  glneedsupdate := True;
end;

procedure TForm1.TrunkImageDblClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
//    TrunkImage.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    glDeleteTextures(1, @trunktexture);
//    trunktexture := gld_CreateTexture(TrunkImage.Picture, False);
  end;
end;

procedure TForm1.TwigImageDblClick(Sender: TObject);
begin
  if OpenPictureDialog2.Execute then
  begin
//    TwigImage.Picture.LoadFromFile(OpenPictureDialog2.FileName);
    glDeleteTextures(1, @twigtexture);
//    twigtexture := gld_CreateTexture(TwigImage.Picture, True);
  end;
end;

procedure TForm1.Renderenviroment1Click(Sender: TObject);
begin
  opt_renderevniroment := not opt_renderevniroment;
  glneedsupdate := True;
end;

procedure TForm1.SeedEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in [#8, '0'..'9']) then
    Key := #0;
end;

procedure TForm1.UpdateSliders;
begin
  OpacitySlider.OnSliderHookChange := nil;
  OpacitySlider.Position := fopacity;
  OpacityPaintBox.Invalidate;
  OpacitySlider.OnSliderHookChange := UpdateFromSliders;

  PenSizeSlider.OnSliderHookChange := nil;
  PenSizeSlider.Position := fpensize;
  PenSizePaintBox.Invalidate;
  PenSizeSlider.OnSliderHookChange := UpdateFromSliders;
end;

procedure TForm1.SlidersToLabels;
begin
  OpacityLabel.Caption := Format('%d', [Round(OpacitySlider.Position)]);
  PenSizeLabel.Caption := Format('%d', [Round(PenSizeSlider.Position)]);
end;

procedure TForm1.TerrainToControls;
begin
  if closing then
    Exit;

  PaintBox1.Invalidate;
//  SeedEdit.Text := IntToStr(tree.mProperties.mSeed);
  StatusBar1.Panels[0].Text := Format('Terrain Size: %dx%d', [Terrain.texturesize, Terrain.texturesize]);
  StatusBar1.Panels[1].Text := Format('Heightmap Size: %dx%d', [Terrain.heightmapsize, Terrain.heightmapsize]);
  UpdateSliders;
  SlidersToLabels;
end;

procedure TForm1.UpdateFromSliders(Sender: TObject);
begin
  if closing then
    Exit;

  SlidersToLabels;
  fopacity := Round(OpacitySlider.Position);
  fpensize := Round(PenSizeSlider.Position);
  CalcPenHit;
  needsrecalc := True;
end;

procedure TForm1.ExportObjModel1Click(Sender: TObject);
var
  fs: TFileStream;
begin
  if SaveDialog2.Execute then
  begin
    BackupFile(SaveDialog2.FileName);
    fs := TFileStream.Create(SaveDialog2.FileName, fmCreate);
    try

//      PT_SaveTreeToObj(tree, fs);
    finally
      fs.Free;
    end;
  end;
end;

procedure TForm1.ExportScreenshot1Click(Sender: TObject);
var
  b: TBitmap;
begin
  if SavePictureDialog1.Execute then
  begin
    BackupFile(SavePictureDialog1.FileName);
    b := TBitmap.Create;
    try
      DoRenderGL;
      Get3dPreviewBitmap(b);
      Clipboard.Assign(b);
      b.SaveToFile(SavePictureDialog1.FileName);
    finally
      b.Free;
    end;
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DoRefreshPaintBox(Rect(0, 0, terrain.texturesize - 1, terrain.texturesize - 1));
end;

procedure TForm1.DoRefreshPaintBox(const r: TRect);
var
  C: TCanvas;
begin
  C := PaintBox1.Canvas;
  C.CopyRect(r, terrain.Texture.Canvas, r);
end;

procedure TForm1.SelectWADFileButtonClick(Sender: TObject);
begin
  if OpenWADDialog.Execute then
  begin
    fwadfilename := ExpandFilename(OpenWADDialog.FileName);
    WADFileNameEdit.Text := ExtractFileName(OpenWADDialog.FileName);
    PopulateFlatsListBox(fwadfilename);
  end;
end;

procedure TForm1.PopulateFlatsListBox(const wadname: string);
var
  wad: TWADReader;
  i: integer;
  inflats: boolean;
begin
  wad := TWADReader.Create;
  wad.OpenWadFile(wadname);
  inflats := false;
  FlatsListBox.Items.Clear;
  for i := 0 to wad.NumEntries - 1 do
  begin
    if UpperCase(wad.EntryName(i)) = 'F_START' then
      inflats := true
    else if UpperCase(wad.EntryName(i)) = 'F_END' then
      inflats := false
    else if inflats then
      FlatsListBox.Items.Add(UpperCase(wad.EntryName(i)));
  end;
  wad.Free;
  if FlatsListBox.Count > 0 then
    FlatsListBox.ItemIndex := 0
  else
    FlatsListBox.ItemIndex := -1;
  NotifyFlatsListBox;
end;

procedure TForm1.NotifyFlatsListBox;
var
  idx: integer;
  bm: TBitmap;
  i, j: integer;
begin
  idx := FlatsListBox.ItemIndex;
  if (idx < 0) or (fwadfilename = '') or not FileExists(fwadfilename) then
  begin
    FlatPreviewImage.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
    FlatPreviewImage.Picture.Bitmap.Canvas.Brush.Color := RGB(255, 255, 255);
    FlatPreviewImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0, 128, 128));
    FlatSizeLabel.Caption := Format('Flat Size (%d, %d)', [128, 128]);
    colorbuffersize := 128;
    FillChar(colorbuffer^, SizeOf(colorbuffer_t), 255);
    exit;
  end;

  bm := GetWADFlatAsBitmap(fwadfilename, FlatsListBox.Items[idx]);

  for j := 0 to MinI(bm.Height - 1, MAXTEXTURESIZE - 1) do
    for i := 0 to MinI(bm.Width - 1, MAXTEXTURESIZE - 1) do
      colorbuffer[i, j] := bm.Canvas.Pixels[i, j];
  colorbuffersize := MinI(bm.Height, MAXTEXTURESIZE);
  FlatPreviewImage.Picture.Bitmap.Canvas.StretchDraw(Rect(0, 0, 128, 128), bm);
  FlatSizeLabel.Caption := Format('Flat Size (%d, %d)', [bm.Width, bm.Height]);
  bm.Free;
end;

function TForm1.GetWADFlatAsBitmap(const fwad: string; const flat: string): TBitmap;
var
  wad: TWADReader;
  i, idx, palidx: integer;
  inflats: boolean;
  wpal: PByteArray;
  palsize: integer;
  lumpsize: integer;
  flatsize: integer;
  buf: PByteArray;
  x, y: integer;
  b: byte;
begin
  idx := -1;
  palidx := -1;
  wad := TWADReader.Create;
  if (fwad <> '') and FileExists(fwad) then
  begin
    wad.OpenWadFile(fwad);
    inflats := false;
    for i := 0 to wad.NumEntries - 1 do
    begin
      if (UpperCase(wad.EntryName(i)) = 'PLAYPAL') or (UpperCase(wad.EntryName(i)) = 'PALETTE') then
        palidx := i
      else if UpperCase(wad.EntryName(i)) = 'F_START' then
        inflats := true
      else if UpperCase(wad.EntryName(i)) = 'F_END' then
        inflats := false
      else if inflats then
      begin
        if UpperCase(wad.EntryName(i)) = UpperCase(flat) then
          idx := i;
      end;
    end;
  end;

  if idx >= 0 then
    lumpsize := wad.EntryInfo(idx).size
  else
    lumpsize := wad.EntryInfo(idx).size;

  if lumpsize < 32 * 32 then
  begin
    Result := TBitmap.Create;
    Result.Width := 64;
    Result.Height := 64;
    Result.Canvas.Brush.Style := bsSolid;
    Result.Canvas.Brush.Color := RGB(255, 255, 255);
    Result.Canvas.FillRect(Rect(0, 0, 64, 64));
    wad.Free;
    Exit;
  end;

  palsize := 0;
  if (palidx >= 0) and (wad.EntryInfo(palidx).size >= 768) then
    wad.ReadEntry(palidx, pointer(wpal), palsize);

  if palsize = 0 then
  begin
    palsize := 768;
    GetMem(wpal, palsize);
    for i := 0 to 255 do
    begin
      wpal[3 * i] := i;
      wpal[3 * i + 1] := i;
      wpal[3 * i + 2] := i;
    end;
  end;

  lumpsize := 0;
  wad.ReadEntry(idx, pointer(buf), lumpsize);

  if lumpsize = 0 then
  begin
    lumpsize := 32 * 32;
    GetMem(buf, lumpsize);
    FillChar(buf^, lumpsize, 255);
  end;

  if lumpsize >= 1024 * 1024 then
    flatsize := 1024
  else if lumpsize >= 512 * 512 then
    flatsize := 512
  else if lumpsize >= 256 * 256 then
    flatsize := 256
  else if lumpsize >= 128 * 128 then
    flatsize := 128
  else if lumpsize >= 64 * 64 then
    flatsize := 64
  else
    flatsize := 32;

  Result := TBitmap.Create;
  Result.Width := flatsize;
  Result.Height := flatsize;
  Result.PixelFormat := pf32bit;

  for x := 0 to flatsize - 1 do
    for y := 0 to flatsize - 1 do
    begin
      b := buf[(y * flatsize + x) mod lumpsize];
      Result.Canvas.Pixels[x, y] := RGB(wpal[b * 3], wpal[b * 3 + 1], wpal[b * 3 + 2]);
    end;

  FreeMem(buf, flatsize * flatsize);
  FreeMem(wpal, 768);
  wad.Free;
end;

procedure TForm1.FlatsListBoxClick(Sender: TObject);
begin
  NotifyFlatsListBox;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then
  begin
    CalcPenHit;
    SaveUndo;
    lmousedown := True;
    lmousedownx := X;
    lmousedowny := Y;
    ZeroMemory(layer, SizeOf(drawlayer_t));
    LLeftMousePaintTo(X, Y);
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then
  begin
    LLeftMousePaintTo(X, Y);
    lmousedownx := X;
    lmousedowny := Y;
    lmousedown := False;
  end;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if lmousedown then
  begin
    LLeftMousePaintTo(X, Y);
    lmousedownx := X;
    lmousedowny := Y;
  end;
end;

function coloraverage(const c1, c2: LongWord; const opact: integer): LongWord;
var
  r1, g1, b1: byte;
  r2, g2, b2: byte;
  opact2: integer;
begin
  if (c1 = c2) or (opact >= 100) then
  begin
    Result := c2;
    Exit;
  end;
  if opact <= 0 then
  begin
    Result := c1;
    Exit;
  end;
  r1 := c1;
  g1 := c1 shr 8;
  b1 := c1 shr 16;
  r2 := c2;
  g2 := c2 shr 8;
  b2 := c2 shr 16;
  opact2 := 100 - opact;
  r1 := (r1 * opact2 + r2 * opact) div 100;
  g1 := (g1 * opact2 + g2 * opact) div 100;
  b1 := (b1 * opact2 + b2 * opact) div 100;
  Result := r1 or (g1 shl 8) or (b1 shl 16);
end;

procedure TForm1.LLeftMousePaintAt(const X, Y: integer);
var
  iX, iY: integer;
  c, c1, c2: LongWord;
  tsize: integer;
  tline: PLongWordarray;
  newopacity: integer;
begin
  tsize := terrain.texturesize;
  if PenSpeedButton1.Down then
  begin
    for iY := GetIntInRange(Y - fpensize div 2, 0, tsize - 1) to GetIntInRange(Y + fpensize div 2, 0, tsize - 1) do
    begin
      tline := terrain.Texture.ScanLine[iY];
      for iX := GetIntInRange(X - fpensize div 2, 0, tsize - 1) to GetIntInRange(X + fpensize div 2, 0, tsize - 1) do
        if layer[iX, iY].pass < fopacity then
        begin
          layer[iX, iY].pass := fopacity;
          c1 := colorbuffer[iX mod colorbuffersize, iY mod colorbuffersize];
          c2 := RGBSwap(tline[iX]);
          c := coloraverage(c2, c1, fopacity);
          tline[iX] := RGBSwap(c);
          PaintBox1.Canvas.Pixels[iX, iY] := c;
        end;
    end;
  end
  else if PenSpeedButton2.Down then
  begin
    for iY := GetIntInRange(Y - fpensize div 2, 0, tsize - 1) to GetIntInRange(Y + fpensize div 2, 0, tsize - 1) do
    begin
      tline := terrain.Texture.ScanLine[iY];
      for iX := GetIntInRange(X - fpensize div 2, 0, tsize - 1) to GetIntInRange(X + fpensize div 2, 0, tsize - 1) do
        if layer[iX, iY].pass < fopacity then
        begin
          newopacity := pen2hit[iX - X, iY - Y];
          if newopacity <> 0 then
          begin
            layer[iX, iY].pass := newopacity;
            c1 := colorbuffer[iX mod colorbuffersize, iY mod colorbuffersize];
            c2 := RGBSwap(tline[iX]);
            c := coloraverage(c2, c1, fopacity);
            tline[iX] := RGBSwap(c);
            PaintBox1.Canvas.Pixels[iX, iY] := c;
          end;
        end;
    end;
  end
  else if PenSpeedButton3.Down then
  begin
    for iY := GetIntInRange(Y - fpensize div 2, 0, tsize - 1) to GetIntInRange(Y + fpensize div 2, 0, tsize - 1) do
    begin
      tline := terrain.Texture.ScanLine[iY];
      for iX := GetIntInRange(X - fpensize div 2, 0, tsize - 1) to GetIntInRange(X + fpensize div 2, 0, tsize - 1) do
        if layer[iX, iY].pass < fopacity then
        begin
          newopacity := pen3hit[iX - X, iY - Y];
          begin
            if layer[iX, iY].pass < newopacity then
            begin
              layer[iX, iY].pass := newopacity;
              c1 := colorbuffer[iX mod colorbuffersize, iY mod colorbuffersize];
              c2 := RGBSwap(tline[iX]);
              c := coloraverage(c2, c1, newopacity);
              tline[iX] := RGBSwap(c);
              PaintBox1.Canvas.Pixels[iX, iY] := c;
            end;
          end;
        end;
    end;
  end;
  changed := true;
end;

procedure TForm1.LLeftMousePaintTo(const X, Y: integer);
var
  dx, dy: integer;
  curx, cury: integer;
  sx, sy,
  ax, ay,
  d: integer;
begin
  if not lmousedown then
    Exit;

  dx := X - lmousedownx;
  ax := 2 * abs(dx);
  if dx < 0 then
    sx := -1
  else
    sx := 1;
  dy := Y - lmousedowny;
  ay := 2 * abs(dy);
  if dy < 0 then
    sy := -1
  else
    sy := 1;

  curx := lmousedownx;
  cury := lmousedowny;

  if ax > ay then
  begin
    d := ay - ax div 2;
    while true do
    begin
      LLeftMousePaintAt(curx, cury);
      if curx = X then break;
      if d >= 0 then
      begin
        cury := cury + sy;
        d := d - ax;
      end;
      curx := curx + sx;
      d := d + ay;
    end;
  end
  else
  begin
    d := ax - ay div 2;
    while true do
    begin
      LLeftMousePaintAt(curx, cury);
      if y = Y then break;
      if d >= 0 then
      begin
        curx := curx + sx;
        d := d - ay;
      end;
      cury := cury + sy;
      d := d + ax;
    end;
  end;
end;

procedure TForm1.CalcPenHit;
var
  iX, iY: integer;
  sqmaxdist: integer;
  sqdist: integer;
  sqry: integer;
  frac: single;
begin
  if (foldopacity = fopacity) and (foldpensize = fpensize) then
    Exit;
  foldopacity := fopacity;
  foldpensize := fpensize;

  ZeroMemory(@pen2hit, SizeOf(pen2hit));
  ZeroMemory(@pen3hit, SizeOf(pen3hit));
  sqmaxdist := sqr(fpensize div 2);
  for iY := -fpensize div 2 to fpensize div 2 do
  begin
    sqry := iY * iY;
    for iX := -fpensize div 2 to fpensize div 2 do
    begin
      sqdist := iX * iX + sqry;
      if sqdist <= sqmaxdist then
      begin
        pen2hit[iX, iY] := fopacity;
        frac := (1 - sqdist / sqmaxdist) * fopacity;
        pen3hit[iX, iY] := GetIntInRange(round(frac), 0, 100);
      end;
    end;
  end;
end;

end.

