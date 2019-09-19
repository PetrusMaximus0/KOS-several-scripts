// you need to dial these coordinates manually.
//local inputcoordinates to LATLNG(-1.01538400225137,179.861589454198).// do it here.
//local inputcoordinates to LATLNG(4+40/60+16/3600,101+38/60+49/3600).
LOCAL INPUTCOORDINATES TO LATLNG(0.45,27.15).
set ship:control:pilotmainthrottle to 0.
function ntval_calc{
   	// not accurate with solidrockets attached.
	parameter dacc.
	if ship:availablethrust > 0{
        return ship:mass*dacc/ship:availablethrust.	
   }else{
        return 0.
   }
}
function vectors {
	set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set InputCoordinates to inputcoordinates.
	set altvec to InputCoordinates:position-targetaltvec.
}
vectors().
local dacc to 0.
//--------------------------------------------------------------------------
function dircorrect {
	//vectors
	vectors().
	set progradePground to VXCL(up:vector,velocity:surface).
	set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
	//---------------------------------------------------------------------------------
	//2d correction
	if vang(progradePground,targetaltvec)> 0.5 {
		
		print "Adjusting   " + "          " at (0,2).
		print "Angle is  " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
		
		lock steering to correctionvector.
		// very important
		if vang(correctionvector,ship:facing:forevector)<5 {
			set dacc to 1*vang(progradePground,targetaltvec).
			
		}else{
			set dacc to 0.
		}
		
	}else{
		set dacc to 0.
		print "All Good    " at (0,2).
		print "Angle is " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
		
	}
	lock throttle to ntval_calc(dacc). 
}
local lastIntegralError to 0.
function MunDescentLz {
	//vectors
	vectors().
	set errorangle to vang (InputCoordinates:position,altvec).//for theta0.
	set HorizontalProgradeVec to VXCL(up:vector,velocity:surface).
	set correction2Vec to VXCL(VXCL(up:vector,targetaltvec),horizontalProgradeVec).
	set RCSassistVec to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	
	//multipliers adjust as necessary.
	set kd to 6. // 
	set kp to 2. //to remember this is not the real KP
	set ki to 0.// don't use this because error is always > 0.
	
    //derivative of the change in angle over time
	set theta0 to errorangle.
	set t0 to TIME:SECONDS.
		//give time
	wait 0.01.
	
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	set theta1 to errorangle.
	set t1 to TIME:SECONDS.
	
	//Integral calc and limiter this isnt really necessary, see above.
	set IntegralError to min(10,lastIntegralError+((theta0+theta1)/2)*(t1-t0)).
	set lastIntegralError to IntegralError.
	//deltas
	set deltatheta to theta1-theta0.
	set deltatime to t1-t0.
	set deltaerror to deltatheta/deltatime.
	// K is a multiplier to the amount of angle that the correction vector will have.
	// the "1" is a placeholder for the proportional part of the controller.
	// The real proportional part is calculated by the vector math and tuned by kp.
	
	set k to max(-1.2,min(1.2,(1*kp + kd*deltaerror+ki*integralerror))) . // when k = 1 the ship will point at a 45ยบ angle
															 //	The lower k the lower angle. The reverse applies.
	set correctionvector to k*(targetaltvec)-altvec-2*errorangle*correction2Vec.
	
	if errorangle > 1{
		wait 0.1.	
		set ship:control:neutralize to true.
		if alt:radar > 50 {
		
			if (HorizontalProgradeVec:mag < errorangle and errorangle < 60) { 
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting                   " at (5,13).
			
			}else if (HorizontalProgradeVec:mag > errorangle and errorangle < 60) {
				lock steering to lookdirup (-(ship:body:position:normalized+2*velocity:surface:normalized),v(0,0,1)).
				print "Mode is 2: Reducing Vx                 " at (5,13).			
			
			}else if errorangle > 60 {//test this part
				lock steering to lookdirup(-(ship:body:position:normalized+2*velocity:surface:normalized),v(0,0,1)).
				print "Mode is 3: Retrograde OFF target     " at (5,13).
			}
		}else if alt:radar < 50{
			
			if errorangle < 50 {
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 5: Precision Correction              " at (5,13).
			}else {
				lock steering to lookdirup(-(ship:body:position:normalized+2*velocity:surface:normalized),v(0,0,1)).
				print "Mode is 3: Retrograde OFF target     " at (5,13).
			}
		}
	
	}else if errorangle < 1 {
		local rcsmultiplier to 1.
		lock steering to lookdirup(-velocity:surface:normalized,v(0,0,1)).
		print "Mode is 4: Retrograde on Point!     " at (5,13).
		
		if Vang(RCSassistVec,ship:facing:topvector) < 90 {
			set ship:control:top to rcsmultiplier*errorangle.
		}else if Vang(RCSassistVec,ship:facing:topvector) > 90 {
			set ship:control:top to -rcsmultiplier*errorangle.
		}else{
			set ship:control:top to 0.
		}
		
		if vang(RCSassistVec,ship:facing:starvector) < 90 {
			set ship:control:starboard to rcsmultiplier*errorangle.
		}else if vang(RCSassistVec,ship:facing:starvector) > 90 {
			set ship:control:starboard to -rcsmultiplier*errorangle.
		}else{
			set ship:control:starboard to 0.
		}
		
	}

	print "INTEGRAL ERROR "  + round (integralerror,3)+ "     											       "      at (0,1).
	print "ERROR ANGLE "	 + round (vang (InputCoordinates:position,altvec),2) + "							       "   	  at (0,6).
	print "DELTA TIME " 	 + round (deltatime,3)  + "   												       "	  at (0,2).
	print "DELTA THETA " 	 + round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)				  at (0,3). 
	print "DELTA ERROR " 	 + round (deltaerror,3) + "     						 					       "      at (0,4).
	print "K FACTOR "  		 + round (k,3)          + "             " 					 							  at (0,5).
	print "TARGET DISTANCE " + round (InputCoordinates:POSITION:mag,1)+ "   									       "	  at (20,5).
	//
}
function munLandIT {
	set Vy to verticalspeed.
	set Vx to groundspeed.
	set h to alt:radar.
	
	if h > 1500 {
			set dsvy to -100.
	}else {
			set dsvy to min(-2,-20*(h/300)).
	}
		
		// this is to avoid the infinity error (which is triggered by a really big number)
	if vy/dsvy < sqrt(ln((100+constant:e)/4))
		{									  
			set dacc to 4*(constant:e^((vy/dsvy)^2) - constant:e^1). // this function: ne^(x^2)-ne , n is IR+ : does not return infinity values.
	}else{ 
			set dacc to 100.
	}
	
	if ship:status ="landed" {
		lock throttle to 0.
	}
	lock throttle to ntval_calc(dacc).
	
	PRINT "RADAR ALTITUDE: " + ROUND(H,2) AT (0,10).
	PRINT "DESIRED THRUST: " + ROUND(SHIP:MASS*DACC,2) AT (0,9).
	PRINT "DESIRED VERTICAL SPEED: " + ROUND(DSVY,2) AT (0,8).
	PRINT "CURRENT VERTICAL SPEED: " + ROUND(SHIP:VERTICALSPEED,2) AT (0,7).
}
function MunApproachLz {
//vectors
	vectors().
	set wangle to vang (altvec,targetaltvec).
	set progradePground to VXCL(up:vector,velocity:surface).
	set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
//2-run dircor when wangle less than 92.5.
	lock steering to retrograde.
	until wangle < 95 {
		print "WAngle is  " + round(wangle,2)+ "    " at (0,5).	
		vectors().
		set wangle to vang (altvec,targetaltvec).
		
	}
	
	until vang(correctionvector,-progradePground)< (max(90,wangle)-89.999999) {
		dircorrect().
		vectors().
		set wangle to vang (altvec,targetaltvec).
		print "WAngle is  " + round(wangle,2)+ "    " at (0,5).
	}
	set dacc to 0.
}
function munSlamHBurn{
	
	lock steering to -progradePground.
	print "Prepping Burn " 												    at (12,33).
	set a to min(30,ship:availablethrust/ship:mass). 
	
	until false {
		vectors().
		set hd to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)):mag.		
		set r to (body:radius+ship:altitude).
		set progradePground to VXCL(up:vector,velocity:surface).	
		set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
		set vx to groundspeed.
		set d  to 2*(constant:DegToRad*arcsin(0.5*hd/r))*r . // angle in degrees have to convert
		set burndist to (Vx^2)/(2*a).	
		
		print "Burn distance " +  round(burndist,2) +"                      " 			at (0,2).
		print "Distance (line) " +  round(hd,2) +"                          " 			at (0,3).
		print "Distance (curved) " +  round(d,2) +"                         " 			at (0,4).
		print "Available acceleration " +  round(a,2) +"                    " 			at (0,5).
		print "Distance to SlamPoint  " + round(d-burndist,2) + "        	"           at (0,6). 									
	
		set anarrow to vecdraw(
		V(0,0,0),progradePground,
		RGB(5,0,0),"Prograde Paralel to Ground",
		1.0,TRUE,0.5).
		
		set anarrow2 to vecdraw(
		V(0,0,0),targetaltvec,
		RGB(0,5,0),	"TARGET Paralel to Ground",
		1.0,TRUE,0.5).
				
		set LandingVector to VECDRAW(
		InputCoordinates:position,-altvec,
		GREEN,"Landing Position",
		1.0,TRUE,.5).
				
		
		if burndist > d {
			
			set dacc to a.
			print " Locked acceleration at " + a 								      at (16,33).
			break.
		}
	}
	print "VX < 1 ? " at (0,28).
	
	until ship:groundspeed < 1 {
		WAIT 0.1.
		set progradePground to VXCL(up:vector,velocity:surface). 
		lock throttle to ntval_calc(dacc).
		lock steering to -progradePground.
	}
	print "Aparently YES " at (0,29).
	lock throttle to 0.
}