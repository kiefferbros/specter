////
//  SPAnimation.m
//  Orba
//
//  Created by Jonathan on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPAnimation.h"
#import "SPNode.h"

@interface SPKeyframe : NSObject <NSCopying> {
@package
	id                  _value;
	SPTime              _time;
    
    SPTimeWeight    _preWeight, _postWeight;
}
@property (nonatomic) id value;
@property (nonatomic, assign) SPTime time;
@property (nonatomic, assign) SPTimeWeight preWeight, postWeight;
+ (SPKeyframe*)keyframeWithValue:(id)value time:(SPTime)time;
+ (SPKeyframe*)keyframeWithValue:(id)value time:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight;
@end

id SPAnimationInterpolateStepped (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    return delta >= 1.f ? bFrame->_value : aFrame->_value;
}

id SPAnimationInterpolateLinearFloat (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPFloat a = [aFrame->_value floatValue];
    SPFloat b = [bFrame->_value floatValue];
    return [NSNumber numberWithFloat:SPFloatLerp(a, b, delta)];
}

id SPAnimationInterpolateWeightedFloat (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPFloat a = [aFrame->_value floatValue];
    SPFloat b = [bFrame->_value floatValue];
    SPTimeWeight aW = aFrame->_postWeight;
    SPTimeWeight bW = bFrame->_preWeight;
    return [NSNumber numberWithFloat:SPFloatWerp(a, b, delta, aW.t, aW.v, bW.t, bW.v)];
}

id SPAnimationInterpolateLinearVec2 (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPVec2 a = [aFrame->_value SPVec2Value];
    SPVec2 b = [bFrame->_value SPVec2Value];
    SPVec2 v = SPVec2Lerp(a, b, delta);
    
    return [NSValue valueWithSPVec2:v];
}

id SPAnimationInterpolateWeightedVec2 (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPVec2 a = [aFrame->_value SPVec2Value];
    SPVec2 b = [bFrame->_value SPVec2Value];
    SPTimeWeight aW = aFrame->_postWeight;
    SPTimeWeight bW = bFrame->_preWeight;
    SPVec2 v = SPVec2Werp(a, b, delta, aW.t, aW.v, bW.t, bW.v);

    return [NSValue valueWithSPVec2:v];
}

id SPAnimationInterpolateLinearVec3 (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPVec3 a = [aFrame->_value SPVec3Value];
    SPVec3 b = [bFrame->_value SPVec3Value];
    
    SPVec3 c= {
        SPFloatLerp(a.x, b.x, delta),
        SPFloatLerp(a.y, b.y, delta),
        SPFloatLerp(a.z, b.z, delta),
    };
    
    return [NSValue valueWithSPVec3:c];
}

id SPAnimationInterpolateWeightedVec3 (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPVec3 a = [aFrame->_value SPVec3Value];
    SPVec3 b = [bFrame->_value SPVec3Value];
    SPTimeWeight aW = aFrame->_postWeight;
    SPTimeWeight bW = bFrame->_preWeight;
    
    SPVec3 v = {
        SPFloatWerp(a.x, b.x, delta, aW.t, aW.v, bW.t, bW.v),
        SPFloatWerp(a.y, b.y, delta, aW.t, aW.v, bW.t, bW.v),
        SPFloatWerp(a.z, b.z, delta, aW.t, aW.v, bW.t, bW.v),
    };
    
    return [NSValue valueWithSPVec3:v];
}

id SPAnimationInterpolateLinearVec4 (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPVec4 a = [aFrame->_value SPVec4Value];
    SPVec4 b = [bFrame->_value SPVec4Value];
    
    SPVec4 c= {
        SPFloatLerp(a.x, b.x, delta),
        SPFloatLerp(a.y, b.y, delta),
        SPFloatLerp(a.z, b.z, delta),
        SPFloatLerp(a.w, b.w, delta)
    };
    
    return [NSValue valueWithSPVec4:c];
}

id SPAnimationInterpolateWeightedVec4 (SPKeyframe *aFrame, SPKeyframe *bFrame, SPFloat delta) {
    SPVec4 a = [aFrame->_value SPVec4Value];
    SPVec4 b = [bFrame->_value SPVec4Value];
    SPTimeWeight aW = aFrame->_postWeight;
    SPTimeWeight bW = bFrame->_preWeight;
    
    SPVec4 v = {
        SPFloatWerp(a.x, b.x, delta, aW.t, aW.v, bW.t, bW.v),
        SPFloatWerp(a.y, b.y, delta, aW.t, aW.v, bW.t, bW.v),
        SPFloatWerp(a.z, b.z, delta, aW.t, aW.v, bW.t, bW.v),
        SPFloatWerp(a.w, b.w, delta, aW.t, aW.v, bW.t, bW.v),
    };
    
    return [NSValue valueWithSPVec4:v];
}

