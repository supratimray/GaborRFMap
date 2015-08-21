/*
GRFStimuli.m
Stimulus generation for GaborRFMap
March 29, 2003 JHRM
*/

#import "GRF.h"
#import "GaborRFMap.h"
#import "GRFStimuli.h"
#import "UtilityFunctions.h"

#define kDefaultDisplayIndex	1		// Index of stim display when more than one display
#define kMainDisplayIndex		0		// Index of main stimulus display
#define kPixelDepthBits			32		// Depth of pixels in stimulus window
#define	stimWindowSizePix		250		// Height and width of stim window on main display

#define kTargetBlue				0.0
#define kTargetGreen			1.0
#define kMidGray				0.5
#define kPI						(atan(1) * 4)
#define kTargetRed				1.0
#define kDegPerRad				57.295779513

#define kAdjusted(color, contrast)  (kMidGray + (color - kMidGray) / 100.0 * contrast)

NSString *stimulusMonitorID = @"GaborRFMap Stimulus";

@implementation GRFStimuli

- (void) dealloc;
{
	[[task monitorController] removeMonitorWithID:stimulusMonitorID];
	[taskStimList release];
	[mapStimList0 release];
	[mapStimList1 release];
	[fixSpot release];
    [targetSpot release];
    [gabors release];
    [plaid release];
    [imageStim release];
    [player release];
    [mapStimImage release];
    //[bmpRep0 release]; //[Vinay] - it seems that this (bmpRep0) can't be owned even if it is allocated and initialized explicitly using -
    // bmpRep0 = [[NSBitmapImageRep alloc] initWithData:nil]; in -init
    // Therefore, we cannot release it ourselves
    // Probably it gets properly allocated and initialized only with a valid bitmap data as done in GRFImageStim.m for bmpRep

    [super dealloc];
}

- (void)doFixSettings;
{
	[fixSpot runSettingsDialog];
}

- (void)doGabor0Settings;
{
	[[self taskGabor] runSettingsDialog];
}

- (void)dumpStimList;
{
	StimDesc stimDesc;
	long index;
	
	NSLog(@"\ncIndex stim0Type stim1Type stimOnFrame stimOffFrame SF");
	for (index = 0; index < [taskStimList count]; index++) {
		[[taskStimList objectAtIndex:index] getValue:&stimDesc];
		NSLog(@"%4ld:\t%d\t %ld %ld %.2f", index, stimDesc.stimType, stimDesc.stimOnFrame, stimDesc.stimOffFrame, 
              stimDesc.spatialFreqCPD);
		NSLog(@"stim is %s", (stimDesc.stimType == kValidStim) ? "valid" : 
              ((stimDesc.stimType == kTargetStim) ? "target" : "other"));
	}
	NSLog(@"\n");
}

- (void)erase;
{
	[[task stimWindow] lock];
    glClearColor(kMidGray, kMidGray, kMidGray, 0);
    glClear(GL_COLOR_BUFFER_BIT);
	[[NSOpenGLContext currentContext] flushBuffer];
	[[task stimWindow] unlock];
}

- (id)init;
{
	float frameRateHz = [[task stimWindow] frameRateHz]; 
	
	if (!(self = [super init])) {
		return nil;
	}
	monitor = [[[LLIntervalMonitor alloc] initWithID:stimulusMonitorID 
					description:@"Stimulus frame intervals"] autorelease];
	[[task monitorController] addMonitor:monitor];
	[monitor setTargetIntervalMS:1000.0 / frameRateHz];
	taskStimList = [[NSMutableArray alloc] init];
	mapStimList0 = [[NSMutableArray alloc] init];
	mapStimList1 = [[NSMutableArray alloc] init];
    mapStimImage = [[NSMutableArray alloc] init];
	
// Create and initialize the visual stimuli

	gabors = [[NSArray arrayWithObjects:[self initGabor:YES],
                            [self initGabor:NO], [self initGabor:NO], nil] retain];
	[[gabors objectAtIndex:kMapGabor0] setAchromatic:YES];
	[[gabors objectAtIndex:kMapGabor1] setAchromatic:YES];
	fixSpot = [[LLFixTarget alloc] init];
	[fixSpot bindValuesToKeysWithPrefix:@"GRFFix"];
    targetSpot = [[LLFixTarget alloc] init];
	//[targetSpot bindValuesToKeysWithPrefix:@"GRFFix"];
    
    [self initPlaid:NO];
    [plaid setAchromatic:YES];
    
    imageStim = [[GRFImageStim alloc] init];
    [imageStim setDisplays:[[task stimWindow] displays] displayIndex:[[task stimWindow] displayIndex]];
    
    // Get the location of the sounds directory and init player object when Knot is initiated [MD 25/04/2015]
    player = [[GRFSoundObjects alloc] init];
    [player setDir:[self getResourcesFolder]];

	return self;
}

