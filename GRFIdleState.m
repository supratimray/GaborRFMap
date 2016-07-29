//
//  GRFIdleState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "GRFIdleState.h"

@implementation GRFIdleState

- (void)stateAction;
{
    [[task dataController] setDataEnabled:[NSNumber numberWithBool:NO]];
    [[task dataController] stopDevice];
	blockStatus.instructDone = 0;					// do new instructions trials on restart
}

- (NSString *)name {

    return @"GRFIdle";
}

- (LLState *)nextState {

	if ([task mode] == kTaskEnding) {
		return [[task stateSystem] stateNamed:@"GRFStop"];
    }
	if ([task mode] != kTaskIdle) {
		return [[task stateSystem] stateNamed:@"GRFIntertrial"];
    }
	else {
        return nil;
    }
}

@end
