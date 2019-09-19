local inputcoordinates to LATLNG(-0.097110810246358, -74.5673081677933).// do it here.
set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
set targetla to inputcoordinates.
set altvec to targetla:position-targetaltvec.

function arrows{
	set anarrow to vecdraw(
		V(0,0,0),
		targetla:position,
		RGB(1,0,0),
		"TARGET Vector",
		1.0,
		TRUE,
		0.5
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
		altvec,
		RGB(1,0,0),
		"Ship Altitude",
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

}
until ag1 {
	arrows().
	set translationVect_raw to targetaltvec.
	set translationVect_ship to translationVect_raw.
	set ship:control:translation to translationVect_ship.
	
	set anarrow14 to vecdraw(
			V(0,0,0),
			translationVect_ship,
			RGB(1,0,6),
			"translationvec",
			1.0,
			TRUE,
			0.5
		).
		
}
set ship:control:neutralize to true.


