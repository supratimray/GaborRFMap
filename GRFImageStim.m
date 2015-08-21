//
// HAImageStim.m
// Experiment
//
//  Created by Ping Sun on Fri Jan 20 2006.
//  Copyright (c) 2006. All rights reserved.
//

// Name modified to GRFImageStim from HAImageStim by Supratim Ray

#import "GRFImageStim.h"
#import <Lablib/LLTextUtil.h>
#import <Lablib/LLMultiplierTransformer.h>

GLuint				imageTexture = nil;
GLuint				backgroundTexture = nil;

NSString *ImageAzimuthDegKey;
NSString *ImageElevationDegKey;
NSString *ImageDirectionDegKey;
NSString *ImageSizeDegKey = @"sizeDeg";

@implementation GRFImageStim

- (float)azimuthDeg {

	return azimuthDeg;
}
/*
- (void)bindValuesToKeysWithPrefix:(NSString *)newPrefix;
{
	NSEnumerator *enumerator;
	NSString *key, *prefixedKey;
	
	[self unbindValues];
	prefix = newPrefix;
	[prefix retain];
	
	enumerator = [keys objectEnumerator];
	while ((key = [enumerator nextObject]) != nil) {
		prefixedKey = [LLTextUtil capitalize:key prefix:prefix];
		[self bind:key 
				toObject:[NSUserDefaultsController sharedUserDefaultsController] 
				withKeyPath:[NSString stringWithFormat:@"values.%@", prefixedKey] options:nil];
	}
}
*/
- (NSBitmapImageRep*)bmpImage	{ return bmpRep; }

- (void)dealloc;
{

	if(glQuad) {
		free(glQuad);
	}
	//[self unbindValues];
	[bmpRep release];
	//[keys release];
	/*if (displays != nil) {
		[displays release];
	}*/
	[super dealloc];
}

- (void)discardData
{

// Dump the bitmap
	if(bmpRep)
	{
		[bmpRep release];
		bmpRep = nil;
	}

// Dump the texture
	glDeleteTextures(1, &imageTexture);
	
// Clear the image width & height
	imgWidth = 0.0;
	imgHeight = 0.0;
}


// We need this to adhere to the LLVisualStimulus protocol, but return zero because we have no direction

- (float)directionDeg;
{
	return directionDeg;
}

- (void)drawImage
{

	if(!bmpRep)
		return;

	if(![bmpRep bitmapData])
		return;
    
    // [Vinay] - compute the aspect ratio and draw the stimulus as per the original aspect ratio
    // float *aspectRatio;
    aspectRatio = (float)imgWidth/(float)imgHeight;

	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, imageTexture);
	
	glColor4f(1.0, 1.0, 1.0, 1.0);

// Draw it!
	glBegin(GL_QUADS);
        /*
		glTexCoord2f(0.0, 0.0); 
		glVertex2f(azimuthDeg + sizeDeg/2, elevationDeg + sizeDeg/2);
		glTexCoord2f(imgWidth, 0.0); 
		glVertex2f(azimuthDeg - sizeDeg/2, elevationDeg + sizeDeg/2);
		glTexCoord2f(imgWidth, imgHeight); 
		glVertex2f(azimuthDeg - sizeDeg/2, elevationDeg - sizeDeg/2);
		glTexCoord2f(0.0, imgHeight); 
		glVertex2f(azimuthDeg + sizeDeg/2, elevationDeg - sizeDeg/2);
        */
    
        glTexCoord2f(0.0, 0.0);
        glVertex2f(azimuthDeg - (aspectRatio * sizeDeg)/2, elevationDeg + sizeDeg/2);
        glTexCoord2f(imgWidth, 0.0);
        glVertex2f(azimuthDeg + (aspectRatio * sizeDeg)/2, elevationDeg + sizeDeg/2);
        glTexCoord2f(imgWidth, imgHeight);
        glVertex2f(azimuthDeg + (aspectRatio * sizeDeg)/2, elevationDeg - sizeDeg/2);
        glTexCoord2f(0.0, imgHeight);
        glVertex2f(azimuthDeg - (aspectRatio * sizeDeg)/2, elevationDeg - sizeDeg/2);
    
	glEnd();
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
}

- (float)elevationDeg;
{
	return elevationDeg;
}

- (void)erase {

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, backgroundTexture);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);   // decal mode
	glBegin(GL_QUADS);
		glTexCoord2f(0.0, 0.0); 
		glVertex2f(azimuthDeg + sizeDeg/2, elevationDeg + sizeDeg/2);
		glTexCoord2f(imgWidth, 0.0); 
		glVertex2f(azimuthDeg - sizeDeg/2, elevationDeg + sizeDeg/2);
		glTexCoord2f(imgWidth, imgHeight); 
		glVertex2f(azimuthDeg - sizeDeg/2, elevationDeg - sizeDeg/2);
		glTexCoord2f(0.0, imgHeight); 
		glVertex2f(azimuthDeg + sizeDeg/2, elevationDeg - sizeDeg/2);
	glEnd();
	glDisable(GL_TEXTURE_2D);
}

