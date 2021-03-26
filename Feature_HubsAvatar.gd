extends Spatial

var oqlefthandcontroller
var oqrighthandcontroller

# The base avatar can be found here: https://github.com/MozillaReality/hubs-avatar-pipelines/tree/master/Blender/AvatarBot
# Compatible with the readyplayer.me half-body avatars
var avatarnode
var avatarskeleton

var oqleftrestpose
var oqrightrestpose
var oqleftskeletontransform
var oqrightskeletontransform

var avatarlefthandrestpose
var avatarrighthandrestpose
var avatarheadrestpose

func _ready():

	oqlefthandcontroller = vr.leftController
	#oqlefthandskeleton = vr.leftController._hand_model.get_node("OculusQuestHand_Left/ArmatureLeft/Skeleton")
	oqrighthandcontroller = vr.rightController
	#oqrighthandskeleton = vr.rightController._hand_model.get_node("OculusQuestHand_Right/ArmatureRight/Skeleton")

	avatarnode = get_child(0)
	avatarskeleton = avatarnode.get_node("AvatarRoot/Skeleton")
	avatarlefthandrestpose = getAvatarhandskelrestpose(avatarskeleton, "left_hand")
	avatarrighthandrestpose = getAvatarhandskelrestpose(avatarskeleton, "right_hand")
	avatarheadrestpose = getAvatarheadskelrestpose(avatarskeleton)
	avatarskeleton.get_node("Wolf3D_Hair").visible = false

enum OVRSkeleton { # https://developer.oculus.com/documentation/unity/unity-handtracking/
	Hand_WristRoot   = 0, Hand_ForearmStub = 1, 
	Hand_Thumb0      = 2, Hand_Thumb1      = 3, Hand_Thumb2      = 4, Hand_Thumb3      = 5, # thumb distal phalange bone
						  Hand_Index1      = 6, Hand_Index2      = 7, Hand_Index3      = 8, 
						  Hand_Middle1     = 9, Hand_Middle2     = 10,Hand_Middle3     = 11,
						  Hand_Ring1       = 12,Hand_Ring2       = 13,Hand_Ring3       = 14,
	Hand_Pinky0      = 15,Hand_Pinky1      = 16,Hand_Pinky2      = 17,Hand_Pinky3      = 18
}

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
	#print(var2str(headrest["left_eye"].basis))
	#print(var2str(headrest["right_eye"].basis))
	assert(headrest["left_eye"].basis.x.is_equal_approx(headrest["right_eye"].basis.x))
	assert(headrest["left_eye"].basis.y.is_equal_approx(headrest["right_eye"].basis.y))
	assert(headrest["left_eye"].basis.z.is_equal_approx(headrest["right_eye"].basis.z))
	#print(headrest["left_eye"].basis.is_equal_approx(headrest["right_eye"].basis))
	#assert (headrest["left_eye"].basis.is_equal_approx(headrest["right_eye"].basis), 1e-3)
	headrest["middle_eye"] = Transform(headrest["left_eye"].basis, 0.5*(headrest["left_eye"].origin + headrest["right_eye"].origin))
	return headrest

func getOQskelrestpose(oqhandskeleton):
	var oqrestpose = { }
	for i in range(oqhandskeleton.get_bone_count()):
		var ambidextrousbonename = oqhandskeleton.get_bone_name(i).substr(4)
		oqrestpose[ambidextrousbonename] = oqhandskeleton.get_bone_rest(i)
	return oqrestpose

func recordresthandposes(avatarnode):
	var oqlefthandmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Left.gltf"
	var oqrighthandmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Right.gltf"
	var oqlefthandmodelI = load(oqlefthandmodel).instance()
	var oqrighthandmodelI = load(oqrighthandmodel).instance()
	oqleftrestpose = getOQskelrestpose(oqlefthandmodelI.get_node("ArmatureLeft/Skeleton"))
	oqrightrestpose = getOQskelrestpose(oqrighthandmodelI.get_node("ArmatureRight/Skeleton"))
	oqleftskeletontransform = oqlefthandmodelI.get_node("ArmatureLeft").transform*oqlefthandmodelI.get_node("ArmatureLeft/Skeleton").transform
	oqrightskeletontransform = oqrighthandmodelI.get_node("ArmatureRight").transform*oqrighthandmodelI.get_node("ArmatureRight/Skeleton").transform


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

func rpmsetrelpose(avatarskeleton, ovrkl, handname, sorigin):
	var bwrist = avatarskeleton.find_bone(handname)
	var twrist = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(bwrist)

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

