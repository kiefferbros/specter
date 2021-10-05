//
//  SPScene.m
//  GravHook
//
//  Created by Jonathan on 3/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPScene.h"
#import "Specter.h"

#define kEpsilon 0.0001

@interface SPNode()
- (void)_setParent:(id)aParent;
- (void)_setScene:(SPScene *)aScene;
- (void)__setScene:(SPScene *)aScene;
- (void)_removeAnimationForProperty:(NSString *)property;
@end

@implementation SPScene
@synthesize camera=_camera;

+ (void)prepareGL {	
	//Initialize OpenGL states
	
	glShadeModel(GL_FLAT); // should speed things up some, but won't allow color blending for "gl gradients" and such
	
	glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
}	

- (id)init {
	if ((self = [super init])) {
		[[self class] prepareGL];
		
		_camera = [[SPCamera alloc] init];
		[_camera _setScene:self];
		
		_nodeAnimations = [[NSMutableArray alloc] initWithCapacity:20];
		_inQueue = [[NSMutableArray alloc] initWithCapacity:10];
		_outQueue = [[NSMutableArray alloc] initWithCapacity:10];
        
	}
	return self;
}

- (void)dealloc {
	[_children makeObjectsPerformSelector:@selector(__setScene:) withObject:nil];
	[_camera __setScene:nil];
}

- (void)draw {  
	SPBox bb = _camera.viewingBox;
	[_camera begin];
	for (SPDrawableNode *node in _children) {
		[node drawInBox:bb];
	}
	[_camera end];
}


- (void)draw:(SPTime)dt {
    [self stepNodeAnimations:dt];
    [self draw];
}

/*
- (void)addChild:(SPNode*)node {
	[super addChild:node];
	[node _setParent:nil];
}

- (void)insertChild:(SPNode*)node atIndex:(NSUInteger)index {
	[super insertChild:node atIndex:index];
	[node _setParent:nil];
}

- (void)replaceChildAtIndex:(NSUInteger)index withChild:(SPNode *)node {
	[super replaceChildAtIndex:index withChild:node];
	[node _setParent:nil];
}*/

/*
- (void)removeChildAtIndex:(NSUInteger)index {
	[super removeChildAtIndex:index];
}

- (void)removeChild:(SPNode*)node {
	[super removeChild:node];
}

- (void)removeAllChildren {
	[super removeAllChildren];
}*/

- (SPScene*)scene {
	return self;
}

- (uint)level {
    return 0;
}

- (void)setCamera:(SPCamera *)aCamera {
	
	[_camera _setScene:nil];
	
	_camera = aCamera;
	
	if (aCamera.scene) {
		aCamera.scene.camera = nil;
	}

	[_camera _setScene:self];
}

- (id)hitNode:(SPVec2)global {
    NSEnumerator *e = [self.children reverseObjectEnumerator];
    
    for (SPLayer *layer in e) {
		SPDrawableNode *node = [layer hitNode:global];
        if ((node))
            return node;
	}
    
    return nil;
}

- (NSArray*)boxHitNodes:(SPBox)box {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (SPLayer *layer in self.children) {
        NSArray *layerArray = [layer boxHitNodes:box];
        if ([layerArray count]) {
            [array addObjectsFromArray:layerArray];
        }
    }
    
    return array;
}

#pragma mark -
#pragma mark Node Animations
- (void)stepNodeAnimations:(SPTime)dt {
	if (_outQueue.count) {
		[_nodeAnimations removeObjectsInArray:_outQueue];
		[_outQueue removeAllObjects];
	}
	
	if (_inQueue.count) {
		[_nodeAnimations addObjectsFromArray:_inQueue];
		[_inQueue removeAllObjects];
	}
	
	for (SPAnimation *animation in _nodeAnimations) {		
		if (animation.isFinished) {
			[_outQueue addObject:animation];
            SPNode *node = animation.node;
            [node _removeAnimationForProperty:animation.property];
            [animation stop];
		} else {
			[animation step:dt];
		}
	}
	
}

- (NSUInteger)animationCount {
    return _nodeAnimations.count + _inQueue.count;
}

@end
