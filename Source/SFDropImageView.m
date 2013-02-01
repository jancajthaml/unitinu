#import "SFDropImageView.h"

#define kMirrorLeft 0
#define kMirrorRight 1


@interface SFDropImageView ()

- (void)savePNGImageToPath:(NSString*)path;
- (void)startDragWithEvent:(NSEvent*)e;
- (BOOL)updateImage;
- (NSImage*)welcomeImage;

@end


@implementation SFDropImageView

@synthesize flipSidesButton = i_flipSidesButton;
@synthesize centerPointSlider = i_centerPointSlider;


- (void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	[self setImage:[self welcomeImage]];
}


- (IBAction)changeCenterPoint:(id)sender
{
	centerAdjust = [sender floatValue];
	[self updateImage];
}


- (IBAction)changeMode:(id)sender
{
	mode = !mode;

	float newPos = 0.0;

	[self.centerPointSlider setFloatValue:newPos];
	centerAdjust = newPos;

	[self updateImage];
}


- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
	[self setNeedsDisplay:YES];
}


- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	if ( ([sender draggingSourceOperationMask] & NSDragOperationCopy) == NSDragOperationCopy ) 
	{
		return NSDragOperationCopy;
	}

	return NSDragOperationNone;
}


- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationCopy;
}


- (void)mouseDown:(NSEvent*)e
{
	[self startDragWithEvent:e];
}


- (NSArray*)namesOfPromisedFilesDroppedAtDestination:(NSURL*)destination
{
	NSString* filename = L(@"image.png");
	
	NSString* path = [[[NSMutableString alloc] initWithString:[destination path]] autorelease];
	path = [path stringByAppendingPathComponent:filename];
	
	[self savePNGImageToPath:path];

	return [NSArray arrayWithObject:filename];
}


- (BOOL)openFileAtPath:(NSString*)path
{
	[imageData release];
	imageData = [[NSData alloc] initWithContentsOfFile:path];

	[imageRep release];
	imageRep = nil;
	
	if ( imageData )
	{
		[self.centerPointSlider setEnabled:YES];
		[self.flipSidesButton setEnabled:YES];
	}
	
	float newPos = 0.0;

	[self.centerPointSlider setFloatValue:newPos];
	centerAdjust = newPos;
	
	return [self updateImage];
}


- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	NSPasteboard* pb = [sender draggingPasteboard];
	NSArray* filenames = [pb propertyListForType:NSFilenamesPboardType];
	
	if ( filenames && [filenames count] > 0 )
	{
		NSString* path = [filenames objectAtIndex:0];
		
		return [self openFileAtPath:path];
	}
	
	return NO;
}


- (void)savePNGImageToPath:(NSString*)path
{
	NSImage* image = [self image];
	
	[image lockFocus];
	NSBitmapImageRep* bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, [image size].width, [image size].height)];
	[image unlockFocus];

	NSData* data = [bitmapRep representationUsingType:NSPNGFileType properties:nil];

	[data writeToFile:path atomically:YES];
	[bitmapRep release];
}


- (void)startDragWithEvent:(NSEvent*)e
{
    NSPoint dragPosition;
    NSRect imageLocation;

    dragPosition = [self convertPoint:[e locationInWindow] fromView:nil];
    dragPosition.x -= 16;
    dragPosition.y -= 16;

    imageLocation.origin = dragPosition;
    imageLocation.size = NSMakeSize(32, 32);

    [self dragPromisedFilesOfTypes:[NSArray arrayWithObject:@"png"] fromRect:imageLocation source:self slideBack:YES event:e];
}


- (BOOL)updateImage
{
	if ( !imageData )
		return NO;
		
	if ( !imageRep )
		imageRep = [[NSBitmapImageRep alloc] initWithData:imageData];
	
	if ( !imageRep )
		return NO;
		
	NSSize repSize = NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
	float halfWidth = floor(repSize.width / 2.0);
	
	NSImage* originalImage = [[[NSImage alloc] initWithSize:repSize] autorelease];
	[originalImage addRepresentation:imageRep];
	
	NSImage* mirroredImage = [[[NSImage alloc] initWithSize:repSize] autorelease];
	[mirroredImage lockFocus];
	
	//NSLog(@"%f", centerAdjust);
	
	if ( mode == kMirrorLeft )
	{
		// A mirror image of the left side is copied to the right
		
		NSRect fromRect = NSMakeRect(halfWidth * centerAdjust, 0, repSize.width - halfWidth, repSize.height);
	 
		[originalImage drawAtPoint:NSZeroPoint fromRect:fromRect operation:NSCompositeCopy fraction:1.0];

		NSAffineTransform *t = [NSAffineTransform transform];
		[t scaleXBy:-1.0 yBy:1.0];
		[t translateXBy:-repSize.width yBy:0];

		[NSGraphicsContext saveGraphicsState];
		
		[t concat];
		[originalImage drawAtPoint:NSZeroPoint fromRect:fromRect operation:NSCompositeCopy fraction:1.0];
		
		[NSGraphicsContext restoreGraphicsState];
	}
	else
	{		
		// A mirror image of the right side is copied to the left

		NSRect fromRect = NSMakeRect(halfWidth + (halfWidth * centerAdjust), 0, halfWidth, repSize.height);
		NSPoint centerPoint = NSMakePoint(halfWidth, 0);
		
		[originalImage drawAtPoint:centerPoint fromRect:fromRect operation:NSCompositeCopy fraction:1.0];

		NSAffineTransform *t = [NSAffineTransform transform];
		[t scaleXBy:-1.0 yBy:1.0];
		[t translateXBy:-repSize.width yBy:0];

		[NSGraphicsContext saveGraphicsState];
		
		[t concat];
		
		fromRect = NSMakeRect(halfWidth - (halfWidth * -centerAdjust), 0, halfWidth, repSize.height);
		centerPoint = NSMakePoint(halfWidth, 0);
		[originalImage drawAtPoint:centerPoint fromRect:fromRect operation:NSCompositeCopy fraction:1.0];
		
		[NSGraphicsContext restoreGraphicsState];
	}
	
	[mirroredImage unlockFocus];	
	
	[self setImage:mirroredImage];
	
	return YES;
}


- (NSImage*)welcomeImage
{
	NSImage* image = [[[NSImage alloc] initWithSize:[self frame].size] autorelease];
	NSRect rect = [self bounds];

	[image lockFocus];

	// Dashed roundrect
	
	NSBezierPath* bp = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, 30.0, 30.0) xRadius:64.0 yRadius:64.0];
	CGFloat dash[2] = { 32.0, 16.0 };
	[bp setLineDash:dash count:2 phase:24.0];
	[bp setLineWidth:10.0];
	[[NSColor grayColor] set];
	[bp stroke];

	// Placeholder text
	
	NSMutableParagraphStyle* ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[ps setAlignment:NSCenterTextAlignment];
	
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSFont systemFontOfSize:20.0], NSFontAttributeName, 
								[NSColor grayColor], NSForegroundColorAttributeName, 
								ps, NSParagraphStyleAttributeName, 
								nil];
	
	NSRect textRect;
	textRect.size.height = 64.0;
	textRect.size.width = 300.0;
	textRect.origin.x = floor((rect.size.width / 2.0) - (textRect.size.width / 2.0));
	textRect.origin.y = floor((rect.size.height / 2.0) - (textRect.size.height / 2.0));
	[L(@"Drop an image from the Finder here") drawInRect:textRect withAttributes:attrs];
	
	[image unlockFocus];

	return image;
}

@end
