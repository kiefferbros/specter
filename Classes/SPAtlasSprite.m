//
//  SPAtlasSprite.m
//  atlas
//
//  Created by Jonathan Kieffer on 4/2/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAtlasSprite.h"
#import "SPAtlasScene.h"

@interface SPAtlasSprite ()
@property (nonatomic, assign) SPBox contentBox;

@end

@implementation SPAtlasSprite

- (id)initWithTag:(uint)atlasTag {
    if ((self = [super initWithBox:SPBoxZero])) {
        _tag = atlasTag;
    }
    return self;
}

@synthesize tag=_tag;
@synthesize contentBox=_contentBox;

- (void)setTag:(uint)tag {
    if (tag != _tag) {
        _tag= tag;
        [self updateVertices];
    }
}

- (SPBox)contentBox {
    return _contentBox;
}

- (void)updateVertices {
    SPAtlasScene *scene = (SPAtlasScene*)self.scene;
    
    if (self.tag > scene.atlas.mapCount) {
        return;
    }
    
    SPTextureAtlasMap map = [scene.atlas mapWithTag:self.tag];
    SPVertex *vt = self.verticesPointer;
    
    vt[0] = (SPVertex){0.f, 0.f, map.t.l, map.t.b};
    vt[1] = (SPVertex){0.f, map.s.y, map.t.l, map.t.t};
    vt[2] = (SPVertex){map.s.x, 0.f, map.t.r, map.t.b};
    vt[3] = (SPVertex){map.s.x, map.s.y, map.t.r, map.t.t};
    
    _contentBox = SPBoxMake(0.f, 0.f, map.s.x, map.s.y);
    
    [super updateVertices];
    
}
@end


@implementation SPAtlasTagAnimation
- (id)initWithTags:(uint*)tags count:(uint)count frameInterval:(SPTime)frameInterval {
	if ((self = [super initWithProperty:@"texture"])) {
		_frameInterval = frameInterval;
		_nTags = count;
        
        _tags = (uint*)malloc(sizeof(uint)*count);
        memcpy(_tags, tags, sizeof(uint)*count);
	}
	return self;
}

- (void)dealloc {
    free(_tags);
}

- (id)copyWithZone:(NSZone *)zone {
	SPAtlasTagAnimation *copy = [super copyWithZone:zone];
	copy->_frameInterval = _frameInterval;
    copy->_nTags = _nTags;
	copy->_tags = (uint*)malloc(sizeof(uint)*_nTags);
    memcpy(copy->_tags, _tags, sizeof(uint)*_nTags);
	return copy;
}

- (SPTime)duration {
	return _nTags*_frameInterval;
}

- (void)setNextValue {
	NSUInteger index = self.currentTime/_frameInterval;
	
	uint tag = (index < _nTags) ? _tags[index] : _tags[_nTags-1];	
    
    ((SPAtlasSprite*)self.node).tag = tag;
}
@end
