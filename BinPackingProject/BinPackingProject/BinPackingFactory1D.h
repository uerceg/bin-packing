//
//  BinPackingFactory1D.h
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory1D : NSObject

// Property used only for info display purposes
@property (nonatomic) NSUInteger permutationCount;

- (id) initWithBinCapacity:(float)initBinCapacity 
                  binLimit:(NSUInteger)binLimit 
                 isLimited:(BOOL)isLimited;

- (NSUInteger) nextFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) nextFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) firstFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) firstFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) bestFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) bestFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) worstFitAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) worstFitDecreasingAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) harmonicAlgorithm1DForGivenItems:(NSMutableArray *)givenItems
                         algorithmGranulation:(NSUInteger)granularity;
- (NSUInteger) detailSearchAlgorithm1DForGivenItems:(NSMutableArray *)givenItems;
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForItems:(NSMutableArray *)bpItems
                               numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                     numberOfGenerations:(NSUInteger)generationsNumber 
                                mutationFactorPercentage:(NSUInteger)mutationFactor 
                                           elitismFactor:(NSUInteger)elitismFactor 
                                 numberOfCrossoverPoints:(NSUInteger)crossoverPoints 
                                fitnessFunctionSelection:(NSUInteger)choice;

- (void) showStorageUsageDetails;

@end