- (void)genQuad
{
	float base = 1.0;
	float depth = 1.0;
	
	float scaledX = base * scaleX;
	float scaledY = base * scaleY;
	
	glQuad = malloc(sizeof(Vector3) * 4);
	
	glQuad[0].x = scaledX;
	glQuad[0].y = scaledY;
	glQuad[0].z = depth;

	glQuad[1].x = -scaledX;
	glQuad[1].y = scaledY;
	glQuad[1].z = depth;

	glQuad[2].x = -scaledX;
	glQuad[2].y = -scaledY;
	glQuad[2].z = depth;

	glQuad[3].x = scaledX;
	glQuad[3].y = -scaledY;
	glQuad[3].z = depth;

}

- (void)getTextureInfo
{
	if([bmpRep hasAlpha])
		bpp = GL_RGBA;
	else
		bpp = GL_RGB;
	
	datatype = GL_UNSIGNED_BYTE;
}

- (id)init {
	
	LLMultiplierTransformer *transformPC;

	if ((self = [super init]) != nil) {
	
		//Default map stim value
		azimuthDeg = 0.0;
		elevationDeg = 0.0;
		sizeDeg = 8.0;
		directionDeg = 0.0;
				
		glClearColor(0.5, 0.5, 0.5, 1.0);						// set the background color
		glShadeModel(GL_FLAT);									// flat shading
		scaleFactor = 100.0;
		imgWidth = imgHeight = 0.0;
		scaleX = scaleY = 1.0;
		//txID = 0;
		//[self genQuad];
		if (!backgroundTexture) {
			[self makeBackgroundTexture];
		}
		ready = YES;
		
		ImageAzimuthDegKey = LLAzimuthDegKey;
		ImageDirectionDegKey = LLDirectionDegKey;
		ImageElevationDegKey = LLElevationDegKey;

		stimPrefix = @"Image";					// make our keys different from other LLVisualStimuli
		[keys addObjectsFromArray:[NSArray arrayWithObjects: ImageSizeDegKey, nil]];
		if (![NSValueTransformer valueTransformerForName:@"MultiplierTransformer"]) {
			transformPC = [[[LLMultiplierTransformer alloc] init] autorelease];;
			[transformPC setMultiplier:100.0];
			[NSValueTransformer setValueTransformer:transformPC forName:@"MultiplierTransformer"];
		}
	}
	return self;
}

- (void)initGL
{

	int samplesPerPixel = 0;
	GLuint err = 0;
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
// Enable client storage
	glPixelTransferf(GL_RED_BIAS, 0.0);
	glPixelTransferf(GL_GREEN_BIAS, 0.0);
	glPixelTransferf(GL_BLUE_BIAS, 0.0);
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, 1);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, imgWidth);
// Generate a texture ID
	glGenTextures(1, &imageTexture);
// Bind to our newly created texture ID
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, imageTexture);
// Specify the texture
	samplesPerPixel = [bmpRep samplesPerPixel];
//	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, bpp, imgWidth, imgHeight, 0, GL_RGB, datatype, [bmpRep bitmapData]);
	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, bpp, imgWidth, imgHeight, 0, GL_RGB, datatype, [bmpRep bitmapData]);

	err = glGetError();
	if(err)
	{
		NSLog(@"WARNING: OpenGL Error 0x%x while loading texture with glTexImage2D().", err);
		[self discardData];
		ready = NO;
		return;
	}
// Rebuild our geometry to match the texture
	//[self genQuad];
	ready = YES;
}

- (void)loadImageParams:(ImageParams *)pImageParams;
{
	pImageParams->azimuthDeg = azimuthDeg;							 
	pImageParams->elevationDeg = elevationDeg;						 
	pImageParams->sizeDeg = sizeDeg;							
	pImageParams->directionDeg = directionDeg;								
}

- (void)loadTextureFromFile:(NSString*)filePath;
{

// First, deallocate any image reps we might have.
	if(bmpRep)
	{
		[bmpRep release];
// We also need to delete our texture ID
		glDeleteTextures(1, &imageTexture);
	}
	if(!filePath)
		return;
// Get raw bitmap data from the NSImage
//	bmpRep = [[NSBitmapImageRep imageRepWithContentsOfFile:filePath] retain];
	
	NSImage	*currentImage = [[NSImage alloc] initWithContentsOfFile:filePath];
	
//	NSSize imageSize = [currentImage size];
	[currentImage lockFocus];
 
    bmpRep = [[NSBitmapImageRep alloc] initWithData:[currentImage TIFFRepresentation]]; // initWithFocusedViewRect:NSMakeRect(0,0,imageSize.width,imageSize.height)];
//    bmpRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,imageSize.width,imageSize.height)];
 
	imgWidth = [bmpRep size].width;
	imgHeight = [bmpRep size].height;
	
	[currentImage unlockFocus];
			
//[self genImageInfo:[filePath lastPathComponent]];
// Set our scaling factors
	scaleX = imgWidth / scaleFactor;
	scaleY = imgHeight / scaleFactor;
	//NSLog(@"Image: %d x %d", imgWidth, imgHeight);
	[self getTextureInfo];
// Run through our initialization routine
	[self initGL];	
}


