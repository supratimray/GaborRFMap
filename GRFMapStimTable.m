//
//  GRFMapStimTable.m
//  GaborRFMap
//
//  Created by John Maunsell on 11/2/07.
//  Copyright 2007. All rights reserved.
//

#import "GRF.h"
#import "GRFMapStimTable.h"

static long GRFMapStimTableCounter = 0;

@implementation GRFMapStimTable

- (long)blocksDone;
{
	return blocksDone;
}

- (void)dumpStimList:(NSMutableArray *)list listIndex:(long)listIndex;
{
	StimDesc stimDesc;
	long index;
	
	NSLog(@"Mapping Stim List %ld", listIndex);
	NSLog(@"index type onFrame offFrame azi ele sig sf  ori  con tf");
	for (index = 0; index < [list count]; index++) {
		[[list objectAtIndex:index] getValue:&stimDesc];
		NSLog(@"%4ld:\t%4d\t%4ld\t%4ld\t%4.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f", index, stimDesc.stimType,
			stimDesc.stimOnFrame, stimDesc.stimOffFrame, stimDesc.azimuthDeg, stimDesc.elevationDeg,
			stimDesc.sigmaDeg, stimDesc.spatialFreqCPD, stimDesc.directionDeg,stimDesc.contrastPC,stimDesc.temporalFreqHz);
	}
	NSLog(@"\n");
}

- (id)initWithIndex:(long)index;
{
	if (!(self = [super init])) {
		return nil;
	}
    mapIndex = index;
	[self updateBlockParameters];
    doneList = CFBitVectorCreateMutable(NULL, stimInBlock);
	[self newBlock];
	return self;
}

// No one should init without using [initWithIndex:], but if they do, we automatically increment the index counter;

- (id)init;
{
	if (!(self = [super init])) {
		return nil;
	}
    mapIndex = GRFMapStimTableCounter++;
    NSLog(@"GRFMapStimTable: initializing with index %ld", mapIndex);
	[self updateBlockParameters];
	[self newBlock];
	return self;
}

- (float)contrastValueFromIndex:(long)index count:(long)count min:(float)min max:(float)max;
{
	short c, stimLevels;
	float stimValue, level, stimFactor;
	
	stimLevels = count;
	stimFactor = 0.5;
	switch (stimLevels) {
		case 1:								// Just the 100% stimulus
			stimValue = max;
			break;
		case 2:								// Just 100% and 0% stimuli
			stimValue = (index == 0) ? min : max;
			break;
		default:							// Other values as well
			if (index == 0) {
				stimValue = min;
			}
			else {
				level = max;
				for (c = stimLevels - 1; c > index; c--) {
					level *= stimFactor;
				}
				stimValue = level;
			}
	}
	return(stimValue);
}


- (float)linearValueWithIndex:(long)index count:(long)count min:(float)min max:(float)max;
{
	return (count < 2) ? min : (min + ((max - min) / (count - 1)) * index);
}

- (float)logValueWithIndex:(long)index count:(long)count min:(float)min max:(float)max;
{
	return (count < 2) ? min : min * (powf(max / min, (float)index/(count - 1)));
}

/* makeMapStimList

Make a mapping stimulus lists for one trial.  The list is constructed as an NSMutableArray of StimDesc or 
StimDesc structures.

In the simplest case, we just draw n unused entries from the done table.  If there are fewer than n entries
remaining, we take them all, clear the table, and then proceed.  We also make a provision for the case where 
several full table worth's will be needed to make the list.  Whenever we take all the entries remaining in 
the table, we simply draw them in order and then use shuffleStimList() to randomize their order.  Shuffling 
does not span the borders between successive doneTables, to ensure that each stimulus pairing will 
be presented n times before any appears n + 1 times, even if each appears several times within 
one trial.

Two types of padding stimuli are used.  Padding stimuli are inserted in the list after the target, so
that the stream of stimuli continues through the reaction time.  Padding stimuli are also optionally
put at the start of the trial.  This is so the first few stimulus presentations, which might have 
response transients, are not counted.  The number of padding stimuli at the end of the trial is 
determined by stimRateHz and reactTimeMS.  The number of padding stimuli at the start of the trial
is determined by rate of presentation and stimLeadMS.  Note that it is possible to set parameters 
so that there will never be anything except targets and padding stimuli (e.g., with a short 
maxTargetS and a long stimLeadMS).
*/

