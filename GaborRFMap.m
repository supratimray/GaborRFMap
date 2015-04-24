//
//  GaborRFMap.m
//  GaborRFMap
//
//  Copyright 2006. All rights reserved.
//

#import "GRF.h"
#import "GaborRFMap.h"
#import "GRFSummaryController.h"
#import "GRFBehaviorController.h"
#import "GRFSpikeController.h"
#import "GRFXTController.h"
#import "UtilityFunctions.h"
#import "GRFStimuli.h"
#import "GRFMapStimTable.h"

#define		kRewardBit				0x0001

// Behavioral parameters

NSString *GRFAcquireMSKey = @"GRFAcquireMS";
NSString *GRFAlphaTargetDetectionTaskKey = @"GRFAlphaTargetDetectionTask";
NSString *GRFBlockLimitKey = @"GRFBlockLimit";
NSString *GRFBreakPunishMSKey = @"GRFBreakPunishMS";
NSString *GRFChangeScaleKey = @"GRFChangeScale";
NSString *GRFCatchTrialPCKey = @"GRFCatchTrialPC";
NSString *GRFCatchTrialMaxPCKey = @"GRFCatchTrialMaxPC";
NSString *GRFCueMSKey = @"GRFCueMS";
NSString *GRFDoSoundsKey = @"GRFDoSounds";
NSString *GRFFixateKey = @"GRFFixate";
NSString *GRFFixateMSKey = @"GRFFixateMS";
NSString *GRFFixateOnlyKey = @"GRFFixateOnly";
NSString *GRFFixGraceMSKey = @"GRFFixGraceMS";
NSString *GRFFixJitterPCKey = @"GRFFixJitterPC";
NSString *GRFFixWindowWidthDegKey = @"GRFFixWindowWidthDeg";
NSString *GRFInstructionTrialsKey = @"GRFInstructionTrials";
NSString *GRFIntertrialMSKey = @"GRFIntertrialMS";
NSString *GRFInvalidRewardFactorKey = @"GRFInvalidRewardFactor";
NSString *GRFMinTargetMSKey = @"GRFMinTargetMS";
NSString *GRFMaxTargetMSKey = @"GRFMaxTargetMS";
NSString *GRFMeanTargetMSKey = @"GRFMeanTargetMS";
NSString *GRFNontargetContrastPCKey = @"GRFNontargetContrastPC";
NSString *GRFRespSpotSizeDegKey = @"GRFRespSpotSizeDeg";
NSString *GRFRespTimeMSKey = @"GRFRespTimeMS";
NSString *GRFRespWindowWidthDegKey = @"GRFRespWindowWidthDeg";
NSString *GRFRewardMSKey = @"GRFRewardMS";
NSString *GRFMinRewardMSKey = @"GRFMinRewardMS";
NSString *GRFRandTaskGaborDirectionKey = @"GRFRandTaskGaborDirection";
NSString *GRFRewardScheduleKey = @"GRFRewardSchedule";
NSString *GRFSaccadeTimeMSKey = @"GRFSaccadeTimeMS";
NSString *GRFStimRepsPerBlockKey = @"GRFStimRepsPerBlock";
NSString *GRFStimDistributionKey = @"GRFStimDistribution";
NSString *GRFTaskStatusKey = @"GRFTaskStatus";
NSString *GRFTooFastMSKey = @"GRFTooFastMS";

// Stimulus Parameters

NSString *GRFInterstimJitterPCKey = @"GRFInterstimJitterPC";
NSString *GRFInterstimMSKey = @"GRFInterstimMS";
NSString *GRFMapInterstimDurationMSKey = @"GRFMapInterstimDurationMS";
NSString *GRFMappingBlocksKey = @"GRFMappingBlocks";
NSString *GRFMapStimDurationMSKey = @"GRFMapStimDurationMS";
NSString *GRFStimDurationMSKey = @"GRFStimDurationMS";
NSString *GRFStimJitterPCKey = @"GRFStimJitterPC";
NSString *GRFOrientationChangesKey = @"GRFOrientationChanges";
NSString *GRFMaxDirChangeDegKey = @"GRFMaxDirChangeDeg";
NSString *GRFMinDirChangeDegKey = @"GRFMinDirChangeDeg";
NSString *GRFChangeRemainKey = @"GRFChangeRemain";
NSString *GRFChangeArrayKey = @"GRFChangeArray";
NSString *GRFStimTablesKey = @"GRFStimTables";
NSString *GRFStimTableCountsKey = @"GRFStimTableCounts";
NSString *GRFStimTableRangeTypesKey = @"GRFStimTableRangeTypes";
NSString *GRFMapStimContrastPCKey = @"GRFMapStimContrastPC";
NSString *GRFMapStimRadiusSigmaRatioKey = @"GRFMapStimRadiusSigmaRatio";
NSString *GRFTargetAlphaKey = @"GRFTargetAlpha";
NSString *GRFTargetRadiusKey = @"GRFTargetRadius";

NSString *GRFHideLeftKey = @"GRFHideLeft";
NSString *GRFHideRightKey = @"GRFHideRight";
NSString *GRFHideLeftDigitalKey = @"GRFHideLeftDigital";
NSString *GRFHideRightDigitalKey = @"GRFHideRightDigital";
NSString *GRFConvertToGratingKey = @"GRFConvertToGrating";
NSString *GRFUseSingleITC18Key = @"GRFUseSingleITC18";

NSString *GRFHideTaskGaborKey = @"GRFHideTaskGabor";
NSString *GRFIncludeCatchTrialsinDoneListKey = @"GRFIncludeCatchTrialsinDoneList";
NSString *GRFMapTemporalModulationKey = @"GRFMapTemporalModulation";

NSString *GRFConvertToPlaidKey = @"GRFConvertToPlaid";
NSString *GRFPlayAudStimKey = @"GRFPlayAudStim";

// Visual Stimulus Parameters 

NSString *GRFSpatialPhaseDegKey = @"GRFSpatialPhaseDeg";
NSString *GRFTemporalFreqHzKey = @"GRFTemporalFreqHz";

// Keys for change array

