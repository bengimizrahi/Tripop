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
} BallType;

@class Sprite;
@class BallMoveStrategy;
@class Hexagrid;

@interface Ball : NSObject {
    int identifier;
    Sprite* sprite;
    
    BallType type;
    BallMoveStrategy* moveStrategy;
    Hexagrid* hexagrid;
    BOOL goingToPop;

    float __verticalDist;
    float __horizontalDist;
    float __actualDist;
}

@property (nonatomic, readonly) int identifier;
@property (nonatomic, readonly) Sprite* sprite;

@property (nonatomic, readonly) BallType type;
@property (nonatomic, retain) BallMoveStrategy* moveStrategy;
@property (nonatomic, retain) Hexagrid* hexagrid;
@property (nonatomic, assign) BOOL goingToPop;
@property (nonatomic) CGPoint position;

- (id) initWithType:(BallType)aType;

- (void) moveByDeltaTime:(CGFloat)dt;

- (NSString*) description;

@end
