//
//  Hexamesh.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Hexamesh.h"

#import "Ball.h"
#import "Hexagrid.h"
#import "common.h"
#import "cocos2d.h"

@interface Hexamesh(Private)

- (void) __setDistances:(NSArray*)arrayx vDist:(int)vdist;
- (void) __connect2and5:(NSArray*)arrayx;
- (void) __connect1and4:(NSArray*)arrayx_l :(NSArray*)arrayx_u offsetl:(int)offsetl offsetu:(int)offsetu;
- (void) __connect0and3:(NSArray*)arrayx_l :(NSArray*)arrayx_u offsetl:(int)offsetl offsetu:(int)offsetu;
- (void) __setPositions;
- (void) __resetDirty;

- (void) __listRetainCounts;


@end

@implementation Hexamesh

@synthesize level, center, rings, hexagrids;

- (void) __listRetainCounts {
    NSMutableString* str = [[NSMutableString alloc] init];
    for (Hexagrid* h in hexagrids) {
        [str appendFormat:@"%d", [h retainCount]];
    }
    CCLOG(str);
}

- (id) initWithLevel:(int)aLevel {
    if ((self = [super init])) {
        level = aLevel;
        hexagrids = [[NSMutableArray alloc] init];
        
        NSMutableArray* arrayy = [[NSMutableArray alloc] init];
        NSMutableArray* last_arrayx = nil;
        for (int i = level + 1; i < 2 * (level + 1); ++i) {
            NSMutableArray* arrayx = [[NSMutableArray alloc] init];
            for (int j = 0; j < i; ++j) {
                Hexagrid* h = [[Hexagrid alloc] init];
                [hexagrids addObject:h];
                [arrayx addObject:h];
                [h release];
            }
            [self __setDistances:arrayx vDist:2*(level+1)-1-i];
            [self __connect2and5:arrayx];
            if (last_arrayx != nil) {
                [self __connect1and4:last_arrayx :arrayx offsetl:0 offsetu:0];
                [self __connect0and3:last_arrayx :arrayx offsetl:0 offsetu:1];
            }
            [last_arrayx release];
            last_arrayx = arrayx;
            [arrayy addObject:arrayx];
        }
        for (int i = 2*level; i > level; --i) {
            NSMutableArray* arrayx = [[NSMutableArray alloc] init];
            for (int j = 0; j < i; ++j) {
                Hexagrid* h = [[Hexagrid alloc] init];
                [hexagrids addObject:h];
                [arrayx addObject:h];
                [h release];
            }
            [self __setDistances:arrayx vDist:2*(level+1)-1-i];
            [self __connect2and5:arrayx];
            [self __connect1and4:last_arrayx :arrayx offsetl:1 offsetu:0];
            [self __connect0and3:last_arrayx :arrayx offsetl:0 offsetu:0];
            [last_arrayx release];
            last_arrayx = arrayx;
            [arrayy addObject:arrayx];
        }
        [last_arrayx release];
        Hexagrid* h = [[arrayy objectAtIndex:0] objectAtIndex:0];
        for (int i = 0; i < level; ++i) {
            h = [h.neighbours objectAtIndex:0];
        }
        center = h;
        [arrayy release];
        
        [self __setPositions];
        Ball* ball = [[Ball alloc] initWithType:BallType_Core];
        center.ball = ball;
        [ball release];

        rings = [[NSMutableArray alloc] init];
        for (int lev = 1; lev <= level; ++lev) {
            Hexagrid* cursor = center;
            for (int i = 0; i < lev; ++i) {
                cursor = [cursor.neighbours objectAtIndex:0];
            }
            int nb_idxes[6] = {4, 3, 2, 1, 0, 5};
            NSMutableArray* ring = [[NSMutableArray alloc] init];
            for (int i = 0; i < 6; ++i) {
                int nb_idx = nb_idxes[i];
                for (int j = 0; j < lev; ++j) {
                    cursor = [cursor.neighbours objectAtIndex:nb_idx];
                    [ring addObject:cursor];
                }
            }
            [rings addObject:ring];
            [ring release];
        }
    }   
    return self;
}

