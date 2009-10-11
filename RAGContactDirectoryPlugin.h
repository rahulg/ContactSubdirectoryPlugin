//
//  RAGContactDirectoryPlugin.h
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

#import <Cocoa/Cocoa.h>

#import <Adium/AIPlugin.h>
#import <Adium/AISharedAdium.h>
#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/AIMenuControllerProtocol.h>
#import <Adium/ESFileTransfer.h>
#import <Adium/ESDebugAILog.h>

#import <AIUtilities/AIMenuAdditions.h>
#import <AIUtilities/AIFileManagerAdditions.h>
#import <AIUtilities/AIStringAdditions.h>


@interface RAGContactDirectoryPlugin : AIPlugin {

	BOOL useDisplayName;
	NSMenuItem *toggleDisplayNameMenuItem;

}

@end
