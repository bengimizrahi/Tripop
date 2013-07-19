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

- (id) init {
    if ((self = [super init])) {
        static int nextId = 0;
        identifier = nextId++;
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

- (void) setBall:(Ball*)aBall {
    if (ball) {
        ball.hexagrid = nil;
        [ball release];
    }
    ball = [aBall retain];
    ball.position = self.position;
    ball.hexagrid = self;
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
