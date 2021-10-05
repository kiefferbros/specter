//
//  SPGeometry.h
//  Project Mallard
//
//  Created by Jonathan on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTypes.h"

#pragma mark - Transform
static const SPTransform SPTransformIdentity = {1.0f,0.0f,0.0f,0.0f,
												0.0f,1.0f,0.0f,0.0f,
												0.0f,0.0f,1.0f,0.0f,
												0.0f,0.0f,0.0f,1.0f};


static inline BOOL
SPTransformIsAffineIdentity(const SPTransform t) {
    return (t.a==1.f && t.b==0.f && t.c==0.f && t.d==1.f && t.x==0.f && t.y==0.f);
}

static inline SPTransform
SPTransformAffineMake (SPVec2 p, SPFloat r, SPVec2 s, SPVec2 a) {
	SPTransform t = SPTransformIdentity;
	SPFloat sr, cr;
	
	sr = SPFastSine(r);
	cr = SPFastCosine(r);
	
	t.m11 = s.x*cr;  t.m12 = s.x*sr;
	t.m21 = -s.y*sr; t.m22 = s.y*cr;
	t.m41 = -a.x*t.m11-a.y*t.m21+p.x;
	t.m42 = -a.x*t.m12-a.y*t.m22+p.y;
	
	return t;
}

static inline void
SPTransformAffineMakePtr (SPTransform *t, SPVec2 p, SPFloat r, SPVec2 s, SPVec2 a) {
	SPFloat sr, cr;
	
	sr = SPFastSine(r);
	cr = SPFastCosine(r);
	
	t->m11 = s.x*cr;  t->m12 = s.x*sr;
	t->m21 = -s.y*sr; t->m22 = s.y*cr;
	t->m41 = -a.x*t->m11-a.y*t->m21+p.x;
	t->m42 = -a.x*t->m12-a.y*t->m22+p.y;
}

static inline SPTransform
SPTransformAffineMult (const SPTransform a, const SPTransform b) {
	SPTransform result = {
		a.m11*b.m11 + a.m12*b.m21,				/**/ a.m11*b.m12 + a.m12*b.m22,		         /**/ 0.f,	 /**/ 0.f,
		
		a.m21*b.m11 + a.m22*b.m21,				/**/ a.m21*b.m12 + a.m22*b.m22,		         /**/ 0.f,	 /**/ 0.f,
	
		0.f,									/**/ 0.f,							         /**/ 1.f,	 /**/ 0.f,
		 
		a.m41*b.m11 + a.m42*b.m21 + b.m41,      /**/ a.m41*b.m12 + a.m42*b.m22 + b.m42,      /**/ 0.f,	 /**/ 1.f	
	};
	
	return result;
}

static inline void
SPTransformAffineMultPtr (const SPTransform *a, const SPTransform *b, SPTransform *result) {
    result->m11 = a->m11*b->m11 + a->m12*b->m21;
    result->m12 = a->m11*b->m12 + a->m12*b->m22;
    result->m13 = 0.f;
    result->m14 = 0.f;
    result->m21 = a->m21*b->m11 + a->m22*b->m21;
    result->m22 = a->m21*b->m12 + a->m22*b->m22;
    result->m23 = 0.f;
    result->m24 = 0.f;
    result->m31 = 0.f;
    result->m32 = 0.f;
    result->m33 = 1.f;
    result->m34 = 0.f;
    result->m41 = a->m41*b->m11 + a->m42*b->m21 + b->m41;
    result->m42 = a->m41*b->m12 + a->m42*b->m22 + b->m42;
    result->m43 = 0.f;
    result->m44 = 1.f;	
}

static inline SPTransform
SPTransformAffineInvert (SPTransform t) {
    SPFloat det = t.m11*t.m22 - t.m12*t.m21;
    
    if (det == 0.f) return t; // no inverse exists
    det = 1.f/det; // inverse
    
    SPFloat C, F;

    C = t.m21*t.m42 - t.m22*t.m41; 
    F = t.m41*t.m12 - t.m11*t.m42;
    
    t.m11 = t.m22*det; t.m12 = -t.m12*det;
    t.m21 = -t.m21*det; t.m22 = t.m11*det;
    t.m41 = C*det; t.m42 = F*det;
    
    return t;
}

SPTransform SPTransform3DMult (SPTransform m1, SPTransform m2);

