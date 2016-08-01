
         LLCL - FPC/Lazarus Light LCL
               based upon
         LVCL - Very LIGHT VCL
         ----------------------------


  The Light LCL (LLCL) is intended to provide a way to produce
small executable files with Free Pascal/Lazarus or Delphi 7,
while being compatible with - a part of - the LCL/VCL. It may
concern for instance: small installation or configuration
programs, simple tools, test programs, ... Typically, the size
is about 1/10th with Free Pascal/Lazarus and 1/5th with Delphi
for small and simple programs.

  It's not a specific graphical library, or another widgetset.
It's an emulation of a small subset of the standard LCL/VCL,
for only the most basic controls and classes, with their most
common properties, methods and events. Of course, it implies
that only the controls and properties present in the Light LCL
can be used.

  There is nothing to install in order to use it, nor any
configuration to modify: just indicate a valid path for the
Light LCL files into your project options, and that's it !

  It's available only for Windows (32 and 64 bits). It has
been tested with FPC 2.6.x/3.x + Lazarus 1.4.x/1.6 and
Delphi 7.


1. HISTORY
----------

  The concept of the Light VCL for Delphi has been introduced
by Paul Toth (VCL Light), formally constructed and improved by
Arnaud Bouchez, and is currently maintained by Synopse's
people (including A. Bouchez).

  The Light LCL (LLCL) is the Free Pascal/Lazarus version of
the Light VCL (LVCL), with some additions and modifications.

LLCL ChangeLog:

* Version 1.02:
  Main changes and additions:
  - TRadioGroup control added (not enabled by default),
  - TRegistry class added (Registry.pas),
  - TClipboard: SetAsText bug fix,
  - TStringGrid: ColCount and RowCount bug fix,
  - bug fixes when application was starting and closing,
  - bug fixes and non standard ItemStrings property removed
    for internal TCustomBox class,
  - TForm: ShowModal bug fix (with several modal forms),
  - DeleteFile and RenameFile added (SysUtils), and also
    DeleteFileUTF8 and RenameFileUTF8 (FileUtil/LazFileUtils),
  - internal TMemoLines et TBoxStrings classes (for TMemo and
    TComboBox/TListBox controls) modified for a better LCL/VCL
    compatibility (data accessing).
* Version 1.01:
  Main changes and additions:
  - TStringGrid control added (Grids.pas),
  - TIniFile class added (IniFiles.pas),
  - TClipboard class added for text data (ClipBrd.pas),
  - PNG images support (not enabled by default),
  - transparent bitmaps support (not enabled by default),
  - forms double buffering support (not enabled by default),
  - TSelectDirectoryDialog control added (Dialog.pas) for
    FPC/Lazarus (not enabled by default) and SelectDirectory
    function (Dialog.pas or FileCtrl.pas),
  - ANSI LLCL option (i.e. no UTF8 at all) added for
    FPC/Lazarus (see in LLCLFPCInc.inc),
  - design time only properties for controls are now
    accessible for dynamic creation purposes. Run time
    modifications are still not supported for them, but they
    can now be set at run time before the corresponding
    control is dynamically created,
  - a few bug fixes and some minor additions/modifications.
  Note: controls and functionalities not enabled by default
  can be activated by defining the corresponding option(s) in
  the option file LLCLOptions.inc.

* Version 1.00:
  - Initial public release.


2. DISCLAIMER AND LICENSE
-------------------------

  Preliminary note: the former content (LVCL) has been
released under the Mozilla Public License version 1.1. So ...

  This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

  See the "LICENSE.txt" file for a copy of the MPL.

Copyright (c) 2015-2016 ChrisF

Based upon the Very LIGHT VCL (LVCL):
Copyright (c) 2008 Arnaud Bouchez - http://bouchez.info
Portions Copyright (c) 2001 Paul Toth - http://tothpaul.free.fr

  Note: as the LVCL has been released under the MPL version
1.1, this Source Code Form is "Incompatible With Secondary
Licenses", as defined by the Mozilla Public License, v. 2.0.

More simply (i.e. my own interpretation):
  In simple terms, it means that you can use it in a common
way without any particular obligations, and for any kind of
program: closed or open source, free or commercial. But, if
you modify the LLCL code and distribute publicly a program
using this modified code, you must provide a way to get the
corresponding modified code of the LLCL (i.e. you must
"distribute" your modified version of the LLCL).
  From a practical point of view, when using the LLCL the MPL
license can be considered as more or less equivalent to the
modified LGPL license used for the standard LCL of Lazarus.


3. DESCRIPTION
---------------

  The files/units present in the Ligth LCL replace the main
standard files/units used inside the LCL/VCL: Classes,
ClipBrd, ComCtrls, Controls, Dialogs, ExtCtrls, FileCtrl,
Forms, Graphics, Grids, IniFiles, Menus, Registry, StdCtrls,
SysUtils and Variants.

  Plus an additional unit for the VCL: XPMan.

  And a few other ones for the LCL: FileUtil, Interfaces,
LazFileUtils, LazUTF8, LazUTF8Classes, LCLIntF, LCLType and
LMessages.

  Some of these units are just 'dummy' (i.e. empty) units,
provided for compatibility reasons.

  There are also a few additional internal files:

- Vista.res and VistaAdm.res: resource files containing a
  Windows manifest (used only for Delphi in XPMan),
- LLCLOSInt.pas: interface unit for the Windows APIs,
- LLCLFPCInc.inc: include file containing compilation
  directives (used only for FPC/Lazarus),
