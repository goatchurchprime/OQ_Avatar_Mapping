extends Spatial

onready var avatarskeleton = $avatar/AvatarRoot/Skeleton
export var vrenabled = true

const test_pose_left_ThumbsUp = [Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), 
Quat(0.321311, 0.450518, -0.055395, 0.831098),
Quat(0.263483, -0.092072, 0.093766, 0.955671), 
Quat(-0.082704, -0.076956, -0.083991, 0.990042),
Quat(0.085132, 0.074532, -0.185419, 0.976124), 

Quat(0.010016, -0.068604, 0.563012, 0.823536),
Quat(-0.019362, 0.016689, 0.8093, 0.586839), 
Quat(-0.01652, -0.01319, 0.535006, 0.844584),

Quat(-0.072779, -0.078873, 0.665195, 0.738917), 
Quat(-0.0125, 0.004871, 0.707232, 0.706854),
Quat(-0.092244, 0.02486, 0.57957, 0.809304), 

Quat(-0.10324, -0.040148, 0.705716, 0.699782),
Quat(-0.041179, 0.022867, 0.741938, 0.668812), 
Quat(-0.030043, 0.026896, 0.558157, 0.828755),

Quat(-0.207036, -0.140343, 0.018312, 0.968042), 
Quat(0.054699, -0.041463, 0.706765, 0.704111),
Quat(-0.081241, -0.013242, 0.560496, 0.824056), 
Quat(0.00276, 0.037404, 0.637818, 0.769273),
]

enum OVRBone { # https://developer.oculus.com/documentation/unity/unity-handtracking/
	Hand_WristRoot   = 0,
	Hand_ForearmStub = 1, 
	Hand_Thumb0      = 2, 
	Hand_Thumb1      = 3, 
	Hand_Thumb2      = 4, 
	Hand_Thumb3      = 5, # thumb distal phalange bone
	Hand_Index1      = 6, # index proximal phalange bone
	Hand_Index2      = 7, # index intermediate phalange bone
	Hand_Index3      = 8, # index distal phalange bone
	Hand_Middle1     = 9, # middle proximal phalange bone
	Hand_Middle2     = 10,# middle intermediate phalange bone
	Hand_Middle3     = 11,# middle distal phalange bone
	Hand_Ring1       = 12,# ring proximal phalange bone
	Hand_Ring2       = 13,# ring intermediate phalange bone
	Hand_Ring3       = 14,# ring distal phalange bone
	Hand_Pinky0      = 15,# pinky metacarpal bone
	Hand_Pinky1      = 16,# pinky proximal phalange bone
	Hand_Pinky2      = 17,# pinky intermediate phalange bone
	Hand_Pinky3      = 18
}

const bonemapping = [ 
	"hand_index_1", OVRBone.Hand_Index1, 
	"hand_index_2", OVRBone.Hand_Index2, 
	"hand_index_3", OVRBone.Hand_Index3, 
	"hand_middle_1", OVRBone.Hand_Middle1, 
	"hand_middle_2", OVRBone.Hand_Middle2, 
	"hand_middle_3", OVRBone.Hand_Middle3, 
	"hand_ring_1", OVRBone.Hand_Ring1, 
	"hand_ring_2", OVRBone.Hand_Ring2, 
	"hand_ring_3", OVRBone.Hand_Ring3, 
	"hand_pinky_1", OVRBone.Hand_Pinky1, 
	"hand_pinky_2", OVRBone.Hand_Pinky2, 
	"hand_pinky_3", OVRBone.Hand_Pinky3, 
	"hand_thumb_1", OVRBone.Hand_Thumb0, 
	"hand_thumb_2", OVRBone.Hand_Thumb1, 
	"hand_thumb_3", OVRBone.Hand_Thumb2, 
]	

var ghipsposerest
var gheadposerest
var glefthandposerest
var grighthandposerest

var middleEyeMatrix
var invMiddleEyeToHead
var invHipsToHeadVector

func setbonepose(s, n, q):
	var i = s.find_bone(n)
	assert (i != -1)
	var bone_rest = s.get_bone_rest(i);
	print(n, " ", bone_rest.origin.length())
	s.set_bone_pose(i, (bone_rest.basis.inverse()*Basis(q)))

