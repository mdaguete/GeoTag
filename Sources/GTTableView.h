//
//  GTTableView.h
//  GeoTag
//
//  Created by Marco S Hyman on 7/5/09.
//

#import <Cocoa/Cocoa.h>


@interface GTTableView : NSTableView <NSTableViewDelegate>

@property IBOutlet id appController;

- (IBAction) cut: (id)sender;
- (IBAction) copy: (id) sender;
- (IBAction) paste: (id) sender;
- (IBAction) delete: (id) sender;
- (IBAction) selectAll: (id)sender;

@end
