//
//  SPShapes.h
//  Specter
//
//  Created by Jonathan on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"




@interface SPCircle : SPSprite {
@package
	GLsizei	_nVertices;
	SPVec2		*_vertices;
	SPFloat		_radius;
}
@property (nonatomic, readonly) SPFloat radius;
@property (nonatomic, readonly) NSUInteger segmentCount;
- (id)initWithRadius:(SPFloat)radius segments:(NSUInteger)segments;
@end


@interface SPRing : SPSprite {
    @package
	GLsizei	_nVertices;
	SPVec2		*_vertices;
	SPFloat		_inRadius, _outRadius;
}
@property (nonatomic, readonly) SPFloat innerRadius, outerRadius;
@property (nonatomic, readonly) NSUInteger segmentCount;
- (id)initWithInnerRadius:(SPFloat)inRadius outerRadius:(SPFloat)outRadius segments:(NSUInteger)segments;
@end

@interface SPRectangle : SPSprite {
@package
	SPVec2	_vertices[4];
	SPBox	_box;
}
- (id)initWithBox:(SPBox)box;
@end

@interface SPRoundedRectangle : SPSprite {
@package
    GLsizei	_nVertices;
    SPVec2 *_vertices;
    SPBox	_box;
}
/*
 box - boundbox for rectangle
 radius - corner radius
 segments - number of segments per corner
*/
- (id)initWithBox:(SPBox)box radius:(SPFloat)radius segments:(NSUInteger)segments;
@end

