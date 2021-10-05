//
//  Subtexture.m
//  Texture Utility
//
//  Created by Jonathan Kieffer on 3/22/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "Subtexture.h"

@implementation Subtexture
- (id)initWithImage:(NSImage*)image {
    if ((self = [super init])) {
        self.image = image;
        self.position = NSZeroPoint;
    }
    return self;
}

- (CGFloat)x {
    return self.position.x;
}

- (void)setX:(CGFloat)x {
    _position.x = round(x);
}

- (CGFloat)y {
    return self.position.y;
}

- (void)setY:(CGFloat)y {
    _position.y = round(y);
}

- (CGFloat)w {
    return self.image.size.width;
}

- (CGFloat)h {
    return self.image.size.height;
}

- (NSRect)frame {
    return NSMakeRect(self.position.x, self.position.y, self.image.size.width, self.image.size.height);
}

- (NSRect)bounds {
    return NSMakeRect(0, 0, self.image.size.width, self.image.size.height);
}

@synthesize position = _position;
@synthesize image = _image;

- (void)setPosition:(CGPoint)position {
    [self willChangeValueForKey:@"x"];
    [self willChangeValueForKey:@"y"];
    _position.x = round(position.x);
    _position.y = round(position.y);
    [self didChangeValueForKey:@"x"];
    [self didChangeValueForKey:@"y"];
}

- (NSString*)name {
    return [_image name];
}

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [_image setName:name];
    [self didChangeValueForKey:@"name"];
}

- (NSArray*)divideIntoRows:(NSUInteger)rows columns:(NSUInteger)columns {
    if ((rows>0 && columns>1) || (rows>1 && columns>0)) {
        
        NSRect rect = NSMakeRect(0, 0, self.w/columns, self.h/rows);
        
        NSArray *subtextures = [NSArray array];
        
        int i = 1;
        for (int r=0; r<rows; ++r) {
            rect.origin.x = 0;
            for (int c=0; c<columns; ++c) {
                
                NSImage *image = [[NSImage alloc] initWithSize:rect.size];
                
                [image lockFocus];
                [_image drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositeSourceOver fraction:1.];
                [image unlockFocus];
                
                [image setName:[NSString stringWithFormat:@"%@-%i", _image.name, i]];
                
                Subtexture *tex = [[Subtexture alloc] initWithImage:image];
                tex.x = self.x + rect.origin.x;
                tex.y = self.y + rect.origin.y;
                
                
                subtextures = [subtextures arrayByAddingObject:tex];
                
                rect.origin.x += rect.size.width;
                ++i;
            }
            rect.origin.y += rect.size.height;
        }
        
        return subtextures;
    }
    return nil;
}

- (void)refactor {
    _position.x /= 2.f;
    _position.y /= 2.f;
    
    CGSize size = _image.size;
    size.height /= 2.f;
    size.width /= 2.f;
    
    NSImage *image = [[NSImage alloc] initWithSize:size];
    
    [image lockFocus];
    [_image drawInRect:NSMakeRect(0., 0., size.width, size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.];
    [image unlockFocus];
    
    _image = image;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodePoint:_position forKey:@"position"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.position = [aDecoder decodePointForKey:@"position"];
    }
    return self;
}
@end
