extends Spatial

var controlledavatar = null

var n = 0
func _process(delta):
	if controlledavatar == null:
		var hubsavatar = vr.vrOrigin.get_node("Feature_HubsAvatar")
		if hubsavatar != null:
			controlledavatar = hubsavatar.avatarnode
	if controlledavatar != null:
		transform = controlledavatar.transform
		var avatarskeleton = controlledavatar.get_node("AvatarRoot/Skeleton")
		for i in range(avatarskeleton.get_bone_count()):
			var bp = avatarskeleton.get_bone_pose(i)
			$AvatarRoot/Skeleton.set_bone_pose(i, bp)

		if $smarker.visible:
			$smarker.transform.origin = transform.inverse()*vr.vrCamera.transform.origin
			var vrcamera = $smarker.global_transform
			var eyetrans = $AvatarRoot/Skeleton.global_transform*$AvatarRoot/Skeleton.get_bone_global_pose(avatarskeleton.find_bone("left_eye"))
			$smarker.global_transform.origin = eyetrans.origin + eyetrans.basis.y*0.0
