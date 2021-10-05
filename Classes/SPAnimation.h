//
//  SPAnimation.h
//  Orba
//
//  Created by Jonathan on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGeometry.h"

@protocol SPAnimationDelegate;
@class SPNode;

typedef enum {
	SPAnimationValueTypeFloat,
	SPAnimationValueTypeVec2,
	SPAnimationValueTypeVec3,
    SPAnimationValueTypeVec4,
	SPAnimationValueTypeUnknown
} SPAnimationValueType;

typedef enum {
    SPAnimationInterpolationLinear,
    SPAnimationInterpolationWeighted,
    SPAnimationInterpolationStepped
} SPAnimationInterpolation;

typedef struct SPTimeWeight {
	SPFloat t, v;
} SPTimeWeight;

static inline SPTimeWeight
SPTimeWeightMake (SPFloat t, SPFloat v) {
    return (SPTimeWeight){t, v};
}

@class SPKeyframe;
typedef id (*SPAnimationInterpolationFunc)(SPKeyframe *a, SPKeyframe *b, SPFloat delta);

@interface SPAnimation : NSObject <NSCopying> {
@package
	id <SPAnimationDelegate>        __unsafe_unretained _delegate;
	NSString                        *_property, *_nodeKey;
	NSMutableArray                  *_keyframes;
	
	NSUInteger                      _keyIndex;
    SPTime                          _delay, _startTime;
    SPTime                          _time, _repeatTime, _timeDir;
	NSInteger                       _repeatCount;
	NSInteger                       _repetition;
    NSInteger                       _tag;
	
	BOOL                            _autoreverses;
    BOOL                            _stopped, _finished;
	
	SPAnimationValueType            _valueType;
    
    SPAnimationInterpolation        _interpolation;
    SPAnimationInterpolationFunc    _interpolationFunc;
	
	SPNode                          *__unsafe_unretained _node;
}
@property (nonatomic, unsafe_unretained) id <SPAnimationDelegate> delegate;
@property (nonatomic, readonly) NSString *property;
@property (nonatomic, readonly, unsafe_unretained) SPNode *node;
@property (nonatomic, assign) SPTime delay;
@property (nonatomic, assign) SPTime startTime;
@property (nonatomic, readonly) SPTime duration;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly) SPTime currentTime;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, readonly) NSInteger currentRepetition;
@property (nonatomic, readonly, getter = isStopped) BOOL stopped;
@property (nonatomic, assign) SPTime repeatTime;
@property (nonatomic, readonly) NSString *nodeKey;
@property (nonatomic, assign) SPAnimationInterpolation interpolation;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) BOOL autoreverses;
@property (nonatomic, readonly, getter=isAutoreversing) BOOL autoreversing;

- (id)initWithProperty:(NSString*)property;

- (void)insertValue:(id)value atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight;

// convenience methods
- (void)insertValue:(id)value atTime:(SPTime)time;
- (void)insertFloat:(SPFloat)aFloat atTime:(SPTime)time;
- (void)insertVec2:(SPVec2)vec atTime:(SPTime)time;
- (void)insertVec3:(SPVec3)color atTime:(SPTime)time;
- (void)insertVec4:(SPVec4)color atTime:(SPTime)time;

// more convenience
- (void)insertValue:(id)value atTime:(SPTime)time weight:(SPTimeWeight)weight;
- (void)insertFloat:(SPFloat)aFloat atTime:(SPTime)time weight:(SPTimeWeight)weight;
- (void)insertVec2:(SPVec2)vec atTime:(SPTime)time weight:(SPTimeWeight)weight;
- (void)insertVec3:(SPVec3)color atTime:(SPTime)time weight:(SPTimeWeight)weight;
- (void)insertVec4:(SPVec4)color atTime:(SPTime)time weight:(SPTimeWeight)weight;

// even more specified convenience
- (void)insertFloat:(SPFloat)aFloat atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight;
- (void)insertVec2:(SPVec2)vec atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight;
- (void)insertVec3:(SPVec3)color atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight;
- (void)insertVec4:(SPVec4)color atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight;

- (void)prepareWithNode:(SPNode*)node forKey:(NSString*)nodeKey;
- (void)start;
- (void)stop;

- (void)step:(SPTime)dt;
@end

@protocol SPAnimationDelegate <NSObject>
@optional
- (void)animationWillStart:(SPAnimation*)animation;
- (void)animationDidStop:(SPAnimation*)animation;
@end


@interface NSValue (NSValueSPAnimationExtentions)
+ (NSValue *)valueWithSPVec2:(SPVec2)vec;
- (SPVec2)SPVec2Value;

+ (id)valueWithSPVec3:(SPVec3)vec;
- (SPVec3)SPVec3Value;

+ (id)valueWithSPVec4:(SPVec4)vec;
- (SPVec4)SPVec4Value;

+ (NSValue *)valueWithSPBox:(SPBox)box;
- (SPBox)SPBoxValue;
@end