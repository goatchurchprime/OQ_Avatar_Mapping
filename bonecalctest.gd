extends Spatial

onready var s = $OculusQuestHand_Left/ArmatureLeft/Skeleton
onready var a = $AvatarBot_base_for_export_altbody/AvatarRoot/Skeleton

enum OVRSkeleton { # https://developer.oculus.com/documentation/unity/unity-handtracking/
	Hand_WristRoot   = 0, Hand_ForearmStub = 1, 
	Hand_Thumb0      = 2, Hand_Thumb1      = 3, Hand_Thumb2      = 4, Hand_Thumb3      = 5, # thumb distal phalange bone
						  Hand_Index1      = 6, Hand_Index2      = 7, Hand_Index3      = 8, 
						  Hand_Middle1     = 9, Hand_Middle2     = 10,Hand_Middle3     = 11,
						  Hand_Ring1       = 12,Hand_Ring2       = 13,Hand_Ring3       = 14,
	Hand_Pinky0      = 15,Hand_Pinky1      = 16,Hand_Pinky2      = 17,Hand_Pinky3      = 18
}

const qpthumbsup = [ Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), 
	Quat(0.321311, 0.450518, -0.055395, 0.831098), Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042), Quat(0.085132, 0.074532, -0.185419, 0.976124), 
	Quat(0.010016, -0.068604, 0.563012, 0.823536), Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
	Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854), Quat(-0.092244, 0.02486, 0.57957, 0.809304), 
	Quat(-0.10324, -0.040148, 0.705716, 0.699782), Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
	Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111), Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]
const qprestpose = [ Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), 
	Quat(0.375387, 0.424584, -0.00777886, 0.823864), Quat(0.26023, 0.0243309, 0.125678, 0.957023), Quat(-0.0827037, -0.0769617, -0.0840623, 0.990036), Quat(0.0835058, 0.0650157, -0.0582741, 0.992675), 
	Quat(0.0306831, -0.0188556, 0.0432814, 0.998414), Quat(-0.0258524, -0.00711605, 0.00329295, 0.999635), Quat(-0.016056, -0.0271487, -0.0720338, 0.996903), 
	Quat(-0.00906633, -0.0514656, 0.0518357, 0.997287), Quat(-0.0112282, -0.00437888, -0.00197819, 0.999925), Quat(-0.0343196, -0.00461181, -0.0930074, 0.995063), 
	Quat(-0.0531593, -0.123103, 0.0498135, 0.989716), Quat(-0.0336325, -0.00278986, 0.00567604, 0.999414), Quat(-0.00347744, 0.0291794, -0.0250285, 0.999255), 
	Quat(-0.207036, -0.140343, 0.0183118, 0.968042), Quat(0.091113, 0.00407132, 0.0281293, 0.995435), Quat(-0.0376167, -0.0429377, -0.0132862, 0.998281), Quat(0.000644803, 0.0491706, -0.024019, 0.998501)
]

func setrelpose(s, n, q):
	var i = s.find_bone(n)
	assert (i != -1)
	var t = s.get_bone_rest(i)
	var tq = t.basis.inverse()*Basis(q)
	s.set_bone_pose(i, Transform(tq, Vector3(0,0,0)))

func oqsetrelpose(s, qp):
	setrelpose(s, "b_l_thumb_0", qp[OVRSkeleton.Hand_Thumb0])
	setrelpose(s, "b_l_thumb_1", qp[OVRSkeleton.Hand_Thumb1])
	setrelpose(s, "b_l_thumb_2", qp[OVRSkeleton.Hand_Thumb2])
	setrelpose(s, "b_l_thumb_3", qp[OVRSkeleton.Hand_Thumb3])
	setrelpose(s, "b_l_index_1", qp[OVRSkeleton.Hand_Index1])
	setrelpose(s, "b_l_index_2", qp[OVRSkeleton.Hand_Index2])
	setrelpose(s, "b_l_index_3", qp[OVRSkeleton.Hand_Index3])
	setrelpose(s, "b_l_middle_1", qp[OVRSkeleton.Hand_Middle1])
	setrelpose(s, "b_l_middle_2", qp[OVRSkeleton.Hand_Middle2])
	setrelpose(s, "b_l_middle_3", qp[OVRSkeleton.Hand_Middle3])
	setrelpose(s, "b_l_ring_1", qp[OVRSkeleton.Hand_Ring1])
	setrelpose(s, "b_l_ring_2", qp[OVRSkeleton.Hand_Ring2])
	setrelpose(s, "b_l_ring_3", qp[OVRSkeleton.Hand_Ring3])
	setrelpose(s, "b_l_pinky_0", qp[OVRSkeleton.Hand_Pinky0])
	setrelpose(s, "b_l_pinky_1", qp[OVRSkeleton.Hand_Pinky1])
	setrelpose(s, "b_l_pinky_2", qp[OVRSkeleton.Hand_Pinky2])
	setrelpose(s, "b_l_pinky_3", qp[OVRSkeleton.Hand_Pinky3])


