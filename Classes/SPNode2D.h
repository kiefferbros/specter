//
//  SPNode2D.h
//  Gravity
//
//  Created by Jonathan on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNode.h"

@interface SPNode2D : SPNode {
@package
	SPFloat				_rotation;  // in radians
	SPVec2				_position;	// center of node with a zero anchor
	SPVec2				_scale;
	
	SPVec2				_anchor;   // in local coords	
	
	SPTransform			_transform;
	BOOL				_transformNeedsUpdate;
}
@property(nonatomic, assign) SPFloat rotation;
@property(nonatomic, assign) SPVec2 position;
@property(nonatomic, assign) SPVec2 scale;
@property(nonatomic, assign) SPVec2 anchor;

// individual channels
@property(nonatomic, assign) SPFloat tx;
@property(nonatomic, assign) SPFloat ty;
@property(nonatomic, assign) SPFloat sx;
@property(nonatomic, assign) SPFloat sy;
@property(nonatomic, assign) SPFloat ax;
@property(nonatomic, assign) SPFloat ay;

// not the most effecient properties, use sparingly
@property(nonatomic, assign) SPVec2 globalPosition;
@property(nonatomic, readonly) SPFloat globalRotation;

// the local affine transform
@property(nonatomic, readonly) SPTransform transform; 
// concatenation of ancestors' transforms as well as the local transform
@property(nonatomic, readonly) SPTransform globalTransform;
@property (nonatomic, readonly) BOOL transformNeedsUpdate;

- (SPVec2)globalToLocal:(SPVec2)v;
- (void)setAnchorInPlace:(SPVec2)anchor;

- (void)setTransformNeedsUpdate;
@end
