//
//  GRFSoundObjects.m
//  GaborRFMap
//
//  Created by Murty V P S Dinavahi on 25/04/15.
//
//

#import "GRFSoundObjects.h"

@implementation GRFSoundObjects

//////////////////////////////// Do not change the following code unless necessary ////////////////////////////////////

-(id)init
{
    soundName = [[NSString alloc] init];
    soundFile = [[NSString alloc] init];
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)getSoundForGabor:(AudStimDesc)pSD fromDir:(NSString*)soundsDir
{

    // Get stimulus duration and protocol type
    stimulusDuration = pSD.stimDurationMS;
    int protocolType = pSD.protocolType;
    
    // Get sound file name
    [self getSoundDetailsforGabor:pSD forProtocolType:protocolType];
    soundFile = [[soundsDir stringByAppendingPathComponent:@"Sounds"] stringByAppendingPathComponent:soundName];
    
    // Init player with set volume
    player = [[NSSound alloc] initWithContentsOfFile:soundFile byReference:NO];
    [player setVolume:stimVolume];
    
    // Log the name of the sound file as this could be helpful durimg runtime
    NSLog(@"Sound File: %@",soundFile);
    
    // Assign self as delegate
    [player setDelegate:self];
}

-(void)startPlay
{
    [player play];
    playerDone = NO;
}

-(void)stopPlay
{
    if (!playerDone) {
        [player stop];
    }
}

// Use the following NSSoundDelegate method to release player after playback. This method gets invoked automatically once playback is over or is stopped.
-(void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool
{
    playerDone = YES;
    [sound setDelegate:nil];
    [sound release];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////// Protocol Specific Calls ///////////////////////////////////////

// Add protocol-specific statements in this loop.
/* Format for adding assignments:
 
 else if {
 [self get______ProtocolSoundForGabor:pSD];
 }
 
 */


-(void)getSoundDetailsforGabor:(AudStimDesc)pSD forProtocolType:(int)protocolType
{
    if (protocolType == 1) { // Stationary and Moving Ripples protocols (eye open and closed state, both)
        [self getRipplesProtocolsSoundForGabor:pSD];
    }
    else if (protocolType == 2){ // Sinusoidal Amplitude Modulated sounds Protocol
        [self getSAMProtocolSoundForGabor:pSD];
    }
    else if (protocolType == 3){ // Ripples protocol with varying volume with and without visual stimuli of different contrasts
        [self getVaryingVolumeProtocolSoundForGabor:pSD];
    }
    else if (protocolType == 10) { // Noise burst protocol
        [self getNoiseProtocolsSoundForGabor:pSD];
    }
}



////////////////////////////////// Add Protocol-specific Methods here ///////////////////////////////

/* Format for adding methods:
 
 -(void)get______ProtocolSoundForGabor:(AudStimDesc)pSD
 {
     int stimType = x; // 'x' sounds
     soundName = [NSString stringWithFormat:@"(name as a string)"]; // *** Make sure to include the file extension with the name
     stimVolume = y;
 }
 
 */

-(void)getRipplesProtocolsSoundForGabor:(AudStimDesc)pSD
{
    int stimType = 1; // Ripple sounds
    soundName = [NSString stringWithFormat:@"Azi_%.1f%@%.1f%@%.0d%@%.1f%@%.0f%@%.1f%@%.1f%@%.0d.wav",(pSD.azimuthDeg),@"_Elev_",(pSD.elevationDeg),@"_Type_",stimType,@"_RF_",(pSD.spatialFreqCPD),@"_RP_",(pSD.directionDeg),@"_MD_",(pSD.contrastPC/100),@"_RV_",(pSD.temporalFreqHz),@"_Dur_",stimulusDuration];
    stimVolume = 1;
}

-(void)getSAMProtocolSoundForGabor:(AudStimDesc)pSD
{
    int stimType = 2; // SAM sounds
    soundName = [NSString stringWithFormat:@"Azi_%.1f_%@_%.1f_%@_%.0d_%@_%.1f_%@_%.0f_%@_%.1f_%@_%.1f_%@_%.0d.wav",(pSD.azimuthDeg),@"Elev",(pSD.elevationDeg),@"Type",stimType,@"RF",(pSD.spatialFreqCPD),@"RP",(pSD.directionDeg),@"MD",(pSD.contrastPC/100),@"RV",(pSD.temporalFreqHz),@"Dur",stimulusDuration];
    stimVolume = 1;
}

-(void)getVaryingVolumeProtocolSoundForGabor:(AudStimDesc)pSD
{
    int stimType = 1; // Ripple sounds
    soundName = [NSString stringWithFormat:@"Azi_%.1f_%@_%.1f_%@_%.0d_%@_%.1f_%@_%.0f_%@_%.1f_%@_%.1f_%@_%.0d.wav",(pSD.azimuthDeg),@"Elev",(pSD.elevationDeg),@"Type",stimType,@"RF",(pSD.spatialFreqCPD),@"RP",(pSD.directionDeg),@"MD",0.9,@"RV",(pSD.temporalFreqHz),@"Dur",stimulusDuration]; // Modulation depth is fixed at 0.9
    stimVolume = (pSD.contrastPC)/100;
}

-(void)getNoiseProtocolsSoundForGabor:(AudStimDesc)pSD
{
    // stimType is Noise
    soundName = [NSString stringWithFormat:@"Noise_Dur_%.0d.wav",stimulusDuration];
    stimVolume = 1;
}


@end
