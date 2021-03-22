extends Spatial

onready var oqlefthandcontroller = $OculusQuestHand_Left
onready var oqrighthandcontroller = $OculusQuestHand_Right
onready var oqlefthandskeleton = $OculusQuestHand_Left/ArmatureLeft/Skeleton
onready var oqrighthandskeleton = $OculusQuestHand_Right/ArmatureRight/Skeleton
onready var avatarnode = $AvatarBot_base_for_export_altbody


enum OVRSkeleton { # https://developer.oculus.com/documentation/unity/unity-handtracking/
	Hand_WristRoot   = 0, Hand_ForearmStub = 1, 
	Hand_Thumb0      = 2, Hand_Thumb1      = 3, Hand_Thumb2      = 4, Hand_Thumb3      = 5, # thumb distal phalange bone
						  Hand_Index1      = 6, Hand_Index2      = 7, Hand_Index3      = 8, 
						  Hand_Middle1     = 9, Hand_Middle2     = 10,Hand_Middle3     = 11,
						  Hand_Ring1       = 12,Hand_Ring2       = 13,Hand_Ring3       = 14,
	Hand_Pinky0      = 15,Hand_Pinky1      = 16,Hand_Pinky2      = 17,Hand_Pinky3      = 18
}

const oqqlefthandthumbsuppose = [ Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), 
	Quat(0.321311, 0.450518, -0.055395, 0.831098), Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042), Quat(0.085132, 0.074532, -0.185419, 0.976124), 
	Quat(0.010016, -0.068604, 0.563012, 0.823536), Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
	Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854), Quat(-0.092244, 0.02486, 0.57957, 0.809304), 
	Quat(-0.10324, -0.040148, 0.705716, 0.699782), Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
	Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111), Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]

func setrelpose(oqhandskeleton, bonename, quat):
	var i = oqhandskeleton.find_bone(bonename)
	assert (i != -1)
	var t = oqhandskeleton.get_bone_rest(i)
	var tq = t.basis.inverse()*Basis(quat)
	oqhandskeleton.set_bone_pose(i, Transform(tq, Vector3(0,0,0)))

func setoqhandfingerpose(oqhandskeleton, oqqhandpose, boneprefix, names, idxs):
	assert (len(names) == len(idxs))
	for i in range(len(idxs)):
		setrelpose(oqhandskeleton, boneprefix+names[i], oqqhandpose[idxs[i]])
#setoqhandpose

func oqsetrelpose(oqhandskeleton, oqqhandpose, boneprefix):
	oqhandskeleton.set_bone_rest(0, Transform(Basis(), Vector3(0,0,0)))
	setoqhandfingerpose(oqhandskeleton, oqqhandpose, boneprefix, ["thumb_0", "thumb_1", "thumb_2", "thumb_3"], [OVRSkeleton.Hand_Thumb0, OVRSkeleton.Hand_Thumb1, OVRSkeleton.Hand_Thumb2, OVRSkeleton.Hand_Thumb3])
	setoqhandfingerpose(oqhandskeleton, oqqhandpose, boneprefix, ["index_1", "index_2", "index_3"], [OVRSkeleton.Hand_Index1, OVRSkeleton.Hand_Index2, OVRSkeleton.Hand_Index3])
	setoqhandfingerpose(oqhandskeleton, oqqhandpose, boneprefix, ["middle_1", "middle_2", "middle_3"], [OVRSkeleton.Hand_Middle1, OVRSkeleton.Hand_Middle2, OVRSkeleton.Hand_Middle3])
	setoqhandfingerpose(oqhandskeleton, oqqhandpose, boneprefix, ["ring_1", "ring_2", "ring_3"], [OVRSkeleton.Hand_Ring1, OVRSkeleton.Hand_Ring2, OVRSkeleton.Hand_Ring3])
	setoqhandfingerpose(oqhandskeleton, oqqhandpose, boneprefix, ["pinky_0", "pinky_1", "pinky_2", "pinky_3"], [OVRSkeleton.Hand_Pinky0, OVRSkeleton.Hand_Pinky1, OVRSkeleton.Hand_Pinky2, OVRSkeleton.Hand_Pinky3])

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
	$smarker.transform.origin = ovrkl["index_null"] + sorigin

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

func getOQskelrestpose(oqhandskeleton):
	var oqrestpose = { }
	for i in range(oqhandskeleton.get_bone_count()):
		var ambidextrousbonename = oqhandskeleton.get_bone_name(i).substr(4)
		oqrestpose[ambidextrousbonename] = oqhandskeleton.get_bone_rest(i)
	return oqrestpose

