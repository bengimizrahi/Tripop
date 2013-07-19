/*
 *  common.c
 *  Tripop
 *
 *  Created by Bengi Mizrahi on 9/28/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameModel.h"
#include "TripopAppDelegate.h"
#include "common.h"

@implementation RotatingLayer
@synthesize prevRotation;
@end

void initializeCommon() {
	struct timeval t;
	gettimeofday(&t, nil);
	unsigned int i;
	i = t.tv_sec;
	i += t.tv_usec;
	srandom(i);
    
    relPos6[0] = ccp(2 * BR * cosf(M_PI_6), 2 * BR * sinf(M_PI_6));
    relPos6[1] = ccp(0, 2 * BR);
    relPos6[2] = ccp(2 * BR * cosf(5 * M_PI_6), 2 * BR * sinf(5 * M_PI_6));
    relPos6[3] = ccp(2 * BR * cosf(7 * M_PI_6), 2 * BR * sinf(7 * M_PI_6));
    relPos6[4] = ccp(0, -2 * BR);
    relPos6[5] = ccp(2 * BR * cosf(11 * M_PI_6), 2 * BR * sinf(11 * M_PI_6));
}

NSString* CGPointDescription(CGPoint p) {
    return [NSString stringWithFormat:@"ccp(%f,%f)", p.x, p.y];
}

CGFloat angleBetween(CGPoint p1, CGPoint p2) {
    CGFloat angle = ccpToAngle(ccpSub(p2, p1));
    if (angle < 0.0f) angle += 2*M_PI;
    return angle;
}

void pdis(CGPoint a, CGPoint b, CGPoint c, CGFloat d, CGFloat* vd, CGFloat* hd, CGFloat* ad) {
    CCLOG(@"Begin pdis(a=%@, b=%@, c=%@, dd=?, vd=?, hd=?, ad=?)", CGPointDescription(a),  CGPointDescription(b), CGPointDescription(c));
    CGPoint t, n, bc;
    t = ccpSub(a, b);
    CCLOG(@"t=%@", CGPointDescription(t));
    d = ccpLength(t);
    CCLOG(@"d=%.2f", d);
    if (d == 0.0f) {CCLOG(@"ASSERT FAILURE: dd(%.2f) must be greater than 0.0f", d); exit(1);}
    t = ccpMult(t, 1.0f/d);
    CCLOG(@"t=%@", CGPointDescription(t));
    n = ccpPerp(t);
    CCLOG(@"n=%@", CGPointDescription(n));
    bc = ccpSub(c, b);
    CCLOG(@"bc=%@", CGPointDescription(bc));
    *vd = fabs(ccpDot(bc, n));
    *hd = fabs(ccpDot(bc, t));
    *ad = FLT_MAX;
    if (TWO_BR >= *vd) {
        *ad = *hd - sqrt(FOUR_BR_SQ - (*vd)*(*vd));
    }
    CCLOG(@"End pdis(a=%@, b=%@, c=%@, dd=%.2f, vd=%.2f, hd=%.2f, ad=%.2f)", CGPointDescription(a),  CGPointDescription(b), CGPointDescription(c), d, *vd, *hd, *ad);
}

NSMutableArray* shuffle(NSMutableArray* array) {
    for (int limit = [array count]; limit >= 0; --limit) {
        int r = CCRANDOM_0_1() * limit;
        id randomObject = [array objectAtIndex:r];
        [array removeObjectAtIndex:r];
        [array addObject:randomObject];
    }
    return array;
}

Action* action_scaleTheBallToZeroThanDestroyIt(Ball* aBall) {
    TripopAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    GameModel* gameModel = delegate.gameModel;
    return [Sequence actions:
            [Spawn actions:[ScaleTo actionWithDuration:0.3f scale:0.0f], [FadeTo actionWithDuration:0.3f opacity: 100], nil],
            [CallFuncND actionWithTarget:gameModel selector:@selector(__destroy:ball:) data:aBall], nil];
}
