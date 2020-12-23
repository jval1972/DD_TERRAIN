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
  Dialogs, xTGA, jpeg, zBitmap, ComCtrls, ExtCtrls, Buttons, Menus, FileCtrl,
  StdCtrls, AppEvnts, ExtDlgs, clipbrd, ToolWin, dglOpenGL, ter_class, ter_undo,
  ter_filemenuhistory, ter_slider, PngImage1, ter_pk3, ter_colorpickerbutton,
  ter_wadexport, xTIFF, ImgList;

type
  drawlayeritem_t = packed record
    pass: byte;
    color: integer;
  end;

  drawlayer_t = packed array[0..MAXTEXTURESIZE - 1, 0..MAXTEXTURESIZE - 1] of drawlayeritem_t;
  drawlayer_p = ^drawlayer_t;

type
  heightlayeritem_t = packed record
    pass: boolean;
  end;

  heightlayer_t = packed array[0..MAXHEIGHTMAPSIZE - 1, 0..MAXHEIGHTMAPSIZE - 1] of heightlayeritem_t;
  heightlayer_p = ^heightlayer_t;

type
  colorbuffer_t = array[0..MAXTEXTURESIZE - 1, 0..MAXTEXTURESIZE - 1] of LongWord;
  colorbuffer_p = ^colorbuffer_t;

const
  MAXPENSIZE = 128;
  MAXHEIGHTSIZE = 128;

