// you need to dial these coordinates manually.
local inputcoordinates to LATLNG(-1.01538400225137,179.861589454198).// do it here.
set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
set targetla to inputcoordinates.
set altvec to targetla:position-targetaltvec.

//--------------------------------------------------------------------------
function munhover {
	//vectors
	set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set targetla to inputcoordinates.
	set altvec to targetla:position-targetaltvec.
	set errorangle to vang (targetla:position,altvec).//for theta0.
	
	//multipliers adjust as necessary.
	set kd to 1. // 
	set kp to 1. //to remember this is not the real KP
	
    //derivative of the change in angle over time
	set theta0 to errorangle.
	set t0 to TIME:SECONDS.
		//give time
	wait 0.01.
	
	set errorangle to vang (targetla:position,altvec).//calc it for theta1.
	set theta1 to errorangle.
	set t1 to TIME:SECONDS.
	
	//deltas
	set deltatheta to theta1-theta0.
	set deltatime to t1-t0.
	set deltaerror to deltatheta/deltatime.
	//arrows().
	// C is to dampen the output at low altitude, so the bigger error angle doesn't matter so much.
	if alt:radar > 300 {
		set c to 1.
		
		print "C IS NOW " + c + "  " at (0,11).
	
	}else if alt:radar > 200{
		set c to 0.9.
		
		print "C IS NOW " + c + "  " at (0,11).
	
	}else if alt:radar > 100{
		set c to 0.8.
		
		print "C IS NOW " + c + "  " at (0,11).
	
	}else{
		set c to 0.5. 
	
		print "C IS NOW " + c + "  " at (0,11).
	}
	// K is a multiplier to the amount of angle that the correction vector will have.
		// the "1" is a placeholder for the proportional part of the controller.
		// The real proportional part is calculated by the vector math and tuned by kp.
	
	set k to min(1,(1*kp + kd*deltaerror)) . // when k = 1 the ship will point at a 45ยบ angle
															 //	The lower k the lower angle. The reverse applies.
	set correctionvector to 1.5*c*k*(targetaltvec)-altvec .
	
	if errorangle > 1 {
		if errorangle > 75 or alt:radar < 40 {//test this part
			lock steering to lookdirup (-(velocity:surface:normalized),v(0,0,1)).
		}else{
			lock steering to lookdirup(correctionvector,v(0,0,1)).
		}
	}else if errorangle < 1 {//needs to be adjusted for shipheight.
		lock steering to lookdirup(-(velocity:surface:normalized),v(0,0,1)).
	}
	
	//	
	print "ERROR ANGLE "	 + round (vang (targetla:position,altvec),2) 										at (0,6).
	print "DELTA TIME " 	 + round (deltatime,3)  + "   " 													at (0,2).
	print "DELTA THETA " 	 + round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTA ERROR " 	 + round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		 + round (k,3)          + "   " 							 						at (0,5).
	print "TARGET DISTANCE " + round (targetla:POSITION:mag,1)+ "   " 											at (20,5).
	//
	set anarrow6 to vecdraw(
		V(0,0,0),
		correctionvector,
		RGB(1,0,6),
		"Correct VEC",
		1.0,
		TRUE,
		0.5
	).
	
		
}
CLEARVECDRAWS().

clearscreen.
run functionlib.
print "functions loaded".
sas off.
set ship:control:pilotmainthrottle to 0.
//wait until (alt:radar < 2000 or ship:altitude < 3000).
print "adjusting speed".
lock steering to srfretrograde.
rcs on.
wait 1.
clearscreen.
gear on.
//slamit(0,10,0).// "slamit(trueornot,ptplus,propatmo)."

until ship:altitude < 7000 {
	//vectors
	set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set targetla to inputcoordinates.
	set altvec to VXCL(up:vector,targetla:position-targetaltvec).
	set progradePground to VXCL(up:vector,velocity:surface).
	set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
	
	//arrows
	set anarrow to vecdraw(
		V(0,0,0),
		correctionvector,
		RGB(1,0,0),
		"correction vector",
		2.0,
		TRUE,
		1
	).
	set anarrow2 to vecdraw(
		V(0,0,0),
		targetaltvec,
		RGB(1,0,0),
		"Parallel to ground Target Vector",
		1.0,
		TRUE,
		0.5
	).
	set anarrow3 to vecdraw(
		V(0,0,0),
		ship:facing:starvector,
		RGB(1,10,0),
		"Starvec",
		1.0,
		TRUE,
		0.5
	).
	
	set anarrow5 to vecdraw(
		V(0,0,0),
		velocity:surface,
		RGB(1,5,0),
		"Surface Velocity",
		1.0,
		TRUE,
		0.5
	).
	
	set anarrow7 to vecdraw(
		V(0,0,0),
		VXCL(up:vector,velocity:surface),
		RGB(1,0,6),
		"VXCL prograde parallel to ground",
		1.0,
		TRUE,
		0.5
	).
		
	//-------------------------------------------------------------------
	if vang(progradePground,targetaltvec)> 0.8 {
		lock steering to correctionvector.
		set dacc to 1.
		print "Adjusting" + "                                     " at (0,2).
		print "Angle is " + round(vang(progradePground,targetaltvec),2)+ "  " at (0,3).
	
	}else{
		lock steering to correctionvector.
		set dacc to 0.
		print "All Good " + "                                     " at (0,2).
		print "Angle is " + round(vang(progradePground,targetaltvec),2)+ "  " at (0,3).
	}
	lock throttle to ntval_calc(dacc). 
}
lock steering to srfretrograde.
wait 4.
clearvecdraws().

until ship:status = "landed" {
	set khv to -ship:velocity:surface.
	set Vy to ship:verticalspeed.
	set Vx to groundspeed.
	set h to alt:radar.
	set vxlimit to (h/5) .
	if groundspeed > min(150,(max(10,vxlimit))) {
		lock steering to vectorexclude(ship:body:position,khv).
	}else{
			//fall guidance
	}
		
	if h > 1000 {
			set dsvy to -40.
	}else {
			set dsvy to min(-2,-20*(h/180)).
	}
		
		// this is to avoid the infinity error (which is triggered by a really big number)
	if vy/dsvy < sqrt(ln((100+constant:e)/4))
		{									  
			set dacc to 1*(constant:e^((vy/dsvy)^2) - constant:e^1). // this function: ne^(x^2)-ne , n is IR+ : does not return infinity values.
	}else{ 
			set dacc to 100.
	}
	
	lock throttle to ntval_calc(dacc).
	
	PRINT "RADAR ALTITUDE: " + ROUND(H,2) AT (0,10).
	PRINT "DESIRED THRUST: " + ROUND(SHIP:MASS*DACC,2) AT (0,9).
	PRINT "DESIRED VERTICAL SPEED: " + ROUND(DSVY,2) AT (0,8).
	PRINT "CURRENT VERTICAL SPEED: " + ROUND(SHIP:VERTICALSPEED,2) AT (0,7).
	
	set anarrow6 to vecdraw(
		V(0,0,0),
		vectorexclude(ship:body:position,khv),
		RGB(1,10,6),
		"KHV",
		1.0,
		TRUE,
		0.5
	).
	
}
CLEARVECDRAWS().
rcs off.
wait 1.
sas on.
print "Expected Successful landing" at (0,6).