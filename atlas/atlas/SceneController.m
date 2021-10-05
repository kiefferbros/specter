//
//  SceneController.m
//  atlas
//
//  Created by Jonathan Kieffer on 3/30/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SceneController.h"
#import "SPTextureAtlas.h"
#import "SPAtlasSprite.h"
#import "SPAtlasScene.h"

@implementation SceneController
- (id)init {
    if ((self = [super init])) {
        SPTexturePack *pack = [[SPTexturePack alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gameplay" ofType:@"sptex"] preload:NO retain:NO];
        SPTextureAtlas *atlas = (SPTextureAtlas*)[pack textureNamed:@"gameplay"];
        
        SPAnimation *anim = [SPAnimation animationWithProperty:@"ty"];
        anim.interpolation = SPAnimationInterpolationWeighted;
        anim.autoreverses = YES;
        anim.repeatCount = -1;
        
        SPAnimation *ranim = [SPAnimation animationWithProperty:@"rotation"];
        ranim.interpolation = SPAnimationInterpolationWeighted;
        ranim.autoreverses = YES;
        ranim.repeatCount = -1;
        [ranim insertFloat:SPPiD2 atTime:0.0 weight:SPTimeWeightMake(1., 1.)];
        [ranim insertFloat:-SPPiD2 atTime:1. weight:SPTimeWeightMake(1., 1.)];
        
        SPAtlasScene *scene = [[SPAtlasScene alloc] init];
        scene.atlas = atlas;
        self.scene = scene;

        for (int c=0; c<7; ++c) {
            for (int r=0; r<10; ++r) {
                SPAtlasSprite *sprite = [[SPAtlasSprite alloc] initWithTag:95];
                sprite.position = SPVec2Make(c*120, r*120);
                [scene addChild:sprite];
                
                SPAtlasSprite *letter = [[SPAtlasSprite alloc] initWithTag:1];
                letter.position = SPVec2Make(15.f, 25.f);
                [sprite addChild:letter];
                
                
                [anim insertFloat:sprite.ty atTime:0.0 weight:SPTimeWeightMake(-1., 0)];
                [anim insertFloat:sprite.ty+50.f atTime:0.5 weight:SPTimeWeightMake(1., 0)];
                [sprite addAnimation:anim forKey:nil];
                [letter addAnimation:ranim forKey:nil];
            }
        }
        
        
        [scene removeChildAtIndex:0];
    }
    return self;
}

- (void)sceneDidAppear:(BOOL)animated {
    [(SPAtlasScene*)self.scene bind];
}

- (void)drawFrameInEAGLView:(EAGLView *)view {
#if DEBUG
    static unsigned long frame = 0;
    static CFTimeInterval totalTime = 0;    
    CFTimeInterval time = CFAbsoluteTimeGetCurrent();
#endif
    
    
    glClear(GL_COLOR_BUFFER_BIT);
    [self.scene draw:view.timeInterval];
    
#if DEBUG
    totalTime += CFAbsoluteTimeGetCurrent() - time;
    ++frame;
    if (frame%120==0)
        printf("%f\n", totalTime/frame);
#endif
}
@end
