//
//  HelloGLKitViewController.m
//  HelloGLKit
//
//  Created by James Valaitis on 22/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "HelloGLKitViewController.h"

//	a structure to keep tack of per-vertex information
typedef struct
{
    float Position[3];
    float Color[4];
	float TextureCoord[2];
	float Normal[3];
} Vertex;

//	create array storing info of each vertex
const Vertex Vertices[] =
{
    //	front
	{{1, -1, 1},	{1, 0, 0, 1},	{1, 0}, {0, 0, 1}},
	{{1, 1, 1},		{0, 1, 0, 1},	{1, 1}, {0, 0, 1}},
	{{-1, 1, 1},	{0, 0, 1, 1},	{0, 1}, {0, 0, 1}},
	{{-1, -1, 1},	{0, 0, 0, 1},	{0, 0}, {0, 0, 1}},
	//	back
	{{1, 1, -1},	{1, 0, 0, 1},	{0, 1}, {0, 0, -1}},
	{{-1, -1, -1},	{0, 1, 0, 1},	{1, 0}, {0, 0, -1}},
	{{1, -1, -1},	{0, 0, 1, 1},	{0, 0}, {0, 0, -1}},
	{{-1, 1, -1},	{0, 0, 0, 1},	{1, 1}, {0, 0, -1}},
	//	left
	{{-1, -1, 1},	{1, 0, 0, 1},	{1, 0}, {-1, 0, 0}},
	{{-1, 1, 1},	{0, 1, 0, 1},	{1, 1}, {-1, 0, 0}},
	{{-1, 1, -1},	{0, 0, 1, 1},	{0, 1}, {-1, 0, 0}},
	{{-1, -1, -1},	{0, 0, 0, 1},	{0, 0}, {-1, 0, 0}},
	//	right
	{{1, -1, -1},	{1, 0, 0, 1},	{1, 0}, {1, 0, 0}},
	{{1, 1, -1},	{0, 1, 0, 1},	{1, 1}, {1, 0, 0}},
	{{1, 1, 1},		{0, 0, 1, 1},	{0, 1}, {1, 0, 0}},
	{{1, -1, 1},	{0, 0, 0, 1},	{0, 0}, {1, 0, 0}},
	//	top
	{{1, 1, 1},		{1, 0, 0, 1},	{1, 0}, {0, 1, 0}},
	{{1, 1, -1},	{0, 1, 0, 1},	{1, 1}, {0, 1, 0}},
	{{-1, 1, -1},	{0, 0, 1, 1},	{0, 1}, {0, 1, 0}},
	{{-1, 1, 1},	{0, 0, 0, 1},	{0, 0}, {0, 1, 0}},
	//	bottom
	{{1, -1, -1},	{1, 0, 0, 1},	{1, 0}, {0, -1, 0}},
	{{1, -1, 1},	{0, 1, 0, 1},	{1, 1}, {0, -1, 0}},
	{{-1, -1, 1},	{0, 0, 1, 1},	{0, 1}, {0, -1, 0}},
	{{-1, -1, -1},	{0, 0, 0, 1},	{0, 0}, {0, -1, 0}}
};

//	an array specifying the three vertices that make up each triangle
const GLubyte Indices[] =
{
	//	front
    0, 1, 2,
    2, 3, 0,
	//	back
	4, 6, 5,
	4, 5, 7,
	//	left
	8, 9, 10,
	10, 11, 8,
	//	right
	12, 13, 14,
	14, 15, 12,
	//	top
	16, 17, 18,
	18, 19, 16,
	//	bottom
	20, 21, 22,
	22, 23, 20
};

@interface HelloGLKitViewController ()
{
	float		_curRed;
	BOOL		_increasing;
	
	float		_rotation;
	float		_lightRotation;
	
	GLuint		_vertexBuffer;
	GLuint		_indexBuffer;
	
	GLuint		_vertexArray;
}

@property (nonatomic, strong)	EAGLContext			*context;
@property (nonatomic, strong)	GLKBaseEffect		*effect;

@end

@implementation HelloGLKitViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.context				= [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if (!self.context)
		NSLog(@"Failed to create ES context.");
	
	GLKView *view				= (GLKView *)self.view;
	
	view.context				= self.context;
	
	view.drawableMultisample	= GLKViewDrawableMultisample4X;
	
	[self setupGL];
}

#pragma mark - Setting Up OpenGL

