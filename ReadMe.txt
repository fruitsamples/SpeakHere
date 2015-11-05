SpeakHere

===========================================================================
DESCRIPTION:

SpeakHere demonstrates basic use of Audio Queue Services, Audio File Services, and Audio Session Services on the iPhone for recording and playing back audio.

The code in SpeakHere uses Audio File Services to create, record into, and read from a CAF (Core Audio Format) audio file containing uncompressed (PCM) audio data. The application uses Audio Queue Services to manage recording and playback. The application also uses Audio Session Services to manage interruptions (as described in Core Audio Overview).

This application shows how to:

	* Set up a monaural linear PCM audio format.
	* Create a Core Audio Format (CAF) audio file and save it to an application's Documents directory.
	* Reuse an existing CAF file by overwriting it.
	* Read from a CAF file for playback.
	* Create and use recording (input) and playback (output) audio queue objects.
	* Define and use audio data and property data callbacks with audio queue objects.
	* Set playback gain for an audio queue object.
	* Stop recording in a way ensures that all audio data gets written to disk.
	* Stop playback when a sound file has finished playing.
	* Stop playback immediately when a user invokes a Stop method.
	* Enable audio level metering in an audio queue object.
	* Get average and peak audio levels from a running audio queue object.
	* Use audio format magic cookies with an audio queue object.
	* Use Core Animation layers to indicate average and peak recording and playback level.
	* Use Audio Session Services to register an interruption callback.
	* Use Audio Session Services to set appropriate audio session categories for recording and playback.
	* Use Audio Session Services to pause playback upon receiving an interruption, and to then resume playback if the interruption ends.
	* Use UIBarButtonItem objects as toggle buttons.

SpeakHere does not demonstrate how to record multiple files, nor does it provide a file picker. It always records into the same file, and plays back only that file.

If SpeakHere receives a memory warning while recording, it stops recording immediately. You can test this in the Simulator using the Hardware > Simulate Memory Warning menu item.


===========================================================================
RELATED INFORMATION:

Core Audio Overview, June 2008


===========================================================================
SPECIAL CONSIDERATIONS:

SpeakHere requires a microphone and so is not appropriate for the iPod touch.


===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.5.4, Xcode 3.1, iPhone OS 2.0


===========================================================================
RUNTIME REQUIREMENTS:

Simulator: Mac OS X v10.5.4
iPhone: iPhone OS 2.0


===========================================================================
PACKAGING LIST:

SpeakHereAppDelegate.h
SpeakHereAppDelegate.m

The SpeakHereAppDelegate class defines the application delegate object, responsible for instantiating the controller object (defined in the AudioViewController class) and adding the application's view to the application window.

AudioViewController.h
AudioViewController.m

The AudioViewController class defines the controller object for the application. The object helps set up the user interface, responds to and manages user interaction, responds to changes in the state of the playback or recording object, handles interruptions to the application's audio session, and handles various housekeeping duties.

AudioQueueObject.h
AudioQueueObject.m

The AudioQueueObject class defines a superclass for playback and recording objects, encapsulating the state and behavior that is common to both.

AudioRecorder.h
AudioRecorder.m

The AudioRecorder class defines a recording object for the application, which in turn employs a recording audio queue object from Audio Queue Services. The AudioRecorder object manages recording, calling Audio File Services to interact with the file system. The class file includes two callback functions. A recording callback is called by the underlying recording audio queue object when a new buffer's worth of audio data is available for writing to the file system. A property listener callback is called by the recording audio queue object when that object starts or stops. Upon receiving the notification, the callback tells the AudioViewController object to update the user interface.

AudioPlayer.h
AudioPlayer.m

The AudioPlayer class defines a playback object for the application, which in turn employs a playback audio queue object from Audio Queue Services. The AudioPlayer object manages playback, calling Audio File Services to interact with the file system. As with the AudioRecorder object, the Audioplayer class file includes two callback functions. A playback callback is called by the underlying playback audio queue object when a just-played buffer is available to fill with additional audio data to be read from disk. A property listener callback is called by the playback audio queue object when that object starts or stops. Upon receiving the notification, the callback tells the AudioViewController object to update the user interface.


===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0. Updated for and tested with iPhone OS 2.0. First public release.


================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.