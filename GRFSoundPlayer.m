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

-(void)getSoundForGabor:(StimDesc)pSD fromDir:(NSString*)soundsDir
{
    // Start the autorelease pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
        // Get the details of the sound object based on gabor parameters: name of the sound file and protocol-specific volume
        soundObject = [[[GRFSoundObjects alloc] init] autorelease];
        soundDetails = [[soundObject getSoundDetailsforGabor:pSD] autorelease];
        soundName = [soundDetails objectAtIndex:0];
        stimVolume = [[soundDetails objectAtIndex:1] floatValue];
        
        // Get NSSound object for the given sound name from the Sounds directory
        soundPath = [[[NSString alloc] initWithString:[soundsDir stringByAppendingPathComponent:@"Sounds"]] autorelease];
        soundFile = [[[NSString alloc] initWithString:[soundPath stringByAppendingPathComponent:soundName]] autorelease];
        player = [[[NSSound alloc] initWithContentsOfFile:soundFile byReference:NO] retain]; // Retain the player for future use
    
        // Log the name of the sound file as this could be helpful durimg runtime
        NSLog(@"Sound File: %@",soundFile);
    
    // Drain the sutorelease pool
    [pool drain];
    
    // Assign self as delegate
    [self setDelegate:self];
}

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
