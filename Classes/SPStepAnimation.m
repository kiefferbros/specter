//
//  SPStepAnimation.m
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 4/9/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPStepAnimation.h"

@implementation SPStepAnimation
- (id)init {
    self = [super initWithProperty:@"step"];
    return self;
}

- (void)step:(SPTime)dt {
    SPTime oldTime = _time;
    _time += dt;
    
	if (_time >= _startTime) {
        if (oldTime <= _startTime) 
            [self start];
        
        [(id)self.node step:dt];
    }
}

- (BOOL)isFinished {
    return NO;
}
@end
