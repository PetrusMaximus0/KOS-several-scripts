function ReentryCorrection {
clearscreen.
set dacc to 0.
lock throttle to ntval_calc(dacc).

print "Running Boostback " at (0,20).
print "Stand By... " at (0,21).
wait until ship:altitude > 60000.
stage.
clearscreen.

local inputcoordinates to LATLNG(2.32607477191447, -41.8901623486278).// OTHER CONTINENT LANDING SPOT.
function vectors {
	set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set targetla to inputcoordinates.
	set altvec to targetla:position-targetaltvec.
	set TrImpact to addons:tr:impactpos:position.
	set progradePground to VXCL(up:vector,velocity:surface).
	set wangle to vang (altvec,targetaltvec).
}

//vectors
vectors().
set wangle to vang (altvec,targetaltvec).
set progradePground to VXCL(up:vector,velocity:surface).
set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
//2-run dircor when wangle less than 92.5.
lock steering to retrograde.
until wangle < 100 {
	print "WAngle is  " + round(wangle,2)+ "    " at (0,5).	
	vectors().
	set wangle to vang (altvec,targetaltvec).
}

until vang(progradePground,targetaltvec)< (max(90,wangle)-89.999999999999) {
	dircorrect().
	vectors().
	set wangle to vang (altvec,targetaltvec).
	print "WAngle is  " + round(wangle,2)+ "    " at (0,5).
	print "this it  " + vang(correctionvector,progradePground) at (0,6).
}
set dacc to 0.
clearscreen.
clearvecdraws().
lock steering to Lookdirup(-ship:velocity:surface,ship:body:position).
wait until vang(velocity:surface,-facing:forevector) < 5.
//correct for pitch
UNTIL (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+targetla:position)):mag < 1000 {
	if (v(0,0,0)+Trimpact):mag < (v(0,0,0)+targetla:position):mag {
		until (v(0,0,0)+Trimpact):mag > (v(0,0,0)+targetla:position):mag + 1000{
			set TrImpact to addons:tr:impactpos:position.
			lock steering to -ship:body:position.
			wait until vang(-ship:body:position,-facing:forevector) < 30.
			lock throttle to 1.
		}
	}
	lock steering to VXCL(up:vector,-velocity:surface).
	set TrImpact to addons:tr:impactpos:position.
	Print "Correcting for pitch" at (10,10).
	Print " D IS " + (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+targetla:position)):mag .
	set dacc to max(20,vang(TrImpact,targetla:position)).
}
set dacc to 0.
Print "angle correct ENDED    " at (10,10).
unlock all.
rcs on.
}