//
//  BinPackingFactory3D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/28/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface BinPackingFactory3D : NSObject

- (id) initWithStorageWidth:(float)sWidth 
              storageLength:(float)sLength 
              storageHeight:(float)sHeight;

- (float) nextFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) nextFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) firstFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) firstFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) bestFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) bestFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) worstFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (float) worstFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes;
- (void) detailSearchAlgorithm3DForgivenBoxes:(NSMutableArray *)givenBoxes;
- (void) searchWithUsageOfGeneticAlgorithm3DForRectangles:(NSMutableArray *)bpBoxes
                                numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                      numberOfGenerations:(NSUInteger)generationsNumber 
                                 mutationFactorPercentage:(NSUInteger)mutationFactor 
                                            elitismFactor:(NSUInteger)elitismFactor 
                                  numberOfCrossoverPoints:(NSUInteger)crossoverPoints 
                                 fitnessFunctionSelection:(NSUInteger)choice;

- (void) showStorageUsageDetails;

@end
