//
//  GRFSoundObjects.h
//  GaborRFMap
//
//  Created by Murty V P S Dinavahi on 25/04/15.
//
//

#import <Foundation/Foundation.h>

// Define AudStimDesc struct here

typedef struct AudStimDesc {
    int     stimDurationMS;
	int     protocolType;
    int     stimType;
	float	azimuthDeg;
	float	elevationDeg;
	float	spatialFreqCPD;
	float	directionDeg;
    float	contrastPC;
    float   temporalFreqHz;
} AudStimDesc;

@interface GRFSoundObjects : NSObject <NSSoundDelegate>

// A GRFSoundObjects object consists of the following objects within it:

{
    int                     stimulusDuration;
    BOOL                    playerDone;
    float                   stimVolume;
    NSSound                 *player;
    NSString                *soundName;    
    NSString                *soundFile;
    NSString                *soundsDir;
}

// Only the following Methods of this object are accessible to other classes.
-(id)init;
-(void)setDir:(NSString*)dir;
-(void)getSoundForGabor:(AudStimDesc)pSD;
-(void)startPlay;
-(void)stopPlay;


// NSSoundDelegate method {-(void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool} is declared in NSSound and should need not be redeclared here. However, it needs to be implemented in GRFSoundObjects.m

// Protocol-specific methods are declared in GRFSoundObjects.m, and are not accessible to other classes

@end

