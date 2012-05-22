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
//        BinPackingFactory1D * binPackingFactory1D = [[BinPackingFactory1D alloc] init];
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
//        for (NSUInteger i = 0; i < 200; i++)
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
//        NSLog(@"[NF] Number of used bins: %lu", [binPackingFactory1D nextFitAlgorithmForGivenItems:inputItems 
//                                                                                   withBinCapacity:1.0f]);
//        
//        NSLog(@"[FF] Number of used bins: %lu", [binPackingFactory1D firstFitAlgorithmForGivenItems:inputItems 
//                                                                                    withBinCapacity:1.0f]);
//        
//        NSLog(@"[BF] Number of used bins: %lu", [binPackingFactory1D bestFitAlgorithmForGivenItems:inputItems 
//                                                                                   withBinCapacity:1.0f]);
//        
////        NSLog(@"[PM] Number of used bins: %lu", [binPackingFactory1D detailSearchAlgorithmForGivenItems:inputItems 
////                                                                                        withBinCapacity:1.0f]);
////        NSLog(@"[PM] Number of permutations: %lu", [binPackingFactory1D permutationCount]);
//        
//        NSLog(@"[GA] Number of used bins: %lu", [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
//                                                                                     numberOfUnitsInGeneration:20 
//                                                                                           numberOfGenerations:200 
//                                                                                      mutationFactorPercentage:5
//                                                                                                 elitismFactor:4 
//                                                                                       numberOfCrossoverPoints:20]);
//        
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
                                                                                      storageHeight:100];
        
        NSLog(@"--- Next Fit Bin Packing 2D ---");
        [binPackingFactory2D shelfNextFitAlgorithmForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        
        NSLog(@"--- First Fit Bin Packing 2D ---");
        [binPackingFactory2D shelfFirstFitAlgorithmForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        
        NSLog(@"--- Best Fit Bin Packing 2D ---");
        [binPackingFactory2D shelfBestFitAlgorithmForGivenRectangles:inputRectangles];
        [binPackingFactory2D showStorageUsageDetails];
        
        NSLog(@"--- Detail Search Bin Packing 2D ---");
        [binPackingFactory2D detailSearchAlgorithmForGivenRectangles:inputRectangles];
        
        NSLog(@"--- Genetic Algorithm Bin Packing 2D ---");
        [binPackingFactory2D searchWithUsageOfGeneticAlgorithmForRectangles:inputRectangles 
                                                  numberOfUnitsInGeneration:20 
                                                        numberOfGenerations:500 
                                                   mutationFactorPercentage:3
                                                              elitismFactor:2 
                                                    numberOfCrossoverPoints:3];
    }
    
    return 0;
}