NSString *GRFChangeKey = @"change";
NSString *GRFValidRepsKey = @"validReps";
NSString *GRFInvalidRepsKey = @"invalidReps";

NSString *keyPaths[] = {@"values.GRFBlockLimit", @"values.GRFRespTimeMS", 
					@"values.GRFStimTableCounts", @"values.GRFStimTables", @"values.GRFStimTableRangeTypes",
					@"values.GRFStimDurationMS", @"values.GRFMapStimDurationMS", @"values.GRFMapInterstimDurationMS", 
					@"values.GRFInterstimMS", @"values.GRFOrientationChanges", @"values.GRFMappingBlocks",
					@"values.GRFMinDirChangeDeg", @"values.GRFMaxDirChangeDeg", @"values.GRFStimRepsPerBlock",
					@"values.GRFMinTargetMS", @"values.GRFMaxTargetMS", @"values.GRFChangeArray",
					@"values.GRFChangeScale", @"values.GRFMeanTargetMS", @"values.GRFFixateMS",
					@"values.GRFMapStimRadiusSigmaRatio",@"values.GRFHideTaskGabor",@"values.GRFHideLeft",@"values.GRFHideRight",
					nil};

LLScheduleController	*scheduler = nil;
GRFStimuli				*stimuli = nil;
GRFDigitalOut			*digitalOut = nil;

LLDataDef gaborStructDef[] = kLLGaborEventDesc;
LLDataDef fixWindowStructDef[] = kLLEyeWindowEventDesc;

LLDataDef blockStatusDef[] = {
	{@"long",	@"changes", 1, offsetof(BlockStatus, changes)},
	{@"float",	@"orientationChangeDeg", kMaxOriChanges, offsetof(BlockStatus, orientationChangeDeg)},
	{@"long",	@"validReps", kMaxOriChanges, offsetof(BlockStatus, validReps)},
	{@"long",	@"validRepsDone", kMaxOriChanges, offsetof(BlockStatus, validRepsDone)},
	{@"long",	@"invalidReps", kMaxOriChanges, offsetof(BlockStatus, invalidReps)},
	{@"long",	@"invalidRepsDone", kMaxOriChanges, offsetof(BlockStatus, invalidRepsDone)},
	{@"long",	@"instructDone", 1, offsetof(BlockStatus, instructDone)},
	{@"long",	@"instructTrials", 1, offsetof(BlockStatus, instructTrials)},
	{@"long",	@"sidesDone", 1, offsetof(BlockStatus, sidesDone)},
	{@"long",	@"blockLimit", 1, offsetof(BlockStatus, blockLimit)},
	{@"long",	@"blocksDone", 1, offsetof(BlockStatus, blocksDone)},
	{nil}};

LLDataDef mappingBlockStatusDef[] = {
	{@"long",	@"stimDone", 1, offsetof(MappingBlockStatus, stimDone)},
	{@"long",	@"stimLimit", 1, offsetof(MappingBlockStatus, stimLimit)},
	{@"long",	@"blocksDone", 1, offsetof(MappingBlockStatus, blocksDone)},
	{@"long",	@"blockLimit", 1, offsetof(MappingBlockStatus, blockLimit)},
	{nil}};

LLDataDef stimDescDef[] = {
	{@"long",	@"gaborIndex", 1, offsetof(StimDesc, gaborIndex)},
	{@"long",	@"sequenceIndex", 1, offsetof(StimDesc, sequenceIndex)},
	{@"long",	@"stimOnFrame", 1, offsetof(StimDesc, stimOnFrame)},
	{@"long",	@"stimOffFrame", 1, offsetof(StimDesc, stimOffFrame)},
	{@"short",	@"stimType", 1, offsetof(StimDesc, stimType)},
	{@"float",	@"orientationChangeDeg", 1, offsetof(StimDesc, orientationChangeDeg)},
	{@"float",	@"contrastPC", 1, offsetof(StimDesc, contrastPC)},
	{@"float",	@"azimuthDeg", 1, offsetof(StimDesc, azimuthDeg)},
	{@"float",	@"elevationDeg", 1, offsetof(StimDesc, elevationDeg)},
	{@"float",	@"sigmaDeg", 1, offsetof(StimDesc, sigmaDeg)},
    {@"float",	@"radiusDeg", 1, offsetof(StimDesc, radiusDeg)},
	{@"float",	@"spatialFreqCPD", 1, offsetof(StimDesc, spatialFreqCPD)},
	{@"float",	@"directionDeg", 1, offsetof(StimDesc, directionDeg)},
    {@"float",	@"temporalFreqHz", 1, offsetof(StimDesc, temporalFreqHz)},
	{@"long",	@"azimuthIndex", 1, offsetof(StimDesc, azimuthIndex)},
	{@"long",	@"elevationIndex", 1, offsetof(StimDesc, elevationIndex)},
	{@"long",	@"sigmaIndex", 1, offsetof(StimDesc, sigmaIndex)},
	{@"long",	@"spatialFreqIndex", 1, offsetof(StimDesc, spatialFreqIndex)},
	{@"long",	@"directionIndex", 1, offsetof(StimDesc, directionIndex)},
	{@"long",	@"contrastIndex", 1, offsetof(StimDesc, contrastIndex)},
	{@"long",	@"temporalFreqIndex", 1, offsetof(StimDesc, temporalFreqIndex)},
    {@"long",	@"temporalModulation", 1, offsetof(StimDesc, temporalModulation)},
    {nil}};

LLDataDef trialDescDef[] = {
	{@"boolean",@"instructTrial", 1, offsetof(TrialDesc, instructTrial)},
	{@"boolean",@"catchTrial", 1, offsetof(TrialDesc, catchTrial)},
	{@"long",	@"numStim", 1, offsetof(TrialDesc, numStim)},
	{@"long",	@"targetIndex", 1, offsetof(TrialDesc, targetIndex)},
	{@"long",	@"targetOnTimeMS", 1, offsetof(TrialDesc, targetOnTimeMS)},
	{@"long",	@"orientationChangeIndex", 1, offsetof(TrialDesc, orientationChangeIndex)},
	{@"float",	@"orientationChangeDeg", 1, offsetof(TrialDesc, orientationChangeDeg)},
	{nil}};

