//
//  Ball.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

#import "BallMoveStrategy.h"
#import "Hexagrid.h"
#import "common.h"
#import "cocos2d.h"

@implementation Ball

@synthesize identifier, sprite, type, moveStrategy, hexagrid, isBeingDestroyed;
@dynamic position;
@synthesize __verticalDist, __horizontalDist, __actualDist;

- (id) initWithType:(BallType)aType {
    if ((self = [super init])) {
        static int nextId = 0;
        identifier = nextId++;
        static NSString* imageFiles[] = {@"Core.png", @"RedBall.png", @"GreenBall.png", @"BlueBall.png", @"YellowBall.png"};
        type = aType;
        sprite = [[Sprite alloc] initWithFile:imageFiles[aType]];
        prevPosition = sprite.position;
        isBeingDestroyed = NO;
    }
    return self;
}

- (void) dealloc {
    [sprite release];
    [moveStrategy release];
    
    [super dealloc];
}

- (void) moveByDeltaTime:(CGFloat)dt {
    [moveStrategy moveByDeltaTime:dt];
}

- (CGPoint) position {
    return sprite.position;
}

- (CGPoint) positionOnLayer:(RotatingLayer*)aLayer {
    CGFloat angle = CC_DEGREES_TO_RADIANS(aLayer.rotation);
    CGPoint r = ccpRotate(ccpForAngle(angle), self.position);
    return r;
}

- (CGPoint) prevPositionOnLayer:(RotatingLayer*)aLayer {
    CGFloat angle = CC_DEGREES_TO_RADIANS(aLayer.prevRotation);
    CGPoint r = ccpRotate(ccpForAngle(angle), prevPosition);
    return r;
}

- (void) setPosition:(CGPoint)pos {
    CGPoint p = sprite.position;
    prevPosition = p;
    sprite.position = pos;
}

- (NSString*) description {
    NSString* dstr = @"";
    if (hexagrid && hexagrid.dirty) {
        dstr = @"/D";
    }
    CGPoint pos = sprite.position;
    if (hexagrid) {
        return [NSString stringWithFormat:@"<B%d:(≈%d,≈%d)-H%d%@-T%d>", identifier, (int)pos.x, (int)pos.y, hexagrid.identifier, dstr, type];
    } else {
        return [NSString stringWithFormat:@"<B%d:(≈%d,≈%d)----T%d>", identifier, (int)pos.x, (int)pos.y, type];
    }
}

@end
