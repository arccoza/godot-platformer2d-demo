extends Node

enum {IN, OUT, INOUT, LINEAR, QUAD, CUBIC, QUART, QUINT}

static func ease(from, to, cur, tot, type=[null, LINEAR]):
	var per = 0.0
	var res = null
	var change = to - from
	
	match type:
		[IN, CUBIC]:
			per = cur / tot
			res = from + change * per * per * per
		[OUT, CUBIC]:
			per = cur / tot - 1
			res = from + change * (per * per * per + 1)
		[OUT, CUBIC]:
			per = cur / tot / 2
			if per < 1:
				res = from + (change / 2) * per * per * per
			else:
				per = per - 2
				res = from + (change / 2) * (per * per * per + 2)
		[IN, QUAD]:
			per = cur / tot
			res = from + change * per * per
		[OUT, QUAD]:
			per = cur / tot
			res = from + change * per * (per - 2)
		[OUT, QUAD]:
			per = cur / tot / 2
			if per < 1:
				res = from + (change / 2) * per * per
			else:
				res = from + (-change / 2) * ((--per) * (per - 2) - 1)
		[_, LINEAR]: continue
		[]: continue
		[..]:
			per = cur / tot
			res = from + change * per
	
	return res