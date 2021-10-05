//
// cocos2d GLU implementation
//
// implementation of GLU functions
//

#ifdef __cplusplus
extern "C" {
#endif

#ifndef GLU_H
#define GLU_H

#include <OpenGLES/ES1/gl.h>

void gluLookAt(GLfloat eyeX, GLfloat eyeY, GLfloat eyeZ, GLfloat lookAtX, GLfloat lookAtY, GLfloat lookAtZ, GLfloat upX, GLfloat upY, GLfloat upZ);
void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);
GLint gluUnProject(GLfloat winx, GLfloat winy, GLfloat winz,
				 const GLfloat modelMatrix[16], 
				 const GLfloat projMatrix[16],
				 const GLint viewport[4],
				  GLfloat *objx, GLfloat *objy, GLfloat *objz);
	



#endif

#ifdef __cplusplus
}
#endif
