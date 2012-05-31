//
//  GeneticAlgorithmFactory3D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/30/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface GeneticAlgorithmFactory3D : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary *sliceLevelsPerLevel;

- (id) initWithNumberOfUnitsInGeneration:(NSUInteger)numberOfUnits 
                              boxesArray:(NSMutableArray *)boxesArray
                           elitismFactor:(NSUInteger)elitism 
                            storageWidth:(float)width 
                           storageHeight:(float)height
                           storageLength:(float)length;

- (void) mate:(NSUInteger)crossingPointsNumber;
- (void) generationSwap;
- (void) generateInitialPopulation;
- (void) mutate:(NSUInteger)mutationFactorPercentage;
- (void) calculateGenerationCostForFitnessFunction1:(float (^) (NSMutableArray *))ffunction1 
                                   fitnessFunction2:(float (^) (NSMutableArray *, NSMutableDictionary *))ffunction2;

@end
