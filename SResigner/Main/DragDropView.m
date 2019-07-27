
#import "DragDropView.h"

@implementation DragDropView
- (void)dealloc {
    [self setDelegate:nil];
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self internalInit];
    }
    return self;
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    return self;
}
- (void) internalInit{
    self.wantsLayer = YES;
    self.enableDragInFileExtensions = @[@"ipa", @"mobileprovision"].mutableCopy;
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    [super draggingEntered:sender];
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    NSString * fileName = list[0];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        if ([self.enableDragInFileExtensions containsObject:[fileName pathExtension].lowercaseString]) {
            self.layer.backgroundColor = [NSColor.whiteColor colorWithAlphaComponent:0.4].CGColor;
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}
- (void)draggingExited:(id<NSDraggingInfo>)sender{
    [super draggingExited:sender];
    self.layer.backgroundColor = NSColor.clearColor.CGColor;
}
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    self.layer.backgroundColor = NSColor.clearColor.CGColor;
    
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    if(self.delegate && [self.delegate respondsToSelector:@selector(onHandleDragInIpa:)])
        [self.delegate onHandleDragInIpa:list[0]];
    return YES;
}

@end
