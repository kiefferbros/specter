//
//  SPNode2D.m
//  Gravity
//
//  Created by Jonathan on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPNode2D.h"


@implementation SPNode2D

@synthesize rotation=_rotation;
@synthesize position=_position;
@synthesize scale=_scale;
@synthesize anchor=_anchor;
@synthesize transformNeedsUpdate=_transformNeedsUpdate;

- (id)init {
	if ((self = [super init])) {
		_position = SPVec2Zero;
		_anchor = SPVec2Zero;
		_scale = SPVec2One;
		_rotation = 0.0f;
		_transform = SPTransformIdentity;
		_transformNeedsUpdate = NO;
	}
	return self;
}

- (void)setTransformNeedsUpdate {
	_transformNeedsUpdate = YES;
}

- (SPTransform)transform {
	if (_transformNeedsUpdate) {
		_transformNeedsUpdate = NO;
        //_transform = SPTransformAffineMake(_position, _rotation, _scale, _anchor);
        SPTransformAffineMakePtr(&_transform, _position, _rotation, _scale, _anchor);
	}
	
	return _transform;
}

- (SPTransform)globalTransform {
	
	
	SPTransform t, nt, rt;
    t = SPTransformIdentity;
	
	for (SPNode2D *n in self.ancestors) {
		//t = SPTransformAffineMult(n.transform, t);
        nt = n.transform;
        SPTransformAffineMultPtr(&nt, &t, &rt);
        t = rt;
	}
	
	//t = SPTransformAffineMult(self.transform, t);
    nt = self.transform;
    SPTransformAffineMultPtr(&nt, &t, &rt);
	
	return rt;
}

- (void)setGlobalPosition:(SPVec2)pos {	
	NSArray *ancestors = self.ancestors;
	SPTransform t = SPTransformIdentity;
	
	for (SPNode2D *n in ancestors) {
		t = SPTransformAffineMult(SPTransformAffineInvert(n.transform), t);
	}
	
	pos = SPVec2Transform(pos, t);
	
	self.position = pos;
}

- (SPVec2)globalPosition {	
	SPTransform t = self.parent!=self.scene ? ((SPNode2D*)self.parent).globalTransform : SPTransformIdentity;
	SPVec2 p = SPVec2Transform(_position, t);
	
	return p;
}

- (SPFloat)globalRotation {
	NSArray *ancestors = self.ancestors;
	float r = 0.0;
	
	for (SPNode2D *n in ancestors) {
		r += n.rotation;
	}
	
	r += self.rotation;
	
	return r;
}

- (SPVec2)globalToLocal:(SPVec2)v {

    NSArray *ancestors = self.ancestors;
	SPTransform t = SPTransformIdentity;
	
	for (SPNode2D *n in ancestors) {
		t = SPTransformAffineMult(SPTransformAffineInvert(n.transform), t);
	}
	
	v = SPVec2Transform(v, t);
	
	return v;
}

- (void)setRotation:(SPFloat)rotation {
	_rotation = rotation;
	[self setTransformNeedsUpdate];
}

-  (void)setPosition:(SPVec2)v {
#if !TARGET_OS_IPHONE
	[self willChangeValueForKey:@"tx"];
	[self willChangeValueForKey:@"ty"];
#endif
	_position = v;
#if !TARGET_OS_IPHONE
	[self didChangeValueForKey:@"tx"];
	[self didChangeValueForKey:@"ty"];
#endif
	
	[self setTransformNeedsUpdate];
}

-  (void)setScale:(SPVec2)v {
#if !TARGET_OS_IPHONE
	[self willChangeValueForKey:@"sx"];
	[self willChangeValueForKey:@"sy"];
#endif
	_scale = v;
#if !TARGET_OS_IPHONE
	[self didChangeValueForKey:@"sx"];
	[self didChangeValueForKey:@"sy"];
#endif
	
	[self setTransformNeedsUpdate];
}

-  (void)setAnchor:(SPVec2)v {
#if !TARGET_OS_IPHONE
	[self willChangeValueForKey:@"ax"];
	[self willChangeValueForKey:@"ay"];
#endif
	_anchor = v;
#if !TARGET_OS_IPHONE
	[self didChangeValueForKey:@"ax"];
	[self didChangeValueForKey:@"ay"];
#endif
	
	[self setTransformNeedsUpdate];
}

- (void)setAnchorInPlace:(SPVec2)anchor {
    SPVec2 dif = SPVec2Sub(anchor, self.anchor);
    self.anchor = anchor;
    self.position = SPVec2Add(self.position, dif);    
}

- (SPFloat)tx {
	return _position.x;
}

- (void)setTx:(SPFloat)n {
	_position.x = n;
	[self setTransformNeedsUpdate];
}

- (SPFloat)ty {
	return _position.y;
}

- (void)setTy:(SPFloat)n {
	_position.y = n;
	[self setTransformNeedsUpdate];
}

- (SPFloat)sx {
	return _scale.x;
}

- (void)setSx:(SPFloat)n {
	_scale.x = n;
	[self setTransformNeedsUpdate];
}

- (SPFloat)sy {
	return _scale.y;
}

- (void)setSy:(SPFloat)n {
	_scale.y = n;
	[self setTransformNeedsUpdate];
}

- (SPFloat)ax {
	return _anchor.x;
}

- (void)setAx:(SPFloat)n {
	_anchor.x = n;
	[self setTransformNeedsUpdate];
}

- (SPFloat)ay {
	return _anchor.y;
}

- (void)setAy:(SPFloat)n {
	_anchor.y = n;
	[self setTransformNeedsUpdate];
}
@end
