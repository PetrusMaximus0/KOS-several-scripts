// you need to dial these coordinates manually.
// OTHER CONTINENT LANDING SPOT.
//local inputcoordinates to LATLNG(-0.097110810246358, -74.5673081677933).// do it here.
function vectors {
set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
set targetla to inputcoordinates.
set altvec to targetla:position-targetaltvec.
set RCSassistVec to (v(0,0,0)+targetla:altitudeposition(ship:altitude)).
}
vectors().
//--------------------------------------------------------------------------
function arrows{
	set anarrow to vecdraw(
		V(0,0,0),targetla:position,
		RGB(1,0,0),	"TARGET Vector",
		1.0,TRUE,0.5).
	set anarrow2 to vecdraw(
		V(0,0,0),targetaltvec,
		RGB(1,0,0),"Parallel to ground Target Vector",
		1.0,TRUE,0.5
	).
	set anarrow3 to vecdraw(
		V(0,0,0),ship:facing:starvector,
		RGB(1,10,0),"Starvec",
		1.0,TRUE,0.5
	).
	
	set anarrow5 to vecdraw(
		V(0,0,0),velocity:surface,
		RGB(1,5,0),"Surface Velocity",
		1.0,TRUE,0.5).
	
	set anarrow7 to vecdraw(
		V(0,0,0),VXCL(up:vector,velocity:surface),
		RGB(1,0,6),"VXCL prograde parallel to ground",
		1.0,TRUE,0.5
	).
}

local lastIntegralError to 0.
function hover {
	brakes on.
	//vectors
	vectors().
	set errorangle to vang (targetla:position,altvec).//for theta0.
	set HorizontalProgradeVec to VXCL(up:vector,velocity:surface).
	set correction2Vec to VXCL(VXCL(up:vector,targetaltvec),horizontalProgradeVec).
	//multipliers adjust as necessary.
	set kd to 0.015. // 
	set kp to 0.15. //to remember this is not the real KP
	set ki to 0.// don't use this because error is always > 0.
	//derivative of the change in angle over time
	set theta0 to errorangle.
	set t0 to TIME:SECONDS.
		//give time
	wait 0.01.
	set errorangle to vang (targetla:position,altvec).//calc it for theta1.
	set theta1 to errorangle.
	set t1 to TIME:SECONDS.
	//Integral calc and limiter this isnt really necessary, see above.
	set IntegralError to min(10,lastIntegralError+((theta0+theta1)/2)*(t1-t0)).
	set lastIntegralError to IntegralError.
	//deltas
	set deltatheta to theta1-theta0.
	set deltatime to t1-t0.
	set deltaerror to deltatheta/deltatime.
	//arrows().
	// K is a multiplier to the amount of angle that the correction vector will have.
		// the "1" is a placeholder for the proportional part of the controller.
		// The real proportional part is calculated by the vector math and tuned by kp.
	
	set k to max(-1,min(1,(1*kp + kd*deltaerror+ki*integralerror))) . // when k = 1 the ship will point at a 45º angle
														 //	The lower k the lower angle. The reverse applies.
	set correctionvector to k*(targetaltvec)-altvec-(4/groundspeed)*correction2Vec .
	
	if errorangle > 4 {
		if alt:radar > 50 {
			lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting                 " at (5,12).
		}else if alt:radar < 50{
			if errorangle < 30 {
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting               " at (5,12).
			}else {
				lock steering to lookdirup(-(ship:body:position:normalized+2*velocity:surface:normalized),v(0,0,1)).
				print "Mode is 3: Retrograde OFF target     " at (5,12).
			}
		}
	}else if errorangle < 4 {//needs to be adjusted for shipheight.
		
		lock steering to lookdirup(-(2*ship:body:position:normalized+velocity:surface:normalized),v(0,0,1)).
		print "Mode is 4: Retrograde on Point!               " at (5,12).
		
		wait 0.01.
		if Vang(RCSassistVec,ship:facing:topvector) < 90 {
			set ship:control:top to 1.
		}else if Vang(RCSassistVec,ship:facing:topvector) > 90 {
			set ship:control:top to -1.
		}else{
			set ship:control:top to 0.
		}
		
		if vang(RCSassistVec,ship:facing:starvector) < 90 {
			set ship:control:starboard to 1.
		}else if vang(RCSassistVec,ship:facing:starvector) > 90 {
			set ship:control:starboard to -1.
		}else{
			set ship:control:starboard to 0.
		}
	}
	//	
	print "INTEGRAL ERROR"   + round (integralerror,3)+ "   " 													at (0,1).
	print "ERROR ANGLE "	 + round (vang (targetla:position,altvec),2) 										at (0,6).
	print "DELTA TIME " 	 + round (deltatime,3)  + "   " 													at (0,2).
	print "DELTA THETA " 	 + round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTA ERROR " 	 + round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		 + round (k,3)          + "   " 							 						at (0,5).
	print "TARGET DISTANCE " + round (targetla:POSITION:mag,1)+ "   " 											at (20,5).
	//
}
function properatmo {
	//vectors
	vectors().
	set errorangle to vang (targetla:position,altvec).//for theta0.
	set wangle to vang (altvec,targetaltvec).
	set HorizontalProgradeVec to VXCL(up:vector,velocity:surface).
	set correction2Vec to VXCL(VXCL(up:vector,targetaltvec),horizontalProgradeVec).
	//multipliers adjust as necessary.
	set kd to 1.95. // 
	set kp to 2. //to remember this is not the real KP
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
	//
	set k to max(-10,min(10,(1*kp + kd*deltaerror))).
	set correctionvector to -(k*targetaltvec + targetla:position-30*correction2Vec) .
	//
	if wangle < 92.5 or alt:radar < 20000 {
		if errorangle < 1  { 
			lock steering to -targetla:position.
			print "    steering to TARGET  LZ   " at (0,7).
			if Vang(RCSassistVec,ship:facing:topvector) < 90 {
					set ship:control:top to 1.
			}else if Vang(RCSassistVec,ship:facing:topvector) > 90 {
				set ship:control:top to -1.
			}else{
				set ship:control:top to 0.
			}
			
			if vang(RCSassistVec,ship:facing:starvector) < 90 {
				set ship:control:starboard to 1.
			}else if vang(RCSassistVec,ship:facing:starvector) > 90 {
				set ship:control:starboard to -1.
			}else{
				set ship:control:starboard to 0.
			}		
		}
		
		if errorangle > 1 {
			lock steering to correctionvector.
			print "     adjusting   " at (0,7). 
		}
	
	}else { 
			lock steering to srfretrograde.
	}
	//print "INTEGRAL ERROR"  + round (integralerror,3)+ "   " 													at (0,1).
	print "ERROR ANGLE "	+ round (vang (targetla:position,altvec),2) 										at (0,6).
	print "DELTATIME " 		+ round (deltatime,3)  + "   " 														at (0,2).
	print "DELTATHETA " 	+ round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTAERROR " 	+ round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		+ round (k,3)          + "   " 							 							at (0,5).
	//
	
	
	if (errorangle < 40 or alt:radar < 10000)  and velocity:surface:mag > 200{
		brakes On.
	}else if velocity:surface:mag > 800 and (alt:radar > 10000 and alt:radar < 15000){
		brakes on.
	}else{
		brakes off.
	}	
	if (errorangle > 60 and alt:radar < 5000) { //failsafe.
		clearscreen.
		Print " RUNNING FAILSAFE " at (0,1).
		run lrnatmo.
		return 0.
		
		
	}
}