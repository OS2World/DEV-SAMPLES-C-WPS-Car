/* deregister.cmd - deregister the Car class.
 */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

rc = SysDeregisterObjectClass('Car')
say 'Deregister Car rc =' rc

/* WPS keeps class data cached per DLL path: if you rebuilt the DLL,
 * reboot (or at least restart the WPS) before registering a new build.
 */
say 'Done. A WPS restart is recommended after deregistering.'
exit 0
