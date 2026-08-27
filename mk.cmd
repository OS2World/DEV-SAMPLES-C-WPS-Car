/* mk.cmd - run wmake and capture ALL output (stdout+stderr) into
 * release\wmake.log.  Linker/resource/implib messages only go to the
 * console, so this wrapper makes every build stage's diagnostics
 * readable host-side through the shared folder.
 * Run on the VM from the project directory.
 */

logfile = 'release\wmake.log'

'wmake -f Makefile.wat clean'

'wmake -f Makefile.wat > ' || logfile || ' 2>&1'
rcx = rc

say ''
say 'wmake rc =' rcx
if rcx = 0 then
    say 'BUILD OK - see release\ for car.dll and car.hlp.'
else do
    say 'BUILD FAILED - full output in' logfile
    say '(readable from the host at C:\Temporal\1.- OS2\SWtest\Car-Watcom\release\wmake.log)'
end
exit rcx
