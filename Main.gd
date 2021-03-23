extends Spatial

export var vrenabled = true

func _ready():
	print(ARVRServer.get_interfaces())
	if ARVRServer.find_interface("OVRMobile"):
		vrenabled = true
	if vrenabled:
		vr.initialize()

