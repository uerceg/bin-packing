//
//  BinPackingFactory1D.h
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory1D : NSObject

- (id) initWithItemArray:(float)initBinCapacity;
- (int) bestFitAlgorithm:(NSMutableArray *)givenItems;
- (int) firstFitAlgorithm:(NSMutableArray *)givenItems;
- (int) detailSearchAlgorithm:(NSMutableArray *)givenItems;

@end