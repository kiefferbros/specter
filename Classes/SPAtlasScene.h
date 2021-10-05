//
//  SPAtlasScene.h
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 3/28/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPScene.h"
#import "SPTextureAtlas.h"
#import "SPAtlasNode.h"

typedef enum {
    SPAtlasSceneBufferUpToDate,
    SPAtlasSceneBufferSizeOutOfDate,
    SPAtlasSceneBufferDataOutOfDate,
} SPAtlasSceneBufferState;

@interface SPAtlasScene : SPScene

@property (nonatomic, strong) SPTextureAtlas *atlas;

@property (nonatomic, readonly) GLuint vertexBuffer;
@property (nonatomic, readonly) GLsizei vertexCount;
@property (nonatomic, readonly) GLuint elementBuffer;
@property (nonatomic, readonly) GLsizei elementCount;

@property (nonatomic, readonly) uint vertexBufferState;
@property (nonatomic, readonly) uint elementBufferState;

- (void)bind;
- (void)unbind;

- (void)setVertexBufferNeedsUpdate;


@end