const
  MINTEXTURESCALE = 10;
  MAXTEXTURESCALE = 400;

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
    MNExport1: TMenuItem;
    ExportObjModel1: TMenuItem;
    SaveDialog1: TSaveDialog;
    N5: TMenuItem;
    N8: TMenuItem;
    CopyTexture1: TMenuItem;
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
    EditPageControl: TPageControl;
    TabSheet1: TTabSheet;
    ExportScreenshot1: TMenuItem;
    Wireframe1: TMenuItem;
    Renderenviroment1: TMenuItem;
    SaveDialog2: TSaveDialog;
    MainPageControl: TPageControl;
    TabSheet4: TTabSheet;
    PaintScrollBox: TScrollBox;
    PaintBox1: TPaintBox;
    TabSheet5: TTabSheet;
    OpenGLScrollBox: TScrollBox;
    OpenGLPanel: TPanel;
    OpenWADDialog: TOpenDialog;
    Panel1: TPanel;
    Label3: TLabel;
    PenSizePaintBox: TPaintBox;
    PenSizeLabel: TLabel;
    OpacityLabel: TLabel;
    OpacityPaintBox: TPaintBox;
    Label2: TLabel;
    Label1: TLabel;
    HeightPaintBox: TPaintBox;
    HeightLabel: TLabel;
    PenSpeedButton1: TSpeedButton;
    PenSpeedButton2: TSpeedButton;
    PenSpeedButton3: TSpeedButton;
    PenSpeedButton5: TSpeedButton;
    PenSpeedButton6: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label4: TLabel;
    SmoothPaintBox: TPaintBox;
    SmoothLabel: TLabel;
    N1: TMenuItem;
    PasteTexture1: TMenuItem;
    PasteHeightmap1: TMenuItem;
    PenSpeedButton4: TSpeedButton;
    MNTools1: TMenuItem;
    Scaleheightmap1: TMenuItem;
    ExportWADFile1: TMenuItem;
    SaveWADDialog: TSaveDialog;
    N3: TMenuItem;
    N4: TMenuItem;
    Copy3dview1: TMenuItem;
    CopyHeightmap1: TMenuItem;
    PalettePopupMenu1: TPopupMenu;
    PaletteDoom1: TMenuItem;
    PaletteHeretic1: TMenuItem;
    PaletteHexen1: TMenuItem;
    PaletteStrife1: TMenuItem;
    PaletteRadix1: TMenuItem;
    N18: TMenuItem;
    PaletteGreyScale1: TMenuItem;
    PaletteDefault1: TMenuItem;
    N6: TMenuItem;
    N9: TMenuItem;
    MNResampleHeightmapX2: TMenuItem;
    Panel2: TPanel;
    TexturePageControl: TPageControl;
    WADTabSheet1: TTabSheet;
    OpenWADMainPanel: TPanel;
    Panel3: TPanel;
    Label23: TLabel;
    SelectWADFileButton: TSpeedButton;
    WADFileNameEdit: TEdit;
    WADTextureListPanel: TPanel;
    Panel5: TPanel;
    Panel10: TPanel;
    FlatsListBox: TListBox;
    WADPreviewTexturePanel: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    WADFlatPreviewImage: TImage;
    PaletteSpeedButton1: TSpeedButton;
    Pk3TabSheet: TTabSheet;
    Panel12: TPanel;
    Panel13: TPanel;
    Label5: TLabel;
    SelectPK3FileButton: TSpeedButton;
    PK3FileNameEdit: TEdit;
    PK3TextureListPanel: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    PK3TexListBox: TListBox;
    PK3PreviewTexturePanel: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    PK3TexPreviewImage: TImage;
    OpenPK3Dialog: TOpenDialog;
    Panel11: TPanel;
    FlatSizeLabel: TLabel;
    Panel21: TPanel;
    PK3TexSizeLabel: TLabel;
    DirTabSheet: TTabSheet;
    Panel4: TPanel;
    Panel6: TPanel;
    Label6: TLabel;
    SelectDIRFileButton: TSpeedButton;
    DIRFileNameEdit: TEdit;
    DIRTextureListPanel: TPanel;
    Panel14: TPanel;
    Panel17: TPanel;
    DIRTexListBox: TListBox;
    DIRPreviewTexturePanel: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    DIRTexPreviewImage: TImage;
    Panel25: TPanel;
    DIRTexSizeLabel: TLabel;
    Import1: TMenuItem;
    MNImportTexture1: TMenuItem;
    MNImportHeightmap1: TMenuItem;
    TextureScaleResetLabel: TLabel;
    TextureScalePaintBox: TPaintBox;
    TextureScaleLabel: TLabel;
    WAADFlatNameLabel: TLabel;
    PK3TextureNameLabel: TLabel;
    DIRTextureNameLabel: TLabel;
    ImageList1: TImageList;
    TabSheet2: TTabSheet;
    SelectColorBackPanel: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    PickColorPalettePanel: TPanel;
    Panel29: TPanel;
    ColorPanel1: TPanel;
    ColorPaletteImage: TImage;
    PickColorRGBLabel: TLabel;
    ExportHeightmap1: TMenuItem;
    SavePictureDialog2: TSavePictureDialog;
    ToolButton5: TToolButton;
    ExportWADButton1: TSpeedButton;
    N10: TMenuItem;
    MNExpoortTexture1: TMenuItem;
    SavePictureDialog3: TSavePictureDialog;
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
    procedure CopyTexture1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Wireframe1Click(Sender: TObject);
    procedure TrunkImageDblClick(Sender: TObject);
    procedure Renderenviroment1Click(Sender: TObject);
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
    procedure PenSpeedButton1Click(Sender: TObject);
    procedure PenSpeedButton2Click(Sender: TObject);
    procedure PenSpeedButton3Click(Sender: TObject);
    procedure PenSpeedButton4Click(Sender: TObject);
    procedure PenSpeedButton5Click(Sender: TObject);
    procedure PenSpeedButton6Click(Sender: TObject);
    procedure PasteTexture1Click(Sender: TObject);
    procedure PasteHeightmap1Click(Sender: TObject);
    procedure Scaleheightmap1Click(Sender: TObject);
    procedure ExportWADFile1Click(Sender: TObject);
    procedure Copy3dview1Click(Sender: TObject);
    procedure CopyHeightmap1Click(Sender: TObject);
    procedure PaletteSpeedButton1Click(Sender: TObject);
    procedure PaletteDefault1Click(Sender: TObject);
    procedure PaletteDoom1Click(Sender: TObject);
    procedure PaletteHeretic1Click(Sender: TObject);
    procedure PaletteHexen1Click(Sender: TObject);
    procedure PaletteStrife1Click(Sender: TObject);
    procedure PaletteRadix1Click(Sender: TObject);
    procedure PaletteGreyScale1Click(Sender: TObject);
    procedure PalettePopupMenu1Popup(Sender: TObject);
    procedure MNTools1Click(Sender: TObject);
    procedure MNResampleHeightmapX2Click(Sender: TObject);
    procedure SelectPK3FileButtonClick(Sender: TObject);
    procedure PK3TexListBoxClick(Sender: TObject);
    procedure MNImportTexture1Click(Sender: TObject);
    procedure MNImportHeightmap1Click(Sender: TObject);
    procedure DIRTexListBoxClick(Sender: TObject);
    procedure SelectDIRFileButtonClick(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure WADFileNameEditChange(Sender: TObject);
    procedure PK3FileNameEditChange(Sender: TObject);
    procedure DIRFileNameEditChange(Sender: TObject);
    procedure TexturePageControlChange(Sender: TObject);
    procedure PickColorPalettePanelCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure ColorPaletteImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ColorPaletteImageMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorPaletteImageMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ExportHeightmap1Click(Sender: TObject);
    procedure TextureScaleResetLabelDblClick(Sender: TObject);
    procedure MNExpoortTexture1Click(Sender: TObject);
  private
    { Private declarations }
    ffilename: string;
    fwadfilename: string;
    fpalettename: string;
    fpk3filename: string;
    fpk3reader: TZipFile;
    fdirdirectory: string;
    fdirlist: TStringList;
    fexportoptions: exportwadoptions_t;
    fdrawcolor: TColor;
    lpickcolormousedown: boolean;
    drawlayer: drawlayer_p;
    heightlayer: heightlayer_p;
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
    glneedstexturerecalc: boolean;
    fopacity: integer;
    fpensize: integer;
    ftexturescale: integer;
    fheightsize: integer;
    fsmoothfactor: integer;
    foldopacity: integer;
    foldpensize: integer;
    OpacitySlider: TSliderHook;
    TextureScaleSlider: TSliderHook;
    PenSizeSlider: TSliderHook;
    HeightSlider: TSliderHook;
    SmoothSlider: TSliderHook;
    closing: boolean;
    lmousedown: boolean;
    lmousedownx, lmousedowny: integer;
    lmouseheightmapx, lmouseheightmapy: integer;
    hmouseheightmapx, hmouseheightmapy: integer;
    lasthmouseheightmapx, lasthmouseheightmapy: integer;
    pen2mask: array[-MAXPENSIZE div 2..MAXPENSIZE div 2, -MAXPENSIZE div 2..MAXPENSIZE div 2] of integer;
    pen3mask: array[-MAXPENSIZE div 2..MAXPENSIZE div 2, -MAXPENSIZE div 2..MAXPENSIZE div 2] of integer;
    bitmapbuffer: TBitmap;
    savebitmapundo: boolean;
    ColorPickerButton1: TColorPickerButton;
    procedure Idle(Sender: TObject; var Done: Boolean);
    function CheckCanClose: boolean;
    procedure DoNewTerrain(const tsize, hsize: integer);
    procedure DoSaveTerrain(const fname: string);
    function DoLoadTerrain(const fname: string): boolean;
    procedure SetFileName(const fname: string);
    procedure DoLoadTerrainBinaryUndo(s: TStream);
    procedure DoSaveTerrainBinaryUndo(s: TStream);
    procedure SaveUndo(const dosavebitmap: boolean);
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
    procedure BitmapToColorBuffer(const abitmap: TBitmap);
    procedure NotifyFlatsListBox;
    function GetWADFlatAsBitmap(const fwad: string; const flat: string): TBitmap;
    procedure PopulatePK3ListBox(const pk3name: string);
    procedure NotifyPK3ListBox;
    function GetPK3TexAsBitmap(const tname: string): TBitmap;
    procedure PopulateDirListBox;
    procedure NotifyDIRListBox;
    function DIRTexListBoxNameSize: integer;
    function DIRTexEditNameSize: integer;
    procedure LLeftMousePaintAt(const X, Y: integer);
    procedure LLeftMousePaintTo(const X, Y: integer);
    procedure CalcPenMasks;
    procedure DoRefreshPaintBox(const r: TRect);
    procedure CheckPaletteName;
    procedure GetHeighmapFromBitmap(const tempBitmap1: TBitmap);
    procedure ChangeListHint(const lst: TListBox; const def: string);
    procedure ColorPickerButton1Click(Sender: TObject);
    procedure ColorPickerButton1Change(Sender: TObject);
    procedure NotifyColor;
    procedure RecreateColorPickPalette;
    procedure PickColorPalette(const X, Y: integer);
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
  ter_wadreader,
  frm_editheightmapitem,
  frm_scaleheightmap,
  ter_palettes,
  frm_loadimagehelper,
  ter_colorpalettebmz,
  ter_cursors,
  frm_exportwadmap;

{$R *.dfm}

resourcestring
  rsTitle = 'Terrain Generator';

// Helper function
procedure ClearList(const lst: TStringList);
var
  i: integer;
begin
  for i := 0 to lst.Count - 1 do
    lst.Objects[i].Free;
  lst.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  pfd: TPIXELFORMATDESCRIPTOR;
  pf: Integer;
  doCreate: boolean;
begin
  Randomize;

  CreateCustomCursors;
  PaintBox1.Cursor := crPaint;

  colorbuffer := nil;

  DoubleBuffered := True;

  fexportoptions.engine := ENGINE_RAD;
  fexportoptions.game := GAME_RADIX;
  fexportoptions.levelname := 'E1M1';
  fexportoptions.palette := @RadixPaletteRaw;
  fexportoptions.defsidetex := 'RDXW0012';
  fexportoptions.defceilingtex := 'F_SKY1';
  fexportoptions.lowerid := 1255;
  fexportoptions.raiseid := 1254;
  fexportoptions.flags := ETF_CALCDXDY or ETF_TRUECOLORFLAT or ETF_MERGEFLATSECTORS or ETF_ADDPLAYERSTART or ETF_EXPORTFLAT;
  fexportoptions.elevationmethod := ELEVATIONMETHOD_SLOPES;
  fexportoptions.defceilingheight := 512;
  fexportoptions.deflightlevel := 192;
  fexportoptions.layerstep := 24;

  bitmapbuffer := TBitmap.Create;
  bitmapbuffer.PixelFormat := pf32bit;

  ColorPickerButton1 := TColorPickerButton.Create(nil);
  ColorPickerButton1.Parent := ColorPanel1;
  ColorPickerButton1.Align := alClient;
  ColorPickerButton1.OnClick := ColorPickerButton1Click;
  ColorPickerButton1.OnChange := ColorPickerButton1Change;
  fdrawcolor := RGB(255, 255, 255);
  lpickcolormousedown := False;
  NotifyColor;
  RecreateColorPickPalette;

  ter_LoadSettingFromFile(ChangeFileExt(ParamStr(0), '.ini'));

  closing := False;

  EditPageControl.ActivePageIndex := 0;
  TexturePageControl.ActivePageIndex := 0;
  MainPageControl.ActivePageIndex := 0;

  GetMem(drawlayer, SizeOf(drawlayer_t));
  GetMem(heightlayer, SizeOf(heightlayer_t));
  GetMem(colorbuffer, SizeOf(colorbuffer_t));
  FillChar(colorbuffer^, SizeOf(colorbuffer_t), 255);
  colorbuffersize := 128;

  // Set palette
  fpalettename := bigstringtostring(@opt_defaultpalette);
  CheckPaletteName;

  // Open WAD resource
  fwadfilename := bigstringtostring(@opt_lastwadfile);
  WADFileNameEdit.Text := ExtractFileName(fwadfilename);
  PopulateFlatsListBox(fwadfilename);

  // Open PK3 resource
  fpk3filename := bigstringtostring(@opt_lastpk3file);
  fpk3reader := TZipFile.Create(fpk3filename);
  PK3FileNameEdit.Text := ExtractFileName(fpk3filename);
  PopulatePK3ListBox(fpk3filename);

  // Open Directory resource
  fdirdirectory := bigstringtostring(@opt_lastdirectory);
  fdirlist := TStringList.Create;
//  DIRFileNameEdit.Text := MkShortName(fdirdirectory, DIRTexEditNameSize);
  DIRFileNameEdit.Text := fdirdirectory;
  PopulateDirListBox;

  lmousedown := False;
  lmousedownx := 0;
  lmousedowny := 0;

  lmouseheightmapx := 0;
  lmouseheightmapy := 0;

  hmouseheightmapx := 0;
  hmouseheightmapy := 0;
  lasthmouseheightmapx := -1;
  lasthmouseheightmapy := -1;

  fopacity := 100;
  fpensize := 64;
  ftexturescale := 100;
  fheightsize := 64;
  fsmoothfactor := 50;
  foldopacity := -1;
  foldpensize := -1;
  savebitmapundo := true;

  CalcPenMasks;

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

  terraintexture := gld_CreateTexture(terrain.Texture, False);

  glneedsupdate := True;

  glneedstexturerecalc := True;

  TabSheet1.DoubleBuffered := True;

  OpacitySlider := TSliderHook.Create(OpacityPaintBox);
  OpacitySlider.Min := 1;
  OpacitySlider.Max := 100;

  PenSizeSlider := TSliderHook.Create(PenSizePaintBox);
  PenSizeSlider.Min := 1;
  PenSizeSlider.Max := MAXPENSIZE;

  TextureScaleSlider := TSliderHook.Create(TextureScalePaintBox);
  TextureScaleSlider.Min := MINTEXTURESCALE;
  TextureScaleSlider.Max := MAXTEXTURESCALE;

  HeightSlider := TSliderHook.Create(HeightPaintBox);
  HeightSlider.Min := -MAXHEIGHTSIZE;
  HeightSlider.Max := MAXHEIGHTSIZE;

  SmoothSlider := TSliderHook.Create(SmoothPaintBox);
  SmoothSlider.Min := 0;
  SmoothSlider.Max := 100;

  doCreate := True;
  if ParamCount > 0 then
    if DoLoadTerrain(ParamStr(1)) then
      doCreate := False;

  if DoCreate then
  begin
    SetFileName('');
    DoNewTerrain(1024, 17);
    glneedsupdate := True;
    glneedstexturerecalc := True;
    undoManager.Clear;
  end;

  NotifyFlatsListBox; // This must be placed here to use the flats for drawing at startup.

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
    if ret = IDCANCEL then
    begin
      Result := False;
      exit;
    end;
    if ret = IDNO then
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
  bitmapbuffer.Width := tsize;
  bitmapbuffer.Height := tsize;
  TerrainToControls;
  glneedsupdate := True;
  glneedstexturerecalc := True;
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

  Screen.Cursor := crHourglass;
  try
    terrain.SaveToFile(fname);
  finally
    Screen.Cursor := crDefault;
  end;

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

  Screen.Cursor := crHourglass;
  try
    terrain.LoadFromFile(fname);
  finally
    Screen.Cursor := crDefault;
  end;

  PaintBox1.Width := terrain.texturesize;
  PaintBox1.Height := terrain.texturesize;
  bitmapbuffer.Width := terrain.texturesize;
  bitmapbuffer.Height := terrain.texturesize;

  TerrainToControls;
  filemenuhistory.AddPath(fname);
  SetFileName(fname);
  glneedsupdate := True;
  glneedstexturerecalc := True;
  changed := False;
  Result := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  closing := True;
  Timer1.Enabled := False;
  undoManager.Free;
  wglMakeCurrent(0, 0);
  wglDeleteContext(rc);

  glDeleteTextures(1, @terraintexture);

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
  stringtobigstring(fpalettename, @opt_defaultpalette);
  stringtobigstring(fpk3filename, @opt_lastpk3file);
  stringtobigstring(fdirdirectory, @opt_lastdirectory);

  ter_SaveSettingsToFile(ChangeFileExt(ParamStr(0), '.ini'));

  filemenuhistory.Free;

  OpacitySlider.Free;
  TextureScaleSlider.Free;
  PenSizeSlider.Free;

  HeightSlider.Free;
  SmoothSlider.Free;
  terrain.Free;
  Freemem(drawlayer, SizeOf(drawlayer_t));
  Freemem(heightlayer, SizeOf(heightlayer_t));
  Freemem(colorbuffer, SizeOf(colorbuffer_t));

  bitmapbuffer.Free;

  fpk3reader.Free;

  ClearList(fdirlist);
  fdirlist.Free;

  ColorPickerButton1.Free;

  PaintBox1.Cursor := crDefault;

  DeleteCustomCursors;
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
  if glneedstexturerecalc then
    glneedsupdate := True;

  UpdateStausbar;

  if not glneedsupdate then
    // jval: We don't need to render
    Exit;

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
  PasteTexture1.Enabled := Clipboard.HasFormat(CF_BITMAP);
  PasteHeightmap1.Enabled := Clipboard.HasFormat(CF_BITMAP);
end;

procedure TForm1.Undo1Click(Sender: TObject);
begin
  if undoManager.CanUndo then
  begin
    Screen.Cursor := crHourglass;
    try
      undoManager.Undo;
      glneedsupdate := True;
      glneedstexturerecalc := True;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TForm1.Redo1Click(Sender: TObject);
begin
  if undoManager.CanRedo then
  begin
    Screen.Cursor := crHourglass;
    try
      undoManager.Redo;
      glneedsupdate := True;
      glneedstexturerecalc := True;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TForm1.DoSaveTerrainBinaryUndo(s: TStream);
begin
  terrain.SaveToStream(s, true, savebitmapundo);
end;

procedure TForm1.DoLoadTerrainBinaryUndo(s: TStream);
begin
  terrain.LoadFromStream(s);
  TerrainToControls;
  glneedsupdate := True;
  glneedstexturerecalc := True;
end;

procedure TForm1.SaveUndo(const dosavebitmap: boolean);
begin
  savebitmapundo := dosavebitmap;
  undoManager.SaveUndo;
  savebitmapundo := true;
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
  StatusBar1.Panels[3].Text := Format('Rendered triangles = %d', [t_rendredtriangles]);
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
      if glneedstexturerecalc then
      begin
        glDeleteTextures(1, @terraintexture);
        terraintexture := gld_CreateTexture(terrain.Texture, False);
        glneedstexturerecalc := False;
      end;
      glRenderEnviroment(terrain);
      glRenderTerrain(terrain);
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

procedure TForm1.CopyTexture1Click(Sender: TObject);
begin
  Clipboard.Assign(terrain.Texture);
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
    glDeleteTextures(1, @terraintexture);
//    trunktexture := gld_CreateTexture(TrunkImage.Picture, False);
  end;
end;

procedure TForm1.Renderenviroment1Click(Sender: TObject);
begin
  opt_renderevniroment := not opt_renderevniroment;
  glneedsupdate := True;
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

  TextureScaleSlider.OnSliderHookChange := nil;
  TextureScaleSlider.Position := ftexturescale;
  TextureScalePaintBox.Invalidate;
  TextureScaleSlider.OnSliderHookChange := UpdateFromSliders;

  HeightSlider.OnSliderHookChange := nil;
  HeightSlider.Position := fheightsize;
  HeightPaintBox.Invalidate;
  HeightSlider.OnSliderHookChange := UpdateFromSliders;

  SmoothSlider.OnSliderHookChange := nil;
  SmoothSlider.Position := fsmoothfactor;
  SmoothPaintBox.Invalidate;
  SmoothSlider.OnSliderHookChange := UpdateFromSliders;
end;

procedure TForm1.SlidersToLabels;
begin
  OpacityLabel.Caption := Format('%d', [Round(OpacitySlider.Position)]);
  PenSizeLabel.Caption := Format('%d', [Round(PenSizeSlider.Position)]);
  TextureScaleLabel.Caption := Format('%d', [Round(TextureScaleSlider.Position)]);
  HeightLabel.Caption := Format('%d', [Round(HeightSlider.Position)]);
  SmoothLabel.Caption := Format('%d', [Round(SmoothSlider.Position)]);
end;

procedure TForm1.TerrainToControls;
begin
  if closing then
    Exit;

  PaintBox1.Invalidate;
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
  ftexturescale := Round(TextureScaleSlider.Position);
  fheightsize := Round(HeightSlider.Position);
  fsmoothfactor := Round(HeightSlider.Position);
  CalcPenMasks;
  glneedstexturerecalc := True;
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
  imgfname: string;
begin
  if SavePictureDialog1.Execute then
  begin
    imgfname := SavePictureDialog1.FileName;
    BackupFile(imgfname);
    b := TBitmap.Create;
    try
      DoRenderGL;
      Get3dPreviewBitmap(b);
      SaveImageToDisk(b, imgfname);
    finally
      b.Free;
    end;
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DoRefreshPaintBox(Rect(0, 0, terrain.texturesize - 1, terrain.texturesize - 1));
end;

function intersectRect(const r1, r2: TRect): boolean;
begin
  Result :=  not ((r2.left > r1.right) or
                  (r2.right < r1.left) or
                  (r2.top > r1.bottom) or
                  (r2.bottom < r1.top));
end;

function intersectRange(const a1, a2, b1, b2: integer): boolean;
begin
  Result := (a1 <= b2) and (a2 >= b1);
end;

procedure TForm1.DoRefreshPaintBox(const r: TRect);
var
  C: TCanvas;
  x, y, k, hsize, hstep, checkstep: integer;
  drawx, drawy: integer;
  pointx, pointy: integer;
  pointrect: TRect;
  hitem: heightbufferitem_t;
  hx, hy: integer;
  drawredpoints: boolean;
  drawheightmap: boolean;

  procedure lineandpoint(const ax, ay: integer);
  begin
    C.LineTo(ax, ay);
    if drawredpoints then
  end;

  function hcolor: LongWord;
  var
    g: integer;
  begin
    g := GetIntInRange(Round(128 + hitem.height * 128 / HEIGHTMAPRANGE), 0, 255);
    Result := RGB(g, g, g);
  end;

begin
  C := bitmapbuffer.Canvas;
  C.CopyRect(r, terrain.Texture.Canvas, r);

  hsize := terrain.heightmapsize;
  hstep := terrain.texturesize div (hsize - 1);
  checkstep := MaxI(64, hstep * 3);

  drawheightmap := PenSpeedButton5.Down or PenSpeedButton6.Down;
  if drawheightmap then
  begin
    C.Pen.Style := psSolid;

    drawx := 0;
    for x := 0 to hsize - 1 do
    begin
      if intersectRange(drawx - checkstep - 1, drawx + checkstep + 1, r.Left, r.Right) then
      begin
        drawy := 0;
        for y := 0 to hsize - 1 do
        begin
          if intersectRect(r, Rect(drawx - checkstep - 1, drawy - checkstep - 1, drawx + checkstep + 1, drawy + checkstep + 1)) then
          begin
            hitem := terrain.Heightmap[x, y];
            C.Pen.Color := hcolor;
            hx := drawx + hitem.dx;
            hy := drawy + hitem.dy;
            for k := -hstep div 2 to hstep + 2 do
            begin
//              if (hy + k) mod 8 = 4 then
//              if (hy + k) mod 4 <> 2 then
              if (hy + k) mod 2 <> 1 then
              begin
                C.MoveTo(hx - hstep div 2, hy + k);
                C.LineTo(hx + hstep div 2, hy + k);
              end;
//              if (hx + k) mod 8 = 4 then
//              if (hx + k) mod 4 <> 2 then
              if (hx + k) mod 2 <> 1 then
              begin
                C.MoveTo(hx + k, hy - hstep div 2);
                C.LineTo(hx + k, hy + hstep div 2);
              end;
            end;
          end;
          drawy := drawy + hstep;
        end;
      end;
      drawx := drawx + hstep;
    end;
  end;

  C.Pen.Style := psSolid;
  C.Pen.Color := RGB(128, 255, 128);
  C.Brush.Style := bsSolid;
  C.Brush.Color := RGB(255, 0, 0);

  drawx := 0;
  for x := 0 to hsize - 2 do
  begin
    if intersectRange(drawx - checkstep - 1, drawx + checkstep + 1, r.Left, r.Right) then
    begin
      drawy := 0;
      for y := 0 to hsize - 2 do
      begin
        if intersectRect(r, Rect(drawx - checkstep - 1, drawy - checkstep - 1, drawx + checkstep + 1, drawy + checkstep + 1)) then
        begin
          hitem := terrain.Heightmap[x, y];
          C.MoveTo(drawx + hitem.dx, drawy + hitem.dy);
          hitem := terrain.Heightmap[x + 1, y];
          C.LineTo(drawx + hstep + hitem.dx, drawy + hitem.dy);
          hitem := terrain.Heightmap[x, y + 1];
          C.LineTo(drawx + hitem.dx, drawy + hstep + hitem.dy);
          hitem := terrain.Heightmap[x + 1, y + 1];
          C.LineTo(drawx + hstep + hitem.dx, drawy + hstep + hitem.dy);
          hitem := terrain.Heightmap[x + 1, y];
          C.LineTo(drawx + hstep + hitem.dx, drawy + hitem.dy);
        end;
        drawy := drawy + hstep;
      end;
    end;
    drawx := drawx + hstep;
  end;

  drawredpoints := PenSpeedButton4.Down;
  if drawredpoints then
  begin
    drawx := 0;
    for x := 0 to hsize - 1 do
    begin
      if intersectRange(drawx, drawx + checkstep, r.Left, r.Right) then
      begin
        drawy := 0;
        for y := 0 to hsize - 1 do
        begin
          hitem := terrain.Heightmap[x, y];
          pointx := drawx + hitem.dx;
          pointy := drawy + hitem.dy;
          pointrect := Rect(pointx - 2, pointy - 2, pointx + 2, pointy + 2);
          if intersectRect(r, pointrect) then
            C.FillRect(pointrect);
          drawy := drawy + hstep;
        end;
      end;
      drawx := drawx + hstep;
    end;
  end;
  
  PaintBox1.Canvas.CopyRect(r, C, r);
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
  uEntry: string;
begin
  wad := TWADReader.Create;
  wad.OpenWadFile(wadname);
  inflats := False;
  FlatsListBox.Items.Clear;
  for i := 0 to wad.NumEntries - 1 do
  begin
    uEntry := UpperCase(wad.EntryName(i));
    if (uEntry = 'F_START') or (uEntry = 'FF_START') then
      inflats := True
    else if (uEntry = 'F_END') or (uEntry = 'FF_END') then
      inflats := False
    else if inflats then
      FlatsListBox.Items.Add(uEntry);
  end;
  wad.Free;
  if FlatsListBox.Count > 0 then
    FlatsListBox.ItemIndex := 0
  else
    FlatsListBox.ItemIndex := -1;
  NotifyFlatsListBox;
end;

procedure TForm1.BitmapToColorBuffer(const abitmap: TBitmap);
var
  i, j: integer;
  A, B: PLongWordArray;
  oldw, oldh: integer;

  function RGBSwap(buffer: LongWord): LongWord;
  var
    r, g, b: LongWord;
  begin
    Result := buffer;
    b := Result and $FF;
    Result := Result shr 8;
    g := Result and $FF;
    Result := Result shr 8;
    r := Result and $FF;
    Result := r + g shl 8 + b shl 16;
  end;

begin
  abitmap.PixelFormat := pf32bit;
  if abitmap.Width <> abitmap.Height then // Make rectangular
  begin
    if abitmap.Width > abitmap.Height then
    begin
      oldh := abitmap.Height;
      abitmap.Height := abitmap.Width;
      for j := oldh to abitmap.Height - 1 do
      begin
        A := abitmap.ScanLine[j];
        B := abitmap.ScanLine[j - oldh];
        for i := 0 to abitmap.Width - 1 do
          A[i] := B[i];
      end;
    end
    else
    begin
      oldw := abitmap.Width;
      abitmap.Width := abitmap.Height;
      for j := 0 to abitmap.Height - 1 do
      begin
        A := abitmap.ScanLine[j];
        for i := oldw to abitmap.Width - 1 do
          A[i] := A[i - oldw];
      end;
    end;
  end;

  // Copy to colorbuffer
  for j := 0 to MinI(abitmap.Height - 1, MAXTEXTURESIZE - 1) do
  begin
    A := abitmap.ScanLine[j];
    for i := 0 to MinI(abitmap.Width - 1, MAXTEXTURESIZE - 1) do
      colorbuffer[i, j] := RGBSwap(A[i]);
  end;
end;

procedure TForm1.NotifyFlatsListBox;
var
  idx: integer;
  bm: TBitmap;
begin
  ChangeListHint(FlatsListBox, 'WAD Flats');
  idx := FlatsListBox.ItemIndex;
  if (idx < 0) or (fwadfilename = '') or not FileExists(fwadfilename) then
  begin
    WADFlatPreviewImage.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
    WADFlatPreviewImage.Picture.Bitmap.Canvas.Brush.Color := RGB(255, 255, 255);
    WADFlatPreviewImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0, 128, 128));
    WAADFlatNameLabel.Caption := '(None)';
    FlatSizeLabel.Caption := Format('(%dx%d)', [128, 128]);
    colorbuffersize := 128;
    FillChar(colorbuffer^, SizeOf(colorbuffer_t), 255);
    exit;
  end;

  bm := GetWADFlatAsBitmap(fwadfilename, FlatsListBox.Items[idx]);

  BitmapToColorBuffer(bm);

  colorbuffersize := MinI(bm.Height, MAXTEXTURESIZE);
  WADFlatPreviewImage.Picture.Bitmap.Canvas.StretchDraw(Rect(0, 0, 128, 128), bm);
  WAADFlatNameLabel.Caption := FlatsListBox.Items[idx];
  FlatSizeLabel.Caption := Format('(%dx%d)', [bm.Width, bm.Height]);
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
  uEntry: string;
  buildinrawpal: rawpalette_p;
