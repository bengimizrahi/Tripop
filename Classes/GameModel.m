//
//  GameModel.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameModel.h"

#import "Ball.h"
#import "Hexagrid.h"
#import "Hexamesh.h"
#import "HexameshLayer.h"
#import "SpaceLayer.h"
//#import "InfoLayer.h"
#import "Level.h"
#import "common.h"

@interface GameModel(Private)
- (void) __prepareLevels;
- (Ball*) __checkCollisionForBall:(Ball*)aBall collidePosition:(CGPoint*)aCollidePosition;
- (BOOL) __connectAttachedBall:(Ball*)aAttachedBall withFreeBall:(Ball*)aFreeBall;
- (NSArray*) __convertToNSArray:(BallType*)arr count:(int)n;
@end

@implementation GameModel

@synthesize freeBalls, attachedBalls, hexamesh, levels;
@synthesize /*infoLayer, */hexameshLayer, spaceLayer;

- (id) init {
    if ((self = [super init])) {
        freeBalls = [[NSMutableArray alloc] init];
        attachedBalls = [[NSMutableArray alloc] init];
        poppingBalls = [[NSMutableArray alloc] init];
        hexamesh = [[Hexamesh alloc] initWithLevel:LEVEL];
        [attachedBalls addObject:hexamesh.center.ball];
        
        [self __prepareLevels];
        
        spaceLayer = [[SpaceLayer node] retain];
        hexameshLayer = [[HexameshLayer node] retain];
        [hexameshLayer addChild:hexamesh.center.ball.sprite];
//      infoLayer = [[InfoLayer node] retain];
    }
    return self;
}

- (void) dealloc {
    [freeBalls release];
    [attachedBalls release];
    [poppingBalls release];
    [hexamesh release];
    [levels release];

    [super dealloc];
}

- (void) __prepareLevels {
    BallType ballTypes[4] = {BallType_Red, BallType_Green, BallType_Blue, BallType_Yellow};
    
    levels = [[NSMutableArray alloc] init];
    
    NSArray* ballTypeList = [self __convertToNSArray:ballTypes count:4];
    Level* level1 = [[Level alloc] initWithBallTypes:ballTypeList repeat:130 ballSpeed:70 createBallInterval:1.0f];
    [levels addObject:level1];
    
    currentLevel = [levels objectAtIndex:0];
    currentLevel.gameModel = self;
}

- (void) startGame {
    [self schedule:@selector(step:)];
}

- (void) endGame {
    CCLOG(@"GAME OVER");
}

- (void) step:(CGFloat)dt {
    if (dt == 0.0f) {
        CCLOG(@"dt = 0.0f, do nothing");
        return;
    } else {
        CCLOG(@"dt = %.2f", dt);
    }
    [hexameshLayer updateRotation];
    
    NSMutableArray* toBeRemovedFromFreeBalls = [[NSMutableArray alloc] init];
    for (Ball* freeBall in freeBalls) {
        [freeBall moveByDeltaTime:dt];
        CGPoint collidePosition;
        Ball* attachedBall = nil;
        if ((attachedBall = [self __checkCollisionForBall:freeBall collidePosition:&collidePosition])) {
            if (freeBall.ballAction) {
                // apply ball action
            } else {
                if (attachedBall.hexagrid.distance == LEVEL) {
                    [self endGame];
                }
                [toBeRemovedFromFreeBalls addObject:freeBall];
                [spaceLayer removeChild:freeBall.sprite cleanup:YES];
                freeBall.position = collidePosition;
                if ([self __connectAttachedBall:attachedBall withFreeBall:freeBall]) {
                    [attachedBalls addObject:freeBall];
                    [hexameshLayer addChild:freeBall.sprite];
                    NSArray* group = [freeBall.hexagrid sameColorGroup];
                }
            }
        }
    }
    for (Ball* ball in toBeRemovedFromFreeBalls) {
        [freeBalls removeObject:ball];
    }
    [toBeRemovedFromFreeBalls release];
    
    [currentLevel execute:dt];
    if (currentLevel.expired) {
        [levels removeObjectAtIndex:0];
        NSAssert([levels count] > 0, @"We are out of 'levels'");
        currentLevel = [levels objectAtIndex:0];
        currentLevel.gameModel = self;
    }
}