- (void) dealloc {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:center, nil];
    while ([arr count] > 0) {
        Hexagrid* h = [arr lastObject];
        [arr removeLastObject];
        for (int nb_idx = 0; nb_idx < [h.neighbours count]; ++nb_idx) {
            Hexagrid* n = [h.neighbours objectAtIndex:nb_idx];
            if ([n isEqual:[NSNull null]] == NO) {
                [arr addObject:n];
            }
        }
        h.neighbours = nil;
    }
    [arr release];
    [rings release];
    [hexagrids release];
    [center release];
    
    [super dealloc];
}

- (void) __setDistances:(NSArray*)arrayx vDist:(int)vdist {
    int sub = level - vdist;
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < sub; ++i) {
        [arr addObject:[NSNumber numberWithInt:level - i]];
    }
    for (int i = 0; i < [arrayx count] - 2*sub - 1; ++i) {
        [arr addObject:[NSNumber numberWithInt:level - sub]];
    }
    for (int i = sub; i >= 0; --i) {
        [arr addObject:[NSNumber numberWithInt:level - i]];
    }
    for (int i = 0; i < [arrayx count]; ++i) {
        Hexagrid* hexagrid = [arrayx objectAtIndex:i];
        hexagrid.distance = [[arr objectAtIndex:i] intValue];
    }
}

- (void) __connect2and5:(NSArray*)arrayx {
    NSAssert([arrayx count] > 0, @"arrayx is empty.");
    for (int i = 0; i < [arrayx count] - 1; ++i) {
        Hexagrid* h1 = [arrayx objectAtIndex:i];
        Hexagrid* h2 = [arrayx objectAtIndex:i + 1];
        [h1.neighbours replaceObjectAtIndex:5 withObject:h2];
        [h2.neighbours replaceObjectAtIndex:2 withObject:h1];
    }
}

- (void) __connect1and4:(NSArray*)arrayx_l :(NSArray*)arrayx_u offsetl:(int)offsetl offsetu:(int)offsetu {
    NSAssert([arrayx_l count] + offsetl > 0, @"");
    NSAssert([arrayx_u count] + offsetu > 0, @"");
    int i = 0;
    while (i < MIN([arrayx_l count], [arrayx_u count])) {
        Hexagrid* hl = [arrayx_l objectAtIndex:i + offsetl];
        Hexagrid* hu = [arrayx_u objectAtIndex:i + offsetu];
        [hl.neighbours replaceObjectAtIndex:1 withObject:hu];
        [hu.neighbours replaceObjectAtIndex:4 withObject:hl];
        i += 1;
    }
}

- (void) __connect0and3:(NSArray*)arrayx_l :(NSArray*)arrayx_u offsetl:(int)offsetl offsetu:(int)offsetu {
    NSAssert([arrayx_l count] + offsetl > 0, @"");
    NSAssert([arrayx_u count] + offsetu > 0, @"");
    int i = 0;
    while (i < MIN([arrayx_l count], [arrayx_u count])) {
        Hexagrid* hl = [arrayx_l objectAtIndex:i + offsetl];
        Hexagrid* hu = [arrayx_u objectAtIndex:i + offsetu];
        [hl.neighbours replaceObjectAtIndex:0 withObject:hu];
        [hu.neighbours replaceObjectAtIndex:3 withObject:hl];
        i += 1;
    }
}

- (void) __setPositions {
    self.center.position = ccp(0, 0);
    NSMutableArray* arr = [NSMutableArray arrayWithObject:center];
    while ([arr count] > 0) {
        Hexagrid* h = [arr lastObject];
        [arr removeLastObject];
        for (int nb_idx = 0; nb_idx < [h.neighbours count]; ++nb_idx) {
            Hexagrid* n = [h.neighbours objectAtIndex:nb_idx];
            if ([n isEqual:[NSNull null]] == NO && n.dirty == NO) {
                CGPoint relPos = relPos6[nb_idx];
                n.position = ccpAdd(h.position, relPos);
                n.dirty = YES;
                [arr addObject:n];
            }
        }
    }
    [self __resetDirty];
}

- (void) __resetDirty {
    for (Hexagrid* h in hexagrids) {
        h.dirty = NO;
    }
}

@end
