//
//  SPNode.h
//  GravHook
//
//  Created by Jonathan on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGeometry.h"

@class SPAnimation, SPScene;
@protocol SPAnimationDelegate;
@interface SPNode : NSObject {
@package
    SPScene *__unsafe_unretained    _scene; // weak reference
	id  __unsafe_unretained         _parent; // weak reference
	NSMutableArray *                _children;

	NSMutableDictionary *           _animations;
}
// hierarchal methods
@property(unsafe_unretained, nonatomic, readonly) id  parent;
@property(unsafe_unretained, nonatomic, readonly) SPScene *scene;
@property(nonatomic, readonly) NSArray *children;
@property(nonatomic, readonly) NSUInteger childIndex;
@property(nonatomic, readonly) NSArray *ancestors; // first object of array is root. last object of array is parent
@property(nonatomic, readonly) NSUInteger childCount;
- (void)addChild:(SPNode*)node;
- (void)insertChild:(SPNode*)node atIndex:(NSUInteger)index;
- (void)insertChild:(SPNode *)node aboveChild:(SPNode*)sibling;
- (void)insertChild:(SPNode *)node belowChild:(SPNode*)sibling;
- (void)replaceChildAtIndex:(NSUInteger)index withChild:(SPNode*)node;
- (void)removeChildAtIndex:(NSUInteger)index;
- (void)removeChild:(SPNode*)node;
- (void)bringChildToFront:(SPNode*)node;
- (void)sendChildToBack:(SPNode*)node;
- (void)removeAllChildren;
- (id)childAtIndex:(NSUInteger)index;
- (id)firstChild;
- (id)lastChild;
- (NSUInteger)indexOfChild:(SPNode*)node;

- (void)disownParent;

- (void)willChangeParent;
- (void)didChangeParent;

- (void)willChangeScene;
- (void)didChangeScene;

// animation methods
@property (nonatomic, readonly) NSArray *animations;
- (void)addAnimation:(SPAnimation*)animation forKey:(NSString*)key;
- (void)removeAnimationForKey:(NSString*)key;
- (void)removeAllAnimations;
- (id)animationForKey:(NSString*)key;
- (BOOL)isAnimating;


- (void)animateProperty:(NSString*)property toValue:(id)value duration:(SPTime)duration delay:(SPTime)delay delegate:(id<SPAnimationDelegate>)delegate;
- (void)animateProperty:(NSString*)property toValue:(id)value duration:(SPTime)duration;
- (id)animationForProperty:(NSString*)property;
- (void)removeAnimationForProperty:(NSString*)property;
- (BOOL)isPropertyAnimating:(NSString*)property;
@end