func makefingerrest(a, handname, fingername):
	var fingerrest = { 
		"i1":a.find_bone(handname+"_"+fingername+"_1"), 
		"i2":a.find_bone(handname+"_"+fingername+"_2"), 
		"i3":a.find_bone(handname+"_"+fingername+"_3") 
	}
	fingerrest["b1rest"] = a.get_bone_rest(fingerrest["i1"])
	fingerrest["b2rest"] = a.get_bone_rest(fingerrest["i2"])
	fingerrest["b3rest"] = a.get_bone_rest(fingerrest["i3"])
	return fingerrest

func getAvatarhandskelrestpose(avatarskeleton, handname):
	return { 
		"thumbrest":makefingerrest(avatarskeleton, handname, "thumb"), 
		"indexrest":makefingerrest(avatarskeleton, handname, "index"),
		"middlerest":makefingerrest(avatarskeleton, handname, "middle"),
		"ringrest":makefingerrest(avatarskeleton, handname, "ring"),
		"pinkyrest":makefingerrest(avatarskeleton, handname, "pinky")
	}


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

func getoqqresthandposefinger(oqqresthandpose, oqrestpose, names, idxs):
	assert (len(idxs) == len(names))
	for i in range(len(idxs)):
		oqqresthandpose[idxs[i]] = Quat(oqrestpose[names[i]].basis)
	
func getoqqresthandpose(oqrestpose):
	var oqqresthandpose = [ ]
	for i in range(19):
		oqqresthandpose.append(Quat())
	getoqqresthandposefinger(oqqresthandpose, oqrestpose, ["thumb_0", "thumb_1", "thumb_2", "thumb_3"], [OVRSkeleton.Hand_Thumb0, OVRSkeleton.Hand_Thumb1, OVRSkeleton.Hand_Thumb2, OVRSkeleton.Hand_Thumb3])
	getoqqresthandposefinger(oqqresthandpose, oqrestpose, ["index_1", "index_2", "index_3"], [OVRSkeleton.Hand_Index1, OVRSkeleton.Hand_Index2, OVRSkeleton.Hand_Index3])
	getoqqresthandposefinger(oqqresthandpose, oqrestpose, ["middle_1", "middle_2", "middle_3"], [OVRSkeleton.Hand_Middle1, OVRSkeleton.Hand_Middle2, OVRSkeleton.Hand_Middle3])
	getoqqresthandposefinger(oqqresthandpose, oqrestpose, ["ring_1", "ring_2", "ring_3"], [OVRSkeleton.Hand_Ring1, OVRSkeleton.Hand_Ring2, OVRSkeleton.Hand_Ring3])
	getoqqresthandposefinger(oqqresthandpose, oqrestpose, ["pinky_0", "pinky_1", "pinky_2", "pinky_3"], [OVRSkeleton.Hand_Pinky0, OVRSkeleton.Hand_Pinky1, OVRSkeleton.Hand_Pinky2, OVRSkeleton.Hand_Pinky3])
	return oqqresthandpose
	
var oqleftrestpose
var oqrightrestpose
var oqleftskeletontransform
var oqrightskeletontransform

var avatarlefthandrestpose
var avatarrighthandrestpose

func recordresthandposes(avatarnode):
	var oqlefthandmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Left.gltf"
	var oqrighthandmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Right.gltf"
	var oqlefthandmodelI = load(oqlefthandmodel).instance()
	var oqrighthandmodelI = load(oqrighthandmodel).instance()
	oqleftrestpose = getOQskelrestpose(oqlefthandmodelI.get_node("ArmatureLeft/Skeleton"))
	oqrightrestpose = getOQskelrestpose(oqrighthandmodelI.get_node("ArmatureRight/Skeleton"))
	oqleftskeletontransform = oqlefthandmodelI.get_node("ArmatureLeft").transform*oqlefthandmodelI.get_node("ArmatureLeft/Skeleton").transform
	oqrightskeletontransform = oqrighthandmodelI.get_node("ArmatureRight").transform*oqrighthandmodelI.get_node("ArmatureRight/Skeleton").transform

	var avatarskeleton = avatarnode.get_node("AvatarRoot/Skeleton")
	avatarlefthandrestpose = getAvatarhandskelrestpose(avatarskeleton, "left_hand")
	avatarrighthandrestpose = getAvatarhandskelrestpose(avatarskeleton, "right_hand")

func basisfromtwovectorplane(a, b):
	var fz = a.cross(b).normalized()
	var fx = fz.cross(a + b).normalized()
	var fy = fz.cross(fx)
	return Basis(fx, fy, fz)

