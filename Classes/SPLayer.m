//
//  SPLayer.m
//  GravHook
//
//  Created by Jonathan on 3/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPLayer.h"
#import "Specter.h"

@interface SPDrawableNode()
- (void)_setLayer:(SPLayer*)aLayer;
- (void)addChildrenIntersectingBox:(SPBox)box toArray:(NSMutableArray**)array;
@end

@implementation SPLayer
+ (NSArray*)editableKeys {
	return [NSArray arrayWithObjects:@"tx", @"ty", nil];
}

+ (id)layer {
	return [[[self class] alloc] init];
}

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

- (void)setRotation:(SPFloat)rot {
}

- (void)setScale:(SPVec2)scale {
}

- (void)setAnchor:(SPVec2)anc {
}

- (SPTransform )transform {
	if (_transformNeedsUpdate) {
		_transformNeedsUpdate = NO;
		
		_transform.m11 = 1.0;	_transform.m12 = 0;
		_transform.m21 = 0;		_transform.m22 = 1.0;
		_transform.m41 = _position.x;
		_transform.m42 = _position.y;
	}
	
	return _transform;
}

/*
- (void)addChild:(SPNode*)node {
	[super addChild:node];
	[(SPDrawableNode*)node _setLayer:self];
}

- (void)insertChild:(SPNode*)node atIndex:(NSUInteger)index {
	[super insertChild:node atIndex:index];
	[(SPDrawableNode*)node _setLayer:self];
}

- (void)replaceChildAtIndex:(NSUInteger)index withChild:(SPNode *)node {
	[[self childAtIndex:index] _setLayer:nil];
	[super replaceChildAtIndex:index withChild:node];
	[(SPDrawableNode*)node _setLayer:self];
}

- (void)removeChildAtIndex:(NSUInteger)index {
	[[self childAtIndex:index] _setLayer:nil];
	[super removeChildAtIndex:index];
}

- (void)removeChild:(SPNode*)node {
	[(SPDrawableNode*)node _setLayer:nil];
	[super removeChild:node];
}

- (void)removeAllChildren {
	[_children makeObjectsPerformSelector:@selector(_setLayer:) withObject:nil];
	[super removeAllChildren];
}*/

- (SPLayer*)layer {
	return self;
}

- (void)drawInBox:(SPBox)box {
	//cpVect cam = cpvmult(self.scene.camera.position, 1.0f-_depth);
	//rect.origin.x += cam.x - _position.x;
	//rect.origin.y += cam.y - _position.y;
	
	[self beginTransform];
	for (SPDrawableNode *node in self.children) {
		[node drawInBox:box];
	}
	[self endTransform];

}

- (SPDrawableNode*)hitNode:(SPVec2)global {
    NSEnumerator *e = [self.children reverseObjectEnumerator]; 
    
    for (SPDrawableNode *n in e) {
        SPDrawableNode *c = [n hitNode:global];
        
        if (c!=nil) {
            return c;
        }
    }
    
    return nil;
}

- (void)addChildrenIntersectingBox:(SPBox)box toArray:(NSMutableArray**)array {    
    for (SPDrawableNode *child in self.children) {
        [child addChildrenIntersectingBox:box toArray:array];
    }
}
@end
