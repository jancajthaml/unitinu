
@interface SFDropImageView : NSImageView
{
	IBOutlet NSSlider* i_centerPointSlider;
	IBOutlet NSButton* i_flipSidesButton;

	NSData* imageData;
	NSBitmapImageRep* imageRep;
	NSInteger mode;
	float centerAdjust;
}

@property (assign) IBOutlet NSSlider* centerPointSlider;
@property (assign) IBOutlet NSButton* flipSidesButton;

- (IBAction)changeCenterPoint:(id)sender;
- (IBAction)changeMode:(id)sender;

- (BOOL)openFileAtPath:(NSString*)path;
- (void)savePNGImageToPath:(NSString*)path;

@end
