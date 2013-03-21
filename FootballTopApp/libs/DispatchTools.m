//
//  DispatchTools.m
//  IPhoneSpeedTracker
//
//  Created by destman on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DispatchTools.h"


@implementation DispatchTask

@synthesize completeBlock,executeBlock;
@synthesize isCancelled,isNetwork,isStarted;

- (NSString *) description
{
    return @"<DispatchTask>";
}

+ (DispatchTask*) taskWithExecuteBlock:(DispatchBlock)executeBlock andCompletitionBlock:(DispatchBlock)completeBlock
{
    DispatchTask *task = [[DispatchTask alloc] init];
    task.executeBlock = executeBlock;
    task.completeBlock = completeBlock;
    return AUTORELEASE(task);
}

- (id) initNetworkTaskWithExecuteBlock:(DispatchBlock)executeBlock_in andCompletitionBlock:(DispatchBlock)completeBlock_in
{
    if( (self=[self init]) )
    {
        isNetwork=YES;
        self.executeBlock = executeBlock_in;
        self.completeBlock = completeBlock_in;
    }
    return self;
}


+ (DispatchTask*) networkTaskWithExecuteBlock:(DispatchBlock)executeBlock andCompletitionBlock:(DispatchBlock)completeBlock
{
    DispatchTask *task = [[DispatchTask alloc] initNetworkTaskWithExecuteBlock:executeBlock andCompletitionBlock:completeBlock];
    return AUTORELEASE(task);
}

- (void)  finishNetworkTask
{
    [[DispatchTools Instance] finishTask:self];
}

- (BOOL)isEqual:(id)anObject
{
    return anObject==self;
} 

- (void) cancelTask
{
    self.isCancelled = YES;
}

#if !HAVE_ARC
- (void) dealloc
{
    [params release];
    [completeBlock release];
    [executeBlock release];
    [super dealloc];
}
#endif

- (id) init
{
    if( (self = [super init]) )
    {
        params = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) setObject:(id)anObject forKey:(id)aKey
{
    [params setObject:anObject forKey:aKey];
}

- (id) objectForKey:(NSString *)key
{
    return [params objectForKey:key];
}

- (void) removeObjectForKey:(id)aKey
{
    [params removeObjectForKey:aKey];
}

- (NSUInteger) count
{
    return [params count];
}

- (NSEnumerator *) keyEnumerator
{
    return [params keyEnumerator];
}

@end


@implementation DispatchTools

+(DispatchTools *) Instance
{
    static DispatchTools *instance;
    if(instance==0)
    {
        instance = [[DispatchTools alloc] init];
    }
    return instance;
}

+(void) doOnMainThread:(dispatch_block_t)block
{
    if([NSThread isMainThread])
    {
        block();
    }else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


-(void) doTask:(DispatchTask *)task 
{
    if(!task.isStarted) @autoreleasepool 
    {
        if(task.isNetwork)
        {
            if(task.isCancelled)
            {
                task.isStarted = YES;
                [task finishNetworkTask];
            }else
            {
                if(_networkSemaphore == 0)
                {
                    [self setMaxNetworkTasks:DEFAULT_MAX_NETWORK_TASKS];
                }
                if(dispatch_semaphore_wait(_networkSemaphore,DISPATCH_TIME_NOW)==0)
                {
                    task.isStarted = YES;
                    [DispatchTools doOnMainThread:^
                     {
                         task.executeBlock(task);
                     }];
                }    
            }
        }else
        {
            task.isStarted = YES;
            if(!task.isCancelled)
            {
                task.executeBlock(task);
            }
            [self finishTask:task];
        }
    }
}

- (id) init
{
    if( (self=[super init]) )
    {
        _tasks = [[NSMutableArray alloc] init];
        _tasks_queue  = dispatch_queue_create("com.appannex.gentools.generalTasks",DISPATCH_QUEUE_SERIAL);
        _tasks_worker = dispatch_queue_create("com.appannex.gentools.generalTasksWorker",DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void) setMaxNetworkTasks:(int) val
{
    if(_networkSemaphore==0)
    {
        _networkSemaphore = dispatch_semaphore_create(val);
    }else
    {
        dbgLog(@"Warning: calling setMaxNetworkTasks second time. Ignore");
    }
}

-(void) addGeneralTaskToMainThread:(DispatchTask *)task
{
    if(task==nil)
        return;
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self doTask:task];
                   });
}

-(void) cancelAllTasks
{
    dispatch_sync(_tasks_queue,^
                  {
                      for (DispatchTask *item in _tasks)
                      {
                          [item cancelTask];
                      }
                  });
}

-(void) processGeneralTasks
{
    __block NSMutableArray *tasksToStart = [[NSMutableArray alloc] init];
    dispatch_sync(_tasks_queue,^
                   {
                       for (DispatchTask *task in _tasks)
                       {
                           if(!task.isStarted)
                           {
                               [tasksToStart addObject:task];
                           }
                       }
                   });
    if([tasksToStart count]==0) //nothing to do
    {
        RELEASE(tasksToStart);
        return;
    }
    dispatch_async(_tasks_worker, ^(void) //launch worker
                 {
                     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                     dispatch_apply([tasksToStart count], queue, ^(size_t i) 
                     {
                         DispatchTask *nextTask=[tasksToStart objectAtIndex:i];
                         [self doTask:nextTask];
                     });
                     RELEASE(tasksToStart);
                     [self processGeneralTasks]; //check if any task left
                 });    
}

-(void) finishTask:(DispatchTask *)task
{
    [DispatchTools doOnMainThread:^
     {
         task.completeBlock(task);
     }];
    dispatch_sync(_tasks_queue,^
                  {
                      if(task.isNetwork)
                      {
                          dispatch_semaphore_signal(_networkSemaphore);
                      }
                      [_tasks removeObject:task];
                  });
    [self processGeneralTasks];
}
    
-(void) addTask:(DispatchTask *)task
{
    if(task!=nil) 
    {
        dispatch_sync(_tasks_queue,^
                      {
                          [_tasks addObject:task];   //add task if not nil
                      });        
    }
    [self processGeneralTasks];       //process tasks if any
}

@end
	