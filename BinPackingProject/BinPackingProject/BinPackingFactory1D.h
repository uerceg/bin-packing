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
                              withBinCapacity:(CGFloat)initBinCapacity;
- (NSUInteger) bestFitAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                             withBinCapacity:(CGFloat)initBinCapacity;
- (NSUInteger) detailSearchAlgorithmForGivenItems:(NSMutableArray *)givenItems 
                                  withBinCapacity:(CGFloat)initBinCapacity;
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForItems:(NSMutableArray *)bpItems
                               numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                     numberOfGenerations:(NSUInteger)generationsNumber 
                                mutationFactorPercentage:(NSUInteger)mutationFactor;

@end