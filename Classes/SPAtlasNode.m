//
//  SPAtlasNode.m
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 3/28/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAtlasNode.h"
#import "SPAtlasScene.h"
#import "SPTextureAtlas.h"

@interface SPAtlasScene ()
- (void)didAddAtlasNode:(SPAtlasNode*)node;
- (void)willRemoveAtlasNode:(SPAtlasNode*)node;
- (void)nodeDidChangeZIndex:(SPAtlasNode*)node;
@end

@interface SPNode()
- (void)_setScene:(SPScene *)aScene;
- (void)_setParent:(id)aParent;
@end

@implementation SPAtlasNode

- (id)init {
    if ((self = [super init])) {
         _color = SPColor3White;
        _opacity = 1.f;
        _inheritOpacity = YES;
        _indexPathNeedsUpdate = YES;
    }
    return self;
}

#pragma mark - Properties
@synthesize zIndex = _zIndex;
@synthesize color = _color;
@synthesize opacity = _opacity;
@synthesize inheritOpacity = _inheritOpacity;

- (void)setTransformNeedsUpdate {
    _transformNeedsUpdate = YES;
    [self setPositionsNeedsUpdate];
    [(SPAtlasScene*)self.scene setVertexBufferNeedsUpdate];
}

- (void)setVerticesNeedsUpdate {
    [self.children makeObjectsPerformSelector:@selector(setVerticesNeedsUpdate)];
}

- (void)setPositionsNeedsUpdate {
    [self.children makeObjectsPerformSelector:@selector(setPositionsNeedsUpdate)];
}

- (void)setColorsNeedUpdate {
    [self.children makeObjectsPerformSelector:@selector(setColorsNeedUpdate)];
}

- (void)setTextureCoordinatesNeedUpdate {
    
}

- (void)setColor:(SPVec3)color {
    _color = color;
    [(SPAtlasScene*)self.scene setVertexBufferNeedsUpdate];
}

- (void)setOpacity:(SPFloat)opacity {
    _opacity = opacity;
    [self setColorsNeedUpdate];
    [(SPAtlasScene*)self.scene setVertexBufferNeedsUpdate];
}

- (void)willChangeParent {
    [super willChangeParent];
    _indexPathNeedsUpdate = YES;
}

- (void)willChangeScene {
    [(SPAtlasScene*)self.scene willRemoveAtlasNode:self];
    [super willChangeScene];
    
}

- (void)didChangeScene {
    [(SPAtlasScene*)self.scene didAddAtlasNode:self];
    [super didChangeScene];
     
}

- (void)updateVertices:(SPColoredVertex**)vt withTransform:(SPTransform*)t opacity:(SPFloat)op index:(GLushort*)index {
    SPTransform st, nt;
    st = self.transform;
    SPTransformAffineMultPtr(&st, t, &nt);
    
    //t = SPTransformAffineMult(self.transform, t);
    op = self.inheritOpacity ? op*self.opacity : self.opacity;
    
    for (SPAtlasNode *node in self.children) {
        [node updateVertices:vt withTransform:&nt opacity:op index:index];
    }
}

- (void)updateElements:(GLushort**)el { }

- (GLsizei)vertexCount {
    return 0;
}

- (GLsizei)elementCount {
    return 0;
}

#pragma mark - Hierarchy
- (void)setZIndex:(uint)zIndex {
    if (zIndex != _zIndex) {
        _zIndex = zIndex;
        _indexPathNeedsUpdate = YES;
        [(SPAtlasScene*)self.scene nodeDidChangeZIndex:self];
    }
}



@synthesize indexPath = _indexPath;
- (NSIndexPath*)indexPath {
    if (_indexPathNeedsUpdate) {
        NSUInteger len, i=1;
        NSArray *ancestors = self.ancestors;
        len = ancestors.count + 2;
        NSUInteger idx[len];
        
        
        idx[0] = _zIndex;
        for (SPNode *node in ancestors) {
            idx[i] = node.childIndex;
            ++i;
        }
        idx[len-1] = self.childIndex;
        _indexPath = [[NSIndexPath alloc] initWithIndexes:idx length:len];
    }
    
    return _indexPath;
}

@synthesize indexPathNeedsUpdate = _indexPathNeedsUpdate;
- (void)setIndexPathNeedsUpdate {
    _indexPathNeedsUpdate = YES;
}

#pragma mark - Bounds
- (SPBox)contentBox {
	return SPBoxMake(0, 0, 0, 0);
}

- (SPBox)boundBox {	
	return SPBoxTransform(self.contentBox, self.transform);
}

- (SPBox)globalBoundBox {
	return SPBoxTransform(self.contentBox, self.globalTransform);
}

#pragma mark - Hit Tests
- (id)hitNode:(SPVec2)global {
    NSEnumerator *e = [self.children reverseObjectEnumerator]; 
    
    for (SPAtlasNode *n in e) {
        SPAtlasNode *c = [n hitNode:global];
        
        if (c!=nil) {
            return c;
        }
    }
    
    return SPBoxContainsVec(self.contentBox, [self globalToLocal:global]) ? self : nil;
}

- (void)addChildrenIntersectingBox:(SPBox)box toArray:(NSMutableArray**)array {
    if (SPBoxIntersects(self.globalBoundBox, box)) {
        [*array addObject:self];
    }
    
    for (id child in self.children) {
        [child addChildrenIntersectingBox:box toArray:array];
    }
}

- (NSArray*)boxHitNodes:(SPBox)box {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    [self addChildrenIntersectingBox:box toArray:&array];
    
    return array;
}
@end


