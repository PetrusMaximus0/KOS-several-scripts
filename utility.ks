//Utility library
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
