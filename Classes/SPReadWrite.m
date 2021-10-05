//
//  SPReadWrite.m
//  KBEditor
//
//  Created by Jonathan Kieffer on 1/30/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPReadWrite.h"
#include <stdlib.h>

static unsigned char 
revbyte (unsigned char b) {
    return ((b * 0x0802LU & 0x22110LU) | (b * 0x8020LU & 0x88440LU)) * 0x10101LU >> 16;
}

static unsigned char
togbyte (unsigned char b) {
    return b ^ 0xFF;
}

static unsigned char
wrapadd (unsigned char b, char o) {
    
    short buffer = b;
    buffer += o;
    
    if (buffer<0) 
        return (unsigned char)(256 + buffer);
    
    if (buffer > 255) 
        return(unsigned char)(buffer - 256);
    
    return (unsigned char)buffer;
}

static unsigned int 
rotl(const unsigned int value, int shift) {
    if ((shift &= sizeof(value)*8 - 1) == 0)
        return value;
    return (value << shift) | (value >> (sizeof(value)*8 - shift));
}

static const unsigned int op = 2276333206;
static const char vals[16] = { 8, 22, 36, 127, 23, 9, -25, 7, 101, -6, 4, 17, 96, -66, 122, -87 };


@implementation NSData (SPReadWriteExtension)

+ (NSData*)dataWithSPData:(NSData*)inData {
    NSMutableData *data = [NSMutableData dataWithData:inData];
    
    NSUInteger len = [data length];
    if (!data || len==0) return nil;
    
    unsigned char *bytes = [data mutableBytes];
    
    unsigned int opm = 1;
    for (NSUInteger i=0; i<len; ++i) {  
        char v = vals[i%16];
        bytes[i] = wrapadd(bytes[i], -v);
        
        bytes[i] = op&opm ? togbyte(bytes[i]) : revbyte(bytes[i]);        
        opm = rotl(opm, 1);
    }

    
    return data;
}

+ (NSData*)dataWithContentsOfSPFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    return [NSData dataWithSPData:data];
}

- (NSData*)SPData {
    NSUInteger len = [self length];
    
    unsigned char *bytes = (unsigned char*)[self bytes];
    unsigned char writeBytes[len];
    
    unsigned int opm = 1;
    for (NSUInteger i=0; i<len; ++i) {
        writeBytes[i] = op&opm ? togbyte(bytes[i]) : revbyte(bytes[i]);
        opm = rotl(opm, 1);
        
        char v = vals[i%16];                 
        writeBytes[i] = wrapadd(writeBytes[i], v);
    }
    

    
    return [NSData dataWithBytes:writeBytes length:len];
}

- (BOOL)writeToSPFile:(NSString *)path {
    NSData *writeData = [self SPData];
    return [writeData writeToFile:path atomically:YES];
}
@end