LLDataDef behaviorSettingDef[] = {
	{@"long",	@"blocks", 1, offsetof(BehaviorSetting, blocks)},
	{@"long",	@"intertrialMS", 1, offsetof(BehaviorSetting, intertrialMS)},
	{@"long",	@"acquireMS", 1, offsetof(BehaviorSetting, acquireMS)},
	{@"long",	@"fixGraceMS", 1, offsetof(BehaviorSetting, fixGraceMS)},
	{@"long",	@"fixateMS", 1, offsetof(BehaviorSetting, fixateMS)},
	{@"long",	@"fixateJitterPC", 1, offsetof(BehaviorSetting, fixateJitterPC)},
	{@"long",	@"responseTimeMS", 1, offsetof(BehaviorSetting, responseTimeMS)},
	{@"long",	@"tooFastMS", 1, offsetof(BehaviorSetting, tooFastMS)},
	{@"long",	@"minSaccadeDurMS", 1, offsetof(BehaviorSetting, minSaccadeDurMS)},
	{@"long",	@"breakPunishMS", 1, offsetof(BehaviorSetting, breakPunishMS)},
	{@"long",	@"rewardSchedule", 1, offsetof(BehaviorSetting, rewardSchedule)},
	{@"long",	@"rewardMS", 1, offsetof(BehaviorSetting, rewardMS)},
	{@"float",	@"fixWinWidthDeg", 1, offsetof(BehaviorSetting, fixWinWidthDeg)},
	{@"float",	@"respWinWidthDeg", 1, offsetof(BehaviorSetting, respWinWidthDeg)},
	{nil}};

LLDataDef stimSettingDef[] = {
	{@"long",	@"stimDurationMS", 1, offsetof(StimSetting, stimDurationMS)},
	{@"long",	@"stimDurJitterPC", 1, offsetof(StimSetting, stimDurJitterPC)},
	{@"long",	@"interStimMS", 1, offsetof(StimSetting, interStimMS)},
	{@"long",	@"interStimJitterPC", 1, offsetof(StimSetting, interStimJitterPC)},
	{@"long",	@"stimLeadMS", 1, offsetof(StimSetting, stimLeadMS)},
	{@"float",	@"stimSpeedHz", 1, offsetof(StimSetting, stimSpeedHz)},
	{@"long",	@"stimDistribution", 1, offsetof(StimSetting, stimDistribution)},
	{@"long",	@"minTargetOnTimeMS", 1, offsetof(StimSetting, minTargetOnTimeMS)},
	{@"long",	@"meanTargetOnTimeMS", 1, offsetof(StimSetting, meanTargetOnTimeMS)},
	{@"long",	@"maxTargetOnTimeMS", 1, offsetof(StimSetting, maxTargetOnTimeMS)},
	{@"float",	@"eccentricityDeg", 1, offsetof(StimSetting, eccentricityDeg)},
	{@"float",	@"polarAngleDeg", 1, offsetof(StimSetting, polarAngleDeg)},
	{@"float",	@"driftDirectionDeg", 1, offsetof(StimSetting, driftDirectionDeg)},
	{@"float",	@"contrastPC", 1, offsetof(StimSetting, contrastPC)},
	{@"short",	@"numberOfSurrounds", 1, offsetof(StimSetting, numberOfSurrounds)},
	{@"long",	@"changeScale", 1, offsetof(StimSetting, changeScale)},
	{@"long",	@"orientationChanges", 1, offsetof(StimSetting, orientationChanges)},
	{@"float",	@"maxChangeDeg", 1, offsetof(StimSetting, maxChangeDeg)},
	{@"float",	@"minChangeDeg", 1, offsetof(StimSetting, minChangeDeg)},
	{@"long",	@"changeRemains", 1, offsetof(StimSetting, changeRemains)},
	{nil}};

LLDataDef mapParamsDef[] = {
    {@"long",	@"n", 1, offsetof(MapParams, n)},
    {@"float",	@"minValue", 1, offsetof(MapParams, minValue)},
    {@"float",	@"maxValue", 1, offsetof(MapParams, maxValue)},
    {nil}};

LLDataDef mapSettingsDef[] = {
	{@"struct",	@"azimuthDeg", 1, offsetof(MapSettings, azimuthDeg), sizeof(MapParams), mapParamsDef},
	{@"struct",	@"elevationDeg", 1, offsetof(MapSettings, elevationDeg), sizeof(MapParams), mapParamsDef},
	{@"struct",	@"directionDeg", 1, offsetof(MapSettings, directionDeg), sizeof(MapParams), mapParamsDef},
	{@"struct",	@"spatialFreqCPD", 1, offsetof(MapSettings, spatialFreqCPD), sizeof(MapParams), mapParamsDef},
	{@"struct",	@"sigmaDeg", 1, offsetof(MapSettings, sigmaDeg), sizeof(MapParams), mapParamsDef},
	{@"struct",	@"contrastPC", 1, offsetof(MapSettings, contrastPC), sizeof(MapParams), mapParamsDef},
	{@"struct",	@"temporalFreqHz", 1, offsetof(MapSettings, temporalFreqHz), sizeof(MapParams), mapParamsDef},
    {nil}};
	
//DataAssignment eyeXDataAssignment = {@"eyeXData",	@"Synthetic", 0, 5.0};	
//DataAssignment eyeYDataAssignment = {@"eyeYData",	@"Synthetic", 1, 5.0};

DataAssignment eyeRXDataAssignment = {@"eyeRXData",     @"Synthetic", 2, 5.0};
DataAssignment eyeRYDataAssignment = {@"eyeRYData",     @"Synthetic", 3, 5.0};
DataAssignment eyeRPDataAssignment = {@"eyeRPData",     @"Synthetic", 4, 5.0};
DataAssignment eyeLXDataAssignment = {@"eyeLXData",     @"Synthetic", 5, 5.0};
DataAssignment eyeLYDataAssignment = {@"eyeLYData",     @"Synthetic", 6, 5.0};
DataAssignment eyeLPDataAssignment = {@"eyeLPData",     @"Synthetic", 7, 5.0};

