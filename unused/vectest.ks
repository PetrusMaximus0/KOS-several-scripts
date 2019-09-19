clearscreen.
run functionlib.
until false {
	
	set vy to verticalspeed.
	set dvy to -6.
	
	set targetla to latlng(-0.0965,-74.557).
	//
	set dir1a to -SHIP:BODY:POSITION*angleaxis(20,ship:facing:starvector).
	set dir1b to -SHIP:BODY:POSITION*angleaxis(-20,ship:facing:starvector).
	set dir2a to -ship:body:position*angleaxis(20,ship:facing:topvector).
	set dir2b to -ship:body:position*angleaxis(-20,ship:facing:topvector).
	//
	set dir2 to velocity:surface.
	set dir3 to velocity:surface*angleaxis(20,ship:facing:topvector).
	set dir4 to velocity:surface*angleaxis(20,ship:facing:starvector).
	//
	set fdbk to V(0,0,0).
	set lnr to V(0,0,0).
	
	set targetaltvec to LATLNG(-0.0965,-74.557):ALTITUDEPOSITION(ship:altitude).
	
	if targetaltvec:mag > 10 and groundspeed <15{
		set fdbk to dir1b.
		print "tilting forwards   " at (0,5).
		
	}else if groundspeed > 15 {//if "needs to tilt backwards"
		set fdbk to dir1a.
		print "tilting backwards    " at (0,5).
	}else {	
		set fdbk to V(0,0,0).
	}
	print "vang for lnr  " + vang(velocity:surface,ship:facing:starvector) at (0,6).
	if vang(velocity:surface,ship:facing:starvector) < 90 {//"needs to tilt left" 
		set lnr to dir2b.
		print "tilting right    " at (0,4).
	}else if vang(velocity:surface,ship:facing:starvector) > 90 { // needs to tilt right
		set lnr to dir2a.
		print "tilting left    " at (0,4).
	}
	//-------------------------------------------	
	
	if vang(ship:velocity:surface,targetla:position) > 5//"needs correction"
	{
		set correctedvector to (fdbk + lnr).
	 }else{
		set correctedvector to -ship:velocity.
	}
			
	set dstwr to (vy/dvy).
	lock throttle to tval_calc(dstwr).
	
	print round( vang(velocity:surface,targetla:position) , 2 ) at (0,2).
	
	lock steering to lookdirup(CorrectedVector,targetla:position).
		
	set anarrow to vecdraw(
		V(0,0,0),
		VCRS(VCRS(ship:body:position,targetla:position),ship:body:position),
		RGB(5,3,0),
		"Ship surface velocity",
		1.0,
		TRUE,
		0.5
	).
	set anarrow2 to vecdraw(
		V(0,0,0),
		ship:facing:starvector,
		RGB(0,1,0),
		"Starboard vector",
		1.0,
		TRUE,
		0.5 
	).
	set anarrow3 to vecdraw(
		V(0,0,0),
		dir2,//targetla:position,
		RGB(0,0,1),
		"Correction VEC rotates top vec axis",
		1.0,
		TRUE,
		0.5 
	).
	set anarrow4 to vecdraw(
		V(0,0,0),
		ship:facing:topvector,
		RGB(5,5,1),
		"TOP Vector",
		1.0,
		TRUE,
		0.5 
	).
		set anarrow5 to vecdraw(
		V(0,0,0),
		dir1a,
		RGB(0,5,1),
		"Correction VEC rotates starvector axis PLUS",
		1.0,
		TRUE,
		0.5 
	).
		set anarrow6 to vecdraw(
		V(0,0,0),
		targetaltvec,
		RGB(10,0,1),
		"Target",
		1.0,
		TRUE,
		0.5 
	).
	
	
}