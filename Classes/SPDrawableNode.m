//
//  SPDrawableNode.m
//  Specter
//
//  Created by Jonathan on 3/26/09.
//  Copyright 2009 Kieffer Bros. LLC. All rights reserved.
//

#import "SPDrawableNode.h"
#import "Specter.h"

@interface SPDrawableNode()
- (void)_setLayer:(SPLayer*)aLayer;
@end

@implementation SPDrawableNode
#pragma mark - Init/Dealloc
- (id)init {
	if ((self =[super init])) {
        _opacity = 1.f;
        _inheritOpacity = YES;
	}
	return self;
}

#pragma mark - Opacity
@synthesize opacity=_opacity;
@synthesize inheritOpacity=_inheritOpacity;

- (SPFloat)displayOpacity {
    return _inheritOpacity&&self.parent!=self.scene ? [self.parent displayOpacity]*_opacity : _opacity;
}

#pragma mark - Bounds
- (SPBox)contentBox {
	return SPBoxMake(0, 0, 0, 0);
}

- (SPBox)boundBox {	
	return SPBoxTransform(self.contentBox, self.transform);
}

- (SPBox)globalBoundBox {
	return SPBoxTransform(self.contentBox, self.globalTransform);
}

#pragma mark - Drawing
- (void)draw {
	
}

- (void)drawInBox:(SPBox)box {		
	[self beginTransform];
	
    [self draw];
	
	NSArray *children = self.children;
	for (SPDrawableNode *node in children) {
		[node drawInBox:box];
	}
	
	[self endTransform];
}

#pragma mark - Transformations
- (void)beginTransform {
	glPushMatrix();	
	glMultMatrixf(self.transform.m);
}

- (void)endTransform {
	glPopMatrix();
}

#pragma mark - Parent Layer
@synthesize layer=_layer;

- (void)_setLayer:(SPLayer *)layer {
    [self willChangeLayer];
	_layer = layer;
    [self didChangeLayer];
	[_children makeObjectsPerformSelector:@selector(_setLayer:) withObject:layer];
}

- (void)willChangeLayer {
    
}

- (void)didChangeLayer {
    
}

#pragma mark - Hit Tests
- (id)hitNode:(SPVec2)global {
    NSEnumerator *e = [self.children reverseObjectEnumerator]; 
    
    for (SPDrawableNode *n in e) {
        SPDrawableNode *c = [n hitNode:global];
        
        if (c!=nil) {
            return c;
        }
    }
    
    return SPBoxContainsVec(self.globalBoundBox, global) ? self : nil;
}

- (void)addChildrenIntersectingBox:(SPBox)box toArray:(NSMutableArray**)array {
    if (SPBoxIntersects(self.globalBoundBox, box)) {
        [*array addObject:self];
    }
    
    for (SPDrawableNode *child in self.children) {
        [child addChildrenIntersectingBox:box toArray:array];
    }
}

- (NSArray*)boxHitNodes:(SPBox)box {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    [self addChildrenIntersectingBox:box toArray:&array];
    
    return array;
}

#pragma mark - SPNode
- (void)addChild:(SPNode*)node {
	[super addChild:node];	
	[(SPDrawableNode *)node _setLayer:self.layer];
}

- (void)insertChild:(SPNode*)node atIndex:(NSUInteger)index {
	[super insertChild:node atIndex:index];
	
	[(SPDrawableNode *)node _setLayer:self.layer];
}

- (void)replaceChildAtIndex:(NSUInteger)index withChild:(SPNode *)node {
	[[self childAtIndex:index] _setLayer:nil];
	[super replaceChildAtIndex:index withChild:node];
	[(SPDrawableNode *)node _setLayer:self.layer];
}

- (void)removeChildAtIndex:(NSUInteger)index {
	SPDrawableNode *node = [_children objectAtIndex:index];
	[node _setLayer:nil];
	
	[super removeChildAtIndex:index];
}

- (void)removeChild:(SPNode*)node {
	[(SPDrawableNode *)node _setLayer:nil];
	
	[super removeChild:node];
}

- (void)removeAllChildren {
	for (SPNode *node in _children) {
		[(SPDrawableNode *)node _setLayer:nil];
	}
	
	[super removeAllChildren];
}

- (void)disownParent {
	[self _setLayer:nil];
	[super disownParent];
	
}
@end
