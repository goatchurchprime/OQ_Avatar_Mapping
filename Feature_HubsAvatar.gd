extends Spatial


# The base avatar can be found here: https://github.com/MozillaReality/hubs-avatar-pipelines/tree/master/Blender/AvatarBot
# Compatible with the readyplayer.me half-body avatars
var avatarnode
var avatarroot
var avatarskeleton

var avatarlefthandrestpose
var avatarrighthandrestpose
var avatarheadrestpose

func _ready():
	avatarroot = find_node("AvatarRoot")
	if avatarroot != null:
		print("half-body avatar not found")
	avatarnode = avatarroot.get_parent()
	avatarskeleton = avatarnode.get_node("AvatarRoot/Skeleton")
	avatarlefthandrestpose = getAvatarhandskelrestpose(avatarskeleton, "left_hand")
	avatarrighthandrestpose = getAvatarhandskelrestpose(avatarskeleton, "right_hand")
	avatarheadrestpose = getAvatarheadskelrestpose(avatarskeleton)
	avatarskeleton.get_node("Wolf3D_Hair").visible = false

func makefingerrest(avatarskeleton, handname, fingername):
	var fingerrest = { 
		"i1":avatarskeleton.find_bone(handname+"_"+fingername+"_1"), 
		"i2":avatarskeleton.find_bone(handname+"_"+fingername+"_2"), 
		"i3":avatarskeleton.find_bone(handname+"_"+fingername+"_3") 
	}
	fingerrest["b1rest"] = avatarskeleton.get_bone_rest(fingerrest["i1"])
	fingerrest["b2rest"] = avatarskeleton.get_bone_rest(fingerrest["i2"])
	fingerrest["b3rest"] = avatarskeleton.get_bone_rest(fingerrest["i3"])
	return fingerrest

func getAvatarhandskelrestpose(avatarskeleton, handname):
	return { 
		"wristrest":avatarskeleton.get_bone_rest(avatarskeleton.find_bone(handname)),
		"thumbrest":makefingerrest(avatarskeleton, handname, "thumb"), 
		"indexrest":makefingerrest(avatarskeleton, handname, "index"),
		"middlerest":makefingerrest(avatarskeleton, handname, "middle"),
		"ringrest":makefingerrest(avatarskeleton, handname, "ring"),
		"pinkyrest":makefingerrest(avatarskeleton, handname, "pinky")
	}
	
func getAvatarheadskelrestpose(avatarskeleton):
	var headrest = { }
	for name in [ "hips", "spine", "neck", "head", "left_eye", "right_eye" ]:
		var i = avatarskeleton.find_bone(name)
		headrest["i"+name] = i
		headrest[name] = avatarskeleton.get_bone_rest(i) 
	assert(headrest["left_eye"].basis.x.is_equal_approx(headrest["right_eye"].basis.x))
	assert(headrest["left_eye"].basis.y.is_equal_approx(headrest["right_eye"].basis.y))
	assert(headrest["left_eye"].basis.z.is_equal_approx(headrest["right_eye"].basis.z))
	headrest["middle_eye"] = Transform(headrest["left_eye"].basis, 0.5*(headrest["left_eye"].origin + headrest["right_eye"].origin))
	return headrest

func oqsinglefingerknucklelocations(wristbasis, kl, oqrestpose, oqqhandpose, n0, n1, n2, n3, ntip, i0, i1, i2, i3):
	var t0 = Transform(wristbasis)
	if n0 != "":
		t0 = t0*Transform(oqqhandpose[i0], oqrestpose[n0].origin)
		kl[n0] = t0.origin
	var t1 = t0*Transform(oqqhandpose[i1], oqrestpose[n1].origin)
	kl[n1] = t1.origin
	var t2 = t1*Transform(oqqhandpose[i2], oqrestpose[n2].origin)
	kl[n2] = t2.origin
	var t3 = t2*Transform(oqqhandpose[i3], oqrestpose[n3].origin)
	kl[n3] = t3.origin
	kl[ntip] = t3.xform(oqrestpose[ntip].origin)

