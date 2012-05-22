//
//  BinPackingFactory2D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/18/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory2D : NSObject

// Property used only for info display purposes
@property (nonatomic) NSUInteger permutationCount;

- (id) initWithStorageWidth:(float)width 
                storageHeight:(float)height;

- (NSUInteger) shelfNextFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles;
- (NSUInteger) shelfFirstFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles;
- (NSUInteger) shelfBestFitAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles;
- (NSUInteger) detailSearchAlgorithmForGivenRectangles:(NSMutableArray *)givenRectangles;
- (NSUInteger) searchWithUsageOfGeneticAlgorithmForRectangles:(NSMutableArray *)bpRectangles
                                    numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                          numberOfGenerations:(NSUInteger)generationsNumber 
                                     mutationFactorPercentage:(NSUInteger)mutationFactor 
                                                elitismFactor:(NSUInteger)elitismFactor 
                                      numberOfCrossoverPoints:(NSUInteger)crossoverPoints;
- (void) showStorageUsageDetails;

@end