begin
  idx := -1;
  palidx := -1;
  wad := TWADReader.Create;
  if (fwad <> '') and FileExists(fwad) then
  begin
    wad.OpenWadFile(fwad);
    inflats := False;
    for i := 0 to wad.NumEntries - 1 do
    begin
      uEntry := UpperCase(wad.EntryName(i));
      if (uEntry = 'PLAYPAL') or (uEntry = 'PALETTE') then
        palidx := i
      else if (uEntry = 'F_START') or (uEntry = 'FF_START') then
        inflats := True
      else if (uEntry = 'F_END') or (uEntry = 'FF_END') then
        inflats := False
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
    lumpsize := 0;

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

  if fpalettename = spalDEFAULT then
  begin
    palsize := 0;
    if (palidx >= 0) and (wad.EntryInfo(palidx).size >= 768) then
      wad.ReadEntry(palidx, pointer(wpal), palsize);
  end
  else
  begin
    buildinrawpal := GetPaletteFromName(fpalettename);
    if buildinrawpal <> nil then
    begin
      palsize := 768;
      GetMem(wpal, palsize);
      for i := 0 to 767 do
        wpal[i] := buildinrawpal[i];
    end
    else
      palsize := 0;
  end;

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
var
  it: heightbufferitem_t;
  iX, iY: integer;