- (LLGabor *)initGabor:(BOOL)bindTemporalFreq;
{
	static long counter = 0;
	LLGabor *gabor;
	
	gabor = [[LLGabor alloc] init];				// Create a gabor stimulus
	[gabor setDisplays:[[task stimWindow] displays] displayIndex:[[task stimWindow] displayIndex]];
    if (bindTemporalFreq) {
        [gabor removeKeysFromBinding:[NSArray arrayWithObjects:LLGaborDirectionDegKey, 
                    LLGaborTemporalPhaseDegKey, LLGaborContrastKey, LLGaborSpatialPhaseDegKey, nil]];
    }
    else {
        [gabor removeKeysFromBinding:[NSArray arrayWithObjects:LLGaborDirectionDegKey, LLGaborTemporalPhaseDegKey,
                    LLGaborContrastKey, LLGaborSpatialPhaseDegKey, LLGaborTemporalFreqHzKey, nil]];
    }
	[gabor bindValuesToKeysWithPrefix:[NSString stringWithFormat:@"GRF%ld", counter++]];
	return gabor;
}

- (LLPlaid *)initPlaid:(BOOL)bindTemporalFreq;
{
//    LLPlaid *plaid;
    
    plaid = [[LLPlaid alloc] init];				// Create a plaid stimulus
    [plaid setDisplays:[[task stimWindow] displays] displayIndex:[[task stimWindow] displayIndex]];
    if (bindTemporalFreq) {
        [plaid removeKeysFromBinding:[NSArray arrayWithObjects:LLPlaid0DirectionDegKey, LLPlaid1DirectionDegKey,
                                      LLPlaid0TemporalPhaseDegKey, LLPlaid1TemporalPhaseDegKey, LLPlaid0ContrastKey, LLPlaid1ContrastKey, LLPlaid0SpatialPhaseDegKey, LLPlaid1SpatialPhaseDegKey, nil]];
    }
    else {
        [plaid removeKeysFromBinding:[NSArray arrayWithObjects:LLPlaid0DirectionDegKey, LLPlaid1DirectionDegKey,
                                      LLPlaid0TemporalPhaseDegKey, LLPlaid1TemporalPhaseDegKey, LLPlaid0ContrastKey, LLPlaid1ContrastKey, LLPlaid0SpatialPhaseDegKey, LLPlaid1SpatialPhaseDegKey, LLPlaid0TemporalFreqHzKey, LLPlaid1TemporalFreqHzKey, nil]];
    }
    [plaid bindValuesToKeysWithPrefix:[NSString stringWithFormat:@"GRF"]];
    return plaid;
}

/*

makeStimList()

Make stimulus lists for one trial.  Three lists are made: one for the task gabor, and one each for the
mapping gabors at the two locations.  Each list is constructed as an NSMutableArry of StimDesc or StimDesc
structures.

Task Stim List: The target in the specified targetIndex position (0 based counting). 

Mapping Stim List: The list is constructed so that each stimulus type appears n times before any appears (n+1).
Details of the construction, as well as monitoring how many stimuli and blocks have been completed are handled
by mapStimTable.

*/

