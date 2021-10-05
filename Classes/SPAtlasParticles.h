//
//  Particles.h
//  Specter
//
//  Created by Jonathan on 6/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPAtlasSprite.h"
#import "SPGradient.h"
#import "SPParticles.h"

/*
typedef struct SPPart {
	SPVec2      p;
	SPVec4      c;
	SPFloat     s;
    SPVec2      v;
	SPTime      lifespan; // in seconds
	SPTime      age;	 // in seconds
} SPParticle;
 */

@interface SPAtlasParticle : SPAtlasSprite
@property (nonatomic, assign) SPVec2 velocity;
@property (nonatomic, assign) SPTime lifespan;
@property (nonatomic, assign) SPTime age;
@end

/*
typedef enum SPParticleCoordSystem {
    SPParticleCoordSystemGlobal,
    SPParticleCoordSystemParent,
    SPParticleCoordSystemLocal
} SPParticleCoordSystem;
 */

@protocol SPAtlasParticleEmitterDelegate;

@class SPGradient;
@interface SPAtlasParticleEmitter : SPAtlasNode {
@private	
    uint                    *_tags;
    uint                    _nTags;
    
	SPVec2                   _gravity;	
    SPParticleCoordSystem   _coordSystem;
	
	SPFloat                 _radius;	// emitter radius
	NSUInteger              _initCount;	// number of particles to start out with
	NSUInteger              _maxCount;	// max number of particles
	SPTime                  _birthRate;	// how many particles added per second
	
	SPFloat                 _minSize, _maxSize;
	SPTime                  _minLifespan, _maxLifespan; // in seconds
	
	SPGradient              *_gradient;
	
	id <SPAtlasParticleEmitterDelegate> _delegate;
}
@property (nonatomic, assign) SPVec2 gravity;
@property (nonatomic, readonly) SPParticleCoordSystem coordinateSystem;

@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, assign) SPTime birthRate;
@property (nonatomic, assign) SPFloat radius;


@property (nonatomic, assign) SPFloat minSize, maxSize;
@property (nonatomic, assign) SPTime minLifespan, maxLifespan;
@property (nonatomic) SPGradient *gradient;

@property (nonatomic, unsafe_unretained) id <SPParticleEmitterDelegate> delegate;

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
       coordSystem:(SPParticleCoordSystem)system;

- (void)initParticle:(SPAtlasParticle*)part;
- (void)stepParticle:(SPAtlasParticle*)part dt:(SPTime)dt;
@end


@protocol SPAtlasParticleEmitterDelegate <NSObject>
- (void)lastParticleDiedForAtlasParticleEmitter:(SPAtlasParticleEmitter*)emitter; 
@end

