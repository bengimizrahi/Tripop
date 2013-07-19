//
//  GameModel.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameModel.h"

#import "BallMoveStrategy.h"
#import "Dynamite.h"
#import "Lightning.h"
#import "Ball.h"
#import "Hexagrid.h"
#import "Hexamesh.h"
#import "PowerBar.h"
#import "SpaceLayer.h"
#import "HexameshLayer.h"
#import "InfoLayer.h"
#import "ScoresLayer.h"
#import "Level.h"
#import "common.h"

@interface GameModel(Private)
- (void) __prepareLevels;
- (Ball*) __checkCollisionForBall:(Ball*)aBall collidePosition:(CGPoint*)aCollidePosition;
- (BOOL) __connectAttachedBall:(Ball*)aAttachedBall withFreeBall:(Ball*)aFreeBall;
- (void) __collapseUnconnectedBalls;
+ (NSArray*) __convertToNSArray:(BallType*)arr count:(int)n;
- (void) __destroy:(Sprite*)aSprite ball:(Ball*)aBall;
@end

@implementation GameModel

@synthesize freeBalls, attachedBalls, hexamesh, currentLevel;
@synthesize spaceLayer, hexameshLayer, infoLayer, scoresLayer;

- (id) init {
    if ((self = [super init])) {
        freeBalls = [[NSMutableArray alloc] init];
        attachedBalls = [[NSMutableArray alloc] init];
        poppingBalls = [[NSMutableArray alloc] init];
        hexamesh = [[Hexamesh alloc] initWithLevel:LEVEL];
        [attachedBalls addObject:hexamesh.center.ball];
        
        [self __prepareLevels];
        
        spaceLayer = [[SpaceLayer alloc] init];
        hexameshLayer = [[HexameshLayer alloc] init];
        infoLayer = [[InfoLayer alloc] init];
        scoresLayer = [[ScoresLayer alloc] init];

        ballsJustDestroyed = [[NSMutableArray alloc] init];
        [hexameshLayer addChild:hexamesh.center.ball.node];

        score = 0;
        hiScore = 0;
    }
    return self;
}

- (void) dealloc {
    [freeBalls release];
    [attachedBalls release];
    [poppingBalls release];
    [hexamesh release];
    
    [levels release];
    
    [spaceLayer release];
    [hexameshLayer release];
    [infoLayer release];
    [scoresLayer release];

    [ballsJustDestroyed release];
    [super dealloc];
}

- (void) powerActionRequested {
    if ([currentLevel powerActionRequested]) {
        infoLayer.powerBar.power = 0;
    }
}

NSMutableArray* convertToNSArray(BallType* arr, NSInteger n) {
    NSMutableArray* r = [[NSMutableArray alloc] init];
    for (int i = 0; i < n; ++i) {
        NSNumber* num = [NSNumber numberWithInt:arr[i]];
        [r addObject:num];
    }
    return [r autorelease];    
}

