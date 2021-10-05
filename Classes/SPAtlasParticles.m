//
//  Particles.m
//  Specter
//
//  Created by Jonathan on 6/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPAtlasParticles.h"
#import "Specter.h"
#import "SPStepAnimation.h"

@implementation SPAtlasParticle
@synthesize velocity = _velocity;
@synthesize lifespan = _lifespan;
@synthesize age = _age;
@end

@implementation SPAtlasParticleEmitter
@synthesize gravity = _gravity;

@synthesize maxCount = _maxCount;
@synthesize birthRate = _birthRate;
@synthesize radius = _radius;

@synthesize minSize = _minSize, maxSize = _maxSize;
@synthesize minLifespan = _minLifespan, maxLifespan = _maxLifespan;
@synthesize gradient = _gradient;

@synthesize delegate;

- (id)initWithTags:(uint*)tags
          tagCount:(uint)nTags
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
	if ((self = [super init])) {
        
        if (nTags==0) return nil;
        
        _nTags = nTags;
        _tags = (uint*)malloc(sizeof(uint)*nTags);
        memcpy(_tags, tags, sizeof(uint)*nTags);
        
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
        
        SPStepAnimation *anim = [[SPStepAnimation alloc] init];
        [self addAnimation:anim forKey:nil];
	}
	return self;
}

- (void)dealloc {
    free(_tags);
}

- (void)didChangeScene {
    [super didChangeScene];
    if (self.scene) {
        if (_initCount || self.childCount)
            [self birthParticles:_initCount deathCount:self.childCount];
        
        
        for (SPAtlasParticle *part in self.children) {
            part.age = SPFloatRandom()*(part.lifespan*0.5);
        }
    }
}

@synthesize coordinateSystem=_coordSystem;

- (void)birthParticles:(NSUInteger)birthCount deathCount:(NSUInteger)deathCount {
    
	NSUInteger newCount = MIN((self.childCount - deathCount ) + birthCount, _maxCount);

	if (newCount==0) {
        [self removeAllChildren];
    } else if (newCount < self.childCount) {
        int i=0;
        while (newCount < self.childCount) {
            SPAtlasParticle *part = [self childAtIndex:i];
            if (part.age>part.lifespan) {
                [self removeChildAtIndex:i];
            } else {
                ++i;
            }
        }
    } else if (newCount > self.childCount) {
        int i=0;
        while (newCount > self.childCount) {
            SPAtlasParticle *part = nil;
            if (i>=self.childCount) {
                int tagIdx = SPFloatRandom()*_nTags;
                part = [[SPAtlasParticle alloc] initWithTag:_tags[tagIdx]];
                
                [self insertChild:part atIndex:0];
                [self initParticle:part];
    
                // keep the anchor in the center of the particle
                SPBox box = part.contentBox;
                part.anchor = SPVec2Scale(SPVec2Make(SPBoxWidth(box), SPBoxHeight(box)), 0.5f);
            } else {
                part = [self childAtIndex:i];
                if (part.age>part.lifespan) {
                    [self initParticle:part];
                }
            }
            ++i;
        }
    }     
}

- (void)initParticle:(SPAtlasParticle*)part {
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
	
	part.position = p;
	part.velocity = SPVec2Zero;
    part.zIndex = self.zIndex;
    
    if (self.gradient) {
        SPVec4 c;
        [self.gradient getColor:(SPFloat*)(&c) atLocation:0.f];
        part.color = SPVec3Make(c.x, c.y, c.z);
        part.opacity = c.w;
    }
	
	part.scale =  SPVec2MakeUniform(_minSize + SPFloatRandom()*(_maxSize-_minSize));	
	part.lifespan = (_minLifespan == _maxLifespan) ? _minLifespan : _minLifespan + SPFloatRandom()*(_maxLifespan-_minLifespan);
    part.age = 0.;
}

- (void)stepParticle:(SPAtlasParticle*)part dt:(SPTime)dt{
	if (self.gradient) {
        SPVec4 c;
        [self.gradient getColor:(SPFloat*)(&c) atLocation:part.age/part.lifespan];
        part.color = SPVec3Make(c.x, c.y, c.z);
        part.opacity = c.w;
	}
	
	part.velocity = SPVec2Add(part.velocity, SPVec2Scale(_gravity, dt*dt));
	part.position = SPVec2Add(part.position, SPVec2Scale(part.velocity, dt));
	
}

- (void)step:(SPTime)dt {
	NSUInteger dieCount = 0, birthCount = 0;
    for (SPAtlasParticle *part in self.children) {
        part.age += dt;
        
        if (part.age > part.lifespan)
            ++dieCount;
        else
            [self stepParticle:part dt:dt];
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
	
	if (!self.childCount && _birthRate <= 0.f && self.delegate) {
        [_delegate lastParticleDiedForAtlasParticleEmitter:self];
	}
} 


- (void)updateVertices:(SPColoredVertex**)vt withTransform:(SPTransform*)t opacity:(SPFloat)op index:(GLushort*)index {
    SPTransform nt;
    switch (_coordSystem) {
        case SPParticleCoordSystemGlobal:
            nt = SPTransformIdentity;
            break;
        case SPParticleCoordSystemParent:
            memcpy(nt.m, t->m, sizeof(SPTransform));
            break;
        case SPParticleCoordSystemLocal:
        {
            SPTransform st = self.transform;
            SPTransformAffineMultPtr(&st, t, &nt);
            //t = SPTransformAffineMult(self.transform, t);
            break;
        }
    }
    
    op = self.inheritOpacity ? op*self.opacity : self.opacity;
    
    for (SPAtlasNode *node in self.children) {
        [node updateVertices:vt withTransform:&nt opacity:op index:index];
    }
}

- (SPBox)contentBox {
	return SPBoxMake(-_radius, -_radius, _radius, _radius);
}
@end
