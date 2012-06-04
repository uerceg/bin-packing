//
//  BinPackingFactory3D.m
//  BinPackingProject
//
//  Created by Ugljesa Erceg on 5/28/12.
//  Open Source project
//

#import "BinPackingFactory3D.h"
#import "GeneticAlgorithmFactory3D.h"
#import "Box.h"

#define FF_STORAGE_WIDTH    10.0f
#define FF_STORAGE_LENGTH   10.0f
#define FF_STORAGE_HEIGHT   500.0f

@implementation BinPackingFactory3D
{
    @private float storageWidth;
    @private float storageLenght;
    @private float storageHeight;
    @private float lowestSliceLevelUsage;
    
    @private NSUInteger permutationCount;
    
    @private NSMutableArray *boxes;
    @private NSMutableDictionary *sliceLevelsPerLevel;
    @private NSMutableDictionary *sliceLevelsPerLevelWithBoxes;
    @private NSMutableDictionary *bestSliceLevelsPerLevel;
    @private NSMutableDictionary *bestSliceLevelsPerLevelWithBoxes;
}

// Custom initializator
- (id) initWithStorageWidth:(float)sWidth 
              storageLength:(float)sLength 
              storageHeight:(float)sHeight
{
    if (self = [super init])
    {
        self->storageWidth = sWidth;
        self->storageLenght = sLength;
        self->storageHeight = sHeight;
        
        self->lowestSliceLevelUsage = (float)INT_MAX;
        
        self->boxes = [NSMutableArray new];
        self->sliceLevelsPerLevel = [NSMutableDictionary dictionary];
        self->sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
        self->bestSliceLevelsPerLevel = [NSMutableDictionary dictionary];
        self->bestSliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    }
    
    return self;
}

