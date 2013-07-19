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
#import "BackgroundLayer.h"
#import "ScoresLayer.h"
#import "MainMenuLayer.h"
#import "LevelDirector.h"
#import "TripopAppDelegate.h"
#import "common.h"
#import "SimpleAudioEngine.h"

@interface GameModel(Private)
- (Ball*) __checkCollisionForBall:(Ball*)aBall collidePosition:(CGPoint*)aCollidePosition;
- (BOOL) __connectAttachedBall:(Ball*)aAttachedBall withFreeBall:(Ball*)aFreeBall;
- (void) __collapseUnconnectedBalls;
@end

@implementation GameModel

@synthesize freeBalls, attachedBalls, hexamesh, levelDirector;
@synthesize spaceLayer, hexameshLayer, infoLayer, scoresLayer;
@synthesize ballsJustDestroyed;
@synthesize gameIsOver;
@synthesize __isRunning;

- (id) init {
    return [self initWithFile:nil];
}

- (id) initWithFile:(NSString*)aFile {
    if ((self = [super init])) {
        delegate = (TripopAppDelegate*)[UIApplication sharedApplication].delegate;
        freeBalls = [[NSMutableArray alloc] init];
        attachedBalls = [[NSMutableArray alloc] init];
        hexamesh = [[Hexamesh alloc] initWithLevel:LEVEL file:aFile gameModel:self];
        Ball* ball = [[Ball alloc] initWithType:BallType_Core gameModel:self];
        hexamesh.center.ball = ball;
        [ball release];
        [attachedBalls addObject:hexamesh.center.ball];
        
        levelDirector = [[StandardLevelDirector alloc] init];
        
        spaceLayer = [[SpaceLayer alloc] init];
        hexameshLayer = [[HexameshLayer alloc] initWithGameModel:self];
        infoLayer = [[InfoLayer alloc] init];
        scoresLayer = [[ScoresLayer alloc] init];

        ballsJustDestroyed = [[NSMutableArray alloc] init];
        [hexameshLayer addChild:hexamesh.center.ball.node];

        gameIsOver = NO;
        score = 0;
        hiscoreBeforeThisGame = hiscore;
    }
    return self;
}

- (void) dealloc {
    [freeBalls release];
    [attachedBalls release];
    [hexamesh release];
    
    [levelDirector release];
    
    [spaceLayer release];
    [hexameshLayer release];
    [infoLayer release];
    [scoresLayer release];

    [ballsJustDestroyed release];
    [super dealloc];
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:freeBalls forKey:@"freeBalls"];
    [aCoder encodeObject:attachedBalls forKey:@"attachedBalls"];
    [aCoder encodeObject:hexamesh forKey:@"hexamesh"];
    [aCoder encodeObject:levelDirector forKey:@"levelDirector"];
    [aCoder encodeObject:hexameshLayer forKey:@"hexameshLayer"];
    [aCoder encodeFloat:infoLayer.powerBar.power forKey:@"infoLayer.powerBar.power"];
    [aCoder encodeInt:score forKey:@"score"];
    [aCoder encodeInt:hiscoreBeforeThisGame forKey:@"hiscoreBeforeThisGame"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
        delegate = (TripopAppDelegate*)[UIApplication sharedApplication].delegate;
        freeBalls = [[aDecoder decodeObjectForKey:@"freeBalls"] retain];
        attachedBalls = [[aDecoder decodeObjectForKey:@"attachedBalls"] retain];
        hexamesh = [[aDecoder decodeObjectForKey:@"hexamesh"] retain];
        levelDirector = [[aDecoder decodeObjectForKey:@"levelDirector"] retain];

        spaceLayer = [[SpaceLayer alloc] init];
        for (Ball* b in freeBalls) {
            [spaceLayer addChild:b.node];
        }
        hexameshLayer = [[aDecoder decodeObjectForKey:@"hexameshLayer"] retain];
        for (Ball* b in attachedBalls) {
            [hexameshLayer addChild:b.node];
        }
        infoLayer = [[InfoLayer alloc] init];
        infoLayer.powerBar.power = [aDecoder decodeFloatForKey:@"infoLayer.powerBar.power"];
        scoresLayer = [[ScoresLayer alloc] init];
        
        ballsJustDestroyed = [[NSMutableArray alloc] init];
        
        score = [aDecoder decodeIntForKey:@"score"];
        hiscoreBeforeThisGame = [aDecoder decodeIntForKey:@"hiscoreBeforeThisGame"];
        
        // post-processing
        gameIsOver = NO;
        for (Ball* b in attachedBalls) {
            if (b.isBeingDestroyed) {
                [b.node runAction:action_scaleToZeroThanDestroy(b, self)];
                nextBallId = MAX(nextBallId, b.identifier);
            }
        }
        for (Hexagrid* h in hexamesh.hexagrids) {
            nextHexagridId = MAX(nextHexagridId, h.identifier);
        }
        nextHexagridId++;
        [self __collapseUnconnectedBalls];
    }
    return self;
}

- (void) powerActionRequested {
    if ([levelDirector powerActionRequested:self]) {
        infoLayer.powerBar.power = 0;
    }
}

- (void) startGame {
    __isRunning = YES;
    [self schedule:@selector(step:)];
}

- (void) startGameWithDelay:(ccTime)aDelay {
    [self runAction:[Sequence actions:[DelayTime actionWithDuration:aDelay], [CallFuncN actionWithTarget:self selector:@selector(startGame)], nil]];
}