func getbonevector(s, n):
	var i = s.find_bone(n)
	return s.get_bone_rest(i).origin



var ovrbonenames = [ 
	"thumb_0",  "thumb_1", 	"thumb_2",  "thumb_3",	"thumb_null",
				"index_1", 	"index_2",  "index_3",	"index_null",
				"middle_1",	"middle_2",	"middle_3",	"middle_null",
				"ring_1",	"ring_2", 	"ring_3",	"ring_null",
	"pinky_0",	"pinky_1",	"pinky_2",	"pinky_3",	"pinky_null"
]
# without these bone vectors, the quat orientations from the api cannot be decoded
var ovrbonevectorsLeft = {  # dict((n, s.get_bone_rest(s.find_bone("b_l_"+n).origin))  for n in ovrbonenames) 
	"thumb_0":Vector3(2.00693, 1.15541, -1.049652), "thumb_1":Vector3(2.485256, 0, -0), "thumb_2":Vector3(3.251291, -0, -0), "thumb_3":Vector3(3.37931, 0.000001, 0), "thumb_null":Vector3(1.486336, -0, 0),
	"index_1":Vector3(9.599623, 0.731646, -2.355068), "index_2":Vector3(3.79273, 0, 0), "index_3":Vector3(2.430365, -0.000001, -0), "index_null":Vector3(1.158304, -0.000001, 0),
	"middle_1":Vector3(9.564662, 0.254316, -0.172591), "middle_2":Vector3(4.292699, 0.000001, 0), "middle_3":Vector3(2.754958, -0.000001, -0), "middle_null":Vector3(1.220348, 0.000001, 0),
	"ring_1":Vector3(8.869379, 0.652931, 1.746524), "ring_2":Vector3(3.899611, -0, 0), "ring_3":Vector3(2.657341, -0, -0), "ring_null":Vector3(1.193942, -0, -0),
	"pinky_0":Vector3(3.407357, 0.941984, 2.299857), "pinky_1":Vector3(4.565055, 0.000099, -0.00022), "pinky_2":Vector3(3.072041, -0, 0), "pinky_3":Vector3(2.031139, -0, 0), "pinky_null":Vector3(1.190879, 0, -0.000001),
}


func oqknucklelocations(wristtransform, qp, ovv):
	var tt
	var kl = { "wrist":wristtransform.origin }
	
	tt = wristtransform
	tt = tt*Transform(qp[OVRSkeleton.Hand_Thumb0], ovv["thumb_0"])
	kl["thumb0"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Thumb1], ovv["thumb_1"])
	kl["thumb1"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Thumb2], ovv["thumb_2"])
	kl["thumb2"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Thumb3], ovv["thumb_3"])
	kl["thumb3"] = tt.origin
	kl["thumbtip"] = tt.xform(ovv["thumb_null"])

	tt = wristtransform
	tt = tt*Transform(qp[OVRSkeleton.Hand_Index1], ovv["index_1"])
	kl["index1"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Index2], ovv["index_2"])
	kl["index2"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Index3], ovv["index_3"])
	kl["index3"] = tt.origin
	kl["indextip"] = tt.xform(ovv["index_null"])
	
	tt = wristtransform
	tt = tt*Transform(qp[OVRSkeleton.Hand_Middle1], ovv["middle_1"])
	kl["middle1"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Middle2], ovv["middle_2"])
	kl["middle2"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Middle3], ovv["middle_3"])
	kl["middle3"] = tt.origin
	kl["middletip"] = tt.xform(ovv["middle_null"])
		
	tt = wristtransform
	tt = tt*Transform(qp[OVRSkeleton.Hand_Ring1], ovv["ring_1"])
	kl["ring1"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Ring2], ovv["ring_2"])
	kl["ring2"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Ring3], ovv["ring_3"])
	kl["ring3"] = tt.origin
	kl["ringtip"] = tt.xform(ovv["middle_null"])

	tt = wristtransform
	tt = tt*Transform(qp[OVRSkeleton.Hand_Pinky0], ovv["pinky_0"])
	kl["pinky0"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Pinky1], ovv["pinky_1"])
	kl["pinky1"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Pinky2], ovv["pinky_2"])
	kl["pinky2"] = tt.origin
	tt = tt*Transform(qp[OVRSkeleton.Hand_Pinky3], ovv["pinky_3"])
	kl["pinky3"] = tt.origin
	kl["pinkytip"] = tt.xform(ovv["pinky_null"])

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
	var absknuckle1pos = ovrkl[fingername+"1"] + sorigin
	var absknuckle2pos = ovrkl[fingername+"2"] + sorigin
	var absknuckle3pos = ovrkl[fingername+"3"] + sorigin
	var absknuckletippos = ovrkl[fingername+"tip"] + sorigin

	var bone1pose = knucklealignedpose(twrist, fingerrest["b1rest"], fingerrest["b2rest"].origin, absknuckle1pos, absknuckle2pos)
	var tindex1 = twrist*fingerrest["b1rest"]*bone1pose
	var bone2pose = knucklealignedpose(tindex1, fingerrest["b2rest"], fingerrest["b3rest"].origin, absknuckle2pos, absknuckle3pos)
	var tindex2 = tindex1*fingerrest["b2rest"]*bone2pose
	var bone3pose = knucklealignedpose(tindex2, fingerrest["b3rest"], fingerrest["b3rest"].origin, absknuckle3pos, absknuckletippos)

	a.set_bone_pose(fingerrest["i1"], bone1pose)
	a.set_bone_pose(fingerrest["i2"], bone2pose)
	a.set_bone_pose(fingerrest["i3"], bone3pose)

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

