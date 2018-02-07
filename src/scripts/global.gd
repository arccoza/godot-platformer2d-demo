extends Node

enum {IN, OUT, INOUT, LINEAR, QUAD, CUBIC, QUART, QUINT}

var bob = "sam"

func _enter_tree():
	print("global")

static func ease(from, to, progress, type=[null, LINEAR]):
	#if progress >= 1.0: return to
	var p = progress  # 0.0 -> 1.0
	var change = to - from
	#print("p: ", p, " change: ", change)
	
	match type:
		[IN, QUART]:
			p = p * p * p * p
		[OUT, QUART]:
			p -= 1
			p = 1 - p * p * p * p 
		[INOUT, QUART]:
			if p < 0.5:
				p = 8 * p * p * p * p
			else:
				p -= 1
				p = 1 - 8 * p * p * p * p

		[IN, CUBIC]:
			p = p * p * p
		[OUT, CUBIC]:
			p -= 1
			p = p * p * p + 1
		[INOUT, CUBIC]:
			p = 4 * p * p * p if p < 0.5 else (p - 1) * (2 * p - 2) * (2 * p - 2) + 1

		[IN, QUAD]:
			p = p * p
		[OUT, QUAD]:
			p = p * (2 - p)
		[INOUT, QUAD]:
			p = 2 * p * p if p < 0.5 else (4 - 2 * p) * p - 1
		
		[_, LINEAR]: continue
		[]: continue
		[..]:
			p = p
	
	return from + p * change