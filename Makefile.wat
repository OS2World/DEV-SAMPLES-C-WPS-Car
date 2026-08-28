#****************************************************************************
# Makefile.wat - Open Watcom build for the Workplace Shell "Car" sample
#                class DLL (car.dll: Car + metaclass M_Car).
#
# Watcom port of IBM's 1993/94 SOM 2.x "Car" sample (orig\CAR.MAK).
# Same project conventions as AddrBook-Watcom - read that makefile's
# header for full rationale.  Summary:
#
# Project layout:
#   idl\    car.idl (interface definition)
#   h\      sc-generated bindings car.ih/car.h (+ this tree's headers)
#   src\    implementations, resource script, module definitions
#   orig\   pristine copy of the IBM sample
#   release build output: .obj/.res/.dll/.map
#
# PREREQUISITES:
#   1. Open Watcom installed; WATCOM environment variable set.
#   2. h\car.ih and h\car.h produced ONCE by genbind.cmd on the OS/2
#      side.  This makefile never invokes sc.
#   3. The sc-generated car.c template is compiled as an extra object
#      ($(OUT)\cargen.obj): it carries SOMInitModule plus the class
#      construction tables; our src\car.c provides only the methods
#      (exactly how the original split work between sc output and hand
#      code).
#   4. Parent WPS classes (WPObject/WPFileSystem/WPDataFile) come from
#      pmwp.dll by ORDINAL: wlib reads C:\OS2\DLL\pmwp.dll directly ->
#      release\pmwp.lib.  src\pmwp.def documents the specific ordinals
#      used but is not fed to wlib (wlib rejects IMPORTS .def files).
#   4a. SOM kernel: wlib builds release\som.lib from som.dll directly
#       (single-module import library; avoids somtk.lib's transitive
#       dependency on somc/some/somtc which fail to load on some systems).
#   5. Help: wipfc (Open Watcom IPF compiler) compiles doc\car.ipf to
#      release\car.hlp.  wipfc must be on PATH (part of Open Watcom).
#****************************************************************************

WATCOM  = $(%WATCOM)

# ---- adjust these paths/libraries for your machine ------------------------
SOMINC  = C:\os2tk45\som\include
WPSINC  = C:\os2tk45\h
# ---------------------------------------------------------------------------
# SOM kernel import library: built directly from som.dll via implib.
# The stock somtk.lib drags in transitive dependencies on somc/some/somtc
# etc. which fail to load on systems where they are not on LIBPATH (WPS
# error 2 naming "SOMC").  Building from som.dll gives us a single-module
# import library: all SOM symbols resolve to som.dll and nothing else.
# ---------------------------------------------------------------------------
SOMDLL  = C:\OS2\DLL\som.dll
SOMLIB  = $(OUT)\som.lib
PMWPDLL = C:\OS2\DLL\pmwp.dll
# ---------------------------------------------------------------------------

HDIR    = h
SRC     = src
OUT     = release
IPFSRC  = doc\car.ipf
CARDEF  = $(SRC)\car.def

CC      = wcc386
LINK    = wlink
RC      = wrc
WLIB    = wlib
WIPFC   = wipfc

# Calling-convention note: SOMLINK stays EMPTY under Watcom; linkage is
# guaranteed by #pragma linkage(..., system) in the generated bindings.
# -wcd=1177 silences sombtype.h(41) "Modifier repeated" under -wx.
CFLAGS  = -bt=os2 -zq -wx -wcd=1177 -d1 &
          -I$(HDIR) -I$(SOMINC) -I$(WPSINC)

# DLL object modules: methods + sc-generated construction template.
DLLOBJ  = $(OUT)\car.obj $(OUT)\cargen.obj

EXPS    = EXP SOMInitModule &
          EXP M_CarClassData EXP M_CarCClassData EXP M_CarNewClass &
          EXP CarClassData EXP CarCClassData EXP CarNewClass

PMWPLIB = $(OUT)\pmwp.lib

LFLAGS  = SYSTEM OS2V2_DLL NAME $(OUT)\car.dll &
          OP MAP=$(OUT)\car.map &
          @$(CARDEF) &
          LIBF $(SOMLIB),$(PMWPLIB) $(EXPS)

all : $(OUT)\car.dll $(OUT)\car.hlp

$(OUT)\car.obj : $(SRC)\car.c idl\car.idl &
                 $(HDIR)\car.ih $(HDIR)\car.h
    $(CC) -bd $(CFLAGS) $(SRC)\car.c -fo=$@

# The sc template includes only <som.h> + "car.h"; car.h needs the OS/2
# types from the C_ih passthru.  Prepend src\cgenpre.h via COPY concat -
# do NOT use wcc386 -fi=os2.h: a forced os2.h fires its include-guard
# before any INCL_* define exists, and the real prelude then no-ops.
$(OUT)\cargen.c : $(HDIR)\car.c $(SRC)\cgenpre.h
    copy $(SRC)\cgenpre.h + $(HDIR)\car.c $@ >nul

$(OUT)\cargen.obj : $(OUT)\cargen.c $(HDIR)\car.ih $(HDIR)\car.h
    $(CC) -bd $(CFLAGS) -wcd=107 -wcd=138 -wcd=202 $(OUT)\cargen.c -fo=$@

$(OUT)\som.lib : $(SOMDLL)
    $(WLIB) -n -b -q $@ +$(SOMDLL)

$(OUT)\pmwp.lib : $(PMWPDLL)
    $(WLIB) -n -b -q $@ +$(PMWPDLL)

# wrc -r always writes <name>.res next to the source; relocate afterwards.
# car.rc includes src\carres.h (IDs only) - wrc cannot parse car.ih.
$(OUT)\car.res : $(SRC)\car.rc $(SRC)\car.ico $(SRC)\carres.h
    $(RC) -r -i=$(SRC) -i=$(WPSINC) $(SRC)\car.rc
    copy $(SRC)\car.res $(OUT)
    del $(SRC)\car.res

$(OUT)\car.dll : $(DLLOBJ) $(OUT)\car.res $(SOMLIB) $(PMWPLIB)
    $(LINK) $(LFLAGS) FIL $(OUT)\car.obj,$(OUT)\cargen.obj
    $(RC) $(OUT)\car.res $(OUT)\car.dll
# No MAPSYM step: IBM mapsym rejects Watcom's map format.

$(OUT)\car.hlp : $(IPFSRC)
    $(WIPFC) $(IPFSRC)
    move car.hlp $@

bindings : .SYMBOLIC
    @echo Run genbind.cmd on the OS/2 side once; this makefile expects
    @echo h\car.ih and h\car.h to already exist.

clean : .SYMBOLIC
    -del $(OUT)\*.obj
    -del $(OUT)\*.res
    -del $(OUT)\*.lib
    -del $(OUT)\*.dll
    -del $(OUT)\*.map
    -del $(OUT)\*.hlp
    -del $(OUT)\cargen.c
# wcc386 drops <name>.err files into the current directory on diagnostics
    -del *.err
