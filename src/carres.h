/*
 * carres.h - OS/2 resource prelude for car.rc.
 *
 * car.rc originally included car.ih for its ID definitions, but wrc's
 * preprocessor cannot digest the full SOM implementation header
 * (#pragma checkout etc.).  This header carries ONLY what the resource
 * script needs: the OS/2 base types plus every ID from the C_ih
 * passthru in idl\car.idl.
 *
 * MAINTENANCE: keep this ID list in sync with the passthru block in
 * idl\car.idl - that one feeds the C sources, this one feeds the
 * resources.
 */

#define INCL_WIN
#define INCL_DOS
#include <os2.h>
#include <pmwp.h>

/* Not in pmwp.h: WPMENUID_USER comes from wpobject.h:230 (toolkit
 * 4.5).  Defined here rather than dragging wpobject.h into wrc. */
#define WPMENUID_USER       0x6500

#define ID_TITLE           100
#define ID_ICON            101

#define IDD_DASHBOARD      200                  /* settings page */
#define IDD_HORNBEEP       202
#define IDD_DASHBOARD2    1200                  /* settings page */
#define IDD_HORNBEEP2     1202

/* User-defined popup menu items must be above WPMENUID_USER.
 * ID_OPENMENU becomes a submenu of the system open menu,
 * WPMENUID_OPEN.
 */
#define ID_BEEPMENU        (WPMENUID_USER+1)
#define ID_OPENMENU        (WPMENUID_USER+2)
#define ID_TRAPMENU        (WPMENUID_USER+3)

#define IDM_OPENCAR        (WPMENUID_USER+4)
#define IDM_BEEPHORN       (WPMENUID_USER+5)
#define IDM_TRAPCAR        (WPMENUID_USER+6)

#define IDMSG_ACCESS_VIOLATION  100
#define IDM_MSGBOX              999

#define ID_FRAME           3000                   /* frame window id */
#define ID_CLIENT          3001                   /* client window id */

/* Unique view ids */
#define OPEN_CAR           IDM_OPENCAR

#define CAR_TIMER          1001                   /* timer id */

/* IDs of dialog items in CAR.RC */
#define ID_UNDO            801
#define ID_DEFAULT         802
#define ID_HELP            803
#define ID_HITONE          804
#define ID_LOTONE          805
#define ID_SPEEDSLIDER     806
#define ID_STOP            807
#define ID_SPEEDDATA       808
#define ID_GO              809

/* Keys for save-restore methods (not used by resources, listed for
 * completeness) */
#define IDKEY_HITONE       1
#define IDKEY_LOTONE       2
#define IDKEY_DURATION     3
#define IDKEY_SPEED        4
#define IDKEY_BRAKEFLAG    5

/* Default values of instance data items (C sources only) */
#define DEFAULT_DURATION   300
#define DEFAULT_HITONE     400
#define DEFAULT_LOTONE     400
#define DEFAULT_SPEED      50
#define DEFAULT_BRAKEFLAG  FALSE

/* Help ids (pre-built CAR.HLP ships with the sample) */
#define ID_HELP_DEFAULT    256
#define ID_HELP_DASHBOARD  257
#define ID_HELP_OPENCAR    258
#define ID_HELP_HORNBEEP   259
#define ID_HELP_BEEPHORN   260
