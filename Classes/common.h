/*
 *  common.h
 *  Tripop
 *
 *  Created by Bengi Mizrahi on 9/28/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "cocos2d.h"
#import <Foundation/Foundation.h>

#define GAME_AREA_RADIUS  180.0f
#define BR                10.0f
#define TWO_BR            20.0f
#define FOUR_BR_SQ        400.0f
#define LEVEL             8
#define TOUCH_SENSITIVITY 2.0f
#define M_PI_3            1.047197551196597
#define M_PI_6            0.52359877559829881565889309058547951

CGPoint relPos6[6];

@class Ball;
@class GameModel;

@interface RotatingLayer : Layer {
    CGFloat prevRotation;
}
@property (nonatomic, readonly) CGFloat prevRotation;
@end

void initializeCommon();
GameModel* gameModel();
NSString* CGPointDescription(CGPoint p);
CGFloat angleBetween(CGPoint p1, CGPoint p2);
void pdis(CGPoint a, CGPoint b, CGPoint c, CGFloat dd, CGFloat* vd, CGFloat* hd, CGFloat* ad);
NSMutableArray* shuffle(NSMutableArray* array);
id randomChoice(NSArray* arr);
NSArray* ballsIn(NSArray* hexagrids);
CGPoint centerPosition(NSArray* aBalls);

Action* action_scaleToZeroThanDestroy(Ball* aBall);
Action* action_fadeOutThanDestroy(Ball* aBall);
Action* action_inflateThanDestroy(Ball* aBall);
Action* action_whiteBlinkThanDestroy(Ball* aBall);
Action* action_destroy(Ball* aBall);