- (void) __prepareLevels {
    BallType ballTypes[4] = {BallType_Red, BallType_Green, BallType_Blue, BallType_Yellow};
    NSMutableArray* arr = shuffle(convertToNSArray(ballTypes, 4));
    
    Level* level1 = [[[Level alloc] initWithBallTypes:[arr subarrayWithRange:NSMakeRange(0, 2)] repeat:30 ballSpeed:70 createBallInterval:1.0f] autorelease];
    Level* level2 = [[[Level alloc] initWithBallTypes:[arr subarrayWithRange:NSMakeRange(0, 3)] repeat:30 ballSpeed:70 createBallInterval:1.0f] autorelease];
    Level* level3 = [[[Level alloc] initWithBallTypes:arr repeat:60 ballSpeed:70 createBallInterval:1.0f] autorelease];
    Level* level4 = [[[LevelWithDistinctBalls alloc] initWithBallTypes:arr repeat:60 ballSpeed:70 createBallInterval:1.0f] autorelease];
    NSArray* warmups = [[[NSArray alloc] initWithObjects:level1, level2, level3, level4, nil] autorelease];
    
    Level* level5 = [[[LevelWithSimultaneousBalls alloc] initWithBallTypes:arr repeat:30 ballSpeed:70 createBallInterval:2.0f simul:2] autorelease];
    Level* level6 = [[[LevelWithSimultaneousBalls alloc] initWithBallTypes:arr repeat:20 ballSpeed:70 createBallInterval:3.0f simul:3] autorelease];
    Level* level7 = [[[LevelWithSimultaneousBalls alloc] initWithBallTypes:arr repeat:30 ballSpeed:70 createBallInterval:2.0f simul:3] autorelease];
    Level* level8 = [[[LevelWithSimultaneousBalls alloc] initWithBallTypes:arr repeat:17 ballSpeed:70 createBallInterval:4.0f simul:4] autorelease];
    Level* level9 = [[[LevelWithSimultaneousBalls alloc] initWithBallTypes:arr repeat:20 ballSpeed:70 createBallInterval:3.0f simul:4] autorelease];
    Level* level10 = [[[LevelWithSimultaneousBalls alloc] initWithBallTypes:arr repeat:30 ballSpeed:70 createBallInterval:2.0f simul:4] autorelease];
    NSArray* simults = [[[NSArray alloc] initWithObjects:level5, level6, level7, level8, level9, level10, nil] autorelease];
    
    levels = [[NSMutableArray alloc] init];
    [levels addObjectsFromArray:warmups];
    [levels addObjectsFromArray:simults];
    
    currentLevel = [levels objectAtIndex:0];
}

- (void) startGame {
    [self schedule:@selector(step:)];
}

- (void) pauseGame {
    [self unschedule:@selector(step:)];
}