- (NSBitmapImageRep *)getImageStimBitmap:(NSString*)filePath;
{
    
    // First, deallocate any image reps we might have.
    /*
	if(bmpRep && !(bmpRep == nil || [bmpRep bitmapData] == nil))
	{
		[bmpRep release];
	}*/
	if(!filePath)
		return 0;
    // Get raw bitmap data from the NSImage
	NSImage	*currentImage = [[NSImage alloc] initWithContentsOfFile:filePath];
    [currentImage lockFocus];
    bmpRep = [[NSBitmapImageRep alloc] initWithData:[currentImage TIFFRepresentation]];
    [currentImage unlockFocus];
    return bmpRep;
}

- (void)setImageStimFromBitmap:(NSBitmapImageRep *)bmp;
{
    
    // First, deallocate any image reps we might have.
	if(bmp)
	{
		glDeleteTextures(1, &imageTexture);
	}
	
    bmpRep = bmp;
    
    imgWidth = [bmpRep size].width;
	imgHeight = [bmpRep size].height;
    
    // Set our scaling factors
	scaleX = imgWidth / scaleFactor;
	scaleY = imgHeight / scaleFactor;
	//NSLog(@"Image: %d x %d", imgWidth, imgHeight);
	[self getTextureInfo];
    // Run through our initialization routine
	[self initGL];
}

- (void)makeBackgroundImage;
{
	int i, j;
    
	for (i = 0; i < kImageWidth; i++) {
		for (j = 0; j < kImageHeight; j++) {
			backgroundImage[i][j] = (GLubyte) 0;
		}
	}
}

- (void)makeBackgroundTexture;
{
	
	[self makeBackgroundImage];
	glGenTextures(1, &backgroundTexture);
	glBindTexture(GL_TEXTURE_2D, backgroundTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_CACHED_APPLE);
	glPixelTransferf(GL_RED_BIAS, 0.5);
	glPixelTransferf(GL_GREEN_BIAS, 0.5);
	glPixelTransferf(GL_BLUE_BIAS, 0.5);
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, 1);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, kImageWidth, 
					kImageHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, 
					backgroundImage);
}

- (void)setAzimuthDeg:(float)newAzimuth {

	azimuthDeg = newAzimuth;
	[self updateIntegerDefault:azimuthDeg key:ImageAzimuthDegKey];

}

// We need this to adhere to the protocol, but we don't have any direction so we do nothing

- (void)setDirectionDeg:(float)newDirection;
{
	directionDeg = newDirection;
	[self updateIntegerDefault:directionDeg key:ImageDirectionDegKey];
}

- (void)setElevationDeg:(float)newElevation {

	elevationDeg = newElevation;
	[self updateIntegerDefault:elevationDeg key:ImageElevationDegKey];
}

- (void)setImageStim:(NSString *)imageFile;
{

	[self loadTextureFromFile:imageFile];
}

- (void)setSizeDeg:(float)newSize {

	sizeDeg = newSize;
	[self updateIntegerDefault:sizeDeg key:ImageSizeDegKey];
}

/*- (void)setWidthDeg:(double)widDeg heightDeg:(double)heiDeg;
{
    widthDeg = widDeg;
    heightDeg = heiDeg;
}

- (void)setHeightDeg:(double)height {

	heightDeg = height;
}*/

- (void)store;
{
	[self loadImageParams:&baseImageStim];
}

- (void)restore;
{
	[self setImageStimData: baseImageStim];
}

- (void)setFrame:(NSNumber *)frameNumber;
{
}

- (void)setImageStimData:(ImageParams)img;
{
	[self setAzimuthDeg:img.azimuthDeg];
	[self setElevationDeg:img.elevationDeg];
	[self setSizeDeg:img.sizeDeg];
	[self setDirectionDeg:img.directionDeg];
}
	
- (ImageParams *)imageStimData;
{	
	[self loadImageParams:&imageStim];
	return &imageStim;
}
/*
- (void)unbindValues;
{
	NSEnumerator *enumerator;
	NSString *key;
	
	if (prefix != nil) {
		enumerator = [keys objectEnumerator];
		while ((key = [enumerator nextObject]) != nil) {
			[self unbind:key];
		}
		[prefix release];
		prefix = nil;
	}
}
*/
- (float)sizeDeg;
{
	return sizeDeg;
}

@end