func oqcalcknucklelocations(wristbasis, oqrestpose, oqqhandpose):
	var OVRSkeleton = $OQ_Handmodel_Constants.OVRSkeleton
	var kl = { }
	oqsinglefingerknucklelocations(wristbasis, kl, oqrestpose, oqqhandpose, 
		"thumb_0", "thumb_1", "thumb_2", "thumb_3", "thumb_null",
		OVRSkeleton.Hand_Thumb0, OVRSkeleton.Hand_Thumb1, OVRSkeleton.Hand_Thumb2, OVRSkeleton.Hand_Thumb3)
	oqsinglefingerknucklelocations(wristbasis, kl, oqrestpose, oqqhandpose, 
		"", "index_1", "index_2", "index_3", "index_null",
		-1, OVRSkeleton.Hand_Index1, OVRSkeleton.Hand_Index2, OVRSkeleton.Hand_Index3)
	oqsinglefingerknucklelocations(wristbasis, kl, oqrestpose, oqqhandpose, 
		"", "middle_1", "middle_2", "middle_3", "middle_null", 
		-1, OVRSkeleton.Hand_Middle1, OVRSkeleton.Hand_Middle2, OVRSkeleton.Hand_Middle3)
	oqsinglefingerknucklelocations(wristbasis, kl, oqrestpose, oqqhandpose, 
		"", "ring_1", "ring_2", "ring_3", "ring_null",
		-1, OVRSkeleton.Hand_Ring1, OVRSkeleton.Hand_Ring2, OVRSkeleton.Hand_Ring3)
	oqsinglefingerknucklelocations(wristbasis, kl, oqrestpose, oqqhandpose, 
		"pinky_0", "pinky_1", "pinky_2", "pinky_3", "pinky_null",
		OVRSkeleton.Hand_Pinky0, OVRSkeleton.Hand_Pinky1, OVRSkeleton.Hand_Pinky2, OVRSkeleton.Hand_Pinky3)
	return kl


# Transform equations
# a*b = Transform(a.basis*b.basis, a.origin + a.basis*b.origin)
# a*b*c = Transform(a.basis*b.basis*c.basis, a.origin + a.basis*b.origin + a.basis*b.basis*c.origin)
# Solve for c where (a*b*c).origin = p
#   c.origin = (a.basis*b.basis).inverse()*(p - a.origin - a.basis*b.origin)
func solvecorigin(a, b, p):
	return (a.basis*b.basis).inverse()*(p - a.origin - a.basis*b.origin)

# rotationtoalign(a, b)*a is parallel to b
func rotationtoalign(a, b):
	var c = a.cross(b)
	var clength = c.length()
	var abl = a.length()*b.length()
	if abl == 0.0 or clength == 0.0:
		return Basis()
	var sinrot = clength/(a.length()*b.length())
	return Basis(c/clength, asin(sinrot))

func knucklealignedpose(t1, t2rest, t3restmove, kp2, kp3):
	var t2posemove = solvecorigin(t1, t2rest, kp2)
	var t2poserot = rotationtoalign(t3restmove, (t1.basis*t2rest.basis).inverse()*(kp3 - kp2))
	return Transform(t2poserot, t2posemove)

func knucklealignedfinger(a, twrist, fingerrest, ovrkl, fingername, sorigin):
	var absknuckle1pos = ovrkl[fingername+"_1"] + sorigin
	var absknuckle2pos = ovrkl[fingername+"_2"] + sorigin
	var absknuckle3pos = ovrkl[fingername+"_3"] + sorigin
	var absknuckletippos = ovrkl[fingername+"_null"] + sorigin

	var bone1pose = knucklealignedpose(twrist, fingerrest["b1rest"], fingerrest["b2rest"].origin, absknuckle1pos, absknuckle2pos)
	var tindex1 = twrist*fingerrest["b1rest"]*bone1pose
	var bone2pose = knucklealignedpose(tindex1, fingerrest["b2rest"], fingerrest["b3rest"].origin, absknuckle2pos, absknuckle3pos)
	var tindex2 = tindex1*fingerrest["b2rest"]*bone2pose
	var bone3pose = knucklealignedpose(tindex2, fingerrest["b3rest"], fingerrest["b3rest"].origin, absknuckle3pos, absknuckletippos)

	a.set_bone_pose(fingerrest["i1"], bone1pose)
	a.set_bone_pose(fingerrest["i2"], bone2pose)
	a.set_bone_pose(fingerrest["i3"], bone3pose)

