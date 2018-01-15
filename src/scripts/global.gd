extends Node

enum {IN, OUT, INOUT, LINEAR, QUAD, CUBIC, QUART, QUINT}

static func ease(from, to, cur, tot, type=[null, LINEAR]):
	var per = cur / tot
	var step = null
	var change = to - from
	
	match type:
		[IN, QUINT]:
			step = change * per * per * per * per * per
		[OUT, CUBIC]:
			per -= 1
			step = change * (per * per * per * per * per + 1)
		[INOUT, CUBIC]:
			per /= 2
			if per < 1:
				step = (change / 2) * per * per * per * per * per
			else:
				per = per - 2
				step = (change / 2) * (per * per * per * per + 2)

		[IN, QUART]:
			step = change * per * per * per * per
		[OUT, CUBIC]:
			per -= 1
			step = -change * (per * per * per * per - 1)
		[INOUT, CUBIC]:
			per /= 2
			if per < 1:
				step = (change / 2) * per * per * per * per
			else:
				per = per - 2
				step = (-change / 2) * (per * per * per * per - 2)

		[IN, CUBIC]:
			step = change * per * per * per
		[OUT, CUBIC]:
			per -= 1
			step = change * (per * per * per + 1)
		[INOUT, CUBIC]:
			per /= 2
			if per < 1:
				step = (change / 2) * per * per * per
			else:
				per -= 2
				step = (change / 2) * (per * per * per + 2)
		
		[IN, QUAD]:
			step = change * per * per
		[OUT, QUAD]:
			step = change * per * (per - 2)
		[INOUT, QUAD]:
			per /= 2
			if per < 1:
				step = (change / 2) * per * per
			else:
				step = (-change / 2) * ((--per) * (per - 2) - 1)
		
		[_, LINEAR]: continue
		[]: continue
		[..]:
			step = change * per
	
	return from + step