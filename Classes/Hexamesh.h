//
//  Hexamesh.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Hexagrid;

@interface Hexamesh : NSObject {
    int level;
    Hexagrid* center;
    NSMutableArray* rings;
    NSMutableArray* hexagrids;
}

@property (nonatomic, readonly) int level;
@property (nonatomic, readonly) Hexagrid* center;
@property (nonatomic, readonly) NSMutableArray* rings;
@property (nonatomic, readonly) NSMutableArray* hexagrids;

- (id) initWithLevel:(int)aLevel;

@end
