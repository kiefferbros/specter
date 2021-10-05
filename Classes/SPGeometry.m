//
//  SPGeometry.m
//  Project Mallard
//
//  Created by Jonathan on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPGeometry.h"

#include <math.h>



#pragma mark - Vec2
SPFloat
SPVec2Length(const SPVec2 v)
{
	return sqrtf( SPVec2Dot(v, v) );
}

SPVec2
SPVec2Slerp(const SPVec2 v1, const SPVec2 v2, const SPFloat t)
{
	SPFloat omega = acosf(SPVec2Dot(v1, v2));
	
	if(omega){
		SPFloat denom = 1.0f/sinf(omega);
		return SPVec2Add(SPVec2Scale(v1, sinf((1.0f - t)*omega)*denom), SPVec2Scale(v2, sinf(t*omega)*denom));
	} else {
		return v1;
	}
}

SPVec2
SPVec2SlerpConst(const SPVec2 v1, const SPVec2 v2, const SPFloat a)
{
	SPFloat angle = acosf(SPVec2Dot(v1, v2));
	return SPVec2Slerp(v1, v2, SPFloatMin(a, angle)/angle);
}

SPVec2
SPVec2FromAngle(const SPFloat a)
{
	return SPVec2Make(cosf(a), sinf(a));
}

SPFloat
SPVec2ToAngle(const SPVec2 v)
{
	return atan2f(v.y, v.x);
}

void SPVec2Print(const SPVec2 v) {
	printf("SPVec(%f, %f)", v.x, v.y);
}

#pragma mark - Vec3
SPFloat
SPVec3Length(const SPVec3 v)
{
	return sqrtf( SPVec3Dot(v, v) );
}

#pragma mark - Transform 3D
/* 
 These define the vectorized version of the 
 matrix multiply function and are based on the Matrix4Mul method from 
 the vfp-math-library. This code has been modified, but is still subject to  
 the original license terms and ownership as follow:
 
 VFP math library for the iPhone / iPod touch
 
 Copyright (c) 2007-2008 Wolfgang Engel and Matthias Grundmann
 http://code.google.com/p/vfpmathlibrary/
 
 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising
 from the use of this software.
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it freely,
 subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must
 not claim that you wrote the original software. If you use this
 software in a product, an acknowledgment in the product documentation
 would be appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must
 not be misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source distribution.
 */