- (void)makeMapStimList:(NSMutableArray *)list index:(long)index lastFrame:(long)lastFrame pTrial:(TrialDesc *)pTrial
{
	long stim, frame, mapDurFrames, interDurFrames;
	float frameRateHz;
	StimDesc stimDesc;
	int localFreshCount;
	CFMutableBitVectorRef localList;
	float azimuthDegMin, azimuthDegMax, elevationDegMin, elevationDegMax, sigmaDegMin, sigmaDegMax, spatialFreqCPDMin, spatialFreqCPDMax, directionDegMin, directionDegMax, radiusSigmaRatio, contrastPCMin, contrastPCMax, temporalFreqHzMin, temporalFreqHzMax;
	BOOL hideStimulus, convertToGrating;
    BOOL sigmaLog, spatialFreqLog, contrastLog, temporalFreqLog;
    
	NSArray *stimTableDefaults = [[task defaults] arrayForKey:@"GRFStimTables"];
    NSArray *stimTableRangeTypeDefaults = [[task defaults] arrayForKey:@"GRFStimTableRangeTypes"];
	NSDictionary *minDefaults = [stimTableDefaults objectAtIndex:0];
	NSDictionary *maxDefaults = [stimTableDefaults objectAtIndex:1];
    NSDictionary *rangeDefaults = [stimTableRangeTypeDefaults objectAtIndex:0];
    
	radiusSigmaRatio = [[[task defaults] objectForKey:GRFMapStimRadiusSigmaRatioKey] floatValue];
	
    switch (index) {
        case 0:
        default:
            azimuthDegMin = [[minDefaults objectForKey:@"azimuthDeg0"] floatValue];
            elevationDegMin = [[minDefaults objectForKey:@"elevationDeg0"] floatValue];
            spatialFreqCPDMin = [[minDefaults objectForKey:@"spatialFreqCPD0"] floatValue];
            sigmaDegMin = [[minDefaults objectForKey:@"sigmaDeg0"] floatValue];
            directionDegMin = [[minDefaults objectForKey:@"orientationDeg0"] floatValue];
            contrastPCMin = [[minDefaults objectForKey:@"contrastPC0"] floatValue];
            temporalFreqHzMin = [[minDefaults objectForKey:@"temporalFreqHz0"] floatValue];

            azimuthDegMax = [[maxDefaults objectForKey:@"azimuthDeg0"] floatValue];
            elevationDegMax = [[maxDefaults objectForKey:@"elevationDeg0"] floatValue];
            sigmaDegMax = [[maxDefaults objectForKey:@"sigmaDeg0"] floatValue];
            spatialFreqCPDMax = [[maxDefaults objectForKey:@"spatialFreqCPD0"] floatValue];
            directionDegMax = [[maxDefaults objectForKey:@"orientationDeg0"] floatValue];
            contrastPCMax = [[maxDefaults objectForKey:@"contrastPC0"] floatValue];
            temporalFreqHzMax = [[maxDefaults objectForKey:@"temporalFreqHz0"] floatValue];
            
            sigmaLog = [[rangeDefaults objectForKey:@"sigmaLog0"] boolValue];
            spatialFreqLog = [[rangeDefaults objectForKey:@"spatialFreqLog0"] boolValue];
            contrastLog = [[rangeDefaults objectForKey:@"contrastLog0"] boolValue];
            temporalFreqLog = [[rangeDefaults objectForKey:@"temporalFreqLog0"] boolValue];
            
            hideStimulus = [[task defaults] boolForKey:GRFHideLeftKey];
            break;
        case 1:
            azimuthDegMin = [[minDefaults objectForKey:@"azimuthDeg1"] floatValue];
            elevationDegMin = [[minDefaults objectForKey:@"elevationDeg1"] floatValue];
            spatialFreqCPDMin = [[minDefaults objectForKey:@"spatialFreqCPD1"] floatValue];
            sigmaDegMin = [[minDefaults objectForKey:@"sigmaDeg1"] floatValue];
            directionDegMin = [[minDefaults objectForKey:@"orientationDeg1"] floatValue];
            contrastPCMin = [[minDefaults objectForKey:@"contrastPC1"] floatValue];
            temporalFreqHzMin = [[minDefaults objectForKey:@"temporalFreqHz1"] floatValue];

            azimuthDegMax = [[maxDefaults objectForKey:@"azimuthDeg1"] floatValue];
            elevationDegMax = [[maxDefaults objectForKey:@"elevationDeg1"] floatValue];
            spatialFreqCPDMax = [[maxDefaults objectForKey:@"spatialFreqCPD1"] floatValue];
            sigmaDegMax = [[maxDefaults objectForKey:@"sigmaDeg1"] floatValue];
            directionDegMax = [[maxDefaults objectForKey:@"orientationDeg1"] floatValue];
            contrastPCMax = [[maxDefaults objectForKey:@"contrastPC1"] floatValue];
            temporalFreqHzMax = [[maxDefaults objectForKey:@"temporalFreqHz1"] floatValue];
            
            sigmaLog = [[rangeDefaults objectForKey:@"sigmaLog1"] boolValue];
            spatialFreqLog = [[rangeDefaults objectForKey:@"spatialFreqLog1"] boolValue];
            contrastLog = [[rangeDefaults objectForKey:@"contrastLog1"] boolValue];
            temporalFreqLog = [[rangeDefaults objectForKey:@"temporalFreqLog1"] boolValue];
            
            hideStimulus = [[task defaults] boolForKey:GRFHideRightKey];
            break;
	}
    
    convertToGrating = [[task defaults] boolForKey:GRFConvertToGratingKey];

    localList = CFBitVectorCreateMutableCopy(NULL, stimInBlock, doneList);
	localFreshCount = stimRemainingInBlock;
	frameRateHz = [[task stimWindow] frameRateHz];
/*
    // debugging start
    short a, e, sig, sf, dir, c, debugLocalListCount = 0, debugDoneListCount = 0;
    NSDictionary *countsDict = (NSDictionary *)[[[task defaults] arrayForKey:@"GRFStimTableCounts"] objectAtIndex:0];
    
    for (a = 0;  a < [[countsDict objectForKey:@"azimuthCount"] intValue]; a++) {
        for (e = 0;  e < [[countsDict objectForKey:@"elevationCount"] intValue]; e++) {
            for (sig = 0;  sig < [[countsDict objectForKey:@"sigmaCount"] intValue]; sig++) {
                for (sf = 0;  sf < [[countsDict objectForKey:@"spatialFreqCount"] intValue]; sf++) {
                    for (dir = 0;  dir < [[countsDict objectForKey:@"orientationCount"] intValue]; dir++) {
                        for (c = 0;  c < [[countsDict objectForKey:@"contrastCount"] intValue]; c++) {
                            if (localList[a][e][sig][sf][dir][c]) {
                                debugLocalListCount++;
                                debugDoneListCount++;
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSLog(@"debugLocalListCount is %d", debugLocalListCount);
    NSLog(@"debugDoneListCount is %d", debugDoneListCount);
    // debugging end
*/
	mapDurFrames = MAX(1, ceil([[task defaults] integerForKey:GRFMapStimDurationMSKey] / 1000.0 * frameRateHz));
	interDurFrames = ceil([[task defaults] integerForKey:GRFMapInterstimDurationMSKey] / 1000.0 * frameRateHz);
	
	[list removeAllObjects];
	
	for (stim = frame = 0; frame < lastFrame; stim++, frame += mapDurFrames + interDurFrames) {
		
		int azimuthIndex, elevationIndex, sigmaIndex, spatialFreqIndex, directionDegIndex, contrastIndex, temporalFreqIndex;
		int startAzimuthIndex, startElevationIndex, startSigmaIndex, startSpatialFreqIndex, startDirectionDegIndex, startContrastIndex, startTemporalFreqIndex, stimIndex;
		BOOL stimDone = YES;
	
		startAzimuthIndex = azimuthIndex = rand() % azimuthCount;
		startElevationIndex = elevationIndex = rand() % elevationCount;
		startSigmaIndex = sigmaIndex = rand() % sigmaCount;
		startSpatialFreqIndex = spatialFreqIndex = rand() % spatialFreqCount;
		startDirectionDegIndex = directionDegIndex = rand() % directionDegCount;
		startContrastIndex = contrastIndex = rand() % contrastCount;
        startTemporalFreqIndex = temporalFreqIndex = rand() % temporalFreqCount;
		
		for (;;) {
            stimIndex = azimuthIndex;
            stimIndex = stimIndex * elevationCount + elevationIndex;
            stimIndex = stimIndex * sigmaCount + sigmaIndex;
            stimIndex = stimIndex * spatialFreqCount + spatialFreqIndex;
            stimIndex = stimIndex * directionDegCount + directionDegIndex;
            stimIndex = stimIndex * contrastCount + contrastIndex;
            stimIndex = stimIndex * temporalFreqCount + temporalFreqIndex;
			stimDone = CFBitVectorGetBitAtIndex(localList, stimIndex);
            
			if (!stimDone) {
				break;
			}
			if ((azimuthIndex = ((azimuthIndex+1)%azimuthCount)) == startAzimuthIndex) {
				if ((elevationIndex = ((elevationIndex+1)%elevationCount)) == startElevationIndex) {
					if ((sigmaIndex = ((sigmaIndex+1)%sigmaCount)) == startSigmaIndex) {
						if ((spatialFreqIndex = ((spatialFreqIndex+1)%spatialFreqCount)) == startSpatialFreqIndex) {
							if ((directionDegIndex = ((directionDegIndex+1)%directionDegCount)) == startDirectionDegIndex) {
								if ((contrastIndex = ((contrastIndex+1)%contrastCount)) == startContrastIndex) {
                                    if ((temporalFreqIndex = ((temporalFreqIndex+1)%temporalFreqCount)) == startTemporalFreqIndex) {
                                        NSLog(@"Failed to find empty entry: Expected %d", localFreshCount);
                                        exit(0);
                                    }
								}
							}
						}
					}
				}
			}
		}
					

		// this stimulus has not been done - add it to the list

		stimDesc.gaborIndex = index + 1;
		stimDesc.sequenceIndex = stim;
		stimDesc.stimOnFrame = frame;
		stimDesc.stimOffFrame = frame + mapDurFrames;
        
        if (pTrial->instructTrial) {
			stimDesc.stimType = kNullStim;
		}
		else {
            if (hideStimulus==TRUE)
				stimDesc.stimType = kNullStim;
			else
				stimDesc.stimType = kValidStim;
		}
		
		stimDesc.azimuthIndex = azimuthIndex;
		stimDesc.elevationIndex = elevationIndex;
		stimDesc.sigmaIndex = sigmaIndex;
		stimDesc.spatialFreqIndex = spatialFreqIndex;
		stimDesc.directionIndex = directionDegIndex;
		stimDesc.contrastIndex = contrastIndex;
        stimDesc.temporalFreqIndex = temporalFreqIndex;
		
		stimDesc.azimuthDeg = [self linearValueWithIndex:azimuthIndex count:azimuthCount min:azimuthDegMin max:azimuthDegMax];
		stimDesc.elevationDeg = [self linearValueWithIndex:elevationIndex count:elevationCount min:elevationDegMin max:elevationDegMax];
        
		if (convertToGrating) { // Sigma very high
			stimDesc.sigmaDeg = 100000;
            if (sigmaLog) {
                stimDesc.radiusDeg = [self logValueWithIndex:sigmaIndex count:sigmaCount min:sigmaDegMin max:sigmaDegMax] * radiusSigmaRatio;
            }
            else {
                stimDesc.radiusDeg = [self linearValueWithIndex:sigmaIndex count:sigmaCount min:sigmaDegMin max:sigmaDegMax] * radiusSigmaRatio;
            }
		}
		else {
            if (sigmaLog) {
                stimDesc.sigmaDeg = [self logValueWithIndex:sigmaIndex count:sigmaCount min:sigmaDegMin max:sigmaDegMax];
            }
            else {
                stimDesc.sigmaDeg = [self linearValueWithIndex:sigmaIndex count:sigmaCount min:sigmaDegMin max:sigmaDegMax];
            }
			stimDesc.radiusDeg = stimDesc.sigmaDeg * radiusSigmaRatio;
		}
        
        if (spatialFreqLog) {
            stimDesc.spatialFreqCPD = [self logValueWithIndex:spatialFreqIndex count:spatialFreqCount min:spatialFreqCPDMin max:spatialFreqCPDMax];
        }
        else {
            stimDesc.spatialFreqCPD = [self linearValueWithIndex:spatialFreqIndex count:spatialFreqCount min:spatialFreqCPDMin max:spatialFreqCPDMax];
        }

        stimDesc.directionDeg = [self linearValueWithIndex:directionDegIndex count:directionDegCount min:directionDegMin max:directionDegMax];
		
        if (contrastLog) {
            stimDesc.contrastPC = [self contrastValueFromIndex:contrastIndex count:contrastCount min:contrastPCMin max:contrastPCMax];
        }
        else {
            stimDesc.contrastPC = [self linearValueWithIndex:contrastIndex count:contrastCount min:contrastPCMin max:contrastPCMax];
        }
        
        if (temporalFreqLog) {
            stimDesc.temporalFreqHz = [self contrastValueFromIndex:temporalFreqIndex count:temporalFreqCount min:temporalFreqHzMin max:temporalFreqHzMax];
        }
        else {
            stimDesc.temporalFreqHz = [self linearValueWithIndex:temporalFreqIndex count:temporalFreqCount min:temporalFreqHzMin max:temporalFreqHzMax];
        }
        
        if (stimDesc.temporalFreqHz>=frameRateHz/2) {
            stimDesc.temporalFreqHz=frameRateHz/2;
        }
        
        stimDesc.temporalModulation = [[task defaults] integerForKey:@"GRFMapTemporalModulation"];
		
		// Unused field
		
		stimDesc.orientationChangeDeg = 0.0;
		
		[list addObject:[NSValue valueWithBytes:&stimDesc objCType:@encode(StimDesc)]];

		CFBitVectorSetBitAtIndex(localList, stimIndex, 1);
		//		NSLog(@"%d %d %d %d %d",stimDesc.azimuthIndex,stimDesc.elevationIndex,stimDesc.sigmaIndex,stimDesc.spatialFreqIndex,stimDesc.directionIndex);
		if (--localFreshCount == 0) {
            CFBitVectorSetAllBits(localList, 0);
			localFreshCount = stimInBlock;
		}
	}
//	[self dumpStimList:list listIndex:index];
	[currentStimList release];
	currentStimList = [list retain];
	// Count the stimlist as completed
}

