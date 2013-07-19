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
#import "Hexamesh.h"
#import "GameModel.h"
#import "common.h"
#import "cocos2d.h"
#import "TripopAppDelegate.h"

static NSString* imageFiles[] = {@"Core.png", @"RedBall.png", @"GreenBall.png", @"BlueBall.png", @"YellowBall.png", @"Dynamite.png", @"Lightning.png"};

@implementation Ball

@synthesize identifier, node;
@synthesize points, power, type, moveStrategy, hexagrid, isBeingDestroyed;
@synthesize gameModel;
@dynamic position;
@synthesize __verticalDist, __horizontalDist, __actualDist;

- (id) initWithGameModel:(GameModel*)aGameModel {
    if ((self = [self initWithType:-1 gameModel:aGameModel])) {
    }
    return self;
}

- (id) initWithType:(BallType)aType gameModel:(GameModel*)aGameModel {
    if ((self = [super init])) {
        delegate = (TripopAppDelegate*)[UIApplication sharedApplication].delegate;
        gameModel = aGameModel;
        identifier = nextBallId++;
        prevPosition = node.position;
        isBeingDestroyed = NO;
        if (aType != -1) {
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

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeInt:identifier forKey:@"identifier"];
    [aCoder encodeCGPoint:node.position forKey:@"node.position"];
    [aCoder encodeInt:points forKey:@"points"];
    [aCoder encodeInt:power forKey:@"power"];
    [aCoder encodeInt:type forKey:@"type"];
    [aCoder encodeObject:moveStrategy forKey:@"moveStrategy"];
    [aCoder encodeObject:hexagrid forKey:@"hexagrid"];
    [aCoder encodeBool:isBeingDestroyed forKey:@"isBeingDestroyed"];
    
    [aCoder encodeObject:gameModel forKey:@"gameModel"];

    [aCoder encodeCGPoint:prevPosition forKey:@"prevPosition"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
        identifier = [aDecoder decodeIntForKey:@"identifier"];
        points = [aDecoder decodeIntForKey:@"points"];
        power = [aDecoder decodeIntForKey:@"power"];
        type = [aDecoder decodeIntForKey:@"type"];
        moveStrategy = [[aDecoder decodeObjectForKey:@"moveStrategy"] retain];
        hexagrid = [[aDecoder decodeObjectForKey:@"hexagrid"] retain];
        isBeingDestroyed = [aDecoder decodeBoolForKey:@"isBeingDestroyed"];
        
        gameModel = [aDecoder decodeObjectForKey:@"gameModel"];
        prevPosition = [aDecoder decodeCGPointForKey:@"prevPosition"];

        node = [[Sprite alloc] initWithFile:imageFiles[type]];
        node.position = [aDecoder decodeCGPointForKey:@"node.position"];
    }
    return self;
}

- (void) __destroy {
    [gameModel.ballsJustDestroyed addObject:self];
    [gameModel.attachedBalls removeObject:self];
    [gameModel.hexameshLayer removeChild:self.node cleanup:YES];
    self.hexagrid.ball = nil;
}

- (void) pauseActions {
}

- (void) resumeActions {
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
        [delegate playPopWithDelay:0.3f];
        for (Hexagrid* h in group) {
            [h.ball.node runAction:action_scaleToZeroThanDestroy(h.ball, gameModel)];
            h.ball.isBeingDestroyed = YES;
        }
    }
}

- (NSArray*) pathToCore {
    NSMutableArray* path = [[NSMutableArray alloc] init];
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:gameModel.hexamesh.center, nil];
    gameModel.hexamesh.center.dirty = YES;
    while ([arr count] > 0) {
        Hexagrid* h = [arr objectAtIndex:0];
        [arr removeObjectAtIndex:0];
        if (h.ball == self) {
            break;
        }
        for (Hexagrid* n in h.neighbours) {
            if (![n isEqual:[NSNull null]] && ![n isOutOfGameArea] && !n.dirty && n.ball) {
                n.__parent = h;
                n.dirty = YES;
                [arr addObject:n];
            }
        }
    }
    Hexagrid* cursor = self.hexagrid;
    while (cursor != gameModel.hexamesh.center) {
        [path addObject:cursor.ball];
        cursor = cursor.__parent;
    }
    for (Hexagrid* h in gameModel.hexamesh.hexagrids) {
        h.dirty = NO;
    }
    [arr release];
    return [path autorelease];
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