- (void)makeStimLists:(TrialDesc *)pTrial;
{
	long targetIndex;
	long stim, nextStimOnFrame, lastStimOffFrame = 0;
	long stimDurFrames, interDurFrames, stimJitterPC, interJitterPC, stimJitterFrames, interJitterFrames;
	long stimDurBase, interDurBase;
	float frameRateHz;
	StimDesc stimDesc;
	LLGabor *taskGabor = [self taskGabor];
    BOOL convertToImage;
    NSString *imageFile;
	
    trial = *pTrial;
	[taskStimList removeAllObjects];
	targetIndex = MIN(pTrial->targetIndex, pTrial->numStim);
	
// Now we make a second pass through the list adding the stimulus times.  We also insert 
// the target stimulus (if this isn't a catch trial) and set the invalid stimuli to kNull
// if this is an instruction trial.

	frameRateHz = [[task stimWindow] frameRateHz];
	stimJitterPC = [[task defaults] integerForKey:GRFStimJitterPCKey];
	interJitterPC = [[task defaults] integerForKey:GRFInterstimJitterPCKey];
	stimDurFrames = ceil([[task defaults] integerForKey:GRFStimDurationMSKey] / 1000.0 * frameRateHz);
	interDurFrames = ceil([[task defaults] integerForKey:GRFInterstimMSKey] / 1000.0 * frameRateHz);
	stimJitterFrames = round(stimDurFrames / 100.0 * stimJitterPC);
	interJitterFrames = round(interDurFrames / 100.0 * interJitterPC);
	stimDurBase = stimDurFrames - stimJitterFrames;
	interDurBase = interDurFrames - interJitterFrames;
/*
    // randomize
    if ([[task defaults] boolForKey:GRFRandTaskGaborDirectionKey]) {
        [taskGabor setDirectionDeg:rand() % 180];
    }
*/
	pTrial->targetOnTimeMS = 0;
    
 	for (stim = nextStimOnFrame = 0; stim < pTrial->numStim; stim++) {

// Set the default values
	
		stimDesc.gaborIndex = kTaskGabor;
		stimDesc.sequenceIndex = stim;
		stimDesc.stimType = kValidStim;
		stimDesc.contrastPC = 100.0*[taskGabor contrast];
        stimDesc.temporalFreqHz = [taskGabor temporalFreqHz];
		stimDesc.azimuthDeg = [taskGabor azimuthDeg];
		stimDesc.elevationDeg = [taskGabor elevationDeg];
		stimDesc.sigmaDeg = [taskGabor sigmaDeg];
		stimDesc.spatialFreqCPD = [taskGabor spatialFreqCPD];
        stimDesc.directionDeg = [taskGabor directionDeg];
		stimDesc.radiusDeg = [taskGabor radiusDeg];
        stimDesc.temporalModulation = [taskGabor temporalModulation];
	
// If it's not a catch trial and we're in a target spot, set the target 
        
		if (!pTrial->catchTrial) {
			if ((stimDesc.sequenceIndex == targetIndex) ||
                (stimDesc.sequenceIndex > targetIndex && [[task defaults] boolForKey:GRFChangeRemainKey])) {
				stimDesc.stimType = kTargetStim;
				stimDesc.directionDeg += pTrial->orientationChangeDeg;
			}
        }

// Load the information about the on and off frames
	
		stimDesc.stimOnFrame = nextStimOnFrame;
		if (stimJitterFrames > 0) {
			stimDesc.stimOffFrame = stimDesc.stimOnFrame + 
					MAX(1, stimDurBase + (rand() % (2 * stimJitterFrames + 1)));
		}
		else {
			stimDesc.stimOffFrame = stimDesc.stimOnFrame +  MAX(1, stimDurFrames);
		}
		lastStimOffFrame = stimDesc.stimOffFrame;
		if (interJitterFrames > 0) {
			nextStimOnFrame = stimDesc.stimOffFrame + 
				MAX(1, interDurBase + (rand() % (2 * interJitterFrames + 1)));
		}
		else {
			nextStimOnFrame = stimDesc.stimOffFrame + MAX(0, interDurFrames);
		}

// Set to null if HideTaskGaborKey is set
        if ([[task defaults] boolForKey:GRFHideTaskGaborKey])
            stimDesc.stimType = kNullStim;
        
// Put the stimulus descriptor into the list

		[taskStimList addObject:[NSValue valueWithBytes:&stimDesc objCType:@encode(StimDesc)]];

// Save the estimated target on time

		if (stimDesc.stimType == kTargetStim) {
			pTrial->targetOnTimeMS = stimDesc.stimOnFrame / frameRateHz * 1000.0;	// this is a theoretical value
		}
	}
//	[self dumpStimList];
	
// The task stim list is done, now we need to get the mapping stim lists

    [[(GaborRFMap*)task mapStimTable0] makeMapStimList:mapStimList0 index:0 lastFrame:lastStimOffFrame pTrial:pTrial];
	[[(GaborRFMap*)task mapStimTable1] makeMapStimList:mapStimList1 index:1 lastFrame:lastStimOffFrame pTrial:pTrial];
    
// [Vinay] - Prepare the image stimuli
    convertToImage = [[task defaults] boolForKey:GRFConvertToImageKey];
    
    if (convertToImage) {
        for (stim=0; stim < pTrial->numStim; stim++) {
            [[mapStimList0 objectAtIndex:stim] getValue:&stimDesc];
            
            imageFile = [[[self getResourcesFolder] stringByAppendingPathComponent:@"Images"] stringByAppendingPathComponent:[NSString stringWithFormat:@"Image%d%s",(int)(stimDesc.spatialFreqCPD),".jpg"]];
            //imageFile = [[[self getResourcesFolder] stringByAppendingPathComponent:@"Images"] stringByAppendingPathComponent:[NSString stringWithFormat:@"Image%d%s",(int)(stimDesc.spatialFreqCPD),".tif"]];
            NSLog(@"imageFile is : %@",imageFile);
            
            bmpRep0 = [imageStim getImageStimBitmap:imageFile];
            [mapStimImage insertObject:bmpRep0 atIndex:stim];
        }
        
    }

}
	
- (void)loadGabor:(LLGabor *)gabor withStimDesc:(StimDesc *)pSD;
{	
	if (pSD->spatialFreqCPD == 0) {					// Change made by Incheol and Kaushik to get gaussians
		[gabor directSetSpatialPhaseDeg:90.0];
	}
	[gabor directSetSigmaDeg:pSD->sigmaDeg];		// *** Should be directSetSigmaDeg
	[gabor directSetRadiusDeg:pSD->radiusDeg];
	[gabor directSetAzimuthDeg:pSD->azimuthDeg elevationDeg:pSD->elevationDeg];
	[gabor directSetSpatialFreqCPD:pSD->spatialFreqCPD];
	[gabor directSetDirectionDeg:pSD->directionDeg];
	[gabor directSetContrast:pSD->contrastPC / 100.0];
    [gabor directSetTemporalFreqHz:pSD->temporalFreqHz];
    [gabor setTemporalModulation:pSD->temporalModulation];
    
    if (pSD->temporalFreqHz == [[task stimWindow] frameRateHz]/2) {
        [gabor directSetTemporalPhaseDeg:90.0];
    }
    else {
        [gabor directSetTemporalPhaseDeg:0.0];
    }
}

