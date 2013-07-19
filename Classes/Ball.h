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
    BallType_Dynamite,
    BallType_Lightning,
} BallType;

@class BallMoveStrategy;
@class Hexagrid;
@class CocosNode;
@class RotatingLayer;
@class GameModel;

@interface Ball : NSObject<NSCoding> {
    int identifier;
    CocosNode* node;
    
    int points;
    CGFloat power;
    BallType type;
    BallMoveStrategy* moveStrategy;
    Hexagrid* hexagrid;
    BOOL isBeingDestroyed;
    
    GameModel* gameModel;
    
    CGPoint prevPosition;
    CGFloat __verticalDist;
    CGFloat __horizontalDist;
    CGFloat __actualDist;
}

@property (nonatomic, readonly) int identifier;
@property (nonatomic, readonly) CocosNode* node;

@property (nonatomic, assign) int points;
@property (nonatomic, assign) CGFloat power;
@property (nonatomic, readonly) BallType type;
@property (nonatomic, retain) BallMoveStrategy* moveStrategy;
@property (nonatomic, retain) Hexagrid* hexagrid;
@property (nonatomic, assign) BOOL isBeingDestroyed;

@property (nonatomic, assign) GameModel* gameModel;

@property (nonatomic) CGPoint position;

@property (nonatomic, assign) CGFloat __verticalDist;
@property (nonatomic, assign) CGFloat __horizontalDist;
@property (nonatomic, assign) CGFloat __actualDist;

- (id) initWithGameModel:(GameModel*)aGameModel;
- (id) initWithType:(BallType)aType gameModel:(GameModel*)aGameModel;
- (void) encodeWithCoder:(NSCoder*)aCoder;
- (id) initWithCoder:(NSCoder*)aDecoder;

- (void) pauseActions;
- (void) resumeActions;

- (void) moveByDeltaTime:(CGFloat)dt;
- (CGPoint) positionOnLayer:(RotatingLayer*)aLayer;
- (CGPoint) prevPositionOnLayer:(RotatingLayer*)aLayer;
- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall;
- (void) applyActionsAfterCollapsingTerminates;
- (NSArray*) randomPathToCore;

- (NSComparisonResult) compare:(Ball*)aBall;
- (NSString*) description;

@end
