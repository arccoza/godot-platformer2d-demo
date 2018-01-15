extends Node

enum {IN, OUT, INOUT, LINEAR, QUAD, CUBIC, QUART, QUINT}

static func ease(from, to, cur, tot, type=[null, LINEAR]):
	var per = cur / tot
	var res = null
	var change = to - from
	
	match type:
		[IN, QUINT]:
			per = cur / tot
			res = change * per * per * per * per * per
		[OUT, CUBIC]:
			per = cur / tot - 1
			res = change * (per * per * per * per * per + 1)
		[INOUT, CUBIC]:
			per = cur / tot / 2
			if per < 1:
				res = (change / 2) * per * per * per * per * per
			else:
				per = per - 2
				res = (change / 2) * (per * per * per * per + 2)

		[IN, QUART]:
			per = cur / tot
			res = change * per * per * per * per
		[OUT, CUBIC]:
			per = cur / tot - 1
			res = -change * (per * per * per * per - 1)
		[INOUT, CUBIC]:
			per = cur / tot / 2
			if per < 1:
				res = (change / 2) * per * per * per * per
			else:
				per = per - 2
				res = (-change / 2) * (per * per * per * per - 2)

		[IN, CUBIC]:
			per = cur / tot
			res = change * per * per * per
		[OUT, CUBIC]:
			per = cur / tot - 1
			res = change * (per * per * per + 1)
		[INOUT, CUBIC]:
			per = cur / tot / 2
			if per < 1:
				res = (change / 2) * per * per * per
			else:
				per = per - 2
				res = (change / 2) * (per * per * per + 2)
		
		[IN, QUAD]:
			per = cur / tot
			res = change * per * per
		[OUT, QUAD]:
			per = cur / tot
			res = change * per * (per - 2)
		[INOUT, QUAD]:
			per = cur / tot / 2
			if per < 1:
				res = (change / 2) * per * per
			else:
				res = (-change / 2) * ((--per) * (per - 2) - 1)
		
		[_, LINEAR]: continue
		[]: continue
		[..]:
			per = cur / tot
			res = change * per
	
	return from + res