func rpmsetrelpose(avatarskeleton, ovrkl, handname, twrist, sorigin):
	var thumbrest = makefingerrest(avatarskeleton, handname, "thumb")
	var indexrest = makefingerrest(avatarskeleton, handname, "index")
	var middlerest = makefingerrest(avatarskeleton, handname, "middle")
	var ringrest = makefingerrest(avatarskeleton, handname, "ring")
	var pinkyrest = makefingerrest(avatarskeleton, handname, "pinky")

	knucklealignedfinger(avatarskeleton, twrist, thumbrest, ovrkl, "thumb", sorigin)
	knucklealignedfinger(avatarskeleton, twrist, indexrest, ovrkl, "index", sorigin)
	knucklealignedfinger(avatarskeleton, twrist, middlerest, ovrkl, "middle", sorigin)
	knucklealignedfinger(avatarskeleton, twrist, ringrest, ovrkl, "ring", sorigin)
	knucklealignedfinger(avatarskeleton, twrist, pinkyrest, ovrkl, "pinky", sorigin)

func rpmsethandposerest(avatarskeleton, handname):
	for finger in ["thumb", "index", "middle", "ring", "pinky" ]:
		for n in ["1", "2", "3"]:
			var i = avatarskeleton.find_bone(handname+"_"+finger+"_"+n)
			assert (i != -1)
			avatarskeleton.set_bone_pose(i, Transform())


func basisfromtwovectorplane(a, b):
	var fz = a.cross(b).normalized()
	var fx = fz.cross(a + b).normalized()
	var fy = fz.cross(fx)
	return Basis(fx, fy, fz)

func rpmsetwristhandpose(wristtrans, oqrestpose, oqqhandpose, avatarhandrestpose, controllerorigin, avatarwristrest, handname):
	var oqknuckelocations = oqcalcknucklelocations(wristtrans.basis, oqrestpose, oqqhandpose)
	var v1 = basisfromtwovectorplane(avatarhandrestpose["indexrest"]["b1rest"].origin, avatarhandrestpose["pinkyrest"]["b1rest"].origin)
	var v2 = basisfromtwovectorplane(oqknuckelocations["index_1"], oqknuckelocations["pinky_1"])
	var wristdestiny = Transform(v2*v1.inverse(), controllerorigin)
	var bonewrist = avatarskeleton.find_bone(handname)
	avatarskeleton.set_bone_pose(bonewrist, avatarwristrest.inverse()*wristdestiny)
	var avatarskeletontransform = transform * avatarnode.transform * avatarroot.transform * avatarskeleton.transform
	var twrist = avatarskeletontransform * avatarskeleton.get_bone_global_pose(bonewrist)
	rpmsetrelpose(avatarskeleton, oqknuckelocations, handname, twrist, wristtrans.origin)


