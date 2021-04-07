extends Node

enum OVRSkeleton { # https://developer.oculus.com/documentation/unity/unity-handtracking/
	Hand_WristRoot   = 0, Hand_ForearmStub = 1, 
	Hand_Thumb0      = 2, Hand_Thumb1      = 3, Hand_Thumb2      = 4, Hand_Thumb3      = 5, # thumb distal phalange bone
						  Hand_Index1      = 6, Hand_Index2      = 7, Hand_Index3      = 8, 
						  Hand_Middle1     = 9, Hand_Middle2     = 10,Hand_Middle3     = 11,
						  Hand_Ring1       = 12,Hand_Ring2       = 13,Hand_Ring3       = 14,
	Hand_Pinky0      = 15,Hand_Pinky1      = 16,Hand_Pinky2      = 17,Hand_Pinky3      = 18
}

var oq_lefthand_restpose = str2var("""{
	"forearm_stub": Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 ),
	"index_1": Transform( 0.995542, -0.0875827, -0.0349953, 0.0852684, 0.994371, -0.062901, 0.0403074, 0.0596366, 0.997406, 9.59962, 0.731646, -2.35507 ),
	"index_2": Transform( 0.999877, -0.00621557, -0.0143972, 0.00695144, 0.998641, 0.0516391, 0.0140566, -0.0517328, 0.998562, 3.79273, 2.06186e-07, 2.63352e-07 ),
	"index_3": Transform( 0.988148, 0.144493, -0.0518162, -0.14275, 0.989107, 0.0359237, 0.0564425, -0.0281012, 0.99801, 2.43037, -8.7442e-07, -1.28656e-07 ),
	"index_null": Transform( 1, -8.73115e-10, 7.6252e-09, 8.73115e-10, 1, -1.16415e-09, -7.6252e-09, 1.16415e-09, 1, 1.1583, -5.55068e-07, 6.14673e-08 ),
	"middle_1": Transform( 0.989329, -0.102457, -0.103592, 0.104323, 0.994462, 0.012748, 0.101712, -0.023419, 0.994538, 9.56466, 0.254316, -0.172591 ),
	"middle_2": Transform( 0.999954, 0.00405442, -0.00871268, -0.00385775, 0.99974, 0.0224721, 0.00880152, -0.0224375, 0.99971, 4.2927, 5.31597e-07, 1.6967e-07 ),
	"middle_3": Transform( 0.982656, 0.185413, -0.00279413, -0.18478, 0.980344, 0.0691582, 0.015562, -0.0674424, 0.997602, 2.75496, -6.38197e-07, -6.37868e-08 ),
	"middle_null": Transform( 1, -9.82545e-08, 9.3132e-10, 9.82545e-08, 1, 4.61005e-08, -9.31325e-10, -4.61005e-08, 1, 1.22035, 1.43796e-06, 3.05474e-07 ),
	"pinky_0": Transform( 0.959937, 0.0226589, -0.279298, 0.0935652, 0.913602, 0.395699, 0.264133, -0.405979, 0.87488, 3.40736, 0.941984, 2.29986 ),
	"pinky_1": Transform( 0.998384, -0.0552599, 0.0132314, 0.0567437, 0.981814, -0.181165, -0.00297957, 0.181623, 0.983363, 4.56506, 9.93073e-05, -0.000219761 ),
	"pinky_2": Transform( 0.995959, 0.029757, -0.0847283, -0.0232963, 0.996817, 0.076245, 0.0867273, -0.0739631, 0.993483, 3.07204, -4.78177e-07, 3.31105e-07 ),
	"pinky_3": Transform( 0.994011, 0.0480293, 0.0981629, -0.0479026, 0.998845, -0.00364973, -0.0982249, -0.00107438, 0.995163, 2.03114, -3.04639e-07, 3.83157e-07 ),
	"pinky_null": Transform( 1, -1.03377e-07, 2.14204e-08, 1.03377e-07, 1, 3.31318e-07, -2.14204e-08, -3.31318e-07, 1, 1.19088, 2.68221e-07, -1.13249e-06 ),
	"ring_1": Transform( 0.964728, -0.0855142, -0.248971, 0.111691, 0.989385, 0.0929609, 0.238379, -0.11749, 0.964039, 8.86938, 0.652931, 1.74652 ),
	"ring_2": Transform( 0.999921, -0.0111578, -0.00595825, 0.0115331, 0.997674, 0.0671939, 0.00519466, -0.0672573, 0.997722, 3.89961, -4.18822e-07, 4.70964e-07 ),
	"ring_3": Transform( 0.997043, 0.0498168, 0.0584895, -0.0502227, 0.998722, 0.00548906, -0.0581413, -0.00841032, 0.998274, 2.65734, -4.13393e-07, -3.47252e-07 ),
	"ring_null": Transform( 1, -9.59262e-08, 1.16415e-08, 9.59262e-08, 1, -5.40167e-08, -1.16415e-08, 5.40167e-08, 1, 1.19394, -1.49012e-07, -1.19209e-07 ),
	"thumb_0": Transform( 0.639336, 0.331584, 0.693759, 0.305949, 0.718048, -0.625142, -0.70544, 0.61193, 0.357626, 2.00693, 1.15541, -1.04965 ),
	"thumb_1": Transform( 0.967226, -0.22789, 0.111981, 0.253217, 0.832971, -0.491977, 0.01884, 0.504209, 0.863376, 2.48526, 2.56281e-07, -2.74327e-07 ),
	"thumb_2": Transform( 0.974021, 0.179179, -0.138485, -0.153719, 0.972187, 0.176698, 0.166294, -0.15082, 0.974474, 3.25129, -4.77677e-07, -1.01843e-07 ),
	"thumb_3": Transform( 0.984754, 0.126553, 0.119347, -0.104836, 0.979262, -0.173366, -0.138811, 0.158211, 0.9776, 3.37931, 1.05558e-06, 2.24569e-07 ),
	"thumb_null": Transform( 1, 1.05471e-15, 5.96046e-08, -7.21645e-16, 1, -5.58794e-09, -5.96046e-08, 5.58794e-09, 1, 1.48634, -1.19209e-07, 2.98023e-07 ),
	"wrist": Transform( 1, 0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0 )
}""")