- (void) resumeGame {
    [self startGame];
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
    for (int i = 1; i < [attachedBalls count]; ++i) {
        Ball* b = [attachedBalls objectAtIndex:i];
        if (b.type != BallType_Core) {
            b.node.rotation = -1 * hexameshLayer.rotation;
        }
    }
    
    NSMutableArray* toBeRemovedFromFreeBalls = [[NSMutableArray alloc] init];
    for (Ball* freeBall in freeBalls) {
        [freeBall moveByDeltaTime:dt];
        CGPoint collidePosition;
        Ball* attachedBall = nil;
        if ((attachedBall = [self __checkCollisionForBall:freeBall collidePosition:&collidePosition])) {
            if (attachedBall.hexagrid.distance == LEVEL) {
                [self endGame];
            }
            [toBeRemovedFromFreeBalls addObject:freeBall];
            [spaceLayer removeChild:freeBall.node cleanup:YES];
            freeBall.position = collidePosition;
            if ([self __connectAttachedBall:attachedBall withFreeBall:freeBall]) {
                [attachedBalls addObject:freeBall];
                [hexameshLayer addChild:freeBall.node];
                [freeBall applyActionsAfterConnectingTo:attachedBall];
            } else {
                NSLog(@"cannot connect");
            }
        }
    }
    for (Ball* ball in toBeRemovedFromFreeBalls) {
        [freeBalls removeObject:ball];
    }
    [toBeRemovedFromFreeBalls release];
    if ([ballsJustDestroyed count] > 0) {
        [currentLevel ballsDestroyed:ballsJustDestroyed];
        [self __collapseUnconnectedBalls];
        [ballsJustDestroyed removeAllObjects];
    }
    [currentLevel execute:dt];
    if (currentLevel.expired) {
        [levels removeObjectAtIndex:0];
        NSAssert([levels count] > 0, @"We are out of 'levels'");
        currentLevel = [levels objectAtIndex:0];
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

- (void) addPointsToScore:(int)aPoints {
    score += aPoints;
    hiScore = MAX(score, hiScore);
    [infoLayer.scoreValueLabel setString:[NSString stringWithFormat:@"%08d", score]];
    [infoLayer.hiScoreValueLabel setString:[NSString stringWithFormat:@"%08d", hiScore]];
}

- (void) __collapseUnconnectedBalls {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:hexamesh.center, nil];
    NSMutableArray* connectedGrids = [[NSMutableArray alloc] initWithObjects:hexamesh.center, nil];
    hexamesh.center.dirty = YES;
    while ([arr count] > 0) {
        Hexagrid* h = [arr lastObject];
        [arr removeLastObject];
        for (Hexagrid* n in h.neighbours) {
            if (![n isEqual:[NSNull null]] && n.ball && !n.dirty) {
                [arr addObject:n];
                [connectedGrids addObject:n];
                n.dirty = YES;
            }
        }
    }
    NSMutableArray* temporaryArray = [[NSMutableArray alloc] init];
    for (Hexagrid* h in connectedGrids) {
        [temporaryArray addObject:h.ball];
        h.dirty = NO;
    }
    NSMutableSet* connectedBalls = [[NSMutableSet alloc] initWithArray:temporaryArray];
    [temporaryArray release];
    [connectedGrids release];    
    [arr release];

    NSMutableSet* temporarySet = [[NSMutableSet alloc] initWithArray:attachedBalls];
    [temporarySet minusSet:connectedBalls];
    NSMutableArray* disconnectedBalls = [[NSMutableArray alloc] initWithArray:[temporarySet allObjects]];
    [temporarySet release];
    
    if ([disconnectedBalls count] == 0) {
        goto end;
    }
    
    NSMutableArray* collapsingBalls = [[NSMutableArray alloc] initWithArray:disconnectedBalls];
    NSMutableSet* ballsToCheckForFurtherActions = [[NSMutableSet alloc] initWithArray:disconnectedBalls];
    [collapsingBalls sortUsingSelector:@selector(compare:)];
    
    while ([collapsingBalls count] > 0) {
        Ball* b = [collapsingBalls objectAtIndex:0];
        [collapsingBalls removeObject:b];
        BOOL touchesToAtLeastOneConnectedBall = NO;
        for (Hexagrid* n in b.hexagrid.neighbours) {
            if (![n isEqual:[NSNull null]] && n.ball && [connectedBalls member:n.ball]) {
                touchesToAtLeastOneConnectedBall = YES;
            }
        }
        if (touchesToAtLeastOneConnectedBall) {
            [connectedBalls addObject:b];
        } else {
            Hexagrid* closestGrid = nil;
            for (Hexagrid* n in b.hexagrid.neighbours) {
                if (![n isEqual:[NSNull null]]) {
                    if (!closestGrid) {
                        closestGrid = n;
                    } else {
                        if (n.distance < closestGrid.distance || ccpLength(n.position) < ccpLength(closestGrid.position)) {
                            closestGrid = n;
                        }
                    }
                }
            }
            if (!closestGrid.ball) {
                Hexagrid* oldH = b.hexagrid;
                oldH.ball = nil;
                closestGrid.ball = b;                
            }
            [collapsingBalls addObject:b];
        }
    }
    [collapsingBalls release];
    while ([ballsToCheckForFurtherActions count] > 0) {
        Ball* b = [ballsToCheckForFurtherActions anyObject];
        [ballsToCheckForFurtherActions removeObject:b];
        if (!b.isBeingDestroyed) {
            [b applyActionsAfterCollapsingTerminates];
        }
    }
    [ballsToCheckForFurtherActions release];
end:
    [disconnectedBalls release];
    [connectedBalls release];
}

- (void) __destroy:(Sprite*)aSprite ball:(Ball*)aBall {
    [ballsJustDestroyed addObject:aBall];
    [attachedBalls removeObject:aBall];
    [hexameshLayer removeChild:aSprite cleanup:YES];
    aBall.hexagrid.ball = nil;
}

@end
