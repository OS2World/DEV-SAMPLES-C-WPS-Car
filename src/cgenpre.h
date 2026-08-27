/*
 * cgenpre.h - OS/2 prelude prepended to release\cargen.c (the
 * sc-generated car.c template) before compilation.  The template only
 * includes <som.h> and "car.h"; car.h references PSZ/CDATE/LONG/etc.
 * without pulling os2.h itself, so the types must come from here.
 * Mirrors the C_ih passthru in idl\car.idl.
 */

#define INCL_WIN
#define INCL_DOS
#define INCL_GPIBITMAPS
#define INCL_DOSERRORS
#include <os2.h>

#define INCL_WPCLASS
#define INCL_WPFOLDER

#include <pmwp.h>
#include <pmstddlg.h>
