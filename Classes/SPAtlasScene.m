//
//  SPAtlasScene.m
//  Albatross Level Editor
//
//  Created by Jonathan Kieffer on 3/28/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAtlasScene.h"
#import "SPAtlasMesh.h"
#import "Specter.h"

#define SPColoredVertexSize sizeof(SPColoredVertex)
#define SPVertexPtrOffset (GLvoid*)0
#define SPTexCoordPtrOffset (GLvoid*)(sizeof(SPFloat)*2)
#define SPColorPtrOffset (GLvoid*)(sizeof(SPFloat)*4)


@interface SPAtlasScene ()
@property (nonatomic, strong) NSMutableArray *meshNodes;
- (void)didAddAtlasNode:(SPAtlasNode*)node;
- (void)willRemoveAtlasNode:(SPAtlasNode*)node;
- (void)nodeDidChangeZIndex:(SPAtlasNode*)node;
- (void)meshWillChangeVertexCount:(SPAtlasMesh*)mesh;
- (void)meshDidChangeVertexCount:(SPAtlasMesh*)mesh;
@end

@implementation SPAtlasScene

- (id)init {
    if ((self = [super init])) {
        glGenBuffers(1, &_vtBuffer);
        glGenBuffers(1, &_elBuffer);
        _meshNodes = [[NSMutableArray alloc] initWithCapacity:3];   
    }
    return self;
}

- (void)dealloc {
    [self unbind];
    glDeleteBuffers(1, &_vtBuffer);
    glDeleteBuffers(1, &_elBuffer);
}

@synthesize atlas = _atlas;
@synthesize vertexBuffer = _vtBuffer;
@synthesize vertexCount = _vtCount;
@synthesize elementBuffer = _elBuffer;
@synthesize elementCount = _elCount;
@synthesize vertexBufferState = _vtBufferState;
@synthesize elementBufferState = _elBufferState;
@synthesize meshNodes = _meshNodes;

- (void)setVertexBufferNeedsUpdate {
    if (_vtBufferState == SPAtlasSceneBufferUpToDate)
        _vtBufferState = SPAtlasSceneBufferDataOutOfDate;
}

- (void)didAddAtlasNode:(SPAtlasNode*)node {
    
    if (node.vertexCount) {
        _vtBufferState = SPAtlasSceneBufferSizeOutOfDate;
        _elBufferState = SPAtlasSceneBufferSizeOutOfDate;
        
        _vtCount += node.vertexCount;
        _elCount += node.elementCount+2;
        
    }
    
    if ([node isKindOfClass:[SPAtlasMesh class]]) {
        NSUInteger index = 0;
        for (SPAtlasMesh *mesh in _meshNodes) {
            if ([node.indexPath compare:mesh.indexPath] == NSOrderedAscending) 
                break;
            ++index;
        }
        [_meshNodes insertObject:node atIndex:index];
    }
}

- (void)willRemoveAtlasNode:(SPAtlasNode*)node {
    if (node.vertexCount) {
        _vtBufferState = SPAtlasSceneBufferSizeOutOfDate;
        _elBufferState = SPAtlasSceneBufferSizeOutOfDate;
        
        _vtCount -= node.vertexCount;
        _elCount -= node.elementCount+2;
    }
       
    if ([node isKindOfClass:[SPAtlasMesh class]])
        [_meshNodes removeObject:node];
    

}

- (void)nodeDidChangeZIndex:(SPAtlasNode *)node {
    if (node.vertexCount) {
        _elBufferState = SPAtlasSceneBufferDataOutOfDate;
        
        [_meshNodes removeObject:node];
        
        NSUInteger index = 0;
        for (SPAtlasMesh *mesh in _meshNodes) {
            if ([node.indexPath compare:mesh.indexPath] == NSOrderedAscending) 
                break;
            ++index;
        }
        [_meshNodes insertObject:node atIndex:index];
    }
}

- (void)meshWillChangeVertexCount:(SPAtlasMesh *)mesh {
    if (mesh.vertexCount) {  
        _vtBufferState = SPAtlasSceneBufferSizeOutOfDate;
        _elBufferState = SPAtlasSceneBufferSizeOutOfDate;
        
        _vtCount -= mesh.vertexCount;
        _elCount -= mesh.elementCount+2;
    }
}

- (void)meshDidChangeVertexCount:(SPAtlasMesh *)mesh {
    if (mesh.vertexCount) {
        _vtBufferState = SPAtlasSceneBufferSizeOutOfDate;
        _elBufferState = SPAtlasSceneBufferSizeOutOfDate;
        
        _vtCount += mesh.vertexCount;
        _elCount += mesh.elementCount+2;
    }
}

- (void)bind {    
    glBindBuffer(GL_ARRAY_BUFFER, _vtBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _elBuffer);
    glBindTexture(GL_TEXTURE_2D, _atlas.glName);
    glEnableClientState(GL_COLOR_ARRAY);
}

- (void)unbind {
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisableClientState(GL_COLOR_ARRAY);
}

- (void)draw {
    if (_elCount) {
        switch (_vtBufferState) {
            case SPAtlasSceneBufferSizeOutOfDate:
                glBufferData(GL_ARRAY_BUFFER, SPColoredVertexSize*_vtCount, NULL, GL_DYNAMIC_DRAW);
                [_meshNodes makeObjectsPerformSelector:@selector(setVerticesNeedsUpdate)];
            case SPAtlasSceneBufferDataOutOfDate:   
            {
#if TARGET_OS_IPHONE
                SPColoredVertex *vt = (SPColoredVertex*)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
#else
                SPColoredVertex *vt = (SPColoredVertex*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
#endif
                SPTransform t = SPTransformIdentity;
                
                GLushort i = 0;
                for (SPAtlasNode *node in self.children) {
                    [node updateVertices:&vt withTransform:&t opacity:1.f index:&i];
                }
                
#if TARGET_OS_IPHONE
                glUnmapBufferOES(GL_ARRAY_BUFFER);
#else
                glUnmapBuffer(GL_ARRAY_BUFFER);
#endif
                
                _vtBufferState = SPAtlasSceneBufferUpToDate;
                break;
            }
        }
        
        
        switch (_elBufferState) {
            case SPAtlasSceneBufferSizeOutOfDate:
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*_elCount, NULL, GL_STATIC_DRAW);
            case SPAtlasSceneBufferDataOutOfDate:   
            {
#if TARGET_OS_IPHONE
                GLushort *el = (GLushort*)glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
#else
                GLushort *el = (GLushort*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);
#endif  
                for (SPAtlasMesh *mesh in _meshNodes) {
                    [mesh updateElements:&el];
                }                
                
#if TARGET_OS_IPHONE
                glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
#else
                glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);        
#endif            
                _elBufferState = SPAtlasSceneBufferUpToDate;
                break;
            }
        }
        
        
        [self.camera begin];
        glVertexPointer(2, GL_FLOAT, SPColoredVertexSize, SPVertexPtrOffset);
        glTexCoordPointer(2, GL_FLOAT, SPColoredVertexSize, SPTexCoordPtrOffset);
        glColorPointer(4, GL_FLOAT, SPColoredVertexSize, SPColorPtrOffset);
    
        // draw the elements
        glDrawElements(GL_TRIANGLE_STRIP, _elCount-2, GL_UNSIGNED_SHORT, (GLvoid*)sizeof(GLushort));
        [self.camera end];
    }
}
@end
