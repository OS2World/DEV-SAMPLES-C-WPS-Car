/* genbind.cmd - REXX script. Run ONCE on the OS/2 side (ArcaOS VM),
 * from the project directory, to produce the SOM bindings:
 *     h\car.ih   h\car.h   from idl\car.idl
 *
 * Unlike the AddrBook project, the sc-generated car.c TEMPLATE is kept:
 * it is moved to release\cargen.c and compiled as an extra object by
 * Makefile.wat (it carries SOMInitModule + class construction tables).
 *
 * LOGGING: summary -> release\genbind.log ; raw compiler output ->
 * release\sc_raw.log (stdout+stderr when sh.exe is available).
 *
 * NOTE: never call bare "sc" - Open Watcom ships its own SC.EXE which
 * shadows the SOM compiler on PATH.  This script uses an explicit path.
 */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

logfile = 'release\genbind.log'
sclog   = 'release\sc_raw.log'

call lineout logfile, '=== genbind.cmd ' date() time() ' ==='

/* ---- locate the SOM compiler ---------------------------------------- */
somBin = ''
candidates = 'C:\OS2TK45\SOM\BIN D:\OS2TK45\SOM\BIN C:\SOM\BIN D:\SOM\BIN C:\IBMSOM\BIN'
do i = 1 while somBin = '' & i <= words(candidates)
    d = word(candidates, i)
    if stream(d'\SC.EXE', 'C', 'QUERY EXISTS') <> '' then
        somBin = d
end
if somBin = '' then do
    p = SysSearchPath('PATH', 'SC.EXE')
    if pos('\WATCOM\', translate(p)) = 0 & p <> '' then
        somBin = filespec('Drive', p)||filespec('Path', p)
end
if somBin = '' then do
    call lineout logfile, 'ERROR: SOM compiler not found'
    say 'ERROR: SOM compiler not found'
    exit 8
end
scexe = somBin'\SC.EXE'
say 'sc: ' scexe
call lineout logfile, 'sc: ' scexe

cur = VALUE('SMINCLUDE', , 'OS2ENVIRONMENT')
say 'SMINCLUDE: ' cur
call lineout logfile, 'SMINCLUDE: ' cur

x = VALUE('SMTMP', '.\release', 'OS2ENVIRONMENT')

/* ---- generate bindings (ih;h;c - template wanted) -------------------- */
shp = SysSearchPath('PATH', 'SH.EXE')
scSh = translate(scexe, '/', '\')
if shp <> '' then
    ADDRESS CMD "sh.exe -c '"""scSh""" -s ""ih;h;c"" -v -d h -I idl idl/car.idl > " || ,
                translate(sclog,'/','\') || " 2>&1'"
else
    ADDRESS CMD '"'||scexe||'" -s "ih;h;c" -v -d h -I idl idl\car.idl >> ' || sclog
src = rc
say 'sc rc=' src
call lineout logfile, 'sc rc=' src

ok = 1
binds = 'h\car.ih h\car.h h\car.c'
do i = 1 to words(binds)
    f = word(binds, i)
    if stream(f, 'C', 'QUERY EXISTS') = '' then ok = 0
end
if ok = 0 then do
    say 'ERROR: sc produced no bindings; see' sclog
    call lineout logfile, 'ERROR: no bindings'
    exit 12
end

/* h\car.c (the template) STAYS where it is: Makefile.wat concatenates
 * src\cgenpre.h + h\car.c into release\cargen.c at build time. */
say 'bindings OK: h\car.ih h\car.h h\car.c'
call lineout logfile, 'bindings OK: h\car.ih h\car.h h\car.c'
exit 0
