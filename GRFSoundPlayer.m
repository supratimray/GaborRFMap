//
//  GRFSoundPlayer.m
//  GaborRFMap
//
//  Created by Murty V P S Dinavahi on 03/05/15.
//
//

#import "GRFSoundPlayer.h"

@implementation GRFSoundPlayer

// Synthesize the delegate
@synthesize delegate;

// Implement instance methods


// Let the delegate call methods that allow the class object to perform various functions when required by GRFStimuli object

-(void)startPlay
{
    [self startPlaying];
}

-(void)stopPlay
{
    [self stopPlaying];
}

-(void)playerDeactivate
{
    [self playerDidFinishJob];
}


// Use the following delegate methods to control the delegating GRFSoundPlayer object through its delegate. This is specifically important to release the class when its delegate calls for playerDidFinishJob delegate method, to avoid retaining of the class object.

-(void)startPlaying;
{
    [player setVolume:[[NSString stringWithFormat:@"%.02f", stimVolume] floatValue] ];
    [player play];
}

-(void)stopPlaying
{
    [player stop];
}

-(void)playerDidFinishJob;
{
    [player release];
    [self setDelegate:nil];
    [self release];
}

@end
