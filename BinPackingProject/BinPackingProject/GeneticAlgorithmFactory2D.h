//
//  GeneticAlgorithmFactory2D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/21/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface GeneticAlgorithmFactory2D : NSObject

@property (nonatomic, readonly) NSUInteger lowestCost;
@property (nonatomic, readonly) float usedStorage;
@property (nonatomic, readonly) float usedStorageHeight;
@property (nonatomic, readonly) float usedStorageHeightPercent;

- (id) initWithNumberOfUnitsInGeneration:(NSUInteger)numberOfUnits 
                         rectanglesArray:(NSMutableArray *)rectanglesArray
                           elitismFactor:(NSUInteger)elitism 
                            storageWidth:(float)width 
                           storageHeight:(float)height;

- (void) mate:(NSUInteger)crossingPointsNumber;
- (void) generationSwap;
- (void) generateInitialPopulation;
- (void) mutate:(NSUInteger)mutationFactorPercentage;
- (void) calculateGenerationCost:(NSUInteger (^) (NSMutableArray *))fitnessFunction 
             helpFitnessFunction:(NSUInteger (^) (NSMutableArray *, NSMutableArray *, NSMutableArray *))helpFF;

@end