var oq_righthand_restpose = str2var("""{
	"forearm_stub": Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 ),
	"index_1": Transform( 0.995542, -0.0875827, -0.0349953, 0.0852684, 0.994371, -0.062901, 0.0403073, 0.0596367, 0.997406, -9.59962, -0.731646, 2.35507 ),
	"index_2": Transform( 0.999877, -0.00621576, -0.0143972, 0.00695163, 0.998641, 0.0516391, 0.0140567, -0.0517328, 0.998562, -3.79273, 3.60057e-07, -3.6766e-07 ),
	"index_3": Transform( 0.988148, 0.144493, -0.0518162, -0.14275, 0.989107, 0.0359238, 0.0564425, -0.0281013, 0.99801, -2.43037, 5.20517e-07, 9.88539e-08 ),
	"index_null": Transform( 1, -1.10595e-09, 1.08557e-08, 1.10595e-09, 1, 1.32713e-08, -1.08557e-08, -1.32713e-08, 1, -1.1583, 4.54485e-07, 7.45058e-08 ),
	"middle_1": Transform( 0.989329, -0.102457, -0.103592, 0.104323, 0.994462, 0.012748, 0.101712, -0.023419, 0.994538, -9.56466, -0.254316, 0.172591 ),
	"middle_2": Transform( 0.999954, 0.00405477, -0.00871269, -0.0038581, 0.99974, 0.0224721, 0.00880154, -0.0224375, 0.99971, -4.2927, -5.32528e-07, -1.66876e-07 ),
	"middle_3": Transform( 0.982656, 0.185413, -0.00279414, -0.18478, 0.980344, 0.0691582, 0.015562, -0.0674425, 0.997602, -2.75496, 2.53897e-08, -1.03851e-07 ),
	"middle_null": Transform( 1, -2.79397e-09, -5.12227e-09, 2.79397e-09, 1, 1.86264e-09, 5.12228e-09, -1.86265e-09, 1, -1.22035, -1.08033e-06, -1.86265e-07 ),
	"pinky_0": Transform( 0.959937, 0.0226589, -0.279298, 0.0935652, 0.913602, 0.395699, 0.264133, -0.405979, 0.87488, -3.40736, -0.941984, -2.29986 ),
	"pinky_1": Transform( 0.998384, -0.0552596, 0.0132313, 0.0567434, 0.981814, -0.181165, -0.0029796, 0.181623, 0.983363, -4.56505, -9.93818e-05, 0.000219523 ),
	"pinky_2": Transform( 0.995959, 0.0297568, -0.0847283, -0.0232961, 0.996817, 0.0762449, 0.0867273, -0.073963, 0.993483, -3.07204, -1.47671e-07, -3.27982e-09 ),
	"pinky_3": Transform( 0.994011, 0.0480292, 0.098163, -0.0479025, 0.998845, -0.00364928, -0.098225, -0.00107482, 0.995163, -2.03114, -5.33552e-07, -2.04344e-07 ),
	"pinky_null": Transform( 1, -1.08033e-07, -9.31327e-10, 1.08033e-07, 1, 6.56582e-08, 9.3132e-10, -6.56582e-08, 1, -1.19088, -4.32134e-07, 4.76837e-07 ),
	"ring_1": Transform( 0.964728, -0.0855142, -0.248971, 0.111691, 0.989385, 0.0929609, 0.238379, -0.11749, 0.964039, -8.86938, -0.652931, -1.74652 ),
	"ring_2": Transform( 0.999921, -0.0111579, -0.00595825, 0.0115332, 0.997674, 0.0671939, 0.00519465, -0.0672573, 0.997722, -3.89961, -4.75248e-07, -1.72941e-07 ),
	"ring_3": Transform( 0.997043, 0.0498168, 0.0584895, -0.0502227, 0.998722, 0.00548903, -0.0581413, -0.0084103, 0.998274, -2.65734, 7.41219e-07, 7.94286e-07 ),
	"ring_null": Transform( 1, 4.65661e-09, -1.39698e-09, -4.65661e-09, 1, -4.47035e-08, 1.39698e-09, 4.47035e-08, 1, -1.19394, 2.98023e-07, -2.38419e-07 ),
	"thumb_0": Transform( 0.639336, 0.331584, 0.693759, 0.305949, 0.718048, -0.625141, -0.70544, 0.61193, 0.357626, -2.00693, -1.15541, 1.04965 ),
	"thumb_1": Transform( 0.967226, -0.22789, 0.111981, 0.253217, 0.832971, -0.491977, 0.0188399, 0.504209, 0.863376, -2.48526, -2.56281e-07, -8.33007e-08 ),
	"thumb_2": Transform( 0.974021, 0.179179, -0.138485, -0.153719, 0.972187, 0.176698, 0.166294, -0.15082, 0.974474, -3.25129, -6.69714e-07, -2.25983e-07 ),
	"thumb_3": Transform( 0.984754, 0.126553, 0.119347, -0.104836, 0.979262, -0.173366, -0.138811, 0.158211, 0.9776, -3.37931, 3.74931e-07, -4.57547e-08 ),
	"thumb_null": Transform( 1, -1.63913e-07, 2.45869e-07, 1.63913e-07, 1, -2.98023e-08, -2.45869e-07, 2.98023e-08, 1, -1.48634, 2.38419e-07, -2.98023e-07 ),
	"wrist": Transform( 1, 0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0 )
}""")

