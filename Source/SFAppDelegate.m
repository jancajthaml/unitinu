#import "SFAppDelegate.h"
#import "SFDropImageView.h"

@implementation SFAppDelegate

@synthesize imageView = i_imageView;
@synthesize window = i_window;


- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
	[self.window center];
	[self.window makeKeyAndOrderFront:self];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	return YES;
}


- (IBAction)open:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	{
		if ( result == NSFileHandlingPanelOKButton )
		{
			[self.imageView openFileAtPath:[[openPanel URL] path]];
		}
	}];
}


- (IBAction)save:(id)sender
{
	NSSavePanel* savePanel = [NSSavePanel savePanel];
	
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"public.png"]];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setCanSelectHiddenExtension:YES];
	
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) 
	{
		if ( result == NSFileHandlingPanelOKButton )
		{
			[self.imageView savePNGImageToPath:[[savePanel URL] path]];
		}
	}];
}

@end
