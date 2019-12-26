//
//  GRFMapStimTable.h
//  GaborRFMap
//
//  Created by John Maunsell on 11/2/07.
//  Copyright 2007. All rights reserved.
//

#import "GRF.h"

@interface GRFMapStimTable : NSObject
{
	long blocksDone;
	long blockLimit;
	CFMutableBitVectorRef doneList; // maintained as a 1-D bit vector
    long azimuthCount;
    long elevationCount;
    long sigmaCount;
    long spatialFreqCount;
    long directionDegCount;
    long contrastCount;
    long temporalFreqCount;
    long mapIndex;                  // index to instance of GRFMapStimTable
	int stimRemainingInBlock;
	int stimInBlock;
	NSMutableArray *currentStimList;
    NSMutableArray *currentStimList1; // Two lists have to be retained if the StimLists are being combined
}

- (long)blocksDone;
- (void)dumpStimList:(NSMutableArray *)list listIndex:(long)listIndex;
- (float)contrastValueFromIndex:(long)index count:(long)count min:(float)min max:(float)max;
- (id)initWithIndex:(long)index;
- (float)linearValueWithIndex:(long)index count:(long)count min:(float)min max:(float)max;
- (float)logValueWithIndex:(long)index count:(long)count min:(float)min max:(float)max;
- (void)makeMapStimList:(NSMutableArray *)list index:(long)index lastFrame:(long)lastFrame pTrial:(TrialDesc *)pTrial;
- (void)makeCombinedMapStimList:(NSMutableArray *)list0 list1:(NSMutableArray *)list1 lastFrame:(long)lastFrame pTrial:(TrialDesc *)pTrial;
- (MappingBlockStatus)mappingBlockStatus;
- (MapSettings)mapSettings;
- (void)newBlock;
- (void)reset;
- (long)stimInBlock;
- (void)tallyStimList:(NSMutableArray *)list  count:(long)count;
- (void)tallyStimList:(NSMutableArray *)list  upToFrame:(long)frameLimit;
- (void)tallyCombinedStimList:(NSMutableArray *)list0 list1:(NSMutableArray *)list1 count:(long)count;
- (void)tallyCombinedStimList:(NSMutableArray *)list0 list1:(NSMutableArray *)list1 upToFrame:(long)frameLimit;
- (long)stimDoneInBlock;
- (void)updateBlockParameters;

@end