func _process(delta):
	#Drecordhandpositionforcontrollerpickup()

	# position the head and body of the avatar here
	# then the hands will be relative to it
	
	#var avatareyesightrot = Basis(-vr.vrCamera.transform.basis.x, -vr.vrCamera.transform.basis.z, vr.vrCamera.transform.basis.y)
	var avatareyesightrot = Basis(vr.vrCamera.transform.basis.x, -vr.vrCamera.transform.basis.z, vr.vrCamera.transform.basis.y)
	var avatareyesight = Transform(avatareyesightrot, vr.vrCamera.transform.origin)
	# solve: 
	#     avatareyesight = spinetrans*neckrest*neckpose*headrest*headpose*eyerest
	#   where spinerot=Basis(Vector3(0,1,0), spineang)
	
	var neckrest = avatarheadrestpose.neck
	var headrest = avatarheadrestpose["head"]
	var eyerest = avatarheadrestpose["middle_eye"]
	var hipsrest = avatarheadrestpose["hips"]
	var spinerest = avatarheadrestpose["spine"]
	#print(avatarskeleton.get_bone_global_pose(avatarskeleton.find_bone("left_eye")))
	
	#   headposerot = (spinerot*neckrestrot*headrestrot)^-1 * avatareyesightrot * (eyerestrot)^-1 
	var spineang = deg2rad(180)-Vector2(avatareyesightrot.x.x, avatareyesightrot.x.z).angle()
	var spinerot = Basis(Vector3(0,1,0), spineang)
	var headposerot = (spinerot*neckrest.basis*headrest.basis).inverse() * avatareyesightrot * (eyerest.basis).inverse()
	var headpose = Transform(headposerot, Vector3(0,0,0))
	var spinetrans = avatareyesight * (neckrest*headrest*headpose*eyerest).inverse()

	var avatarskeletontransform = spinetrans * (hipsrest*spinerest).inverse()
	avatarnode.transform = transform.inverse() * avatarskeletontransform * (avatarroot.transform*avatarskeleton.transform).inverse()
	
	avatarskeleton.set_bone_pose(avatarheadrestpose["ihead"], headpose)
	
	#var avatarskeletontransform = transform * avatarnode.transform * avatarroot.transform * avatarskeleton.transform
	var avatarleftwristrest = avatarskeletontransform * spinerest * avatarlefthandrestpose["wristrest"]
		
	if vr.leftController.is_hand:
		vr.leftController.visible = true
		var oqleftskeletonglobaltransform = vr.leftController.transform * $OQ_Handmodel_Constants.oq_lefthand_skeletontransform.scaled(vr.leftController._hand_model.model.scale)
		if vr.leftController._hand_model.tracking_confidence > 0:
			rpmsetwristhandpose(oqleftskeletonglobaltransform, $OQ_Handmodel_Constants.oq_lefthand_restpose, 
								vr.leftController._hand_model._vrapi_bone_orientations, 
								avatarlefthandrestpose, vr.leftController.transform.origin, 
								avatarleftwristrest, "left_hand")

	else:
		var leftwristdestiny = vr.leftController.transform * $OQ_Handmodel_Constants.oq_lefthand_controllerhandtransform
		vr.leftController.visible = true
		var oqleftskeletonglobaltransform = leftwristdestiny * $OQ_Handmodel_Constants.oq_lefthand_skeletontransform
		rpmsetwristhandpose(oqleftskeletonglobaltransform, $OQ_Handmodel_Constants.oq_lefthand_restpose, 
							$OQ_Handmodel_Constants.oq_lefthand_controllergrip_boneorientations, 
							avatarlefthandrestpose, leftwristdestiny.origin, 
							avatarleftwristrest, "left_hand")

		
	var avatarrightwristrest = avatarskeletontransform * spinerest * avatarrighthandrestpose["wristrest"]
	if vr.rightController.is_hand:
		vr.rightController.visible = true
		var oqrightskeletonglobaltransform = vr.rightController.transform * $OQ_Handmodel_Constants.oq_righthand_skeletontransform.scaled(vr.rightController._hand_model.model.scale)
		if vr.rightController._hand_model.tracking_confidence > 0:
			rpmsetwristhandpose(oqrightskeletonglobaltransform, $OQ_Handmodel_Constants.oq_righthand_restpose, 
								vr.rightController._hand_model._vrapi_bone_orientations, 
								avatarrighthandrestpose, vr.rightController.transform.origin, avatarrightwristrest, 
								"right_hand")

	else:
		var rightwristdestiny = vr.rightController.transform * $OQ_Handmodel_Constants.oq_righthand_controllerhandtransform
		vr.rightController.visible = true
		var oqrightskeletonglobaltransform = rightwristdestiny * $OQ_Handmodel_Constants.oq_righthand_skeletontransform
		rpmsetwristhandpose(oqrightskeletonglobaltransform, $OQ_Handmodel_Constants.oq_righthand_restpose, 
							$OQ_Handmodel_Constants.oq_righthand_controllergrip_boneorientations, 
							avatarrighthandrestpose, rightwristdestiny.origin, avatarrightwristrest, 
							"right_hand")


