//
//  main.m
//  BinPacking
//
//  Created by Ugljesa Erceg on 5/15/12.
//  Open Source project
//

#import <Foundation/Foundation.h>
#import "BinPackingFactory1D.h"
#import "BinPackingFactory2D.h"

#define ARC4RANDOM_MAX      0x100000000

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
//        // Test for BinPackingFactory1D
//        NSMutableArray *inputItems = [NSMutableArray new];
//        BinPackingFactory1D * binPackingFactory1D = [[BinPackingFactory1D alloc] initWithBinCapacity:1.0f 
//                                                                                            binLimit:300
//                                                                                           isLimited:YES];
//        
////        [inputItems addObject:[NSNumber numberWithFloat:0.3f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.25f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.25f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.7f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.5f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.3f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
////        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
//        
//        for (NSUInteger i = 0; i < 400; i++)
//        {
//            float randomFloat = (float)arc4random() / ARC4RANDOM_MAX;
//            float roundedFloat = roundf(randomFloat * 100) / 100.0;
//            
//            if (roundedFloat == 0.0f)
//            {
//                roundedFloat = 0.1f;
//            }
//            
//            [inputItems addObject:[NSNumber numberWithFloat:roundedFloat]];
//        }
//        
//        // Write output information how many beans was used for packing
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Next Fit Bin Packing 1D ***");
//        [binPackingFactory1D nextFitAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Next Fit Decreasing Bin Packing 1D ***");
//        [binPackingFactory1D nextFitDecreasingAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** First Fit Bin Packing 1D ***");
//        [binPackingFactory1D firstFitAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** First Fit Decreasing Bin Packing 1D ***");
//        [binPackingFactory1D firstFitDecreasingAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Best Fit Bin Packing 1D ***");
//        [binPackingFactory1D bestFitAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Best Fit Decreasing Bin Packing 1D ***");
//        [binPackingFactory1D bestFitDecreasingAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Worst Fit Bin Packing 1D ***");
//        [binPackingFactory1D worstFitAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Worst Fit Decreasing Bin Packing 1D ***");
//        [binPackingFactory1D worstFitDecreasingAlgorithm1DForGivenItems:inputItems];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Genetic Algorithm (FF: Next Fit) Bin Packing 1D ***");
//        [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
//                                             numberOfUnitsInGeneration:20 
//                                                   numberOfGenerations:200 
//                                              mutationFactorPercentage:5
//                                                         elitismFactor:4 
//                                               numberOfCrossoverPoints:7 
//                                              fitnessFunctionSelection:0];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Genetic Algorithm (FF: First Fit) Bin Packing 1D ***");
//        [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
//                                             numberOfUnitsInGeneration:20 
//                                                   numberOfGenerations:200 
//                                              mutationFactorPercentage:5
//                                                         elitismFactor:4 
//                                               numberOfCrossoverPoints:7 
//                                              fitnessFunctionSelection:1];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Genetic Algorithm (FF: Best Fit) Bin Packing 1D ***");
//        [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
//                                             numberOfUnitsInGeneration:20 
//                                                   numberOfGenerations:200 
//                                              mutationFactorPercentage:5
//                                                         elitismFactor:4 
//                                               numberOfCrossoverPoints:7 
//                                              fitnessFunctionSelection:2];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Genetic Algorithm (FF: Worst Fit) Bin Packing 1D ***");
//        [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
//                                             numberOfUnitsInGeneration:20 
//                                                   numberOfGenerations:200 
//                                              mutationFactorPercentage:5
//                                                         elitismFactor:4 
//                                               numberOfCrossoverPoints:7 
//                                              fitnessFunctionSelection:3];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//        
//        NSLog(@"-------------------------------------");
//        NSLog(@"*** Harmonics Bin Packing 1D ***");
//        [binPackingFactory1D harmonicAlgorithm1DForGivenItems:inputItems
//                                         algorithmGranulation:5];
//        [binPackingFactory1D showStorageUsageDetails];
//        NSLog(@"-------------------------------------");
//
////        NSLog(@"[PM] Number of used bins: %lu", [binPackingFactory1D detailSearchAlgorithm1DForGivenItems:inputItems 
////                                                                                        withBinCapacity:1.0f]);
////        NSLog(@"[PM] Number of permutations: %lu", [binPackingFactory1D permutationCount]);
////
////        NSLog(@"[PSO] Number of used bins: %lu", [binPackingFactory1D searchWithUsageOfPSOAlgorithmForItems:inputItems 
////                                                                                         numberOfIterations:50 
////                                                                                   numberOfParticlesInSwarm:10]);
        
        // Test for BinPackingFactory2D
        NSMutableArray *inputRectangles = [NSMutableArray new];
        
        NSRect rectangle1 = NSMakeRect(0.0f, 0.0f, 4.0f, 4.0f);
        NSRect rectangle2 = NSMakeRect(0.0f, 0.0f, 4.0f, 2.0f);
        NSRect rectangle3 = NSMakeRect(0.0f, 0.0f, 8.0f, 3.0f);
        NSRect rectangle4 = NSMakeRect(0.0f, 0.0f, 7.0f, 1.0f);
        NSRect rectangle5 = NSMakeRect(0.0f, 0.0f, 6.0f, 6.0f);
        NSRect rectangle6 = NSMakeRect(0.0f, 0.0f, 2.0f, 3.0f);
        NSRect rectangle7 = NSMakeRect(0.0f, 0.0f, 3.0f, 2.0f);
        NSRect rectangle8 = NSMakeRect(0.0f, 0.0f, 4.0f, 3.0f);
        
