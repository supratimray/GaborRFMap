//
//  GRFFixateState.m
//  GaborRFMap
//
//  GRFPreCueState.m
//	Created by John Maunsell on 2/25/06.
//	modified from GRFPreCueState.m by Incheol Kang on 12/8/06
//
//  Copyright 2006. All rights reserved.
//

#import "GRFFixateState.h"
#import "GRFUtilities.h"
#import "GRFDigitalOut.h"

@implementation GRFFixateState

- (void)stateAction {
	long fixDurBase, fixJitterMS;
	long fixateMS = [[task defaults] integerForKey:GRFFixateMSKey];
	long fixJitterPC = [[task defaults] integerForKey:GRFFixJitterPCKey];
		
	if ([[task defaults] boolForKey:GRFFixateKey]) {				// fixation required && fixated
//        [digitalOut outputEvent:kFixateDigitOutCode withData:(kFixateDigitOutCode+1)]; // Thomas 2014 Feb 25
        [digitalOut outputEventName:@"fixate" withData:(long)(fixateMS)];
		[[task dataDoc] putEvent:@"fixate"];
		[scheduler schedule:@selector(updateCalibration) toTarget:self withObject:nil
				delayMS:fixateMS * 0.8];
		if ([[task defaults] boolForKey:GRFDoSoundsKey]) {
			[[NSSound soundNamed:kFixateSound] play];
		}
	}
	
	if (fixJitterPC > 0){
		fixJitterMS = round((fixateMS * fixJitterPC) / 100.0);
		fixDurBase = fixateMS - fixJitterMS;
		fixateMS = fixDurBase + (rand() % (2 * fixJitterMS + 1));
	}
	
	expireTime = [LLSystemUtil timeFromNow:fixateMS];
}

- (NSString *)name {

    return @"GRFFixate";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kMyEOTQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];;
	}
	if ([[task defaults] boolForKey:GRFFixateKey] && ![GRFUtilities inWindow:fixWindow]) {
		eotCode = kMyEOTBroke;
		return [[task stateSystem] stateNamed:@"Endtrial"];;
	}
	if ([LLSystemUtil timeIsPast:expireTime]) {
		return [[task stateSystem] stateNamed:@"GRFStimulate"];
	}
	return nil;
}

- (void)updateCalibration;
{
	if ([GRFUtilities inWindow:fixWindow]) {
		[[task eyeCalibrator] updateCalibration:([task currentEyesDeg])[kRightEye]];
	}
}


@end
