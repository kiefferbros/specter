//
//  SPCamera.m
//  GravHook
//
//  Created by Jonathan on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPCamera.h"
#import "Specter.h"

@implementation SPCamera

@synthesize contentSize=_contentSize;
@synthesize viewport = _viewport;

- (void)begin {
	//glMatrixMode(GL_MODELVIEW);
    glLoadMatrixf(self.transform.m);
}

- (void)end {
}

- (void)reshape {
	[self reshapeWithSize:_contentSize viewport:_viewport];

}

- (void)reshapeWithSize:(SPVec2)size viewport:(SPBox)viewport {
	_contentSize = size;
    _viewport = viewport;
    
	//Set up OpenGL projection matrix
	glViewport(viewport.l, viewport.b, viewport.r, viewport.t);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
#if TARGET_OS_IPHONE
	glOrthof(0, size.x, 0, size.y, -1, 1);
#else
	glOrtho(0, size.x, 0, size.y, -1, 1);
#endif
	
	glMatrixMode(GL_MODELVIEW);

}

- (SPVec2)screenToGlobal:(SPVec2)p {
	//p.x = (p.x + _position.x)/_scale.x;
	//p.y = (p.y + _position.y)/_scale.y;
	return SPVec2Div(SPVec2Add(p, _position), _scale);
	
    //return SPVec2Transform(p, SPTransformAffineInvert(self.transform));	
}

- (SPBox)viewingBox {
	return SPBoxMake(_position.x, _position.y, _position.x+_contentSize.x, _position.y+_contentSize.y);
}

- (SPTransform )transform {
	if (_transformNeedsUpdate) {
		_transformNeedsUpdate = NO;
        
        _transform.m11 = _scale.x; _transform.m22 = _scale.y;
		_transform.m41 = -_position.x;
		_transform.m42 = -_position.y;
	}
	return _transform;
}

- (SPFloat)zoom {
    return _scale.x;
}

- (void)setZoom:(SPFloat)zoom {
    self.scale = SPVec2MakeUniform(zoom);
}


@end