var n = 0
var neckrot = 0
func _process(delta):
	if (vr.leftController.is_hand or vr.rightController.is_hand) and (oqleftrestpose == null):
		print("recording the rest pose values from the Quest hand model")
		recordresthandposes(avatarnode)

	# position the head and body of the avatar here
	# then the hands will be relative to it
	
	#var avatareyesightrot = Basis(-vr.vrCamera.transform.basis.x, -vr.vrCamera.transform.basis.z, vr.vrCamera.transform.basis.y)
	var avatareyesightrot = Basis(vr.vrCamera.transform.basis.x, -vr.vrCamera.transform.basis.z, vr.vrCamera.transform.basis.y)
	var avatareyesight = Transform(avatareyesightrot, vr.vrCamera.transform.origin)
	# solve: 
	#     avatareyesight = spinetrans*neckrest*neckpose*headrest*headpose*eyerest
	#   where spinerot=Basis(Vector3(0,1,0), spineang)
	var neckrest = avatarheadrestpose["neck"]
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

	#   spinetrans = avatartrans*hipsrest*spinerest
	avatarnode.transform = spinetrans * (hipsrest*spinerest).inverse()
	avatarskeleton.set_bone_pose(avatarheadrestpose["ihead"], headpose)
	
	var blefthand = avatarskeleton.find_bone("left_hand")
	# prefer to avoid next line and subsequently use *avatarskeleton.get_bone_pose(blefthand).inverse(), but doesn't work
	avatarskeleton.set_bone_pose(blefthand, Transform())
	var avatarleftwristrest = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(blefthand) 
	if vr.leftController.is_hand:
		vr.leftController.visible = true
		var hand_scale = vr.leftController._hand_model.model.scale
		var oqleftskeletonglobaltransform = vr.leftController.global_transform*oqleftskeletontransform.scaled(hand_scale)
		var oqleftknuckelocations = oqcalcknucklelocations(oqleftskeletonglobaltransform.basis, oqleftrestpose, vr.leftController._hand_model._vrapi_bone_orientations)

		var v1 = basisfromtwovectorplane(avatarlefthandrestpose["indexrest"]["b1rest"].origin, avatarlefthandrestpose["pinkyrest"]["b1rest"].origin)
		var v2 = basisfromtwovectorplane(oqleftknuckelocations["index_1"], oqleftknuckelocations["pinky_1"])
		var leftwristdestiny = Transform(v2*v1.inverse(), vr.leftController.global_transform.origin)
		avatarskeleton.set_bone_pose(blefthand, avatarleftwristrest.inverse()*leftwristdestiny)
		rpmsetrelpose(avatarskeleton, oqleftknuckelocations, "left_hand", oqleftskeletonglobaltransform.origin)
	else:
		var leftwristdestiny = vr.leftController.global_transform
		avatarskeleton.set_bone_pose(blefthand, avatarleftwristrest.inverse()*leftwristdestiny)
		vr.leftController.visible = true
		rpmsethandposerest(avatarskeleton, "left_hand")

	var brighthand = avatarskeleton.find_bone("right_hand")
	avatarskeleton.set_bone_pose(brighthand, Transform())
	var avatarrightwristrest = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(brighthand) # *(avatarskeleton.get_bone_pose(brighthand).inverse())
	if vr.rightController.is_hand:
		vr.rightController.visible = false
		var hand_scale = vr.rightController._hand_model.model.scale
		var oqrightskeletonglobaltransform = vr.rightController.global_transform*oqrightskeletontransform.scaled(hand_scale)
		var oqrightknuckelocations = oqcalcknucklelocations(oqrightskeletonglobaltransform.basis, oqrightrestpose, vr.rightController._hand_model._vrapi_bone_orientations)

		var v1 = basisfromtwovectorplane(avatarrighthandrestpose["indexrest"]["b1rest"].origin, avatarrighthandrestpose["pinkyrest"]["b1rest"].origin)
		var v2 = basisfromtwovectorplane(oqrightknuckelocations["index_1"], oqrightknuckelocations["pinky_1"])
		var rightwristdestiny = Transform(v2*v1.inverse(), vr.rightController.global_transform.origin)
		avatarskeleton.set_bone_pose(brighthand, avatarrightwristrest.inverse()*rightwristdestiny)
		rpmsetrelpose(avatarskeleton, oqrightknuckelocations, "right_hand", oqrightskeletonglobaltransform.origin)
	else:
		var rightwristdestiny = vr.rightController.global_transform
		avatarskeleton.set_bone_pose(brighthand, avatarrightwristrest.inverse()*rightwristdestiny)
		vr.rightController.visible = true
		rpmsethandposerest(avatarskeleton, "right_hand")


