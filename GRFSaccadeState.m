//
//  GRFSaccadeState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "GRFSaccadeState.h"
#import "GRFUtilities.h"
#import "GRFDigitalOut.h"

@implementation GRFSaccadeState

- (void)stateAction {

    bool useFewDigitalCodes;
    
    useFewDigitalCodes = [[task defaults] boolForKey:GRFUseFewDigitalCodesKey];
    
	[[task dataDoc] putEvent:@"saccade"];
    if (useFewDigitalCodes)
        [digitalOut outputEvent:kSaccadeDigitOutCode sleepInMicrosec:kSleepInMicrosec];
    else
        [digitalOut outputEventName:@"saccade" withData:0.0];
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:GRFSaccadeTimeMSKey]];
}

- (NSString *)name {

    return @"GRFSaccade";
}

- (LLState *)nextState;
{
	if ([task mode] == kTaskIdle) {
		eotCode = kMyEOTQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];;
	}
	if (eotCode == kMyEOTBroke) {				// got here by leaving fixWindow early (from stimulate)
		if ([GRFUtilities inWindow:respWindow])  {
			eotCode = kMyEOTEarlyToValid;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
		if ([LLSystemUtil timeIsPast:expireTime]) {
			eotCode = kMyEOTBroke;
			brokeDuringStim = YES;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
	}
	else {
		if ([GRFUtilities inWindow:respWindow])  {
			eotCode = kMyEOTCorrect;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
		if ([LLSystemUtil timeIsPast:expireTime]) {
			eotCode = kMyEOTMissed;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
	}
    return nil;
}

@end