const oq_lefthand_skeletontransform = Transform( Vector3(0.01, 0, 0), Vector3(0, 0.01, 0), Vector3(0, 0, 0.01), Vector3(0, 0, 0) )
const oq_righthand_skeletontransform = Transform( Vector3(0.01, 0, 0), Vector3(0, 0.01, 0), Vector3(0, 0, 0.01), Vector3(0, 0, 0) )

# hands holding controllers postures
const oq_lefthand_controllergrip_boneorientations = [ Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0.471764, 0.368524, 0.0825901, 0.796749 ), Quat( 0.252133, 0.153631, 0.159081, 0.942083 ), Quat( -0.0814745, -0.049174, 0.229848, 0.968563 ), Quat( 0.0804535, 0.0542877, 0.0714153, 0.992713 ), Quat( 0.0329857, -0.0055884, 0.135946, 0.990151 ), Quat( -0.0261238, 0.00153864, 0.323206, 0.945967 ), Quat( -0.0168683, -0.024202, 0.102814, 0.994263 ), Quat( -0.0101063, -0.00479251, 0.530312, 0.847729 ), Quat( -0.0124632, 0.00498791, 0.714714, 0.699288 ), Quat( -0.0922695, 0.0248773, 0.579955, 0.809024 ), Quat( -0.0842006, -0.035978, 0.598568, 0.795821 ), Quat( -0.0418505, 0.0196106, 0.652544, 0.75634 ), Quat( -0.0323627, 0.0260134, 0.61143, 0.790209 ), Quat( -0.207036, -0.140343, 0.0183118, 0.968042 ), Quat( 0.0707321, -0.0211219, 0.630092, 0.773003 ), Quat( -0.0801693, -0.0144093, 0.543163, 0.835667 ), Quat( 0.00263388, 0.0391247, 0.593912, 0.803574 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ) ]
var oq_lefthand_controllerhandtransform = str2var("Transform( 0.147704, 0.879465, 0.452466, -0.124731, 0.470395, -0.873596, -0.981135, 0.0725972, 0.179176, -0.0600408, -0.0279442, 0.104986 )")
const oq_righthand_controllergrip_boneorientations = [ Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0.432201, 0.393216, 0.0445541, 0.810308 ), Quat( 0.261818, -0.0168982, 0.114574, 0.958143 ), Quat( -0.0781411, -0.034555, 0.368387, 0.925738 ), Quat( 0.0816343, 0.0580046, 0.0278615, 0.994583 ), Quat( 0.0208749, -0.070101, 0.313543, 0.946753 ), Quat( -0.0261515, 0.00131619, 0.315338, 0.948618 ), Quat( -0.0169508, -0.0236595, 0.130622, 0.991005 ), Quat( -0.0204704, -0.0307655, 0.431432, 0.901388 ), Quat( -0.0119961, 0.00617106, 0.787663, 0.615958 ), Quat( -0.0810382, 0.0180314, 0.424355, 0.901682 ), Quat( -0.100894, -0.077514, 0.531612, 0.837377 ), Quat( -0.0400899, 0.0253736, 0.809323, 0.585445 ), Quat( -0.0232572, 0.0286684, 0.405102, 0.913526 ), Quat( -0.207036, -0.140343, 0.0183118, 0.968042 ), Quat( 0.0704236, -0.0201182, 0.557989, 0.82661 ), Quat( -0.093166, 0.00556991, 0.796621, 0.59723 ), Quat( 0.00212586, 0.0441871, 0.425412, 0.903918 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ), Quat( 0, 0, 0, 1 ) ]
var oq_righthand_controllerhandtransform = str2var("Transform( -0.25005, 0.966524, 0.0575051, 0.119603, -0.0281036, 0.992424, 0.960817, 0.255034, -0.108572, 0.0381929, -0.0233026, 0.115482 )")