@interface SPAnimation ()
- (void)setNextValue;
@end

@implementation SPAnimation
@synthesize delegate = _delegate;
@synthesize property = _property;
@synthesize delay = _delay;
@synthesize currentTime = _time;
@synthesize repeatCount = _repeatCount;
@synthesize currentRepetition = _repetition;
@synthesize repeatTime = _repeatTime;
@synthesize finished = _finished;
@synthesize nodeKey = _nodeKey;
@synthesize startTime = _startTime;
@synthesize autoreverses = _autoreverses;
@synthesize tag = _tag;
@synthesize stopped=_stopped;

- (id)initWithProperty:(NSString *)property {
	if ((self = [super init])) {
		_keyframes = [[NSMutableArray alloc] init];
		_property = [property copy];
		_delay = 0;
		_keyIndex = 0;
		_repeatCount = 0;
		_repetition = 0;
		_repeatTime = 0.;
		_timeDir = 1.;
		_autoreverses = NO;
        _interpolation = SPAnimationInterpolationLinear;
        _interpolationFunc = SPAnimationInterpolateStepped;
	}
	return self;
}


- (SPNode*)node {
    return _node;
}

- (void)_setNode:(SPNode*)node {
    _node = node;
    if (_node==nil) {
        self.delegate = nil;
    }
}

- (void)setNode:(SPNode *)node {
    _node = node;
    if (_node==nil) {
        self.delegate = nil;
    }
}

- (SPTime)duration {
	return ((SPKeyframe*)[_keyframes lastObject]).time;
}

- (BOOL)isAutoreversing {
	return (_timeDir < 0.);
}

/*
- (BOOL)isFinished {
	return (_time >= [self duration] && _repeatCount != -1 && _repetition >= _repeatCount);
}*/

- (void)insertValue:(id)value atTime:(SPTime)time {
	[self insertValue:value atTime:time preWeight:SPTimeWeightMake(0.f, 0.f) postWeight:SPTimeWeightMake(0.f, 0.f)];
}

- (void)insertFloat:(SPFloat)aFloat atTime:(SPTime)time {
	[self insertValue:[NSNumber numberWithFloat:aFloat] atTime:time preWeight:SPTimeWeightMake(0.f, 0.f) postWeight:SPTimeWeightMake(0.f, 0.f)];
}

- (void)insertVec2:(SPVec2)vec atTime:(SPTime)time {
	[self insertValue:[NSValue valueWithSPVec2:vec] atTime:time preWeight:SPTimeWeightMake(0.f, 0.f) postWeight:SPTimeWeightMake(0.f, 0.f)];
}

- (void)insertVec3:(SPVec3)vec atTime:(SPTime)time {
	[self insertValue:[NSValue valueWithSPVec3:vec] atTime:time preWeight:SPTimeWeightMake(0.f, 0.f) postWeight:SPTimeWeightMake(0.f, 0.f)];
}

- (void)insertVec4:(SPVec4)vec atTime:(SPTime)time {
	[self insertValue:[NSValue valueWithSPVec4:vec] atTime:time preWeight:SPTimeWeightMake(0.f, 0.f) postWeight:SPTimeWeightMake(0.f, 0.f)];
}

- (void)insertValue:(id)value atTime:(SPTime)time weight:(SPTimeWeight)weight {
    [self insertValue:value atTime:time preWeight:weight postWeight:weight];
}

- (void)insertFloat:(SPFloat)aFloat atTime:(SPTime)time weight:(SPTimeWeight)weight {
    [self insertValue:[NSNumber numberWithFloat:aFloat] atTime:time preWeight:weight postWeight:weight];
}

- (void)insertVec2:(SPVec2)vec atTime:(SPTime)time weight:(SPTimeWeight)weight {
    [self insertValue:[NSValue valueWithSPVec2:vec] atTime:time preWeight:weight postWeight:weight];
}

- (void)insertVec3:(SPVec3)vec atTime:(SPTime)time weight:(SPTimeWeight)weight {
    [self insertValue:[NSValue valueWithSPVec3:vec] atTime:time preWeight:weight postWeight:weight];
}

- (void)insertVec4:(SPVec4)vec atTime:(SPTime)time weight:(SPTimeWeight)weight {
    [self insertValue:[NSValue valueWithSPVec4:vec] atTime:time preWeight:weight postWeight:weight];
}