DataAssignment spike0Assignment =   {@"spike0",     @"Synthetic", 2, 1};
DataAssignment spike1Assignment =   {@"spike1",     @"Synthetic", 3, 1};
DataAssignment VBLDataAssignment =  {@"VBLData",	@"Synthetic", 1, 1};

	
EventDefinition GRFEvents[] = {
    // recorded at start of file, these need to be announced using announceEvents() in UtilityFunctions.m
	{@"taskGabor",			sizeof(Gabor),			{@"struct", @"taskGabor", 1, 0, sizeof(Gabor), gaborStructDef}},
	{@"mappingGabor0",		sizeof(Gabor),			{@"struct", @"mappingGabor0", 1, 0, sizeof(Gabor), gaborStructDef}},
	{@"mappingGabor1",		sizeof(Gabor),			{@"struct", @"mappingGabor1", 1, 0, sizeof(Gabor), gaborStructDef}},
	{@"behaviorSetting",	sizeof(BehaviorSetting),{@"struct", @"behaviorSetting", 1, 0, sizeof(BehaviorSetting), behaviorSettingDef}},
	{@"stimSetting",		sizeof(StimSetting),	{@"struct", @"stimSetting", 1, 0, sizeof(StimSetting), stimSettingDef}},
	{@"map0Settings",		sizeof(MapSettings),    {@"struct", @"mapSettings", 1, 0, sizeof(MapSettings), mapSettingsDef}},
	{@"map1Settings",		sizeof(MapSettings),    {@"struct", @"mapSettings", 1, 0, sizeof(MapSettings), mapSettingsDef}},
	{@"eccentricityDeg",	sizeof(float),			{@"float"}},
	{@"polarAngleDeg",		sizeof(float),			{@"float"}},

    // timing parameters
	{@"stimDurationMS",		sizeof(long),			{@"long"}},
	{@"interstimMS",		sizeof(long),			{@"long"}},
	{@"mapStimDurationMS",	sizeof(long),			{@"long"}},
	{@"mapInterstimDurationMS",		sizeof(long),	{@"long"}},
	{@"stimLeadMS",			sizeof(long),			{@"long"}},
	{@"responseTimeMS",		sizeof(long),			{@"long"}},
	{@"fixateMS",			sizeof(long),			{@"long"}},
	{@"tooFastTimeMS",		sizeof(long),			{@"long"}},
	{@"blockStatus",		sizeof(BlockStatus),	{@"struct", @"blockStatus", 1, 0, sizeof(BlockStatus), blockStatusDef}},
	{@"mappingBlockStatus",	sizeof(MappingBlockStatus),	{@"struct", @"mappingBlockStatus", 1, 0, sizeof(MappingBlockStatus), mappingBlockStatusDef}},
	{@"meanTargetTimeMS",	sizeof(long),			{@"long"}},
	{@"minTargetTimeMS",	sizeof(long),			{@"long"}},
	{@"maxTargetTimeMS",	sizeof(long),			{@"long"}},

    // declared at start of each trial	
	{@"trial",				sizeof(TrialDesc),		{@"struct", @"trial", 1, 0, sizeof(TrialDesc), trialDescDef}},
	{@"responseWindow",		sizeof(FixWindowData),	{@"struct", @"responseWindowData", 1, 0, sizeof(FixWindowData), fixWindowStructDef}},

    // marking the course of each trial
	{@"preStimuli",			0,						{@"no data"}},
	{@"stimulus",			sizeof(StimDesc),		{@"struct", @"stimDesc", 1, 0, sizeof(StimDesc), stimDescDef}},
    {@"stimulusOffTime",	0,						{@"no data"}},
	{@"stimulusOnTime",		0,						{@"no data"}},
	{@"postStimuli",		0,						{@"no data"}},
	{@"saccade",			0,						{@"no data"}},
	{@"tooFast",			0,						{@"no data"}},
	{@"react",				0,						{@"no data"}},
	{@"fixGrace",			0,						{@"no data"}},
	{@"myTrialEnd",			sizeof(long),			{@"long"}},

	{@"taskMode", 			sizeof(long),			{@"long"}},
	{@"reset", 				sizeof(long),			{@"long"}}, 
};

BlockStatus			blockStatus;
MappingBlockStatus	mappingBlockStatus;
BOOL				brokeDuringStim;
LLTaskPlugIn		*task = nil;
long                trialCounter;


@implementation GaborRFMap

+ (NSInteger)version;
{
	return kLLPluginVersion;
}

// Start the method that will collect data from the event buffer

- (void)activate;
{ 
	long longValue;
	NSMenu *mainMenu;
	
	if (active) {
		return;
	}

    // Insert Actions and Settings menus into menu bar
	 
	mainMenu = [NSApp mainMenu];
	[mainMenu insertItem:actionsMenuItem atIndex:([mainMenu indexOfItemWithTitle:@"Tasks"] + 1)];
	[mainMenu insertItem:settingsMenuItem atIndex:([mainMenu indexOfItemWithTitle:@"Tasks"] + 1)];
    
    // Make sure that the task status is in the right state
    
    [taskStatus setMode:kTaskIdle];
    [taskStatus setDataFileOpen:NO];
		
    // Erase the stimulus display

	[stimuli erase];
	
	mapStimTable0 = [[GRFMapStimTable alloc] initWithIndex:0];
	mapStimTable1 = [[GRFMapStimTable alloc] initWithIndex:1];
	
// Create on-line display windows

	
	[[controlPanel window] orderFront:self];
  
	behaviorController = [[GRFBehaviorController alloc] init];
    [dataDoc addObserver:behaviorController];

//	spikeController = [[GRFSpikeController alloc] init];
//    [dataDoc addObserver:spikeController];

    eyeXYController = [[GRFEyeXYController alloc] init];
    [dataDoc addObserver:eyeXYController];

    summaryController = [[GRFSummaryController alloc] init];
    [dataDoc addObserver:summaryController];
 
	xtController = [[GRFXTController alloc] init];
    [dataDoc addObserver:xtController];

// Set up data events (after setting up windows to receive them)

	[dataDoc defineEvents:[LLStandardDataEvents eventsWithDataDefs] count:[LLStandardDataEvents countOfEventsWithDataDefs]];
	[dataDoc defineEvents:GRFEvents count:(sizeof(GRFEvents) / sizeof(EventDefinition))];
	announceEvents();
	longValue = 0;
	[[task dataDoc] putEvent:@"reset" withData:&longValue];
	

// Set up the data collector to handle our data types

    [dataController assignSampleData:eyeRXDataAssignment];
	[dataController assignSampleData:eyeRYDataAssignment];
	[dataController assignSampleData:eyeRPDataAssignment];
	[dataController assignSampleData:eyeLXDataAssignment];
	[dataController assignSampleData:eyeLYDataAssignment];
	[dataController assignSampleData:eyeLPDataAssignment];
    
	[dataController assignTimestampData:spike0Assignment];
	[dataController assignTimestampData:spike1Assignment];
	[dataController assignTimestampData:VBLDataAssignment];
	[dataController assignDigitalInputDevice:@"Synthetic"];
	[dataController assignDigitalOutputDevice:@"Synthetic"];
    
    
	collectorTimer = [NSTimer scheduledTimerWithTimeInterval:0.004 target:self
			selector:@selector(dataCollect:) userInfo:nil repeats:YES];
	[dataDoc addObserver:stateSystem];
    [stateSystem startWithCheckIntervalMS:5];				// Start the experiment state system
	
	active = YES;
}