begin
  if button = mbLeft then
  begin
    CalcPenMasks;
    SaveUndo(PenSpeedButton1.Down or PenSpeedButton2.Down or PenSpeedButton3.Down);
    lmousedown := True;
    lmousedownx := X;
    lmousedowny := Y;

    terrain.TerrainToHeightmapIndex(X, Y, lmouseheightmapx, lmouseheightmapy);
    terrain.TerrainToHeightmapIndex(X, Y, hmouseheightmapx, hmouseheightmapy);

    ZeroMemory(drawlayer, SizeOf(drawlayer_t));
    ZeroMemory(heightlayer, SizeOf(heightlayer_t));

    LLeftMousePaintTo(X, Y);
  end
  else if button = mbRight then
  begin
    terrain.TerrainToHeightmapIndex(X, Y, iX, iY);
    it := terrain.Heightmap[iX, iY];
    if EditHeightmapItem(it) then
    begin
      SaveUndo(false);
      terrain.Heightmap[iX, iY] := it;
      changed := True;
      PaintBox1.Invalidate;
      glneedsupdate := True;
    end;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then
  begin
    terrain.TerrainToHeightmapIndex(X, Y, hmouseheightmapx, hmouseheightmapy);
    LLeftMousePaintTo(X, Y);
    lmousedownx := X;
    lmousedowny := Y;
    lmousedown := False;
    glneedstexturerecalc := PenSpeedButton1.Down or PenSpeedButton2.Down or PenSpeedButton3.Down;
    glneedsupdate := True; 
    lasthmouseheightmapx := -1;
    lasthmouseheightmapy := -1;
  end;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if lmousedown then
  begin
    terrain.TerrainToHeightmapIndex(X, Y, hmouseheightmapx, hmouseheightmapy);
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
  iX1, iX2, iY1, iY2: integer;
  c, c1, c2: LongWord;
  tsize: integer;
  tline: PLongWordarray;
  newopacity: integer;
  hchanged: boolean;
  hitem: heightbufferitem_t;
