//
//  SPTypes.m
//  Gravity
//
//  Created by Jonathan on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPTypes.h"

const SPVec4 SPColor4Clear = {0.f, 0.f, 0.f, 0.f};
const SPVec4 SPColor4Black = {0.f, 0.f, 0.f, 1.f};
const SPVec4 SPColor4White = {1.f, 1.f, 1.f, 1.f};
const SPVec4 SPColor4Gray = {0.5f, 0.5f, 0.5f, 1.f};

const SPVec3 SPColor3Black = {0.f, 0.f, 0.f};
const SPVec3 SPColor3White = {1.f, 1.f, 1.f};
const SPVec3 SPColor3Gray = {0.5f, 0.5f, 0.5f};

const SPPixel SPPixelClear = {0, 0, 0, 0};
const SPPixel SPPixelBlack = {0, 0, 0, 255};
const SPPixel SPPixelWhite = {255, 255, 255, 255};


#pragma mark - Random Float
static unsigned int mirand = 1;

void SPFloatRandomSeed(unsigned int seed) {
	mirand = MAX(seed, 1);
}

// returns range of [0, 1]
SPFloat SPFloatRandom(void) {
	//static unsigned int mirand = 1; //(unsigned int)(mach_absolute_time() & 0xFFFFFFFF);
	
	unsigned int a;
	
	mirand *= 16807;
	
	// mask out sign and exponent
	// set the exponent to 127 (which is offset to zero)
	a = (mirand&0x007fffff) | 0x3f800000;
	
	return ( *((SPFloat*)&a) - 1.f );
}

#pragma mark - Fast Sine and Cosine

// const float B = 4/SPPI;
// const float C = -4/(SPPISQR);
const SPFloat B			= 1.273239544735163f;
const SPFloat C			= -0.405284734569351f;


SPFloat SPFastSine(SPFloat x)
{
	//int hrots = x/SPPi;
	//int rots = x/SPPi2;
    
    //x = (x - rots*SPPi2) - (hrots%2)*SPPi2;	
    
    SPFloat hrots = (int)(x/SPPi)%2;
    SPFloat rots = (int)(x/SPPi2);
    
    x = (x - rots*SPPi2) - hrots*SPPi2;	
    
    SPFloat y = B * x + C * x * fabs(x);
    
	// extra precision
    //  const float Q = 0.775;
	const SPFloat P = 0.225;
	y = P * (y * fabs(y) - y) + y;   // Q * y + P * y * abs(y)
    
	
	return y;
}

SPFloat SPFastCosine(SPFloat x) {
	return SPFastSine(x+SPPiD2);
}

SPFloat SPSimpleSine(SPFloat x) {
	//int hrots = x/SPPi;
	//int rots = x/SPPi2;
	
	//x = (x - rots*SPPi2) - (hrots%2)*SPPi2;
    
    SPFloat hrots = (int)(x/SPPi)%2;
	SPFloat rots = (int)(x/SPPi2);
	
	x = (x - rots*SPPi2) - hrots*SPPi2;
	
    SPFloat y = B * x + C * x * fabs(x);
	
	return y;
}

SPFloat SPSimpleCosine(SPFloat x) {
	return SPSimpleSine(x+SPPiD2);
}
