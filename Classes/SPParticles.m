//
//  Particles.m
//  Specter
//
//  Created by Jonathan on 6/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPParticles.h"
#import "Specter.h"
#import "SPStepAnimation.h"

@interface SPParticleEmitter ()
- (void)notifyDelegate;
- (void)birthParticles:(NSUInteger)count deathCount:(NSUInteger)deathCount;
@end


@implementation SPParticleEmitter
@synthesize gravity = _gravity;

@synthesize maxCount = _maxCount;
@synthesize birthRate = _birthRate;
@synthesize radius = _radius;


@synthesize minSize = _minSize, maxSize = _maxSize;
@synthesize minLifespan = _minLifespan, maxLifespan = _maxLifespan;
@synthesize gradient = _gradient;

@synthesize delegate;

- (id)initWithTexture:(SPTexture*)texture 
			   radius:(SPFloat)aRadius 
		   startCount:(NSUInteger)initCount
			birthRate:(SPTime)rate 
			 maxCount:(NSUInteger)maxParts
			  minSize:(SPFloat)minS 
			  maxSize:(SPFloat)maxS  
		  minLifespan:(SPTime)minL 
		  maxLifespan:(SPTime)maxL
			 gradient:(SPGradient*)aGradient 
          coordSystem:(SPParticleCoordSystem)system
{
	if ((self = [super initWithTexture:texture])) {	
		
		
		// enable gl sprite drawing
#if TARGET_OS_IPHONE
		glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
#else 
        glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
#endif
		
		// vertex buffer
		glGenBuffers(1, &_vertBuffer);
		
		_radius = aRadius;
		_initCount = initCount;
		_birthRate = rate;
		_maxCount = maxParts;
		_minSize = minS;
		_maxSize = maxS;
		_minLifespan = minL;
		_maxLifespan = maxL;
		self.gradient = aGradient;	
        _coordSystem = system;
		
		_nParticles = 0;
        
        SPStepAnimation *anim = [[SPStepAnimation alloc] init];
        [self addAnimation:anim forKey:nil];
	}
	return self;
}

- (void)dealloc {
	glDeleteBuffers(1, &_vertBuffer);
	free(_parts);
	free(_infos);
}

- (void)didChangeParent {
    if (_initCount || _nParticles)
        [self birthParticles:_initCount deathCount:_nParticles];
    
    for (int i=0; i<_nParticles; ++i) {
        _infos[i].age = SPFloatRandom()*(_infos[i].lifespan*0.9);
    }
}

@synthesize coordinateSystem=_coordSystem;

- (void)birthParticles:(NSUInteger)birthCount deathCount:(NSUInteger)deathCount {
	NSUInteger oldCount = _nParticles;
	NSUInteger newCount = MIN((_nParticles - deathCount ) + birthCount, _maxCount);

	SPPart *buffer = NULL;
	SPPartInfo *iBuffer = NULL;
	if (newCount) {
		buffer = (SPPart*)malloc(sizeof(SPPart)*newCount);
		iBuffer = (SPPartInfo*)malloc(sizeof(SPPartInfo)*newCount);
		
        
        for (int i=0; i<birthCount; ++i) {	
			[self initParticle:&buffer[i] withInfo:&iBuffer[i]];
		}
        
        int j=(int)birthCount;
		if (oldCount) {
			for (int i=0; i<oldCount; ++i) {
				if (_infos[i].age <= _infos[i].lifespan) {
					buffer[j] = _parts[i];
					iBuffer[j] = _infos[i];
					++j;
				}
			}
		}
	}
	
    if (_parts)
        free(_parts);
    if (_infos)
        free(_infos);
	_parts = buffer;
	_infos = iBuffer;
	_nParticles = newCount;	
}

- (void)initParticle:(SPPart*)part withInfo:(SPPartInfo*)info {
	// set the particle up
	SPVec2 p = SPVec2Make(SPFloatRandom()*_radius*2-_radius, SPFloatRandom()*_radius*2-_radius);    
	SPFloat len = SPVec2Length(p);
	SPFloat dist = SPFloatRandom()*_radius;
	p = SPVec2Scale(p, dist/len);
    
    switch (_coordSystem) {
        case SPParticleCoordSystemGlobal:
            p = SPVec2Add(self.globalPosition, p);
            break;
        case SPParticleCoordSystemParent:
            p = SPVec2Add(self.position, p);
            break;
        case SPParticleCoordSystemLocal:
            break;
    }
	
	part->p = p;
	info->v = SPVec2Zero;
    if (self.gradient)
        [_gradient getColor:(SPFloat*)(&part->c) atLocation:0.f];
    else 
        part->c = self.displayColor;
    
	
	part->s = (_minSize + SPFloatRandom()*(_maxSize-_minSize))*self.texture.scale;	
	
	info->lifespan = (_minLifespan == _maxLifespan) ? _minLifespan : _minLifespan + SPFloatRandom()*(_maxLifespan-_minLifespan);
	info->age = 0.;
}

