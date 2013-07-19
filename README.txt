- detect unconnected balls
- slide them until all of them are connected
- addToPoppingGrids if there are any:
    while len slided balls > 0:
        pop a slided ball
        if sameColorGroup > 3 then add to popping grids:

- collision detection:
ooooooo            ooooooo
 oo oo   0   -->  0 ab cd    .
  ooo                ooo
   o                  o

From all the balls that are <2R far away from the line 0-----------., pick the closest one to '.'.

    o o o                    hd
---o--+--o-----------------------------------------.
  o vd|   o <--- hit point
  o   x   o
  o       o
   o     o
    o o o

Let rd = dist between . and 'hit point'
If vd == 2r, then rd = hd.
If vd == 0, then rd = hd-2r
So, the problem is if vd = x, what is rd in terms of x, vd and hd?

from math import sqrt, fabs
def pdis(a, b, c):
    t = b[0]-a[0], b[1]-a[1]           # Vector ab
    dd = sqrt(t[0]**2+t[1]**2)         # Length of ab
    t = t[0]/dd, t[1]/dd               # unit vector of ab
    n = -t[1], t[0]                    # normal unit vector to ab
    ac = c[0]-a[0], c[1]-a[1]          # vector ac
    return fabs(ac[0]*n[0]+ac[1]*n[1]) # Projection of ac to n (the minimum distance)
   