- LLCLOptions.inc: include file with various possible
  compilation options for the LLCL,
- LLCLPng.pas and LLCLZlib.pas: internal unit files for the
  PNG support and the ZLib interface.


4. HOW TO USE THE LIGHT LCL
---------------------------

  Put all the LLCL files into a new directory (DO NOT
OVERWRITE the standard LCL/VCL files - for instance, create a
subdirectory in your project directory and call it LLCLUnits),
and just add the corresponding path for the LLCL files into
your project options, in order they are used instead of the
standard LCL/VCL ones:

- for FPC/Lazarus (-Fu compiler option):
  Project->Project Options->Compiler options->Paths->
           Other unit files

- for Delphi:
  Project->Options->Directories/Conditions->Search path

  Additionally, in order to minimize the size of the final
executable file for FPC/Lazarus, here are a few more options
to apply to your projects:

- as usual, uncheck the debugging info generation:
  Project->Project Options->Compiler options->Debugging->
           Generate debugging info for GDB
- use compilation optimizations level 2 (quick) or 3 (slow):
  Project->Project Options->Compiler options->Compilation
           and Linking->Optimization levels
- use a smaller icon than the default one for your program.
  The by-default icon for a project created with FPC/Lazarus
  (i.e. [yourproject].ico) includes several versions of icons,
  with various sizes and various numbers of colors: but, the
  final icon file size is about 134 Kb. Use instead only one
  small icon: for instance one with 32x32x256 size*colors
  (3 Kb), or with 32x32x16 size*colors (only 1 Kb).

  And both for FPC/Lazarus and Delphi:

- remove the LLCL units not needed into your code (in the
  'uses' clauses). Especially, remove the Dialogs unit (added
  automatically by default in a new project) if this unit is
  not needed. Units especially concerned by this remark:
  ComCtrls, Dialogs and ExtCtrls.


5. LINKS
--------

Download link for the Light LCL (LLCL) sources:
https://github.com/FChrisF/LLCL

Additional various sample projects (demos) using it :
https://github.com/FChrisF/LLCL-samples

Connected links:
Paul Toth:  http://tothpaul.free.fr
Arnaud Bouchez:  http://bouchez.info
Synopse:  http://synopse.info
Very Light VCL sources:  https://github.com/synopse/LVCL
Free Pascal:  http://www.freepascal.org
Lazarus:  http://www.lazarus-ide.org
Delphi: http://www.embarcadero.com

FreePascal/Lazarus forum for discussion:
http://forum.lazarus.freepascal.org/index.php/topic,30027.0.html


6. GENERAL NOTES
----------------

. It's impossible to use any components or units of the
  standard LCL/VCL in combination with the LLCL. This also
  includes packages using the LCL/VCL.

. Some other standard (i.e. FPC/Lazarus or Delphi) units may
  or may not be used with the LLCL. More particularly:
  - can be used: SysUtils (with an extra size penalization),
  Variants (only with the standard SysUtils unit), Types (not
  included into the LLCL files),
  - cannot be used: Classes (at least not without some
  modifications - see the "GetWebPage" sample).
  To use one standard unit instead of its corresponding LLCL
  unit in your projects, rename or delete it into the LLCL
  directory. See also the next paragraph in this case.

. It's possible to switch back and forth between the LLCL and
  the LCL/VCL for a given project. In each case, a full build
  ("Build" Shift+F9) is preferable. However, when switching
  from the LLCL to the VCL/LCL, it's not sufficient for
  FPC/Lazarus if the source files of the LLCL have been used:
  because the binary files of the LLCL are then still present.
  Here are the steps to use in both cases:
  * From the LCL/VCL to the LLCL:
    1/ add the path for the LLCL files into the project
       options,
    2/ build the project.
  * From the LLCL to the LCL/VCL:
    1/ remove the path for the LLCL files into the project
       options, or rename/delete the corresponding LLCL file
       (for using a standard LCL/VCL file like SysUtils, for
       instance),
    2/ if the source files of the LLCL have been used, delete
       the corresponding binary file(s) in the binary
       directory of the project: usually, \lib\i386-win32 or
       \lib\x86_64-win64 for FPC/Lazarus (you can eventually
       delete the whole \lib directory). This step is also
       necessary (Delphi included, this time) if one file of
       the LLCL has been renamed/deleted to use the standard
       LCL/VCL one instead. For Delphi, rename/delete also
       the corresponding .dcu files in the LLCL directory,
    3/ build the project.

. Besides that, binary files for the LLCL (i.e. LLCL source
  files already compiled) can also be used. There are pros
  and cons for both solutions.

. Binaries produced for the 64 bits version of Windows are
  bigger than for the 32 bits version (about one third).

. For FPC/Lazarus, LLCL files can be compiled with either
  the "objfpc" (default) or the "delphi" mode (see the
  LLCLFPCInc include file in the mode section).

. Some compilation directives for the LLCL are available in
  the LLCLOptions.inc file. Their main aims are to permit to
  reduce a little bit more the size of the final executable
  file, or to adjust more precisely some functionalities
  supported by the LLCL. See in the include file itself for
  the option list, and for pieces of information for each of
  these options. It's also possible to use global defines for
  these options in the project options (see the "Visual"
  sample for this later case).

. Unknown properties (i.e. properties not supported by the
  LLCL) present in the lfm/dfm files are just ignored; as for
  unknown events (see hereafter). Unknown controls provoke an
  error, and terminate the program; as for events present in
  the lfm/dfm files and not in the corresponding unit.