begin
  tsize := terrain.texturesize;
  iX1 := GetIntInRange(X - fpensize div 2, 0, tsize - 1);
  iX2 := GetIntInRange(X + fpensize div 2, 0, tsize - 1);
  iY1 := GetIntInRange(Y - fpensize div 2, 0, tsize - 1);
  iY2 := GetIntInRange(Y + fpensize div 2, 0, tsize - 1);

  ftexturescale := GetIntInRange(ftexturescale, MINTEXTURESCALE, MAXTEXTURESCALE);
  
  if PenSpeedButton1.Down then
  begin
    for iY := iY1 to iY2 do
    begin
      tline := terrain.Texture.ScanLine[iY];
      for iX := iX1 to iX2 do
        if drawlayer[iX, iY].pass < fopacity then
        begin
          drawlayer[iX, iY].pass := fopacity;
          c1 := colorbuffer[Round(iX / ftexturescale * 100) mod colorbuffersize, Round(iY / ftexturescale * 100) mod colorbuffersize];
          c2 := RGBSwap(tline[iX]);
          c := coloraverage(c2, c1, fopacity);
          tline[iX] := RGBSwap(c);
        end;
    end;
    DoRefreshPaintBox(Rect(iX1, iY1, iX2, iY2));
    changed := True;
  end
  else if PenSpeedButton2.Down then
  begin
    for iY := iY1 to iY2 do
    begin
      tline := terrain.Texture.ScanLine[iY];
      for iX := iX1 to iX2 do
      begin
        newopacity := pen2mask[iX - X, iY - Y];
        if drawlayer[iX, iY].pass < newopacity then
        begin
          if drawlayer[iX, iY].pass = 0 then
            c2 := RGBSwap(tline[iX])
          else
            c2 := drawlayer[iX, iY].color;
          drawlayer[iX, iY].color := c2;
          drawlayer[iX, iY].pass := newopacity;
          c1 := colorbuffer[Round(iX / ftexturescale * 100) mod colorbuffersize, Round(iY / ftexturescale * 100) mod colorbuffersize];
          c := coloraverage(c2, c1, fopacity);
          tline[iX] := RGBSwap(c);
        end;
      end;
    end;
    DoRefreshPaintBox(Rect(iX1, iY1, iX2, iY2));
    changed := True;
  end
  else if PenSpeedButton3.Down then
  begin
    for iY := iY1 to iY2 do
    begin
      tline := terrain.Texture.ScanLine[iY];
      for iX := iX1 to iX2 do
      begin
        newopacity := pen3mask[iX - X, iY - Y];
        if drawlayer[iX, iY].pass < newopacity then
        begin
          if drawlayer[iX, iY].pass = 0 then
            c2 := RGBSwap(tline[iX])
          else
            c2 := drawlayer[iX, iY].color;
          drawlayer[iX, iY].color := c2;
          drawlayer[iX, iY].pass := newopacity;
          c1 := colorbuffer[Round(iX / ftexturescale * 100) mod colorbuffersize, Round(iY / ftexturescale * 100) mod colorbuffersize];
          c := coloraverage(c2, c1, newopacity);
          tline[iX] := RGBSwap(c);
        end;
      end;
    end;
    DoRefreshPaintBox(Rect(iX1, iY1, iX2, iY2));
    changed := True;
  end
  else if PenSpeedButton4.Down then
  begin
    hchanged := terrain.MoveHeightmapPoint(lmouseheightmapx, lmouseheightmapy, X, Y);
    if hchanged then
    begin
      iX1 := terrain.HeightmapToCoord(lmouseheightmapx) - 2 * terrain.heightmapblocksize;
      iX2 := terrain.HeightmapToCoord(lmouseheightmapx) + 2 * terrain.heightmapblocksize;
      iY1 := terrain.HeightmapToCoord(lmouseheightmapy) - 2 * terrain.heightmapblocksize;
      iY2 := terrain.HeightmapToCoord(lmouseheightmapy) + 2 * terrain.heightmapblocksize;
      DoRefreshPaintBox(Rect(iX1, iY1, iX2, iY2));
      changed := True;
    end;
  end
  else if PenSpeedButton5.Down then
  begin
    hchanged := False;
    if not heightlayer[hmouseheightmapx, hmouseheightmapy].pass then
    begin
      hchanged := True;
      heightlayer[hmouseheightmapx, hmouseheightmapy].pass := True;
      hitem := terrain.Heightmap[hmouseheightmapx, hmouseheightmapy];
      hitem.height := terrain.Heightmap[hmouseheightmapx, hmouseheightmapy].height + fheightsize;
      terrain.Heightmap[hmouseheightmapx, hmouseheightmapy] := hitem;
      changed := True;
    end;
    if hchanged then
    begin
      iX1 := GetIntInRange(X - terrain.heightmapblocksize, 0, tsize - 1);
      iX2 := GetIntInRange(X + terrain.heightmapblocksize, 0, tsize - 1);
      iY1 := GetIntInRange(Y - terrain.heightmapblocksize, 0, tsize - 1);
      iY2 := GetIntInRange(Y + terrain.heightmapblocksize, 0, tsize - 1);
      DoRefreshPaintBox(Rect(iX1, iY1, iX2, iY2));
    end;
  end
  else if PenSpeedButton6.Down then
  begin
    if (hmouseheightmapx <> lasthmouseheightmapx) or (lasthmouseheightmapy <> hmouseheightmapy) then
    begin
      lasthmouseheightmapx := hmouseheightmapx;
      lasthmouseheightmapy := hmouseheightmapy;
      hchanged := terrain.SmoothHeightmap(hmouseheightmapx, hmouseheightmapy, fsmoothfactor);
      if hchanged then
      begin
        changed := True;
        iX1 := GetIntInRange(X - terrain.heightmapblocksize, 0, tsize - 1);
        iX2 := GetIntInRange(X + terrain.heightmapblocksize, 0, tsize - 1);
        iY1 := GetIntInRange(Y - terrain.heightmapblocksize, 0, tsize - 1);
        iY2 := GetIntInRange(Y + terrain.heightmapblocksize, 0, tsize - 1);
        DoRefreshPaintBox(Rect(iX1, iY1, iX2, iY2));
      end;
    end;
  end;
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
    while True do
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
    while True do
    begin
      LLeftMousePaintAt(curx, cury);
      if cury = Y then break;
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