- (MappingBlockStatus)mappingBlockStatus;
{
	MappingBlockStatus status;
    
	status.stimDone = stimInBlock - stimRemainingInBlock;
	status.blocksDone = blocksDone;
	status.stimLimit = stimInBlock;
	status.blockLimit = blockLimit;
	return status;
}

- (MapSettings)mapSettings;
{
 	MapSettings settings;
  	NSDictionary *countsDict = (NSDictionary *)[[[task defaults] arrayForKey:@"GRFStimTableCounts"] objectAtIndex:0];
  	NSDictionary *valuesDict;
   
	settings.azimuthDeg.n = [[countsDict objectForKey:@"azimuthCount"] intValue];
	settings.elevationDeg.n = [[countsDict objectForKey:@"elevationCount"] intValue];
	settings.sigmaDeg.n = [[countsDict objectForKey:@"sigmaCount"] intValue];
	settings.spatialFreqCPD.n = [[countsDict objectForKey:@"spatialFreqCount"] intValue];
	settings.directionDeg.n = [[countsDict objectForKey:@"orientationCount"] intValue];
	settings.contrastPC.n = [[countsDict objectForKey:@"contrastCount"] intValue];
    settings.temporalFreqHz.n = [[countsDict objectForKey:@"temporalFreqCount"] intValue];
 
  	valuesDict = (NSDictionary *)[[[task defaults] arrayForKey:@"GRFStimTables"] objectAtIndex:0];
    settings.azimuthDeg.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"azimuthDeg%ld", mapIndex]] floatValue];
    settings.elevationDeg.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"elevationDeg%ld", mapIndex]] floatValue];
    settings.sigmaDeg.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"sigmaDeg%ld", mapIndex]] floatValue];
    settings.spatialFreqCPD.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"spatialFreqCPD%ld", mapIndex]] floatValue];
    settings.directionDeg.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"orientationDeg%ld", mapIndex]] floatValue];
    settings.contrastPC.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"contrastPC%ld", mapIndex]] floatValue];
    settings.temporalFreqHz.minValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"temporalFreqHz%ld", mapIndex]] floatValue];
    
 	valuesDict = (NSDictionary *)[[[task defaults] arrayForKey:@"GRFStimTables"] objectAtIndex:1];
    settings.azimuthDeg.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"azimuthDeg%ld", mapIndex]] floatValue];
    settings.elevationDeg.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"elevationDeg%ld", mapIndex]] floatValue];
    settings.sigmaDeg.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"sigmaDeg%ld", mapIndex]] floatValue];
    settings.spatialFreqCPD.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"spatialFreqCPD%ld", mapIndex]] floatValue];
    settings.directionDeg.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"orientationDeg%ld", mapIndex]] floatValue];
    settings.contrastPC.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"contrastPC%ld", mapIndex]] floatValue];
    settings.temporalFreqHz.maxValue = [[valuesDict objectForKey:[NSString stringWithFormat:@"temporalFreqHz%ld", mapIndex]] floatValue];

    return settings;
}

