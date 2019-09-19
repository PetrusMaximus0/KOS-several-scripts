// prep
clearscreen.
run functionlib.
Run lamunlib.
sas off.
set ship:control:pilotmainthrottle to 0.
print " CHECK YOUR LZ COORDINATES" at (0,30).
//---------------------------------------
until alt:radar < 2500 {
	dircorrect().
}

lock throttle to 0.
lock steering to srfretrograde.
wait until vang(-ship:velocity:surface,ship:facing:forevector)<1.
clearvecdraws().
until ship:status ="landed" {
	munLandThr().
	munDescentLz().	//fall guidance
		
		set anarrow12 to vecdraw(
		V(0,0,0),
		correction2Vec,
		RGB(1,50,0),
		"Exclude ception",
		1.0,
		TRUE,
		0.5
	).
		
}
unlock steering.
lock throttle to 0.
Sas on.
rcs off.
clearvecdraws().