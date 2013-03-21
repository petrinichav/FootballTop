/*
 *  VectorMath.cpp
 *  SpaceCowboy
 *
 *  Created by destman on 11/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "VectorMath.h"

Matrix3x3  kMatrix3x3Ident = {1,0,0, 0,1,0, 0,0,1};

Matrix3x3 Matrix3x3MultMatrix3x3(const Matrix3x3 a,const Matrix3x3 b)
{
	Matrix3x3 m;
	for(int i=0;i<3;i++)
		for(int j=0;j<3;j++)
		{
			m.v[i][j]=0;
			for (int k=0;k<3;k++) 
				m.v[i][j]+=a.v[i][k]*b.v[k][j];
		}	
	return m;
}

Matrix4x4f Matrix4x4fMultMatrix4x4f(const Matrix4x4f a,const Matrix4x4f b)
{
	Matrix4x4f rv;
	for(int i=0;i<4;i++)
		for(int j=0;j<4;j++)
		{
			rv.v[i][j]=0;
			for (int k=0;k<4;k++) 
				rv.v[i][j]+=a.v[i][k]*b.v[k][j];
		}	
	return rv;
}

Vector3D	Vector3DMultMatrix3x3(const Vector3D v,const Matrix3x3 m)
{
	Vector3D r;
	
	r.x = m.v[0][0]*v.x + m.v[0][1]*v.y + m.v[0][2]*v.z;
	r.y = m.v[1][0]*v.x + m.v[1][1]*v.y + m.v[1][2]*v.z;
	r.z = m.v[2][0]*v.x + m.v[2][1]*v.y + m.v[2][2]*v.z;
	
	return r;
}


Matrix3x3 Matrix3x3RotationX(double angle)
{
	Matrix3x3 m;
	
	double cosA = cos(angle*M_PI/180);
	double sinA = sin(angle*M_PI/180);
	
	m.v[0][0] = 1;
	m.v[0][1] = 0;
	m.v[0][2] = 0;	
	
	m.v[1][0] = 0;	
	m.v[1][1] = cosA;
	m.v[1][2] = -sinA;	
	
	m.v[2][0] = 0;	
	m.v[2][1] = sinA;
	m.v[2][2] = cosA;
	
	return m;
}

Matrix3x3 Matrix3x3RotationY(double angle)
{
	Matrix3x3 m;
	
	double cosA = cos(angle*M_PI/180);
	double sinA = sin(angle*M_PI/180);
	
	m.v[0][0] = cosA;
	m.v[0][1] = 0;
	m.v[0][2] = sinA;
	
	m.v[1][0] = 0;
	m.v[1][1] = 1;
	m.v[1][2] = 0;	
	
	m.v[2][0] = -sinA;	
	m.v[2][1] = 0;
	m.v[2][2] = cosA;
	
	return m;
}

Matrix3x3 Matrix3x3RotationZ(double angle)
{
	Matrix3x3 m;
	
	double cosA = cos(angle*M_PI/180);
	double sinA = sin(angle*M_PI/180);
	
	m.v[0][0] = cosA;
	m.v[0][1] = -sinA;
	m.v[0][2] = 0;
	
	m.v[1][0] = sinA;	
	m.v[1][1] = cosA;
	m.v[1][2] = 0;	
	
	m.v[2][0] = 0;	
	m.v[2][1] = 0;
	m.v[2][2] = 1;
	
	return m;
}


Matrix3x3 Matrix3x3Rotation (const Vector3D angle)
{
	return Matrix3x3MultMatrix3x3(Matrix3x3MultMatrix3x3(Matrix3x3RotationX(angle.x),Matrix3x3RotationY(angle.y)), Matrix3x3RotationZ(angle.z));
}

Matrix3x3 Matrix3x3Scale    (const Vector3D scale)
{
	Matrix3x3 m;
	double *scaleK  = (double *)&scale;
	for(int i=0;i<3;i++)
		for(int j=0;j<3;j++)
		{
			if(i==j)
				m.v[j][j] = scaleK[i];
			else
				m.v[i][j] = 0;
		}	
	return m;
}



//http://www.opengl.org/sdk/docs/man/xhtml/glFrustum.xml
Matrix4x4f Matrix4x4fOrtho   (float left, float right, float bottom, float top, float near, float far)
{
	Matrix4x4f m;
	
	m.v[0][0] = 2.0f/(right-left);
	m.v[0][1] = 0;
	m.v[0][2] = 0;
	m.v[0][3] = 0;
	
	m.v[1][0] = 0;
	m.v[1][1] = 2.0f/(top-bottom);
	m.v[1][2] = 0;
	m.v[1][3] = 0;
	
	m.v[2][0] = 0;
	m.v[2][1] = 0;
	m.v[2][2] = -2.0/(far-near);
	m.v[2][3] = 0;
	
	m.v[3][0] = - (right + left)/(right - left);
	m.v[3][1] = - (top + bottom)/(top - bottom);
	m.v[3][2] = - (far + near)/(far - near);
	m.v[3][3] = 1;	
	
	return m;
}


//http://www.opengl.org/sdk/docs/man/xhtml/glFrustum.xml
Matrix4x4f Matrix4x4fFrustum(float left, float right, float bottom, float top, float near, float far)
{
	Matrix4x4f m;
	
	m.v[0][0] = 2*near/(right-left);
	m.v[0][1] = 0;
	m.v[0][2] = 0;
	m.v[0][3] = 0;
	
	m.v[1][0] = 0;
	m.v[1][1] = 2*near/(top-bottom);
	m.v[1][2] = 0;
	m.v[1][3] = 0;
	
	
	m.v[2][0] = (right+left)/(right-left);
	m.v[2][1] = (top+bottom)/(top-bottom);
	m.v[2][2] = -(far+near)/(far-near);
	m.v[2][3] = -1;
	
	m.v[3][0] = 0;
	m.v[3][1] = 0;
	m.v[3][2] = -2*far*near/(far-near);
	m.v[3][3] = 0;
	
	return m;
}


Matrix4x4f Matrix4x4fTranslate(float x, float y, float z)
{
	Matrix4x4f m;	
	
	m.v[0][0] = 1;
	m.v[0][1] = 0;
	m.v[0][2] = 0;
	m.v[0][3] = 0;
	
	m.v[1][0] = 0;
	m.v[1][1] = 1;
	m.v[1][2] = 0;
	m.v[1][3] = 0;
	
	
	m.v[2][0] = 0;
	m.v[2][1] = 0;
	m.v[2][2] = 1;
	m.v[2][3] = 0;
	
	m.v[3][0] = x;
	m.v[3][1] = y;
	m.v[3][2] = z;
	m.v[3][3] = 1;	
	
	return m;
}

Matrix4x4f Matrix4x4fScale(float x, float y, float z)
{
	Matrix4x4f m;
	
	m.v[0][0] = x;
	m.v[0][1] = 0;
	m.v[0][2] = 0;
	m.v[0][3] = 0;
	
	m.v[1][0] = 0;
	m.v[1][1] = y;
	m.v[1][2] = 0;
	m.v[1][3] = 0;
	
	
	m.v[2][0] = 0;
	m.v[2][1] = 0;
	m.v[2][2] = z;
	m.v[2][3] = 0;
	
	m.v[3][0] = 0;
	m.v[3][1] = 0;
	m.v[3][2] = 0;
	m.v[3][3] = 1;	
	
	return m;
}

Matrix4x4f Matrix4x4fRotate(float x, float y, float z)
{
	Matrix4x4f m;
	
	Matrix3x3 R = Matrix3x3Rotation(Vector3DMake(x, y, z));
	
	m.v[0][0] = R.v[0][0];
	m.v[0][1] = R.v[0][1];
	m.v[0][2] = R.v[0][2];
	m.v[0][3] = 0;
	
	m.v[1][0] = R.v[1][0];
	m.v[1][1] = R.v[1][1];
	m.v[1][2] = R.v[1][2];
	m.v[1][3] = 0;
	
	
	m.v[2][0] = R.v[2][0];
	m.v[2][1] = R.v[2][1];
	m.v[2][2] = R.v[2][2];
	m.v[2][3] = 0;
	
	m.v[3][0] = 0;
	m.v[3][1] = 0;
	m.v[3][2] = 0;
	m.v[3][3] = 1;	
	
	return m;
}




