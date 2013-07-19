//
//  Ball.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BallType_Core = 0,
    BallType_Red,
    BallType_Green,
    BallType_Blue,
    BallType_Yellow,
    BallType_FireBall,
} BallType;

@class BallMoveStrategy;
@class Hexagrid;
@class CocosNode;
@class RotatingLayer;

@interface Ball : NSObject {
    int identifier;
    CocosNode* node;
    
    BallType type;
    BallMoveStrategy* moveStrategy;
    Hexagrid* hexagrid;
    BOOL isBeingDestroyed;
    
    CGPoint prevPosition;
    CGFloat __verticalDist;
    CGFloat __horizontalDist;
    CGFloat __actualDist;
}

@property (nonatomic, readonly) int identifier;
@property (nonatomic, readonly) CocosNode* node;

@property (nonatomic, readonly) BallType type;
@property (nonatomic, retain) BallMoveStrategy* moveStrategy;
@property (nonatomic, retain) Hexagrid* hexagrid;
@property (nonatomic, assign) BOOL isBeingDestroyed;

@property (nonatomic) CGPoint position;

@property (nonatomic, assign) CGFloat __verticalDist;
@property (nonatomic, assign) CGFloat __horizontalDist;
@property (nonatomic, assign) CGFloat __actualDist;

- (id) initWithType:(BallType)aType;

- (void) moveByDeltaTime:(CGFloat)dt;
- (CGPoint) positionOnLayer:(RotatingLayer*)aLayer;
- (CGPoint) prevPositionOnLayer:(RotatingLayer*)aLayer;

- (NSComparisonResult) compare:(Ball*)aBall;
- (NSString*) description;

@end