func _ready():
	print(ARVRServer.get_interfaces())
	if ARVRServer.find_interface("OVRMobile"):
		vrenabled = true
	if vrenabled:
		vr.initialize()
	print(len(test_pose_left_ThumbsUp))

	#for i in range(avatarskeleton.get_bone_count()):
	#	avatarskeleton.set_bone_pose(i, Transform())

	#avatarskeleton.set_bone_pose(avatarskeleton.find_bone("left_hand"), Transform(Basis(Vector3(1,0,0), deg2rad(-90))))
	#for i in range(0, len(bonemapping), 2):
	for i in range(24, 26, 2):
		break
		var j = avatarskeleton.find_bone("left_"+bonemapping[i])
		var q = test_pose_left_ThumbsUp[bonemapping[i+1]]
		var gp = avatarskeleton.get_bone_rest(j)
		print(q)
		q = Quat(q.z, q.x, q.y, q.w) # Vector3(1,0,0), deg2rad(90))
		print(q)
		q = Quat(Vector3(0,0,1), deg2rad(-45))
		#q = Quat(Vector3(1,0,0), deg2rad(90))*Quat(Vector3(0,0,1), deg2rad(-90))*q
		avatarskeleton.set_bone_pose(j, Transform(gp.basis.inverse()*Basis(q)))

	var sa = avatarskeleton
	var sq = $OculusQuestHand_Left/ArmatureLeft/Skeleton
	var q = Quat(Vector3(0,0,1), deg2rad(90))
	#setbonepose(sq, "b_l_wrist", Quat(0,0,0,1))
	sq.set_bone_rest(sq.find_bone("b_l_wrist"), Transform())

	var qqz = Quat(Vector3(1,1,1).normalized(), deg2rad(120))
	setbonepose(sq, "b_l_thumb_0", Quat(0.321311, 0.450518, -0.055395, 0.831098))
	setbonepose(sq, "b_l_thumb_1", Quat(0.263483, -0.092072, 0.093766, 0.955671))
	setbonepose(sq, "b_l_thumb_2", Quat(-0.082704, -0.076956, -0.083991, 0.990042))
	#setbonepose(sq, "b_l_thumb_3", Quat(0.085132, 0.074532, -0.185419, 0.976124))
	setbonepose(sa, "left_hand_thumb_1", qqz*Quat(0.321311, 0.450518, -0.055395, 0.831098)*qqz.inverse())
	setbonepose(sa, "left_hand_thumb_2", qqz*Quat(0.263483, -0.092072, 0.093766, 0.955671)*qqz.inverse())
	setbonepose(sa, "left_hand_thumb_3", qqz*Quat(-0.082704, -0.076956, -0.083991, 0.990042)*qqz.inverse())
	



	setbonepose(sq, "b_l_index_1", Quat(0.010016, -0.068604, 0.563012, 0.823536))
	setbonepose(sq, "b_l_index_2", Quat(-0.019362, 0.016689, 0.8093, 0.586839))
	setbonepose(sq, "b_l_index_3", Quat(-0.01652, -0.01319, 0.535006, 0.844584))

	setbonepose(sa, "left_hand_index_1", qqz*Quat(0.010016, -0.068604, 0.563012, 0.823536)*qqz.inverse())
	setbonepose(sa, "left_hand_index_2", qqz*Quat(-0.019362, 0.016689, 0.8093, 0.586839)*qqz.inverse())
	setbonepose(sa, "left_hand_index_3", qqz*Quat(-0.01652, -0.01319, 0.535006, 0.844584)*qqz.inverse())

	setbonepose(sq, "b_l_pinky_1", Quat(-0.207036, -0.140343, 0.018312, 0.968042))
	setbonepose(sa, "left_hand_pinky_1", qqz*Quat(-0.207036, -0.140343, 0.018312, 0.968042)*qqz.inverse())
 
