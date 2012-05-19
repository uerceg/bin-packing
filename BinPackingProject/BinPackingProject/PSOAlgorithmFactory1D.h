// UNUSABLE SO FAR, SINCE PSO VELOCITY CALCULATION DOESN'T GIVE UNIQUE INDEXES ARRAY
// PSO WILL BE RECONSIDERED LATER

//
//  PSOAlgorithmFactory1D.h
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/18/12.
//  Open Source project
//

#import <Foundation/Foundation.h>

@interface PSOAlgorithmFactory1D : NSObject

@property (nonatomic, readonly) NSUInteger allTimeBestParticleFitnessValue;

- (id) initWithNumberOfParticlesInSwarm:(NSUInteger)numberOfParticles 
                     numberOfIterations:(NSUInteger) iterations
                         particlesArray:(NSMutableArray *)particlesArray;

- (void) generateInitialSwarm;
- (void) calculateBestCandidateFromSwarm:(NSUInteger (^) (NSMutableArray *)) fitnessFunction;
- (void) calculateVelocityForNextStep:(NSUInteger (^) (NSMutableArray *)) fitnessFunction;
- (void) addVelocityToParticlesInSwarm;
- (void) swarmSwap;

@end
