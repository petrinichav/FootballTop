/*
 *  VectorMath.h
 *  SpaceCowboy
 *
 *  Created by destman on 11/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef VectorMath_h
#define VectorMath_h

#ifdef __cplusplus 
extern "C" {
#endif

#include <mactypes.h>
#include <math.h>

typedef struct 
{
	double x,y,z;
}Vector3D;

typedef struct
{
    double x,y;
}Vector2D,Point2D;


typedef struct 
{
	double v[3][3];
}Matrix3x3;

typedef struct
{
	float v[4][4];
}Matrix4x4f;

typedef struct 
{
	Vector3D pos;
	Vector3D n;
	float    pen;
	void     *object;
}Collision;

extern Matrix4x4f kMatrix4x4fIdent;
extern Matrix3x3  kMatrix3x3Ident;

Matrix3x3 Matrix3x3Rotation (const Vector3D angle);
Matrix3x3 Matrix3x3Scale    (const Vector3D scale);
Matrix3x3 Matrix3x3RotationX(double angle);
Matrix3x3 Matrix3x3RotationY(double angle);
Matrix3x3 Matrix3x3RotationZ(double angle);


Matrix4x4f Matrix4x4fOrtho		(float left, float right, float bottom, float top, float near, float far);
Matrix4x4f Matrix4x4fFrustum	(float left, float right, float bottom, float top, float near, float far);
Matrix4x4f Matrix4x4fTranslate	(float x, float y, float z);
Matrix4x4f Matrix4x4fScale		(float x, float y, float z);
Matrix4x4f Matrix4x4fRotate		(float x, float y, float z);
Matrix4x4f Matrix4x4fIdent		();

Matrix4x4f  Matrix4x4fMultMatrix4x4f    (const Matrix4x4f a,const Matrix4x4f   b);
Vector3D	Vector3DMultMatrix3x3       (const Vector3D   v,const Matrix3x3    m);
Matrix3x3	Matrix3x3MultMatrix3x3      (const Matrix3x3  a,const Matrix3x3    b);

static inline Vector3D Vector3DMake(double x,double y, double z)
{
	Vector3D v = {x, y, z};
	return v;	
}

static inline Vector3D Vector3DTranslateX(const Vector3D v1, double dx)
{
    return Vector3DMake(v1.x+dx, v1.y, v1.z);
}

static inline Vector3D Vector3DTranslateY(const Vector3D v1, double dy)
{
    return Vector3DMake(v1.x, v1.y+dy, v1.z);
}

static inline Vector3D Vector3DTranslateXY(const Vector3D v1, double dx ,double dy)
{
    return Vector3DMake(v1.x+dx, v1.y+dy, v1.z);
}
    

static inline Vector3D Vector3DAdd(const Vector3D v1, const Vector3D v2)
{
	return Vector3DMake(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z);
}

static inline Vector3D Vector3DSub(const Vector3D v1, const Vector3D v2)
{
	return Vector3DMake(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z);
}

static inline double Vector3DDot(const Vector3D v1, const Vector3D v2)
{
	return v1.x*v2.x + v1.y*v2.y+ v1.z*v2.z;
}


static inline double Vector3DLenght(const Vector3D v)
{
	return sqrt(Vector3DDot(v, v));
}


static inline Vector3D Vector3DMult(const Vector3D v, const double s)
{
	return Vector3DMake(v.x*s, v.y*s, v.z*s);
}

static inline Vector3D Vector3DMultVector(const Vector3D v1, const Vector3D v2)
{
	return Vector3DMake(v1.y*v2.z-v1.z*v2.y,v1.z*v2.x-v1.x*v2.z,v1.x*v2.y-v1.y*v2.x);
}

static inline Vector3D Vector3DProject(const Vector3D v1, const Vector3D v2)
{
	return Vector3DMult(v2, Vector3DDot(v1, v2)/Vector3DDot(v2, v2));
}


static inline bool isCCW(Vector3D v1, Vector3D v2, Vector3D v3)
{
	double s = Vector3DDot(Vector3DSub(v2, v1), Vector3DSub(v3, v1));
	return s>0;
}


// Some vector functions for Point2D
static inline Vector2D Vector2DMake(double x,double y)
{
	return (Vector2D){x, y};	
}

static inline Point2D Point2DMake(double x,double y)
{
	return (Point2D){x, y};	
}

static inline double Vector2DMultVector(const Vector2D v1, const Vector2D v2)
{
    return v1.x*v2.y-v1.y*v2.x;
}

static inline double Vector2DDot(const Vector2D v1, const Vector2D v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}
    
static inline double Vector2DLenght(const Vector2D v)
{
    return sqrt(Vector2DDot(v, v));
}
    
static inline double Vector2DAngleVector(const Vector2D v1, const Vector2D v2)
{
    double cosAngle = Vector2DDot(v1, v2)/(Vector2DLenght(v1)*Vector2DLenght(v2));
    if(cosAngle>1)
    {
        cosAngle = 1;
    }
    if(cosAngle<-1)
    {
        cosAngle = -1;
    }
    double rv = acos(cosAngle);
    if(Vector2DMultVector(v1,v2)<0)
    {
        rv = -rv;
    }
    return rv;
}

static inline double Vector2DAngle(const Point2D v)
{
	return atan2(v.y, v.x);		
}

static inline Point2D Vector2DPerp(const Point2D v)
{
	return Vector2DMake(-v.y, v.x);
}

    static inline double Vector2DModMultVector(const Vector2D v1, const Vector2D v2)
    {
        return v1.x*v2.y-v1.y*v2.x;
    }    
    
    
#ifdef __cplusplus 
}
#endif
    
#endif