func _ready():
	recordresthandposes(avatarnode)
	
	# transforms and poses read from the vrapi
	var oqcontrollerlefttransform = $OculusQuestHand_Left.global_transform
	var oqcontrollerrighttransform = $OculusQuestHand_Right.global_transform
	var hand_scale = 1.0
	var oqqlefthandpose = oqqlefthandthumbsuppose  #getoqqresthandpose(oqleftrestpose)
	var oqqrighthandpose = getoqqresthandpose(oqrightrestpose)
	
	# optionally we can set the positions of the poses to the OQ hands  
	$OculusQuestHand_Left.global_transform = oqcontrollerlefttransform
	$OculusQuestHand_Right.global_transform = oqcontrollerrighttransform
	oqsetrelpose(oqlefthandskeleton, oqqlefthandpose, "b_l_")
	oqsetrelpose(oqrighthandskeleton, oqqrighthandpose, "b_r_")

	# calculate the knuckle locations offset relative to the controller positions (without reference to the OQ skeleton)
	var oqleftskeletonglobaltransform = (oqcontrollerlefttransform*oqleftskeletontransform).scaled(Vector3(hand_scale, hand_scale, hand_scale))
	var oqrightskeletonglobaltransform = (oqcontrollerrighttransform*oqrightskeletontransform).scaled(Vector3(hand_scale, hand_scale, hand_scale))
	var oqleftknuckelocations = oqcalcknucklelocations(oqleftskeletonglobaltransform.basis, oqleftrestpose, oqqlefthandpose)
	var oqrightknuckelocations = oqcalcknucklelocations(oqrightskeletonglobaltransform.basis, oqrightrestpose, oqqrighthandpose)
	
	$smarker.transform.origin = oqleftknuckelocations["pinky_null"] + oqleftskeletonglobaltransform.origin


	var avatarskeleton = avatarnode.get_node("AvatarRoot/Skeleton")

	var blefthand = avatarskeleton.find_bone("left_hand")
	var avatarleftwristrest = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(blefthand)*avatarskeleton.get_bone_pose(blefthand).inverse()
	var v1 = basisfromtwovectorplane(avatarlefthandrestpose["indexrest"]["b1rest"].origin, avatarlefthandrestpose["pinkyrest"]["b1rest"].origin)
	var v2 = basisfromtwovectorplane(oqleftknuckelocations["index_1"], oqleftknuckelocations["pinky_1"])
	var leftwristdestiny = Transform(v2*v1.inverse(), oqcontrollerlefttransform.origin)
	avatarskeleton.set_bone_pose(blefthand, avatarleftwristrest.inverse()*leftwristdestiny)
	print(avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(blefthand))
	print(leftwristdestiny)
	rpmsetrelpose(avatarskeleton, oqleftknuckelocations, "left_hand", oqleftskeletonglobaltransform.origin)

	var brighthand = avatarskeleton.find_bone("right_hand")
	var avatarrightwristrest = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(brighthand)*avatarskeleton.get_bone_pose(brighthand).inverse()
	var vv1 = basisfromtwovectorplane(avatarrighthandrestpose["indexrest"]["b1rest"].origin, avatarrighthandrestpose["pinkyrest"]["b1rest"].origin)
	var vv2 = basisfromtwovectorplane(oqrightknuckelocations["index_1"], oqrightknuckelocations["pinky_1"])
	var rightwristdestiny = Transform(vv2*vv1.inverse(), oqcontrollerrighttransform.origin)
	avatarskeleton.set_bone_pose(brighthand, avatarrightwristrest.inverse()*rightwristdestiny)
	rpmsetrelpose(avatarskeleton, oqrightknuckelocations, "right_hand", oqrightskeletonglobaltransform.origin)


#func _physics_process(delta):
#	var cursorx = (-1 if Input.is_action_pressed("ui_left") else 0) + (1 if Input.is_action_pressed("ui_right") else 0)
#	var cursory = (-1 if Input.is_action_pressed("ui_down") else 0) + (1 if Input.is_action_pressed("ui_up") else 0)
#	if cursorx != 0 or cursory != 0:
#		var bindex_1 = a.find_bone("left_hand_index_2")
#		var t = a.get_bone_pose(bindex_1)
#		t.origin.x += cursorx*0.001
#		t.origin.y += cursory*0.001
#		a.set_bone_pose(bindex_1, t)
	
	#elif event is InputEventKey:
	#	if event.scancode == KEY_M:
