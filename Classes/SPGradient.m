//
//  SPGradient.m
//  MonsterSoup
//
//  Created by Jonathan on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPGradient.h"
#import "SPGeometry.h"
#include <stdio.h>
#include <string.h>

@implementation SPGradient
- (id)initWithColors:(SPFloat*)colors locations:(SPFloat*)locations componentCount:(NSUInteger)nComps stopCount:(NSUInteger)nStops {
	if ((self = [super init])) {
		if (nStops < 2) {
			return nil;
		}
		
        _nComponents = nComps;
		_nStops = nStops;
		_color = (SPFloat*)malloc(sizeof(SPFloat)*nStops*nComps);
		memcpy(_color, colors, sizeof(SPFloat)*nStops*nComps);
		_location = (SPFloat*)malloc(sizeof(SPFloat)*nStops);
		memcpy(_location, locations, sizeof(SPFloat)*nStops);
		
	}
	return self;
}

- (void)dealloc {
	free(_location);
	free(_color);
}

@synthesize componentCount = _nComponents;
@synthesize stopCount = _nStops;

- (void)getColor:(out SPFloat*)color atLocation:(SPFloat)delta {
	if (delta <= _location[0])
		memcpy(color, _color, sizeof(SPFloat)*_nComponents);
	else if (delta >= _location[_nStops-1])
        memcpy(color, _color+(_nStops-1)*_nComponents, sizeof(SPFloat)*_nComponents);
	
    int i=1;
    while (delta > _location[i]) ++i;
    int j=i-1;
    
    SPFloat spread = _location[i]-_location[j];
    SPFloat d = (delta - _location[j])/spread;
    
    for (int k=0; k<_nComponents; ++k) {
        color[k] = SPFloatLerp(_color[j*_nComponents], _color[i*_nComponents], d);
    }
}


@end


