clearscreen.
print "READY FOR LAUNCH" at (0,1).
print "PRESS AG6 TO LOCK" at (0,2).
on ag6 {
	if hastarget = true {
		print "LOCKED TO " + target at (0,3).
		set Tlock to target.
	}else{
		print "NO TARGET ASSIGNED".
		print "PLEASE ASSIGN TARGET".
	}
	preserve.
}
on ag1 {
reboot.
}
wait until availablethrust > 0.
lock throttle to 1.
sas on.
wait 15.
sas off.
//lock throttle to 0.2.
PRINT "Missile released" .
until false {
	wait 0.1.
	set Vtarget to Tlock:position.
	set k to 5.
	set Vi to k*Vtarget:normalized-(k-1)*ship:velocity:surface:normalized-ship:body:position:normalized*0.3.
	lock steering to Vi.
	SET anArrow1 TO VECDRAW(
      V(0,0,0),
      vi,
      RGB(1,0,0),
      "Vi",
      2.0,
      TRUE,
      0.2
    ).
	SET anArrow2 TO VECDRAW(
      V(0,0,0),
      ship:velocity:surface,
      RGB(1,0,0),
      "Prograde",
      2.0,
      TRUE,
      0.2
    ).
	SET anArrow3 TO VECDRAW(
      V(0,0,0),
      2*Vtarget,
      RGB(1,0,0),
      "Vtarget",
      2.0,
      TRUE,
      0.2
    ).
}