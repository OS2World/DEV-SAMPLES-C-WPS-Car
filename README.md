# Car - Workplace Shell Sample Object (SOM/IDL)

A Workplace Shell sample demonstrating a custom WPS data-file class built
with SOM and the OS/2 IDL compiler.  The Car object associates with `*.CAR`
files, opens an animated view, and exposes horn/beep/speed settings through
the WPS settings notebook.

![Car ScreenShot](/doc/car.png)

Copyright (C) 1992, 1993, 1994, 1995 IBM Corporation.
Ported to Open Watcom 2024.

## Class Hierarchy

```
SOMObject
  WPObject
    WPFileSystem
      WPDataFile
        Car          (metaclass: M_Car)
```

Car inherits all WPDataFile capabilities (drag/drop, print, details view,
settings notebook) and adds:

- **Open view** -- animated car bouncing inside the window, driven by a
  PM timer.  Speed and brake state control the animation.
- **Horn Beep** -- configurable high/low tone frequencies and duration,
  triggered from the context menu or the settings page.
- **Dashboard** -- speed slider and brake Go/Stop button on a settings
  notebook page.
- **Details view** -- five columns (Make, Model, Color, Sale date, Price)
  appended to the parent's details chain.
- **Exception handling** -- the Trap D menu item deliberately causes an
  access violation to demonstrate the `#pragma handler` exception
  recovery mechanism.

## Project Layout

```
Car-Watcom/
  idl/       car.idl             SOM interface definition
  h/         car.ih, car.h, car.c   sc-generated bindings (checked in)
  src/
    car.c        methods + SOMInitModule + window/dialog procs
    car.rc       menus, dialogs, icons, string table (resource script)
    carres.h     resource ID constants (wrc-compatible)
    car.ico      application icon
    cgenpre.h    OS/2 prelude prepended to sc-generated car.c
    pmwp.def     ordinal imports for WPObject/WPFileSystem/WPDataFile
    som.def      (retained; no longer used by the build)
  doc/
    car.ipf      IPF help source
    car.png      help illustration
  release/     build output: .dll, .hlp, .obj, .res, .map, .lib
  Makefile.wat Open Watcom wmake makefile (primary build)
  Makefile.vac original IBM VAC/nmake makefile (reference only)
  mk.cmd       REXX build wrapper (captures to release\wmake.log)
  genbind.cmd  REXX wrapper for sc (generates h\ bindings once)
  register.cmd REXX WPS class registration
  deregister.cmd REXX WPS class deregistration
```

## Prerequisites

- **ArcaOS** or **OS/2 Warp 3+** with the Workplace Shell.
- **Open Watcom v2** (wcc386, wlink, wrc, wmake) on the build machine.
  `WATCOM` environment variable must be set.
- **SOM toolkit** headers at `C:\os2tk45\som\include` (adjust `SOMINC`
  in the Makefile for your layout).
- **WPS/PM headers** at `C:\os2tk45\h` (adjust `WPSINC`).
- **som.dll** at `C:\OS2\DLL\som.dll` (standard on ArcaOS/OS/2).

## Building

On the OS/2 build machine:

```
cd <path>\Car-Watcom
mk
```

`mk.cmd` runs `wmake -f Makefile.wat clean`, then a full build, capturing
all output to `release\wmake.log`.

### Build sequence

1. `sc` (SOM compiler) is **not** invoked by the Makefile.  The binding
   files (`h\car.ih`, `h\car.h`, `h\car.c`) are generated once via
   `genbind.cmd` and checked in.

2. **Compilation** -- `wcc386` compiles `src\car.c` (methods) and
   `release\cargen.c` (sc-generated class construction template,
   prepended with `src\cgenpre.h` for OS/2 types) as DLL objects
   (`-bd`).

3. **Import libraries** -- `implib` builds:
   - `release\som.lib` from `C:\OS2\DLL\som.dll` (single-module SOM
     import library).
   - `release\pmwp.lib` from `src\pmwp.def` (ordinal-only PMWP imports).

4. **Link** -- `wlink` produces `release\car.dll` with seven exports
   (SOMInitModule plus the six class symbols).

5. **Resources** -- `wrc` compiles `src\car.rc` and binds it into the DLL.

6. **Help** -- the pre-built `orig\car.hlp` is copied to `release\`.

## Registration

After building:

```
register.cmd
```

This calls `SysRegisterObjectClass('Car', '<full path>\release\car.dll')`
via the REXX `SysUtil` functions.  The Car class then appears in the WPS
and associates with any `.CAR` file.

To remove:

```
deregister.cmd
```

## Changes in This Release (Open Watcom Port)

The following changes were made to port the IBM SOM 2.x / VAC sample to
Open Watcom and toolkit 4.5:

### IDL (`idl\car.idl`)

- **`dllname = "car.dll"`** added to both implementation blocks (Car and
  M_Car).  The original IDL omitted `dllname`; modern `sc` requires it so
  that `_somLocateClassFile` and the WPS agree on which DLL hosts the
  class.
- **`DebugBox` passthru removed.**  The original emitted a `DebugBox`
  macro from the `C_ih` passthru using `#if`/`#else`.  Watcom's
  preprocessor rejected this as a non-identical redefinition (E1100)
  because the toolkit's `wpdataf.h:81` already defines `DebugBox`
  unconditionally.  `DebugBox` is now a plain helper in `src\car.c`.

### C Sources (`src\car.c`)

