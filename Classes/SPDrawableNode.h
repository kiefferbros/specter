//
//  SPDrawableNode.h
//  Specter
//
//  Created by Jonathan on 3/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNode2D.h"

@class SPLayer;
@interface SPDrawableNode : SPNode2D {
	SPLayer *__unsafe_unretained _layer; // weak reference
    
    BOOL    _inheritOpacity;
    SPFloat _opacity;
}
@property(nonatomic, readonly) SPBox contentBox;
@property(nonatomic, readonly) SPBox boundBox;
@property(nonatomic, readonly) SPBox globalBoundBox;
@property(unsafe_unretained, nonatomic, readonly) SPLayer *layer;

@property (nonatomic, assign) SPFloat opacity;
@property (nonatomic, assign) BOOL inheritOpacity;
@property (nonatomic, readonly) SPFloat displayOpacity;


- (void)draw;
- (void)drawInBox:(SPBox)box;

// pushes and transforms the current modelview matrix to the node's specifications
- (void)beginTransform;
// pops the current modelview matrix
- (void)endTransform;

- (void)willChangeLayer;
- (void)didChangeLayer;

- (id)hitNode:(SPVec2)global;
- (NSArray*)boxHitNodes:(SPBox)box;
@end