- (void)loadImage:(StimDesc *)pSD;
{
    NSString *imageFile;
    ImageParams imageDesc;
    
    imageDesc = [self generateImageDescWithGabor:pSD];
    imageFile = [[[self getResourcesFolder] stringByAppendingPathComponent:@"Images"] stringByAppendingPathComponent:[NSString stringWithFormat:@"Image%d%s",(int)(pSD->spatialFreqCPD),".jpg"]];
    //imageFile = [[[self getResourcesFolder] stringByAppendingPathComponent:@"Images"] stringByAppendingPathComponent:[NSString stringWithFormat:@"Image%d%s",(int)(pSD->spatialFreqCPD),".tif"]];
    NSLog(@"imageFile is : %@",imageFile);
    [imageStim setImageStimData:imageDesc];
    [imageStim setImageStim:imageFile];
}

- (void)loadImageFromBitmap:(StimDesc *)pSD bitmapFile:(NSBitmapImageRep *)bmp;
{
    ImageParams imageDesc;
    imageDesc = [self generateImageDescWithGabor:pSD];
    [imageStim setImageStimData:imageDesc];
    [imageStim setImageStimFromBitmap:bmp];
}

- (void)loadPlaid:(LLPlaid *)pld withStimDesc0:(StimDesc *)pSD0 withStimDesc1:(StimDesc *)pSD1;
{
    
    [pld directSetSigmaDeg:pSD0->sigmaDeg];
    [pld directSetRadiusDeg:pSD0->radiusDeg];
    [pld directSetAzimuthDeg:pSD0->azimuthDeg elevationDeg:pSD0->elevationDeg];
    
    if (pSD0->spatialFreqCPD == 0) {
        [pld directSetSpatialPhaseDeg0:90.0];
    }
    [pld directSetSpatialFreqCPD0:pSD0->spatialFreqCPD];
    [pld setDirectionDeg0:pSD0->directionDeg];
    [pld directSetContrast0:pSD0->contrastPC / 100.0];
    [pld directSetTemporalFreqHz0:pSD0->temporalFreqHz];
    [pld directSetTemporalModulation0:pSD0->temporalModulation];
    
    if (pSD0->temporalFreqHz == [[task stimWindow] frameRateHz]/2) {
        [pld directSetTemporalPhaseDeg0:90.0];
    }
    else {
        [pld directSetTemporalPhaseDeg0:0.0];
    }
    
    if (pSD1->spatialFreqCPD == 0) {
        [pld directSetSpatialPhaseDeg1:90.0];
    }
    [pld directSetSpatialFreqCPD1:pSD1->spatialFreqCPD];
    [pld setDirectionDeg1:pSD1->directionDeg];
    [pld directSetContrast1:pSD1->contrastPC / 100.0];
    [pld directSetTemporalFreqHz1:pSD1->temporalFreqHz];
    [pld directSetTemporalModulation1:pSD1->temporalModulation];
    
    if (pSD1->temporalFreqHz == [[task stimWindow] frameRateHz]/2) {
        [pld directSetTemporalPhaseDeg1:90.0];
    }
    else {
        [pld directSetTemporalPhaseDeg1:0.0];
    }
}


- (void)clearStimLists:(TrialDesc *)pTrial
{
	// tally stim lists first?
	[mapStimList0 removeAllObjects];
	[mapStimList1 removeAllObjects];
    [mapStimImage removeAllObjects];
}

- (LLGabor *)mappingGabor0;
{
	return [gabors objectAtIndex:kMapGabor0];
}

- (LLGabor *)mappingGabor1;
{
	return [gabors objectAtIndex:kMapGabor1];
}

- (LLIntervalMonitor *)monitor;
{
	return monitor;
}