//        NSRect rectangle1 = NSMakeRect(0.0f, 0.0f, 4.0f, 4.0f);
//        NSRect rectangle2 = NSMakeRect(0.0f, 0.0f, 4.0f, 2.0f);
//        NSRect rectangle3 = NSMakeRect(0.0f, 0.0f, 7.0f, 1.0f);
//        NSRect rectangle4 = NSMakeRect(0.0f, 0.0f, 4.0f, 3.0f);
//        NSRect rectangle5 = NSMakeRect(0.0f, 0.0f, 2.0f, 3.0f);
//        NSRect rectangle6 = NSMakeRect(0.0f, 0.0f, 3.0f, 2.0f);
//        NSRect rectangle7 = NSMakeRect(0.0f, 0.0f, 6.0f, 6.0f);
//        NSRect rectangle8 = NSMakeRect(0.0f, 0.0f, 8.0f, 3.0f);
        
        [inputRectangles addObject:[NSValue valueWithRect:rectangle1]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle2]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle3]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle4]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle5]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle6]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle7]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle8]];
        
        BinPackingFactory2D *binPackingFactory2D = [[BinPackingFactory2D alloc] initWithStorageWidth:10 
                                                                                       storageHeight:100 
                                                                                storageHeightLimited:NO];
        
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Next Fit Bin Packing 2D ***");
        [binPackingFactory2D shelfNextFitAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Next Fit Decreasing Bin Packing 2D ***");
        [binPackingFactory2D shelfNextFitDecreasingAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf First Fit Bin Packing 2D ***");
        [binPackingFactory2D shelfFirstFitAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf First Fit Decreasing Bin Packing 2D ***");
        [binPackingFactory2D shelfFirstFitDecreasingAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Best Fit Bin Packing 2D ***");
        [binPackingFactory2D shelfBestFitAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Best Fit Decreasing Bin Packing 2D ***");
        [binPackingFactory2D shelfBestFitDecreasingAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Worst Fit Bin Packing 2D ***");
        [binPackingFactory2D shelfWorstFitAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Worst Fit Decreasing Bin Packing 2D ***");
        [binPackingFactory2D shelfWorstFitDecreasingAlgorithm2DForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Genetic Algorithm (FF: Next Fit) Bin Packing 2D ***");
        [binPackingFactory2D searchWithUsageOfGeneticAlgorithmForRectangles:inputRectangles 
                                                  numberOfUnitsInGeneration:40 
                                                        numberOfGenerations:300 
                                                   mutationFactorPercentage:5
                                                              elitismFactor:2 
                                                    numberOfCrossoverPoints:3 
                                                   fitnessFunctionSelection:0];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Genetic Algorithm (FF: First Fit) Bin Packing 2D ***");
        [binPackingFactory2D searchWithUsageOfGeneticAlgorithmForRectangles:inputRectangles 
                                                  numberOfUnitsInGeneration:40 
                                                        numberOfGenerations:300 
                                                   mutationFactorPercentage:5
                                                              elitismFactor:2 
                                                    numberOfCrossoverPoints:3 
                                                   fitnessFunctionSelection:1];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Genetic Algorithm (FF: Best Fit) Bin Packing 2D ***");
        [binPackingFactory2D searchWithUsageOfGeneticAlgorithmForRectangles:inputRectangles 
                                                  numberOfUnitsInGeneration:40 
                                                        numberOfGenerations:300 
                                                   mutationFactorPercentage:5
                                                              elitismFactor:2 
                                                    numberOfCrossoverPoints:3 
                                                   fitnessFunctionSelection:2];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Genetic Algorithm (FF: Worst Fit) Bin Packing 2D ***");
        [binPackingFactory2D searchWithUsageOfGeneticAlgorithmForRectangles:inputRectangles 
                                                  numberOfUnitsInGeneration:40 
                                                        numberOfGenerations:300 
                                                   mutationFactorPercentage:5
                                                              elitismFactor:2 
                                                    numberOfCrossoverPoints:3 
                                                   fitnessFunctionSelection:3];
        NSLog(@"-------------------------------------");
        
        NSLog(@"-------------------------------------");
        NSLog(@"*** Shelf Detail Search Bin Packing 2D ***");
        [binPackingFactory2D detailSearchAlgorithm2DForGivenRectangles:inputRectangles];
        NSLog(@"-------------------------------------");
    }
    
    return 0;
}