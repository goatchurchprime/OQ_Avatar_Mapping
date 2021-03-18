extends Spatial

onready var avatarskeleton = $avatar/AvatarRoot/Skeleton
export var vrenabled = true

func _ready():
	print(ARVRServer.get_interfaces())
	if ARVRServer.find_interface("OVRMobile"):
		vrenabled = true
	if vrenabled:
		vr.initialize()
	
func _process(delta):
	var head_transform = $OQ_ARVROrigin/OQ_ARVRCamera.transform
	avatarskeleton.set_bone_pose(avatarskeleton.find_bone("hips"), Transform(Basis(), head_transform.origin - Vector3(0,0.5,0)))
		
	head_transform.basis.x *= -1
	head_transform.basis.z *= -1
	avatarskeleton.set_bone_global_pose_override(avatarskeleton.find_bone("neck"),head_transform,1)

	var right_hand = $OQ_ARVROrigin/OQ_RightController.transform
	right_hand.basis *= Basis(Vector3(0,0,1),Vector3(0,1,0),Vector3(-1,0,0))
	right_hand.basis *= Basis(Vector3(0,1,0),Vector3(-1,0,0),Vector3(0,0,1))
	avatarskeleton.set_bone_global_pose_override(avatarskeleton.find_bone("right_hand"), right_hand, 1)

	var left_hand = $OQ_ARVROrigin/OQ_LeftController.transform
	left_hand.basis *= Basis(Vector3(0,0,-1),Vector3(0,1,0),Vector3(1,0,0))
	left_hand.basis *= Basis(Vector3(0,-1,0),Vector3(1,0,0),Vector3(0,0,1))
	avatarskeleton.set_bone_global_pose_override(avatarskeleton.find_bone("left_hand"), left_hand, 1)
