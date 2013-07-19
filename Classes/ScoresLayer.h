//
//  ScoresLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import <Foundation/Foundation.h>

@interface ScoresLayer : Layer {
}

- (void) addPoints:(int)aPoints animateAtPosition:(CGPoint)aPosition duration:(ccTime)aDuration scaleBy:(CGFloat)aScaleBy;

@end