func rpmsetrelpose(a, ovrkl, sorigin):
	var bwrist = a.find_bone("left_hand")
	var twrist = a.global_transform*a.get_bone_global_pose(bwrist)
	$smarker.transform.origin = ovrkl["indextip"] + sorigin

	#twrist.origin -= sorigin
	#sorigin = Vector3(0,0,0)

	var thumbrest = makefingerrest(a, "left_hand", "thumb")
	var indexrest = makefingerrest(a, "left_hand", "index")
	var middlerest = makefingerrest(a, "left_hand", "middle")
	var ringrest = makefingerrest(a, "left_hand", "ring")
	var pinkyrest = makefingerrest(a, "left_hand", "pinky")

	knucklealignedfinger(a, twrist, thumbrest, ovrkl, "thumb", sorigin)
	knucklealignedfinger(a, twrist, indexrest, ovrkl, "index", sorigin)
	knucklealignedfinger(a, twrist, middlerest, ovrkl, "middle", sorigin)
	knucklealignedfinger(a, twrist, ringrest, ovrkl, "ring", sorigin)
	knucklealignedfinger(a, twrist, pinkyrest, ovrkl, "pinky", sorigin)


func getOQskelrestpose(oqhandskeleton):
	var oqrestpose = { }
	for i in range(oqhandskeleton.get_bone_count()):
		var ambidextrousbonename = oqhandskeleton.get_bone_name(i).substr(4)
		oqrestpose[ambidextrousbonename] = oqhandskeleton.get_bone_rest(i)
	return oqrestpose

func getAvatarhandskelrestpose(avatarskeleton, handname):
	return { 
		"thumbrest":makefingerrest(avatarskeleton, handname, "thumb"), 
		"indexrest":makefingerrest(avatarskeleton, handname, "index"),
		"middlerest":makefingerrest(avatarskeleton, handname, "middle"),
		"ringrest":makefingerrest(avatarskeleton, handname, "ring"),
		"pinkyrest":makefingerrest(avatarskeleton, handname, "pinky")
	}


func oqsinglefingerknucklelocations(kl, oqrestpose, oqqhandpose, n0, n1, n2, n3, ntip, i0, i1, i2, i3):
	var t0 = Transform()
	if n0 != "":
		t0 = Transform(oqqhandpose[i0], oqrestpose[n0].origin)
		kl[n0] = t0.origin
	var t1 = t0*Transform(oqqhandpose[i1], oqrestpose[n1].origin)
	kl[n1] = t1.origin
	var t2 = t1*Transform(oqqhandpose[i2], oqrestpose[n2].origin)
	kl[n2] = t2.origin
	var t3 = t2*Transform(oqqhandpose[i3], oqrestpose[n3].origin)
	kl[n3] = t3.origin
	kl[ntip] = t3.xform(oqrestpose[ntip].origin)