- (void)applyVertexAttributes
{
	//	create new vertex array object and bind to it, now all set up calls are stored in this array
	glGenVertexArraysOES(1, &_vertexArray);
	glBindVertexArrayOES(_vertexArray);
	
	//	creates new vertex buffer object, makes vertex buffer active buffer for commands using gl_array_buffer, and moves data from cpu to gpu
	glGenBuffers(1, &_vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
	
	//	same for this, but with index buffer
	glGenBuffers(1, &_indexBuffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
	
	//	enable position, colour, texture and normal of vertex
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribColor);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
	glEnableVertexAttribArray(GLKVertexAttribNormal);
	
	/**
	 *	@param	glk vertex attribute
	 *	@param	number of values present for this attribute
	 *	@param	type of value
	 *	@param	this is always false
	 *	@param	size of the c struct
	 *	@param	offset of the particular member of the vertex struct
	 */
	glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Position));
	glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Color));
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, TextureCoord));
	glVertexAttribPointer(GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, TextureCoord));
	glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Normal));
	
	//	we're done with this now, so we bind to 0 instead of array
	glBindVertexArrayOES(0);
}

- (void)setupFog
{
	self.effect.fog.color				= GLKVector4Make(1.0, 0.0, 0.0, 1.0);
	self.effect.fog.enabled				= YES;
	self.effect.fog.end					= 5.5;
	self.effect.fog.start				= 5.0;
	self.effect.fog.mode				= GLKFogModeLinear;
}

- (void)setupGL
{
	//	sets open gl context to our current context
	[EAGLContext setCurrentContext:self.context];
	
	//	do not render backwards facing frames
	glEnable(GL_CULL_FACE);
	
	//	initialise our glkbaseeffect
	self.effect					= [[GLKBaseEffect alloc] init];
	
	[self setupTextures];
	
	[self setupLighting];
	
	[self setupFog];
	
	[self applyVertexAttributes];
}

- (void)setupLighting
{
	//	set the light 0 property on our effect
	self.effect.light0.enabled			= GL_TRUE;
	self.effect.light0.diffuseColor		= GLKVector4Make(0, 1, 1, 1);
	self.effect.light0.ambientColor		= GLKVector4Make(0, 0, 0, 1);
	self.effect.light0.specularColor	= GLKVector4Make(0, 0, 0, 1);
	self.effect.light0.position			= GLKVector4Make(0, 1.5, -6, 1);
	
	//	set the light 1 property and enable it
	self.effect.light1.enabled			= GL_TRUE;
	self.effect.light1.diffuseColor		= GLKVector4Make(1.0, 1.0, 0.8, 1.0);
	self.effect.light1.position			= GLKVector4Make(0.0, 0.0, 1.5, 1.0);
	
	//	define global light property
	self.effect.lightModelAmbientColor	= GLKVector4Make(0, 0, 0, 1);
	self.effect.material.specularColor	= GLKVector4Make(1, 1, 1, 1);
	self.effect.lightingType			= GLKLightingTypePerPixel;
}

