tool
extends Light2D



func _ready():
	var tex = ImageTexture.new()
	var img = Image.new()
	var size = Vector2(64, 64)
	
	img.create(size.x, size.y, false, Image.FORMAT_RGBA8)
#	img.fill(Color(1,1,0,0.5))
	
	img.lock()
	var uv = Vector2()
	for x in range(0, size.x):
		uv.x = float(x) / (size.x - 1)
		for y in range(0, size.y):
			uv.y = float(y) / (size.y - 1)
#			prints(x, y, uv)
			img.set_pixel(x, y, Color(1,1,1,uv.x))
	img.unlock()
#	prints(uv)

#	prints(img.data["data"].size())
	
	tex.create_from_image(img, Texture.FLAG_FILTER)
	self.texture = tex
	
#	for k in img.data:
#		prints(k)
	prints("data: ", tex.get_data())
	
	tex.resource_name = "The created texture!"
	print(self.texture.resource_name)
	
	var tmp = LightTexture.new()
	print(tmp)


class LightTexture extends ImageTexture:
	enum {GRADIENT_LINEAR, GRADIENT_RADIAL}
	export(int, "Linear", "Radial") var gradient_type
	export(bool) var reflected = false
	export(float, 0, 1) var soften_edges = 0
	export var size = Vector2(64, 64)
	var image = Image.new()
	
	func _init():
		image.create(size.x, size.y, true, Image.FORMAT_RGBA8)
