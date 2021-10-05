//
//  SPAtlasSprite.h
//  atlas
//
//  Created by Jonathan Kieffer on 4/2/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAtlasMesh.h"
#import "SPAnimation.h"

@interface SPAtlasTagAnimation : SPAnimation
{
	uint				*_tags;
    uint                _nTags;
	SPTime				_frameInterval;  
}
- (id)initWithTags:(uint*)tags count:(uint)count frameInterval:(SPTime)frameInterval;
@end

@interface SPAtlasSprite : SPAtlasMesh 
- (id)initWithTag:(uint)atlasTag;
@property (nonatomic, assign) uint tag;
@end