- (Ball*) __checkCollisionForBall:(Ball*)aBall collidePosition:(CGPoint*)aCollidePosition {
    CGPoint pos = [aBall positionOnLayer:hexameshLayer];
    CGPoint prevPos = [aBall prevPositionOnLayer:hexameshLayer];
    CGFloat d = ccpDistance(pos, prevPos);
    
    Ball* candidateBall = nil;
    for (Ball* attBall in attachedBalls) {
        CCLOG(@"Checking attBall=%@ for collision with freeBall=%@", attBall, aBall);
        CGFloat vd, hd, ad; {
            pdis(pos, prevPos, attBall.position, d, &vd, &hd, &ad);
            attBall.__actualDist = ad;
            CCLOG(@"d, vd, hd, ad = %.2f, %.2f, %.2f, %.2f", d, vd, hd, ad);
        }
        if (attBall.__actualDist != FLT_MAX) {
            CCLOG(@"ad=%.2f", ad);
            if (candidateBall == nil || ad < candidateBall.__actualDist) {
                if (candidateBall) {
                    CCLOG(@"ad(%.2f) < candidateBall.__actualDist(%.2f)", ad, candidateBall.__actualDist);
                } else {
                    CCLOG(@"candidateBall == nil");
                }
                if (d > ad) {
                    CCLOG(@"d(%.2f) > ad(%.2f)", d, ad);
                    CCLOG(@"new candidate ball: %@", attBall);
                    candidateBall = attBall;
                } else {
                    CCLOG(@"dd(%.2f) <= ad(%.2f)", d, ad);
                    CCLOG(@"candidate ball is still: %@", candidateBall);
                }
            } else {
                CCLOG(@"ad >= candidateBall.__actualDist(%.2f). Skipping attBall(%s)", candidateBall.__actualDist, attBall);
            }
        } else {
            CCLOG(@"attBall.__actualDist is FLT_MAX");
        }
        CCLOG(@"\n---next candidate---");
    }
    CCLOG(@"Final candidate ball: %@", candidateBall);
    CCLOG(@"");
    if (candidateBall) {
        NSAssert1(candidateBall.__actualDist != FLT_MAX, @"%@.__actualDist=FLT_MAX", candidateBall);
        *aCollidePosition = ccpMult(ccpAdd(ccpMult(ccpSub(pos, prevPos), candidateBall.__actualDist), ccpMult(prevPos, d)), 1.0f/d);
    } else {
        CCLOG(@"final position becomes(aCollidePosition): %@", CGPointDescription(*aCollidePosition));
    }
    return candidateBall;
}

- (BOOL) __connectAttachedBall:(Ball*)aAttachedBall withFreeBall:(Ball*)aFreeBall {
    CGPoint p1 = aAttachedBall.position;
    CGPoint p2 = aFreeBall.position;
    CGFloat angle = angleBetween(p1, p2);
    CGPoint p = ccpSub(p2, p1);
    int nb_idx;
    if (p.x >= 0 && p.y >= 0 && 0 <= angle && angle <= M_PI_3) nb_idx = 0;
    else if (p.y >= 0 && M_PI_3 <= angle && angle <= 2*M_PI_3) nb_idx = 1;
    else if (p.x <= 0 && p.y >= 0 && 2*M_PI_3 <= angle && angle <= M_PI) nb_idx = 2;
    else if (p.x <= 0 && p.y <= 0 && M_PI <= angle && angle <= 4*M_PI_3) nb_idx = 3;
    else if (p.y <= 0 && 4*M_PI_3 <= angle && angle <= 5*M_PI_3) nb_idx = 4;
    else if (p.y <= 0 && 5*M_PI_3 <= angle && angle <= 2*M_PI) nb_idx = 5;
    else {
        NSString* errStr = [NSString stringWithFormat:@"connect error %@ angle=%.2f", CGPointDescription(p), angle];
        NSAssert(NO, errStr);
    }
    Hexagrid* nb_hexagrid = [aAttachedBall.hexagrid.neighbours objectAtIndex:nb_idx];
    //NSAssert (nb_hexagrid.ball == None, @"Can't connect, there is a ball %@ in %@", nb_hexagrid.ball, nb_hexagrid);
    if (nb_hexagrid.ball) {
        [aFreeBall moveByDeltaTime:-1.0f];
        return NO;
    }
    nb_hexagrid.ball = aFreeBall;
    aFreeBall.moveStrategy = nil;
    return YES;
}

- (NSArray*) __convertToNSArray:(BallType*)arr count:(int)n {
    NSMutableArray* r = [[NSMutableArray alloc] init];
    for (int i = 0; i < n; ++i) {
        NSNumber* num = [NSNumber numberWithInt:arr[i]];
        [r addObject:num];
    }
    return [r autorelease];
}

@end
