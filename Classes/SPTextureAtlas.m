//
//  SPTextureAtlas.m
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 3/22/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPTextureAtlas.h"



@implementation SPTextureAtlas
- (id)initWithAltasData:(NSData *)data scale:(SPFloat)texScale options:(SPTextureOptions)options {
    
    SPTextureAtlasHeader *header = (SPTextureAtlasHeader*)[data bytes];
    
    if (data==nil || header->atlasTag != kSPTextureAtlasFileTag) return nil;
    
    NSRange pngRange = NSMakeRange(sizeof(SPTextureAtlasHeader)+header->nMaps*sizeof(SPTexAtlasMapCoords), header->pngLength);
    NSData *pngData = [data subdataWithRange:pngRange];
    
    if ((self = [super initWithPNGData:pngData scale:texScale options:options])) {
        
        
        _nMaps = header->nMaps;
        _map = (SPTextureAtlasMap*)malloc(sizeof(SPTextureAtlasMap)*_nMaps);
        
        SPTexAtlasMapCoords *coord = (SPTexAtlasMapCoords *)([data bytes]+sizeof(SPTextureAtlasHeader));
        
        // convert the coords into the map structure
        for (int i=0; i<_nMaps; ++i) {
           _map[i].t = SPBoxMake((float)coord[i].x/(float)self.glWidth, 
                                  (float)coord[i].y/(float)self.glHeight,
                                  (float)(coord[i].x+coord[i].w)/(float)self.glWidth, 
                                  (float)(coord[i].y+coord[i].h)/(float)self.glHeight);
            
            _map[i].s = SPVec2Make((float)coord[i].w/self.scale, (float)coord[i].h/self.scale);
        }   
    }
    return self;
}

- (void)dealloc {
    if (_map) free(_map);
}

@synthesize mapCount = _nMaps;

- (SPTextureAtlasMap)mapWithTag:(uint)index {
    return _map[index];
}


- (void)setScale:(SPFloat)aScale {
    for (int i=0; i<_nMaps; ++i) {
        _map[i].s = SPVec2Scale(_map[i].s, self.scale);
    } 
    [super setScale:aScale];
    for (int i=0; i<_nMaps; ++i) {
        _map[i].s = SPVec2DivScale(_map[i].s, self.scale);
    } 

}
@end
