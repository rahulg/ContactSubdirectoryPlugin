//
//  RAGContactDirectoryPlugin.m
//  RAGContactDirectoryPlugin
//
//  Created by Rahul AG on 11/10/09.
//  Copyright 2009 Rahul AG
//  Some portions of code are copyright of Henrik Nyh and Dustin Brewer
//
//  This work ‘as-is’ we provide.
//  No warranty, express or implied.
//  We’ve done our best,
//  to debug and test.
//  Liability for damages denied.
//
//  Permission is granted hereby,
//  to copy, share, and modify.
//  Use as is fit,
//  free or for profit.
//  On this notice these rights rely.
//

#import "RAGContactDirectoryPlugin.h"


@implementation RAGContactDirectoryPlugin

/*  Plugin Information Methods  */

- (NSString *)pluginAuthor {
	return @"Rahul AG";
}

- (NSString *)pluginVersion {
	return @"2.0";
}

- (NSString *)pluginDescription {
	return @"Places received files in a subdirectory for each sender";
}

- (NSString *)pluginURL {
	return @"";
}

/*  Standard Plugin Methods  */

- (void)installPlugin {
	
	AILog(@"(RAGCttDir): Plugin Loaded");
	
	// Register plugin
	[[adium notificationCenter] addObserver:self
								   selector:@selector(redirectFile:)
									   name:FILE_TRANSFER_BEGAN
									 object:nil];
	
	// Load folder naming preference
	useDisplayName = [[[adium preferenceController] preferenceForKey:@"RAGCDUseDisplayName"
															   group:@"RAGContactDirectory"] boolValue];
	// Set up menu item
	toggleDisplayNameMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Display Name in Download Subfolder"
																					 target:self
																					 action:@selector(toggleDisplayNameInFolder:)
																			  keyEquivalent:@""];
	[toggleDisplayNameMenuItem setState:(useDisplayName ? NSOnState : NSOffState)];
	[[adium menuController] addMenuItem:toggleDisplayNameMenuItem toLocation:LOC_Edit_Additions];
	
}

- (void)uninstallPlugin {
	
	[toggleDisplayNameMenuItem release];
	[[adium notificationCenter] removeObserver:self];
	AILog(@"(RAGCttDir): Plugin Unloaded");
	
}

/*  Helper Methods  */

- (void)redirectFile:(NSNotification *)notification {

	ESFileTransfer *currentFileTransfer = (ESFileTransfer *)[notification userInfo];
	NSString *desiredSubdirectoryName, *fsObjectToTest;
	BOOL UIDMatch, isDirectory;
	
	// Obtain information about the sender
	NSString *userID = [[currentFileTransfer contact] formattedUID];
	NSString *displayName = [[currentFileTransfer contact] displayName];
	
	// Generate desired subfolder name
	if (useDisplayName) {
		desiredSubdirectoryName = [NSString stringWithFormat:@"%@ (%@)", displayName, userID];
	} else {
		desiredSubdirectoryName = [NSString stringWithFormat:@"%@", userID];
	}
	// Clean up any unwanted characters
	desiredSubdirectoryName = [desiredSubdirectoryName safeFilenameString];
	
	// We will want to re-uniqueify the file name later, so we may ignore whatever's been done already
	NSString *destinationFile = [currentFileTransfer remoteFilename];
	
	// We will only redirect downloads if they're heading to the default folder
	NSString *destinationDirectory = [[currentFileTransfer localFilename] stringByDeletingLastPathComponent];
	NSString *defaultDirectory = [[adium preferenceController] userPreferredDownloadFolder];
	if (![destinationDirectory isEqualToString:defaultDirectory]) {
		return;
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Find and use existing directory, if it exists
	NSDirectoryEnumerator *directoryEnum = [fileManager enumeratorAtPath:defaultDirectory];
	for (fsObjectToTest in directoryEnum) {
		
		UIDMatch = [fsObjectToTest isEqualToString:userID] || [fsObjectToTest hasSuffix:[NSString stringWithFormat:@" (%@)", userID]];
		[fileManager fileExistsAtPath:[defaultDirectory stringByAppendingPathComponent:fsObjectToTest] isDirectory:&isDirectory];
		if (UIDMatch && isDirectory) {
			desiredSubdirectoryName = fsObjectToTest;
			break;
		}
		
	}
	
	// Create subdirectory if it doesn't exist
	NSString *targetSubdirectory = [defaultDirectory stringByAppendingPathComponent:desiredSubdirectoryName];
	if (![fileManager fileExistsAtPath:targetSubdirectory]) {
		[fileManager createDirectoryAtPath:targetSubdirectory attributes:nil];
	}
	
	// Change file destination
	NSString *targetPath = [fileManager uniquePathForPath:[targetSubdirectory stringByAppendingPathComponent:destinationFile]];
	[currentFileTransfer setLocalFilename:targetPath];
	
	AILog(@"(RAGCttDir): FILE[%@] FROM[%@] REDIR.TO[%@]", destinationFile, (useDisplayName ? displayName : userID), targetPath);
	
}

- (void)toggleDisplayNameInFolder:(id)sender {
	
	useDisplayName = useDisplayName ? NO : YES;
	[[adium preferenceController] setPreference:[NSNumber numberWithBool:useDisplayName] forKey:@"RAGCDUseDisplayName" group:@"RAGContactDirectory"];
	[toggleDisplayNameMenuItem setState:(useDisplayName ? NSOnState : NSOffState)];
	
}

/*  I have no idea what this does, but Dustin had it in his code  */

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	return YES;
}

@end
