/*
 *  common.c
 *  Tripop
 *
 *  Created by Bengi Mizrahi on 9/28/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "common.h"
#include "cocos2d.h"

void initializeCommon() {
    relPos6[0] = ccp(2 * BR * cosf(M_PI_6), 2 * BR * sinf(M_PI_6));
    relPos6[1] = ccp(0, 2 * BR);
    relPos6[2] = ccp(2 * BR * cosf(5 * M_PI_6), 2 * BR * sinf(5 * M_PI_6));
    relPos6[3] = ccp(2 * BR * cosf(7 * M_PI_6), 2 * BR * sinf(7 * M_PI_6));
    relPos6[4] = ccp(0, -2 * BR);
    relPos6[5] = ccp(2 * BR * cosf(11 * M_PI_6), 2 * BR * sinf(11 * M_PI_6));
}

CGFloat angleBetween(CGPoint p1, CGPoint p2) {
    CGFloat angle = ccpToAngle(ccpSub(p2, p1));
    if (angle < 0.0f) angle += 2*M_PI;
    return angle;
}

NSString* CGPointDescription(CGPoint p) {
    return [NSString stringWithFormat:@"ccp(%.2f,%.2f)", p.x, p.y];
}