/*
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define VFP_CLOBBER_S0_S31 "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8",  \
"s9", "s10", "s11", "s12", "s13", "s14", "s15", "s16",  \
"s17", "s18", "s19", "s20", "s21", "s22", "s23", "s24",  \
"s25", "s26", "s27", "s28", "s29", "s30", "s31"
#define VFP_VECTOR_LENGTH(VEC_LENGTH) "fmrx    r0, fpscr                         \n\t" \
"bic     r0, r0, #0x00370000               \n\t" \
"orr     r0, r0, #0x000" #VEC_LENGTH "0000 \n\t" \
"fmxr    fpscr, r0                         \n\t"
#define VFP_VECTOR_LENGTH_ZERO "fmrx    r0, fpscr            \n\t" \
"bic     r0, r0, #0x00370000  \n\t" \
"fmxr    fpscr, r0            \n\t" 
static inline void Matrix3DMultiplyVector(SPFloat m1[16], SPFloat m2[16], SPFloat result[16])
{
    __asm__ __volatile__ ( VFP_VECTOR_LENGTH(3)
                          
                          // Interleaving loads and adds/muls for faster calculation.
                          // Let A:=src_ptr_1, B:=src_ptr_2, then
                          // function computes A*B as (B^T * A^T)^T.
                          
                          // Load the whole matrix into memory.
                          "fldmias  %2, {s8-s23}    \n\t"
                          // Load first column to scalar bank.
                          "fldmias  %1!, {s0-s3}    \n\t"
                          // First column times matrix.
                          "fmuls s24, s8, s0        \n\t"
                          "fmacs s24, s12, s1       \n\t"
                          
                          // Load second column to scalar bank.
                          "fldmias %1!,  {s4-s7}    \n\t"
                          
                          "fmacs s24, s16, s2       \n\t"
                          "fmacs s24, s20, s3       \n\t"
                          // Save first column.
                          "fstmias  %0!, {s24-s27}  \n\t" 
                          
                          // Second column times matrix.
                          "fmuls s28, s8, s4        \n\t"
                          "fmacs s28, s12, s5       \n\t"
                          
                          // Load third column to scalar bank.
                          "fldmias  %1!, {s0-s3}    \n\t"
                          
                          "fmacs s28, s16, s6       \n\t"
                          "fmacs s28, s20, s7       \n\t"
                          // Save second column.
                          "fstmias  %0!, {s28-s31}  \n\t" 
                          
                          // Third column times matrix.
                          "fmuls s24, s8, s0        \n\t"
                          "fmacs s24, s12, s1       \n\t"
                          
                          // Load fourth column to scalar bank.
                          "fldmias %1,  {s4-s7}    \n\t"
                          
                          "fmacs s24, s16, s2       \n\t"
                          "fmacs s24, s20, s3       \n\t"
                          // Save third column.
                          "fstmias  %0!, {s24-s27}  \n\t" 
                          
                          // Fourth column times matrix.
                          "fmuls s28, s8, s4        \n\t"
                          "fmacs s28, s12, s5       \n\t"
                          "fmacs s28, s16, s6       \n\t"
                          "fmacs s28, s20, s7       \n\t"
                          // Save fourth column.
                          "fstmias  %0!, {s28-s31}  \n\t" 
                          
                          VFP_VECTOR_LENGTH_ZERO
                          : "=r" (result), "=r" (m2)
                          : "r" (m1), "0" (result), "1" (m2)
                          : "r0", "cc", "memory", VFP_CLOBBER_S0_S31
                          );
}
#endif
*/
SPTransform SPTransform3DMult (SPTransform m1, SPTransform m2) {
    SPTransform result;
    
//#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
//    Matrix3DMultiplyVector(m1.m, m2.m, result.m);
//#else
    result.m[0] = m1.m[0] * m2.m[0] + m1.m[4] * m2.m[1] + m1.m[8] * m2.m[2] + m1.m[12] * m2.m[3];
    result.m[1] = m1.m[1] * m2.m[0] + m1.m[5] * m2.m[1] + m1.m[9] * m2.m[2] + m1.m[13] * m2.m[3];
    result.m[2] = m1.m[2] * m2.m[0] + m1.m[6] * m2.m[1] + m1.m[10] * m2.m[2] + m1.m[14] * m2.m[3];
    result.m[3] = m1.m[3] * m2.m[0] + m1.m[7] * m2.m[1] + m1.m[11] * m2.m[2] + m1.m[15] * m2.m[3];
    
    result.m[4] = m1.m[0] * m2.m[4] + m1.m[4] * m2.m[5] + m1.m[8] * m2.m[6] + m1.m[12] * m2.m[7];
    result.m[5] = m1.m[1] * m2.m[4] + m1.m[5] * m2.m[5] + m1.m[9] * m2.m[6] + m1.m[13] * m2.m[7];
    result.m[6] = m1.m[2] * m2.m[4] + m1.m[6] * m2.m[5] + m1.m[10] * m2.m[6] + m1.m[14] * m2.m[7];
    result.m[7] = m1.m[3] * m2.m[4] + m1.m[7] * m2.m[5] + m1.m[11] * m2.m[6] + m1.m[15] * m2.m[7];
    
    result.m[8] = m1.m[0] * m2.m[8] + m1.m[4] * m2.m[9] + m1.m[8] * m2.m[10] + m1.m[12] * m2.m[11];
    result.m[9] = m1.m[1] * m2.m[8] + m1.m[5] * m2.m[9] + m1.m[9] * m2.m[10] + m1.m[13] * m2.m[11];
    result.m[10] = m1.m[2] * m2.m[8] + m1.m[6] * m2.m[9] + m1.m[10] * m2.m[10] + m1.m[14] * m2.m[11];
    result.m[11] = m1.m[3] * m2.m[8] + m1.m[7] * m2.m[9] + m1.m[11] * m2.m[10] + m1.m[15] * m2.m[11];
    
    result.m[12] = m1.m[0] * m2.m[12] + m1.m[4] * m2.m[13] + m1.m[8] * m2.m[14] + m1.m[12] * m2.m[15];
    result.m[13] = m1.m[1] * m2.m[12] + m1.m[5] * m2.m[13] + m1.m[9] * m2.m[14] + m1.m[13] * m2.m[15];
    result.m[14] = m1.m[2] * m2.m[12] + m1.m[6] * m2.m[13] + m1.m[10] * m2.m[14] + m1.m[14] * m2.m[15];
    result.m[15] = m1.m[3] * m2.m[12] + m1.m[7] * m2.m[13] + m1.m[11] * m2.m[14] + m1.m[15] * m2.m[15];
//#endif
    
    return result;
}

#pragma mark - Box
SPVec2
SPBoxClampVec(const SPBox bb, const SPVec2 v)
{
	SPFloat x = SPFloatClamp(v.x, bb.l, bb.r);
	SPFloat y = SPFloatClamp(v.y, bb.b, bb.t);
	return SPVec2Make(x, y);
}

SPBox 
SPBoxTransform(SPBox bb, SPTransform t) {	
	SPBox bbT;
	SPVec2 corners[4] = {
		SPVec2Transform(SPVec2Make(bb.l, bb.b), t),
		SPVec2Transform(SPVec2Make(bb.l, bb.t), t),
		SPVec2Transform(SPVec2Make(bb.r, bb.b), t),
		SPVec2Transform(SPVec2Make(bb.r, bb.t), t)
	};
	
	bbT = SPBoxMake(corners[0].x, corners[0].y, corners[0].x, corners[0].y);
	for (int i=1;i<4;++i) {
		if (corners[i].x < bbT.l) bbT.l = corners[i].x;
		else if (corners[i].x > bbT.r) bbT.r = corners[i].x;
		if (corners[i].y < bbT.b) bbT.b = corners[i].y;
		else if (corners[i].y > bbT.t) bbT.t = corners[i].y;
	}
	
	return bbT;	
}

SPVec2 
SPBoxGetCorner(SPBox bb, int corner) {
	SPVec2 v;
	switch (corner) {
		case 0:
			v = SPVec2Make(bb.l,bb.b);
			break;
		case 1:
			v = SPVec2Make(bb.l,bb.t);
			break;
		case 2:
			v = SPVec2Make(bb.r,bb.b);
			break;
		case 3:
			v = SPVec2Make(bb.r,bb.t);
			break;
	}
	
	return v;
}

void SPBoxPrint(const SPBox box) {
	printf("SPBox(%f, %f, %f, %f)", box.l, box.b, box.r, box.t);
}