static inline SPTransform 
SPTransform3DInvert (SPTransform t) {

    SPFloat inv[16], *m, det;
    m = t.m;
    
    inv[0] =   m[5]*m[10]*m[15] - m[5]*m[11]*m[14] - m[9]*m[6]*m[15]
    + m[9]*m[7]*m[14] + m[13]*m[6]*m[11] - m[13]*m[7]*m[10];
    inv[4] =  -m[4]*m[10]*m[15] + m[4]*m[11]*m[14] + m[8]*m[6]*m[15]
    - m[8]*m[7]*m[14] - m[12]*m[6]*m[11] + m[12]*m[7]*m[10];
    inv[8] =   m[4]*m[9]*m[15] - m[4]*m[11]*m[13] - m[8]*m[5]*m[15]
    + m[8]*m[7]*m[13] + m[12]*m[5]*m[11] - m[12]*m[7]*m[9];
    inv[12] = -m[4]*m[9]*m[14] + m[4]*m[10]*m[13] + m[8]*m[5]*m[14]
    - m[8]*m[6]*m[13] - m[12]*m[5]*m[10] + m[12]*m[6]*m[9];
    inv[1] =  -m[1]*m[10]*m[15] + m[1]*m[11]*m[14] + m[9]*m[2]*m[15]
    - m[9]*m[3]*m[14] - m[13]*m[2]*m[11] + m[13]*m[3]*m[10];
    inv[5] =   m[0]*m[10]*m[15] - m[0]*m[11]*m[14] - m[8]*m[2]*m[15]
    + m[8]*m[3]*m[14] + m[12]*m[2]*m[11] - m[12]*m[3]*m[10];
    inv[9] =  -m[0]*m[9]*m[15] + m[0]*m[11]*m[13] + m[8]*m[1]*m[15]
    - m[8]*m[3]*m[13] - m[12]*m[1]*m[11] + m[12]*m[3]*m[9];
    inv[13] =  m[0]*m[9]*m[14] - m[0]*m[10]*m[13] - m[8]*m[1]*m[14]
    + m[8]*m[2]*m[13] + m[12]*m[1]*m[10] - m[12]*m[2]*m[9];
    inv[2] =   m[1]*m[6]*m[15] - m[1]*m[7]*m[14] - m[5]*m[2]*m[15]
    + m[5]*m[3]*m[14] + m[13]*m[2]*m[7] - m[13]*m[3]*m[6];
    inv[6] =  -m[0]*m[6]*m[15] + m[0]*m[7]*m[14] + m[4]*m[2]*m[15]
    - m[4]*m[3]*m[14] - m[12]*m[2]*m[7] + m[12]*m[3]*m[6];
    inv[10] =  m[0]*m[5]*m[15] - m[0]*m[7]*m[13] - m[4]*m[1]*m[15]
    + m[4]*m[3]*m[13] + m[12]*m[1]*m[7] - m[12]*m[3]*m[5];
    inv[14] = -m[0]*m[5]*m[14] + m[0]*m[6]*m[13] + m[4]*m[1]*m[14]
    - m[4]*m[2]*m[13] - m[12]*m[1]*m[6] + m[12]*m[2]*m[5];
    inv[3] =  -m[1]*m[6]*m[11] + m[1]*m[7]*m[10] + m[5]*m[2]*m[11]
    - m[5]*m[3]*m[10] - m[9]*m[2]*m[7] + m[9]*m[3]*m[6];
    inv[7] =   m[0]*m[6]*m[11] - m[0]*m[7]*m[10] - m[4]*m[2]*m[11]
    + m[4]*m[3]*m[10] + m[8]*m[2]*m[7] - m[8]*m[3]*m[6];
    inv[11] = -m[0]*m[5]*m[11] + m[0]*m[7]*m[9] + m[4]*m[1]*m[11]
    - m[4]*m[3]*m[9] - m[8]*m[1]*m[7] + m[8]*m[3]*m[5];
    inv[15] =  m[0]*m[5]*m[10] - m[0]*m[6]*m[9] - m[4]*m[1]*m[10]
    + m[4]*m[2]*m[9] + m[8]*m[1]*m[6] - m[8]*m[2]*m[5];
    
    det = m[0]*inv[0] + m[1]*inv[4] + m[2]*inv[8] + m[3]*inv[12];
    if (det == 0) return t;
    
    det = 1.0 / det;
    
    for (int i = 0; i < 16; ++i)
        m[i] = inv[i] * det;
        
    return t;
}

#pragma mark - Vec2

