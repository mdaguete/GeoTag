//
//  GTTableView.m
//  GeoTag
//
//  Created by Marco S Hyman on 7/5/09.
//

#import "GTTableView.h"
#import "GTController.h"

@implementation GTTableView

#pragma mark -
#pragma mark init and setup

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here if needed in the future
    }
    return self;
}

- (void) awakeFromNib
{
    [self setDelegate: self];
}

#pragma mark -
#pragma mark cut, copy, paste, and delete lat/lng from table items

- (BOOL) validateMenuItem: (NSMenuItem *) item
{
    SEL action = [item action];
    if (action == @selector(selectAll:))
        return [self.appController numberOfRowsInTableView: self] != 0;
    if (action == @selector(copy:) ||
	action == @selector(cut:) ||
	action == @selector(paste:) ||
	action == @selector(delete:))
	return [self.appController isValidImageAtIndex: [self selectedRow]];
    return YES;
}

- (IBAction) cut: (id) sender
{
    [self copy: self];
    [self delete: self];
}

- (IBAction) copy: (id) sender
{
    NSInteger row = [self selectedRow];
    if ([self.appController isValidImageAtIndex: row]) {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes: @[NSStringPboardType]
		   owner: self];
	[pb setString: [[self.appController imageAtIndex: row] stringRepresentation]
	      forType: NSStringPboardType];
    }
}

- (IBAction) paste: (id) sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    if ([[pb types] containsObject: NSStringPboardType]) {
        NSString *val = [pb stringForType: NSStringPboardType];
        NSIndexSet *rows = [self selectedRowIndexes];
        [rows enumerateIndexesUsingBlock: ^(NSUInteger row, BOOL *stop) {
            if ([self.appController isValidImageAtIndex: row]) {
                NSString *lat;
                NSString *lng;
                if ([[self.appController imageAtIndex: row] convertFromString: val
                                                                latitude: &lat
                                                               longitude: &lng]) {
                    [self.appController updateLocationForImageAtRow: row
                                                      latitude: lat
                                                     longitude: lng
                                                      modified: YES];
                    [self.appController adjustMapViewForRow: row];
                }
                
            }
        }];
    }
}

- (IBAction) delete: (id) sender
{
    NSIndexSet *rows = [self selectedRowIndexes];
    [rows enumerateIndexesUsingBlock: ^(NSUInteger row, BOOL *stop) {
        if ([self.appController isValidImageAtIndex: row]) {
            [self.appController updateLocationForImageAtRow: row
                                              latitude: nil
                                             longitude: nil
                                              modified: YES];
            [self.appController adjustMapViewForRow: row];
        }
    }];
}

- (IBAction) selectAll: (id)sender
{
    NSRange range = {0, [self.appController numberOfRowsInTableView: self]};
    NSIndexSet *allItems = [NSIndexSet indexSetWithIndexesInRange: range];
    [self selectRowIndexes: allItems byExtendingSelection: NO];
}

#pragma mark -
#pragma mark tableView delegate functions

- (void) tableView: (NSTableView *) aTableView
   willDisplayCell: (id) aCell
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
    if ([aCell respondsToSelector:@selector(setTextColor:)]) {
	NSColor *textColor;
	if ([self.appController isValidImageAtIndex: rowIndex])
	    textColor = [NSColor blackColor];
	else
	    textColor = [NSColor grayColor];
	
	[aCell setTextColor: textColor];
    }
}

- (BOOL) tableView: (NSTableView *) aTableView
   shouldSelectRow: (NSInteger) rowIndex
{
    return [self.appController isValidImageAtIndex: rowIndex];
}

- (void) tableViewSelectionDidChange: (NSNotification *)notification
{
    [self.appController showImageForIndex: [self selectedRow]];
}

- (NSString *) tableView: (NSTableView *) tv
	  toolTipForCell: (NSCell *) aCell
		    rect: (NSRectPointer) rect
	     tableColumn: (NSTableColumn *) aTableColumn
		     row: (NSInteger) row
	   mouseLocation: (NSPoint) mouseLocation
{
    if ([[aTableColumn identifier] isEqual: @"name"])
	return [[self.appController imageAtIndex: row] path];
    return nil;
}

#pragma mark -
#pragma mark right mouse down select

/*
 * Select the row that the user right clicked on before passing the
 * event off to the super class for context menu processing.
 */
- (void) rightMouseDown: (NSEvent *) event
{
    // figure out the row where the click occurred
    NSPoint eventLocation = [event locationInWindow];  
    NSPoint localPoint = [self convertPointFromBase: eventLocation];  
    NSInteger row = [self rowAtPoint: localPoint];
    // select the row if it is not selected and selection is allowed
    // otherwise deselect the current row
    if (! [self isRowSelected: row]) {
	[self selectRowIndexes: [NSIndexSet indexSetWithIndex: row]
	  byExtendingSelection: NO];
	if (! [self isRowSelected: row])
	    [self deselectAll: self];
	[self reloadData];
    }
    [super rightMouseDown: event];
}


@end