- (void) pauseGame {
    __isRunning = NO;
    [self unschedule:@selector(step:)];
    for (Ball* b in freeBalls) {
        [b pauseActions];
    }
    for (Ball* b in attachedBalls) {
        [b pauseActions];
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Game paused"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Resume", @"Menu", nil];
    alertView.tag = ALERTVIEW_GAME_PAUSED;
    [alertView show];
}

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERTVIEW_GAME_PAUSED) {
        if (buttonIndex == 0) {
            [self resumeGame];
        } else if (buttonIndex == 1) {
            Scene* scene = [Scene node];
            [scene addChild:[BackgroundLayer node]];
            InfoLayer* infoLayerr = [InfoLayer node];
            [infoLayerr convertToDemoMode];
            [scene addChild:infoLayerr];
            [scene addChild:[MainMenuLayer node]];
            TransitionScene* transitionScene = [FadeTransition transitionWithDuration:1.0f scene:scene withColor:ccBLACK];
            [[Director sharedDirector] replaceScene: transitionScene];
        }
    }
    [alertView release];
}

- (void) resumeGame {
    for (Ball* b in freeBalls) {
        [b resumeActions];
    }
    for (Ball* b in attachedBalls) {
        [b resumeActions];
    }
    [self startGame];
}

- (void) resumeGameWithDelay:(ccTime)aDelay {
    [self runAction:[Sequence actions:[DelayTime actionWithDuration:aDelay], [CallFuncN actionWithTarget:self selector:@selector(resumeGame)], nil]];
}

- (void) endGame {
    gameIsOver = YES;
    __isRunning = NO;
    [self unschedule:@selector(step:)];
        
    NSString* message;
    if (score > hiscoreBeforeThisGame) {
        message = [NSString stringWithFormat:@"New Record! Your final score is %d", score];
    } else {
        message = [NSString stringWithFormat:@"Your final score is %d", score];
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                         message:message
                                                        delegate:delegate
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"Ok", nil];
    alertView.tag = ALERTVIEW_GAME_ENDED;
    [alertView show];
}

- (void) step:(CGFloat)dt {
    if (!__isRunning) {
        return;
    }
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
            [toBeRemovedFromFreeBalls addObject:freeBall];
            [spaceLayer removeChild:freeBall.node cleanup:YES];
            freeBall.position = collidePosition;
            [delegate playConnect];
            if ([self __connectAttachedBall:attachedBall withFreeBall:freeBall]) {
                [attachedBalls addObject:freeBall];
                [hexameshLayer addChild:freeBall.node];
                if (freeBall.hexagrid.distance > LEVEL && 1 <= freeBall.type && freeBall.type <= 4) {
                    [self endGame];
                    [freeBall.node runAction:[RepeatForever actionWithAction:[Blink actionWithDuration:0.5f blinks:1]]];
                    return;
                }                
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
        [self ballsDestroyed:ballsJustDestroyed];
        [self __collapseUnconnectedBalls];
        [ballsJustDestroyed removeAllObjects];
    }
    [levelDirector execute:dt gameModel:self];
}

- (void) ballsDestroyed:(NSArray*)aBalls {
    if ([aBalls count] == 1) {
        Ball* b = [aBalls objectAtIndex:0];
        if (!(1 <= b.type && b.type <= 4)) {
            return;
        }
    }   
    int totalPointsEarned = 0;
    CGFloat totalPowerEarned = 0.0f;
    for (Ball* b in aBalls) {
        totalPointsEarned += b.points;
        totalPowerEarned += b.power;
    }
    totalPowerEarned = 5*powf(MAX(totalPowerEarned - 2.0f, 0.0f), 2);
    [infoLayer.powerBar addPower:totalPowerEarned];
    [scoresLayer addPoints:totalPointsEarned animateAtPosition:centerPosition(aBalls, hexameshLayer.rotation) duration:0.4f scaleBy:2.0f];
    [self addPointsToScore:totalPointsEarned];
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
    int nb_idx = 0;
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
    hiscore = MAX(score, hiscore);
    [infoLayer.scoreValueLabel setString:[NSString stringWithFormat:@"%08d", score]];
    [infoLayer.hiScoreValueLabel setString:[NSString stringWithFormat:@"%08d", hiscore]];
}

- (void) __collapseUnconnectedBalls {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:hexamesh.center, nil];
    NSMutableArray* connectedGrids = [[NSMutableArray alloc] initWithObjects:hexamesh.center, nil];
    hexamesh.center.dirty = YES;
    while ([arr count] > 0) {
        Hexagrid* h = [arr lastObject];
        [arr removeLastObject];
        for (Hexagrid* n in h.neighbours) {
            if (![n isOutOfGameArea] && n.ball && !n.dirty) {
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
    
    int numUnDestroyedConnectedBalls = 0;
    while ([collapsingBalls count] > 0) {
        Ball* b = [collapsingBalls objectAtIndex:0];
        if (!b.isBeingDestroyed) {
            numUnDestroyedConnectedBalls += 1;
        }
        [collapsingBalls removeObject:b];
        BOOL touchesToAtLeastOneConnectedBall = NO;
        for (Hexagrid* n in b.hexagrid.neighbours) {
            if (![n isOutOfGameArea] && n.ball && [connectedBalls member:n.ball]) {
                touchesToAtLeastOneConnectedBall = YES;
            }
        }
        if (touchesToAtLeastOneConnectedBall) {
            [connectedBalls addObject:b];
        } else {
            Hexagrid* closestGrid = nil;
            for (Hexagrid* n in b.hexagrid.neighbours) {
                if (![n isOutOfGameArea]) {
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
    if (numUnDestroyedConnectedBalls > 0) {
        [delegate playCollapse];
    }

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

@end