- (void)setupTextures
{
	//	specify we want to vertically flip the texture to match opengl's coordinate system
	NSDictionary *options		= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
	NSError *error;
	
	//	get the path of the image, then load it as a texture with our predefined options and if there was an error we log it
	NSString *path				= [[NSBundle mainBundle] pathForResource:@"tile_floor" ofType:@"png"];
	GLKTextureInfo *info		= [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
	if (!info)
		NSLog(@"Error loading the file: %@", error.localizedDescription);
	
	//	set the texture's name and enable it
	self.effect.texture2d0.name	= info.name;
	[self.effect.texture2d0 setEnabled:GL_TRUE];
	
	//	get the path of the image, then load it as a texture with our predefined options and if there was an error we log it
	path						= [[NSBundle mainBundle] pathForResource:@"item_powerup_fish" ofType:@"png"];
	info						= [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
	if (!info)
		NSLog(@"Error loading the file: %@", error.localizedDescription);
	
	//	set our second texture's name and enable it
	self.effect.texture2d1.name	= info.name;
	[self.effect.texture2d1 setEnabled:GL_TRUE];
	self.effect.texture2d1.envMode		= GLKTextureEnvModeDecal;
}

- (void)tearDownGL
{
	//	sets open gl context to our current context
	[EAGLContext setCurrentContext:self.context];
	
	self.effect					= nil;
	
	//	delete the buffers
	glDeleteBuffers(1, &_vertexBuffer);
	glDeleteBuffers(1, &_indexBuffer);
}

#pragma mark - Action & Selector Methods

- (IBAction)diffuseChanged:		(UISlider *)sender
{
	self.effect.light0.diffuseColor			= GLKVector4Make(0, sender.value, sender.value, 1);
}

- (IBAction)ambientChanged:		(UISlider *)sender
{
	self.effect.light0.ambientColor			= GLKVector4Make(sender.value, sender.value, sender.value, 1);
}

- (IBAction)specularChanged:	(UISlider *)sender
{
	self.effect.light0.specularColor		= GLKVector4Make(sender.value, sender.value, sender.value, 1);
}

- (IBAction)shininessChanged:	(UISlider *)sender
{
	self.effect.material.shininess			= sender.value;
}

- (IBAction)cutoffChanged:		(UISlider *)sender
{
	self.effect.light0.spotCutoff			= sender.value;
}

- (IBAction)exponentChanged:	(UISlider *)sender
{
	self.effect.light0.spotExponent			= sender.value;
}

- (IBAction)constantChanged:	(UISlider *)sender
{
	self.effect.light0.constantAttenuation	= sender.value;
}

- (IBAction)linearChanged:		(UISlider *)sender
{
	self.effect.light0.linearAttenuation	= sender.value;
}

- (IBAction)quadraticChanged:	(UISlider *)sender
{
	self.effect.light0.quadraticAttenuation	= sender.value;
}

#pragma mark - GLKViewDelegate Methods

- (void)glkView:(GLKView *)view
	 drawInRect:(CGRect)rect
{
	//	when clearing the screen, make it red
	glClearColor(0.0, 0.0, 0.0, 1.0);
	//	does the clearing (of the render/colour buffer in this case)
	glClear(GL_COLOR_BUFFER_BIT);
	
	//	use the effect on the draw
	[self.effect prepareToDraw];
	
	//	bind to the vertex array with all of our set up
	glBindVertexArrayOES(_vertexArray);
	
	//	specifies manner of drawing vertices, get vertices count by dividing total size by size of one, data type of each index, unnecessary
	glDrawElements(GL_TRIANGLES, sizeof(Indices) / sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

#pragma mark - GLKViewControllerDelegate Methods

- (void)update
{
	/*
	if (_increasing)
		_curRed								+= 1.0 * self.timeSinceLastUpdate;
	else
		_curRed								-= 1.0 * self.timeSinceLastUpdate;
	
	if (_curRed >= 1.0)
	{
		_curRed								= 1.0;
		_increasing							= NO;
	}
	else if (_curRed <= 0.0)
	{
		_curRed								= 0.0;
		_increasing							= YES;
	}
	 */
	
	//	get the aspect ratio of the glkview
	float aspect							= fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	
	//	easily create perspective matrix (fov at 65, aspect ratio above, near plane at 4 units way from eye, and far plane at 10)
	GLKMatrix4 projectionMatrix				= GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
	
	//	set the projection matrix on the effect's transform property
	self.effect.transform.projectionMatrix	= projectionMatrix;
	
	//	rotate and position the light
	GLKMatrix4 lightModelViewMatrix			= GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
	_lightRotation							+= -90 *self.timeSinceLastUpdate;
	lightModelViewMatrix					= GLKMatrix4Rotate(lightModelViewMatrix, GLKMathDegreesToRadians(25), 1, 0, 0);
	lightModelViewMatrix					= GLKMatrix4Rotate(lightModelViewMatrix, GLKMathDegreesToRadians(_lightRotation), 0, 1, 0);
	
	self.effect.transform.modelviewMatrix	= lightModelViewMatrix;
	self.effect.light1.position				= GLKVector4Make(0, 0, 1.5, 1);
	
	//	first we create a matrix which translates everything 6 units backwards (z axis)
	GLKMatrix4 modelViewMatrix				= GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
	
	//	we're also going to make the square rotate 90 degrees every second
	_rotation								+= 90 * self.timeSinceLastUpdate;
	
	//	rotate at an angle so we can the cube in 3d
	modelViewMatrix							= GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(25), 1, 0, 0);
	//	we concatenate the rotation matrix to our model view matrix
	modelViewMatrix							= GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 1, 0);
	
	//	we then set this on the effect's transform property
	self.effect.transform.modelviewMatrix	= modelViewMatrix;
}

- (void)touchesBegan:(NSSet *)touches
		   withEvent:(UIEvent *)event
{
	NSLog(@"Time Since Last Update: %f", self.timeSinceLastUpdate);
	NSLog(@"Time Since Last Draw: %f", self.timeSinceLastDraw);
	NSLog(@"Time Since First Resume: %f", self.timeSinceFirstResume);
	NSLog(@"Time Since Last Resume: %f", self.timeSinceLastResume);
	
	self.paused								= !self.paused;
}

@end
