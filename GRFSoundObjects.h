//
//  GRFSoundObjects.h
//  GaborRFMap
//
//  Created by Murty V P S Dinavahi on 25/04/15.
//
//

#import <Foundation/Foundation.h>
#import "GRF.h"

@interface GRFSoundObjects : NSObject

{
    int                     stimulusDuration;
}

// Only the following Method is accessible to GRFStimuli.m. This is called in the method presentStimSequence of GRFStimuli.m and returns an array of a string that contains the name of the sound file and a number that contains protocol-specific volume
-(NSArray*)getSoundDetailsforGabor:(StimDesc)pSD;

// Protocol-specific methods are declared in GRFSoundObjects.m, and are not accessible to GRFStimuli.m

@end
