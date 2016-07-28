//
//  GRFFixonState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "GRFFixonState.h"
#import "GRFUtilities.h"
#import "GRFDigitalOut.h"

@implementation GRFFixonState

- (void)stateAction {

    bool useFewDigitalCodes;
    
    useFewDigitalCodes = [[task defaults] boolForKey:GRFUseFewDigitalCodesKey];
    
    [stimuli setFixSpot:YES];
	[[task dataDoc] putEvent:@"fixOn"];
    if (!useFewDigitalCodes)
        [digitalOut outputEventName:@"fixOn" withData:0x0000];
    [[task synthDataDevice] setEyeTargetOn:NSMakePoint(0, 0)];
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:GRFAcquireMSKey]];
	if ([[task defaults] boolForKey:GRFDoSoundsKey]) {
		[[NSSound soundNamed:kFixOnSound] play];
	}
}

- (NSString *)name {

    return @"GRFFixon";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kMyEOTQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];;
	}
	if (![[task defaults] boolForKey:GRFFixateKey]) { 
		return [[task stateSystem] stateNamed:@"GRFFixate"];
    }
	else if ([GRFUtilities inWindow:fixWindow])  {
		return [[task stateSystem] stateNamed:@"GRFFixGrace"];
    }
	if ([LLSystemUtil timeIsPast:expireTime]) {
		eotCode = kMyEOTIgnored;
		return [[task stateSystem] stateNamed:@"Endtrial"];;
	}
	else {
		return nil;
    }
}

@end