. Though not recommended, it's possible to make conditional
  compilation for programs using the LLCL by testing the
  "Declared(LLCLVersion)" assertion (i.e. {$if ...}). The
  Forms unit must be used in this case.

. Controls can be created at run time, but with some
  limitations. The main exception is menus (TMainMenu and
  TPopupMenu), which can't be created at run time.

. Though they are not supposed to be seen by the final user,
  it's possible to use an external include file for the LLCL
  message strings (mostly error/exception and debug), for
  translation purposes. See LLCL_STR_USE_EXTINC in the
  LLCLOSInt unit (ANSI and/or UTF8 version).

. Using the Windows APIs is often necessary, when missing
  functionalities/controls in the LLCL are needed.

. For FPC/Lazarus and with FPC version 3.x or later, it's
  possible to use an experimental UTF16 version of the LLCL
  (i.e. "Unicode" version of Free Pascal). Select one of the
  UTF16 modes in the LLCLFPCInc include file ("unicodestrings"
  or "delphiunicode"), and PUT IT ALSO in your own units.
  Notes:
  - some of the SysUtils functions are currently absent in the
    UTF16 version of the LLCL,
  - only a part of the System/RTL functions are available for
    the "Unicode" version of Free Pascal. As a consequence,
    using the standard SysUtils unit in the LLCL will display
    several implicit conversions and relative warnings during
    the compilation,
  - only the Unicode Windows APIs are then used (though it's
    still possible to use the LLCL_OPT_UNICODE_API_XXXX
    options to modify this),
  - the "-FcUTF8" option must be then used for the whole
    project, or the "{$codepage UTF8}" directive must be added
    to all your program units. If the "delphiunicode" mode is
    choosen, the "{$codepage UTF8}" directive in all your
    units is then mandatory (i.e. the "-FcUTF8" option is not
    sufficient).

. For FPC/Lazarus, it's possible to use a "pure" ANSI version
  of the LLCL (note: it is not really the same thing as the
  "DisableUTF8RTL" option of the standard LCL version 1.6):
  see the LLCL_FPC_ANSI_ONLY option in LLCLFPCInc.inc. In this
  later case, you must also save your own program units in the
  corresponding ANSI encoding type, and not use the by-default
  UTF8 encoding type. With this mode, only the ANSI Windows
  APIs are then used (though it's still possible to use the
  LLCL_OPT_UNICODE_API_XXXX options to modify this). For
  compatibility reasons, UTF8 functions (especially UTF8ToSys
  and SysToUTF8) are not making any conversions when used in
  this mode (mainly concerns FPC 2.6.x).


7. EMULATION MINI DOCUMENTATION
-------------------------------


7.1 CONTROL CLASSES AVAILABLE
-----------------------------

Standard: TLabel, TButton, TEdit, TMemo, TCheckBox,
          TRadioButton, TGroupBox, TComboBox, TListBox,
          TStaticText, TMainMenu, TPopupMenu, TRadioGroup
Additional: TImage,  TTrayIcon, TStringGrid
Common: TProgressBar, TTrackBar, TXPManifest (Delphi)
Dialogs: TOpenDialog, TSaveDialog, TSelectDirectoryDialog
         (FPC only, and not enabled by default)
System: TTimer

Other classes: TCustomForm, TForm, TClipboard, TIniFile,
               TRegistry

General variables: Application (TApplication), Mouse(TMouse),
    Clipboard(TClipboard)


7.2 BASE CLASSES TREE
---------------------

                    (TObject)
                       !
                   TPersistent
                       !
                   TComponent
                       !
                    TControl
       ----------------!----------------
       !                               !
TNonVisualControl*               TVisualControl*
                         -------------!-------------
                         !                         !
                   TGraphicControl           TWinControl
                                                   !
                                           (TCustomControl)**
*: Specific to the LLCL
**: Not used in the LLCL


7.3 CLASSES DETAILS
--------------------

  Standard public methods, properties and events available
[rwd] options: r=read, w=write, d=design time.

  "Design time" meaning: can bet set only inside the IDE
(i.e. in the dfm/lfm files), or in code for controls created
dynamically before their "real" creation (i.e. before affected
to their TWinControl parent).

  Preliminary note: generally speaking, they are usually
simplified and so, are supposed to work properly for the
common case(s) only.


7.3.1 PROPERTY CLASSES DETAILS
------------------------------

TStaticHandle (Graphic - object)
  property  Color: integer; [rw]
Note: TStaticHandle is specific to the LLCL

TBrush (Graphic - TStaticHandle)
  property  Handle: THandle; [r]
  property  Style: TBrushStyle; [rw]

TPen (Graphic - TStaticHandle)
  procedure Select(Canvas: HDC);
  property  Width: integer; [rw]

TCanvas (Graphic - TObject)
  Brush: TBrush;
  Pen: TPen;
  destructor  Destroy; override;
  procedure FillRect(const R: TRect);
  procedure FrameRect(const Rect: TRect; cl1,cl2: integer);
  procedure LineTo(x,y: integer);
  procedure MoveTo(x,y: integer);
  procedure Rectangle(x1,y1,x2,y2: integer);
  procedure TextOut(x,y: integer; const s: string);
  procedure TextRect(const Rect: TRect; x,y: integer; const s:string);
  function  TextWidth(const s: string): integer;
  function  TextHeight(const s: string): integer;
  property  Font: TFont; [rw]
  property  Handle: THandle; [rw]

