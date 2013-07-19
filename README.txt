- prepare a special sorted list sliding balls where:

compare(h1, h2):
    if h1.distance < h2.distance:
	return -1
    elif h1.distance > h2.distance:
	return 1
    else:
	if h1.physicalDistance < h2.physicalDistance:
	    return -1
	else:
	    return 1

* NOTE: remove the justAttachedBalls logic. I don't think it is necessary.
