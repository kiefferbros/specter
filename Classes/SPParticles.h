//
//  Particles.h
//  Specter
//
//  Created by Jonathan on 6/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"
#import "SPGradient.h"

/* particle data*/
typedef struct SPPartInfo {
	SPVec2       v;
	SPTime      lifespan; // in seconds
	SPTime      age;	 // in seconds
} SPPartInfo;

/* GL Data*/
typedef struct SPPart {
	SPVec2      p;
	SPVec4      c;
	SPFloat     s;
} SPPart;

typedef enum SPParticleCoordSystem {
    SPParticleCoordSystemGlobal,
    SPParticleCoordSystemParent,
    SPParticleCoordSystemLocal
} SPParticleCoordSystem;

@protocol SPParticleEmitterDelegate;

@class SPGradient;
@interface SPParticleEmitter : SPSprite {
@private
	
	NSUInteger              _nParticles;
	SPPart                  *_parts;
	SPPartInfo              *_infos;
	GLuint                  _vertBuffer;
	
	SPVec2                   _gravity;	
    SPParticleCoordSystem   _coordSystem;
	
	SPFloat                 _radius;	// emitter radius
	NSUInteger              _initCount;	// number of particles to start out with
	NSUInteger              _maxCount;	// max number of particles
	SPTime                  _birthRate;	// how many particles added per second
	
	SPFloat                 _minSize, _maxSize;
	SPTime                  _minLifespan, _maxLifespan; // in seconds
	
	SPGradient              *_gradient;
	
	id <SPParticleEmitterDelegate> _delegate;
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
          coordSystem:(SPParticleCoordSystem)system;

- (void)initParticle:(SPPart*)part withInfo:(SPPartInfo*)info;
- (void)stepParticle:(SPPart*)part withInfo:(SPPartInfo*)info dt:(SPTime)dt;
@end


@protocol SPParticleEmitterDelegate <NSObject>
- (void)lastParticleDiedForParticleEmitter:(SPParticleEmitter*)emitter; 
@end