#Quat(0.054699, -0.041463, 0.706765, 0.704111),
#Quat(-0.081241, -0.013242, 0.560496, 0.824056), 

	#setbonepose(sq, "b_l_index_2", Quat(Vector3(0,0,1), deg2rad(90)))
	#setbonepose(sa, "left_hand_index_2", qqz*Quat(Vector3(0,0,1), deg2rad(90))*qqz.inverse())
	

	var hipheight = 1.2
	var bhips = avatarskeleton.find_bone("hips")
	avatarskeleton.set_bone_pose(bhips, Transform(Basis(), Vector3(0,hipheight,0)))
	ghipsposerest = avatarskeleton.get_bone_global_pose(avatarskeleton.find_bone("hips"))
	gheadposerest = avatarskeleton.get_bone_global_pose(avatarskeleton.find_bone("head"))
	grighthandposerest = avatarskeleton.get_bone_global_pose(avatarskeleton.find_bone("right_hand"))
	glefthandposerest = avatarskeleton.get_bone_global_pose(avatarskeleton.find_bone("left_hand"))
	
	var middleEyePosition = 0.5*(avatarskeleton.get_bone_rest(avatarskeleton.find_bone("left_eye")).origin + avatarskeleton.get_bone_rest(avatarskeleton.find_bone("right_eye")).origin)
	middleEyeMatrix = Transform(Basis(), middleEyePosition)
	invMiddleEyeToHead = middleEyeMatrix.inverse()
	invHipsToHeadVector = -(avatarskeleton.get_bone_rest(avatarskeleton.find_bone("spine")).origin + avatarskeleton.get_bone_rest(avatarskeleton.find_bone("neck")).origin + avatarskeleton.get_bone_rest(avatarskeleton.find_bone("head")).origin)
	
	
	var skeleton = $OculusQuestHand_Left/ArmatureLeft/Skeleton
	var _vrapi2hand_bone_map = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];
	for i in range(19):
		break
		var j = _vrapi2hand_bone_map[i]
		var bone_rest = skeleton.get_bone_rest(j);
		skeleton.set_bone_pose(j, (bone_rest.basis.inverse()*Basis(test_pose_left_ThumbsUp[i])))
	
	
func _process(delta):
	var hipheight = 1.2
	var head_transform = $OQ_ARVROrigin/OQ_ARVRCamera.transform
	var ltrans = Transform(head_transform.basis, Vector3(0,head_transform.origin.y,0))
	var cpos = Vector3(head_transform.origin.x, 0, head_transform.origin.z)
	ltrans.basis.x.y = -ltrans.basis.x.y
	ltrans.basis.z.y = -ltrans.basis.z.y
	var bhead = avatarskeleton.find_bone("head")
	#avatarskeleton.set_bone_pose(avatarskeleton.find_bone("hips"), Transform(Basis(), head_transform.origin - Vector3(0,0.5,0)))
	avatarskeleton.set_bone_pose(bhead, gheadposerest.inverse()*ltrans)
	
	var bhips = avatarskeleton.find_bone("hips")
	avatarskeleton.set_bone_pose(bhips, Transform(Basis(), Vector3(0,hipheight,0)))

	var right_hand = $OQ_ARVROrigin/OQ_RightController.transform
	right_hand.origin.x = -(right_hand.origin.x - cpos.x)
	right_hand.origin.z = -(right_hand.origin.z - cpos.z)
	var brh = avatarskeleton.find_bone("right_hand")
	avatarskeleton.set_bone_pose(brh, grighthandposerest.inverse()*right_hand)

	var left_hand = $OQ_ARVROrigin/OQ_LeftController.transform
	left_hand.origin.x = -(left_hand.origin.x - cpos.x)
	left_hand.origin.z = -(left_hand.origin.z - cpos.z)
	var brl = avatarskeleton.find_bone("left_hand")
	left_hand.basis = Basis(Vector3(0,0,1), deg2rad(90))*Basis(Vector3(0,0,1), deg2rad(180))
	avatarskeleton.set_bone_pose(brl, glefthandposerest.inverse()*left_hand)


	# attempts to scavenge code from Hubs IK module
	var flipY = Transform(Basis(Vector3(0,1,0), deg2rad(180)))
	var cameraForward = $OQ_ARVROrigin/OQ_ARVRCamera.transform*flipY
	var headTransform = cameraForward*invMiddleEyeToHead
	#$avatar.transform.origin = Vector3(0, headTransform.origin.y, 0) + invHipsToHeadVector
	
	var cameraYRotation = cameraForward.basis.get_euler() # YXZ not "YXZ"
	cameraYRotation.x = 0;
	cameraYRotation.z = 0;
	var cameraYQuaternion = Quat(cameraYRotation)
	# cameraYQuaternion is then slerped in the Mozilla code
	#$avatar.transform.basis = Basis(cameraYQuaternion)
	
	var invHipsQuaternion = Quat($avatar.transform.basis).inverse()
	var headquaternion = invHipsQuaternion*Quat(headTransform.basis)
	var rootToChest = $avatar.transform*avatarskeleton.get_bone_rest(avatarskeleton.find_bone("spine"))
	var invRootToChest = rootToChest.inverse()

	#handMatrix.multiplyMatrices(this.invRootToChest, controllerObject3D.matrix);
	#handMatrix.multiply(handRotation);
	#handObject3D.position.setFromMatrixPosition(handMatrix);
	#handObject3D.rotation.setFromRotationMatrix(handMatrix);
