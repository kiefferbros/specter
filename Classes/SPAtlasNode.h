//
//  SPAtlasNode.h
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 3/28/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPDrawableNode.h"
#import "SPLayer.h"



@interface SPAtlasNode : SPNode2D  

@property (nonatomic, assign) uint zIndex;
@property (strong, nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) BOOL indexPathNeedsUpdate;

@property (nonatomic, assign) SPVec3 color;
@property (nonatomic, assign) SPFloat opacity;
@property (nonatomic, assign) BOOL inheritOpacity;

@property (nonatomic, readonly) GLsizei vertexCount;
@property (nonatomic, readonly) GLsizei elementCount;

@property(nonatomic, readonly) SPBox contentBox;
@property(nonatomic, readonly) SPBox boundBox;
@property(nonatomic, readonly) SPBox globalBoundBox;

- (void)updateVertices:(SPColoredVertex**)vt withTransform:(SPTransform*)t opacity:(SPFloat)op index:(GLushort*)index;
- (void)updateElements:(GLushort**)el;

- (void)setVerticesNeedsUpdate;

- (void)setPositionsNeedsUpdate;
- (void)setTextureCoordinatesNeedUpdate;
- (void)setColorsNeedUpdate;
- (void)setIndexPathNeedsUpdate;

- (id)hitNode:(SPVec2)global;
- (NSArray*)boxHitNodes:(SPBox)box;

@end


