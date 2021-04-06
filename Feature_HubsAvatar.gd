extends Spatial

var oqlefthandcontroller
var oqrighthandcontroller

# The base avatar can be found here: https://github.com/MozillaReality/hubs-avatar-pipelines/tree/master/Blender/AvatarBot
# Compatible with the readyplayer.me half-body avatars
var avatarnode
var avatarskeleton

onready var oqleftrestpose = $OQ_Handmodel_Constants.oq_lefthand_restpose
onready var oqrightrestpose = $OQ_Handmodel_Constants.oq_righthand_restpose
onready var oqleftskeletontransform = $OQ_Handmodel_Constants.oq_lefthand_skeletontransform
onready var oqrightskeletontransform = $OQ_Handmodel_Constants.oq_righthand_skeletontransform

var avatarlefthandrestpose
var avatarrighthandrestpose
var avatarheadrestpose

func _ready():

	oqlefthandcontroller = vr.leftController
	#oqlefthandskeleton = vr.leftController._hand_model.get_node("OculusQuestHand_Left/ArmatureLeft/Skeleton")
	oqrighthandcontroller = vr.rightController
	#oqrighthandskeleton = vr.rightController._hand_model.get_node("OculusQuestHand_Right/ArmatureRight/Skeleton")

	var avatarroot = find_node("AvatarRoot")
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

var Dstoredpose = { }
func Drpmstorehandposerest(avatarskeleton, handname):
	for finger in ["thumb", "index", "middle", "ring", "pinky" ]:
		for n in ["1", "2", "3"]:
			var bonename = handname+"_"+finger+"_"+n
			var i = avatarskeleton.find_bone(bonename)
			assert (i != -1)
			assert (not is_nan(avatarskeleton.get_bone_pose(i).basis.x.x))
			Dstoredpose[bonename] = avatarskeleton.get_bone_pose(i)

func Drpmretrievehandposerest(avatarskeleton, handname):
	for finger in ["thumb", "index", "middle", "ring", "pinky" ]:
		for n in ["1", "2", "3"]:
			var bonename = handname+"_"+finger+"_"+n
			var i = avatarskeleton.find_bone(bonename)
			assert (i != -1)
			if bonename in Dstoredpose:
				avatarskeleton.set_bone_pose(i, Dstoredpose[bonename])


func basisfromtwovectorplane(a, b):
	var fz = a.cross(b).normalized()
	var fx = fz.cross(a + b).normalized()
	var fy = fz.cross(fx)
	return Basis(fx, fy, fz)

func rpmsetwristhandpose(wristtrans, oqrestpose, oqqhandpose, avatarhandrestpose, controllerorigin, avatarwristrest, avatarskeleton, bonehand, handname):
	var oqknuckelocations = oqcalcknucklelocations(wristtrans.basis, oqrestpose, oqqhandpose)
	var v1 = basisfromtwovectorplane(avatarhandrestpose["indexrest"]["b1rest"].origin, avatarhandrestpose["pinkyrest"]["b1rest"].origin)
	var v2 = basisfromtwovectorplane(oqknuckelocations["index_1"], oqknuckelocations["pinky_1"])
	var wristdestiny = Transform(v2*v1.inverse(), controllerorigin)
	avatarskeleton.set_bone_pose(bonehand, avatarwristrest.inverse()*wristdestiny)
	rpmsetrelpose(avatarskeleton, oqknuckelocations, handname, wristtrans.origin)

const lefthandgrippose = [ Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0.481135, 0.362292, 0.0918141, 0.792984 ), Quat( 0.261836, -0.0174307, 0.114429, 0.958146 ), Quat( -0.0821178, -0.0532191, 0.188751, 0.977138 ), Quat( 0.0769265, 0.0447865, 0.177054, 0.980168 ), Quat( 0.0123445, -0.100205, 0.315544, 0.943524 ), Quat( -0.0262213, 0.00067591, 0.292588, 0.955879 ), Quat( -0.0166503, -0.025287, 0.0437345, 0.998584 ), Quat( -0.0432909, -0.0737373, 0.475973, 0.875294 ), Quat( -0.012525, 0.00478883, 0.701965, 0.712085 ), Quat( -0.0872469, 0.021686, 0.50748, 0.856961 ), Quat( -0.109041, -0.0885534, 0.542539, 0.828203 ), Quat( -0.0408939, 0.0236673, 0.76361, 0.643947 ), Quat( -0.02363, 0.0285974, 0.413419, 0.909785 ), Quat( -0.207036, -0.140343, 0.0183118, 0.968042 ), Quat( 0.0626236, -0.0343012, 0.503477, 0.861053 ), Quat( -0.0922863, 0.0033893, 0.773326, 0.627247 ), Quat( 0.00225568, 0.0431241, 0.467484, 0.882946 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ) ]
const test_pose_left_ThumbsUp = [Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), Quat(0.321311, 0.450518, -0.055395, 0.831098),
Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042),
Quat(0.085132, 0.074532, -0.185419, 0.976124), Quat(0.010016, -0.068604, 0.563012, 0.823536),
Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854),
Quat(-0.092244, 0.02486, 0.57957, 0.809304), Quat(-0.10324, -0.040148, 0.705716, 0.699782),
Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111),
Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]
# tt Transform( 0.926005, -0.0242465, -0.376732, 0.000282953, -0.99789, 0.0649197, -0.377511, -0.0602226, -0.924044, 1.20563, 0.75668, 0.00409779 )Transform( 0.865736, 0.234283, 0.442281, -0.170236, -0.693153, 0.700399, 0.47066, -0.681653, -0.560204, 1.28151, 0.503296, 0.0612732 )


