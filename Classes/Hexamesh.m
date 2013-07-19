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

- (void) __listRetainCounts;


@end

@implementation Hexamesh

@synthesize level, center, hexagrids;

- (void) __listRetainCounts {
    NSMutableString* str = [[NSMutableString alloc] init];
    for (Hexagrid* h in hexagrids) {
        [str appendFormat:@"%d", [h retainCount]];
    }
    CCLOG(str);
}

- (id) initWithLevel:(int)aLevel gameModel:(GameModel*)aGameModel {
    if ((self = [super init])) {
        gameModel = aGameModel;
        level = aLevel + 2;
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
    }
    return self;
}

- (id) initWithLevel:(int)aLevel file:(NSString*)aFile gameModel:(GameModel*)aGameModel {
    if ([self initWithLevel:aLevel gameModel:aGameModel]) {
        if (aFile) {
            NSError* err;
            NSString* path = [[NSBundle mainBundle] pathForResource: @"Meshballs1" ofType: @"txt" inDirectory:nil];
            NSString* input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
            NSScanner* scanner = [NSScanner scannerWithString:input];
            Hexagrid* cursor = center;
            int dir = 0;
            while (![scanner isAtEnd]) {
                int count = 0;
                NSString* command;
                [scanner scanInt:&count];
                [scanner scanUpToString:@" " intoString:&command];
                [scanner scanString:@" " intoString:nil];
                if (count == 0) {
                    count++;
                }
                NSLog(@"%d%@", count, command);
                for (int i = 0; i < count; ++i) {
                    if ([command isEqualToString:@"c"]) {
                        dir = (dir + 1) % 6;
                    } else if ([command isEqualToString:@"cc"]) {
                        dir = (dir + 5) % 6;
                    } else if ([command isEqualToString:@"f"]) {
                        cursor = [cursor.neighbours objectAtIndex:dir];
                    } else if ([command isEqualToString:@"y"]) {
                        Ball* b = [[Ball alloc] initWithType:BallType_Yellow gameModel:aGameModel];
                        cursor.ball = b;
                        [b release];
                        cursor = [cursor.neighbours objectAtIndex:dir];
                    } else if ([command isEqualToString:@"b"]) {
                        Ball* b = [[Ball alloc] initWithType:BallType_Blue gameModel:aGameModel];
                        cursor.ball = b;
                        [b release];
                        cursor = [cursor.neighbours objectAtIndex:dir];
                    } else if ([command isEqualToString:@"r"]) {
                        Ball* b = [[Ball alloc] initWithType:BallType_Red gameModel:aGameModel];
                        cursor.ball = b;
                        [b release];
                        cursor = [cursor.neighbours objectAtIndex:dir];
                    } else if ([command isEqualToString:@"g"]) {
                        Ball* b = [[Ball alloc] initWithType:BallType_Green gameModel:aGameModel];
                        cursor.ball = b;
                        [b release];
                        cursor = [cursor.neighbours objectAtIndex:dir];
                    }
                }
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeInt:level forKey:@"level"];
    [aCoder encodeObject:center forKey:@"center"];
    [aCoder encodeObject:hexagrids forKey:@"hexagrids"];
    
    [aCoder encodeObject:gameModel forKey:@"gameModel"];
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
        level = [aDecoder decodeIntForKey:@"level"];
        center = [[aDecoder decodeObjectForKey:@"center"] retain];
        hexagrids = [[aDecoder decodeObjectForKey:@"hexagrids"] retain];
        
        gameModel = [aDecoder decodeObjectForKey:@"gameModel"];
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
            if (![n isEqual:[NSNull null]] && n.dirty == NO) {
                CGPoint relPos = relPos6[nb_idx];
                n.position = ccpAdd(h.position, relPos);
                n.dirty = YES;
                [arr addObject:n];
            }
        }
    }
    for (Hexagrid* h in hexagrids) {
        h.dirty = NO;
    }
}

@end
