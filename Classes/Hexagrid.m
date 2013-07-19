//
//  Hexagrid.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Hexagrid.h"

#import "Ball.h"
#import "common.h"
#import "cocos2d.h"

@implementation Hexagrid

@synthesize identifier, ball, neighbours, dirty, distance, position;
@synthesize __ringDistance;

- (id) init {
    if ((self = [super init])) {
        identifier = nextHexagridId++;
        self.neighbours = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
        dirty = NO;
    }
    return self;
}

- (void) dealloc {
    [ball release];
    [neighbours release];
    
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeInt:identifier forKey:@"identifier"];
    [aCoder encodeObject:ball forKey:@"ball"];
    [aCoder encodeObject:neighbours forKey:@"neighbours"];
    // ignore dirty
    [aCoder encodeInt:distance forKey:@"distance"];
    [aCoder encodeCGPoint:position forKey:@"position"];
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
        identifier = [aDecoder decodeIntForKey:@"identifier"];
        ball = [[aDecoder decodeObjectForKey:@"ball"] retain];
        neighbours = [[aDecoder decodeObjectForKey:@"neighbours"] retain];
        dirty = NO;
        distance = [aDecoder decodeIntForKey:@"distance"];
        position = [aDecoder decodeCGPointForKey:@"position"];
    }
    return self;
}

- (void) setBall:(Ball*)aBall {
    if (ball) {
        ball.hexagrid = nil;
        [ball release];
    }
    ball = [aBall retain];
    ball.position = self.position;
    ball.hexagrid = self;
}

- (NSArray*) sameColorGroup {
    NSAssert(ball, @"no ball in my hexagrid");
    dirty = YES;
    NSMutableArray* group = [[NSMutableArray alloc] initWithObjects:self, nil];
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:self, nil];
    int num = 1;
    while ([arr count] > 0) {
        Hexagrid* h = [arr lastObject];
        [arr removeLastObject];
        for (Hexagrid* n in h.neighbours) {
            if ((![n isNull]) && n.ball && (!n.ball.isBeingDestroyed) && n.ball.type == ball.type && (!n.dirty)) {
                [arr addObject:n];
                [group addObject:n];
                n.dirty = YES;
                num += 1;
            }
        }
    }
    for (Hexagrid* h in group) {
        h.dirty = NO;
    }
    [arr release];
    return [group autorelease];
}

- (NSArray*) ringsToLevel:(int)aLevel {
    NSMutableArray* rings = [[NSMutableArray alloc] init];
    for (int i = 0; i < aLevel; ++i) {
        NSMutableArray* ring = [[NSMutableArray alloc] init];
        [rings addObject:ring];
        [ring release];
    }
    self.__ringDistance = 0;
    self.dirty = YES;
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:self, nil];
    while ([arr count] > 0) {
        Hexagrid* h = [arr objectAtIndex:0];
        [arr removeObjectAtIndex:0];
        if (h.__ringDistance < aLevel) {
            [[rings objectAtIndex:h.__ringDistance] addObject:h];
            for (Hexagrid* n in h.neighbours) {
                if (![n isNull] && !n.dirty) {
                    n.__ringDistance = h.__ringDistance + 1;
                    n.dirty = YES;
                    [arr addObject:n];
                }
            }
        }
    }
    [arr release];
    for (NSArray* ring in rings) {
        for (Hexagrid* h in ring) {
            h.dirty = NO;
        }
    }
    return [rings autorelease];
}

- (BOOL) isNull {
    return distance == LEVEL + 1;
}

- (NSString*) description {
    NSString* dstr = @"";
    if (dirty) {
        dstr = @"/D";
    }
    if (ball) {
        return [NSString stringWithFormat:@"[H:%d-B%d%@]", identifier, ball.identifier, dstr];
    } else {
        return [NSString stringWithFormat:@"[H:%d---%@]", identifier, dstr];
    }
}

@end
