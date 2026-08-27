/* register.cmd - register the Car class against our built DLL.
 * Run on the ArcaOS VM (after a successful wmake).  Usage:
 *
 *   register                      - from the project directory; uses
 *                                   <cwd>\release\car.dll
 *   register D:\path\car.dll      - explicit DLL path, any directory
 *
 * The DLL is referenced by full path so no LIBPATH edit is needed.
 *
 * NOTE (learned during AddrBook bring-up): on some ArcaOS builds
 * SysRegisterObjectClass returns 0 even on SUCCESS.  Do not trust its
 * return code here - verify registration by opening a folder that
 * contains a *.CAR file (see below) and checking what icon it gets.
 *
 * REXX, using the RexxUtil functions that map onto
 * WinRegisterObjectClass / WinDeregisterObjectClass.
 *
 * Car derives from WPDataFile with instance filter "*.CAR": after
 * registering, ANY file with a .CAR extension appears as a Car object
 * (icon, popup menus, settings pages, details view, animated open view).
 * To test:
 *   1. register
 *   2. restart the WPS (or reboot) so pmshell loads the new DLL
 *   3. create an empty file named e.g. MYCAR.CAR in any folder
 */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

dll = strip(arg(1))
if dll = '' then
    dll = directory()'\release\car.dll'
if stream(dll, 'C', 'QUERY EXISTS') = '' then do
    say 'ERROR:' dll 'not found.'
    say 'Either run from the project directory after wmake, or pass'
    say 'the full DLL path:  register D:\path\to\car.dll'
    exit 1
end
say 'DLL: ' dll

rc1 = SysRegisterObjectClass('Car', dll)
say 'SysRegisterObjectClass('Car') rc=' rc1 '(may read 0 even on success)'
say ''
say 'Next steps:'
say '  1. Restart the Workplace Shell (or reboot) so it loads car.dll'
say '  2. Put an empty file MYCAR.CAR into any folder'
say '  3. It should show the car icon; open it for the animated view,'
say '     Settings for Dashboard/Horn Beep pages, Details view for the'
say '     bill-of-sale columns.'
exit 0
