//
//  HexameshLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import <Foundation/Foundation.h>

@class GameModel;

@interface HexameshLayer : Layer {
    
}

@property (nonatomic, assign) GameModel* gameModel;

- (id) init;

@end
