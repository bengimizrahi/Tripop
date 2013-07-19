/*
 *  common.h
 *  Tripop
 *
 *  Created by Bengi Mizrahi on 9/28/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "Ball.h"
#import "cocos2d.h"
#import <Foundation/Foundation.h>

#define GAME_AREA_RADIUS  208.0f
#define BR                10.0f
#define TWO_BR            20.0f
#define FOUR_BR_SQ        400.0f
#define LEVEL             8
#define TOUCH_SENSITIVITY 2.0f
#define M_PI_3            1.047197551196597
#define M_PI_6            0.52359877559829881565889309058547951

#define ALERTVIEW_GAME_PAUSED 11
#define ALERTVIEW_GAME_ENDED  12

#define ACTION_ROTATE_FOREVER 20

CGPoint relPos6[6];
int nextBallId;
int nextGridId;
int hiscore;

@class Ball;
@class GameModel;

@interface RotatingLayer : Layer {
    CGFloat prevRotation;
}
@property (nonatomic, readonly) CGFloat prevRotation;
@end

void initializeCommon();
NSString* CGPointDescription(CGPoint p);
CGFloat angleBetween(CGPoint p1, CGPoint p2);
void pdis(CGPoint a, CGPoint b, CGPoint c, CGFloat dd, CGFloat* vd, CGFloat* hd, CGFloat* ad);
NSMutableArray* shuffle(NSMutableArray* array);
NSMutableArray* convertToNSArray(BallType* arr, NSInteger n);
id randomChoice(NSArray* arr);
NSArray* ballsIn(NSArray* grids);
CGPoint centerPosition(NSArray* aBalls, CGFloat rotation);
NSString* int2str(int v);
NSString* float2str(CGFloat v);

Action* action_scaleToZeroThanDestroy(Ball* aBall, GameModel* gameModel);
Action* action_inflateThanDestroy(Ball* aBall, GameModel* gameModel);
Action* action_whiteBlinkThanDestroy(Ball* aBall, GameModel* gameModel);
Action* action_destroy(Ball* aBall, GameModel* gameModel);