static const SPVec2 SPVec2Zero={0.0f,0.0f};
static const SPVec2 SPVec2One = {1.f, 1.f};

static inline SPVec2
SPVec2Make(SPFloat x, SPFloat y) {
	SPVec2 v = {x, y};
	return v;
}

static inline SPVec2
SPVec2MakeUniform (SPFloat s) {
	SPVec2 v = {s, s};
	return v;
}

static inline SPVec2
SPVec2Neg(const SPVec2 v)
{
	return SPVec2Make(-v.x, -v.y);
}

static inline SPVec2
SPVec2Add(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Make(v1.x + v2.x, v1.y + v2.y);
}

static inline SPVec2
SPVec2Sub(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Make(v1.x - v2.x, v1.y - v2.y);
}

static inline SPVec2
SPVec2Mult(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Make(v1.x*v2.x, v1.y*v2.y);
}

static inline SPVec2
SPVec2Div (const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Make(v1.x/v2.x, v1.y/v2.y);
}

static inline SPVec2
SPVec2Scale(const SPVec2 v, const SPFloat s)
{
	return SPVec2Make(v.x*s, v.y*s);
}

static inline SPVec2
SPVec2DivScale(const SPVec2 v, const SPFloat s)
{
	return SPVec2Make(v.x/s, v.y/s);
}

