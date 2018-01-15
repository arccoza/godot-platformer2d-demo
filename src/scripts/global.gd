extends Node

enum {IN, OUT, INOUT, LINEAR, QUAD, CUBIC, QUART, QUINT}

static func ease(from, to, progress, type=[null, LINEAR]):
	#if progress >= 1.0: return to
	var p = progress  # 0.0 -> 1.0
	var step = null
	var change = to - from
	print("p: ", p, " change: ", change)
	
	match type:
		[IN, QUINT]:
			step = change * p * p * p * p * p
		[OUT, QUINT]:
			p -= 1
			step = change * (p * p * p * p * p + 1)
		[INOUT, QUINT]:
			p /= 2
			if p < 1:
				step = (change / 2) * p * p * p * p * p
			else:
				p = p - 2
				step = (change / 2) * (p * p * p * p + 2)

		[IN, QUART]:
			step = change * p * p * p * p
		[OUT, QUART]:
			p -= 1
			step = -change * (p * p * p * p - 1)
		[INOUT, QUART]:
			p /= 2
			if p < 1:
				step = (change / 2) * p * p * p * p
			else:
				p = p - 2
				step = (-change / 2) * (p * p * p * p - 2)

		[IN, CUBIC]:
			step = change * p * p * p
		[OUT, CUBIC]:
			p -= 1
			step = change * (p * p * p + 1)
		[INOUT, CUBIC]:
			p /= 2
			if p < 1:
				step = (change / 2) * p * p * p
			else:
				p -= 2
				step = (change / 2) * (p * p * p + 2)
		
		[IN, QUAD]:
			step = change * p * p
		[OUT, QUAD]:
			step = change * p * (2 - p)
		[INOUT, QUAD]:
			p /= 2
			if p < 1:
				step = (change / 2) * p * p
			else:
				step = (-change / 2) * ((--p) * (p - 2) - 1)
		
		[_, LINEAR]: continue
		[]: continue
		[..]:
			step = change * p
	
	return from + step