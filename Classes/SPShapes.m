//
//  Shapes.m
//  Specter
//
//  Created by Jonathan on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPShapes.h"


@implementation SPCircle
@synthesize radius = _radius;
- (id)initWithRadius:(SPFloat)radius segments:(NSUInteger)segments {
	if ((self = [super initWithTexture:nil])) {
		_nVertices = (GLsizei)segments + 2;
		_vertices = (SPVec2*)malloc(sizeof(SPVec2)*_nVertices);
		
		_vertices[0] = SPVec2Zero;
		SPFloat t = 0.f;
		for (int i=1; i<=_nVertices-1; ++i, t+=SPPi2/segments) {
			_vertices[i] = SPVec2Make(radius*SPFastCosine(t), radius*SPFastSine(t));			
		}
		_vertices[_nVertices-1] = _vertices[1];
		
		_radius = radius;
		
		_color = SPColor3White;
	}
	return self;
}

- (void)dealloc {
	if (_vertices) free(_vertices);
}

- (void)draw {
	[self makeColorCurrent];
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, _nVertices);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (SPBox)contentBox {
	return SPBoxMake(-_radius, -_radius, _radius, _radius);
}

- (NSUInteger)segmentCount {
	return _nVertices - 2;
}
@end

@implementation SPRing
@synthesize innerRadius = _inRadius;
@synthesize outerRadius = _outRadius;
- (id)initWithInnerRadius:(SPFloat)inRadius outerRadius:(SPFloat)outRadius segments:(NSUInteger)segments {
	if ((self = [super initWithTexture:nil])) {
		_nVertices = (GLsizei)(segments + 1)*2;
		_vertices = (SPVec2*)malloc(sizeof(SPVec2)*_nVertices);
		
		
        inRadius = SPFloatMin(outRadius, inRadius);
        
		SPFloat t = 0.f;
		for (int i=0; i<=segments; ++i, t+=SPPi2/segments) {
            SPFloat c, s;
            c = SPFastCosine(t);
            s = SPFastSine(t);
			_vertices[i*2] = SPVec2Make(inRadius*c, inRadius*s);
			_vertices[i*2+1] = SPVec2Make(outRadius*c, outRadius*s);
		}
		
		_inRadius = inRadius;
        _outRadius = outRadius;
		
		_color = SPColor3White;
	}
	return self;
}

- (void)dealloc {
	if (_vertices) free(_vertices);
}

- (void)draw {
	[self makeColorCurrent];
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, _nVertices);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (SPBox)contentBox {
	return SPBoxMake(-_outRadius, -_outRadius, _outRadius, _outRadius);
}

- (NSUInteger)segmentCount {
	return _nVertices - 2;
}
@end


@implementation SPRectangle
- (id)initWithBox:(SPBox)box {
	if ((self = [super initWithTexture:nil])) {
		_box = box;
		_vertices[0] = SPVec2Make(box.l, box.b);
		_vertices[1] = SPVec2Make(box.l, box.t);
		_vertices[2] = SPVec2Make(box.r, box.b);
		_vertices[3] = SPVec2Make(box.r, box.t);
		_color = SPColor3White;
	}
	return self;
}

- (void)draw {
	[self makeColorCurrent];
	
	glDisable(GL_TEXTURE_2D);
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glEnable(GL_TEXTURE_2D);
}

- (SPBox)contentBox {
	return _box;
}
@end

@implementation SPRoundedRectangle
- (id)initWithBox:(SPBox)box radius:(SPFloat)radius segments:(NSUInteger)segments {
    if ((self = [super initWithTexture:nil])) {
        _nVertices = (GLsizei)(segments+1)*4 + 2;
		_vertices = (SPVec2*)malloc(sizeof(SPVec2)*_nVertices);
        
        _vertices[0] = SPVec2Make(box.l + SPBoxWidth(box)/2.f,box.b + SPBoxHeight(box)/2.f); // center point
        
        SPVec2 corner;
        for (int i=0; i<4; ++i) {
            
            switch (i) {
                case 0: corner = SPVec2Make(box.r-radius, box.t-radius); break; //rt
                case 1: corner = SPVec2Make(box.l+radius, box.t-radius); break; //lt
                case 2: corner = SPVec2Make(box.l+radius, box.b+radius); break; //lb
                case 3: corner = SPVec2Make(box.r-radius, box.b+radius); break; //rb
                
            }
            
            SPFloat t = i*SPPiD2;
            
            for (int j=0; j<=segments; ++j) {
                int k = 1 + ((int)segments+1)*i + j;
                _vertices[k] = SPVec2Make(radius*SPFastCosine(t) + corner.x, radius*SPFastSine(t) + corner.y);
                
                t+=SPPiD2/segments;
            }
        }
    
		_vertices[_nVertices-1] = _vertices[1];
        
        _box = box;
    }
    return  self;
}

- (void)dealloc {
	if (_vertices) free(_vertices);
}

- (void)draw {
	[self makeColorCurrent];
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, _nVertices);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}


- (SPBox)contentBox {
	return _box;
}
@end