- (void)presentStimSequence;
{
    long index, trialFrame, taskGaborFrame;
	NSArray *stimLists;
	StimDesc stimDescs[kGabors], *pSD;
    AudStimDesc audStim;
	long stimIndices[kGabors];
	long stimOffFrames[kGabors];
	long gaborFrames[kGabors];
	LLGabor *theGabor;
	NSAutoreleasePool *threadPool;
	BOOL listDone = NO;
//	long stimCounter = 0;
    BOOL useSingleITC18;
    BOOL convertToPlaid;
    BOOL convertToImage;
    // local variables related to auditory stimulus [MD 25/04/2015]
    BOOL playAudStim;
    int kMapGaborAV;
    //NSColor *fixSpotColor;
    
	
    threadPool = [[NSAutoreleasePool alloc] init];		// create a threadPool for this thread
	[LLSystemUtil setThreadPriorityPeriodMS:1.0 computationFraction:0.250 constraintFraction:1.0];
	
	stimLists = [[NSArray arrayWithObjects:taskStimList, mapStimList0, mapStimList1, nil] retain];

// Set up the stimulus calibration, including the offset then present the stimulus sequence

	[[task stimWindow] lock];
	[[task stimWindow] setScaleOffsetDeg:[[task eyeCalibrator] offsetDeg]];
	[[task stimWindow] scaleDisplay];

// Set up the gabors
    
	for (index = 0; index < kGabors; index++) {
		stimIndices[index] = 0;
		gaborFrames[index] = 0;
		[[[stimLists objectAtIndex:index] objectAtIndex:0] getValue:&stimDescs[index]];
		[self loadGabor:[gabors objectAtIndex:index] withStimDesc:&stimDescs[index]];
		stimOffFrames[index] = stimDescs[index].stimOffFrame;
	}
    
    [gabors makeObjectsPerformSelector:@selector(store)];

// Set up the plaid if necessary
// Instead of showing two gabors, we can "merge" them together and draw a plaid. In that situation, the azimuth, elevation, sigma and radius of MappingGabor0 are used. We simply set the stimTypes of kMapGabor0 and kMapGabor1 to Null so that they are not displayed, and set up the plaid instead. Plaid uses stimOn, stimOff and Frame number (see below) of MappingGabor0.
    
    convertToPlaid = [[task defaults] boolForKey:GRFConvertToPlaidKey];

    if (convertToPlaid) {
        [self loadPlaid:plaid withStimDesc0:&stimDescs[kMapGabor0] withStimDesc1:&stimDescs[kMapGabor1]];
        stimDescs[kMapGabor0].stimType=kPlaidStim;
        stimDescs[kMapGabor1].stimType=kPlaidStim;
    }
    
    [plaid store];

// Set up the images if necessary.
// Instead of showing gabors or plaids, we can show a set of images instead.
    
    convertToImage = [[task defaults] boolForKey:GRFConvertToImageKey];
    
    if (convertToImage) {
        //[self loadImage:&stimDescs[kMapGabor0]];
        [self loadImageFromBitmap:&stimDescs[kMapGabor0] bitmapFile:[mapStimImage objectAtIndex:0]];
        //[imageStim fillImageInTexture];
        stimDescs[kMapGabor0].stimType=kImageStim;
    }
    
    // Set up the targetSpot if needed
/*
    if ([[task defaults] boolForKey:GRFAlphaTargetDetectionTaskKey]) {
        [targetSpot setState:YES];
        NSColor *targetColor = [[fixSpot foreColor]retain];
        [targetSpot setForeColor:[targetColor colorWithAlphaComponent:[[task defaults] floatForKey:GRFTargetAlphaKey]]];
        [targetSpot setOuterRadiusDeg:[[task defaults]floatForKey:GRFTargetRadiusKey]];
        [targetSpot setShape:kLLCircle];
        [targetColor release];
    }
*/
    
// Set up the auditory stimulus if necessary [MD 25/04/2015]
    playAudStim = [[task defaults] boolForKey:GRFPlayAudStimKey];
    
    if (playAudStim) {
        
        // Auditory gabor. This is presently mapped to the properties of the right gabor.
        kMapGaborAV = kMapGabor1;
        
        // update player with the required sound stimulus
        audStim = [self updateAuditoryGaborWithGabor:&stimDescs[kMapGaborAV]];
        [player getSoundForGabor:audStim];
        
        // Changes in stimDescs that would indicate presence of auditory stimulus in LL data
        stimDescs[kMapGaborAV].stimType = audStim.stimType;
    }
    
	targetOnFrame = -1;

    for (trialFrame = taskGaborFrame = 0; !listDone && !abortStimuli; trialFrame++) {
		glClear(GL_COLOR_BUFFER_BIT);
		for (index = 0; index < kGabors; index++) {
			if (trialFrame >= stimDescs[index].stimOnFrame && trialFrame < stimDescs[index].stimOffFrame) {
                
                // Visual Stimuli
				if (stimDescs[index].stimType != kNullStim && stimDescs[index].stimType != kPlaidStim && stimDescs[index].stimType !=kAudStim && stimDescs[index].stimType !=kImageStim) {
                    theGabor = [gabors objectAtIndex:index];
                    [theGabor directSetFrame:[NSNumber numberWithLong:gaborFrames[index]]];	// advance for temporal modulation
                    [theGabor draw];
/*
                    if (!trial.catchTrial && index == kTaskGabor && stimDescs[index].stimType == kTargetStim) {
                        [targetSpot setAzimuthDeg:stimDescs[index].azimuthDeg elevationDeg:stimDescs[index].elevationDeg];
                        [targetSpot draw];
                    }
*/
                }
                
                if (convertToPlaid && !convertToImage && index == kMapGabor0) {
                    [plaid directSetFrame:[NSNumber numberWithLong:gaborFrames[index]]];	// advance for temporal modulation
                    [plaid draw];
                }
                
                if (convertToImage && index == kMapGabor0) {
                    [imageStim drawImage];
                }
                
                // Auditory Stimulus. This is played only if Auditory Stimulus check-box is checked. [MD 25/04/2015]

                if (playAudStim && index == kMapGaborAV && gaborFrames[index] == 0) {
                    [player startPlay]; // start playback
                    [digitalOut outputEventName:@"auditoryStimulus" withData:(long)(audStim.stimType)];
                }
                
                // Increment gaborFrames here
                gaborFrames[index]++;
			}

		}

		//fixSpotColor = [fixSpot fixTargetColor];
        //[fixSpot setFixTargetColor:fixSpotColor];
        [fixSpot draw];
		[[NSOpenGLContext currentContext] flushBuffer];
		glFinish();
		if (trialFrame == 0) {
			[monitor reset];
		}
		else {
			[monitor recordEvent];
		}

// Update Gabors as needed

		for (index = 0; index < kGabors; index++) {
			pSD = &stimDescs[index];

 // If this is the frame after the last draw of a stimulus, post an event declaring it off.  We have to do this first,
 // because the off of one stimulus may occur on the same frame as the on of the next

            useSingleITC18 = [[task defaults] boolForKey:GRFUseSingleITC18Key];
            
			if (trialFrame == stimOffFrames[index]) {
                [[task dataDoc] putEvent:@"stimulusOff" withData:&index];
                [[task dataDoc] putEvent:@"stimulusOffTime"];
                if (!useSingleITC18) {
                    [digitalOut outputEvent:kStimulusOffDigitOutCode withData:index];
                }
				if (++stimIndices[index] >= [[stimLists objectAtIndex:index] count]) {	// no more entries in list
					listDone = YES;
				}
			}
			
// If this is the first frame of a Gabor, post an event describing it

			if (trialFrame == pSD->stimOnFrame) {
				[[task dataDoc] putEvent:@"stimulusOn" withData:&index];
                [[task dataDoc] putEvent:@"stimulusOnTime"];
                [[task dataDoc] putEvent:@"stimulus" withData:pSD];

                if (!useSingleITC18) {
                    [digitalOut outputEvent:kStimulusOnDigitOutCode withData:index];
                }
				// put the digital events
				if (index == kTaskGabor) {
					[digitalOut outputEventName:@"taskGabor" withData:(long)(pSD->stimType)];
				}
				else {
					if (pSD->stimType != kNullStim) {
						if (index == kMapGabor0)
							[digitalOut outputEventName:@"mapping0" withData:(long)(pSD->stimType)];
						if (index == kMapGabor1)
							[digitalOut outputEventName:@"mapping1" withData:(long)(pSD->stimType)];
					}
				}
                
                if (convertToPlaid && !convertToImage && index == kMapGabor0) {
                    [digitalOut outputEventName:@"mappingPlaid" withData:(long)(pSD->stimType)];
                }
                
                if (convertToImage && index == kMapGabor0) {
                    [digitalOut outputEventName:@"imageStimulus" withData:(long)(stimDescs[kMapGabor0].temporalFreqHz)];
                }
				
				// Other prperties of the Gabor
				if (index == kMapGabor0 && pSD->stimType != kNullStim && !([[task defaults] boolForKey:GRFHideLeftDigitalKey])) {
					//NSLog(@"Sending left digital codes...");
					[digitalOut outputEventName:@"contrast" withData:(long)(10*(pSD->contrastPC))];
                    [digitalOut outputEventName:@"temporalFreq" withData:(long)(10*(pSD->temporalFreqHz))];
					[digitalOut outputEventName:@"azimuth" withData:(long)(100*(pSD->azimuthDeg))];
					[digitalOut outputEventName:@"elevation" withData:(long)(100*(pSD->elevationDeg))];
					[digitalOut outputEventName:@"orientation" withData:(long)((pSD->directionDeg))];
					[digitalOut outputEventName:@"spatialFreq" withData:(long)(100*(pSD->spatialFreqCPD))];
					[digitalOut outputEventName:@"radius" withData:(long)(100*(pSD->radiusDeg))];
					[digitalOut outputEventName:@"sigma" withData:(long)(100*(pSD->sigmaDeg))];
				}
				
				if (index == kMapGabor1 && pSD->stimType != kNullStim && !([[task defaults] boolForKey:GRFHideRightDigitalKey])) {
					//NSLog(@"Sending right digital codes...");
					[digitalOut outputEventName:@"contrast" withData:(long)(10*(pSD->contrastPC))];
                    [digitalOut outputEventName:@"temporalFreq" withData:(long)(10*(pSD->temporalFreqHz))];
					[digitalOut outputEventName:@"azimuth" withData:(long)(100*(pSD->azimuthDeg))];
					[digitalOut outputEventName:@"elevation" withData:(long)(100*(pSD->elevationDeg))];
					[digitalOut outputEventName:@"orientation" withData:(long)((pSD->directionDeg))];
					[digitalOut outputEventName:@"spatialFreq" withData:(long)(100*(pSD->spatialFreqCPD))];
					[digitalOut outputEventName:@"radius" withData:(long)(100*(pSD->radiusDeg))];
					[digitalOut outputEventName:@"sigma" withData:(long)(100*(pSD->sigmaDeg))];
				}
                
                if (pSD->stimType == kTargetStim) {
					targetPresented = YES;
					targetOnFrame = trialFrame;
                    if (!useSingleITC18) {
                        [digitalOut outputEvent:kTargetOnDigitOutCode withData:(kTargetOnDigitOutCode+1)];
                    }
				}
				stimOffFrames[index] = stimDescs[index].stimOffFrame;		// previous done by now, save time for this one
			}

// If we've drawn the current stimulus for the last time, load the Gabor with the next stimulus settings

			if (trialFrame == stimOffFrames[index] - 1) {
				if ((stimIndices[index] + 1) < [[stimLists objectAtIndex:index] count]) {	// check there are more
					[[[stimLists objectAtIndex:index] objectAtIndex:(stimIndices[index] + 1)] getValue:&stimDescs[index]];
                    [self loadGabor:[gabors objectAtIndex:index] withStimDesc:&stimDescs[index]];
					gaborFrames[index] = 0;
                    
                    if (convertToPlaid) {
                        [self loadPlaid:plaid withStimDesc0:&stimDescs[kMapGabor0] withStimDesc1:&stimDescs[kMapGabor1]];
                        stimDescs[kMapGabor0].stimType=kPlaidStim;
                        stimDescs[kMapGabor1].stimType=kPlaidStim;
                    }
                    
                    if (convertToImage && index == kMapGabor0) {
                        //[self loadImage:&stimDescs[kMapGabor0]];
                        //[self loadImageFromBitmap:&stimDescs[kMapGabor0] bitmapFile:[mapStimImage objectAtIndex:(stimIndices[index]+1)]]; // [Vinay] - do not load it as yet. Load it on the frame before the next stimulus is drawn. This way the fixation spot retains its colour.
                        stimDescs[kMapGabor0].stimType=kImageStim;
                    }
                    
                    if (playAudStim && index == kMapGaborAV) {
                        
                        // update player with the required sound stimulus
                        audStim = [self updateAuditoryGaborWithGabor:&stimDescs[kMapGaborAV]];
                        [player getSoundForGabor:audStim];
                        
                        // Changes in stimDescs that would indicate presence of auditory stimulus in LL data
                        stimDescs[kMapGaborAV].stimType = audStim.stimType;
                    }
				}
             
                // Every time fresh gabors are selected, we need to store them because otherwise counterphasing option would keep using the baseGabor of the first gabor.
                [gabors makeObjectsPerformSelector:@selector(store)];
                [plaid store];
			}
            
            // [Vinay] - Load the next image on the frame previous to its stimOnFrame
            if (((stimIndices[index]) < [[stimLists objectAtIndex:index] count]) && (index == kMapGabor0) && (trialFrame == stimDescs[kMapGabor0].stimOnFrame - 1) && convertToImage) {
                            [self loadImageFromBitmap:&stimDescs[kMapGabor0] bitmapFile:[mapStimImage objectAtIndex:(stimIndices[index])]]; // [Vinay] - stimIndices[index] is already incremented on the stimOffFrame of the previous stimulus
                //[imageStim fillImageInTexture];
            }
		}
    }
	
// If there was no target (catch trial), we nevertheless need to set a valid targetOnFrame time (now)

	targetOnFrame = (targetOnFrame < 0) ? trialFrame : targetOnFrame;

// Clear the display and leave the back buffer cleared

    glClear(GL_COLOR_BUFFER_BIT);
    [[NSOpenGLContext currentContext] flushBuffer];
	glFinish();

	[[task stimWindow] unlock];
	
// The temporal counterphase might have changed some settings.  We restore these here.
// No need to restore, because Gabors are loaded and stored fresh in each trial.
    
//	[gabors makeObjectsPerformSelector:@selector(restore)];
//  [plaid restore];
    
    [imageStim erase];
// Pass a message to player to stop playing. If sound has not been terminated when this line is reached during runtime (eg. when abortStimuli becomes true) and playback has to be aborted prematurely, player will abort playing using its own routines implemented in GRFSoundObjects.m . [MD 06/04/2015]
    if (playAudStim) {
        [player stopPlay];
    }
    
	stimulusOn = abortStimuli = NO;
	[stimLists release];
    [threadPool release];
    [mapStimImage removeAllObjects]; // [Vinay] - The objects need to be removed here, otherwise they keep adding up across trials
}

