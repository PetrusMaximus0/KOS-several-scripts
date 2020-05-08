// Kerbin Function LiB
// DO NOT switch THE ORDER OF THE FUNCTIONS!
@lazyglobal off.
set ship:control:pilotmainthrottle to 0.
global deltavee to 0.
function currentg{
	return (ship:body):mu /(SHIP:ALTITUDE + (ship:body):RADIUS)^2.
}
function ntval_calc{
   	// not accurate with SRBs attached.
	parameter desiredAcceleration.//desired acceleration
	if ship:availablethrust > 0{
        return ship:mass*desiredAcceleration/ship:availablethrust.	
   }else{
        return 0.
   }
}
function tval_calc{
	// not accurate with SRBs attached.
	parameter DesiredTwr.
	if Ship:AvailableThrust > 0{
		return DesiredTWR / (Ship:AvailableThrust / (Ship:Mass * currentg()))  . //   tval = dtwr/(F/mg),  F = maxthrust
	}else{ 
		return 0. 
	}
}
function stagelogic{
	//local EngineHasFlameOut to false.
	local motorlist to 0.
	local engineNumberIS to 0.
	local n to 0. 	
	when true then {
		set engineNumberIs to 0.
		wait 0.5.				
		list engines in motorlist.
		For eng in motorlist{
			set n to n+1.
			set engineNumberIS to engineNumberIS + 1.
			print "EngineNumber: " + engineNumberIS at (10,18+n).
			if eng:FLAMEOUT = true {
				stage.
				clearscreen.
				print "engine nº " + engineNUmberIs + " flamed out".
			}
			if eng:stage=stage:number and eng:ignition = false {			
				eng:activate.
				clearscreen.
				print "engine nº " + engineNUmberIs + " was restarted".
			}
		}
		set engineNumberIS to 0.
		preserve.
	}
	//stagelogic().
}
function landIt{
	SteeringManager:RESETTODEFAULT().
	parameter hov.
	local dsrtwr to 0.
	local h to 0.
	local dsvy to 0.
	local Vy to 0.	
	brakes on.
	gear on.
	lights on.
	Print "maintaining speed".
	lock throttle to tval_calc(dsrtwr).
	until ship:status = "landed" OR ship:status = "splashed" {
		wait 0.
		set h to alt:radar.	
		if h > 80 {
			set dsvy to max((min(-8,(-h/20))),-40).
		//}else {
			//set dsvy to min(-3,6*(-h/40)).
		}		
		set Vy to ship:verticalspeed.
		set dsrtwr to (Vy/dsVy).	
		if hov = 1{
			hover(0.45, 0.6, 0).
		}		
		if dsrtwr > ship:availablethrust/(ship:mass*currentg()) {
			 brakes on.
		}else{ 
			 brakes off.
		}
		print "rad altitude: " + round(h,2) at (0,9).
		print "desired twr: " + round(dsrtwr,2) at (0,8).
		print "desired vertical speed: " + round(dsvy,2) at (0,7).		
	}
	set dsrtwr to 0.
	unlock ALL.
}
function slamit{
	rcs on.
	//"slamit(XtraD,propatmo,maxG)."
	parameter XtraD. // Xtra distance to ground
	parameter propatmo.// 1 for yes 0 for no
	parameter MaxG.	//Mandatory Input!
	local accel to 0.
	local Vy to 0.
	local burndist to 0.
	local aReal to 0.
	local dist to 0.
	local desiredAcceleration to 0.
	until false {
		wait 0.
		if propatmo = 1 {
			properatmo().
		}else if propatmo = 0{
			lock steering to srfretrograde.
		}
		set      accel 		    to 		min(MaXG,(ship:availablethrust/ship:mass)). //acceleration
		set  	 Vy			to		abs(airspeed).
		set  	 dist		to      alt:radar. 		
		set      aReal		to		accel-currentg().
		set		 burndist   to 		(Vy^2)/(2*aReal).
		
		print round (alt:radar,2)     +		"  Read alt radar "      	    at (0,14).
		print round (verticalspeed,2) +     "  Vertical speed " 			at (0,15).
		print round (burndist,2) 	  + 	"  Burn distance "  	 		at (0,16).
		print round (accel,2) 			  + 	"  Raw available Accel "	    at (0,17).
		print round (aReal,2) 		  + 	"  Corrected Av. Accel "	    at (0,18).
		
		if  burndist+XtraD > dist and alt:radar < 3000  {
			clearscreen.
			set desiredAcceleration to accel.
			Break.
		}		
	}	
	gear on.
	until verticalspeed > -100{
		brakes off.
		lock steering to srfretrograde.
		lock throttle to ntval_calc(desiredAcceleration).
		wait 0.
	}
	LandIt(1).
}	
function Rocket_Ascent{
	//Power and trajectory guidance for ascent.
	//This script can be restarted mid flight.
	parameter OrbitHeading.
	parameter MaxAcc.
	parameter TargetApo.
	clearscreen.
	print "Running Ascent Guidance" at (0,20).
	//declare variables
	local desiredAcceleration to 15. //max desired acc initially
	local initialAngle to 90. // initial angle in current flight
	local angleAltitudeRatio to 0.
	lock throttle to ntval_calc(desiredAcceleration).
	lock steering to heading(OrbitHeading,(initialAngle-angleAltitudeRatio*45)).
	print "Target heading is " + OrbitHeading + " degrees".
	gear off.
	until ship:altitude > 11000 {
		set angleAltitudeRatio to (ship:altitude/11000). // at 11000m = 1
		print round(initialAngle-angleAltitudeRatio*45)+" degrees" at (0,9). //at 11000m pitch will be 90-45*1 degrees
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		//abort_logic( heading(OrbitHeading,(initialAngle-angleAltitudeRatio*45)) ).
		wait 0.
			
	}
	set initialAngle to 45.// setting to our expected current pitch at this time.
	set desiredAcceleration to maxacc. // new desired acc
	print desiredAcceleration + " is desired acc" at (0,11).
	//30m\s max acc and continue the gravity turn so that 
	//the ship points at 0 degrees by the time it reaches altitude 47 000 meters .
	until ship:apoapsis > TargetApo	{
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		set angleAltitudeRatio to ((ship:altitude-11000)/(47000-11000)). // angleAltitudeRatio is 1 at 47000m
		//abort_logic( heading(OrbitHeading,(initialAngle-angleAltitudeRatio*45)) ).
		print round(initialAngle-angleAltitudeRatio*45)+" degrees" at (0,9).
		wait 0.
	}	
}
function ReentryHeadingCorrection{
		clearscreen.
	parameter InputCoordinates.
	local desiredAcceleration to 0.
	local progradePground to VXCL(up:vector,velocity:surface).
	local targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	local altvec to InputCoordinates:position-targetaltvec.
	local wangle to vang (altvec,targetaltvec).
	local correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
	
	lock throttle to ntval_calc(desiredAcceleration).
	lock steering to prograde.
	print "Running Reentry " at (0,20).
	if verticalspeed > 0{
		wait until ship:altitude > 50000.
		print "Stand By... " at (0,21).
	}
	clearscreen.
	until wangle < 100 {
		set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
		set altvec to InputCoordinates:position-targetaltvec.
		set wangle to vang(altvec,targetaltvec).
		print "WAngle is  " + round(wangle,2)+ "    " at (0,5).	
	}
	until vang(progradePground,targetaltvec)< (max(90,wangle)-89.9) OR ALTITUDE < 50000{
		wait 0.01.
		set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
		set altvec to InputCoordinates:position-targetaltvec.
		set progradePground to VXCL(up:vector,velocity:surface).
		set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
		if vang(progradePground,targetaltvec)> 0.5 {
			print "Adjusting   " + "          " at (0,2).
			print "Angle is  " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
			lock steering to correctionvector.
			if vang(correctionvector,ship:facing:forevector) < 8 {
				set desiredAcceleration to vang(progradePground,targetaltvec).
			}else{
				set desiredAcceleration to 0.
			}
		}else{
			set desiredAcceleration to 0.
			print "All Good    " at (0,2).
			print "Angle is " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
		}
		set wangle to vang (altvec,targetaltvec).
		print "Wangle is  " + round(wangle,2)+ "    " at (0,4).
	}
	wait 2.
}
function ReentryPitchCorrection{
	parameter InputCoordinates.
	local desiredAcceleration to 0.
	local TrImpact to addons:tr:impactpos:position.
	clearscreen.
	LOCK THROTTLE TO ntval_calc(desiredAcceleration).
	lock steering to Lookdirup(-ship:velocity:surface,ship:body:position).
	wait until vang(velocity:surface,-facing:forevector) < 5.
	UNTIL (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag < 3000 or altitude< 55000 {
		wait 0.
		if (v(0,0,0)+Trimpact):mag < (v(0,0,0)+InputCoordinates:position):mag {
			SET DESIREDaCCELERATION TO 0.
			until (v(0,0,0)+Trimpact):mag > (v(0,0,0)+InputCoordinates:position):mag + 200{
				set TrImpact to addons:tr:impactpos:position.
				lock steering to VXCL(up:vector,TrImpact).
				wait until vang(VXCL(up:vector,TrImpact),facing:forevector) < 5.
				set desiredAcceleration to 20.
				wait 0.
				Print " D IS " + (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag  at  (10,12).
			}
			SET DESIREDaCCELERATION TO 0.
		}else{
			lock steering to VXCL(up:vector,-velocity:surface).
			wait until vang(ship:facing:vector, VXCL(up:vector,-velocity:surface)) < 10 .
			set TrImpact to addons:tr:impactpos:position.
			Print "Correcting for OVERSHOOT" at (10,10).
			Print " D IS " + (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag  at  (10,12).
			set desiredAcceleration to max(20,vang(TrImpact,InputCoordinates:position)).

		}
		
	}
	set desiredAcceleration to 0.
	Print "angle correct ENDED    " at (10,10).
	unlock all.
}

function properatmo{
	//vectors
	local targetaltvec 		to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	local altvec 				to InputCoordinates:position-targetaltvec.
	local progradePground 		to VXCL(up:vector,velocity:surface).
	local wangle 				to vang (altvec,targetaltvec).
	local errorangle 			to vang (InputCoordinates:position,altvec).//for theta0.
	local correction2Vec 		to VXCL(VXCL(up:vector,targetaltvec),ProgradePground).//eliminates "spin of death"
	local RCSassistVec 		to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	//multipliers adjust as necessary.
	local kd to 2.0. // 
	local kp to 1.9. //
	//
	local theta0 to errorangle.//for easier read
	local t0 to TIME:SECONDS.
	//give time
	wait 0.005.
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	local theta1 to errorangle.
	local t1 to TIME:SECONDS.
	//deltas
	local deltatheta to theta1-theta0. //change in angle.
	local deltatime to t1-t0.         //0.01 seconds.
	local deltaerror to deltatheta/deltatime.  // change in error angle per 0.01 seconds.
	//
	local k to 1*kp + kd*deltaerror.
	local correctionvector to -(k*targetaltvec + InputCoordinates:position-30*correction2Vec).
	//
	if wangle < 92.5 or alt:radar < 20000 {
		if errorangle < 0.5  { 
			lock steering to -InputCoordinates:position.
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
		
		if errorangle > 0.5 {
			lock steering to correctionvector.
			print "     adjusting   " at (0,7). 
		}
	
	}else { 
			lock steering to srfretrograde.
	}
	//print "INTEGRAL ERROR"  + round (integralerror,3)+ "   " 													at (0,1).
	print "ERROR ANGLE "	+ round (vang (InputCoordinates:position,altvec),2) 										at (0,6).
	print "DELTATIME " 		+ round (deltatime,3)  + "   " 														at (0,2).
	print "DELTATHETA " 	+ round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTAERROR " 	+ round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		+ round (k,3)          + "   " 							 							at (0,5).

	if (errorangle < 40 or alt:radar < 4000)  and velocity:surface:mag > 200{
		brakes on.
	}else if velocity:surface:mag > 600 and (alt:radar > 4000 and alt:radar < 20000){
		brakes on.
	}else{
		brakes off.
	}	
	if (errorangle > 50 and alt:radar < 5000) { //failsafe.
		clearscreen.
		Print " RUNNING FAILSAFE " at (0,1).
		Slamit(50,0,100).
		LandIt(0).
		return 0.
	}
}
function hover{
	parameter kp, kd, ki.
	local lastIntegralError to 0.
	brakes on.
	//vectors
	local targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	local InputCoordinates to inputcoordinates.
	local altvec to InputCoordinates:position-targetaltvec.
	local RCSassistVec to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	local errorangle to vang (InputCoordinates:position,altvec).//for theta0.
	local ProgradePground to VXCL(up:vector,velocity:surface).
	local correction2Vec to VXCL(VXCL(up:vector,targetaltvec),ProgradePground).
	//multipliers adjust as necessary.
	//set kp to 0.45. //to remember this is not the real KP
	//set kd to 0.225. // 
	//set ki to 0.// don't use this because error is always > 0.
	//derivative of the change in angle over time
	local theta0 to errorangle.
	local t0 to TIME:SECONDS.
		//give time
	wait 0.005.
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	local theta1 to errorangle.
	local t1 to TIME:SECONDS.
	//Integral calc and limiter this isnt really necessary, see above.
	local IntegralError to min(10,lastIntegralError+((theta0+theta1)/2)*(t1-t0)).
	set lastIntegralError to IntegralError.
	//deltas
	local deltatheta to theta1-theta0.
	local deltatime to t1-t0.
	local deltaerror to deltatheta/deltatime.
	// K is a multiplier to the amount of angle that the correction vector will have.
		// the "1" is a placeholder for the proportional part of the controller.
		// The real proportional part is calculated by the vector math and tuned by kp.
	//	The lower k the lower angle. The reverse applies.
	local k to 1*kp + kd*deltaerror + ki*integralerror . // when k = 1 the ship will point at a 45ยบ angle
	local correctionvector to k*(targetaltvec)-altvec-8*correction2Vec .
	if errorangle > 10 {
		set ship:control:top to 0.
		set ship:control:starboard to 0.
		if alt:radar > 50 {	
			if errorangle > 30 and alt:radar < 1000{
				lock steering to -(ship:velocity:surface:normalized+ship:body:position:normalized).
				print "Mode is 3B: Retrograde OFF target(failsafe)    " at (5,12).
			}else{
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting                 " at (5,12).
			}		
		}else if alt:radar < 50{			
			if errorangle < 20 {
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting               " at (5,12).
			}else {
				lock steering to -(0.66*ship:velocity:surface:normalized+SHIP:BODY:POSITION:normalized).
				print "Mode is 3: Retrograde OFF target              " at (5,12).
			}
		}
	}else if errorangle < 10 {//needs to be adjusted for shipheight.
		lock steering to lookdirup(-(ship:body:position:normalized+0.66*velocity:surface:normalized),v(0,0,1)).
		print "Mode is 4: Retrograde on Point!               " at (5,12).
		set lastIntegralError to 0.
		if Vang(RCSassistVec,ship:facing:topvector) < 89 {
			set ship:control:top to 0.25*ERRORANGLE.
		}else if Vang(RCSassistVec,ship:facing:topvector) > 91 {
			set ship:control:top to -0.25*ERRORANGLE.
		}else{
			set ship:control:top to 0.
		}		
		if vang(RCSassistVec,ship:facing:starvector) < 89 {
			set ship:control:starboard to 0.25*ERRORANGLE.
		}else if vang(RCSassistVec,ship:facing:starvector) > 91 {
			set ship:control:starboard to -0.25*ERRORANGLE.
		}else{
			set ship:control:starboard to 0.
		}
	}
	//	
	print "INTEGRAL ERROR"   + round (integralerror,3)+ "   " 													at (0,1).
	print "ERROR ANGLE "	 + round (vang (InputCoordinates:position,altvec),2) 										at (0,6).
	print "DELTA TIME " 	 + round (deltatime,3)  + "   " 													at (0,2).
	print "DELTA THETA " 	 + round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTA ERROR " 	 + round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		 + round (k,3)          + "   " 							 						at (0,5).
	print "TARGET DISTANCE " + round (InputCoordinates:POSITION:mag,1)+ "   " 											at (20,5).
	//
}
function launchProcedure{
	set ship:control:pilotmainthrottle to 0.
	lights on.
	rcs on.
	sas off.
	print "setup complete".
	print "waiting for launch conditions".
	wait 1.
	if  (ship:status = "prelaunch" and stage:liquidfuel <= 0 and stage:solidfuel <= 0)  {
		print "Launch conditions met".
		print "Launching from prelaunch status".
		lock throttle to 1.
		stage.
	}else if  ship:status = "landed"{
		print "Launch conditions met".
		print "Launching from landed status, check headings".
		lock throttle to 1.	
	}
}
function ProgradeStabilize {
	local englist to 0.
	list engines in englist.
	For eng in englist{
		eng:shutdown.
	}
	set throttle to 0.
	set ship:control:pilotmainthrottle to 0.
	lock steering to prograde.
}
function ShipAngularMomentum {
	local R_Ap to ship:apoapsis+Orbit:BODY:radius.
	local R_Pe to ship:periapsis+Orbit:BODY:radius.
	return ship:mass* sqrt( (2*Orbit:BODY:Mu)/(1/R_Ap+1/R_Pe) ). 
}
function OrbitalSpeedAtCritPointEliptical {
	Parameter APorPE.//use "AP" or use  "PE"
	Local MaxAltChoice to 0.

	if APorPE = "AP"{
		set MaxAltChoice to ship:apoapsis+Orbit:body:radius.
	
	}else if APorPE = "PE"{
		set MaxAltChoice to ship:periapsis+Orbit:body:radius.
	
	}else{		
		print("error Calling function").
		return 0.
	}
	Return ShipAngularMomentum()/(ship:mass * MaxAltChoice).
}
function OrbitalSpeedCircular {
	parameter expectedApo.
	return sqrt(orbit:body:Mu/(expectedApo+orbit:body:radius)).

}
function AverageISP {
	
	local ISPsum to 0.
	local NumberOfEngines to 0.
	local engineList to 0.
	list engines in engineList.
	for motors in engineList {
		if motors:stage = stage:number {
			motors:activate.
		}
		set NumberOfEngines to NumberOfEngines+1.
		set ISPsum to ISPsum + round(motors:isp).
		print "EngineNumber " + NumberOfEngines +" ISPtotal = "+ ISPsum at (0,1).
	}
	return ISPsum/NumberOfEngines.
}
function abort_logic{
	//not working at all
	parameter desiredHeading.
	local myvec to desiredHeading:vector.
	local allowedOffset to 15. //in degrees 
	if ( vang(myvec, ship:prograde) > allowedOffset) {
		abort on.
		sas off.
		rcs off.
		unlock all.
		wait 10.
		clearscreen.
		print ("Aborted!").
		reboot.
	}
}
function exnode{
	clearscreen.
	set ship:control:pilotmainthrottle to 0.
	lock throttle to 0.
	SAS off.
	rcs on.
	local deltaVee to nextnode:deltav:mag.
	local BurnTime to .5*deltavee*mass/availablethrust.
	lock steering to LOOKDIRUP(nextnode:burnvector,facing:topvector).
	print "Aligning with Maneuver Node".
	until VANG(ship:facing:vector,nextnode:burnvector) < 1 {
		print "Direction Angle Error = " + round(VANG(ship:facing:vector,nextnode:burnvector),1) + "   "at(0,1).
	}
	clearscreen.
	print "Warping to Node".
	print "Burn Starts at T-minus " + round(BurnTime,2) + "secs   ".
	warpto(time:seconds + nextnode:eta - BurnTime - 10).
	wait until BurnTime >= nextnode:eta.

	clearscreen.
	//lock throttle to deltavee*mass/availablethrust.

	print "Executing Node".

	until deltavee <= .1 {
		if VANG(ship:facing:vector,nextnode:burnvector) < 1 {
			lock throttle to deltavee*mass/availablethrust.
		}else{
			lock throttle to 0.
		}
		print "Delta V = " + round(deltavee,1) + "   " at(0,1).
		print "Throttle = " + MIN(100,round(throttle*100)) + "%   " at(0,2).
	}
	lock throttle to 0.
	unlock all.
	rcs off.
	sas on.
	remove nextnode.
	clearscreen.
	print "Node Executed".
}