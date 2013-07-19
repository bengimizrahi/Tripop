/*
 *  common.h
 *  Tripop
 *
 *  Created by Bengi Mizrahi on 9/28/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#define GAME_AREA_RADIUS  180.0f
#define BR                10.0f
#define BR_SQ             400.0f
#define LEVEL             8
#define TOUCH_SENSITIVITY 1.0f
#define M_PI_3            1.047197551196597
#define M_PI_6            0.52359877559829881565889309058547951

CGPoint relPos6[6];

void initializeCommon();

CGFloat angleBetween(CGPoint p1, CGPoint p2);
NSString* CGPointDescription(CGPoint p);