- (void)setFixSpot:(BOOL)state;
{
	[fixSpot setState:state];
	if (state) {
		if (!stimulusOn) {
			[[task stimWindow] lock];
			[[task stimWindow] setScaleOffsetDeg:[[task eyeCalibrator] offsetDeg]];
			[[task stimWindow] scaleDisplay];
			glClear(GL_COLOR_BUFFER_BIT);
			[fixSpot draw];
			[[NSOpenGLContext currentContext] flushBuffer];
			[[task stimWindow] unlock];
		}
	}
}

// Shuffle the stimulus sequence by repeated passed along the list and paired substitution

- (void)shuffleStimListFrom:(short)start count:(short)count;
{
	long rep, reps, stim, index, temp, indices[kMaxOriChanges];
	NSArray *block;
	
	reps = 5;	
	for (stim = 0; stim < count; stim++) {			// load the array of indices
		indices[stim] = stim;
	}
	for (rep = 0; rep < reps; rep++) {				// shuffle the array of indices
		for (stim = 0; stim < count; stim++) {
			index = rand() % count;
			temp = indices[index];
			indices[index] = indices[stim];
			indices[stim] = temp;
		}
	}
	block = [taskStimList subarrayWithRange:NSMakeRange(start, count)];
	for (index = 0; index < count; index++) {
		[taskStimList replaceObjectAtIndex:(start + index) withObject:[block objectAtIndex:indices[index]]];
	}
}

