//
//  BinPackingFactory1D.h
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory1D : NSObject

- (id) init;

- (NSUInteger) firstFitAlgorithmForGivenItems:(NSMutableArray *)givenItems
                              withBinCapacity:(float)initBinCapacity;
- (NSUInteger) bestFitAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                             withBinCapacity:(float)initBinCapacity;
- (NSUInteger) detailSearchAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                                  withBinCapacity:(float)initBinCapacity;
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForItems:(NSMutableArray *)bpItems
                               numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                     numberOfGenerations:(NSUInteger)generationsNumber 
                                mutationFactorPercentage:(NSUInteger)mutationFactor;

@end