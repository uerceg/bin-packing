//
//  BinPackingFactory1D.h
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Copyright (c) 2012 Ugljesa Erceg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory1D : NSObject

- (id) initWithItemArray:(float)initBinCapacity;
- (int) bestFitAlgorithm:(NSMutableArray *)givenItems;
- (int) firstFitAlgorithm:(NSMutableArray *)givenItems;
- (int) detailSearchAlgorithm:(NSMutableArray *)givenItems;

@end