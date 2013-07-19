//
//  Hexamesh.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Hexagrid;
@class GameModel;

@interface Hexamesh : NSObject<NSCoding> {
    int level;
    Hexagrid* center;
    NSMutableArray* hexagrids;
    
    GameModel* gameModel;
}

@property (nonatomic, readonly) int level;
@property (nonatomic, readonly) Hexagrid* center;
@property (nonatomic, readonly) NSMutableArray* hexagrids;

- (id) initWithLevel:(int)aLevel gameModel:(GameModel*)aGameModel;
- (id) initWithLevel:(int)aLevel file:(NSString*)aFile gameModel:(GameModel*)aGameModel;
- (void) encodeWithCoder:(NSCoder*)aCoder;
- (id) initWithCoder:(NSCoder*)aDecoder;

@end
