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

@synthesize identifier, node, type, moveStrategy, hexagrid, isBeingDestroyed;
@dynamic position;
@synthesize __verticalDist, __horizontalDist, __actualDist;

- (id) initWithType:(BallType)aType {
    
    if ((self = [super init])) {
        static int nextId = 0;
        identifier = nextId++;
        static NSString* imageFiles[] = {@"Core.png", @"RedBall.png", @"GreenBall.png", @"BlueBall.png", @"YellowBall.png"};
        type = aType;
        if (type == BallType_FireBall) {
            node = [[ParticleSun alloc] init];
        } else {
            node = [[Sprite alloc] initWithFile:imageFiles[aType]];
        }
        prevPosition = node.position;
        isBeingDestroyed = NO;
    }
    return self;
}

- (void) dealloc {
    [node release];
    [moveStrategy release];
    
    [super dealloc];
}

- (void) moveByDeltaTime:(CGFloat)dt {
    [moveStrategy moveByDeltaTime:dt];
}

- (CGPoint) position {
    return node.position;
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
    CGPoint p = node.position;
    prevPosition = p;
    node.position = pos;
}

- (NSComparisonResult) compare:(Ball*)aBall {
    CGFloat l = ccpLength(self.position);
    CGFloat al = ccpLength(aBall.position);
    if (l < al) {
        return NSOrderedAscending;
    } else if (l > al) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSString*) description {
    NSString* dstr = @"";
    if (hexagrid && hexagrid.dirty) {
        dstr = @"/D";
    }
    CGPoint pos = node.position;
    if (hexagrid) {
        return [NSString stringWithFormat:@"<B%d:(≈%d,≈%d)-H%d%@-T%d>", identifier, (int)pos.x, (int)pos.y, hexagrid.identifier, dstr, type];
    } else {
        return [NSString stringWithFormat:@"<B%d:(≈%d,≈%d)----T%d>", identifier, (int)pos.x, (int)pos.y, type];
    }
}

@end