static inline SPFloat
SPVec2Dot(const SPVec2 v1, const SPVec2 v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

static inline SPFloat
SPVec2Cross(const SPVec2 v1, const SPVec2 v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

static inline SPVec2
SPVec2Perp(const SPVec2 v)
{
	return SPVec2Make(-v.y, v.x);
}

static inline SPVec2
SPVec2RevPerp(const SPVec2 v)
{
	return SPVec2Make(v.y, -v.x);
}

static inline SPVec2
SPVec2Project(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Scale(v2, SPVec2Dot(v1, v2)/SPVec2Dot(v2, v2));
}

static inline SPVec2
SPVec2Rotate(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Make(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

static inline SPVec2
SPVec2Unrotate(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Make(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

// non-inlined functions
SPFloat SPVec2Length(const SPVec2 v);
SPVec2 SPVec2Slerp(const SPVec2 v1, const SPVec2 v2, const SPFloat t);
SPVec2 SPVec2SlerpConst(const SPVec2 v1, const SPVec2 v2, const SPFloat a);
SPVec2 SPVec2FromAngle(const SPFloat a); // convert radians to a normalized vector
SPFloat SPVec2ToAngle(const SPVec2 v); // convert a vector to radians

static inline SPFloat
SPVec2LengthSq(const SPVec2 v)
{
	return SPVec2Dot(v, v);
}

static inline SPVec2
SPVec2Lerp(const SPVec2 v1, const SPVec2 v2, const SPFloat t)
{
	return SPVec2Make(SPFloatLerp(v1.x, v2.x, t), SPFloatLerp(v1.y, v2.y, t));
}

static inline SPVec2
SPVec2Werp(const SPVec2 v1, const SPVec2 v2, SPFloat t, SPFloat aT, SPFloat aV, SPFloat bT, SPFloat bV)
{
	return SPVec2Make(SPFloatWerp(v1.x, v2.x, t, aT, aV, bT, bV), SPFloatWerp(v1.y, v2.y, t, aT, aV, bT, bV));
}

static inline SPVec2
SPVec2Berp (const SPVec2 a1, const SPVec2 h1, const SPVec2 h2, const SPVec2 a2, const SPFloat t) {
    SPFloat ot = 1.f-t;
    return SPVec2Add(SPVec2Add(SPVec2Add(SPVec2Scale(a1, ot*ot*ot), SPVec2Scale(h1, 3*ot*ot*t)),SPVec2Scale(h2, 3*ot*t*t)),SPVec2Scale(a2, t*t*t));
}

static inline SPVec2
SPVec2Normalize(const SPVec2 v)
{
	return SPVec2DivScale(v, SPVec2Length(v));
}

static inline SPVec2
SPVec2Clamp(const SPVec2 v, const SPFloat len)
{
	return (SPVec2Dot(v,v) > len*len) ? SPVec2Scale(SPVec2Normalize(v), len) : v;
}

static inline SPVec2
SPVec2LerpConst(SPVec2 v1, SPVec2 v2, SPFloat d)
{
	return SPVec2Add(v1, SPVec2Clamp(SPVec2Sub(v2, v1), d));
}

static inline SPFloat
SPVec2Dist(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2Length(SPVec2Sub(v1, v2));
}

static inline SPFloat
SPVec2DistSq(const SPVec2 v1, const SPVec2 v2)
{
	return SPVec2LengthSq(SPVec2Sub(v1, v2));
}

static inline SPVec2 
SPVec2Transform(SPVec2 v, SPTransform t) {
	SPVec2 ov;
	ov.x = t.m11*v.x + t.m21*v.y + t.m41;
	ov.y = t.m12*v.x + t.m22*v.y + t.m42;
	return ov;
}

static inline SPVec2 
SPVec2TransformPtr(SPVec2 v, const SPTransform *const t) {
	SPVec2 ov;
	ov.x = t->m11*v.x + t->m21*v.y + t->m41;
	ov.y = t->m12*v.x + t->m22*v.y + t->m42;
	return ov;
}

static inline int 
SPVec2Equal (SPVec2 v1, SPVec2 v2) {
	return (v1.x == v2.x && v1.y == v2.y);
}

static inline SPVec2
SPVec2Round (SPVec2 v) {
	return SPVec2Make(roundf(v.x), roundf(v.y));
}

void SPVec2Print(const SPVec2 v);

#pragma mark - Vec3
static inline SPVec3
SPVec3Make (const SPFloat x, const SPFloat y, const SPFloat z) {
    SPVec3 v = {x, y, z};
	return v;
}

static inline SPVec3
SPVec3MakeUniform (const SPFloat s) {
    SPVec3 v = {s, s, s};
	return v;
}

static inline SPVec3
SPVec3Neg (SPVec3 v) {
	return SPVec3Make(-v.x, -v.y, -v.z);
}

static inline SPVec3
SPVec3Add (SPVec3 v1, SPVec3 v2) {
	return SPVec3Make(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}

static inline SPVec3
SPVec3Sub (SPVec3 v1, SPVec3 v2) {
	return SPVec3Make(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}

static inline SPVec3
SPVec3Mult(const SPVec3 v1, const SPVec3 v2) {
	return SPVec3Make(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z);
}

static inline SPVec3
SPVec3Div(const SPVec3 v1, const SPVec3 v2) {
	return SPVec3Make(v1.x/v2.x, v1.y/v2.y, v1.z/v2.z);
}

static inline SPVec3
SPVec3Scale(const SPVec3 v1, const SPFloat s) {
	return SPVec3Make(v1.x*s, v1.y*s, v1.z*s);
}

static inline SPVec3
SPVec3DivScale(const SPVec3 v, const SPFloat s)
{
	return SPVec3Make(v.x/s, v.y/s, v.z/s);
}

static inline SPFloat
SPVec3Dot(SPVec3 v1, SPVec3 v2)
{
	return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}

static inline SPVec3
SPVec3Cross(SPVec3 v1, SPVec3 v2) {
	return SPVec3Make(v1.y*v2.z - v1.z*v2.y,
					   v1.z*v2.x - v1.x*v2.z,
					   v1.x*v2.y - v1.y*v2.x);
}

SPFloat SPVec3Length(SPVec3 v);

static inline SPFloat 
SPVec3LengthSq(SPVec3 v) {
	return SPVec3Dot(v, v);
}

static inline SPVec3
SPVec3DNormalize(const SPVec3 v)
{
	return SPVec3DivScale(v, SPVec3Length(v));
}

static inline SPFloat
SPVec3Dist(const SPVec3 v1, const SPVec3 v2)
{
	return SPVec3Length(SPVec3Sub(v1, v2));
}

static inline SPFloat
SPVec3DistSq(const SPVec3 v1, const SPVec3 v2)
{
	return SPVec3LengthSq(SPVec3Sub(v1, v2));
}

static inline SPVec3
SPVec3Transform(SPVec3 v, SPTransform t) {	
	return SPVec3Make(v.x*t.m11 + v.y*t.m21 + v.z*t.m31 + t.m41,
                      v.x*t.m12 + v.y*t.m22 + v.z*t.m32 + t.m42,
                      v.x*t.m13 + v.y*t.m23 + v.z*t.m33 + t.m43);
}

static inline SPVec3
SPVec3Lerp(const SPVec3 v1, const SPVec3 v2, const SPFloat t)
{
	return SPVec3Make(SPFloatLerp(v1.x, v2.x, t), 
                      SPFloatLerp(v1.y, v2.y, t),
                      SPFloatLerp(v1.z, v2.z, t));
}

static inline SPVec3
SPVec3Werp(const SPVec3 v1, const SPVec3 v2, SPFloat t, SPFloat aT, SPFloat aV, SPFloat bT, SPFloat bV)
{
	return SPVec3Make(SPFloatWerp(v1.x, v2.x, t, aT, aV, bT, bV), 
                      SPFloatWerp(v1.y, v2.y, t, aT, aV, bT, bV), 
                      SPFloatWerp(v1.z, v2.z, t, aT, aV, bT, bV));
}

#pragma mark - Vec4
static inline SPVec4
SPVec4Make (const SPFloat x, const SPFloat y, const SPFloat z, const SPFloat w) {
    SPVec4 v = {x, y, z, w};
	return v;
}

static inline SPVec4
SPVec4MakeUniform (const SPFloat s) {
    SPVec4 v = {s, s, s, s};
	return v;
}

static inline SPVec4
SPVec4Add (SPVec4 v1, SPVec4 v2) {
	return SPVec4Make(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.w + v2.w);
}

static inline SPVec4
SPVec4Mult(const SPVec4 v1, const SPVec4 v2)
{
	return SPVec4Make(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z, v1.w*v2.w);
}

static inline SPVec4
SPVec4Scale(const SPVec4 v, const SPFloat s)
{
	return SPVec4Make(v.x*s, v.y*s, v.z*s, v.w*s);
}

static inline SPVec4
SPVec4Lerp(const SPVec4 v1, const SPVec4 v2, const SPFloat t)
{
	return SPVec4Make(SPFloatLerp(v1.x, v2.x, t), SPFloatLerp(v1.y, v2.y, t), SPFloatLerp(v1.z, v2.z, t), SPFloatLerp(v1.w, v2.w, t));
}


#pragma mark - Box
static const SPBox SPBoxZero={0.0f,0.0f,0.0f,0.0f};

static inline SPBox
SPBoxMake(const SPFloat l, const SPFloat b,
		  const SPFloat r, const SPFloat t)
{
	SPBox bb = {l, b, r, t};
	return bb;
}

static inline int
SPBoxIntersects(const SPBox a, const SPBox b)
{
	return (a.l<=b.r && b.l<=a.r && a.b<=b.t && b.b<=a.t);
}

/*
static int
SPBoxOverlaps(const SPBox a, const SPBox b)
{
	return (a.l<b.r && b.l<a.r && a.b<b.t && b.b<a.t);
}
 */

static inline int
SPBoxContainsBox(const SPBox bb, const SPBox other)
{
	return (bb.l < other.l && bb.r > other.r && bb.b < other.b && bb.t > other.t);
}

static inline int
SPBoxContainsVec(const SPBox bb, const SPVec2 v)
{
	return (bb.l < v.x && bb.r > v.x && bb.b < v.y && bb.t > v.y);
}

static inline SPBox
SPBoxMerge(const SPBox a, const SPBox b){
	return SPBoxMake(
				   SPFloatMin(a.l, b.l),
				   SPFloatMin(a.b, b.b),
				   SPFloatMax(a.r, b.r),
				   SPFloatMax(a.t, b.t)
				   );
}

static inline SPBox
SPBoxExpand(const SPBox bb, const SPVec2 v){
	return SPBoxMake(
				   SPFloatMin(bb.l, v.x),
				   SPFloatMin(bb.b, v.y),
				   SPFloatMax(bb.r, v.x),
				   SPFloatMax(bb.t, v.y)
				   );
}

static inline SPFloat 
SPBoxWidth (SPBox box) {
	return box.r-box.l;
}

static inline SPFloat 
SPBoxHeight (SPBox box) {
	return box.t-box.b;
}

static inline SPBox
SPBoxInset(SPBox box, SPFloat inset) {
	return SPBoxMake(box.l+inset, box.b+inset, box.r-inset, box.t-inset);
}

static inline SPBox
SPBoxOffset(SPBox box, SPVec2 offset) {
	return SPBoxMake(box.l+offset.x, box.b+offset.y, box.r+offset.x, box.t+offset.y);
}

SPVec2 SPBoxGetCorner(SPBox bb, int corner);
SPBox SPBoxTransform(SPBox bb, SPTransform t);

SPVec2 SPBoxClampVec(const SPBox bb, const SPVec2 v); // clamps the vector to lie within the bbox


void SPBoxPrint(const SPBox box);