- (void)startStimSequence;
{
	if (stimulusOn) {
		return;
	}
	stimulusOn = YES;
	targetPresented = NO;
	[NSThread detachNewThreadSelector:@selector(presentStimSequence) toTarget:self
				withObject:nil];
}

- (BOOL)stimulusOn;
{
	return stimulusOn;
}

// Stop on-going stimulation and clear the display

- (void)stopAllStimuli;
{
	if (stimulusOn) {
		abortStimuli = YES;
		while (stimulusOn) {};
	}
	else {
		[stimuli setFixSpot:NO];
		[self erase];
	}
}

- (void)tallyStimLists:(long)count
{
	[[(GaborRFMap *)task mapStimTable0] tallyStimList:mapStimList0 count:count];
	[[(GaborRFMap *)task mapStimTable1] tallyStimList:mapStimList1 count:count];
}

- (long)targetOnFrame;
{
	return targetOnFrame;
}

- (BOOL)targetPresented;
{
	return targetPresented;
}

- (LLGabor *)taskGabor;
{
	return [gabors objectAtIndex:kTaskGabor];
}

// Function renamed to getResourcesFolder from getSoundFolder
-(NSString*)getResourcesFolder // [MD 25/04/2015]
{
    NSString *soundFolderPath = [[NSString alloc] initWithString:@""]; // Declare output variable, init with an empty string
    NSString *searchFilename = @"getAuditoryStimuli.m"; // This is the MATLAB file whose parent directory (one directory above) also contains all the sound stimuli in another sub-directory called Sounds. In our case, it is the Resources folder
    
    // Search for the specific path. It is assumed that this folder is in the specific user's Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory];
    NSString *documentsSubpath;
    while (documentsSubpath = [direnum nextObject])
    {
        if ([documentsSubpath.lastPathComponent isEqual:searchFilename]) {
            
            // Initialise sound folder path as a string with the contents of parent directory of getAuditoryStimuli.m file
            soundFolderPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[[documentsSubpath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]]];
        }
    }
    
    // If the MATLAB file is not found (and hence the Sounds directory could not be located), log a message
    if ([soundFolderPath isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:[@"Sounds directory could not be located as the search file " stringByAppendingString:[searchFilename stringByAppendingString:@" could not be found in the user's Documents directory."]]];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            [alert release];
        }
    }
    
    // Return the parent directory path
    return soundFolderPath;
};