procedure TForm1.CalcPenMasks;
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

  ZeroMemory(@pen2mask, SizeOf(pen2mask));
  ZeroMemory(@pen3mask, SizeOf(pen3mask));
  sqmaxdist := sqr(fpensize div 2);
  for iY := -fpensize div 2 to fpensize div 2 do
  begin
    sqry := iY * iY;
    for iX := -fpensize div 2 to fpensize div 2 do
    begin
      sqdist := iX * iX + sqry;
      if sqdist <= sqmaxdist then
      begin
        pen2mask[iX, iY] := fopacity;
        frac := (1 - sqdist / sqmaxdist) * fopacity;
        pen3mask[iX, iY] := GetIntInRange(round(frac), 0, 100);
      end;
    end;
  end;
end;

procedure TForm1.PenSpeedButton1Click(Sender: TObject);
begin
  PaintBox1.Cursor := crPaint;
  PaintBox1.Invalidate;
end;

procedure TForm1.PenSpeedButton2Click(Sender: TObject);
begin
  PaintBox1.Cursor := crPaint;
  PaintBox1.Invalidate;
end;

procedure TForm1.PenSpeedButton3Click(Sender: TObject);
begin
  PaintBox1.Cursor := crPaint;
  PaintBox1.Invalidate;
end;

procedure TForm1.PenSpeedButton4Click(Sender: TObject);
begin
  PaintBox1.Cursor := crEditMesh;
  PaintBox1.Invalidate;
end;

procedure TForm1.PenSpeedButton5Click(Sender: TObject);
begin
  PaintBox1.Cursor := crElevateMesh;
  PaintBox1.Invalidate;
end;

procedure TForm1.PenSpeedButton6Click(Sender: TObject);
begin
  PaintBox1.Cursor := crSmoothMesh;
  PaintBox1.Invalidate;
end;

procedure TForm1.PasteTexture1Click(Sender: TObject);
var
  tempBitmap: TBitmap;
begin
  // if there is an image on clipboard
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    SaveUndo(true);

    tempBitmap := TBitmap.Create;
    tempBitmap.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(cf_Bitmap), 0);

    tempBitmap.PixelFormat := pf32bit;

    terrain.Texture.Canvas.StretchDraw(Rect(0, 0, terrain.texturesize, terrain.texturesize), tempBitmap);

    tempBitmap.Free;

    changed := True;
    PaintBox1.Invalidate;
    glneedsupdate := True;
    glneedstexturerecalc := True;
  end;
end;

procedure TForm1.GetHeighmapFromBitmap(const tempBitmap1: TBitmap);
var
  tempBitmap2: TBitmap;
  hX, hY: integer;
  c: LongWord;
  pt: TPoint;
  h: integer;
  it: heightbufferitem_t;
begin
  tempBitmap2 := TBitmap.Create;
  tempBitmap2.PixelFormat := pf32bit;
  tempBitmap2.Width := terrain.texturesize;
  tempBitmap2.Height := terrain.texturesize;
  tempBitmap2.Canvas.StretchDraw(Rect(0, 0, tempBitmap2.Width, tempBitmap2.Height), tempBitmap1);

  for hX := 0 to terrain.heightmapsize - 1 do
    for hY := 0 to terrain.heightmapsize - 1 do
    begin
      pt := terrain.HeightmapCoords(hX, hY);
      c := tempBitmap2.Canvas.Pixels[GetIntInRange(pt.X, 0, tempBitmap2.Width - 1), GetIntInRange(pt.Y, 0, tempBitmap2.Height - 1)];
      h := GetIntInRange(Round((GetRValue(c) + GetGValue(c) + GetBValue(c)) / 768 * 2 * HEIGHTMAPRANGE) - HEIGHTMAPRANGE, -HEIGHTMAPRANGE, HEIGHTMAPRANGE);
      it := terrain.Heightmap[hX, hY];
      it.height := h;
      terrain.Heightmap[hX, hY] := it;
    end;

  tempBitmap2.Free;
end;

procedure TForm1.PasteHeightmap1Click(Sender: TObject);
var
  tempBitmap1: TBitmap;
begin
  // if there is an image on clipboard
  if Clipboard.HasFormat(CF_BITMAP) then
  begin
    SaveUndo(false);

    tempBitmap1 := TBitmap.Create;
    tempBitmap1.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(cf_Bitmap), 0);

    tempBitmap1.PixelFormat := pf32bit;
    try
      GetHeighmapFromBitmap(tempBitmap1);
    finally
      tempBitmap1.Free;
    end;

    changed := True;
    PaintBox1.Invalidate;
    glneedsupdate := True;
  end;
end;

procedure TForm1.Scaleheightmap1Click(Sender: TObject);
var
  amul, adiv, aadd: integer;
  hX, hY: integer;
  it: heightbufferitem_t;
begin
  amul := 1;
  adiv := 1;
  aadd := 0;
  if GetScaleHeightmapInfo(amul, adiv, aadd) then
  begin
    SaveUndo(false);
    for hX := 0 to terrain.heightmapsize - 1 do
      for hY := 0 to terrain.heightmapsize - 1 do
      begin
        it := terrain.Heightmap[hX, hY];
        it.height := GetIntInRange(round(it.height * amul / adiv + aadd), -HEIGHTMAPRANGE, HEIGHTMAPRANGE);
        terrain.Heightmap[hX, hY] := it;
      end;
    changed := True;
    PaintBox1.Invalidate;
    glneedsupdate := True;
  end;
end;

procedure TForm1.ExportWADFile1Click(Sender: TObject);
var
  fs: TFileStream;
  ename: string;
begin
  if GetWADExportOptions(terrain, @fexportoptions, ename) then
  begin
    Screen.Cursor := crHourglass;
    try
      BackupFile(ename);
      fs := TFileStream.Create(ename, fmCreate);
      case fexportoptions.engine of
        ENGINE_RAD:
          if fexportoptions.game = GAME_HEXEN then
            ExportTerrainToHexenFile(
              terrain,
              fs,
              @fexportoptions
            )
          else
            ExportTerrainToWADFile(
              terrain,
              fs,
              @fexportoptions
            );
        ENGINE_VAVOOM:
          ExportTerrainToHexenFile(
            terrain,
            fs,
            @fexportoptions
          );
        ENGINE_UDMF:
          ExportTerrainToUDMFFile(
            terrain,
            fs,
            @fexportoptions
          );
        end;
      fs.Free;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TForm1.Copy3dview1Click(Sender: TObject);
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

procedure TForm1.CopyHeightmap1Click(Sender: TObject);
var
  b: TBitmap;
  hX, hY: integer;
  h: integer;
  g: byte;
begin
  b := TBitmap.Create;
  try
    b.Width := terrain.heightmapsize;
    b.Height := terrain.heightmapsize;
    b.PixelFormat := pf24bit;
    for hX := 0 to terrain.heightmapsize - 1 do
      for hY := 0 to terrain.heightmapsize - 1 do
      begin
        h := terrain.Heightmap[hX, hY].height;
        g := GetIntInRange(Round((h + HEIGHTMAPRANGE) * 256 / (2 * HEIGHTMAPRANGE)), 0, 255);
        b.Canvas.Pixels[hX, hY] := RGB(g, g, g);
      end;
    Clipboard.Assign(b);
  finally
    b.Free;
  end;
end;

procedure TForm1.PaletteSpeedButton1Click(Sender: TObject);
var
  p: TPoint;
begin
  p := PaletteSpeedButton1.ClientToScreen(Point(0, PaletteSpeedButton1.Height));
  PalettePopupMenu1.Popup(p.X, p.Y);
  PaletteSpeedButton1.Down := False;
end;

procedure TForm1.PaletteDefault1Click(Sender: TObject);
begin
  fpalettename := spalDEFAULT;
  NotifyFlatsListBox;
end;

procedure TForm1.PaletteDoom1Click(Sender: TObject);
begin
  fpalettename := spalDOOM;
  NotifyFlatsListBox;
end;

procedure TForm1.PaletteHeretic1Click(Sender: TObject);
begin
  fpalettename := spalHERETIC;
  NotifyFlatsListBox;
end;

procedure TForm1.PaletteHexen1Click(Sender: TObject);
begin
  fpalettename := spalHEXEN;
  NotifyFlatsListBox;
end;

procedure TForm1.PaletteStrife1Click(Sender: TObject);
begin
  fpalettename := spalSTRIFE;
  NotifyFlatsListBox;
end;

procedure TForm1.PaletteRadix1Click(Sender: TObject);
begin
  fpalettename := spalRADIX;
  NotifyFlatsListBox;
end;

procedure TForm1.PaletteGreyScale1Click(Sender: TObject);
begin
  fpalettename := spalGRAYSCALE;
  NotifyFlatsListBox;
end;

procedure TForm1.CheckPaletteName;
begin
  if fpalettename <> spalDEFAULT then
    if fpalettename <> spalDOOM then
      if fpalettename <> spalHERETIC then
        if fpalettename <> spalHEXEN then
          if fpalettename <> spalSTRIFE then
            if fpalettename <> spalRADIX then
              if fpalettename <> spalGRAYSCALE then
                fpalettename := spalDEFAULT;
