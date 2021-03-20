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
	

var rpmbonenames = [ 
	"thumb_1", 	"thumb_2",  "thumb_3",
	"index_1", 	"index_2",  "index_3",
	"middle_1",	"middle_2",	"middle_3",
	"ring_1",	"ring_2", 	"ring_3",
	"pinky_1",	"pinky_2",	"pinky_3"
]
# without these bone vectors, the quat orientations from the api cannot be decoded
var rpmbonevectorsLeft = { # dict((n, a.get_bone_rest(s.find_bone("left_hand_"+n).origin))  for n in rpmbonenames) 
	"thumb_1":Vector3(-0.029541, 0.018715, -0), "thumb_2":Vector3(0, 0.034613, -0), "thumb_3":Vector3(0, 0.026784, -0), "thumb_tip":Vector3(0, 0.02, -0),
	"index_1":Vector3(-0.030061, 0.082512, 0.000042), "index_2":Vector3(-0, 0.033596, -0), "index_3":Vector3(0, 0.025763, -0), "index_tip":Vector3(0, 0.02, 0), 
	"middle_1":Vector3(-0.008664, 0.088486, -0), "middle_2":Vector3(0, 0.034021, -0), "middle_3":Vector3(-0, 0.026764, 0), "middle_tip":Vector3(0, 0.02, 0), 
	"ring_1":Vector3(0.00893, 0.085625, 0), "ring_2":Vector3(-0, 0.029214, -0), "ring_3":Vector3(-0, 0.02711, -0), "pinky_tip":Vector3(0, 0.02, 0),
	"pinky_1":Vector3(0.027168, 0.076698, 0), "pinky_2":Vector3(-0, 0.033349, 0), "pinky_3":Vector3(-0, 0.019546, 0), "ring_tip":Vector3(0, 0.013, 0), 
}
var rpmbonequatsrestLeft = {
	"thumb_1":Quat(-0.103249, 0.283311, 0.326471, 0.895819), "thumb_2":Quat(0.243438, 0.029522, -0.011856, 0.969395), "thumb_3":Quat(0.128924, -0.001055, 0.003452, 0.991648),
	"index_1":Quat(0.129554, 0.009594, 0.067984, 0.989193), "index_2":Quat(0.131135, 0.00038, 0.008156, 0.991331), "index_3":Quat(0.130525, 0.000547, 0.004155, 0.991436), 
	"middle_1":Quat(0.130524, 0.000699, 0.005309, 0.991431), "middle_2":Quat(0.130525, -0.000424, -0.003217, 0.99144), "middle_3":Quat(0.130525, 0.000486, 0.003691, 0.991438), 
	"ring_1":Quat(0.130432, -0.004964, -0.037708, 0.990727), "ring_2":Quat(0.130524, 0.000777, 0.005902, 0.991427), "ring_3":Quat(0.130526, -0.000203, -0.001541, 0.991444), 
	"pinky_1":Quat(0.129679, -0.014849, -0.11279, 0.985008), "pinky_2":Quat(0.130521, 0.001213, 0.009213, 0.991402), "pinky_3":Quat(0.130523, -0.000945, -0.007175, 0.991419), 
}


func rpmknucklelocations(wristtransform, qp, ovv):
	var tt
	var kl = { "wrist":wristtransform.origin }

	tt = wristtransform
	tt = tt*Transform(qp["thumb_1"], ovv["thumb_1"])
	kl["thumb1"] = tt.origin
	tt = tt*Transform(qp["thumb_2"], ovv["thumb_2"])
	kl["thumb2"] = tt.origin
	tt = tt*Transform(qp["thumb_3"], ovv["thumb_3"])
	kl["thumb3"] = tt.origin
	kl["thumbtip"] = tt.xform(ovv["thumb_tip"])
	
	tt = wristtransform
	tt = tt*Transform(qp["index_1"], ovv["index_1"])
	kl["index1"] = tt.origin
	tt = tt*Transform(qp["index_2"], ovv["index_2"])
	kl["index2"] = tt.origin
	tt = tt*Transform(qp["index_3"], ovv["index_3"])
	kl["index3"] = tt.origin
	kl["indextip"] = tt.xform(ovv["index_tip"])
	
	tt = wristtransform
	tt = tt*Transform(qp["middle_1"], ovv["middle_1"])
	kl["middle1"] = tt.origin
	tt = tt*Transform(qp["middle_2"], ovv["middle_2"])
	kl["middle2"] = tt.origin
	tt = tt*Transform(qp["middle_3"], ovv["middle_3"])
	kl["middle3"] = tt.origin
	kl["middletip"] = tt.xform(ovv["middle_tip"])

	tt = wristtransform
	tt = tt*Transform(qp["ring_1"], ovv["ring_1"])
	kl["ring1"] = tt.origin
	tt = tt*Transform(qp["ring_2"], ovv["ring_2"])
	kl["ring2"] = tt.origin
	tt = tt*Transform(qp["ring_3"], ovv["ring_3"])
	kl["ring3"] = tt.origin
	kl["ringtip"] = tt.xform(ovv["ring_tip"])

	tt = wristtransform
	tt = tt*Transform(qp["pinky_1"], ovv["pinky_1"])
	kl["pinky1"] = tt.origin
	tt = tt*Transform(qp["pinky_2"], ovv["pinky_2"])
	kl["pinky2"] = tt.origin
	tt = tt*Transform(qp["pinky_3"], ovv["pinky_3"])
	kl["pinky3"] = tt.origin
	kl["pinkytip"] = tt.xform(ovv["pinky_tip"])

	return kl

	
func _ready():
	var v = { }
	var r = { }
	for x in rpmbonenames:
		v[x] = a.get_bone_rest(a.find_bone("left_hand_"+x)).origin
		r[x] = Quat(a.get_bone_rest(a.find_bone("left_hand_"+x)).basis)

	var qp = qprestpose # qpthumbsup
	s.set_bone_rest(0, Transform(Basis(), Vector3(0,0,0)))
	oqsetrelpose(s, qp)
	var qwristtransform = s.global_transform
	var ovrkl = oqknucklelocations(Transform(s.global_transform.basis, Vector3(0,0,0)), qp, ovrbonevectorsLeft)
	$smarker.transform.origin = ovrkl["pinkytip"] + s.global_transform.origin

	var i = a.find_bone("left_hand")
	var t = a.global_transform*a.get_bone_global_pose(i)
	var atoqtrans = Basis(Vector3(1,0,0), deg2rad(-90)).rotated(Vector3(0,1,0), deg2rad(-90))
	var tq = t.inverse()*Transform(qwristtransform.basis.orthonormalized()*atoqtrans, qwristtransform.origin)
	a.set_bone_pose(i, tq)

	var awristtransform = a.global_transform*a.get_bone_global_pose(a.find_bone("left_hand"))
	var rpmkl = rpmknucklelocations(Transform(awristtransform.basis, Vector3(0,0,0)), rpmbonequatsrestLeft, rpmbonevectorsLeft)
	$smarker.transform.origin = rpmkl["pinkytip"] + awristtransform.origin

	# what rotation will take 
	for k in [ovrkl, rpmkl]:
		var vv = { }
		for ss in k:
			vv[ss] = k[ss].length()
		print(vv)
	#print(ovrkl)
	#print(rpmkl)