TFont (Graphic - TPersistent)
  destructor Destroy; override;
  procedure Assign(AFont: TFont);
  property  Color: integer; [rwd]
  property  Handle: THandle; [r]
  property  Height: integer; [rwd]
  property  Name: string; [rwd]
  property  Style: TFontStyles; [rwd]

TList (Classes - TObject)
  destructor Destroy; override;
  function  Add(item: pointer): integer;
  procedure Clear;
  procedure Delete(index: integer);
  function  IndexOf(item: pointer): integer;
  procedure Insert(index: integer; item: pointer);
  procedure Remove(item: pointer);
  property  Capacity: integer; [rw]
  property  Count: integer; [rw]
  property  Items[index: integer]: pointer; default; [rw]
  property  List: PPointerList; [r]

TObjectList (Classes - TList)
  constructor Create;

TStringList (Classes - TObject)
  function  Add(const s: string): integer;
  function  AddObject(const s: string; AObject: TObject): integer;
  procedure AddStrings(SomeStrings: TStringList);
  procedure Clear;
  procedure CustomSort(Compare: TStringListSortCompare);
  procedure Delete(index: integer);
  function  IndexOf(const s: string): integer;
  function  IndexOfName(const ObjName: string; const Separator: string='='): integer;
  function  IndexOfObject(item: pointer): integer;
  procedure LoadFromFile(const FileName: string);
  function  NameOf(const Value: string; const Separator: string='='): string;
  procedure SaveToFile(const FileName: string);
  function  TextLen(): integer;
  function  ValueOf(const ObjName: string; const Separator: string='='): string;
  property  CaseSensitive: boolean; [rw]
  property  Count: integer; [r]
  property  Objects[index: integer]: TObject; [rw]
  property  Strings[index: integer]: string; default; [rw]
  property  Text: string; [rw]

TStrings = TStringList

TCtrlStrings (StdCtrls - TPersistent)
  constructor Create(ParentCtrl: TWinControl);
  destructor  Destroy; override;
  function  Add(const S: string): integer; virtual;
  procedure Clear; virtual;
  property  Count: integer; [r]
Note: TCtrlStrings is specific to the LLCL

TMemoLines (StdCtrls - TCtrlStrings)
  function  Add(const S: string): integer; override;
  procedure Clear; override;
  property  Strings[index: integer]: string; default; [r]
Note: TMemoLines is specific to the LLCL

TBoxStrings (SdtCtrls - TCtrlStrings)
  function  Add(const S: string): integer; override;
  procedure Clear; override;
  property  Items[index: integer]: string; default; [r]
Note: TBoxStrings is specific to the LLCL

TCustomBox (SdtCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure Clear;
  property  ItemCount: integer; [r]
  property  ItemIndex: integer; [rwd]
  property  Items: TBoxStrings; [r]
  property  Sorted: boolean; [d]
Note: TCustomBox is specific to the LLCL

TGraphicData (Graphics - TPersistent)
  destructor  Destroy; override;
  property  Data: array of byte; [d]
  property  OnChange: TNotifyEvent; [rw]
Note: TGraphicData is specific to the LLCL

TBitmap (Graphics - TGraphicData)
  procedure Assign(ABitmap: TBitmap);
  procedure LoadFromResourceName(Instance: THandle; const ResName: string);
  procedure LoadFromFile(const FileName: string);
  property  Empty: boolean; [r]

TPicture (Graphics - TPersistent)
  destructor  Destroy; override;
  procedure Assign(APicture: TPicture);
  procedure LoadFromResourceName(Instance: THandle; const ResName: string); *
  procedure LoadFromFile(const FileName: string);
  property  Bitmap: TBitmap; [rw]
  property  OnChange: TNotifyEvent; [rw]
*: only with Free Pascal/Lazarus

TIcon (Graphics - TGraphicData)
  destructor Destroy; override;
  property  Handle: THandle; [rw]

TMenuItem (Menus - TControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  property  AutoCheck: boolean; [rwd]
  property  Caption: string; [rwd]
  property  Checked: boolean; [rwd]
  property  Enabled: boolean; [rwd]
  property  Handle: THandle; [r]
  property  Items[Index: integer]: TMenuItem; default; [rd]

TMenu (Menus - TControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  property  Handle: THandle; [r]
  property  Items: TMenuItem; [rd]


7.3.2 BASE CLASSES DETAILS
--------------------------

TPersistent (Classes - TObject)
  (None)

TComponent (Classes - TPersistent)
  constructor Create(AOwner: TComponent); virtual;
  destructor  Destroy; override;
  function  FindComponent(const CompName: string): TComponent;
  function  GetParentComponent(): TComponent; virtual;
  property  ComponentCount: integer; [r]
  property  Components: TObjectList; [r]
  property  Name: string; [rw]
  property  Owner: TComponent; [r]
  property  Tag: NativeUInt; [rwd]

TControl (Controls - TComponent)
  property  Parent: TWinControl; [rw]
  property  OnClick: TNotifyEvent; [rwd]

TNonVisualControl (Controls - TControl)
  constructor Create(AOwner: TComponent); override;
Note: TNonVisualControl is specific to the LLCL

TVisualControl (Controls - TControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  function  ClientRect(): TRect; virtual;
  procedure Hide; virtual;
  procedure Invalidate;
  procedure Refresh;
  procedure Repaint;
  procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); virtual;
  procedure Show; virtual;
  procedure Update; virtual;
  property  Alignment: [rd] *
  property  AutoSize; [rwd]
  property  Canvas: TCanvas; [r]
  property  Caption: string; [rwd]
  property  Color: integer; [rwd]
  property  Font: TFont; [rwd]
  property  Height: integer; [rwd]
  property  Left: integer; [rwd]
  property  ParentFont; [rwd]
  property  Top: integer; [rwd]
  property  Transparent: boolean; [rwd]
  property  Visible: boolean; [rwd]
  property  Width: integer; [rwd]
  property  OnShow: TNotifyEvent; [rwd]
*: Present in corresponding controls for standard LCL/VCL
Note: TVisualControl is specific to the LLCL

TGraphicControl (Controls - TVisualControl)
  procedure Hide; override;
  procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
  procedure Show; override;

TWinControl (Controls - TVisualControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure BringToFront; *
  function  CanFocus(): boolean;
  function  ClientRect(): TRect; override;
  procedure DefaultHandler(var Message); override;
  function  Focused(): boolean;
  procedure Hide; override;
  procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
  procedure SetFocus();
  procedure Show; override;
  procedure Update; override;
  property  ControlCount: integer; [rw]
  property  Controls: TList; [r]
  property  Enabled: boolean; [rwd]
  property  Handle: THandle; [rw]
  property  TabOrder: integer; [rwd]
  property  TabStop: boolean; [rwd]
  property  Text; [d]
  property  OnDblClick: TNotifyEvent; [rwd]
  property  OnKeyDown: TKeyEvent; [rwd]
  property  OnKeyPress: TKeyPressEvent; [rwd]
  property  OnKeyUp: TKeyEvent; [rwd]
  property  OnMouseDown: TMouseEvent; [rwd]
  property  OnMouseUp: TMouseEvent; [rwd]
*: Present in TControl for standard LCL/VCL
Note: it's also possible to use (from the protected part)
  procedure CreateParams(var Params: TCreateParams); virtual;

TCustomControl (Controls - TWinControl)
  (None)


7.3.3 CONTROLS CLASSES DETAILS
------------------------------

TButton (StdCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  property  Cancel: boolean; [rwd]
  property  Default: boolean; [rwd]

TCheckBox (SdtCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  property  AllowGrayed: boolean; [rwd]
  property  Checked: boolean; [rwd]
  property  State: TCheckBoxState; [rwd]

TComboBox (SdtCtrls - TCustomBox)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure SelectAll;
  property  DroppedDown: boolean; [rw]
  property  Style: TComboBoxStyle; [d]
  property  Text: string; [rwd]
  property  OnChange: TNotifyEvent; [rwd]

TEdit (StdCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  procedure SelectAll;
  property  PasswordChar: Char; [d]
  property  ReadOnly: boolean; [rwd]
  property  Text: string; [rwd]
  property  OnChange: TNotifyEvent; [rwd]

TGroupBox (SdtCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;

TImage (ExtCtrl - TGraphicControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  property  Picture: TPicture; [rwd]
  property  Stretch: boolean; [rwd]

TLabel (StdCtrls - TGraphicControl)
  constructor Create(AOwner: TComponent); override;
  property  WordWrap: boolean; [d]
Note: TLabel is a TStaticText subclass, if LLCL_OPT_STDLABEL
      is not defined

TListBox (SdtCtrls - TCustomBox)
  constructor Create(AOwner: TComponent); override;

TMainMenu (Menus - TMenu)
  constructor Create(AOwner: TComponent); override;

TMemo (StdCtrls - TEdit)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure Clear;
  property  Lines: TMemoLines; [rd]
  property  ScrollBars: TScrollStyle; [d]
  property  WantReturns: boolean; [rwd]
  property  WantTabs: boolean; [rwd]
  property  WordWrap: boolean; [d]

TPopupMenu (Menus - TMenu)
  constructor Create(AOwner: TComponent); override;
  procedure Popup(X, Y: integer);

TRadioButton (SdtCtrls - TCheckBox)
  constructor Create(AOwner: TComponent); override;

TRadioGroup (ExtCtrls - TGroupBox)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  property  ColumnLayout: TColumnLayout; [rw] *
  property  Columns: integer; [rw]
  property  ItemIndex: integer; [rw]
  property  Items: TRadioGroupStrings; [r]
*: only for FPC/Lazarus
Note: available only if LLCL_OPT_USERADIOGROUP is defined (see
the option file LLCLOptions.inc)

TStaticText (SdtCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  property  BorderStyle: boolean; [d]

TOpenDialog (Dialogs - TNonVisualControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  function Execute: boolean; virtual;
  property DefaultExt: string; [rwd]
  property FileName: string; [rwd]
  property Files: TStringList; [rw]
  property Filter: string; [rwd]
  property FilterIndex: integer; [rwd]
  property InitialDir: string; [rwd]
  property Options: TOpenOptions; [rwd]
  property Title: string; [rwd]
Note: available only if LLCL_OPT_USEDIALOG is not undefined

TProgressBar (ComCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  procedure StepIt;
  procedure StepBy(Value: integer);
  property  Min: integer; [rwd]
  property  Max: integer; [rwd]
  property  Position: integer; [rwd]
  property  Step: integer; [rwd]

TSaveDialog (Dialogs - TOpenDialog)
  constructor Create(AOwner: TComponent); override;
Note: available only if LLCL_OPT_USEDIALOG is not undefined

TSelectDirectoryDialog (Dialogs - TOpenDialog)
  constructor Create(AOwner: TComponent); override;
  function Execute: boolean; override;
Notes: - only with Free Pascal/Lazarus
       - available only if LLCL_OPT_USESELECTDIRECTORYDIALOG
         is defined

TStringGrid (Grids - TWinControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure SortColRow(IsColumn: boolean; Index: integer); *1
  property  Cells[ACol, ARow: integer]: string; [rwd] *2
  property  Col: integer; [rw]
  property  ColCount: integer; [rwd]
  property  Cols[Index: integer]: TStringList; [rw]
  property  ColumnClickSorts: boolean; [rwd] *3
  property  ColWidths[Index: integer]: integer; [rwd]
  property  DefaultColWidth: integer; [rwd]
  property  DefaultRowHeight: integer; [rwd] *4
  property  FixedCols: integer; [rwd] *5
  property  FixedRows: integer; [rwd] *6
  property  Options: TGridOptions; [rd]
  property  Row: integer; [rw]
  property  RowCount: integer; [rwd]
  property  RowHeights[Index: integer]: integer; [rwd] *7
  property  Rows[Index: integer]: TStringList; [rw]
  property  Selection: TGridRect; [r]
  property  SortColumn: integer; [r] *3
  property  SortOrder: TSortOrder; [rw] *3
  property  OnCompareCells: TOnCompareCells; [rwd] *3
  property  OnGetEditText: TGetEditEvent; [rwd]
  property  OnHeaderClick: THdrEvent; [rwd] *3
  property  OnSelectCell: TOnSelectCellEvent; [rwd]
  property  OnSetEditText: TSetEditEvent; [rwd]
*1: only for columns (i.e. IsColumn = True)
*2: not possible at design time for Delphi
*3: not present in the standard Delphi VCL
*4: fixed row not concerned
*5: ignored
*6: only 1 fixed row is possible
*7: ignored
Note: some properties are available only if certain options
      are defined (see LLCL_OPT_GRIDSOPT_XXXX)

TTimer (ExtCtrl - TNonVisualControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  property  Enabled: boolean; [rwd]
  property  Interval: integer; [rwd]
  property  OnTimer: TNotifyEvent; [rwd]

TTrackBar (ComCtrls - TWinControl)
  constructor Create(AOwner: TComponent); override;
  property  Min: integer; [rwd]
  property  Max: integer; [rwd]
  property  Position: integer; [rwd]
  property  Frequency: integer; [rwd]
  property  LineSize: integer; [rwd]
  property  PageSize: integer; [rwd]
  property  Orientation: TOrientation; [d]
  property  TickStyle: TTickStyle; [d]
  property  OnChange: TNotifyEvent; [rwd]

TTrayIcon (ExtCtrl - TNonVisualControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure Show;
  procedure Hide;
  procedure ShowBalloonHint;
  property  BalloonFlags: TBalloonFlags; [rwd]
  property  BalloonHint: string; [rwd] **
  property  BalloonTimeout: integer; [rwd] ***
  property  BalloonTitle: string; [rwd]
  property  Icon: TIcon; [rwd]
  property  Hint: string; [rwd]
  property  Visible: boolean; [rwd]
  property  PopUpMenu: TPopupMenu; [rwd] *
  property  OnDblClick: TNotifyEvent; [rwd]
*: Available if LLCL_OPT_USEMENUS is not undefined
**: Balloon notifications are possible only for Windows 2000+
***: Only for Windows 2000 or XP

TXPManifest (XPMan - TComponent)
  (None - Used only with Delphi)


7.3.4 MAIN CLASSES DETAILS
--------------------------

TApplication (Forms - TComponent);
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure BringToFront;
  procedure CreateHandle; *
  procedure CreateForm(InstanceClass: TComponentClass; var Reference);
  procedure Initialize;
  function  MessageBox(Text, Caption: PChar; Flags: cardinal = MB_OK): integer;
  procedure Minimize;
  procedure ProcessMessages;
  procedure Restore;
  procedure Run;
  procedure ShowException(E: Exception);
  procedure Terminate;
  property  BiDiMode: TBiDiMode; [rw]
  property  Handle: THandle; [r] **
  property  Icon: TIcon; [rd]
  property  MainForm: TCustomForm; [r]
  property  MainFormOnTaskBar: boolean; [rw] ***
  property  ShowMainForm: boolean; [rw]
  property  Terminated: boolean; [r]
  property  Title: string; [rwd]
  property  OnMinimize: TNotifyEvent; [rw]
  property  OnRestore: TNotifyEvent; [rw]
*: if LLCL_OPT_TOPFORM is defined (absent in standard LCL)
**: only with Delphi
***: not for old versions of Delphi

TCustomForm (Forms - TWinControl)
  constructor Create(AOwner: TComponent); override;
  destructor  Destroy; override;
  procedure Close;
  procedure Hide; override;
  procedure Show; override;
  procedure ShowModal;
  property  ActiveControl: TWinControl; [rw]
  property  BorderStyle: TFormBorderStyle; [d]
  property  ClientHeight: integer; [d] *
  property  ClientWidth: integer; [d] *
  property  FormStyle: TFormStyle; [d]
  property  KeyPreview: boolean; [rwd]
  property  Menu: TMainMenu; [rwd] **
  property  Position: TPosition; [d]
  property  WindowState: TWindowState; [rwd]
  property  OnCreate: TNotifyEvent; [rwd]
  property  OnPaint: TNotifyEvent; [rwd]
  property  OnResize: TNotifyEvent; [rwd]
  property  OnDestroy: TNotifyEvent; [rwd]
*: Used only if Height/Width absent
**: Available if LLCL_OPT_USEMENUS is not undefined

TForm (Forms - TCustomForm)
  (None)

TMouse (Controls - TObject)
  property  CursorPos: TPoint; [rw]


7.3.5 VARIOUS OTHER CLASSES DETAILS
-----------------------------------

TStream (Classes - TObject)
  procedure Clear;
  function  CopyFrom(Source: TStream; Count: integer): integer;
  procedure LoadFromFile(const FileName: string);
  procedure LoadFromStream(aStream: TStream); virtual;
  function  Read(var Buffer; Count: integer): integer; virtual; abstract;
  procedure ReadBuffer(var Buffer; Count: integer);
  procedure SaveToFile(const FileName: string);
  procedure SaveToStream(aStream: TStream); virtual;
  function  Seek(Offset: integer; Origin: Word): integer; overload; virtual; abstract;
  function  Seek(Offset: int64; Origin: TSeekOrigin): int64; overload; virtual; abstract;
  function  Write(var Buffer; Count: integer): integer; virtual; abstract;
  property  Position: integer; [rw]
  property  Size: integer; [rw]

THandleStream (Classes - TStream)
  constructor Create(aHandle: THandle);
  function  Read(var Buffer; Count: integer): integer; override;
  function  Seek(Offset: integer; Origin: Word): integer; overload; override;
  function  Seek(Offset: int64; Origin: TSeekOrigin): int64; overload; override;
  function  Write(var Buffer; Count: integer): integer; override;
  property  Handle: THandle; [r]

TFileStream (Classes - THandleStream)
  constructor Create(const FileName: string; Mode: Word);
  destructor  Destroy; override;
  property  FileName: string; [r]

TFileStreamUTF8 (LazUTF8Classes - TFileStream)
Note: only for FPC/Lazarus

TCustomMemoryStream (Classes - TStream)
  function  Read(var Buffer; Count: integer): integer; override;
  procedure SaveToStream(aStream: TStream); override;
  function  Seek(Offset: integer; Origin: Word): integer; override;
  procedure SetPointer(Buffer: pointer; Count: integer);
  property  Memory: pointer; [r]

TResourceStream (Classes - TCustomMemoryStream)
  constructor Create(Instance: THandle; const ResName: string; ResType: PChar);

TMemoryStream (Classes - TCustomMemoryStream)
  destructor  Destroy; override;
  procedure LoadFromStream(aStream: TStream); override;
  function  Write(var Buffer; Count: integer): integer; override;

TReader (Classes - TObject)
Note: the whole class is not standard, and therefore should
      not be used

TThread (Classes - TObject)
  constructor Create(CreateSuspended: boolean);
  destructor  Destroy; override;
  procedure AfterConstruction; override;
  procedure Resume; *
  procedure Suspend; *
  procedure Start; **
  procedure Terminate;
  function  WaitFor(): cardinal;
  property  FreeOnTerminate: boolean; [rw]
  property  Handle: THandle; [r]
  property  Suspended: boolean; [rw]
  property  ThreadID: THandle; [r]
  property  OnTerminate: TNotifyEvent; [rw]
Note: it's also possible to use (from the protected part)
  procedure Execute; virtual; abstract;
  property  Terminated: boolean; [r]
*: Resume and Suspend are deprecated for Delphi 2010+ and
   FPC/Lazarus 2.4.4+
**: only with FPC and Delphi 2010+ (Start instead of Resume)

TEvent (Classes - TObject)
  constructor Create(EventAttributes: PSecurityAttributes; ManualReset, InitialState: Boolean; const Name: string);
  destructor Destroy; override;
  procedure ResetEvent;
  procedure SetEvent;
  function  WaitFor(Timeout: LongWord): TWaitResult;
  property  Handle: THandle; [r] *
*: only with Delphi

TClipboard (ClipBrd - TPersistent)
  procedure Open;
  procedure Close;
  procedure Clear;
  function  HasFormat(Format: cardinal): boolean;
  function  GetAsHandle(Format: cardinal): THandle;
  procedure SetAsHandle(Format: cardinal; Value: THandle);
  property  AsText: string; [rw]

TIniFile (IniFiles - TObject)
  constructor Create(const AFileName: string);
  procedure DeleteKey(const Section, Ident: string); virtual;
  procedure EraseSection(const Section: string); virtual;
  function  ReadBool(const Section, Ident: string; Default: boolean): boolean; virtual;
  function  ReadDate(const Section, Ident: string; Default: TDateTime): TDateTime; virtual;
  function  ReadInt64(const Section, Ident: string; Default: int64): int64; virtual;
  function  ReadInteger(const Section, Ident: string; Default: integer): integer; virtual;
  function  ReadString(const Section, Ident, Default: string): string; virtual;
  procedure WriteBool(const Section, Ident: string; Value: boolean); virtual;
  procedure WriteDate(const Section, Ident: string; Value: TDateTime); virtual;
  procedure WriteInt64(const Section, Ident: string; Value: int64); virtual;
  procedure WriteInteger(const Section, Ident: string; Value: integer); virtual;
  procedure WriteString(const Section, Ident, Value: string); virtual;
  property  FileName: string; [r]
Note: string date/time formats are specific in LLCL SysUtils

TRegistry (Registry - TObject)
  constructor Create; overload;
  destructor Destroy; override;
  procedure CloseKey;
  function  CreateKey(const Key: string): boolean;
  function  DeleteKey(const Key: string): boolean;
  function  DeleteValue(const Name: string): boolean;
  function  GetDataInfo(const ValueName: string; var Value: TRegDataInfo): boolean;
  function  GetKeyInfo(var Value: TRegKeyInfo): boolean;
  procedure GetKeyNames(Strings: TStrings);
  procedure GetValueNames(Strings: TStrings);
  function  KeyExists(const Key: string): boolean;
  function  OpenKey(const Key: string; CanCreate: boolean): boolean;
  function  OpenKeyReadOnly(const Key: String): boolean;
  function  ReadBinaryData(const Name: string; var Buffer; BufSize: integer): integer;
  function  ReadBool(const Name: string): boolean;
  function  ReadDate(const Name: string): TDateTime;
  function  ReadInteger(const Name: string): integer;
  function  ReadString(const Name: string): string;
  function  ValueExists(const Name: string): boolean;
  procedure WriteBinaryData(const Name: string; var Buffer; BufSize: integer);
  procedure WriteBool(const Name: string; Value: boolean);
  procedure WriteDate(const Name: string; Value: TDateTime);
  procedure WriteInteger(const Name: string; Value: integer);
  procedure WriteString(const Name, Value: string);
  property  Access: longword; [rw]
  property  CurrentKey: HKEY; [r]
  property  RootKey: HKEY; [rw]


7.4 SPECIFIC NOTES
------------------

Controls and main classes:

. TApplication:
  BiDiMode and MainFormOnTaskBar properties are general for
  the whole program. They must be set before the first form
  creation: ideally in the lpr/dpr unit.

. TCanvas:
  Currently, the specific TVisualControl class includes a
  TCanvas property; so, this property is also present in the
  TWinControl class. As it's not standard, this property
  must never been used for any control which is a descendant
  of the TWinControl class.

. TFont:
  Though it's theoretically possible to change them at run
  time, there is no support in the LLCL for this: especially,
  but not only, for size, color, ... Therefore, in the LLCL
  TFont should be considered as to be set only at design time.

. TIcon:
  Only the first image in the .ico files is used, and only
  BMP images are supported.

. TMainMenu:
  Only one main menu is -eventually- supposed to be present
  for a given form (and the "Menu" property for the form is
  not used).

. TPicture:
  Only BMP and PNG (not enabled by default for PNG) images are
  supported. To use PNG images, the LLCL_OPT_PNGSUPPORT option
  must be defined, or eventually the more complete
  LLCL_OPT_EXTENDGRAPHICAL option which enables also the
  support of transparent bitmaps and of the double buffering
  painting mode for forms. Some additional Zlib options (PNG
  images support requires the Zlib decompression) are also
  available. Neither TPicture nor TBitmap support any kind of
  data saving.

. TOpenDialog:
  The number of files which can be selected is limited in
  case of a multi selection: 100 files or more, depending of
  the whole file path sizes.

. TStringGrid:
  As the StringGrid control is based upon a Windows Listview
  control in the LLCL, there are several differences with the
  standard LCL/VCL one. Hereafter, the main differences:
  - only one or zero fixed rows is possible. More than one
    fixed rows gives only one fixed row,
  - fixed columns are not possible: they are just ignored,
  - a single cell or a group of cells can't be selected except
    in the first column. Selecting a single row or a
    group of rows is however possible (if the goRowSelect
    option is set),
  - only cells in the first column can be edited (not enabled
    by default),
  - rows can't be sorted, only columns,
  A few options are available concerning this control: see
  LLCL_OPT_GRIDSOPT_XXXX in LLCLOptions.inc.

. TSelectDirectoryDialog:
  This control (FPC/Lazarus only) is available only if the
  general LLCL_OPT_USEDIALOG option is defined, and if the
  specific LLCL_OPT_USESELECTDIRECTORYDIALOG option too.

. TTrayIcon:
  WM_USER+125 message is used in the main Windows procedure
  for TTrayIcon; i.e. it's not available for other purposes.

System classes:

. TThread:
  There is no Synchronize function. As a consequence, the
  OnTerminate event is executed inside the calling thread,
  and not inside the main thread (contrarily to the standard
  LCL/VCL).

Others:

. SysUtils:
  The DateTimeToStr, DateToStr, TimeToStr, TryStrToDate and
  TryStrToTime functions are using only a fixed format:
  'YYYY/MM/DD hh:mm:ss'.


7.5 KNOWN ISSUES
----------------

. Graphical controls (i.e. TGraphicControl descendants) may
  flicker if located inside a TGroupBox control, when the
  form is resized (if the TGroupBox area has to be repainted).
  Possible workarounds:
  - TLabel: use TStaticText instead,
  - TImage: move it outside the TGroupBox control.

. The following compilation options can't be used for the LLCL
  units: "range" (-Cr) and "Verify method calls (-CR). Your
  projects may however still used these options, but the used
  LLCL units must be compiled first without them.

. Since Lazarus 1.6, the IDE is displaying some warnings (i.e.
  "note") during the compilation step, when some unit names
  are identical between the project files and the files used
  by the package(s) for the project. This is especially the
  case when the "LCL" package is used for a project (default
  for a standard application), and the LLCL too. Currently,
  there are no ways to avoid them. So, just ignore them; or
  eventually (which is absolutely not recommended) remove the
  "LCL" package dependency for the project.
