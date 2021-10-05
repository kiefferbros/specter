//
//  Sprite.m
//  GravHook
//
//  Created by Jonathan on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPSprite.h"
#import "SPScene.h"
#if TARGET_OS_IPHONE
#import <OpenGLES/ES1/glext.h>
#endif

@interface SPSprite ()
- (void)_updateVBO;
@end

@implementation SPSprite
@synthesize  color=_color;

- (id)init {
	self = [self initWithTexture:nil];
	return self;
}

- (id)initWithTexture:(SPTexture*)texture {
	if ((self= [super init])) {
		_anchor = SPVec2Zero;
		
		_color = SPColor3White;
        glGenBuffers(1, &_vbo);
        glBindBuffer(GL_ARRAY_BUFFER, _vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(SPVertex)*4, NULL, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        self.texture = texture;
        
	}
	return self;
}

+ (id)spriteWithTexture:(SPTexture*)texture {
	id sprite = [[[self class] alloc] initWithTexture:texture];
	return sprite;
}

+ (id)sprite {
	return [[self class] spriteWithTexture:nil];
}

- (void)dealloc {
    glDeleteBuffers(1, &_vbo);
}

- (SPTexture*)texture {
    return _texture;
}

- (void)_updateVBO {
    if (_texture) {
        glBindBuffer(GL_ARRAY_BUFFER, _vbo);
#if TARGET_OS_IPHONE
        SPVertex *vt = (SPVertex*)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
#else 
        SPVertex *vt = (SPVertex*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
#endif
        SPVec2 s;
        SPBox t;
        if ([_texture isKindOfClass:[SPTextureAtlas class]]) {
            SPTextureAtlasMap map = [(SPTextureAtlas*)_texture mapWithTag:_atlasTag];
            
            s = map.s;
            t = map.t;
        } else {
            s = _texture.contentSize;
            t = SPBoxMake(0.f, 0.f, _texture.maxS, _texture.maxT);
        }
        
        vt[0].p.x = 0.f;
        vt[1].p.x = 0.f;
        vt[2].p.x = s.x;
        vt[3].p.x = s.x;
        vt[0].p.y = 0.f; 
        vt[2].p.y = 0.f;
        vt[1].p.y = s.y;
        vt[3].p.y = s.y;
        
        vt[0].t.x = t.l;
        vt[1].t.x = t.l;
        vt[2].t.x = t.r;
        vt[3].t.x = t.r;
        vt[0].t.y = t.b;
        vt[2].t.y = t.b;
        vt[1].t.y = t.t;
        vt[3].t.y = t.t;
        
#if TARGET_OS_IPHONE        
        glUnmapBufferOES(GL_ARRAY_BUFFER);
#else 
        glUnmapBuffer(GL_ARRAY_BUFFER);
#endif
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

}

- (void)setTexture:(SPTexture *)texture {
    if (_texture != texture) {
        _texture = texture;
        [self _updateVBO];
    }
}

- (uint)atlasTag {
    return _atlasTag;
}

- (void)setAtlasTag:(uint)tag {
    if (_atlasTag != tag) {
        _atlasTag = tag;
        [self _updateVBO];
    }
}

- (void)makeColorCurrent {
    SPFloat op = self.displayOpacity;
    glColor4f(_color.x*op, _color.y*op, _color.z*op, op);
}

- (SPVec4)displayColor {
    SPFloat op = self.displayOpacity;
    return (SPVec4){_color.x*op, _color.y*op, _color.z*op, op};
}

- (void)draw {	
	// do the drawing
	if (self.texture)  {
		[self makeColorCurrent];

		glBindTexture(GL_TEXTURE_2D, _texture.glName);
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
        
		glVertexPointer(2, GL_FLOAT, sizeof(SPVertex), 0);
		glTexCoordPointer(2, GL_FLOAT, sizeof(SPVertex), (GLvoid*)(sizeof(GLfloat)*2));

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
        
	}
}

- (CGRect)frame {
	CGSize size = CGSizeMake(_scale.x*_texture.contentSize.x, _scale.y*_texture.contentSize.y);
	return CGRectMake(_position.x-(size.width/2.0f)-_anchor.x, _position.y-(size.height/2.0f)-_anchor.y, size.width, size.height);
}


- (SPBox)contentBox {
	return SPBoxMake(0.f, 0.f, _texture.contentSize.x, _texture.contentSize.y);
}
@end

@implementation SPSpriteAnimation
- (id)initWithTextures:(NSArray*)textures frameInterval:(SPTime)frameInterval {
	if ((self = [super initWithProperty:@"texture"])) {
		_frameInterval = frameInterval;
		_textures = textures;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	SPSpriteAnimation *copy = [super copyWithZone:zone];
	copy->_frameInterval = _frameInterval;
	copy->_textures = [_textures copy];
	return copy;
}

- (SPTime)duration {
	return [_textures count]*_frameInterval;
}

- (void)setNextValue {
	NSUInteger index = MIN(self.currentTime/_frameInterval, _textures.count-1);
	
	SPTexture *texture = (index < [_textures count]) ? [_textures objectAtIndex:index] : nil;	
    ((SPSprite*)self.node).texture = texture;
}
@end