- (void)stepParticle:(SPPart*)part withInfo:(SPPartInfo*)info dt:(SPTime)dt{
	if (self.gradient) {
		SPFloat ageDelta = (SPFloat)info->age/(SPFloat)info->lifespan;
        SPVec4 color;
        [_gradient getColor:(SPFloat*)(&color) atLocation:ageDelta];
        part->c = SPVec4Mult(color, self.displayColor);
		//part->c = SPVec4Mult([self.gradient colorAtPosition:ageDelta], self.displayColor);
		//part->c = [self.gradient colorAtPosition:ageDelta];
	}
	
	info->v = SPVec2Add(info->v, _gravity);
	part->p = SPVec2Add(part->p, info->v);
	
}

- (void)step:(SPTime)dt {
	NSUInteger dieCount = 0, birthCount = 0;
	for (int i=0; i<_nParticles; ++i) {
		_infos[i].age += dt;
		
		if (_infos[i].age > _infos[i].lifespan) {
			++dieCount;
		} else {
			[self stepParticle:&_parts[i] withInfo:&_infos[i] dt:dt];
		}
	}
	
    if (_birthRate > 0.f) {
        SPFloat birthFloat = _birthRate*dt;
        birthCount = birthFloat;
        SPFloat mirand = birthFloat - floorf(birthFloat);
        if (SPFloatRandom() <= mirand)
            birthCount++;
    }
    
    if (birthCount || dieCount) {
        [self birthParticles:birthCount deathCount:dieCount];
    }
	
	if (!_nParticles && _birthRate <= 0.f && self.delegate) {
		// make sure this is called after the the entire scene has been drawn
		//[self performSelector:@selector(notifyDelegate) withObject:nil afterDelay:0.0];
        [_delegate lastParticleDiedForParticleEmitter:self];
	}
} 

- (void)notifyDelegate {
	[_delegate lastParticleDiedForParticleEmitter:self];
}

- (void)beginTransform {
    switch (_coordSystem) {
        case SPParticleCoordSystemGlobal:
            glPushMatrix();
            glLoadIdentity();
            break;
        case SPParticleCoordSystemParent:
            break;
        case SPParticleCoordSystemLocal:
            [super beginTransform];
            break;
    }
}

- (void)drawInBox:(SPBox)box {
	
	if (_nParticles) {
        
		[self beginTransform];
		glBindTexture(GL_TEXTURE_2D, self.texture.glName);
        
       
		glBindBuffer(GL_ARRAY_BUFFER, _vertBuffer);
         
#if TARGET_OS_IPHONE
		glEnable(GL_POINT_SPRITE_OES);
        glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
#else 
        glEnable(GL_POINT_SPRITE);
        glEnableClientState(GL_POINT_SIZE_ARRAY_APPLE);
#endif

		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
        
		// copy the data to the vbo        
        glBufferData(GL_ARRAY_BUFFER, sizeof(SPPart)*_nParticles, _parts, GL_DYNAMIC_DRAW);
	
		glVertexPointer(2, GL_FLOAT, sizeof(SPPart), 0);
		glColorPointer(4, GL_FLOAT, sizeof(SPPart), (GLvoid*)sizeof(SPVec2));
#if TARGET_OS_IPHONE
		glPointSizePointerOES(GL_FLOAT, sizeof(SPPart),(GLvoid*)(sizeof(GLfloat)*6));
#else
        glPointSizePointerAPPLE(GL_FLOAT, sizeof(SPPart), (GLvoid*)(sizeof(GLfloat)*6));
#endif
		glDrawArrays(GL_POINTS, 0, (GLsizei)_nParticles);
	 

#if TARGET_OS_IPHONE
        glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
        glDisable(GL_POINT_SPRITE_OES);
#else
        glDisableClientState(GL_POINT_SIZE_ARRAY_APPLE);
        glDisable(GL_POINT_SPRITE);
#endif
		glDisableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		[self endTransform];
	}
}

- (SPBox)contentBox {
	return SPBoxMake(-_radius, -_radius, _radius, _radius);
}
@end
