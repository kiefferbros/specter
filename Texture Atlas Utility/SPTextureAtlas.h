//
//  SPTextureAtlas.h
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 3/22/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPTexture.h"

static const uint32_t kSPTextureAtlasTag = 'SPTA';

typedef struct _SPTextureAtlasHeader
{
	uint32_t atlasTag;
	uint32_t nMaps;
	uint32_t pngLength;
} SPTextureAtlasHeader;

typedef struct _SPTexAtlasMapCoords {
    uint32_t x, y, w, h;
} SPTexAtlasMapCoords;

typedef struct _SPTextureAtlasMap {
    SPBox t;
    SPVec2 s;
} SPTextureAtlasMap;

@interface SPTextureAtlas : SPTexture {
@private
    uint _nMaps;
    SPTextureAtlasMap *_map;
}

- (id)initWithAltasData:(NSData*)data scale:(SPFloat)texScale options:(SPTextureOptions)options;
- (SPTextureAtlasMap)mapWithTag:(uint)index;
@end
