//
//  SPCamera.h
//  GravHook
//
//  Created by Jonathan on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNode2D.h"

@interface SPCamera : SPNode2D {
	SPVec2 _contentSize;
    SPBox _viewport;
}
@property(nonatomic, readonly) SPVec2 contentSize;
@property(nonatomic, readonly) SPBox viewingBox;
@property(nonatomic, readonly) SPBox viewport;
@property(nonatomic, assign) SPFloat zoom;

- (void)reshapeWithSize:(SPVec2)size viewport:(SPBox)viewport;
- (void)reshape;

- (void)begin;
- (void)end;

- (SPVec2)screenToGlobal:(SPVec2)position;
@end
