//
//  DropDown.m
//  WorldOfAbsinthe
//
//  Created by Alex Petrinich on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DropDown.h"

@implementation DropDown
@synthesize isShow;
@synthesize dropDownDelegate;

+ (id) loadViewWithDelegate:(id)delegate
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"DropDown" owner:self options:nil];
    DropDown* view = [objects objectAtIndex:0];
    view.dropDownDelegate = delegate;
    
    return view;
}

- (void) show
{
    [UIView animateWithDuration:0.5 animations:^{
        if (!self.isShow)
        {
            self.alpha =1; 
            self.isShow = YES;
        }
    }
     ];
}

- (void) hide
{
    [UIView animateWithDuration:0.5 animations:^{
        if (self.isShow)
        {
            self.alpha = 0; 
            self.isShow = NO;
        }
    }
     ];

}

- (void) dealloc
{
    [table release];
    table = nil;
    [_data release];
    _data = nil;
    [super dealloc];
}

- (void) setData:(NSArray *)data
{
    [_data release];
    _data = nil;
    _data = data;
    [_data retain];    
}

- (void) reloadData
{
    [table reloadData];
}

- (NSString *) titleActivCell
{
    UITableViewCell *cell = [table cellForRowAtIndexPath:[table indexPathForSelectedRow]];
    if (cell == nil)
        return [[_data objectAtIndex:0] objectForKey:@"name"];
    return cell.textLabel.text;
}

#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIndentifier = @"CountryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier] autorelease];
    }
    cell.textLabel.text = [[_data objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    if ([[_data objectAtIndex:indexPath.row] objectForKey:@"is_active"])
    {
        if (![[[_data objectAtIndex:indexPath.row] objectForKey:@"is_active"] boolValue])
        {
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }       
    }
           
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hide];
    [dropDownDelegate dropDown:self selectItemWithIndex:indexPath.row];
}

@end