func oqcalcknucklelocations(oqrestpose, oqqhandpose):
	var kl = { }
	oqsinglefingerknucklelocations(kl, oqrestpose, oqqhandpose, 
		"thumb_0", "thumb_1", "thumb_2", "thumb_3", "thumb_null",
		OVRSkeleton.Hand_Thumb0, OVRSkeleton.Hand_Thumb1, OVRSkeleton.Hand_Thumb2, OVRSkeleton.Hand_Thumb3)
	oqsinglefingerknucklelocations(kl, oqrestpose, oqqhandpose, 
		"", "index_1", "index_2", "index_3", "index_null",
		-1, OVRSkeleton.Hand_Index1, OVRSkeleton.Hand_Index2, OVRSkeleton.Hand_Index3)
	oqsinglefingerknucklelocations(kl, oqrestpose, oqqhandpose, 
		"", "middle_1", "middle_2", "middle_3", "middle_null", 
		-1, OVRSkeleton.Hand_Middle1, OVRSkeleton.Hand_Middle2, OVRSkeleton.Hand_Middle3)
	oqsinglefingerknucklelocations(kl, oqrestpose, oqqhandpose, 
		"", "ring_1", "ring_2", "ring_3", "ring_null",
		-1, OVRSkeleton.Hand_Ring1, OVRSkeleton.Hand_Ring2, OVRSkeleton.Hand_Ring3)
	oqsinglefingerknucklelocations(kl, oqrestpose, oqqhandpose, 
		"pinky_0", "pinky_1", "pinky_2", "pinky_3", "pinky_null",
		OVRSkeleton.Hand_Pinky1, OVRSkeleton.Hand_Pinky1, OVRSkeleton.Hand_Pinky2, OVRSkeleton.Hand_Pinky3)
	
func getoqqresthandpose(oqrestpose):
	# this needs to refile the quats back into the list based on the vrapi 
	var oqqresthandpose = { }
	for k in oqrestpose:
		oqqresthandpose[k] = Quat(oqrestpose[k].basis)
	return oqqresthandpose


func _ready():
	# constant geometric information
	var oqlefthmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Left.gltf"
	var oqrrighthmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Right.gltf"
	var oqleftrestpose = getOQskelrestpose(load(oqlefthmodel).instance().get_node("ArmatureLeft/Skeleton"))
	var oqrightrestpose = getOQskelrestpose(load(oqrrighthmodel).instance().get_node("ArmatureRight/Skeleton"))
	
	var avatarlefthandrestpose = getAvatarhandskelrestpose(a, "left_hand")
	var avatarrighthandrestpose = getAvatarhandskelrestpose(a, "right_hand")

	# pose settings (to be pulled from the vrapi)
	var oqqlefthandpose = qpthumbsup
	var oqqrighthandpose = qpthumbsup# getoqqresthandpose(oqrightrestpose)

	# calculating the knuckles in space relative to the wrists
	var oqleftknuckelocations = oqcalcknucklelocations(oqleftrestpose, oqqlefthandpose)
	var oqrightknuckelocations = oqcalcknucklelocations(oqrightrestpose, oqqrighthandpose)
		
	#var qp = qprestpose
	var qp = qpthumbsup
	s.set_bone_rest(0, Transform(Basis(), Vector3(0,0,0)))
	oqsetrelpose(s, qp)
	
	var qwristtransform = s.global_transform
	var ovrkl = oqknucklelocations(Transform(s.global_transform.basis, Vector3(0,0,0)), qp, ovrbonevectorsLeft)
	$smarker.transform.origin = ovrkl["pinkytip"] + s.global_transform.origin

	var ilh = a.find_bone("left_hand")
	var t = a.global_transform*a.get_bone_global_pose(ilh)
	var atoqtrans = Basis(Vector3(1,0,0), deg2rad(-90)).rotated(Vector3(0,1,0), deg2rad(-90))
	var tq = t.inverse()*Transform(qwristtransform.basis.orthonormalized()*atoqtrans, qwristtransform.origin)
	a.set_bone_pose(ilh, tq)

	var awristtransform = a.global_transform*a.get_bone_global_pose(a.find_bone("left_hand"))
	var awristtransformZ = Transform(awristtransform.basis, Vector3(0,0,0))
	rpmsetrelpose(a, ovrkl, s.global_transform.origin)



func _physics_process(delta):
	var cursorx = (-1 if Input.is_action_pressed("ui_left") else 0) + (1 if Input.is_action_pressed("ui_right") else 0)
	var cursory = (-1 if Input.is_action_pressed("ui_down") else 0) + (1 if Input.is_action_pressed("ui_up") else 0)
	if cursorx != 0 or cursory != 0:
		var bindex_1 = a.find_bone("left_hand_index_2")
		var t = a.get_bone_pose(bindex_1)
		t.origin.x += cursorx*0.001
		t.origin.y += cursory*0.001
		a.set_bone_pose(bindex_1, t)
	
	#elif event is InputEventKey:
	#	if event.scancode == KEY_M:
