//
//  SPScene.h
//  GravHook
//
//  Created by Jonathan on 3/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNode.h"
#import "SPCamera.h"

@interface SPScene : SPNode {
	SPCamera			*_camera;
	
	NSMutableArray *_nodeAnimations, *_inQueue, *_outQueue;
}
@property (nonatomic) SPCamera *camera;
@property (nonatomic, readonly) NSUInteger animationCount;

+ (void)prepareGL;

- (void)draw;
- (void)draw:(SPTime)dt;
- (void)stepNodeAnimations:(SPTime)dt; // needs to be called for animations to take place



- (id)hitNode:(SPVec2)global;
- (NSArray*)boxHitNodes:(SPBox)box;
@end