end;

procedure TForm1.PalettePopupMenu1Popup(Sender: TObject);
begin
  PaletteDoom1.Checked := fpalettename = spalDOOM;
  PaletteHeretic1.Checked := fpalettename = spalHERETIC;
  PaletteHexen1.Checked := fpalettename = spalHEXEN;
  PaletteStrife1.Checked := fpalettename = spalSTRIFE;
  PaletteRadix1.Checked := fpalettename = spalRADIX;
  PaletteGreyScale1.Checked := fpalettename = spalGRAYSCALE;
  PaletteDefault1.Checked := fpalettename = spalDEFAULT;
end;

procedure TForm1.MNTools1Click(Sender: TObject);
begin
  MNResampleHeightmapX2.Enabled := terrain.CanResampleHeightMapX2;
end;

procedure TForm1.MNResampleHeightmapX2Click(Sender: TObject);
begin
  if terrain.CanResampleHeightMapX2 then
  begin
    SaveUndo(false);
    terrain.ResampleHeightMapX2;
    TerrainToControls;
    changed := True;
    PaintBox1.Invalidate;
    glneedsupdate := True;
  end;
end;

procedure TForm1.SelectPK3FileButtonClick(Sender: TObject);
begin
  if OpenPK3Dialog.Execute then
  begin
    fpk3filename := ExpandFilename(OpenPK3Dialog.FileName);
    PK3FileNameEdit.Text := ExtractFileName(OpenPK3Dialog.FileName);
    PopulatePK3ListBox(fpk3filename);
  end;
end;

procedure TForm1.PopulatePK3ListBox(const pk3name: string);
var
  i: integer;
  uEntry: string;
  uExt: string;
begin
  fpk3reader.FileName := fpk3filename;
  PK3TexListBox.Items.Clear;
  for i := 0 to fpk3reader.FileCount - 1 do
  begin
    uEntry := UpperCase(fpk3reader.Files[i]);
    uExt := ExtractFileExt(uEntry);
    if (uExt = '.PNG') or (uExt = '.JPG') then
      PK3TexListBox.Items.Add(uEntry);
  end;
  if PK3TexListBox.Count > 0 then
    PK3TexListBox.ItemIndex := 0
  else
    PK3TexListBox.ItemIndex := -1;
  NotifyPK3ListBox;
end;

procedure TForm1.NotifyPK3ListBox;
var
  idx: integer;
  bm: TBitmap;
begin
  ChangeListHint(PK3TexListBox, 'PK3 Textures');
  idx := PK3TexListBox.ItemIndex;
  if (idx < 0) or (fpk3filename = '') or not FileExists(fpk3filename) then
  begin
    PK3TexPreviewImage.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
    PK3TexPreviewImage.Picture.Bitmap.Canvas.Brush.Color := RGB(255, 255, 255);
    PK3TexPreviewImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0, 128, 128));
    PK3TextureNameLabel.Caption := '(none)';
    PK3TexSizeLabel.Caption := Format('(%dx%d)', [128, 128]);
    colorbuffersize := 128;
    FillChar(colorbuffer^, SizeOf(colorbuffer_t), 255);
    exit;
  end;

  Screen.Cursor := crHourglass;
  try
    bm := GetPK3TexAsBitmap(PK3TexListBox.Items[idx]);
  finally
    Screen.Cursor := crDefault;
  end;

  BitmapToColorBuffer(bm);

  colorbuffersize := MinI(bm.Height, MAXTEXTURESIZE);
  PK3TexPreviewImage.Picture.Bitmap.Canvas.StretchDraw(Rect(0, 0, 128, 128), bm);
  PK3TextureNameLabel.Caption := ExtractFileName(PK3TexListBox.Items[idx]);
  PK3TexSizeLabel.Caption := Format('(%dx%d)', [bm.Width, bm.Height]);
  bm.Free;
end;

function TForm1.GetPK3TexAsBitmap(const tname: string): TBitmap;
var
  p: pointer;
  psize: integer;
  jpg: TJpegImage;
  png: TPNGObject;
  uExt: string;
  m: TMemoryStream;
begin
  if fpk3reader.GetZipFileData(tname, p, psize) then
  begin
    m := TMemoryStream.Create;
    m.Write(p^, psize);
    FreeMem(p, psize);

    m.Position := 0;

    uExt := UpperCase(ExtractFileExt(tname));

    if uExt = '.JPG' then
    begin
      jpg := TJpegImage.Create;
      jpg.LoadFromStream(m);
      Result := TBitmap.Create;
      Result.Assign(jpg);
      jpg.Free;
      m.Free;
      Exit;
    end;

    if uExt = '.PNG' then
    begin
      png := TPNGObject.Create;
      png.LoadFromStream(m);
      Result := TBitmap.Create;
      Result.Assign(png);
      png.Free;
      m.Free;
      Exit;
    end;
    m.Free;
  end;

  // Not supported extension ???
  Result := TBitmap.Create;
  Result.Width := 64;
  Result.Height := 64;
  Result.Canvas.Brush.Style := bsSolid;
  Result.Canvas.Brush.Color := RGB(255, 255, 255);
  Result.Canvas.FillRect(Rect(0, 0, 64, 64));
  Exit;
end;

procedure TForm1.PK3TexListBoxClick(Sender: TObject);
begin
  NotifyPK3ListBox;
end;

procedure TForm1.MNImportTexture1Click(Sender: TObject);
var
  f: TLoadImageHelperForm;
begin
  if OpenPictureDialog1.Execute then
  begin
    f := TLoadImageHelperForm.Create(nil);
    try
      f.Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
      SaveUndo(True);
      terrain.Texture.Canvas.StretchDraw(Rect(0, 0, terrain.texturesize, terrain.texturesize), f.Image1.Picture.Graphic);
      glneedstexturerecalc := True;
      glneedsupdate := True;
      changed := True;
      PaintBox1.Invalidate;
    finally
      f.Free;
    end;
  end;
end;

procedure TForm1.MNImportHeightmap1Click(Sender: TObject);
var
  tempBitmap1: TBitmap;
  f: TLoadImageHelperForm;
begin
  if OpenPictureDialog2.Execute then
  begin
    f := TLoadImageHelperForm.Create(nil);
    try
      f.Image1.Picture.LoadFromFile(OpenPictureDialog2.FileName);
      SaveUndo(false);

      tempBitmap1 := TBitmap.Create;
      tempBitmap1.Assign(f.Image1.Picture.Graphic);
      tempBitmap1.PixelFormat := pf32bit;
      try
        GetHeighmapFromBitmap(tempBitmap1);
      finally
        tempBitmap1.Free;
      end;

      changed := True;
      PaintBox1.Invalidate;
      glneedsupdate := True;
    finally
      f.Free;
    end;
  end;
end;

procedure TForm1.PopulateDirListBox;
var
  Rec: TSearchRec;
  uName, uExt: string;
  i: integer;
begin
  if (fdirdirectory = '') or not DirectoryExists(fdirdirectory) then
    fdirdirectory := ExtractFileDir(ParamStr(0));
  if fdirdirectory[Length(fdirdirectory)] <> '\' then
    fdirdirectory := fdirdirectory + '\';
  ClearList(fdirlist);
  if FindFirst(fdirdirectory + '*.*', faAnyFile - faDirectory, Rec) = 0 then
  try
    repeat
      uName := UpperCase(fdirdirectory + Rec.Name);
      uExt := ExtractFileExt(uName);
      if (uExt = '.JPG') or (uExt = '.JPEG') or (uExt = '.BMP') or (uExt = '.TGA') or (uExt = '.PNG') then
        fdirlist.AddObject(MkShortName(fdirdirectory + Rec.Name, DIRTexListBoxNameSize), TString.Create(fdirdirectory + Rec.Name));
    until FindNext(Rec) <> 0;
  finally
    FindClose(Rec);
  end;
  DIRTexListBox.Items.Clear;
  for i := 0 to fdirlist.Count - 1 do
    DIRTexListBox.Items.AddObject(fdirlist.Strings[i], fdirlist.Objects[i]);
  if DIRTexListBox.Items.Count > 0 then
    DIRTexListBox.ItemIndex := 0;
  NotifyDIRListBox;
end;

procedure TForm1.NotifyDIRListBox;
var
  idx: integer;
  bm: TBitmap;
  f: TLoadImageHelperForm;
