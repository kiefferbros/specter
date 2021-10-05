/*
 *  SpecterTypes.h
 *  Paper Sail
 *
 *  Created by Jonathan on 4/22/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#if TARGET_OS_IPHONE
#import <OpenGLES/ES1/gl.h>
#else 
#import <OpenGL/gl.h>
#endif


typedef enum {
	SPTypeNone=0,
	SPTypeFloat,
	SPTypeInt,
	SPTypeBool,
	SPTypeNSString,
    SPTypeEnum
} SPDataType;

typedef float SPFloat;
typedef double SPTime;

typedef struct _SPVec2 {
    SPFloat x, y;
} SPVec2;

typedef struct _SPVec3 { 
    SPFloat x, y, z;
} SPVec3;

typedef struct _SPVec4 {
    SPFloat x, y, z, w;
} SPVec4;

/*
typedef union SPVec2 { 
    struct { SPFloat x, y; };
    struct { SPFloat w, h; };
    struct { SPFloat s, t; };
    SPFloat v[2];
} SPVec2;

typedef union SPVec3 { 
    struct { SPFloat x, y, z; };
    struct { SPFloat r, g, b; };
    struct { SPFloat s, t, p; };
    SPFloat v[3];
} SPVec3;

typedef union SPVec4 {
    struct { SPFloat x, y, z, w; };
    struct { SPFloat r, g, b, a; };
    struct { SPFloat s, t, p, q; };
    float v[4];
} SPVec4;
 */

typedef struct _SPVertex {
	SPVec2       p;
    SPVec2       t;
} SPVertex;

typedef struct _SPColoredVertex {
    SPVec2       p;
    SPVec2       t;
	SPVec4       c;
} SPColoredVertex;

typedef struct _SPColorVertex {
	SPVec2       p;
	SPVec4       c;
} SPColorVertex;

typedef union _SPTransform {
    struct {
        SPFloat m11, m12, m13, m14;
        SPFloat m21, m22, m23, m24;
        SPFloat m31, m32, m33, m34;
        SPFloat m41, m42, m43, m44;
    };
    struct {
        SPFloat a, b, e0, e1;
        SPFloat c, d, e2, e3;
        SPFloat e4, e5, e6, e7;
        SPFloat x, y, e8, e9;
    };
    SPFloat m[16];
} SPTransform;


typedef struct _SPBox {
    SPFloat l, b, r, t;
} SPBox;

/*
typedef union SPBox {
    struct { SPFloat l, b, r, t; }; 
    struct { SPFloat minS, minT, maxS, maxT; }; 
    SPFloat x[4];
} SPBox;*/

#pragma mark - Float
static inline SPFloat
SPFloatMax(SPFloat a, SPFloat b)
{
	return (a > b) ? a : b;
}

static inline SPFloat
SPFloatMin(SPFloat a, SPFloat b)
{
	return (a < b) ? a : b;
}

static inline SPFloat
SPFloatAbs(SPFloat n)
{
	return (n < 0) ? -n : n;
}

void SPFloatRandomSeed(unsigned int seed);
SPFloat SPFloatRandom(void);

static inline SPFloat
SPFloatClamp(SPFloat f, SPFloat min, SPFloat max)
{
	return SPFloatMin(SPFloatMax(f, min), max);
}


static inline SPFloat
SPFloatLerpConst(SPFloat f1, SPFloat f2, SPFloat d)
{
	return f1 + SPFloatClamp(f2 - f1, -d, d);
}

static inline bool
SPFloatBetween(SPFloat f, SPFloat min, SPFloat max) {
	return (f > min && f < max);
}

// linear interpolation
static inline SPFloat
SPFloatLerp (SPFloat a, SPFloat b, SPFloat delta) {    
    return (b-a)*delta+a;
}

// weighted interpolation
static inline SPFloat
SPFloatWerp (SPFloat a, SPFloat b, SPFloat t, SPFloat aT, SPFloat aV, SPFloat bT, SPFloat bV) {   
     
    aT = -0.33333333f*SPFloatClamp(aT,-1.f,1.f) + 0.33333333f;
    bT = 1.f - (-0.33333333f*SPFloatClamp(bT,-1.f,1.f) + 0.33333333f);
    
    aV = -0.33333333f*aV + 0.33333333f;
    bV = 1.f - (-0.33333333f*bV + 0.33333333f);
    
    SPFloat OmT = 1.f-t;
    SPFloat d = 3*(OmT*OmT)*t*aT + 3*OmT*(t*t)*bT + t*t*t;

    SPFloat OmD = 1.f-d;
    SPFloat v = 3*(OmD*OmD)*d*aV + 3*OmD*(d*d)*bV + d*d*d;
    return (b-a)*v + a;
}

static const SPFloat SPPi		= 3.141592653589793f;
static const SPFloat SPPi2		= 6.283185307179586f;
static const SPFloat SPPiD2		= 1.570796326794897f;
static const SPFloat SPPiSQR	= 9.869604401089357f;
SPFloat SPFastSine(SPFloat x);
SPFloat SPFastCosine(SPFloat x);

SPFloat SPSimpleSine(SPFloat x);
SPFloat SPSimpleCosine(SPFloat x);

#pragma mark - Color RGBA
static inline SPVec4
SPColor4MakeWhite (SPFloat val) {
	SPVec4 c = {val, val, val, 1.f};
	return c;
}

static inline SPVec4
SPColorMultiplyAlpha (SPVec4 c) {
	c.x *= c.w;
	c.y *= c.w;
	c.z *= c.w;
	return c;
}

extern const SPVec4 SPColor4Clear;
extern const SPVec4 SPColor4Black;
extern const SPVec4 SPColor4White;
extern const SPVec4 SPColor4Gray;

#pragma mark - Color RGB
extern const SPVec3 SPColor3Black;
extern const SPVec3 SPColor3White;
extern const SPVec3 SPColor3Gray;

#pragma mark - Pixel RGBA
typedef struct _SPPixel {
	unsigned char r, g, b, a;
} SPPixel;

static inline SPPixel
SPPixelMake (unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
	SPPixel c = { r, g, b, a };
	return c;
}

static inline bool
SPPixelEqual (SPPixel c1, SPPixel c2) {
	return (c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a);
}

extern const SPPixel SPPixelClear;
extern const SPPixel SPPixelBlack;
extern const SPPixel SPPixelWhite;

// used for core foundation containers
const void * SPContainerRetainCallBack(CFAllocatorRef allocator, const void *value);
void SPContainerReleaseCallBack(CFAllocatorRef allocator, const void *value);

