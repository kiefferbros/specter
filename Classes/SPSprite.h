//
//  Sprite.h
//  GravHook
//
//  Created by Jonathan on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDrawableNode.h"
#import "SPAnimation.h"
#import "SPTextureAtlas.h"


@interface SPSpriteAnimation : SPAnimation
{
	NSArray				*_textures;  
	SPTime				_frameInterval;  
}
- (id)initWithTextures:(NSArray*)textures frameInterval:(SPTime)frameInterval;
@end


@interface SPSprite : SPDrawableNode {
	SPTexture				*_texture;
	SPVec3                  _color;	
    
    uint                    _atlasTag;
    GLuint                  _vbo;
}
@property(nonatomic) SPTexture *texture;
@property(nonatomic, assign) SPVec3 color;
@property(nonatomic, readonly) SPVec4 displayColor;
@property(nonatomic, assign) uint atlasTag;
- (id)initWithTexture:(SPTexture*)texture;
+ (id)sprite;
+ (id)spriteWithTexture:(SPTexture*)texture;

- (void)makeColorCurrent;
@end
