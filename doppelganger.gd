extends Spatial

var avatarnode = null

func _process(delta):
	if avatarnode == null:
		var hubsavatar = vr.vrOrigin.get_node("Feature_HubsAvatar")
		if hubsavatar != null:
			avatarnode = hubsavatar.avatarnode
	if avatarnode != null:
		transform.origin = avatarnode.transform.origin
		var avatarskeleton = avatarnode.get_node("AvatarRoot/Skeleton")
		for i in range(avatarskeleton.get_bone_count()):
			var bp = avatarskeleton.get_bone_pose(i)
			$AvatarRoot/Skeleton.set_bone_pose(i, bp)
		#print($AvatarRoot/Skeleton.get_bone_global_pose($AvatarRoot/Skeleton.find_bone("right_eye")))
		$smarker.transform = $AvatarRoot/Skeleton.get_bone_global_pose($AvatarRoot/Skeleton.find_bone("left_hand_index_3"))
