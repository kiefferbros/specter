//
//  SPAtlasMesh.h
//  atlas
//
//  Created by Jonathan Kieffer on 4/2/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAtlasNode.h"

@interface SPAtlasMesh : SPAtlasNode

- (id)initWithBox:(SPBox)box;
- (id)initWithVertices:(SPVertex*)verts vertexCount:(uint)vtCount elements:(GLushort*)elems elementCount:(uint)elCount;

@property (nonatomic, readonly) SPVertex *verticesPointer;
@property (nonatomic, readonly) GLushort *elementsPointer;

@property (nonatomic, readonly) BOOL positionsNeedsUpdate;
@property (nonatomic, readonly) BOOL textureCoordinatesNeedUpdate;
@property (nonatomic, readonly) BOOL colorsNeedUpdate;


- (void)setVertices:(SPVertex*)verts vertexCount:(uint)vtCount elements:(GLushort*)elems elementCount:(uint)elCount;

- (void)updateVertices;
@end

