//
//  GaborRFMap.h
//  GaborRFMap
//
//  Copyright 2006. All rights reserved.
//

#import "GRF.h"
#import "GRFStateSystem.h"
#import "GRFEyeXYController.h"
#import "GRFRoundToStimCycle.h"
#import "GRFDigitalOut.h"
@class GRFMapStimTable;

@interface GaborRFMap:LLTaskPlugIn {

	NSMenuItem				*actionsMenuItem;
    NSWindowController 		*behaviorController;
	LLControlPanel			*controlPanel;
	NSPoint					currentEyesUnits[kEyes];
    GRFEyeXYController		*eyeXYController;				// Eye position display
	NSMenuItem				*settingsMenuItem;
    NSWindowController 		*spikeController;
    NSWindowController 		*summaryController;
	LLTaskStatus			*taskStatus;
    NSArray                 *topLevelObjects;
    NSWindowController 		*xtController;
    LLFilterExp				*xFilter;
    LLFilterExp				*yFilter;
	
	GRFMapStimTable			*mapStimTable0; 
	GRFMapStimTable			*mapStimTable1; 

    IBOutlet NSMenu			*actionsMenu;
    IBOutlet NSMenu			*settingsMenu;
	IBOutlet NSMenuItem		*runStopMenuItem;
}

- (IBAction)doFixSettings:(id)sender;
- (IBAction)doJuice:(id)sender;
- (void)doJuiceOff;
- (IBAction)doReset:(id)sender;
- (IBAction)doRFMap:(id)sender;
- (IBAction)doRunStop:(id)sender;
- (IBAction)doTaskGaborSettings:(id)sender;
- (GRFStimuli *)stimuli;
- (GRFMapStimTable *)mapStimTable0;
- (GRFMapStimTable *)mapStimTable1;
- (void)updateChangeTable;

@end
