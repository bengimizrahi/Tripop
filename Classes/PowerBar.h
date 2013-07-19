//
//  PowerBar.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>

@interface PowerDrawing : CocosNode {
    CGFloat power;
}

@property (nonatomic, assign) CGFloat power;

@end

@interface PowerBar : Sprite {
    PowerDrawing* powerDrawing;
}

@property (nonatomic) CGFloat power;

- (id) init;

@end
