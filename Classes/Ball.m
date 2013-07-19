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
#import "Level.h"
#import "GameModel.h"
#import "common.h"
#import "cocos2d.h"

@implementation Ball

@synthesize identifier, node;
@synthesize points, power, type, moveStrategy, hexagrid, isBeingDestroyed;
@dynamic position;
@synthesize __verticalDist, __horizontalDist, __actualDist;

- (id) init {
    if ((self = [self initWithType:-1])) {
    }
    return self;
}

- (id) initWithType:(BallType)aType {
    if ((self = [super init])) {
        static int nextId = 0;
        identifier = nextId++;
        prevPosition = node.position;
        isBeingDestroyed = NO;
        if (aType != -1) {
            static NSString* imageFiles[] = {@"Core.png", @"RedBall.png", @"GreenBall.png", @"BlueBall.png", @"YellowBall.png", @"Dynamite.png", @"Lightning.png"};
            type = aType;
            node = [[Sprite alloc] initWithFile:imageFiles[aType]];
        }
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

- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall {
    [self applyActionsAfterCollapsingTerminates];
}

- (void) applyActionsAfterCollapsingTerminates {
    NSArray* group = [hexagrid sameColorGroup];
    if ([group count] >=3) {
        for (Hexagrid* h in group) {
            [h.ball.node runAction:action_scaleToZeroThanDestroy(h.ball)];
            h.ball.isBeingDestroyed = YES;
        }
    }
}

- (NSArray*) randomPathToCore {
    NSMutableArray* pathToCore = [[NSMutableArray alloc] init];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    Ball* b = self;
    while (b.type != BallType_Core) {
        [pathToCore addObject:b];
        int minDistance = LEVEL+1;
        for (Hexagrid* h in b.hexagrid.neighbours) {
            if (![h isEqual:[NSNull null]] && h.ball) {
                if (h.distance < minDistance) {
                    minDistance = h.distance;
                }
            }
        }
        for (Hexagrid* h in b.hexagrid.neighbours) {
            if (![h isEqual:[NSNull null]] && h.ball) {
                if (h.distance == minDistance) {
                    [arr addObject:h];
                }
            }
        }
        b = ((Hexagrid*)randomChoice(arr)).ball;
        [arr removeAllObjects];
    }
    [arr release];
    return [pathToCore autorelease];    
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