// PUBLIC: Next Fit Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) nextFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSUInteger currentSliceLevelId = 0;
    NSUInteger currentBoxFromInput = 0;
    NSUInteger currentLevelNumber = 0;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    [self->boxes addObjectsFromArray:givenBoxes];
    
    float currentLevelWidth = 0.0f;
    float currentLevelHeight = 0.0f;
    
    for (Box *box in self->boxes)
    {
        float filledLevelsHeight = 0.0f;
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        currentBoxFromInput += 1;
        
        // Check if level dictionary has entry for this level
        NSString *keySlice;
        NSString *keyLevel = [[NSNumber numberWithInteger:currentLevel] stringValue];
        
        if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
        {
            // Entry exists, everything's fine
        }
        else
        {
            // No entry, add one
            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
        }
        
        // We are at first level at this moment
        if (0 == currentLevel)
        {

        }
        else
        {
            // We are at some upper level
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:keyLevel] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
        }
        
        // Slice-level exists, check if new box can fit
        // Check height
        if (filledLevelsHeight + box.height <= self->storageHeight)
        {
            // Check width afterwards
            if (currentLevelWidth + box.width <= self->storageWidth)
            {
                // Check length in the end
                if (currentSliceLevelLength + box.length <= self->storageLenght)
                {
                    // At this moment, we determined that box fits in slice-level by length, height and width
                    // Box will be added to current slice-level, but check should be made weather box's height and width
                    // are greater than current slice-level's, and if yes, slice-level's should be updated
                    currentSliceLevelLength += box.length;
                    
                    if (currentSliceLevelWidth < box.width)
                    {
                        currentSliceLevelWidth = box.width;
                    }
                    
                    if (currentSliceLevelHeight < box.height)
                    {
                        currentSliceLevelHeight = box.height;
                    }
                    
                    // Add entry in level dictionary for current level and current slice-level ID
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    else
                    {
                        [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                        [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    
                    // Check current box is the last one, if yes, seal it's slice-level
                    if (currentBoxFromInput == [self->boxes count])
                    {
                        // Find out current slice-level height and width
                        float height = 0.0f;
                        float width = 0.0f;
                        
                        for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            if (height < addedBox.height)
                            {
                                height = addedBox.height;
                            }
                            if (width < addedBox.width)
                            {
                                width = addedBox.width;
                            }
                        }
                        
                        Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                        
                        // Seal the slice-level
                        if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                    }
                }
                else
                {
                    // Box doesn't fit by length in current slice-level which means new slice level should be created
                    // Now current level widht and heigh MUST be updated, because we closed previous slice-level
                    // so we need to check if that slice-level was higher than current level height (width must be added)
                    // Find out current slice-level height and width
                    float height = 0.0f;
                    float width = 0.0f;
                    
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        if (height < addedBox.height)
                        {
                            height = addedBox.height;
                        }
                        if (width < addedBox.width)
                        {
                            width = addedBox.width;
                        }
                    }
                    
                    Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                    
                    // Seal the slice-level
                    if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    else
                    {
                        [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                        [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    
                    currentSliceLevelId += 1;
                    
                    // Update width and height
                    currentLevelWidth = 0.0f;
                    currentLevelHeight = 0.0f;
                    
                    for (Box *sealedBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        currentLevelWidth += sealedBox.width;
                        
                        if (currentLevelHeight < sealedBox.height)
                        {
                            currentLevelHeight = sealedBox.height;
                        }
                    }
                    
                    // Now we have updated width and length of current level, so we need to check following:
                    // Will this box be added to slice-level which can be placed on current level OR
                    // new slice-level will be opened on next level
                    
                    if (currentLevelWidth + box.width > self->storageWidth)
                    {
                        // Check if box can fit in storage width at all
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it

                            float remainedWidth = self->storageWidth - currentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)

                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= self->storageHeight)
                            {
                                if (box.width + currentLevelWidth <= self->storageWidth)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [self->boxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                                        
                                        // Seal the slice-level
                                        if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // Box can't fit to storage width at all
                            NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                        }
                    }
                    else
                    {
                        // Slice-level for current box CAN be opened on CURRENT level
                        currentSliceLevelHeight = box.height;
                        currentSliceLevelWidth = box.width;
                        currentSliceLevelLength = box.length;
                        
                        // Adding to current level new slice-level entry and adding current box to it
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        
                        // Check current box is the last one, if yes, seal it's slice-level
                        if (currentBoxFromInput == [self->boxes count])
                        {
                            // Find out current slice-level height and width
                            float height = 0.0f;
                            float width = 0.0f;
                            
                            for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                            {
                                if (height < addedBox.height)
                                {
                                    height = addedBox.height;
                                }
                                if (width < addedBox.width)
                                {
                                    width = addedBox.width;
                                }
                            }
                            
                            Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                            
                            // Seal the slice-level
                            if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                        }
                    }
                }
            }
            else
            {
                // Box doesn't fit in width on current level
                // New level should be opened and this box added to first slice-level on that level
                // NOTE: It is possible that when attempting this action height of current box is simply
                //       to big to fit in remaining space of current bin, so new bin should be made then
                //       In this implementation this case probably won't be considered, infinite height will be supposed
                
                // First added box to bin doesn't fit by width
                if (0 == currentLevelWidth)
                {
                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                }
                else
                {
                    // There are some slice-levels on current level, but this box doesn't fit to current
                    // level by width anymore, so we will try to place it on next level in new slice-level
                    
                    // Check if bin can fit to storage width at all
                    if (box.width <= self->storageWidth)
                    {
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        NSUInteger sliceLevelsOnCurrentLevel = [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] count];
                        NSUInteger closedSliceLevelsOnCurrentLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] count];
                        
                        // Check if number of closed slice-levels on current level fits this number
                        if (sliceLevelsOnCurrentLevel == closedSliceLevelsOnCurrentLevel)
                        {
                            // All slice-levels on current level closed, so just need to make new one from empty space
                            
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - currentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= self->storageHeight)
                            {
                                if (box.width + currentLevelWidth <= self->storageWidth)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [self->boxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                                        
                                        // Seal the slice-level
                                        if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // There is an open slice-level, but current item can't fit to it NOR current level
                            // Seal that slice-level so it width reaches storage width border
                            float remainedWidth = self->storageWidth - currentLevelWidth;
                            
                            // Locate the last sealed slice-level, make updated box and replace it
                            Box *lastSealedSliceLevel = [[Box alloc] initWithWidth:remainedWidth 
                                                                            length:self->storageLenght 
                                                                            height:currentSliceLevelHeight];
                            
                            // Add currently sealed slice-level to current level
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:lastSealedSliceLevel];
                            
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= self->storageHeight)
                            {
                                if (box.width + currentLevelWidth <= self->storageWidth)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
                            }

                        }
                    }
                    else
                    {
                        NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                    }
                }
            }
            
        }
        else
        {
            // Box doesn't fit in height, this means that current box cannot be placed in current bin
            // New bin must be opened in order to place this item
            // NOTE: In this implementation this case probably won't be considered, infinite height will be supposed
            //       and then afterwards maybe will levels be divided in order to fit in bins with finite dimensions
            NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PRIVATE: Block implementation of Next Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^nextFitAlgorithm3DFF1) (NSMutableArray *) = ^(NSMutableArray * givenBoxes)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSUInteger currentSliceLevelId = 0;
    NSUInteger currentBoxFromInput = 0;
    NSUInteger currentLevelNumber = 0;
    
    NSMutableDictionary *sliceLevelsPerLevel = [NSMutableDictionary dictionary];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    float currentLevelWidth = 0.0f;
    float currentLevelHeight = 0.0f;
    
    for (Box *box in givenBoxes)
    {
        float filledLevelsHeight = 0.0f;
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        currentBoxFromInput += 1;
        
        // Check if level dictionary has entry for this level
        NSString *keySlice;
        NSString *keyLevel = [[NSNumber numberWithInteger:currentLevel] stringValue];
        
        if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
        {
            // Entry exists, everything's fine
        }
        else
        {
            // No entry, add one
            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
        }
        
        // We are at first level at this moment
        if (0 == currentLevel)
        {
            
        }
        else
        {
            // We are at some upper level
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:keyLevel] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
        }
        
        // Slice-level exists, check if new box can fit
        // Check height
        if (filledLevelsHeight + box.height <= (float)FF_STORAGE_HEIGHT)
        {
            // Check width afterwards
            if (currentLevelWidth + box.width <= (float)FF_STORAGE_WIDTH)
            {
                // Check length in the end
                if (currentSliceLevelLength + box.length <= (float)FF_STORAGE_LENGTH)
                {
                    // At this moment, we determined that box fits in slice-level by length, height and width
                    // Box will be added to current slice-level, but check should be made weather box's height and width
                    // are greater than current slice-level's, and if yes, slice-level's should be updated
                    currentSliceLevelLength += box.length;
                    
                    if (currentSliceLevelWidth < box.width)
                    {
                        currentSliceLevelWidth = box.width;
                    }
                    
                    if (currentSliceLevelHeight < box.height)
                    {
                        currentSliceLevelHeight = box.height;
                    }
                    
                    // Add entry in level dictionary for current level and current slice-level ID
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    if ([[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    else
                    {
                        [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                        [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    
                    // Check current box is the last one, if yes, seal it's slice-level
                    if (currentBoxFromInput == [givenBoxes count])
                    {
                        // Find out current slice-level height and width
                        float height = 0.0f;
                        float width = 0.0f;
                        
                        for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            if (height < addedBox.height)
                            {
                                height = addedBox.height;
                            }
                            if (width < addedBox.width)
                            {
                                width = addedBox.width;
                            }
                        }
                        
                        Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                        
                        // Seal the slice-level
                        if ([sliceLevelsPerLevel objectForKey:keyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                    }
                }
                else
                {
                    // Box doesn't fit by length in current slice-level which means new slice level should be created
                    // Now current level widht and heigh MUST be updated, because we closed previous slice-level
                    // so we need to check if that slice-level was higher than current level height (width must be added)
                    // Find out current slice-level height and width
                    float height = 0.0f;
                    float width = 0.0f;
                    
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        if (height < addedBox.height)
                        {
                            height = addedBox.height;
                        }
                        if (width < addedBox.width)
                        {
                            width = addedBox.width;
                        }
                    }
                    
                    Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                    
                    // Seal the slice-level
                    if ([sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    else
                    {
                        [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                        [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    
                    currentSliceLevelId += 1;
                    
                    // Update width and height
                    currentLevelWidth = 0.0f;
                    currentLevelHeight = 0.0f;
                    
                    for (Box *sealedBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        currentLevelWidth += sealedBox.width;
                        
                        if (currentLevelHeight < sealedBox.height)
                        {
                            currentLevelHeight = sealedBox.height;
                        }
                    }
                    
                    // Now we have updated width and length of current level, so we need to check following:
                    // Will this box be added to slice-level which can be placed on current level OR
                    // new slice-level will be opened on next level
                    
                    if (currentLevelWidth + box.width > (float)FF_STORAGE_WIDTH)
                    {
                        // Check if box can fit in storage width at all
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - currentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                            {
                                if (box.width + currentLevelWidth <= (float)FF_STORAGE_WIDTH)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [givenBoxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                                        
                                        // Seal the slice-level
                                        if ([sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // Box can't fit to storage width at all
                            NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                    else
                    {
                        // Slice-level for current box CAN be opened on CURRENT level
                        currentSliceLevelHeight = box.height;
                        currentSliceLevelWidth = box.width;
                        currentSliceLevelLength = box.length;
                        
                        // Adding to current level new slice-level entry and adding current box to it
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        
                        // Check current box is the last one, if yes, seal it's slice-level
                        if (currentBoxFromInput == [givenBoxes count])
                        {
                            // Find out current slice-level height and width
                            float height = 0.0f;
                            float width = 0.0f;
                            
                            for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                            {
                                if (height < addedBox.height)
                                {
                                    height = addedBox.height;
                                }
                                if (width < addedBox.width)
                                {
                                    width = addedBox.width;
                                }
                            }
                            
                            Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                            
                            // Seal the slice-level
                            if ([sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                        }
                    }
                }
            }
            else
            {
                // Box doesn't fit in width on current level
                // New level should be opened and this box added to first slice-level on that level
                // NOTE: It is possible that when attempting this action height of current box is simply
                //       to big to fit in remaining space of current bin, so new bin should be made then
                //       In this implementation this case probably won't be considered, infinite height will be supposed
                
                // First added box to bin doesn't fit by width
                if (0 == currentLevelWidth)
                {
                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                }
                else
                {
                    // There are some slice-levels on current level, but this box doesn't fit to current
                    // level by width anymore, so we will try to place it on next level in new slice-level
                    
                    // Check if bin can fit to storage width at all
                    if (box.width <= (float)FF_STORAGE_WIDTH)
                    {
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        NSUInteger sliceLevelsOnCurrentLevel = [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] count];
                        NSUInteger closedSliceLevelsOnCurrentLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] count];
                        
                        // Check if number of closed slice-levels on current level fits this number
                        if (sliceLevelsOnCurrentLevel == closedSliceLevelsOnCurrentLevel)
                        {
                            // All slice-levels on current level closed, so just need to make new one from empty space
                            
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - currentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                            {
                                if (box.width + currentLevelWidth <= (float)FF_STORAGE_WIDTH)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [givenBoxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                                        
                                        // Seal the slice-level
                                        if ([sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // There is an open slice-level, but current item can't fit to it NOR current level
                            // Seal that slice-level so it width reaches storage width border
                            float remainedWidth = (float)FF_STORAGE_WIDTH - currentLevelWidth;
                            
                            // Locate the last sealed slice-level, make updated box and replace it
                            Box *lastSealedSliceLevel = [[Box alloc] initWithWidth:remainedWidth 
                                                                            length:(float)FF_STORAGE_LENGTH
                                                                            height:currentSliceLevelHeight];
                            
                            // Add currently sealed slice-level to current level
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:lastSealedSliceLevel];
                            
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                            {
                                if (box.width + currentLevelWidth <= (float)FF_STORAGE_WIDTH)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
                            }
                            
                        }
                    }
                    else
                    {
                        NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                    }
                }
            }
            
        }
        else
        {
            // Box doesn't fit in height, this means that current box cannot be placed in current bin
            // New bin must be opened in order to place this item
            // NOTE: In this implementation this case probably won't be considered, infinite height will be supposed
            //       and then afterwards maybe will levels be divided in order to fit in bins with finite dimensions
            NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PRIVATE: Block implementation of Next Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^nextFitAlgorithm3DFF2) (NSMutableArray *, NSMutableDictionary *) = ^(NSMutableArray * givenBoxes, NSMutableDictionary * sliceLevelsPerLevel)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSUInteger currentSliceLevelId = 0;
    NSUInteger currentBoxFromInput = 0;
    NSUInteger currentLevelNumber = 0;
    
    [sliceLevelsPerLevel removeAllObjects];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    float currentLevelWidth = 0.0f;
    float currentLevelHeight = 0.0f;
    
    for (Box *box in givenBoxes)
    {
        float filledLevelsHeight = 0.0f;
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        currentBoxFromInput += 1;
        
        // Check if level dictionary has entry for this level
        NSString *keySlice;
        NSString *keyLevel = [[NSNumber numberWithInteger:currentLevel] stringValue];
        
        if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
        {
            // Entry exists, everything's fine
        }
        else
        {
            // No entry, add one
            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
        }
        
        // We are at first level at this moment
        if (0 == currentLevel)
        {
            
        }
        else
        {
            // We are at some upper level
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:keyLevel] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
        }
        
        // Slice-level exists, check if new box can fit
        // Check height
        if (filledLevelsHeight + box.height <= (float)FF_STORAGE_HEIGHT)
        {
            // Check width afterwards
            if (currentLevelWidth + box.width <= (float)FF_STORAGE_WIDTH)
            {
                // Check length in the end
                if (currentSliceLevelLength + box.length <= (float)FF_STORAGE_LENGTH)
                {
                    // At this moment, we determined that box fits in slice-level by length, height and width
                    // Box will be added to current slice-level, but check should be made weather box's height and width
                    // are greater than current slice-level's, and if yes, slice-level's should be updated
                    currentSliceLevelLength += box.length;
                    
                    if (currentSliceLevelWidth < box.width)
                    {
                        currentSliceLevelWidth = box.width;
                    }
                    
                    if (currentSliceLevelHeight < box.height)
                    {
                        currentSliceLevelHeight = box.height;
                    }
                    
                    // Add entry in level dictionary for current level and current slice-level ID
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    if ([[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    else
                    {
                        [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                        [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    
                    // Check current box is the last one, if yes, seal it's slice-level
                    if (currentBoxFromInput == [givenBoxes count])
                    {
                        // Find out current slice-level height and width
                        float height = 0.0f;
                        float width = 0.0f;
                        
                        for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            if (height < addedBox.height)
                            {
                                height = addedBox.height;
                            }
                            if (width < addedBox.width)
                            {
                                width = addedBox.width;
                            }
                        }
                        
                        Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                        
                        // Seal the slice-level
                        if ([sliceLevelsPerLevel objectForKey:keyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                    }
                }
                else
                {
                    // Box doesn't fit by length in current slice-level which means new slice level should be created
                    // Now current level widht and heigh MUST be updated, because we closed previous slice-level
                    // so we need to check if that slice-level was higher than current level height (width must be added)
                    // Find out current slice-level height and width
                    float height = 0.0f;
                    float width = 0.0f;
                    
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        if (height < addedBox.height)
                        {
                            height = addedBox.height;
                        }
                        if (width < addedBox.width)
                        {
                            width = addedBox.width;
                        }
                    }
                    
                    Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                    
                    // Seal the slice-level
                    if ([sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    else
                    {
                        [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                        [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    
                    currentSliceLevelId += 1;
                    
                    // Update width and height
                    currentLevelWidth = 0.0f;
                    currentLevelHeight = 0.0f;
                    
                    for (Box *sealedBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        currentLevelWidth += sealedBox.width;
                        
                        if (currentLevelHeight < sealedBox.height)
                        {
                            currentLevelHeight = sealedBox.height;
                        }
                    }
                    
                    // Now we have updated width and length of current level, so we need to check following:
                    // Will this box be added to slice-level which can be placed on current level OR
                    // new slice-level will be opened on next level
                    
                    if (currentLevelWidth + box.width > (float)FF_STORAGE_WIDTH)
                    {
                        // Check if box can fit in storage width at all
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - currentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                            {
                                if (box.width + currentLevelWidth <= (float)FF_STORAGE_WIDTH)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [givenBoxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                                        
                                        // Seal the slice-level
                                        if ([sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // Box can't fit to storage width at all
                            NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                    else
                    {
                        // Slice-level for current box CAN be opened on CURRENT level
                        currentSliceLevelHeight = box.height;
                        currentSliceLevelWidth = box.width;
                        currentSliceLevelLength = box.length;
                        
                        // Adding to current level new slice-level entry and adding current box to it
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        
                        // Check current box is the last one, if yes, seal it's slice-level
                        if (currentBoxFromInput == [givenBoxes count])
                        {
                            // Find out current slice-level height and width
                            float height = 0.0f;
                            float width = 0.0f;
                            
                            for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                            {
                                if (height < addedBox.height)
                                {
                                    height = addedBox.height;
                                }
                                if (width < addedBox.width)
                                {
                                    width = addedBox.width;
                                }
                            }
                            
                            Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                            
                            // Seal the slice-level
                            if ([sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                        }
                    }
                }
            }
            else
            {
                // Box doesn't fit in width on current level
                // New level should be opened and this box added to first slice-level on that level
                // NOTE: It is possible that when attempting this action height of current box is simply
                //       to big to fit in remaining space of current bin, so new bin should be made then
                //       In this implementation this case probably won't be considered, infinite height will be supposed
                
                // First added box to bin doesn't fit by width
                if (0 == currentLevelWidth)
                {
                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                }
                else
                {
                    // There are some slice-levels on current level, but this box doesn't fit to current
                    // level by width anymore, so we will try to place it on next level in new slice-level
                    
                    // Check if bin can fit to storage width at all
                    if (box.width <= (float)FF_STORAGE_WIDTH)
                    {
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        NSUInteger sliceLevelsOnCurrentLevel = [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] count];
                        NSUInteger closedSliceLevelsOnCurrentLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] count];
                        
                        // Check if number of closed slice-levels on current level fits this number
                        if (sliceLevelsOnCurrentLevel == closedSliceLevelsOnCurrentLevel)
                        {
                            // All slice-levels on current level closed, so just need to make new one from empty space
                            
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - currentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                            {
                                if (box.width + currentLevelWidth <= (float)FF_STORAGE_WIDTH)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [givenBoxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:(float)FF_STORAGE_LENGTH height:height];
                                        
                                        // Seal the slice-level
                                        if ([sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // There is an open slice-level, but current item can't fit to it NOR current level
                            // Seal that slice-level so it width reaches storage width border
                            float remainedWidth = (float)FF_STORAGE_WIDTH - currentLevelWidth;
                            
                            // Locate the last sealed slice-level, make updated box and replace it
                            Box *lastSealedSliceLevel = [[Box alloc] initWithWidth:remainedWidth 
                                                                            length:(float)FF_STORAGE_LENGTH
                                                                            height:currentSliceLevelHeight];
                            
                            // Add currently sealed slice-level to current level
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:lastSealedSliceLevel];
                            
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                            {
                                if (box.width + currentLevelWidth <= (float)FF_STORAGE_WIDTH)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
                            }
                            
                        }
                    }
                    else
                    {
                        NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                    }
                }
            }
            
        }
        else
        {
            // Box doesn't fit in height, this means that current box cannot be placed in current bin
            // New bin must be opened in order to place this item
            // NOTE: In this implementation this case probably won't be considered, infinite height will be supposed
            //       and then afterwards maybe will levels be divided in order to fit in bins with finite dimensions
            NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, (float)FF_STORAGE_HEIGHT - filledLevelsHeight);
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PUBLIC: Next Fit Decreasing Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) nextFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSUInteger currentSliceLevelId = 0;
    NSUInteger currentBoxFromInput = 0;
    NSUInteger currentLevelNumber = 0;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"height"
//                                                 ascending:YES];
//    
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSArray *sortedBoxes = [givenBoxes sortedArrayUsingDescriptors:sortDescriptors];
    
    NSSortDescriptor *widthSorter = [[NSSortDescriptor alloc] initWithKey:@"width" ascending:NO];
    NSSortDescriptor *heightSorter = [[NSSortDescriptor alloc] initWithKey:@"height" ascending:NO];
    
    NSMutableArray *doubleSortedBoxes = [NSMutableArray arrayWithArray:givenBoxes];
    
    [doubleSortedBoxes sortUsingDescriptors:[NSArray arrayWithObjects:heightSorter, widthSorter, nil]];
    
    [self->boxes addObjectsFromArray:doubleSortedBoxes];
    
    float currentLevelWidth = 0.0f;
    float currentLevelHeight = 0.0f;
    
    for (Box *box in self->boxes)
    {
        float filledLevelsHeight = 0.0f;
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        currentBoxFromInput += 1;
        
        // Check if level dictionary has entry for this level
        NSString *keySlice;
        NSString *keyLevel = [[NSNumber numberWithInteger:currentLevel] stringValue];
        
        if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
        {
            // Entry exists, everything's fine
        }
        else
        {
            // No entry, add one
            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
        }
        
        // We are at first level at this moment
        if (0 == currentLevel)
        {

        }
        else
        {
            // We are at some upper level
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:keyLevel] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
        }
        
        // Slice-level exists, check if new box can fit
        // Check height
        if (filledLevelsHeight + box.height <= self->storageHeight)
        {
            // Check width afterwards
            if (currentLevelWidth + box.width <= self->storageWidth)
            {
                // Check length in the end
                if (currentSliceLevelLength + box.length <= self->storageLenght)
                {
                    // At this moment, we determined that box fits in slice-level by length, height and width
                    // Box will be added to current slice-level, but check should be made weather box's height and width
                    // are greater than current slice-level's, and if yes, slice-level's should be updated
                    currentSliceLevelLength += box.length;
                    
                    if (currentSliceLevelWidth < box.width)
                    {
                        currentSliceLevelWidth = box.width;
                    }
                    
                    if (currentSliceLevelHeight < box.height)
                    {
                        currentSliceLevelHeight = box.height;
                    }
                    
                    // Add entry in level dictionary for current level and current slice-level ID
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    else
                    {
                        [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                        [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                    }
                    
                    // Check current box is the last one, if yes, seal it's slice-level
                    if (currentBoxFromInput == [self->boxes count])
                    {
                        // Find out current slice-level height and width
                        float height = 0.0f;
                        float width = 0.0f;
                        
                        for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            if (height < addedBox.height)
                            {
                                height = addedBox.height;
                            }
                            if (width < addedBox.width)
                            {
                                width = addedBox.width;
                            }
                        }
                        
                        Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                        
                        // Seal the slice-level
                        if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                        }
                    }
                }
                else
                {
                    // Box doesn't fit by length in current slice-level which means new slice level should be created
                    // Now current level widht and heigh MUST be updated, because we closed previous slice-level
                    // so we need to check if that slice-level was higher than current level height (width must be added)
                    // Find out current slice-level height and width
                    float height = 0.0f;
                    float width = 0.0f;
                    
                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                    
                    for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                    {
                        if (height < addedBox.height)
                        {
                            height = addedBox.height;
                        }
                        if (width < addedBox.width)
                        {
                            width = addedBox.width;
                        }
                    }
                    
                    Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                    
                    // Seal the slice-level
                    if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    else
                    {
                        [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                        [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                    }
                    
                    currentSliceLevelId += 1;
                    
                    // Update width and height
                    currentLevelWidth = 0.0f;
                    currentLevelHeight = 0.0f;
                    
                    for (Box *sealedBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                    {
                        currentLevelWidth += sealedBox.width;
                        
                        if (currentLevelHeight < sealedBox.height)
                        {
                            currentLevelHeight = sealedBox.height;
                        }
                    }
                    
                    // Now we have updated width and length of current level, so we need to check following:
                    // Will this box be added to slice-level which can be placed on current level OR
                    // new slice-level will be opened on next level
                    
                    if (currentLevelWidth + box.width > self->storageWidth)
                    {
                        // Check if box can fit in storage width at all
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - currentLevelWidth;
                            
                            // Locate the last sealed slice-level, make updated box and replace it
                            Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                            Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                               length:self->storageLenght 
                                                                               height:lastSealedSliceLevel.height];
                            
                            // Remove last sealed slice-level and add updated one
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= self->storageHeight)
                            {
                                if (box.width + currentLevelWidth <= self->storageWidth)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [self->boxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                                        
                                        // Seal the slice-level
                                        if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // Box can't fit to storage width at all
                            NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                        }
                    }
                    else
                    {
                        // Slice-level for current box CAN be opened on CURRENT level
                        currentSliceLevelHeight = box.height;
                        currentSliceLevelWidth = box.width;
                        currentSliceLevelLength = box.length;
                        
                        // Adding to current level new slice-level entry and adding current box to it
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                        }
                        
                        // Check current box is the last one, if yes, seal it's slice-level
                        if (currentBoxFromInput == [self->boxes count])
                        {
                            // Find out current slice-level height and width
                            float height = 0.0f;
                            float width = 0.0f;
                            
                            for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                            {
                                if (height < addedBox.height)
                                {
                                    height = addedBox.height;
                                }
                                if (width < addedBox.width)
                                {
                                    width = addedBox.width;
                                }
                            }
                            
                            Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                            
                            // Seal the slice-level
                            if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                            }
                        }
                    }
                }
            }
            else
            {
                // Box doesn't fit in width on current level
                // New level should be opened and this box added to first slice-level on that level
                // NOTE: It is possible that when attempting this action height of current box is simply
                //       to big to fit in remaining space of current bin, so new bin should be made then
                //       In this implementation this case probably won't be considered, infinite height will be supposed
                
                // First added box to bin doesn't fit by width
                if (0 == currentLevelWidth)
                {
                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                }
                else
                {
                    // There are some slice-levels on current level, but this box doesn't fit to current
                    // level by width anymore, so we will try to place it on next level in new slice-level
                    
                    // Check if bin can fit to storage width at all
                    if (box.width <= self->storageWidth)
                    {
                        keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                        NSUInteger sliceLevelsOnCurrentLevel = [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] count];
                        NSUInteger closedSliceLevelsOnCurrentLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] count];
                        
                        // Check if number of closed slice-levels on current level fits this number
                        if (sliceLevelsOnCurrentLevel == closedSliceLevelsOnCurrentLevel)
                        {
                            // All slice-levels on current level closed, so just need to make new one from empty space
                            
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - currentLevelWidth;
                            
                            // Locate the last sealed slice-level, make updated box and replace it
                            Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                            Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                               length:self->storageLenght 
                                                                               height:lastSealedSliceLevel.height];
                            
                            // Remove last sealed slice-level and add updated one
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= self->storageHeight)
                            {
                                if (box.width + currentLevelWidth <= self->storageWidth)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                    
                                    // Check current box is the last one, if yes, seal it's slice-level
                                    if (currentBoxFromInput == [self->boxes count])
                                    {
                                        // Find out current slice-level height and width
                                        float height = 0.0f;
                                        float width = 0.0f;
                                        
                                        for (Box *addedBox in [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice])
                                        {
                                            if (height < addedBox.height)
                                            {
                                                height = addedBox.height;
                                            }
                                            if (width < addedBox.width)
                                            {
                                                width = addedBox.width;
                                            }
                                        }
                                        
                                        Box *newBox = [[Box alloc] initWithWidth:width length:self->storageLenght height:height];
                                        
                                        // Seal the slice-level
                                        if ([self->sliceLevelsPerLevel objectForKey:keyLevel])
                                        {
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                        else
                                        {
                                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:keyLevel];
                                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:newBox];
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
                            }
                        }
                        else
                        {
                            // There is an open slice-level, but current item can't fit to it NOR current level
                            // Seal that slice-level so it width reaches storage width border
                            float remainedWidth = self->storageWidth - currentLevelWidth;
                            
                            // Locate the last sealed slice-level, make updated box and replace it
                            Box *lastSealedSliceLevel = [[Box alloc] initWithWidth:remainedWidth 
                                                                            length:self->storageWidth 
                                                                            height:currentSliceLevelHeight];
                            
                            // Add currently sealed slice-level to current level
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:lastSealedSliceLevel];
                            
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float currentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (currentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    currentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:currentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // MOVING TO THE NEXT LEVEL
                            // Opening slice-level on NEXT level if current box fits in height and width
                            // Current level width is now set to ZERO, since new level is opened, height should be updated too
                            currentLevelWidth = 0.0f;
                            filledLevelsHeight += currentHighestSliceLevelHeight;
                            
                            // NEW SLICE-LEVEL is being created on NEW LEVEL
                            currentSliceLevelId += 1;
                            currentLevelNumber += 1;
                            
                            // Add dictionary information for new level
                            keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
                            
                            if (box.height + filledLevelsHeight <= self->storageHeight)
                            {
                                if (box.width + currentLevelWidth <= self->storageWidth)
                                {
                                    // Box can be added to new slice-level on new level
                                    currentSliceLevelHeight = box.height;
                                    currentSliceLevelWidth = box.width;
                                    currentSliceLevelLength = box.length;
                                    
                                    // Adding to current level new slice-level entry and adding current box to it
                                    keyLevel = [[NSNumber numberWithInteger:currentLevelNumber] stringValue];
                                    keySlice = [[NSNumber numberWithInteger:currentSliceLevelId] stringValue];
                                    
                                    [[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] setObject:[NSMutableArray array] forKey:keySlice];
                                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel] objectForKey:keySlice] addObject:box];
                                }
                                else
                                {
                                    NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                                }
                            }
                            else
                            {
                                NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
                            }
                            
                        }
                    }
                    else
                    {
                        NSLog(@"Current box with width %f can't be placed in current bin, since level width is %f!", box.width, self->storageWidth);
                    }
                }
            }
            
        }
        else
        {
            // Box doesn't fit in height, this means that current box cannot be placed in current bin
            // New bin must be opened in order to place this item
            // NOTE: In this implementation this case probably won't be considered, infinite height will be supposed
            //       and then afterwards maybe will levels be divided in order to fit in bins with finite dimensions
            NSLog(@"Current box with height %f can't be placed in current bin, since remaining level height is %f!", box.height, self->storageHeight - filledLevelsHeight);
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PUBLIC: First Fit Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) firstFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    [self->boxes addObjectsFromArray:givenBoxes];
    
    for (Box *box in self->boxes)
    {
        BOOL placedCurrentBox = NO;

        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;

        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [self->sliceLevelsPerLevelWithBoxes allKeys])
        {
            if (YES == placedCurrentBox)
            {
                break;
            }
            
            currentLevel = [levelKey intValue];

            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                if (YES == placedCurrentBox)
                {
                    break;
                }
                
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= self->storageLenght)
                {
                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [self->sliceLevelsPerLevel count] != 0 ? [self->sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[self->sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [self->sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= self->storageLenght)
            {
                if (box.height + aCurrentFilledLevelsHeight <= self->storageHeight)
                {
                    if (box.width + aCurrentLevelWidth <= self->storageWidth)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                        
                        if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];

                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                            
                            if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, self->storageWidth);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, self->storageHeight - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, self->storageLenght);
            }
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PRIVATE: Block implementation of First Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^firstFitAlgorithm3DFF1) (NSMutableArray *) = ^(NSMutableArray * givenBoxes)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSMutableDictionary *sliceLevelsPerLevel = [NSMutableDictionary dictionary];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    for (Box *box in givenBoxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [sliceLevelsPerLevelWithBoxes allKeys])
        {
            if (YES == placedCurrentBox)
            {
                break;
            }
            
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                if (YES == placedCurrentBox)
                {
                    break;
                }
                
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= (float)FF_STORAGE_LENGTH)
                {
                    [[[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [sliceLevelsPerLevel count] != 0 ? [sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= (float)FF_STORAGE_LENGTH)
            {
                if (box.height + aCurrentFilledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                {
                    if (box.width + aCurrentLevelWidth <= (float)FF_STORAGE_WIDTH)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                        
                        if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                            
                            if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, (float)FF_STORAGE_HEIGHT - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, (float)FF_STORAGE_LENGTH);
            }
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PRIVATE: Block implementation of First Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^firstFitAlgorithm3DFF2) (NSMutableArray *, NSMutableDictionary *) = ^(NSMutableArray * givenBoxes, NSMutableDictionary * sliceLevelsPerLevel)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [sliceLevelsPerLevel removeAllObjects];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    for (Box *box in givenBoxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [sliceLevelsPerLevelWithBoxes allKeys])
        {
            if (YES == placedCurrentBox)
            {
                break;
            }
            
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                if (YES == placedCurrentBox)
                {
                    break;
                }
                
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= (float)FF_STORAGE_LENGTH)
                {
                    [[[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [sliceLevelsPerLevel count] != 0 ? [sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= (float)FF_STORAGE_LENGTH)
            {
                if (box.height + aCurrentFilledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                {
                    if (box.width + aCurrentLevelWidth <= (float)FF_STORAGE_WIDTH)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                        
                        if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                            
                            if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, (float)FF_STORAGE_HEIGHT - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, (float)FF_STORAGE_LENGTH);
            }
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PUBLIC: First Fit Decreasing Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) firstFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    NSSortDescriptor *widthSorter = [[NSSortDescriptor alloc] initWithKey:@"width" ascending:NO];
    NSSortDescriptor *heightSorter = [[NSSortDescriptor alloc] initWithKey:@"height" ascending:NO];
    
    NSMutableArray *doubleSortedBoxes = [NSMutableArray arrayWithArray:givenBoxes];
    
    [doubleSortedBoxes sortUsingDescriptors:[NSArray arrayWithObjects:heightSorter, widthSorter, nil]];
    
    [self->boxes addObjectsFromArray:doubleSortedBoxes];
    
    for (Box *box in self->boxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [self->sliceLevelsPerLevelWithBoxes allKeys])
        {
            if (YES == placedCurrentBox)
            {
                break;
            }
            
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                if (YES == placedCurrentBox)
                {
                    break;
                }
                
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= self->storageLenght)
                {
                    [[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [self->sliceLevelsPerLevel count] != 0 ? [self->sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[self->sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [self->sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= self->storageLenght)
            {
                if (box.height + aCurrentFilledLevelsHeight <= self->storageHeight)
                {
                    if (box.width + aCurrentLevelWidth <= self->storageWidth)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                        
                        if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                            
                            if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, self->storageWidth);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, self->storageHeight - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, self->storageLenght);
            }
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PUBLIC: Best Fit Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) bestFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    [self->boxes addObjectsFromArray:givenBoxes];
    
    for (Box *box in self->boxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float bestFitCurrentRemainingLength = (float)INT_MAX;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger bestFitLevelNumber = 0;
        NSUInteger bestFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [self->sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= self->storageLenght)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = self->storageLenght - (currentSliceLevelLength + box.length);
                    
                    if (potentialRemainingLength < bestFitCurrentRemainingLength)
                    {
                        bestFitCurrentRemainingLength = potentialRemainingLength;
                        bestFitLevelNumber = [levelKey intValue];
                        bestFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [self->sliceLevelsPerLevel count] != 0 ? [self->sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[self->sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [self->sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= self->storageLenght)
            {
                if (box.height + aCurrentFilledLevelsHeight <= self->storageHeight)
                {
                    if (box.width + aCurrentLevelWidth <= self->storageWidth)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                        
                        if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                            
                            if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, self->storageWidth);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, self->storageHeight - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, self->storageLenght);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *bestFitLevelKey = [[NSNumber numberWithInteger:bestFitLevelNumber] stringValue];
            NSString *bestFitSliceLevelKey = [[NSNumber numberWithInteger:bestFitSliceLevelNumber] stringValue];
            
            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:bestFitLevelKey] objectForKey:bestFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PRIVATE: Block implementation of Best Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^bestFitAlgorithm3DFF1) (NSMutableArray *) = ^(NSMutableArray * givenBoxes)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSMutableDictionary *sliceLevelsPerLevel = [NSMutableDictionary dictionary];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    for (Box *box in givenBoxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float bestFitCurrentRemainingLength = (float)INT_MAX;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger bestFitLevelNumber = 0;
        NSUInteger bestFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= (float)FF_STORAGE_LENGTH)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = (float)FF_STORAGE_LENGTH - (currentSliceLevelLength + box.length);
                    
                    if (potentialRemainingLength < bestFitCurrentRemainingLength)
                    {
                        bestFitCurrentRemainingLength = potentialRemainingLength;
                        bestFitLevelNumber = [levelKey intValue];
                        bestFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [sliceLevelsPerLevel count] != 0 ? [sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= (float)FF_STORAGE_LENGTH)
            {
                if (box.height + aCurrentFilledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                {
                    if (box.width + aCurrentLevelWidth <= (float)FF_STORAGE_WIDTH)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                        
                        if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                            
                            if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, (float)FF_STORAGE_HEIGHT - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, (float)FF_STORAGE_LENGTH);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *bestFitLevelKey = [[NSNumber numberWithInteger:bestFitLevelNumber] stringValue];
            NSString *bestFitSliceLevelKey = [[NSNumber numberWithInteger:bestFitSliceLevelNumber] stringValue];
            
            [[[sliceLevelsPerLevelWithBoxes objectForKey:bestFitLevelKey] objectForKey:bestFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PRIVATE: Block implementation of Best Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^bestFitAlgorithm3DFF2) (NSMutableArray *, NSMutableDictionary *) = ^(NSMutableArray * givenBoxes, NSMutableDictionary * sliceLevelsPerLevel)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [sliceLevelsPerLevel removeAllObjects];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    for (Box *box in givenBoxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float bestFitCurrentRemainingLength = (float)INT_MAX;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger bestFitLevelNumber = 0;
        NSUInteger bestFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= (float)FF_STORAGE_LENGTH)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = (float)FF_STORAGE_LENGTH - (currentSliceLevelLength + box.length);
                    
                    if (potentialRemainingLength < bestFitCurrentRemainingLength)
                    {
                        bestFitCurrentRemainingLength = potentialRemainingLength;
                        bestFitLevelNumber = [levelKey intValue];
                        bestFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [sliceLevelsPerLevel count] != 0 ? [sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= (float)FF_STORAGE_LENGTH)
            {
                if (box.height + aCurrentFilledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                {
                    if (box.width + aCurrentLevelWidth <= (float)FF_STORAGE_WIDTH)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                        
                        if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                            
                            if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, (float)FF_STORAGE_HEIGHT - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, (float)FF_STORAGE_LENGTH);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *bestFitLevelKey = [[NSNumber numberWithInteger:bestFitLevelNumber] stringValue];
            NSString *bestFitSliceLevelKey = [[NSNumber numberWithInteger:bestFitSliceLevelNumber] stringValue];
            
            [[[sliceLevelsPerLevelWithBoxes objectForKey:bestFitLevelKey] objectForKey:bestFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PUBLIC: Best Fit Decreasing Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) bestFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    NSSortDescriptor *widthSorter = [[NSSortDescriptor alloc] initWithKey:@"width" ascending:NO];
    NSSortDescriptor *heightSorter = [[NSSortDescriptor alloc] initWithKey:@"height" ascending:NO];
    
    NSMutableArray *doubleSortedBoxes = [NSMutableArray arrayWithArray:givenBoxes];
    
    [doubleSortedBoxes sortUsingDescriptors:[NSArray arrayWithObjects:heightSorter, widthSorter, nil]];
    
    [self->boxes addObjectsFromArray:doubleSortedBoxes];
    
    for (Box *box in self->boxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float bestFitCurrentRemainingLength = (float)INT_MAX;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger bestFitLevelNumber = 0;
        NSUInteger bestFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [self->sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= self->storageLenght)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = self->storageLenght - (currentSliceLevelLength + box.length);
                    
                    if (potentialRemainingLength < bestFitCurrentRemainingLength)
                    {
                        bestFitCurrentRemainingLength = potentialRemainingLength;
                        bestFitLevelNumber = [levelKey intValue];
                        bestFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [self->sliceLevelsPerLevel count] != 0 ? [self->sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[self->sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [self->sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= self->storageLenght)
            {
                if (box.height + aCurrentFilledLevelsHeight <= self->storageHeight)
                {
                    if (box.width + aCurrentLevelWidth <= self->storageWidth)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                        
                        if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                            
                            if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, self->storageWidth);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, self->storageHeight - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, self->storageLenght);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *bestFitLevelKey = [[NSNumber numberWithInteger:bestFitLevelNumber] stringValue];
            NSString *bestFitSliceLevelKey = [[NSNumber numberWithInteger:bestFitSliceLevelNumber] stringValue];
            
            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:bestFitLevelKey] objectForKey:bestFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PUBLIC: Worst Fit Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) worstFitAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    [self->boxes addObjectsFromArray:givenBoxes];
    
    for (Box *box in self->boxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float worstFitCurrentRemainingLength = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger worstFitLevelNumber = 0;
        NSUInteger worstFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [self->sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= self->storageLenght)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = self->storageLenght - (currentSliceLevelLength + box.length);
                    
                    if (worstFitCurrentRemainingLength < potentialRemainingLength)
                    {
                        worstFitCurrentRemainingLength = potentialRemainingLength;
                        worstFitLevelNumber = [levelKey intValue];
                        worstFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [self->sliceLevelsPerLevel count] != 0 ? [self->sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[self->sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [self->sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= self->storageLenght)
            {
                if (box.height + aCurrentFilledLevelsHeight <= self->storageHeight)
                {
                    if (box.width + aCurrentLevelWidth <= self->storageWidth)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                        
                        if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                            
                            if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, self->storageWidth);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, self->storageHeight - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, self->storageLenght);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *worstFitLevelKey = [[NSNumber numberWithInteger:worstFitLevelNumber] stringValue];
            NSString *worstFitSliceLevelKey = [[NSNumber numberWithInteger:worstFitSliceLevelNumber] stringValue];
            
            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:worstFitLevelKey] objectForKey:worstFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PRIVATE: Block implementation of Worst Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^worstFitAlgorithm3DFF1) (NSMutableArray *) = ^(NSMutableArray * givenBoxes)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    NSMutableDictionary *sliceLevelsPerLevel = [NSMutableDictionary dictionary];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    for (Box *box in givenBoxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float worstFitCurrentRemainingLength = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger worstFitLevelNumber = 0;
        NSUInteger worstFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= (float)FF_STORAGE_LENGTH)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = (float)FF_STORAGE_LENGTH - (currentSliceLevelLength + box.length);
                    
                    if (potentialRemainingLength > worstFitCurrentRemainingLength)
                    {
                        worstFitCurrentRemainingLength = potentialRemainingLength;
                        worstFitLevelNumber = [levelKey intValue];
                        worstFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [sliceLevelsPerLevel count] != 0 ? [sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= (float)FF_STORAGE_LENGTH)
            {
                if (box.height + aCurrentFilledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                {
                    if (box.width + aCurrentLevelWidth <= (float)FF_STORAGE_WIDTH)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                        
                        if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                            
                            if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, (float)FF_STORAGE_HEIGHT - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, (float)FF_STORAGE_LENGTH);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *worstFitLevelKey = [[NSNumber numberWithInteger:worstFitLevelNumber] stringValue];
            NSString *worstFitSliceLevelKey = [[NSNumber numberWithInteger:worstFitSliceLevelNumber] stringValue];
            
            [[[sliceLevelsPerLevelWithBoxes objectForKey:worstFitLevelKey] objectForKey:worstFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PRIVATE: Block implementation of Worst Fit Bin Packing algorithm (used for GA)
// RETURNS: Percentage of used space with slice-levels
float (^worstFitAlgorithm3DFF2) (NSMutableArray *, NSMutableDictionary *) = ^(NSMutableArray * givenBoxes, NSMutableDictionary * sliceLevelsPerLevel)
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [sliceLevelsPerLevel removeAllObjects];
    NSMutableDictionary *sliceLevelsPerLevelWithBoxes = [NSMutableDictionary dictionary];
    
    for (Box *box in givenBoxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float worstFitCurrentRemainingLength = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger worstFitLevelNumber = 0;
        NSUInteger worstFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= (float)FF_STORAGE_LENGTH)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = (float)FF_STORAGE_LENGTH - (currentSliceLevelLength + box.length);
                    
                    if (potentialRemainingLength > worstFitCurrentRemainingLength)
                    {
                        worstFitCurrentRemainingLength = potentialRemainingLength;
                        worstFitLevelNumber = [levelKey intValue];
                        worstFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [sliceLevelsPerLevel count] != 0 ? [sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= (float)FF_STORAGE_LENGTH)
            {
                if (box.height + aCurrentFilledLevelsHeight <= (float)FF_STORAGE_HEIGHT)
                {
                    if (box.width + aCurrentLevelWidth <= (float)FF_STORAGE_WIDTH)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                        
                        if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= (float)FF_STORAGE_WIDTH)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = (float)FF_STORAGE_WIDTH - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:(float)FF_STORAGE_LENGTH
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:(float)FF_STORAGE_LENGTH height:box.height];
                            
                            if ([sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, (float)FF_STORAGE_WIDTH);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, (float)FF_STORAGE_HEIGHT - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, (float)FF_STORAGE_LENGTH);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *worstFitLevelKey = [[NSNumber numberWithInteger:worstFitLevelNumber] stringValue];
            NSString *worstFitSliceLevelKey = [[NSNumber numberWithInteger:worstFitSliceLevelNumber] stringValue];
            
            [[[sliceLevelsPerLevelWithBoxes objectForKey:worstFitLevelKey] objectForKey:worstFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
};

// PUBLIC: Worst Fit Decreasing Bin Packing Algorithm
// RETURNS: Percentage of used space with slice-levels
- (float) worstFitDecreasingAlgorithm3DForGivenBoxes:(NSMutableArray *)givenBoxes
{
    float currentSliceLevelWidth = 0.0f;
    float currentSliceLevelLength = 0.0f;
    float currentSliceLevelHeight = 0.0f;
    
    [self->boxes removeAllObjects];
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    NSSortDescriptor *widthSorter = [[NSSortDescriptor alloc] initWithKey:@"width" ascending:NO];
    NSSortDescriptor *heightSorter = [[NSSortDescriptor alloc] initWithKey:@"height" ascending:NO];
    
    NSMutableArray *doubleSortedBoxes = [NSMutableArray arrayWithArray:givenBoxes];
    
    [doubleSortedBoxes sortUsingDescriptors:[NSArray arrayWithObjects:heightSorter, widthSorter, nil]];
    
    [self->boxes addObjectsFromArray:doubleSortedBoxes];
    
    for (Box *box in self->boxes)
    {
        BOOL placedCurrentBox = NO;
        
        float filledLevelsHeight = 0.0f;
        float aCurrentLevelWidth = 0.0f;
        float aCurrentFilledLevelsHeight = 0.0f;
        float worstFitCurrentRemainingLength = 0.0f;
        
        NSString *aKeyLevel;
        NSString *aKeySliceLevel;
        
        NSUInteger aCurrentLevelNumber = 0;
        NSUInteger aCurrentSliceLevelNumber = 0;
        
        NSUInteger worstFitLevelNumber = 0;
        NSUInteger worstFitSliceLevelNumber = 0;
        
        NSUInteger currentLevel = [self->sliceLevelsPerLevel count];
        
        // Go through each level
        for (NSString *levelKey in [self->sliceLevelsPerLevelWithBoxes allKeys])
        {
            currentLevel = [levelKey intValue];
            
            // Determine total filled height of so far filled levels
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:0];
                    filledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            NSUInteger sliceLevelsOnThisLevelNumber = 0;
            
            // Go through each slice-level on current level
            for (NSString *sliceLevelKey in [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] allKeys])
            {
                // Take box array of current slice-level
                NSMutableArray *currentSliceLevelItems = [[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey];
                
                // It is sealed, we must read it's length, height and width in order to determine
                // weather current box fits in this slice-level
                currentSliceLevelLength = 0.0f;
                currentSliceLevelWidth = 0.0f;
                currentSliceLevelHeight = 0.0f;
                
                // Determine sealed slice-level length
                for (Box *sealedBox in currentSliceLevelItems)
                {
                    currentSliceLevelLength += sealedBox.length;
                }
                
                // Determine sealed slice-level height and width
                Box *helpBox = (Box *)([[self->sliceLevelsPerLevel objectForKey:levelKey] objectAtIndex:sliceLevelsOnThisLevelNumber]);
                currentSliceLevelWidth = helpBox.width;
                currentSliceLevelHeight = helpBox.height;
                
                // Check if current box can be added to this slice-level
                if (box.height <= currentSliceLevelHeight && box.width <= currentSliceLevelWidth && box.length + currentSliceLevelLength <= self->storageLenght)
                {
                    //[[[self->sliceLevelsPerLevelWithBoxes objectForKey:levelKey] objectForKey:sliceLevelKey] addObject:box];
                    float potentialRemainingLength = self->storageLenght - (currentSliceLevelLength + box.length);
                    
                    if (worstFitCurrentRemainingLength < potentialRemainingLength)
                    {
                        worstFitCurrentRemainingLength = potentialRemainingLength;
                        worstFitLevelNumber = [levelKey intValue];
                        worstFitSliceLevelNumber = [sliceLevelKey intValue];
                    }
                    
                    placedCurrentBox = YES;
                }
                
                sliceLevelsOnThisLevelNumber += 1;
            }
        }
        
        // If no place for current box is found, in this algorithm it means that we need to open new slice-level for it
        if (NO == placedCurrentBox)
        {
            aCurrentLevelNumber = [self->sliceLevelsPerLevel count] != 0 ? [self->sliceLevelsPerLevel count] - 1 : 0;
            NSString *keyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
            
            if ([self->sliceLevelsPerLevelWithBoxes objectForKey:keyLevel])
            {
                // Entry exists, everything's fine
            }
            else
            {
                // No entry, add one
                [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:keyLevel];
            }
            
            // Go through levels and find out next slice-level ID
            aCurrentSliceLevelNumber = 0;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                aCurrentSliceLevelNumber += [[self->sliceLevelsPerLevel objectForKey:key] count];
            }
            
            // Go through level-slices on current level and find out remaining width on level
            aCurrentLevelWidth = 0.0f;
            for (Box *sliceLevel in [self->sliceLevelsPerLevel objectForKey:keyLevel])
            {
                aCurrentLevelWidth += sliceLevel.width;
            }
            
            // Find out previous used levels height so far
            aCurrentFilledLevelsHeight = 0.0f;
            for (NSString *key in [self->sliceLevelsPerLevel allKeys])
            {
                NSUInteger intKey = [key intValue];
                
                if (intKey < [self->sliceLevelsPerLevel count] - 1)
                {
                    Box *sampleSealedBox = [[self->sliceLevelsPerLevel objectForKey:key] objectAtIndex:0];
                    aCurrentFilledLevelsHeight += sampleSealedBox.height;
                }
            }
            
            // Check if box sides are within allowed values
            if (box.length <= self->storageLenght)
            {
                if (box.height + aCurrentFilledLevelsHeight <= self->storageHeight)
                {
                    if (box.width + aCurrentLevelWidth <= self->storageWidth)
                    {
                        // New slice-level for current box will be opened on current level
                        aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                        aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                        
                        if ([[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel])
                        {
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        else
                        {
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                        }
                        
                        // Seal currently added slice-level so it's width and height are not changable anymore
                        Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                        
                        if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                        {
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                        else
                        {
                            [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                        }
                    }
                    else
                    {
                        // New slice-level for current box will be opened on next level
                        if (box.width <= self->storageWidth)
                        {
                            // MANAGING REMAINED EMPTY SPACE
                            // Empty space which remained til the end of storage by width
                            // will be added to previously closed slice-level and thus expand it
                            
                            float remainedWidth = self->storageWidth - aCurrentLevelWidth;
                            
                            if (0.0f != remainedWidth)
                            {
                                // Locate the last sealed slice-level, make updated box and replace it
                                aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                                
                                Box *lastSealedSliceLevel = [[self->sliceLevelsPerLevel objectForKey:keyLevel] lastObject];
                                Box *updatedSealedSliceLevel = [[Box alloc] initWithWidth:(remainedWidth + lastSealedSliceLevel.width) 
                                                                                   length:self->storageLenght 
                                                                                   height:lastSealedSliceLevel.height];
                                
                                // Remove last sealed slice-level and add updated one
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeLastObject];
                                [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObject:updatedSealedSliceLevel];
                            }
                            
                            // FINALIZING CLOSING LEVEL JOBS (ADDING HEIGHT TO ARRAY, SLICE-LEVELS TO DICTIONARY)
                            
                            // Slice-level must be opened on new level, we are ceiling this current one
                            // All slice-levels must be adjusted to SAME size (height from HIGHEST slice-level on level)
                            float aCurrentHighestSliceLevelHeight = 0.0f;
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                if (aCurrentHighestSliceLevelHeight < sliceLevelBox.height)
                                {
                                    aCurrentHighestSliceLevelHeight = sliceLevelBox.height;
                                }
                            }
                            
                            NSMutableArray *sliceLevelsAdjusted = [NSMutableArray new];
                            
                            for (Box *sliceLevelBox in [self->sliceLevelsPerLevel objectForKey:keyLevel])
                            {
                                Box *adjustedSliceLevel = [[Box alloc] initWithWidth:sliceLevelBox.width 
                                                                              length:sliceLevelBox.length 
                                                                              height:aCurrentHighestSliceLevelHeight];
                                
                                [sliceLevelsAdjusted addObject:adjustedSliceLevel];
                            }
                            
                            // Clear all sealed slice-levels from current level and fill that level with
                            // adjusted sealed slice-levels which all have the same height
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] removeAllObjects];
                            [[self->sliceLevelsPerLevel objectForKey:keyLevel] addObjectsFromArray:sliceLevelsAdjusted];
                            
                            // At this moment we updated the level below and we need to place new slice-level on new level
                            aCurrentLevelNumber += 1;
                            //aCurrentSliceLevelNumber += 1;
                            
                            // New slice-level for current box will be opened on current level
                            aKeyLevel = [[NSNumber numberWithInteger:aCurrentLevelNumber] stringValue];
                            aKeySliceLevel = [[NSNumber numberWithInteger:aCurrentSliceLevelNumber] stringValue];
                            
                            [self->sliceLevelsPerLevelWithBoxes setObject:[NSMutableDictionary dictionary] forKey:aKeyLevel];
                            [[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] setObject:[NSMutableArray array] forKey:aKeySliceLevel];
                            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:aKeyLevel] objectForKey:aKeySliceLevel] addObject:box];
                            
                            // Seal currently added slice-level so it's width and height are not changable anymore
                            Box *sealedBox = [[Box alloc] initWithWidth:box.width length:self->storageLenght height:box.height];
                            
                            if ([self->sliceLevelsPerLevel objectForKey:aKeyLevel])
                            {
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                            else
                            {
                                [self->sliceLevelsPerLevel setObject:[NSMutableArray array] forKey:aKeyLevel];
                                [[self->sliceLevelsPerLevel objectForKey:aKeyLevel] addObject:sealedBox];
                            }
                        }
                        else
                        {
                            NSLog(@"Current box can't fit in storage since it's width is %f and storage width is %f!", box.width, self->storageWidth);
                        }
                    }
                }
                else
                {
                    NSLog(@"Current box can't fit in storage since it's height is %f and remaining height in storage is %f!", box.height, self->storageHeight - aCurrentFilledLevelsHeight);
                }
            }
            else
            {
                NSLog(@"Current box can't fit in storage since it's length is %f and storage length is %f!", box.length, self->storageLenght);
            }
        }
        else
        {
            // Found place where to best fit current box, just add it
            NSString *worstFitLevelKey = [[NSNumber numberWithInteger:worstFitLevelNumber] stringValue];
            NSString *worstFitSliceLevelKey = [[NSNumber numberWithInteger:worstFitSliceLevelNumber] stringValue];
            
            [[[self->sliceLevelsPerLevelWithBoxes objectForKey:worstFitLevelKey] objectForKey:worstFitSliceLevelKey] addObject:box];
        }
    }
    
    // Calculate current sealed slice-levels area
    float usedSliceLevelsArea = 0.0f;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    return usedSliceLevelsArea;
}

// PUBLIC: Detail Search Bin Packing Algorithm
- (void) detailSearchAlgorithm3DForgivenBoxes:(NSMutableArray *)givenBoxes
{
    NSInteger size = [givenBoxes count];
    
    self->permutationCount = 0;
    
    int indexes[size];
    
    for (NSUInteger i = 0; i < size; i++)
    {
        indexes[i] = i;
    }
    
    [self permutationArray3D:indexes 
             initialPosition:0 
                 sizeOfArray:size 
                  givenBoxes:givenBoxes];
    
    // At this moment, permutation algorithm ended
    // We should now return best values into their original variables
    // so that showStorageUsageDetails method can show proper values
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevelWithBoxes removeAllObjects];
    
    [self->sliceLevelsPerLevel addEntriesFromDictionary:self->bestSliceLevelsPerLevel];
    [self->sliceLevelsPerLevelWithBoxes addEntriesFromDictionary:self->bestSliceLevelsPerLevelWithBoxes];

}

// PUBLIC: Bin Packing algorithm with usage of Genetic Algorithm
// RETURNS: Percentage of used space with slice-levels
// NOTE: Fitness function choice: 0 - Next Fit
//                                1 - First Fit
//                                2 - Best Fit
//                                3 - Worst Fit
- (void) searchWithUsageOfGeneticAlgorithm3DForRectangles:(NSMutableArray *)bpBoxes
                                numberOfUnitsInGeneration:(NSUInteger)unitNumber
                                      numberOfGenerations:(NSUInteger)generationsNumber 
                                 mutationFactorPercentage:(NSUInteger)mutationFactor 
                                            elitismFactor:(NSUInteger)elitismFactor 
                                  numberOfCrossoverPoints:(NSUInteger)crossoverPoints 
                                 fitnessFunctionSelection:(NSUInteger)choice
{
    // Initialize GA factory object
    NSUInteger currentNumberOfGenerations = 0;
    GeneticAlgorithmFactory3D *gaFactory = [[GeneticAlgorithmFactory3D alloc] initWithNumberOfUnitsInGeneration:unitNumber 
                                                                                                     boxesArray:bpBoxes 
                                                                                                  elitismFactor:elitismFactor 
                                                                                                   storageWidth:self->storageWidth  
                                                                                                  storageHeight:self->storageHeight     
                                                                                                  storageLength:self->storageLenght];
    // Create initial population and calculate costs
    [gaFactory generateInitialPopulation];
    
    switch (choice)
    {
        case 0: [gaFactory calculateGenerationCostForFitnessFunction1:nextFitAlgorithm3DFF1 
                                                     fitnessFunction2:nextFitAlgorithm3DFF2];
            break;
        case 1: [gaFactory calculateGenerationCostForFitnessFunction1:firstFitAlgorithm3DFF1 
                                                     fitnessFunction2:firstFitAlgorithm3DFF2];
            break;
        case 2: [gaFactory calculateGenerationCostForFitnessFunction1:bestFitAlgorithm3DFF1 
                                                     fitnessFunction2:bestFitAlgorithm3DFF2];
            break;
        case 3: [gaFactory calculateGenerationCostForFitnessFunction1:worstFitAlgorithm3DFF1 
                                                     fitnessFunction2:worstFitAlgorithm3DFF2];
            break;
        default: [gaFactory calculateGenerationCostForFitnessFunction1:bestFitAlgorithm3DFF1 
                                                      fitnessFunction2:bestFitAlgorithm3DFF2];
            break;
    }
    
    // GA loop
    do
    {
        currentNumberOfGenerations += 1;
        
        // Do mating and mutation
        [gaFactory mate:elitismFactor];
        [gaFactory mutate:mutationFactor];
        
        // Swap generations and calculate costs
        [gaFactory generationSwap];
        
        switch (choice)
        {
            case 0: [gaFactory calculateGenerationCostForFitnessFunction1:nextFitAlgorithm3DFF1 
                                                         fitnessFunction2:nextFitAlgorithm3DFF2];
                break;
            case 1: [gaFactory calculateGenerationCostForFitnessFunction1:firstFitAlgorithm3DFF1 
                                                         fitnessFunction2:firstFitAlgorithm3DFF2];
                break;
            case 2: [gaFactory calculateGenerationCostForFitnessFunction1:bestFitAlgorithm3DFF1 
                                                         fitnessFunction2:bestFitAlgorithm3DFF2];
                break;
            case 3: [gaFactory calculateGenerationCostForFitnessFunction1:worstFitAlgorithm3DFF1 
                                                         fitnessFunction2:worstFitAlgorithm3DFF2];
                break;
            default: [gaFactory calculateGenerationCostForFitnessFunction1:bestFitAlgorithm3DFF1 
                                                          fitnessFunction2:bestFitAlgorithm3DFF2];
                break;
        }
        
    } while (currentNumberOfGenerations < generationsNumber);
    
    [self->boxes removeAllObjects];
    [self->boxes addObjectsFromArray:bpBoxes];
    
    [self->sliceLevelsPerLevel removeAllObjects];
    [self->sliceLevelsPerLevel addEntriesFromDictionary:gaFactory.sliceLevelsPerLevel];
}

// PRIVATE: Recursive method which generates permutations with usage of backstepping algorithm
//          and calculates number of used bins with usage of FF
- (void) permutationArray3D:(int *)array 
            initialPosition:(int)position 
                sizeOfArray:(int)size 
                 givenBoxes:(NSMutableArray *)givenBoxes
{
    self->lowestSliceLevelUsage = (float)INT_MAX;
    
    if (position == size - 1)
        
    {
        NSMutableArray *newBoxesPermutation = [NSMutableArray new];
        self->permutationCount += 1;
        
        for (NSUInteger i = 0; i < size; ++i)
        {
            // Generating items array based on indexes array
            [newBoxesPermutation addObject:[givenBoxes objectAtIndex:array[i]]];
        }
        
        // Now we need to check for current item order how many bins we need
        float usedSliceLevelArea = [self bestFitAlgorithm3DForGivenBoxes:newBoxesPermutation];
        
        if (usedSliceLevelArea <= self->lowestSliceLevelUsage)
        {
            [self->bestSliceLevelsPerLevel removeAllObjects];
            [self->bestSliceLevelsPerLevelWithBoxes removeAllObjects];
            
            [self->bestSliceLevelsPerLevel addEntriesFromDictionary:self->sliceLevelsPerLevel];
            [self->bestSliceLevelsPerLevelWithBoxes addEntriesFromDictionary:self->sliceLevelsPerLevelWithBoxes];
            
            self->lowestSliceLevelUsage = usedSliceLevelArea;
        }
        
    }
    else
    {
        for (int i = position; i < size; i++)
        {
            swap3D(&array[position], &array[i]);
            
            [self permutationArray3D:array 
                     initialPosition:position+1 
                         sizeOfArray:size 
                          givenBoxes:givenBoxes];
            
            swap3D(&array[position], &array[i]);
        }
    }
}

// PRIVATE: Used for permutation generation
void swap3D(int *first, int *second)
{
    int temp = *first;
    *first = *second;
    *second = temp;
}

// PUBLIC: Print storage usage information
- (void) showStorageUsageDetails
{
    float totalBoxesArea = 0.0f;
    float totalStorageArea = 0.0f;
    float usedSliceLevelsArea = 0.0f;
    
    totalStorageArea = self->storageWidth * self->storageLenght * self->storageHeight;
    
    for (NSString *key in self->sliceLevelsPerLevel)
    {
        NSMutableArray *sliceLevelsInLevel = [self->sliceLevelsPerLevel objectForKey:key];
        
        for (Box *sliceLevel in sliceLevelsInLevel)
        {
            usedSliceLevelsArea += sliceLevel.width * sliceLevel.height * sliceLevel.length;
        }
    }
    
    for (Box *box in self->boxes)
    {
        totalBoxesArea += box.width * box.height * box.length;
    }
    
    NSLog(@"Used storage: / storage area: %.2f / %.2f [%.2f%%]", usedSliceLevelsArea, totalStorageArea, usedSliceLevelsArea / totalStorageArea * 100.0f);
    NSLog(@"In theory optimal usage area: %.2f%%", totalBoxesArea / totalStorageArea * 100.0f);
    NSLog(@"Wasted space from used area: %.2f%%", (usedSliceLevelsArea - totalBoxesArea) / usedSliceLevelsArea * 100.0f);
}

@end
