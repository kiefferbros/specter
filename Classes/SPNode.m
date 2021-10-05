//
//  SPNode.m
//  GravHook
//
//  Created by Jonathan on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPNode.h"
#import "Specter.h"
#import "SPAnimation.h"

@interface SPNode ()
- (void)_setParent:(id)aParent;
- (void)_setScene:(SPScene *)aScene;
@end

@interface SPAnimation ()
- (void)setNode:(SPNode*)node;
- (void)_setNode:(SPNode*)node;
@end

@interface SPScene (AnimationManagement) 

- (void)_addNodeAnimation:(SPAnimation*)animation;
- (void)_addNodeAnimations:(NSArray*)animations;
- (void)_removeNodeAnimation:(SPAnimation*)animation;
- (void)_removeNodeAnimations:(NSArray*)animations;

@end

#pragma mark -
@implementation SPNode
- (id)init {
	if ((self = [super init])) {
		_parent = nil;
        _children = [[NSMutableArray alloc] init];
        
		_animations = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	return self;
}

- (void)dealloc {
    [self.animations makeObjectsPerformSelector:@selector(setNode:) withObject:nil];
	[self __setScene:nil];
}

- (id)valueForUndefinedKey:(NSString*)key {
	return nil;
}

#pragma mark - Hierarchy
@synthesize parent=_parent;
@synthesize scene=_scene;

- (NSArray*)children {
    return (NSArray*)_children;
}



- (NSArray*)ancestors {
	NSMutableArray *ancestors = [NSMutableArray array];
	// find the root
	SPNode *root = self;
	while ((root = root.parent) && root.scene != root) {
		[ancestors insertObject:root atIndex:0];
	}
	
	return ancestors;
}

- (NSUInteger)childCount {
	return _children.count;
}

- (NSUInteger)childIndex {
    SPNode *parent = _parent==nil ? _scene : _parent;
    return [parent->_children indexOfObject:self];
}


#pragma mark - Modify Children Array
- (void)addChild:(SPNode*)node {
    if (node.parent == self)
        [self bringChildToFront:node];
    else
        [self insertChild:node atIndex:self.childCount];
}

- (void)insertChild:(SPNode*)node atIndex:(NSUInteger)index {
    SPNode *oldParent = node.parent;
    
    [_children insertObject:node atIndex:index];
	
	// only one parent at a time
	if (node.parent) {
		[oldParent->_children removeObject:node];
	}
    
	[node _setParent:self];
	[node _setScene:self.scene];
}

- (void)insertChild:(SPNode *)node aboveChild:(SPNode*)sibling {
    NSUInteger index = [self indexOfChild:sibling];
    [self insertChild:node atIndex:index+1];
}

- (void)insertChild:(SPNode *)node belowChild:(SPNode*)sibling {
    NSUInteger index = [self indexOfChild:sibling];
	[self insertChild:node atIndex:index];
}

- (void)replaceChildAtIndex:(NSUInteger)index withChild:(SPNode*)node {
	SPNode *oldNode = [_children objectAtIndex:index];
	[oldNode _setParent:nil];
	[oldNode _setScene:nil];
	
    [_children replaceObjectAtIndex:index withObject:node];
	
	// only one parent at a time
	if (node.parent || node.scene) {
		SPNode *oldParent = (!node.parent) ? node.scene : node.parent;
		[oldParent->_children removeObject:node];
	}
	
	[node _setParent:self];
	[node _setScene:self.scene];
}

- (void)removeChildAtIndex:(NSUInteger)index {
	SPNode *node = [_children objectAtIndex:index];
	
	[node _setParent:nil];
	[node _setScene:nil];
	
	[_children removeObjectAtIndex:index];
}

- (void)removeChild:(SPNode*)node {
    NSUInteger index = [_children indexOfObject:node];
    if (index != NSNotFound) {
        [node _setParent:nil];
        [node _setScene:nil];
        [_children removeObjectAtIndex:index];
    }
}

- (void)removeAllChildren {
	for (SPNode *node in _children) {
		[node _setParent:nil];
		[node _setScene:nil];
	}
	
    [_children removeAllObjects];
}

- (void)bringChildToFront:(SPNode*)node {
    NSUInteger index = [_children indexOfObject:node];
    if (index!=NSNotFound) {
        [_children addObject:node];
        [_children removeObjectAtIndex:index];
    }
}

- (void)sendChildToBack:(SPNode*)node {
    NSUInteger index = [_children indexOfObject:node];
    if (index!=NSNotFound) {        
        [_children insertObject:node atIndex:0];
        [_children removeObjectAtIndex:index+1];
    }
}

- (void)disownParent {
	if (self.parent || self.scene) {
		SPNode *oldParent = (!self.parent) ? self.scene : self.parent;
		[oldParent removeChild:self];
	}
}

#pragma mark - Objects and Info from Children Array
- (id)childAtIndex:(NSUInteger)index {
	return [_children objectAtIndex:index];
}

- (id)firstChild {
	return (_children.count) ? [_children objectAtIndex:0] : nil;
}

- (id)lastChild {
	return [_children lastObject];
}

- (NSUInteger)indexOfChild:(SPNode*)node {
	return [_children indexOfObject:node];
}


#pragma mark - Heirarchal Events
- (void)_setParent:(id)aParent {
    [self willChangeParent];
	_parent = aParent;
    [self didChangeParent];
}

- (void)__setScene:(SPScene*)aScene {
    NSArray *anims = self.animations;
    [_scene _removeNodeAnimations:anims];
    
    _scene = aScene;
    
    [_children makeObjectsPerformSelector:@selector(__setScene:) withObject:aScene];
    
    if (aScene)
        [_scene _addNodeAnimations:anims];
}

- (void)_setScene:(SPScene*)aScene {
    if (_scene != aScene) {
        [self willChangeScene];
        [self __setScene:aScene];
        [self didChangeScene];
    }
}

- (void)willChangeParent {}
- (void)didChangeParent {}
- (void)willChangeScene {
    [_children makeObjectsPerformSelector:@selector(willChangeScene)];
}
- (void)didChangeScene {
    [_children makeObjectsPerformSelector:@selector(didChangeScene)];
}

#pragma mark -
#pragma mark Animations
- (NSArray*)animations {
	return [_animations allValues];
}

- (void)addAnimation:(SPAnimation*)anim forKey:(NSString*)key {
	
	SPAnimation *animation = [anim copy];
          
	
	SPAnimation *oldAnim = [_animations objectForKey:animation.property];
	if (oldAnim) {
		//[oldAnim stop];

        
        [oldAnim _setNode:nil];
		[self.scene _removeNodeAnimation:oldAnim];
	}
	
	[_animations setObject:animation forKey:animation.property];
    
	[self.scene _addNodeAnimation:animation];
	
	[animation prepareWithNode:self forKey:key];
}

- (void)removeAnimationForKey:(NSString*)key {
    SPAnimation *anim = [self animationForKey:key];
    
    if (anim) {
        [anim stop];
        [_animations removeObjectForKey:anim.property];
        [self.scene _removeNodeAnimation:anim];
    }
}

- (void)removeAllAnimations {
	for (SPAnimation *a in [_animations allValues]) {
		[a stop];
		[self.scene _removeNodeAnimation:a];
	}
	[_animations removeAllObjects];
}

- (id)animationForKey:(NSString*)key {
	SPAnimation *anim = nil;
    NSArray *anims = [_animations allValues];
    for (SPAnimation *a in anims) {
        if ([a.nodeKey isEqualToString:key]) {
            anim = a;
            break;
        }
    }
	return anim;
}

- (BOOL)isAnimating {
	return _animations.count;
}

- (BOOL)isPropertyAnimating:(NSString*)property {
    return [_animations objectForKey:property] != nil;
}

- (void)animateProperty:(NSString*)property toValue:(id)value duration:(SPTime)duration {
    SPAnimation *anim = [[SPAnimation alloc] initWithProperty:property];
    [anim insertValue:value atTime:duration];
    [self addAnimation:anim forKey:nil];
}

- (void)animateProperty:(NSString*)property toValue:(id)value duration:(SPTime)duration delay:(SPTime)delay delegate:(id<SPAnimationDelegate>)delegate {
    SPAnimation *anim = [[SPAnimation alloc] initWithProperty:property];
    anim.delay = delay;
    anim.delegate = delegate;
    [anim insertValue:value atTime:duration];
    [self addAnimation:anim forKey:nil];
}

- (id)animationForProperty:(NSString*)property {
    return [_animations objectForKey:property];
}

- (void)removeAnimationForProperty:(NSString *)property {
    SPAnimation *anim = [_animations objectForKey:property];
    if (anim) {
        [anim stop];
        [self.scene _removeNodeAnimation:anim];
        [_animations removeObjectForKey:property];
    }
}

- (void)_removeAnimationForProperty:(NSString *)property {
	[_animations removeObjectForKey:property];
}
@end

#pragma mark -
@implementation SPScene (AnimationManagement)
- (void)_addNodeAnimation:(SPAnimation*)animation {
	[_inQueue addObject:animation];
}

- (void)_addNodeAnimations:(NSArray*)animations {
	[_inQueue addObjectsFromArray:animations];
}

- (void)_removeNodeAnimation:(SPAnimation *)animation {
	[_outQueue addObject:animation];
}

- (void)_removeNodeAnimations:(NSArray*)animations {
	[_outQueue addObjectsFromArray:animations];
}
@end