- (void)newBlock;
{
    CFBitVectorSetAllBits(doneList, 0);
	stimRemainingInBlock = stimInBlock;
}

- (void)reset;
{
	[self updateBlockParameters];
	[self newBlock];
	blocksDone = 0;
}

- (void)tallyStimList:(NSMutableArray *)list  count:(long)count;
{
	// count = the number of stims that have been processed completely.
	//         The list is processed in order so the first count stims
	//         can be marked done.
	StimDesc stimDesc;
	int stim;
	NSMutableArray *l;
	
	if (list == nil) {
		l = currentStimList;
	}
	else {
		l = list;
	}
	
	for (stim = 0; stim < count; stim++) {
		short a=0, e=0, sf=0, sig=0, o=0, c=0, t=0;
        int stimIndex = 0;
		NSValue *val = [l objectAtIndex:stim];
		
		[val getValue:&stimDesc];
		a=stimDesc.azimuthIndex;
		e=stimDesc.elevationIndex;
		sf=stimDesc.spatialFreqIndex;
		sig=stimDesc.sigmaIndex;
		o=stimDesc.directionIndex;
		c=stimDesc.contrastIndex;
        t=stimDesc.temporalFreqIndex;
		
        stimIndex = a;
        stimIndex = stimIndex * elevationCount + e;
        stimIndex = stimIndex * sigmaCount + sig;
        stimIndex = stimIndex * spatialFreqCount + sf;
        stimIndex = stimIndex * directionDegCount + o;
        stimIndex = stimIndex * contrastCount + c;
        stimIndex = stimIndex * temporalFreqCount + t;
        CFBitVectorSetBitAtIndex(doneList, stimIndex, 1);
		if (--stimRemainingInBlock == 0 ) {
			[self newBlock];
			blocksDone++;
		}
	}
	return;
}

