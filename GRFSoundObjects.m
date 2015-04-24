//
//  GRFSoundObjects.m
//  GaborRFMap
//
//  Created by Murty V P S Dinavahi on 25/04/15.
//
//

#import "GRFSoundObjects.h"

@implementation GRFSoundObjects

-(NSArray*)getSoundDetailsforGabor:(StimDesc)pSD
{
    // Do not change the following code unless necessary
    // Defaults
    NSNumber *stimVolume = [NSNumber numberWithFloat:1]; // Default would be taken to be the maximum volume if it is not specified in the Protocol Specific Assignments loop.
    
    // Protocol type is to be specified in the min cell of sigma of the right gabor for now
    NSString *soundName = [[NSString alloc] init];
    NSArray *stimTableDefaults = [[task defaults] arrayForKey:@"GRFStimTables"];
    NSDictionary *minDefaults = [stimTableDefaults objectAtIndex:0];
    float protocolType = [[minDefaults objectForKey:@"sigmaDeg1"] floatValue];
    
    stimulusDuration = [[task defaults] integerForKey:GRFMapStimDurationMSKey];
    
    
    
    //////////////////////////////////// Protocol Specific Assignments ///////////////////////////////
    
    // Add protocol-specific statements in this loop.
    /* Format for adding assignments:
     
     soundName = [self get______ProtocolSoundNameforGabor:pSD];
     stimVolume = [NSNumber numberWithFloat:'x'];
     
    */
    
    if (protocolType == 1) { // Stationary and Moving Ripples protocols (1a and 1b respectively)
        soundName = [self getRipplesProtocolsSoundNameforGabor:pSD];
        stimVolume = [NSNumber numberWithFloat:1.0]; // Volume is constant at 100%
    }
    else if (protocolType == 2){ // Sinusoidal Amplitude Modulated sounds Protocol
        soundName = [self getSAMProtocolSoundNameforGabor:pSD];
        stimVolume = [NSNumber numberWithFloat:1.0]; // Volume is constant at 100%
    }
    else if (protocolType == 3) { // Moving Ripples protocol, eyes closed
        soundName = [self getRippleProtocolEyesClosedSoundNameforGabor:pSD];
        stimVolume = [NSNumber numberWithFloat:1.0]; // Volume is constant at 100%
    }
    else if (protocolType == 4){ // Ripples protocol with varying volume with and without visual stimuli of different contrasts
        soundName = [self getVaryingVolumeProtocolSoundNameforGabor:pSD];
        stimVolume = [NSNumber numberWithFloat:(pSD.contrastPC/100)]; // Volume is varying, mapped to contrast of the specific gabor (here, it is rightgabor)
    }
    else if (protocolType == 10) { // Noise burst protocol
        soundName = [self getNoiseProtocolsSoundNameforGabor:pSD];
        stimVolume = [NSNumber numberWithFloat:1.0]; // Volume is constant at 100%
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    // Do not change the following code unless necessary
    NSArray *soundDetails = [[NSArray alloc] initWithObjects:(NSString*)soundName,(NSNumber*)stimVolume, nil];
    return soundDetails;
}



////////////////////////////////// Add Protocol-specific Methods here ///////////////////////////////

/* Format for adding methods:
 
 -(NSString*)get______ProtocolSoundNameforGabor:(StimDesc)pSD
 {
 int stimType = x; // 'x' sounds
 NSString * soundName = [NSString stringWithFormat:@"(name as a string)"]; *** Make sure to include the file extension with the name
 return soundName;
 }
 
 */

-(NSString*)getRipplesProtocolsSoundNameforGabor:(StimDesc)pSD
{
    int stimType = 1; // Ripple sounds
    NSString * soundName = [NSString stringWithFormat:@"Azi_%.1f%@%.1f%@%.0d%@%.1f%@%.0f%@%.1f%@%.1f%@%.0d.wav",(pSD.azimuthDeg),@"_Elev_",(pSD.elevationDeg),@"_Type_",stimType,@"_RF_",(pSD.spatialFreqCPD),@"_RP_",(pSD.directionDeg),@"_MD_",(pSD.contrastPC/100),@"_RV_",(pSD.temporalFreqHz),@"_Dur_",stimulusDuration];
    return soundName;
}

-(NSString*)getSAMProtocolSoundNameforGabor:(StimDesc)pSD
{
    int stimType = 2; // SAM sounds
    NSString * soundName = [NSString stringWithFormat:@"Azi_%.1f_%@_%.1f_%@_%.0d_%@_%.1f_%@_%.0f_%@_%.1f_%@_%.1f_%@_%.0d.wav",(pSD.azimuthDeg),@"Elev",(pSD.elevationDeg),@"Type",stimType,@"RF",(pSD.spatialFreqCPD),@"RP",(pSD.directionDeg),@"MD",(pSD.contrastPC/100),@"RV",(pSD.temporalFreqHz),@"Dur",stimulusDuration];
    return soundName;
}

-(NSString*)getRippleProtocolEyesClosedSoundNameforGabor:(StimDesc)pSD
{
    int stimType = 1; // Ripple sounds
    NSString * soundName = [NSString stringWithFormat:@"Azi_%.1f_%@_%.1f_%@_%.0d_%@_%.1f_%@_%.0f_%@_%.1f_%@_%.1f_%@_%.0d.wav",(pSD.azimuthDeg),@"Elev",(pSD.elevationDeg),@"Type",stimType,@"RF",(pSD.spatialFreqCPD),@"RP",(pSD.directionDeg),@"MD",(pSD.contrastPC/100),@"RV",(pSD.temporalFreqHz*8),@"Dur",stimulusDuration];
    return soundName;
}

-(NSString*)getVaryingVolumeProtocolSoundNameforGabor:(StimDesc)pSD
{
    int stimType = 1; // Ripple sounds
    NSString * soundName = [NSString stringWithFormat:@"Azi_%.1f_%@_%.1f_%@_%.0d_%@_%.1f_%@_%.0f_%@_%.1f_%@_%.1f_%@_%.0d.wav",(pSD.azimuthDeg),@"Elev",(pSD.elevationDeg),@"Type",stimType,@"RF",(pSD.spatialFreqCPD),@"RP",(pSD.directionDeg),@"MD",0.9,@"RV",(pSD.temporalFreqHz),@"Dur",stimulusDuration]; // Modulation depth is fixed at 0.9
    return soundName;
}


-(NSString*)getNoiseProtocolsSoundNameforGabor:(StimDesc)pSD
{
    // Noise_Dur_100
    NSString * soundName = [NSString stringWithFormat:@"Noise_Dur_%.0d.wav",stimulusDuration];
    return soundName;
}


@end
