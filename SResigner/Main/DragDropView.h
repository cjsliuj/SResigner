

#import <Cocoa/Cocoa.h>
@protocol DragDropViewDelegate;

@interface DragDropView : NSView
@property (assign) IBOutlet id<DragDropViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray<NSString *>* enableDragInFileExtensions;
@end

@protocol DragDropViewDelegate <NSObject>
-(void)onHandleDragInIpa:(NSString *)filePath;
@end