- (void)insertValue:(id)value atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight {
    // set the animation value type of the first key inserted
	if (![_keyframes count]) {
		_valueType = SPAnimationValueTypeUnknown;
		if ([value isKindOfClass:[NSValue class]]) {
			if (strcmp([value objCType], @encode(SPFloat)) == 0) 
				_valueType = SPAnimationValueTypeFloat;
            else if (strcmp([value objCType], @encode(SPVec2)) == 0)
				_valueType = SPAnimationValueTypeVec2;
			else if (strcmp([value objCType], @encode(SPVec3)) == 0) 
				_valueType = SPAnimationValueTypeVec3;
            else if (strcmp([value objCType], @encode(SPVec4)) == 0) 
				_valueType = SPAnimationValueTypeVec4;
		}
        
        self.interpolation = _interpolation;
	}
	
	SPKeyframe *keyframe = [SPKeyframe keyframeWithValue:value time:time preWeight:preWeight postWeight:postWeight];
	// sort 
	NSUInteger index = 0;
	for (SPKeyframe *key in _keyframes) {
		if (key.time > time) {
			break;
		} else if (key.time == time) {
			[_keyframes replaceObjectAtIndex:index withObject:keyframe];
			return;
		}
		++index;
	}
	[_keyframes insertObject:keyframe atIndex:index];
}

- (void)insertFloat:(SPFloat)aFloat atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight {
    [self insertValue:[NSNumber numberWithFloat:aFloat] atTime:time preWeight:preWeight postWeight:postWeight];
}

- (void)insertVec2:(SPVec2)vec atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight {
    [self insertValue:[NSValue valueWithSPVec2:vec] atTime:time preWeight:preWeight postWeight:postWeight];
}

- (void)insertVec3:(SPVec3)vec atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight {
    [self insertValue:[NSValue valueWithSPVec3:vec] atTime:time preWeight:preWeight postWeight:postWeight];
}

- (void)insertVec4:(SPVec4)vec atTime:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight {
    [self insertValue:[NSValue valueWithSPVec4:vec] atTime:time preWeight:preWeight postWeight:postWeight];
}

- (void)prepareWithNode:(SPNode*)node forKey:(NSString*)nodeKey {
	self.node = node;
	_time = -_delay + _startTime;
	_keyIndex = 0;
    if (_keyframes.count > 1) {
        for (int i=0; i<_keyframes.count-1; ++i) {
            SPKeyframe *cur, *next;
            cur = [_keyframes objectAtIndex:i];
            next = [_keyframes objectAtIndex:i+1];
            
            if (_time >= cur.time && _time < next.time) {
                _keyIndex = i;
                break;
            }
        }
    }
    
	_repetition = 0;
	_nodeKey = nodeKey;
	
	// add keyframe at frame zero if neccessary
	if ([_keyframes count]) {
		SPKeyframe *keyframe = [_keyframes objectAtIndex:0];
		if (keyframe.time != 0.) {
			id value = [node valueForKey:self.property];
			[self insertValue:value atTime:0.];
		}
	}
}

- (void)start {
    _repetition = 1;
	if (_delegate && [_delegate respondsToSelector:@selector(animationWillStart:)]) {
		[_delegate animationWillStart:self];
	}
}

- (void)stop {
    if (self.node && !_stopped) {
        _stopped = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(animationDidStop:)]) {
            [_delegate animationDidStop:self];
        }
        
        self.node = nil; 
    }
}

- (void)setNextValue {	
	if (_timeDir < 0.) {
		if (_keyIndex > 0 && _time < ((SPKeyframe*)[_keyframes objectAtIndex:_keyIndex]).time)
			_keyIndex--;
	} else {
		if ((int)_keyIndex < (int)[_keyframes count]-2 && _time > ((SPKeyframe*)[_keyframes objectAtIndex:_keyIndex+1]).time)
			_keyIndex++;
	}
	
	SPKeyframe *k1, *k2;
	k1 = [_keyframes objectAtIndex:_keyIndex];
	k2 = [_keyframes objectAtIndex:_keyIndex+1];
	
	SPFloat delta = (_time-k1.time)/(k2.time-k1.time);    
    
    id value = _interpolationFunc(k1, k2, delta);
    [_node setValue:value forKey:_property];
}

- (void)step:(SPTime)dt {    
    SPTime oldTime = _time;
    SPTime duration = self.duration;
    _time += _timeDir*dt;
    
    if (_time>duration)
        _time=duration;

	if (_time >= _startTime) {
        if (oldTime <= _startTime && _repetition==0) 
            [self start];
		[self setNextValue];
    }
	

	// end of repetition
	if ((_timeDir > 0. && _time >= duration) || (_timeDir < 0 && _time < _repeatTime) ) {
        if (_repeatCount == -1 || _repetition <= _repeatCount) {
            ++_repetition;
            
            if (_autoreverses) {
                _timeDir = -_timeDir;
                
                if (_timeDir < 0.) {
                    
                    _time = duration;
                } else {
                    _time = _repeatTime;
                    _keyIndex = 0;
                }
            } else {
                
                _time = _repeatTime;
                _keyIndex = 0;
            }
        } else {
            _finished = YES;
        }
	}
}

