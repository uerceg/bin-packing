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

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
//        // Test for BinPackingFactory1D
//        NSMutableArray *inputItems = [NSMutableArray new];
//        BinPackingFactory1D * binPackingFactory1D = [[BinPackingFactory1D alloc] init];
//        
//        [inputItems addObject:[NSNumber numberWithFloat:0.7f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.7f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.6f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.7f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.5f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.4f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.3f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.1f]];
//        [inputItems addObject:[NSNumber numberWithFloat:0.2f]];
//        
//        // Write output information how many beans was used for packing
//        NSLog(@"[PSO] Number of used bins: %lu", [binPackingFactory1D searchWithUsageOfPSOAlgorithmForItems:inputItems 
//                                                                                         numberOfIterations:50 
//                                                                                   numberOfParticlesInSwarm:10]);
//        
//        NSLog(@"[FF] Number of used bins: %lu", [binPackingFactory1D firstFitAlgorithmForGivenItems:inputItems 
//                                                                                   withBinCapacity:1.0f]);
//        
//        NSLog(@"[BF] Number of used bins: %lu", [binPackingFactory1D bestFitAlgorithmForGivenItems:inputItems 
//                                                                                   withBinCapacity:1.0f]);
//        
//        NSLog(@"[PM] Number of used bins: %lu", [binPackingFactory1D detailSearchAlgorithmForGivenItems:inputItems 
//                                                                                        withBinCapacity:1.0f]);
//        
//        NSLog(@"[GA] Number of used bins: %lu", [binPackingFactory1D searchWithUsageOfGeneticAlgorithmForItems:inputItems 
//                                                                                numberOfUnitsInGeneration:10 
//                                                                                      numberOfGenerations:50 
//                                                                                 mutationFactorPercentage:2]);
        
        // Test for BinPackingFactory2D
        NSMutableArray *inputRectangles = [NSMutableArray new];
        
        NSRect rectangle1 = NSMakeRect(0.0f, 0.0f, 3.0f, 2.0f);
        NSRect rectangle2 = NSMakeRect(0.0f, 0.0f, 2.0f, 2.0f);
        NSRect rectangle3 = NSMakeRect(0.0f, 0.0f, 2.0f, 2.0f);
        NSRect rectangle4 = NSMakeRect(0.0f, 0.0f, 4.0f, 2.0f);
        NSRect rectangle5 = NSMakeRect(0.0f, 0.0f, 3.0f, 2.0f);
        NSRect rectangle6 = NSMakeRect(0.0f, 0.0f, 1.0f, 2.0f);
        NSRect rectangle7 = NSMakeRect(0.0f, 0.0f, 1.0f, 2.0f);
        
        [inputRectangles addObject:[NSValue valueWithRect:rectangle1]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle2]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle3]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle4]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle5]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle6]];
        [inputRectangles addObject:[NSValue valueWithRect:rectangle7]];
        
        BinPackingFactory2D *binPackingFactory2D = [[BinPackingFactory2D alloc] initWithStorageWidth:5 
                                                                                      storageHeight:10];
        
        [binPackingFactory2D firstFitAlgorithmForGivenRectangles:inputRectangles];
    }
    
    return 0;
}