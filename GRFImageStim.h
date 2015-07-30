//
//  HAImageStim.h
//
//  Created by Ping Sun on Fri Jan 20 2006.
//  Copyright (c) 2006. All rights reserved.
//

// Modified to GRFImageStim by Supratim Ray

#import <Lablib/LLVisualStimulus.h>
#import <Lablib/LLDisplays.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#import <QuartzCore/QuartzCore.h>

typedef struct {
	float	azimuthDeg;		// Center of image 
	float	elevationDeg;	// Center of image 
	float	sizeDeg;		// size of drawing  (not in the image)
	float	directionDeg;	// direction of drawing  (not in the image)
} ImageParams;

typedef struct
{
	float x, y, z;
} Vector3;

#define kLLImageStimEventDesc\
	{{@"float", @"azimuthDeg", 1, offsetof(ImageParams, azimuthDeg)},\
	{@"float", @"elevationDeg", 1, offsetof(ImageParams, elevationDeg)},\
	{@"float", @"sizeDeg", 1, offsetof(ImageParams, widthDeg)},\
	{@"float", @"directionDeg", 1, offsetof(ImageParams, directionDeg)},\
	{nil}}

#define kImageWidth 64
#define kImageHeight 64

extern NSString *ImageAzimuthDegKey;
extern NSString *ImageElevationDegKey;
extern NSString *ImageSizeDegKey;
extern NSString *ImageDirectionDegKey;

@interface GRFImageStim : LLVisualStimulus {
	
	GLubyte				backgroundImage[kImageHeight][kImageWidth];
	ImageParams			imageStim;
	ImageParams			baseImageStim;
	NSBitmapImageRep	*bmpRep;
	Vector3				*glQuad;
	long				imgWidth;
	long				imgHeight;
	float				scaleX;
	float				scaleY;
	float				scaleFactor;
	GLenum				pixfmt;
	GLenum				bpp;
	GLenum				datatype;
	BOOL				ready;
	//float				azimuthDeg;
	//float				elevationDeg;
	float				sizeDeg;	
	//float				directionDeg;	
}

- (NSBitmapImageRep*)bmpImage;
//- (void)bindValuesToKeysWithPrefix:(NSString *)newPrefix;
- (ImageParams *)imageStimData;
- (void)discardData;
- (void)drawImage;
//- (double)stimulationSizeDeg;
- (float)sizeDeg;
- (void)erase;
- (void)genQuad;
- (void)getTextureInfo;
- (void)initGL;
- (void)loadImageParams:(ImageParams *)pImageParams;
- (void)loadTextureFromFile:(NSString*)filePath;
- (NSBitmapImageRep *)getImageStimBitmap:(NSString*)filePath;
- (void)setImageStimFromBitmap:(NSBitmapImageRep *)bmp;
- (void)makeBackgroundImage;
- (void)makeBackgroundTexture;
- (void)restore;
- (void)setAzimuthDeg:(float)newAzimuth;
- (void)setElevationDeg:(float)newElevation;
- (void)setImageStim:(NSString *)imageFile;
- (void)setImageStimData:(ImageParams)newImageStimData;
- (void)setSizeDeg:(float)newSize;
- (void)store;
//- (void)unbindValues;
//- (double)widthDeg;
@end

