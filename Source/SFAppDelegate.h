@class SFDropImageView;

@interface SFAppDelegate : NSObject <NSApplicationDelegate>
{
	SFDropImageView* i_imageView;
	NSWindow* i_window;
}

@property (assign) IBOutlet SFDropImageView* imageView;
@property (assign) IBOutlet NSWindow* window;

- (IBAction)open:(id)sender;
- (IBAction)save:(id)sender;

@end