-(AudStimDesc)updateAuditoryGaborWithGabor:(StimDesc *)pSD
{
    AudStimDesc AudStim;
    
    AudStim.stimDurationMS = [[task defaults] integerForKey:GRFMapStimDurationMSKey];
    AudStim.protocolType = (int)(pSD->radiusDeg/[[task defaults] floatForKey:GRFMapStimRadiusSigmaRatioKey]);
    AudStim.azimuthDeg = pSD->azimuthDeg;
    AudStim.elevationDeg = pSD->elevationDeg;
    AudStim.spatialFreqCPD = pSD->spatialFreqCPD;
    AudStim.directionDeg = pSD->directionDeg;
    AudStim.contrastPC = pSD->contrastPC;
    AudStim.temporalFreqHz = pSD->temporalFreqHz;
    
    if (pSD->stimType == kNullStim) {
        AudStim.stimType = kAudStim; // Only Auditory stimulus for this gabor
    }
    else if (pSD->stimType == kValidStim || pSD->stimType == kPlaidStim) {
        AudStim.stimType = kVisAudStim; // Both Auditory and visual stimuli mapped to this gabor
    }
    
    return AudStim;
}

-(ImageParams)generateImageDescWithGabor:(StimDesc *)pSD
{
    ImageParams params;

    params.azimuthDeg = pSD->azimuthDeg;
    params.elevationDeg = pSD->elevationDeg;
    params.sizeDeg = pSD->radiusDeg;
    params.directionDeg = pSD->directionDeg;
    
    return params;
}
@end
