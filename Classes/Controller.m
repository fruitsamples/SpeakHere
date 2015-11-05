/*
File: Controller.m
Abstract: This file is included for support purposes and isn't necessary for
understanding this sample.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

//
//  Controller.m
//  SimpleTouchRecorder
//
//  Created by Murray Jason on 5/1/08.
//  Copyright 2008 Apple. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#import "AudioQueueObject.h"
#import "Controller.h"

@implementation Controller

@synthesize audioPlayer;				// the playback audio queue object
@synthesize audioRecorder;				// the recording audio queue object
@synthesize soundFileURL;				// the sound file to record to and to play back
@synthesize playOrStopButton;			// the play button, which toggles to display "stop"
@synthesize recordOrStopButton;			// the record button, which toggles to display "stop"

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil {

	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];

	if (self != nil) {
	
		// this app uses a fixed file name at a fixed location, so it makes sense to set the name and 
		// URL here.
		CFStringRef fileString = (CFStringRef) [NSString stringWithFormat: @"%@/Recording.caf", [[NSBundle mainBundle] bundlePath]];

		// create a file URL that identifies a file for a recording audio queue to record into
		CFURLRef fileURL =	CFURLCreateWithFileSystemPath (
								NULL,
								fileString,
								kCFURLPOSIXPathStyle,
								false
							);
		NSLog (@"Recorded file path: %@", fileURL); // shows the location of the recorded file
		
		// save the sound file URL as an object attribute (as an NSURL object)
		if (fileURL) {
			self.soundFileURL	= (NSURL *) fileURL;
			CFRelease (fileURL);
		}
	}
	return self;
}

// this method gets called (by property listener callback functions) when a recording or playback 
// audio queue object starts or stops. 
- (void) updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue {
	NSLog (@"updateUserInterfaceOnAudioQueueStateChange just called.");

	// the audio queue (playback or record) just started
	if ([inQueue isRunning]) {
	
		// playback just started
		if (inQueue == self.audioPlayer) {
			NSLog (@"playback just started.");
			[self.playOrStopButton setSelected: YES];
			[self.recordOrStopButton setEnabled: NO];
			[self.playOrStopButton setTitle: @"Stop" forState: UIControlStateHighlighted];

		// recording just started
		} else if (inQueue == self.audioRecorder) {
			NSLog (@"recording just started.");
			[self.recordOrStopButton setSelected: YES];
			[self.playOrStopButton setEnabled: NO];
			NSLog (@"setting Record button title to Stop.");
			[self.recordOrStopButton setTitle: @"Stop" forState: UIControlStateHighlighted];
			
		}
	// the audio queue (playback or record) just stopped
	} else {

		// playback just stopped
		if (inQueue == self.audioPlayer) {
			NSLog (@"playback just stopped.");
			[self.playOrStopButton setSelected: NO];
			[self.recordOrStopButton setEnabled: YES];
			[self.playOrStopButton setTitle: @"Play" forState: UIControlStateHighlighted];

			[audioPlayer release];
			audioPlayer = nil;

		// recording just stopped
		} else if (inQueue == self.audioRecorder) {
			NSLog (@"recording just stopped.");
			[self.recordOrStopButton setSelected: NO];
			[self.playOrStopButton setEnabled: YES];
			NSLog (@"setting Record button title to Record.");
			[self.recordOrStopButton setTitle: @"Record" forState: UIControlStateHighlighted];

			[audioRecorder release];
			audioRecorder = nil;
		}
	}
}


// respond to a tap on the Record button. If stopped, start recording. If recording, stop.
// an audio queue object is created for each recording, and destroyed when the recording finishes.
- (IBAction) recordOrStop: (id) sender {

	NSLog (@"recordOrStop:");
	
	// if not recording, start recording
	if (self.audioRecorder == nil) {
		// the first step in recording is to instantiate a recording audio queue object
		AudioRecorder *theRecorder = [[AudioRecorder alloc] initWithURL: self.soundFileURL];

		// if the audio queue was successfully created, initiate recording.
		if (theRecorder) {

			self.audioRecorder = theRecorder;
			[theRecorder release];								// decrements the retain count for the theRecorder object
			
			[self.audioRecorder setNotificationDelegate: self];	// sets up the recorder object to receive property change notifications 
																//	from the recording audio queue object
//			[self.audioRecorder enableMetering: YES];			// sets a property value on the recording audio queue object to enable 
																//	metering (inherited from the AudioQueueObject class)
			NSLog (@"sending record message to recorder object.");
			[self.audioRecorder record];						// starts the recording audio queue object
		}

	// else if recording, stop recording
	} else {
	
		if (self.audioRecorder) {
			[self.audioRecorder setStopping: YES];				// this flag lets the property listener callback
																//	know that the user has tapped Stop
			NSLog (@"sending stop message to recorder object.");
			[self.audioRecorder stop];							// stops the recording audio queue object. the object 
																//	remains in existence until it actually stops, at
																//	which point the property listener callback calls
																//	this class's updateUserInterfaceOnAudioQueueStateChange:
																//	method, which releases the recording object.
		}		
	}
}

// respond to a tap on the Play button. If stopped, start playing. If playing, stop.
- (IBAction) playOrStop: (id) sender {

	NSLog (@"playOrStop:");
	
	// if not playing, start playing
	if (self.audioPlayer == nil) {
	
		AudioPlayer *thePlayer = [[AudioPlayer alloc] initWithURL: self.soundFileURL];
		
		if (thePlayer) {
		
			self.audioPlayer = thePlayer;
			[thePlayer release];								// decrements the retain count for the thePlayer object
			
			[self.audioPlayer setNotificationDelegate: self];	// sets up the playback object to receive property change notifications from the playback audio queue object
//			[thePlayer enableMetering: YES];
			[self.audioPlayer play];
		}
		
	// else if playing, stop playing
	} else {
	
		if (self.audioPlayer) {

			[self.audioPlayer setAudioPlayerShouldStopImmediately: YES];
			[self.audioPlayer stop];
		}
	}  
}



- (void) viewDidLoad {

	[self.recordOrStopButton setTitle: @"Record" forState: UIControlStateHighlighted];
	[self.playOrStopButton setTitle: @"Play" forState: UIControlStateHighlighted];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath: [NSString stringWithFormat: @"%@/Recording.caf", [[NSBundle mainBundle] bundlePath]]] != TRUE) {
		[self.playOrStopButton setEnabled: NO];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview

	// the most likely reason for a memory warning is that the file being recorded is getting
	// too big -- so stop recording.
	if (self.audioRecorder) {
		[self recordOrStop: self];
	}
}



- (void) dealloc {

	[recordOrStopButton release];
	[playOrStopButton release];
	[super dealloc];
}


@end