- (void)tallyStimList:(NSMutableArray *)list  upToFrame:(long)frameLimit;
{
	StimDesc stimDesc;
	long a, e, sf, sig, o, stim, c, t;
	NSValue *val;
	NSMutableArray *l;
    int stimIndex = 0;
	
	l = (list == nil) ? currentStimList : list;
	for (stim = 0; stim < [l count]; stim++) {
		val = [l objectAtIndex:stim];
		[val getValue:&stimDesc];
		if (stimDesc.stimOffFrame > frameLimit) {
			break;
		}
		a = stimDesc.azimuthIndex;
		e = stimDesc.elevationIndex;
		sf = stimDesc.spatialFreqIndex;
		sig = stimDesc.sigmaIndex;
		o = stimDesc.directionIndex;
		c = stimDesc.contrastIndex;
        t=stimDesc.temporalFreqIndex;
        stimIndex = a;
        stimIndex = stimIndex * elevationCount + e;
        stimIndex = stimIndex * sigmaCount + sig;
        stimIndex = stimIndex * spatialFreqCount + sf;
        stimIndex = stimIndex * directionDegCount + o;
        stimIndex = stimIndex * contrastCount + c;
        stimIndex = stimIndex * temporalFreqCount + t;
        CFBitVectorSetBitAtIndex(doneList, stimIndex, 1);
		if (--stimRemainingInBlock == 0 ) {
			[self newBlock];
			blocksDone++;
		}
	}
	return;
}

- (long)stimDoneInBlock;
{
	return stimInBlock - stimRemainingInBlock;
}

- (long)stimInBlock;
{
	return stimInBlock;
}

- (void)updateBlockParameters;
{
	NSDictionary *countsDict = (NSDictionary *)[[[task defaults] arrayForKey:@"GRFStimTableCounts"] objectAtIndex:0];

	azimuthCount = [[countsDict objectForKey:@"azimuthCount"] intValue];
	elevationCount = [[countsDict objectForKey:@"elevationCount"] intValue];
	sigmaCount = [[countsDict objectForKey:@"sigmaCount"] intValue];
	spatialFreqCount = [[countsDict objectForKey:@"spatialFreqCount"] intValue];
	directionDegCount = [[countsDict objectForKey:@"orientationCount"] intValue];
	contrastCount = [[countsDict objectForKey:@"contrastCount"] intValue];
	temporalFreqCount = [[countsDict objectForKey:@"temporalFreqCount"] intValue];
    
	stimInBlock = stimRemainingInBlock = azimuthCount * elevationCount * sigmaCount * spatialFreqCount * directionDegCount * contrastCount * temporalFreqCount;
	blockLimit = [[task defaults] integerForKey:GRFMappingBlocksKey];
}

@end
