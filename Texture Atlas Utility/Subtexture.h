//
//  Subtexture.h
//  Texture Utility
//
//  Created by Jonathan Kieffer on 3/22/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Subtexture : NSObject <NSCoding>

- (id)initWithImage:(NSImage*)image;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, assign) NSPoint position;
@property (nonatomic, assign) CGFloat x, y;
@property (nonatomic, readonly) CGFloat w, h;
@property (nonatomic, readonly) NSRect frame, bounds;
@property (nonatomic, assign) NSString *name;

- (NSArray*)divideIntoRows:(NSUInteger)rows columns:(NSUInteger)columns;
- (void)refactor;
@end
