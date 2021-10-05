//
//  SPReadWrite.h
//  KBEditor
//
//  Created by Jonathan Kieffer on 1/30/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SPReadWriteExtension)
+ (NSData*)dataWithSPData:(NSData*)inData;
+ (NSData *)dataWithContentsOfSPFile:(NSString *)path;

- (BOOL)writeToSPFile:(NSString *)path;
- (NSData*)SPData;
@end