// The following function is called after the nib has finished loading.  It is the correct
// place to initialize nib related components, such as menus.

- (void)awakeFromNib;
{
	if (actionsMenuItem == nil) {
		actionsMenuItem = [[NSMenuItem alloc] init]; 
		[actionsMenu setTitle:@"Actions"];
		[actionsMenuItem setSubmenu:actionsMenu];
		[actionsMenuItem setEnabled:YES];
	}
	if (settingsMenuItem == nil) {
		settingsMenuItem = [[NSMenuItem alloc] init]; 
		[settingsMenu setTitle:@"Settings"];
		[settingsMenuItem setSubmenu:settingsMenu];
		[settingsMenuItem setEnabled:YES];
	}
}

- (void)dataCollect:(NSTimer *)timer;
{
    long spikeIndex, spikes;
    short *spikePtr;
	NSData *data;
    TimestampData spikeData;

//	if ((data = [dataController dataOfType:@"eyeXData"]) != nil) {
//		[dataDoc putEvent:@"eyeXData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
//		currentEyeUnits.x = *(short *)([data bytes] + [data length] - sizeof(short));
//	}
//	if ((data = [dataController dataOfType:@"eyeYData"]) != nil) {
//		[dataDoc putEvent:@"eyeYData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
//		currentEyeUnits.y = *(short *)([data bytes] + [data length] - sizeof(short));
//		currentEyeDeg = [eyeCalibrator degPointFromUnitPoint:currentEyeUnits];
//	}
    
    if ((data = [dataController dataOfType:@"eyeLXData"]) != nil) {
		[dataDoc putEvent:@"eyeLXData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
		currentEyesUnits[kLeftEye].x = *(short *)([data bytes] + [data length] - sizeof(short));
	}
    
	if ((data = [dataController dataOfType:@"eyeLYData"]) != nil) {
        [dataDoc putEvent:@"eyeLYData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
		currentEyesUnits[kLeftEye].y = *(short *)([data bytes] + [data length] - sizeof(short));
        currentEyesDeg[kLeftEye] = [eyeCalibrator degPointFromUnitPoint: currentEyesUnits[kLeftEye] forEye:kLeftEye];
        }
	if ((data = [dataController dataOfType:@"eyeLPData"]) != nil) {
		[dataDoc putEvent:@"eyeLPData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
	}
	if ((data = [dataController dataOfType:@"eyeRXData"]) != nil) {
		[dataDoc putEvent:@"eyeRXData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
		currentEyesUnits[kRightEye].x = *(short *)([data bytes] + [data length] - sizeof(short));
	}
	if ((data = [dataController dataOfType:@"eyeRYData"]) != nil) {
		[dataDoc putEvent:@"eyeRYData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
		currentEyesUnits[kRightEye].y = *(short *)([data bytes] + [data length] - sizeof(short));
		currentEyesDeg[kRightEye] = [eyeCalibrator degPointFromUnitPoint: currentEyesUnits[kRightEye] forEye:kRightEye];	}
	if ((data = [dataController dataOfType:@"eyeRPData"]) != nil) {
		[dataDoc putEvent:@"eyeRPData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
	}

    
    
	if ((data = [dataController dataOfType:@"VBLData"]) != nil) {
		[dataDoc putEvent:@"VBLData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
	}
	if ((data = [dataController dataOfType:@"spike0"]) != nil) {
        spikeData.channel = 0;
        spikes = [data length] / sizeof(short);
        spikePtr = (short *)[data bytes];
        for (spikeIndex = 0; spikeIndex < spikes; spikeIndex++) {
            spikeData.time = *spikePtr++;
            [dataDoc putEvent:@"spike" withData:(Ptr)&spikeData];
        }
	}
	if ((data = [dataController dataOfType:@"spike1"]) != nil) {
        spikeData.channel = 1;
        spikes = [data length] / sizeof(short);
        spikePtr = (short *)[data bytes];
        for (spikeIndex = 0; spikeIndex < spikes; spikeIndex++) {
            spikeData.time = *spikePtr++;
            [dataDoc putEvent:@"spike" withData:(Ptr)&spikeData];
        }
	}
}
	
// Stop data collection and shut down the plug in

- (void)deactivate:(id)sender;
{
	if (!active) {
		return;
	}
    [dataController setDataEnabled:[NSNumber numberWithBool:NO]];
    [stateSystem stop];
	[collectorTimer invalidate];
    [dataDoc removeObserver:stateSystem];
    [dataDoc removeObserver:behaviorController];
    [dataDoc removeObserver:spikeController];
    [dataDoc removeObserver:eyeXYController];
    [dataDoc removeObserver:summaryController];
    [dataDoc removeObserver:xtController];
	[dataDoc clearEventDefinitions];

// Remove Actions and Settings menus from menu bar
	 
	[[NSApp mainMenu] removeItem:settingsMenuItem];
	[[NSApp mainMenu] removeItem:actionsMenuItem];

// Release all the display windows

    [behaviorController close];
    [behaviorController release];
    [spikeController close];
    [spikeController release];
    [eyeXYController deactivate];			// requires a special call
    [eyeXYController release];
    [summaryController close];
    [summaryController release];
    [xtController close];
    [xtController release];
	[[controlPanel window] close];
	
	active = NO;
}

- (void)dealloc;
{
	long index;
 
	while ([stateSystem running]) {};		// wait for state system to stop, then release it
	
	for (index = 0; keyPaths[index] != nil; index++) {
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:keyPaths[index]];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 

    [[task dataDoc] removeObserver:stateSystem];
    [stateSystem release];
	
	[actionsMenuItem release];
	[settingsMenuItem release];
	[scheduler release];
	[stimuli release];
	[mapStimTable0 release];
	[mapStimTable1 release];
	[digitalOut release];
	[controlPanel release];
	[taskStatus release];
    [topLevelObjects release];
	[super dealloc];
}

- (void)doControls:(NSNotification *)notification;
{
	if ([[notification name] isEqualToString:LLTaskModeButtonKey]) {
		[self doRunStop:self];
	}
	else if ([[notification name] isEqualToString:LLJuiceButtonKey]) {
		[self doJuice:self];
	}
	if ([[notification name] isEqualToString:LLResetButtonKey]) {
		[self doReset:self];
	}
}

- (IBAction)doFixSettings:(id)sender;
{
	[stimuli doFixSettings];
}

- (IBAction)doJuice:(id)sender;
{
	long juiceMS, rewardSchedule;
	long minTargetMS, maxTargetMS;
	long minRewardMS, maxRewardMS;
	long targetOnTimeMS;
	float alpha, beta;
	BOOL useSingleITC18;
    
	NSSound *juiceSound;
	
	if ([sender respondsToSelector:@selector(juiceMS)]) {
		juiceMS = (long)[sender performSelector:@selector(juiceMS)];
	}
	else {
		juiceMS = [[task defaults] integerForKey:GRFRewardMSKey];
	}

	rewardSchedule = [[task defaults] integerForKey:GRFRewardScheduleKey];

	if (rewardSchedule == kRewardVariable) {
		minTargetMS = [[task defaults] integerForKey:GRFMinTargetMSKey];
		maxTargetMS = [[task defaults] integerForKey:GRFMaxTargetMSKey];
		
		minRewardMS = [[task defaults] integerForKey:GRFMinRewardMSKey];;
		maxRewardMS = juiceMS * 2 - minRewardMS;
		
		alpha = (float)(minRewardMS - maxRewardMS) / (float)(minTargetMS - maxTargetMS);
		beta = minRewardMS - alpha * minTargetMS;
		targetOnTimeMS = trial.targetOnTimeMS;
		juiceMS = alpha * targetOnTimeMS + beta;
		juiceMS = abs(juiceMS);
	}
    
    useSingleITC18 = [[task defaults] boolForKey:GRFUseSingleITC18Key];
    
    if (useSingleITC18) {
        [[task dataController] digitalOutputBits:(0xffff-kRewardBit)];      // Works as long as kRewardBit is either 0x0001 or 0x0000
    }
    else {
        [[task dataController] digitalOutputBitsOff:kRewardBit];
    }
	
    [scheduler schedule:@selector(doJuiceOff) toTarget:self withObject:nil delayMS:juiceMS];
	if ([[task defaults] boolForKey:GRFDoSoundsKey]) {
		juiceSound = [NSSound soundNamed:@"Correct"];
		if ([juiceSound isPlaying]) {   // won't play again if it's still playing
			[juiceSound stop];
		}
		[juiceSound play];			// play juice sound
	}
}

- (void)doJuiceOff;
{
    BOOL useSingleITC18;
    useSingleITC18 = [[task defaults] boolForKey:GRFUseSingleITC18Key];
    
    if (useSingleITC18) {
        [[task dataController] digitalOutputBits:(0xfffe | kRewardBit)];    // Works as long as kRewardBit is either 0x0001 or 0x0000
    }
    else {
        [[task dataController] digitalOutputBitsOn:kRewardBit];
    }
}

- (IBAction)doReset:(id)sender;
{
    requestReset();
}

- (IBAction)doRFMap:(id)sender;
{
	[host performSelector:@selector(switchToTaskWithName:) withObject:@"RFMap"];
}

- (IBAction)doRunStop:(id)sender;
{
	long newMode;
	
    switch ([taskStatus mode]) {
    case kTaskIdle:
		newMode = kTaskRunning;
        break;
    case kTaskRunning:
		newMode = kTaskStopping;
        break;
    case kTaskStopping:
    default:
		newMode = kTaskIdle;
        break;
    }
	[self setMode:newMode];
}

- (IBAction)doTaskGaborSettings:(id)sender;
{
	[stimuli doGabor0Settings];
}

// After our -init is called, the host will provide essential pointers such as
// defaults, stimWindow, eyeCalibrator, etc.  Only aMSer those are initialized, the
// following method will be called.  We therefore defer most of our initialization here

- (void)initializationDidFinish;
{
	long index;
	NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
	
	extern long argRand;
	
	task = self;
	
// Register our default settings. This should be done first thing, before the
// nib is loaded, because items in the nib are linked to defaults

	userDefaultsValuesPath = [[NSBundle bundleForClass:[self class]] 
						pathForResource:@"UserDefaults" ofType:@"plist"];
	userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[[task defaults] registerDefaults:userDefaultsValuesDict];
	[NSValueTransformer 
			setValueTransformer:[[[LLFactorToOctaveStepTransformer alloc] init] autorelease]
			forName:@"FactorToOctaveStepTransformer"];

	[NSValueTransformer 
			setValueTransformer:[[[GRFRoundToStimCycle alloc] init] autorelease]
			forName:@"RoundToStimCycle"];


// Set up to respond to changes to the values

	for (index = 0; keyPaths[index] != nil; index++) {
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:keyPaths[index]
				options:NSKeyValueObservingOptionNew context:nil];
	}
		
// Set up the task mode object.  We need to do this before loading the nib,
// because some items in the nib are bound to the task mode. We also need
// to set the mode, because the value in defaults will be the last entry made
// which is typically kTaskEnding.

	taskStatus = [[LLTaskStatus alloc] init];
	stimuli = [[GRFStimuli alloc] init];
	digitalOut = [[GRFDigitalOut alloc] init];

// Load the items in the nib

	[[NSBundle bundleForClass:[self class]] loadNibNamed:@"GaborRFMap" owner:self topLevelObjects:&topLevelObjects];
	[topLevelObjects retain];
	
// Initialize other task objects

	scheduler = [[LLScheduleController alloc] init];
	stateSystem = [[GRFStateSystem alloc] init];

// Set up control panel and observer for control panel

	controlPanel = [[LLControlPanel alloc] init];
	[controlPanel setWindowFrameAutosaveName:@"GRFControlPanel"];
	[[controlPanel window] setFrameUsingName:@"GRFControlPanel"];
	[[controlPanel window] setTitle:@"GaborRFMap"];
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(doControls:) name:nil object:controlPanel];
	
// initilize arg for randUnitInterval()
	srand(time(nil));
	argRand = -1 * abs(rand());
}

- (long)mode;
{
	return [taskStatus mode];
}

- (NSString *)name;
{
	return @"GaborRFMap";
}

// The release notes for 10.3 say that the options for addObserver are ignore
// (http://developer.apple.com/releasenotes/Cocoa/AppKit.html).   This means that the change dictionary
// will not contain the new values of the change.  For now it must be read directly from the model

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	static BOOL tested = NO;
	NSString *key;
	id newValue;
	long longValue;
    MapSettings settings;

	if (!tested) {
		newValue = [change objectForKey:NSKeyValueChangeNewKey];
		if (![[newValue className] isEqualTo:@"NSNull"]) {
			NSLog(@"NSKeyValueChangeNewKey is not NSNull, JHRM needs to change how values are accessed");
		}
		tested = YES;
	}
	key = [keyPath pathExtension];
	if ([key isEqualTo:GRFStimTablesKey] || [key isEqualTo:GRFStimTableCountsKey]) {
		[mapStimTable0 updateBlockParameters];
		settings = [mapStimTable0 mapSettings];
		[dataDoc putEvent:@"map0Settings" withData:&settings];
		[mapStimTable1 updateBlockParameters];
		settings = [mapStimTable1 mapSettings];
		[dataDoc putEvent:@"map1Settings" withData:&settings];
		requestReset();
	}
	else if ([key isEqualTo:GRFRespTimeMSKey]) {
		longValue = [defaults integerForKey:GRFRespTimeMSKey];
		[dataDoc putEvent:@"responseTimeMS" withData:&longValue];
	}
	else if ([key isEqualTo:GRFMapStimDurationMSKey]) {
		longValue = [defaults integerForKey:GRFMapStimDurationMSKey];
		[dataDoc putEvent:@"mapStimDurationMS" withData:&longValue];
		requestReset();
	}
	else if ([key isEqualTo:GRFMapInterstimDurationMSKey]) {
		longValue = [defaults integerForKey:GRFMapInterstimDurationMSKey];
		[dataDoc putEvent:@"mapInterstimDurationMS" withData:&longValue];
		requestReset();
	}
	else if ([key isEqualTo:GRFStimDurationMSKey]) {
		longValue = [defaults integerForKey:GRFStimDurationMSKey];
		[dataDoc putEvent:@"stimDurationMS" withData:&longValue];
		if ([[task defaults] integerForKey:GRFStimDistributionKey] == kExponential) {
			updateCatchTrialPC();
		}
		requestReset();
	}
	else if ([key isEqualTo:GRFMeanTargetMSKey]) {
		longValue = [defaults integerForKey:GRFMeanTargetMSKey];
		[dataDoc putEvent:@"meanTargetTimeMS" withData:&longValue];
		if ([[task defaults] integerForKey:GRFStimDistributionKey] == kExponential) {
			updateCatchTrialPC();
		}
//		requestReset();
	}
	else if ([key isEqualTo:GRFMaxTargetMSKey]) {
		longValue = [defaults integerForKey:GRFMaxTargetMSKey];
		[dataDoc putEvent:@"maxTargetTimeMS" withData:&longValue];
		if ([[task defaults] integerForKey:GRFStimDistributionKey] == kUniform) {
			longValue = [defaults integerForKey:GRFMinTargetMSKey] +
						([defaults integerForKey:GRFMaxTargetMSKey] - [defaults integerForKey:GRFMinTargetMSKey]) / 2.0;
//			[[task defaults] setInteger: longValue forKey: GRFMeanTargetMSKey];
		}
		else updateCatchTrialPC();
		requestReset();
	}
	else if ([key isEqualTo:GRFMinTargetMSKey]) {
		longValue = [defaults integerForKey:GRFMinTargetMSKey];
		[dataDoc putEvent:@"minTargetTimeMS" withData:&longValue];
		if ([[task defaults] integerForKey:GRFStimDistributionKey] == kUniform) {
			longValue = [defaults integerForKey:GRFMinTargetMSKey] +
						([defaults integerForKey:GRFMaxTargetMSKey] - [defaults integerForKey:GRFMinTargetMSKey]) / 2.0;
//			[[task defaults] setInteger: longValue forKey: GRFMeanTargetMSKey];
		}
		else updateCatchTrialPC();
		requestReset();
	}
	else if ([key isEqualTo:GRFInterstimMSKey]) {
		longValue = [defaults integerForKey:GRFInterstimMSKey];
		[dataDoc putEvent:@"interstimMS" withData:&longValue];
		if ([[task defaults] integerForKey:GRFStimDistributionKey] == kExponential) {
			updateCatchTrialPC();
		}
		requestReset();
	}
	else if ([key isEqualTo:GRFOrientationChangesKey] || [key isEqualTo:GRFMaxDirChangeDegKey] ||
				[key isEqualTo:GRFMinDirChangeDegKey] || [key isEqualTo:GRFChangeScaleKey]) {
		[self updateChangeTable];
	}
	else if ([key isEqualTo:GRFChangeArrayKey]) {
		updateBlockStatus();
		[[task dataDoc] putEvent:@"blockStatus" withData:&blockStatus];
	}
	else if ([key isEqualTo:GRFMappingBlocksKey]) {
		mappingBlockStatus.blockLimit = [[task defaults] integerForKey:GRFMappingBlocksKey];
		[[task dataDoc] putEvent:@"mappingBlockStatus" withData:&mappingBlockStatus];
	}
	else if ([key isEqualTo:GRFFixateMSKey]) {
		longValue = [defaults integerForKey:GRFFixateMSKey];
		[[task dataDoc] putEvent:@"fixateMS" withData:&longValue];
	}
	else if ([key isEqualTo:GRFStimRepsPerBlockKey]) {
		longValue = [defaults integerForKey:GRFOrientationChangesKey];
		[dataDoc putEvent:@"stimRepsPerBlock" withData:&longValue];
	}
    else if ([key isEqualTo:GRFMapStimContrastPCKey])	{
		[stimuli clearStimLists:&trial];
		//[stimuli makeStimLists:&trial];
	}
    else if ([key isEqualTo:GRFHideTaskGaborKey]) {
        [[task defaults] setBool:YES forKey:GRFIncludeCatchTrialsinDoneListKey];
        [[task defaults] setInteger:100 forKey:GRFCatchTrialPCKey];
    }
    else if ([key isEqualTo:GRFHideLeftKey]) {
        [[task defaults] setBool:YES forKey:GRFHideLeftDigitalKey];
    }
    else if ([key isEqualTo:GRFHideRightKey]) {
        [[task defaults] setBool:YES forKey:GRFHideRightDigitalKey];
    }
}

- (DisplayModeParam)requestedDisplayMode;
{
	displayMode.widthPix = 1280; //1024;
	displayMode.heightPix = 720; //768;
	displayMode.pixelBits = 32;
	displayMode.frameRateHz = 100;
	return displayMode;
}

- (void)setMode:(long)newMode;
{
	[taskStatus setMode:newMode];
	[defaults setInteger:[taskStatus status] forKey:GRFTaskStatusKey];
	[controlPanel setTaskMode:[taskStatus mode]];
	[dataDoc putEvent:@"taskMode" withData:&newMode];
	switch ([taskStatus mode]) {
	case kTaskRunning:
	case kTaskStopping:
		[runStopMenuItem setKeyEquivalent:@"."];
		break;
	case kTaskIdle:
		[runStopMenuItem setKeyEquivalent:@"r"];
		break;
	default:
		break;
	}
}
// Respond to changes in the stimulus settings

- (void)setWritingDataFile:(BOOL)state;
{
	if ([taskStatus dataFileOpen] != state) {
		[taskStatus setDataFileOpen:state];
		[defaults setInteger:[taskStatus status] forKey:GRFTaskStatusKey];
		if ([taskStatus dataFileOpen]) {
			announceEvents();
			[controlPanel displayFileName:[[[dataDoc filePath] lastPathComponent] 
												stringByDeletingPathExtension]];
			[controlPanel setResetButtonEnabled:NO];
		}
		else {
			[controlPanel displayFileName:@""];
			[controlPanel setResetButtonEnabled:YES];
		}
	}
}

- (GRFStimuli *)stimuli;
{
	return stimuli;
}

- (GRFMapStimTable *)mapStimTable0
{
	return mapStimTable0;
}

- (GRFMapStimTable *)mapStimTable1
{
	return mapStimTable1;
}

// The change table (array) contains information about what changes will be tested and
// how often each change will be tested in the valid and invalid mode in each block

- (void)updateChangeTable;
{
	long index, changes, oldChanges;
	long changeScale;
	float minChange, maxChange;
	float logMinChange, logMaxChange;
	float newValue;
	NSMutableArray *changeArray;
	NSMutableDictionary *changeEntry;

	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.GRFChangeArray"];
	changeArray = [NSMutableArray arrayWithArray:[defaults arrayForKey:GRFChangeArrayKey]];
	oldChanges = [changeArray count];
	changes = [defaults integerForKey:GRFOrientationChangesKey];

	if (oldChanges > changes) {
		[changeArray removeObjectsInRange:NSMakeRange(changes, oldChanges - changes)];
	}
	else if (changes > oldChanges) {
		changeEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithFloat:10.0], GRFChangeKey,
				[NSNumber numberWithLong:1], GRFValidRepsKey,
				[NSNumber numberWithLong:0], GRFInvalidRepsKey,
				nil];
		for (index = oldChanges; index < changes; index++) {
			[changeArray addObject:changeEntry];
		}
	}
	changeScale = [defaults integerForKey:GRFChangeScaleKey];
	minChange = [defaults floatForKey:GRFMinDirChangeDegKey];
	maxChange = [defaults floatForKey:GRFMaxDirChangeDegKey];
	logMinChange = log(minChange);
	logMaxChange = log(maxChange);
	for (index = 0; index < changes; index++) {
		if (changes <= 1) {
			newValue = minChange;
		}
		else if (changeScale == kLogarithmic) {
            newValue = exp(logMinChange + index * (logMaxChange - logMinChange) / (changes - 1));
        }
        else {
            newValue = minChange + index * (maxChange - minChange) / (changes - 1);
        }
		changeEntry = [NSMutableDictionary dictionaryWithCapacity:1];
		[changeEntry setDictionary:[changeArray objectAtIndex:index]];
		[changeEntry setObject:[NSNumber numberWithFloat:newValue] forKey:GRFChangeKey];
		[changeArray replaceObjectAtIndex:index withObject:changeEntry];
	}

	[defaults setObject:changeArray forKey:GRFChangeArrayKey];
	updateBlockStatus();
	[[task dataDoc] putEvent:@"blockStatus" withData:&blockStatus];
	requestReset();
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.GRFChangeArray"
				options:NSKeyValueObservingOptionNew context:nil];

}

@end