begin
  ChangeListHint(DIRTexListBox, 'Disk Textures');
  idx := DIRTexListBox.ItemIndex;
  if (idx < 0) or (idx >= fdirlist.Count) or not FileExists((fdirlist.Objects[idx] as TString).str) then
  begin
    DIRTexPreviewImage.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
    DIRTexPreviewImage.Picture.Bitmap.Canvas.Brush.Color := RGB(255, 255, 255);
    DIRTexPreviewImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0, 128, 128));
    DIRTextureNameLabel.Caption := '(none)';
    DIRTexSizeLabel.Caption := Format('(%dx%d)', [128, 128]);
    colorbuffersize := 128;
    FillChar(colorbuffer^, SizeOf(colorbuffer_t), 255);
    exit;
  end;

  Screen.Cursor := crHourglass;

  f := TLoadImageHelperForm.Create(nil);
  bm := TBitmap.Create;
  bm.PixelFormat := pf32bit;
  bm.Width := 128;
  bm.Height := 128;
  try
    f.Image1.Picture.LoadFromFile((fdirlist.Objects[idx] as TString).str);
    bm.Assign(f.Image1.Picture.Graphic);
  finally
    f.Free;
  end;

  Screen.Cursor := crDefault;

  BitmapToColorBuffer(bm);

  colorbuffersize := MinI(bm.Height, MAXTEXTURESIZE);
  DIRTexPreviewImage.Picture.Bitmap.Canvas.StretchDraw(Rect(0, 0, 128, 128), bm);
  DIRTextureNameLabel.Caption := ExtractFileName((fdirlist.Objects[idx] as TString).str);
  DIRTexSizeLabel.Caption := Format('(%dx%d)', [bm.Width, bm.Height]);
  bm.Free;
end;

function TForm1.DIRTexListBoxNameSize: integer;
begin
  Result := 32 + (DIRTexListBox.Width - 236) div 7;
end;

function TForm1.DIRTexEditNameSize: integer;
begin
  Result := DIRFileNameEdit.Width div 7;
end;

procedure TForm1.DIRTexListBoxClick(Sender: TObject);
begin
  NotifyDIRListBox;
end;

procedure TForm1.SelectDIRFileButtonClick(Sender: TObject);
var
  newdir: string;
begin
  newdir := fdirdirectory;
  if SelectDirectory('Select textures folder', '', newdir) then
  begin
    if newdir <> '' then
      if newdir[Length(newdir)] <> '\' then
        newdir := newdir + '\';
    if newdir <> fdirdirectory then
    begin
      fdirdirectory := newdir;
//      DIRFileNameEdit.Text := MkShortName(fdirdirectory, DIRTexEditNameSize);
      DIRFileNameEdit.Text := fdirdirectory;
      PopulateDirListBox;
    end;
  end;
end;

procedure TForm1.Splitter1Moved(Sender: TObject);
var
  i, idx: integer;
begin
  idx := DIRTexListBox.ItemIndex;
  DIRTexListBox.Items.Clear;
  for i := 0 to fdirlist.Count - 1 do
    DIRTexListBox.Items.AddObject(mkshortname((fdirlist.Objects[i] as TString).str, DIRTexListBoxNameSize), fdirlist.Objects[i]);
  DIRTexListBox.ItemIndex := idx;
  RecreateColorPickPalette;
end;

procedure TForm1.WADFileNameEditChange(Sender: TObject);
begin
  WADFileNameEdit.Hint := WADFileNameEdit.Text;
end;

procedure TForm1.PK3FileNameEditChange(Sender: TObject);
begin
  PK3FileNameEdit.Hint := PK3FileNameEdit.Text;
end;

procedure TForm1.DIRFileNameEditChange(Sender: TObject);
begin
  DIRFileNameEdit.Hint := DIRFileNameEdit.Text;
end;

procedure TForm1.ChangeListHint(const lst: TListBox; const def: string);
var
  idx: integer;
begin
  idx := lst.ItemIndex;
  if idx >= 0 then
  begin
    if lst.Items.Objects[idx] <> nil then
      lst.Hint := (lst.Items.Objects[idx] as TString).str
    else
      lst.Hint := lst.Items.strings[idx];
  end
  else
    lst.Hint := def;
end;

procedure TForm1.TexturePageControlChange(Sender: TObject);
begin
  case TexturePageControl.ActivePageIndex of
  0: NotifyFlatsListBox;
  1: NotifyPK3ListBox;
  2: NotifyDIRListBox;
  3:
    begin
      RecreateColorPickPalette;
      NotifyColor;
    end;
  end;
end;

procedure TForm1.ColorPickerButton1Click(Sender: TObject);
begin
  ColorDialog1.Color := ColorPickerButton1.Color;
  if ColorDialog1.Execute then
  begin
    fdrawcolor := ColorDialog1.Color;
    NotifyColor;
  end;
end;

procedure TForm1.ColorPickerButton1Change(Sender: TObject);
begin
  fdrawcolor := ColorPickerButton1.Color;
  NotifyColor;
end;

procedure TForm1.NotifyColor;
var
  x, y: integer;
begin
  ColorPickerButton1.Color := fdrawcolor;
  PickColorRGBLabel.Caption := Format('RGB(%d, %d, %d)', [GetRValue(fdrawcolor), GetGValue(fdrawcolor), GetBValue(fdrawcolor)]);
  if colorbuffer = nil then
    Exit;
  colorbuffersize := 64;
  for x := 0 to 63 do
    for y := 0 to 63 do
      colorbuffer[x, y] := fdrawcolor;
end;

procedure TForm1.RecreateColorPickPalette;
var
  m: TMemoryStream;
  bmz: TZBitmap;
  w, h: integer;
begin
  m := TMemoryStream.Create;
  m.Write(ColorPaletteBMZ, SizeOf(ColorPaletteBMZ));
  m.Position := 0;
  bmz := TZBitmap.Create;
  bmz.LoadFromStream(m);
  m.Free;
  w := ColorPaletteImage.Width;
  h := ColorPaletteImage.Height;
  ColorPaletteImage.Picture.Bitmap.Width := w;
  ColorPaletteImage.Picture.Bitmap.Height := h;
  ColorPaletteImage.Picture.Bitmap.Canvas.StretchDraw(Rect(0, 0, w, h), bmz);
  bmz.Free;
end;

procedure TForm1.PickColorPalettePanelCanResize(Sender: TObject;
  var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  RecreateColorPickPalette;
end;

procedure TForm1.PickColorPalette(const X, Y: integer);
var
  x2, y2: integer;
begin
  x2 := GetIntInRange(X, 0, ColorPaletteImage.Picture.Bitmap.Width - 1);
  y2 := GetIntInRange(Y, 0, ColorPaletteImage.Picture.Bitmap.Height - 1);
  fdrawcolor := ColorPaletteImage.Picture.Bitmap.Canvas.Pixels[x2, y2];
  NotifyColor;
end;

procedure TForm1.ColorPaletteImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then
  begin
    lpickcolormousedown := True;
    PickColorPalette(X, Y);
  end;
end;


procedure TForm1.ColorPaletteImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if lpickcolormousedown then
    PickColorPalette(X, Y);
end;

procedure TForm1.ColorPaletteImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then
  begin
    lpickcolormousedown := False;
    PickColorPalette(X, Y);
  end;
end;

procedure TForm1.ExportHeightmap1Click(Sender: TObject);
var
  bmh: bitmapheightmap_p;
  x, y: integer;
  b: TBitmap;
  imgfname: string;
  l: PLongWordArray;
  g: integer;
begin
  if SavePictureDialog2.Execute then
  begin
    Screen.Cursor := crHourglass;
    imgfname := SavePictureDialog2.FileName;
    BackupFile(imgfname);
    b := TBitmap.Create;
    try
      GetMem(bmh, SizeOf(bitmapheightmap_t));
      terrain.GenerateBitmapHeightmap(bmh, MAXBITMAPHEIGHTMAP);
      b.Width := MAXBITMAPHEIGHTMAP;
      b.Height := MAXBITMAPHEIGHTMAP;
      b.PixelFormat := pf32bit;
      for y := 0 to b.Height - 1 do
      begin
        l := b.ScanLine[y];
        for x := 0 to b.Width - 1 do
        begin
          g := bmh[x, y];
          g := GetIntInRange(Round((g + HEIGHTMAPRANGE) * 256 / (2 * HEIGHTMAPRANGE)), 0, 255);
          l[x] := RGB(g, g, g);
        end;
      end;
      FreeMem(bmh, SizeOf(bitmapheightmap_t));
      SaveImageToDisk(b, imgfname);
    finally
      b.Free;
    end;
    Screen.Cursor := crDefault;
  end;

end;

procedure TForm1.TextureScaleResetLabelDblClick(Sender: TObject);
begin
  ftexturescale := 100;
  UpdateSliders;
  SlidersToLabels;
end;

procedure TForm1.MNExpoortTexture1Click(Sender: TObject);
var
  imgfname: string;
begin
  if SavePictureDialog3.Execute then
  begin
    Screen.Cursor := crHourglass;
    try
      imgfname := SavePictureDialog3.FileName;
      BackupFile(imgfname);
      SaveImageToDisk(terrain.Texture, imgfname);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

end.

