//
//  SPAtlasMesh.m
//  atlas
//
//  Created by Jonathan Kieffer on 4/2/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAtlasMesh.h"
#import "SPAtlasScene.h"

@interface SPAtlasMesh ()
@property (nonatomic, assign) GLushort firstElement;
@end

@interface SPNode()
- (void)_setScene:(SPScene *)aScene;
@end

@interface SPAtlasScene ()
- (void)meshWillChangeVertexCount:(SPAtlasMesh*)mesh;
- (void)meshDidChangeVertexCount:(SPAtlasMesh*)mesh;
@end

@implementation SPAtlasMesh

- (id)initWithBox:(SPBox)box {
    if ((self = [super init])) {
        _vtCount = 4;
        _elCount = 4;
        
        _verts = (SPVertex*)malloc(sizeof(SPVertex)*_vtCount);
        _verts[0]=(SPVertex){box.l, box.b, 0.f, 0.f}; _verts[1]=(SPVertex){box.l, box.t, 0.f, 1.f};
        _verts[2]=(SPVertex){box.r, box.b, 1.f, 0.f}; _verts[3]=(SPVertex){box.r, box.t, 1.f, 1.f};
        
        _elems = (GLushort*)malloc(sizeof(GLushort)*_elCount);
        _elems[0]=0;_elems[1]=1;_elems[2]=2;_elems[3]=3;
        
        _updatePos = YES;
        _updateTex = YES;
        _updateColor = YES;
    }
    return self;
}

- (id)initWithVertices:(SPVertex*)verts vertexCount:(uint)vtCount elements:(GLushort*)elems elementCount:(uint)elCount {
    if ((self = [super init])) {
        _vtCount = vtCount;
        _verts = (SPVertex*)malloc(sizeof(SPVertex)*vtCount);
        memcpy(_verts, verts, sizeof(SPVertex)*vtCount);
        
        _elCount = elCount;
        _elems = (GLushort*)malloc(sizeof(GLushort)*_elCount);
        memcpy(_elems, elems, sizeof(GLushort)*_elCount);
        
        _updatePos = YES;
        _updateTex = YES;
        _updateColor = YES;
    }
    return self;
}


- (void)dealloc {
    free(_verts);
    free(_elems);
}


@synthesize verticesPointer = _verts;
@synthesize vertexCount = _vtCount;
@synthesize elementsPointer = _elems;
@synthesize elementCount = _elCount;

@synthesize firstElement = _firstElement;

@synthesize positionsNeedsUpdate = _updatePos;
@synthesize textureCoordinatesNeedUpdate = _updateTex;
@synthesize colorsNeedUpdate = _updateColor;

- (void)setVertices:(SPVertex *)verts vertexCount:(uint)vtCount elements:(GLushort *)elems elementCount:(uint)elCount {
    [(SPAtlasScene*)self.scene meshWillChangeVertexCount:self];
    
    _vtCount = vtCount;
    _verts = (SPVertex*)malloc(sizeof(SPVertex)*vtCount);
    memcpy(_verts, verts, sizeof(SPVertex)*vtCount);
    
    _elCount = elCount;
    _elems = (GLushort*)malloc(sizeof(GLushort)*_elCount);
    memcpy(_elems, elems, sizeof(GLushort)*_elCount);    
    
    [(SPAtlasScene*)self.scene meshDidChangeVertexCount:self];
}


- (void)didChangeScene {
    if (self.scene) [self updateVertices];
    [super didChangeScene];
}

- (void)updateVertices {
    _updatePos = YES;
    _updateTex = YES;
    [(SPAtlasScene*)self.scene setVertexBufferNeedsUpdate];
}

- (void)setVerticesNeedsUpdate {
    _updatePos = YES;
    _updateTex = YES;
    _updateColor = YES;
    [super setVerticesNeedsUpdate];
}

- (void)setPositionsNeedsUpdate {
    _updatePos = YES;
    [super setPositionsNeedsUpdate];
}

- (void)setTextureCoordinatesNeedUpdate {
    _updateTex = YES;
}

- (void)setColorsNeedUpdate {
    _updateColor = YES;
    [super setColorsNeedUpdate];
}

- (void)setColor:(SPVec3)color {
    [super setColor:color];
    _updateColor = YES;
}

- (void)updateColors:(SPColoredVertex*)v opacity:(SPFloat)op count:(GLsizei)vtCount {
    SPVec3 col = self.color;
    SPVec4 c = (SPVec4){col.x*op, col.y*op, col.z*op, op};
    for (int i=0; i<vtCount; ++i) {
        v[i].c = c;
    }
}

- (void)updateVertices:(SPColoredVertex**)vt withTransform:(SPTransform*)t opacity:(SPFloat)op index:(GLushort*)index {
    SPTransform st, nt;
    st = self.transform;
    SPTransformAffineMultPtr(&st, t, &nt);
    op = self.inheritOpacity ? op*self.opacity : self.opacity;    

    GLsizei vtCount = self.vertexCount;
    
    if (vtCount) {
        SPColoredVertex *v = *vt;
        if (_updatePos) {
            _updatePos = NO;
            for (int i=0; i<vtCount; ++i) {
                v[i].p = SPVec2TransformPtr(_verts[i].p, &nt);
            }
        }
        
        if (_updateTex) {
            _updateTex = NO;
            for (int i=0; i<vtCount; ++i) {
                v[i].t = _verts[i].t;
            }
        }
        
        if (_updateColor) {
            _updateColor = NO;
            [self updateColors:v opacity:op count:vtCount];
        }
        
        *vt = v+vtCount;
        _firstElement = *index;
        *index = _firstElement+vtCount;
    }
    
    for (SPAtlasNode *node in self.children) {
        [node updateVertices:vt withTransform:&nt opacity:op index:index];
    }
}

- (void)updateElements:(GLushort**)el {
    GLushort *e = *el;
    GLsizei elCount = self.elementCount;
    
    e[0] = _elems[0]+_firstElement;
    for (int j=0; j<elCount; ++j)
        e[j+1] = _elems[j]+_firstElement;
    e[elCount+1] = _elems[elCount-1]+_firstElement;
    
    e += elCount+2;
    *el = e;
}

@end