- **`SOMInitModule`** added as an explicit entry point.  Modern `sc`
  (emitted via `emitc`) no longer generates `SOMInitModule`; without it,
  `wlink` silently resolved the name from `somtk.lib` and exported a
  forwarder to `somir.dll`, whose `SOMInitModule` initializes `somir`'s
  classes -- not ours.  The implementation calls `M_CarNewClass` first,
  then `CarNewClass`, matching the metaclass-first convention proven by
  the ClrPalet and MBFolder ports.
- **`#pragma handler(car_TrapTest)`** commented out.  IBM C Set/2's
  `#pragma handler` marks a function for exception-handler unwinding; Open
  Watcom has no equivalent.  The Trap D menu item will genuinely trap
  instead of demonstrating recovery.
- **`zString`** replaced with `string`.  `zString` was an IBM-era typedef
  absent from toolkit 4.5 SOM headers; `string` (i.e. `char *`) is what
  `_somLocateClassFile` returns.

### Resources (`src/carres.h`, `src/car.rc`)

- **`carres.h`** created as a separate header for resource ID constants.
  The original embedded defines in the IDL passthru; `wrc` cannot parse
  `car.ih`, so the resource script includes `carres.h` directly.
- **`WPMENUID_USER`** defined as `0x6500` (from `wpobject.h:230`).
  IBM's toolkit 4.5 moved this constant out of the public headers; the
  define ensures user-defined popup menu IDs resolve correctly.
- **`-i=$(WPSINC)`** added to the `wrc` rule so the resource compiler
  finds `pmwp.h`.

### Build System (`Makefile.wat`)

- **SOM import library built from `som.dll`**, not from a `.def` file.
  IBM's `implib` silently drops entries when processing `.def` IMPORTS
  sections containing SOM-family symbols, producing a 1024-byte stub that
  resolves nothing.  Building directly from the DLL's export table gives a
  correct single-module import library.  This eliminates the 13 phantom
  imports (`somc`, `some`, `soms`, `somem`, `somct`, `somsec`, `somd`,
  `somir`, `somtc`, `somp`, `somr`, `somu`, `somuc`) that `somtk.lib`
  drags in transitively and that are absent from minimal OS/2
  installations.
- **`somtk.lib` no longer used.**  The stock SOM toolkit import library
  resolves SOM symbols but also pulls in every SOM-family DLL as a
  transitive dependency.  The error "Registering class 'Car' failed.
  Error code: 2. Module information: SOMC" occurs when `DosLoadModule`
  cannot find `SOMC.DLL` on `LIBPATH`.
- **`LIBF $(SOMLIB),$(PMWPLIB)`** -- the linker searches `som.lib`
  first (SOM ordinals), then `pmwp.lib` (WPObject/WPFileSystem/WPDataFile
  ordinals).  The comma ensures correct search order.
- **`mk.cmd`** wrapper captures all output (stdout + stderr) to
  `release\wmake.log` for host-side diagnosis through the shared folder.

### Import Definitions

- **`src/pmwp.def`** -- 12 ordinal imports for WPObject, WPFileSystem,
  and WPDataFile (ClassData, CClassData, NewClass, and metaclass
  counterparts).  Ordinals from Paul Ratcliffe's published PMWP entry
  point table.
- **`src/som.def`** -- retained for reference but no longer used by the
  build.

### Other

- **`src\cgenpre.h`** -- OS/2 prelude header prepended to the
  sc-generated `h\car.c` via COPY concatenation.  Using `wcc386
  -fi=os2.h` was rejected because a forced include fires os2.h's
  include guard before any `INCL_*` define exists, causing the real
  prelude to no-op.
- All text files in the repository are kept in CRLF (ASCII) line endings
  as required by the OS/2 toolchain.

## Differences from the Original IBM Sample

| Aspect | Original (orig/) | Watcom Port |
|---|---|---|
| Compiler | IBM C Set/2 | Open Watcom wcc386 |
| SOM compiler | sc from SOM toolkit 1.x | sc from toolkit 4.5 |
| Build tool | nmake + `ibmsamp.inc` | wmake + `Makefile.wat` |
| IDL `dllname` | omitted | added (`"car.dll"`) |
| `SOMInitModule` | generated by sc | explicit in `src\car.c` |
| `DebugBox` | IDL passthru macro | helper function in `src\car.c` |
| `#pragma handler` | active | commented out (no OW equivalent) |
| `zString` typedef | present | replaced with `string` |
| Import library | `somtk.lib` (full) | `som.lib` from `som.dll` (minimal) |
| WPS registration | `ibmsamp.inc` helper | `register.cmd` / REXX |

## Running

1. Register the class (see Registration above).
2. Create a `.CAR` file on the desktop (e.g. `MYTEST.CAR`).
3. The file icon changes to the Car icon.
4. Double-click to open the animated view.
5. Right-click for context menu: Open Car, Beep Horn, Trap D.
6. Drag the file to the settings notebook for Dashboard / Horn Beep pages.

## Troubleshooting

- **"Registering class 'Car' failed. Error code: 2. Module information:
  SOMC"** -- `somtk.lib` is being used instead of the per-DLL
  `som.lib`.  Ensure `release\som.lib` exists (built from
  `C:\OS2\DLL\som.dll`) and that `Makefile.wat` line 77 reads
  `LIBF $(SOMLIB),$(PMWPLIB)`.
- **`wlink: E3033 directive error near ...`** -- a `.lnk` response file
  contains `IMPORT` directives.  `IMPORT` is an `implib` directive, not
  `wlink`.  Remove any `@release\car.lnk` reference from LFLAGS.
- **Build output unreadable** -- check `release\wmake.log` (captured by
  `mk.cmd`).  Individual `.err` files in the project root contain
  compiler diagnostics.
- **Help not found** -- ensure `car.hlp` is in the same directory as
  `car.dll` or on `HELPREFPATH`.