- (void)setInterpolation:(SPAnimationInterpolation)interp {
    _interpolation = interp;
    
    switch (_interpolation) {
        case SPAnimationInterpolationStepped:
            _interpolationFunc = &SPAnimationInterpolateStepped;
            break;
        default:
        {
            switch (_valueType) {
                case SPAnimationValueTypeFloat:
                    _interpolationFunc = interp==SPAnimationInterpolationLinear ? &SPAnimationInterpolateLinearFloat : &SPAnimationInterpolateWeightedFloat;
                    break;
                case SPAnimationValueTypeVec2:
                    _interpolationFunc = interp==SPAnimationInterpolationLinear ? &SPAnimationInterpolateLinearVec2 : &SPAnimationInterpolateWeightedVec2;
                    break;   
                case SPAnimationValueTypeVec3:
                    _interpolationFunc = interp==SPAnimationInterpolationLinear ? &SPAnimationInterpolateLinearVec3 : &SPAnimationInterpolateWeightedVec3;
                    break; 
                case SPAnimationValueTypeVec4:
                    _interpolationFunc = interp==SPAnimationInterpolationLinear ? &SPAnimationInterpolateLinearVec4 : &SPAnimationInterpolateWeightedVec4;
                    break;
                default:
                    _interpolationFunc = &SPAnimationInterpolateStepped;
                    break;
            }
            break;
        }
    }    
}

- (SPAnimationInterpolation)interpolation {
    return _interpolation;
}

// NSCopying
- (id)copyWithZone:(NSZone *)zone {
	SPAnimation *copy = [[[self class] allocWithZone:zone] init];
	
	copy->_delegate = _delegate;
	copy->_property = [_property copy];
	copy->_nodeKey = [_nodeKey copy];
    copy->_tag = _tag;
	copy->_keyframes = [[NSMutableArray alloc] initWithArray:_keyframes copyItems:YES];
	copy->_keyIndex = _keyIndex;
	copy->_delay = _delay;
	copy->_startTime = _startTime;
	copy->_time = _time;
    copy->_finished = _finished;
	copy->_timeDir = _timeDir;
	copy->_repeatTime = _repeatTime;
	copy->_repeatCount = _repeatCount;
	copy->_repetition = _repetition;
	copy->_valueType = _valueType;
	copy->_node = _node;
	copy->_autoreverses = _autoreverses;
    copy->_interpolation = _interpolation;
    copy->_interpolationFunc = _interpolationFunc;
	
	return copy;
}
@end

#pragma mark -
#pragma mark NSValue Keyframe
@implementation SPKeyframe 
@synthesize value = _value;
@synthesize time = _time;
@synthesize preWeight = _preWeight;
@synthesize postWeight = _postWeight;

- (id)copyWithZone:(NSZone*)zone {
	SPKeyframe *copy = [[[self class] allocWithZone:zone] init];
	copy->_value = [_value copy];
	copy->_time = _time;
	copy->_preWeight = _preWeight;
    copy->_postWeight = _postWeight;
	return copy;
}

+ (SPKeyframe*)keyframeWithValue:(id)value time:(SPTime)time {
	SPKeyframe *frame = [[SPKeyframe alloc] init];
	frame.value = value;
	frame.time = time;
	return frame;
}

+ (SPKeyframe*)keyframeWithValue:(id)value time:(SPTime)time preWeight:(SPTimeWeight)preWeight postWeight:(SPTimeWeight)postWeight {
    SPKeyframe *frame = [[SPKeyframe alloc] init];
	frame.value = value;
	frame.time = time;
    frame.preWeight = preWeight;
    frame.postWeight = postWeight;
	return frame;
}

@end

#pragma mark -
#pragma mark NSValue Extensions
@implementation NSValue (NSValueSPAnimationExtentions)
+ (NSValue *)valueWithSPVec2:(SPVec2)vector {
	return [NSValue valueWithBytes:&vector objCType:@encode(SPVec2)];
}

- (SPVec2)SPVec2Value {
	SPVec2 vector;
	[self getValue:&vector];
	return vector;
}


+ (id)valueWithSPVec4:(SPVec4)vec {
	return [NSValue valueWithBytes:&vec objCType:@encode(SPVec4)];
}

- (SPVec4)SPVec4Value {
	SPVec4 vec;
	[self getValue:&vec];
	return vec;
}

+ (id)valueWithSPVec3:(SPVec3)vec {
	return [NSValue valueWithBytes:&vec objCType:@encode(SPVec3)];
}

- (SPVec3)SPVec3Value {
	SPVec3 vec;
	[self getValue:&vec];
	return vec;
}


+ (NSValue *)valueWithSPBox:(SPBox)box {
	return [NSValue valueWithBytes:&box objCType:@encode(SPBox)];
}

- (SPBox)SPBoxValue {
	SPBox box;
	[self getValue:&box];
	return box;
}
@end