var n = 0
var neckrot = 0

var lefthandorientations
var lefthandtransform
var righthandorientations
#var righthandtransform

func _process(delta):
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
	
	var bonelefthand = avatarskeleton.find_bone("left_hand")
	# prefer to avoid next line and subsequently use *avatarskeleton.get_bone_pose(blefthand).inverse(), but doesn't work
	avatarskeleton.set_bone_pose(bonelefthand, Transform())
	var avatarleftwristrest = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(bonelefthand) 
	
	if vr.leftController.is_hand:
		if vr.leftController._hand_model.tracking_confidence == 1.0:
			lefthandorientations = vr.leftController._hand_model._vrapi_bone_orientations.duplicate()
			lefthandtransform = vr.leftController.transform
			Drpmstorehandposerest(avatarskeleton, "left_hand")
		
		vr.leftController.visible = true
		var oqleftskeletonglobaltransform = vr.leftController.global_transform*oqleftskeletontransform.scaled(vr.leftController._hand_model.model.scale)
		if vr.leftController._hand_model.tracking_confidence > 0:
			rpmsetwristhandpose(oqleftskeletonglobaltransform, oqleftrestpose, vr.leftController._hand_model._vrapi_bone_orientations, avatarlefthandrestpose, vr.leftController.global_transform.origin, avatarleftwristrest, avatarskeleton, bonelefthand, "left_hand")


	else:
		if lefthandorientations != null:
			print("lefthand: ", var2str(lefthandorientations))
			print("tt: ", var2str(vr.leftController.transform.inverse()*lefthandtransform))
			lefthandorientations = null
		var leftwristdestiny = vr.leftController.global_transform
		avatarskeleton.set_bone_pose(bonelefthand, avatarleftwristrest.inverse()*leftwristdestiny)
		vr.leftController.visible = true
		#rpmsethandposerest(avatarskeleton, "left_hand")
		if oqleftrestpose != null and oqleftskeletontransform != null:
			var oqleftskeletonglobaltransform = vr.leftController.global_transform*oqleftskeletontransform.scaled(vr.leftController._hand_model.model.scale if vr.leftController._hand_model != null else Vector3(1,1,1))
			rpmsetwristhandpose(oqleftskeletonglobaltransform, oqleftrestpose, test_pose_left_ThumbsUp, avatarlefthandrestpose, vr.leftController.global_transform.origin, avatarleftwristrest, avatarskeleton, bonelefthand, "left_hand")
			#Drpmretrievehandposerest(avatarskeleton, "left_hand")
		else:
			rpmsethandposerest(avatarskeleton, "left_hand")
		
	var bonerighthand = avatarskeleton.find_bone("right_hand")
	avatarskeleton.set_bone_pose(bonerighthand, Transform())
	var avatarrightwristrest = avatarskeleton.global_transform*avatarskeleton.get_bone_global_pose(bonerighthand)
	if vr.rightController.is_hand:
		righthandorientations = vr.leftController._hand_model._vrapi_bone_orientations.duplicate()
		vr.rightController.visible = false
		var oqrightskeletonglobaltransform = vr.rightController.global_transform*oqrightskeletontransform.scaled(vr.rightController._hand_model.model.scale)

		#var hand_scale = vr.rightController._hand_model.model.scale
		#var oqrightknuckelocations = oqcalcknucklelocations(oqrightskeletonglobaltransform.basis, oqrightrestpose, vr.rightController._hand_model._vrapi_bone_orientations)

		#var v1 = basisfromtwovectorplane(avatarrighthandrestpose["indexrest"]["b1rest"].origin, avatarrighthandrestpose["pinkyrest"]["b1rest"].origin)
		#var v2 = basisfromtwovectorplane(oqrightknuckelocations["index_1"], oqrightknuckelocations["pinky_1"])
		#var rightwristdestiny = Transform(v2*v1.inverse(), vr.rightController.global_transform.origin)
		#avatarskeleton.set_bone_pose(bonerighthand, avatarrightwristrest.inverse()*rightwristdestiny)
		#rpmsetrelpose(avatarskeleton, oqrightknuckelocations, "right_hand", oqrightskeletonglobaltransform.origin)
		if vr.rightController._hand_model.tracking_confidence > 0:
			rpmsetwristhandpose(oqrightskeletonglobaltransform, oqrightrestpose, vr.rightController._hand_model._vrapi_bone_orientations, avatarrighthandrestpose, vr.rightController.global_transform.origin, avatarrightwristrest, avatarskeleton, bonerighthand, "right_hand")


	else:
		if righthandorientations != null:
			#print("righthand: ", var2str(righthandorientations))
			righthandorientations = null
		var rightwristdestiny = vr.rightController.global_transform
		avatarskeleton.set_bone_pose(bonerighthand, avatarrightwristrest.inverse()*rightwristdestiny)
		vr.rightController.visible = true
		rpmsethandposerest(avatarskeleton, "right_hand")


