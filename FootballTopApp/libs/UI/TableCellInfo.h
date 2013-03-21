//
//  CellInfo.h
//  Fuel Tracker
//
//  Created by Arkadiy Tolkun on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableCellInfo;

typedef void             (^TableCellActionBlock)(TableCellInfo *info);
typedef void             (^TableCellConfigBlock)(TableCellInfo *info, UITableViewCell *cell);
typedef UITableViewCell *(^TableCellCreateBlock)(TableCellInfo *info, UITableView *tableView);
typedef int              (^TableCellEditStyleBlock)(TableCellInfo *info);
typedef void             (^TableCellEditActionBlock)(TableCellInfo *info, UITableViewCellEditingStyle style);

@interface TableCellInfo : NSObject
{
    TableCellActionBlock        _action;
    TableCellConfigBlock        _config;
    TableCellCreateBlock        _create;
    TableCellEditStyleBlock     _editStyle;
    TableCellEditActionBlock    _editAction;
    
    NSMutableDictionary *_params;
}

@property (copy)        TableCellActionBlock     action;
@property (copy)        TableCellConfigBlock     config;
@property (copy)        TableCellCreateBlock     create;
@property (copy)        TableCellEditStyleBlock  editStyle;
@property (copy)        TableCellEditActionBlock editAction;

@property (readonly)    NSMutableDictionary      *params;

@end
