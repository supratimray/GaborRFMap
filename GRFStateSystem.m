//
//  GRFStateSystem.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "GRFStateSystem.h"
#import "UtilityFunctions.h"
#import "GaborRFMap.h"

#import "GRFBlockedState.h"
#import "GRFEndtrialState.h"
#import "GRFFixGraceState.h"
#import "GRFFixonState.h"
#import "GRFIdleState.h"
#import "GRFIntertrialState.h"
#import "GRFFixateState.h"
#import "GRFReactState.h"
#import "GRFSaccadeState.h"
#import "GRFStarttrialState.h"
#import "GRFStimulate.h"
#import "GRFStopState.h"
#import "GRFTooFastState.h"

long 				eotCode;			// End Of Trial code
BOOL 				fixated;
LLEyeWindow			*fixWindow;
LLEyeWindow			*respWindow;
GRFStateSystem		*stateSystem;
TrialDesc			trial;

@implementation GRFStateSystem

- (void)dealloc {

    [fixWindow release];
	[respWindow release];
    [super dealloc];
}

- (id)init;
{
    if ((self = [super init]) != nil) {

// create & initialize the state system's states

		[self addState:[[[GRFBlockedState alloc] init] autorelease]];
		[self addState:[[[GRFEndtrialState alloc] init] autorelease]];
		[self addState:[[[GRFFixonState alloc] init] autorelease]];
		[self addState:[[[GRFFixGraceState alloc] init] autorelease]];
		[self addState:[[[GRFIdleState alloc] init] autorelease]];
		[self addState:[[[GRFIntertrialState alloc] init] autorelease]];
		[self addState:[[[GRFStimulate alloc] init] autorelease]];
		[self addState:[[[GRFFixateState alloc] init] autorelease]];
		[self addState:[[[GRFTooFastState alloc] init] autorelease]];
		[self addState:[[[GRFReactState alloc] init] autorelease]];
		[self addState:[[[GRFSaccadeState alloc] init] autorelease]];
		[self addState:[[[GRFStarttrialState alloc] init] autorelease]];
		[self addState:[[[GRFStopState alloc] init] autorelease]];
		[self setStartState:[self stateNamed:@"GRFIdle"] andStopState:[self stateNamed:@"GRFStop"]];

		[controller setLogging:YES];
	
		fixWindow = [[LLEyeWindow alloc] init];
		[fixWindow setWidthAndHeightDeg:[[task defaults] floatForKey:GRFFixWindowWidthDegKey]];
			
		respWindow = [[LLEyeWindow alloc] init];
		[respWindow setWidthAndHeightDeg:[[task defaults] floatForKey:GRFRespWindowWidthDegKey]];
    }
    return self;
}

- (BOOL) running {

    return [controller running];
}

- (BOOL) startWithCheckIntervalMS:(double)checkMS {			// start the system running

    return [controller startWithCheckIntervalMS:checkMS];
}

- (void) stop {										// stop the system

    [controller stop];
}

// Methods related to data events follow:

// Make a block status object that contains the number of blocks to do and how many 
// trials of each type have been done (initialized to zero).

- (void) reset:(NSData *)eventData eventTime:(NSNumber *)eventTime;
{
	long index;
	
	updateBlockStatus();
	blockStatus.blocksDone = blockStatus.sidesDone = blockStatus.instructDone = 0;
	for (index = 0; index < blockStatus.changes; index++) {
		blockStatus.validRepsDone[index] = blockStatus.invalidRepsDone[index] = 0;
	}
	[[(GaborRFMap *)task mapStimTable0] reset];
	[[(GaborRFMap *)task mapStimTable1] reset];
	mappingBlockStatus = [[(GaborRFMap *)task mapStimTable0] mappingBlockStatus];
    trialCounter = 0;
}

#define kMaxRate        100.0
#define kSpontRate      1.0

// Adjust based only on stim 0

- (void)stimulus:(NSData *)eventData eventTime:(NSNumber *)eventTime;
{
	float firingRateHz;
	StimDesc *pSD = (StimDesc *)[eventData bytes];
	
    if (pSD->gaborIndex != kMapGabor1) {
        return;                                                     // do nothing with the task stimuli
    }
	firingRateHz = kMaxRate;
	firingRateHz *= (fabs(pSD->directionDeg - 90.0) < 45.0) ? 1.0 : 0.5;
	firingRateHz *= (fabs(fabs(pSD->azimuthDeg) - 5.0) < 2.5) ? 1.0 : 0.5;
	firingRateHz *= (fabs(fabs(pSD->elevationDeg) - 5.0) < 2.5) ? 1.0 : 0.5;
	firingRateHz *= (fabs(pSD->spatialFreqCPD - 1.0) < 0.5) ? 1.0 : 0.5;
	firingRateHz *= (fabs(pSD->sigmaDeg - 0.5) < 0.25) ? 1.0 : 0.5;
    [[task synthDataDevice] setSpikeRateHz:firingRateHz atTime:[LLSystemUtil getTimeS]];
}

- (void) stimulusOff:(NSData *)eventData eventTime:(NSNumber *)eventTime;
{
    [[task synthDataDevice] setSpikeRateHz:kSpontRate atTime:[LLSystemUtil getTimeS]];
}

- (void) tries:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	long tries;
	
	[eventData getBytes:&tries length:sizeof(long)];
}

@end