# *******
# To run this code in the editor to extract constants 
# oq_lefthand_restpose, oq_righthand_restpose, oq_lefthand_skeletontransform, oq_righthand_skeletontransform
# from the OculusQuestHand models, 
# make this file (with tool at the top) and hit Control-Shift X 
# to run this code in the editor
# *******

# tool
# extends EditorScript
#
#func getOQskelrestpose(oqhandskeleton):
#	var oqrestpose = { }
#	for i in range(oqhandskeleton.get_bone_count()):
#		var ambidextrousbonename = oqhandskeleton.get_bone_name(i).substr(4)
#		oqrestpose[ambidextrousbonename] = oqhandskeleton.get_bone_rest(i)
#	return oqrestpose
#
#
#func _run():
#	var oqlefthandmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Left.gltf"
#	var oqrighthandmodel = "res://OQ_Toolkit/OQ_ARVRController/models3d/OculusQuestHand_Right.gltf"
#	var oqlefthandmodelI = load(oqlefthandmodel).instance()
#	var oqrighthandmodelI = load(oqrighthandmodel).instance()
#
#	var oq_lefthand_restpose = getOQskelrestpose(oqlefthandmodelI.get_node("ArmatureLeft/Skeleton"))
#	var oq_righthand_restpose = getOQskelrestpose(oqrighthandmodelI.get_node("ArmatureRight/Skeleton"))
#	var oq_lefthand_skeletontransform = oqlefthandmodelI.get_node("ArmatureLeft").transform*oqlefthandmodelI.get_node("ArmatureLeft/Skeleton").transform
#	var oq_righthand_skeletontransform = oqrighthandmodelI.get_node("ArmatureRight").transform*oqrighthandmodelI.get_node("ArmatureRight/Skeleton").transform
#	print(var2str(oq_righthand_skeletontransform))


# *******
# To extract the hands holding controllers postures, put Drecordhandpositionforcontrollerpickup 
# into the process function to capture the moment when the controllers wake up and 
# displace the hands.  
# *******
#
#var Dhandorientations
#var Dhandtransform
#onready var Dhandvrcontroller = vr.rightController
#
#func Doutputcontrollertransform():
#	yield(get_tree().create_timer(0.7), "timeout")
#	print("tt: ", var2str(Dhandvrcontroller.transform.inverse()*Dhandtransform))
#	
#func Drecordhandpositionforcontrollerpickup():
#	if Dhandvrcontroller.is_hand:
#		if Dhandvrcontroller._hand_model.tracking_confidence == 1.0:
#			Dhandorientations = Dhandvrcontroller._hand_model._vrapi_bone_orientations.duplicate()
#			Dhandtransform = Dhandvrcontroller.transform
#	elif Dhandorientations != null:
#		print("lefthand: ", var2str(Dhandorientations))
#		call_deferred("Doutputcontrollertransform")
#		Dhandorientations = null
