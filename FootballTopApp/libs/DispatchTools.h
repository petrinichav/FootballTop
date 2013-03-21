//
//  DispatchTools.h
//  IPhoneSpeedTracker
//
//  Created by destman on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MAX_NETWORK_TASKS 3

typedef enum TypeError
{
    DeviceIsActivated   = 409,
    EventError          = 403,
    Unavailable         = 404,
    InternalServerError = 500,
    DBNotPrepared       = 202,
    DBNotNecessary      = 204,
}TypeError;

enum
{
    EventExpiredError   = 0,
    AvailableActivation = 15,
};


@class DispatchTask;
typedef void(^DispatchBlock)(DispatchTask *item);

/*! @interface DispatchTask
 *  @brief Base class for asyncronys tasks.
 *
 *  Storage task parameters and blocks that called at different time of task execution. 
 */
@interface DispatchTask : NSMutableDictionary
{
    DispatchBlock       completeBlock;
    DispatchBlock       executeBlock;
    BOOL                isCancelled,isNetwork,isStarted;
    
    /*!Storage for task parameters*/
    NSMutableDictionary *params;
}

/*! Initialize network task
    @param executeBlock - block that called to start network task.
    @param completeBlock - block that called after task competes.
    @returns initialized DispatchTask object.
 */
- (id) initNetworkTaskWithExecuteBlock:(DispatchBlock)executeBlock andCompletitionBlock:(DispatchBlock)completeBlock;

/*! Allocates and initilze general task.
    @param executeBlock - block that called to perform asyncronys task. Can execute not on main thread.
    @param completeBlock - called shortly after executeBlock finished.
    @returns allocated and initialized DispatchTask object.
 */
+ (DispatchTask*) taskWithExecuteBlock:(DispatchBlock)executeBlock andCompletitionBlock:(DispatchBlock)completeBlock;

/*! Allocates and initilze network task.
 @param executeBlock - block that called to start network task.
 @param completeBlock - block that called after task competes.
 @returns allocated and initialized DispatchTask object.
 */
+ (DispatchTask*) networkTaskWithExecuteBlock:(DispatchBlock)executeBlock andCompletitionBlock:(DispatchBlock)completeBlock;


/*! Cancel task. Tasks must check state to handle this correctly.*/
- (void)  cancelTask;

/*!Called from network task to finish it.*/
- (void)  finishNetworkTask;

/*! Block that executes after task is finished. Called in main thread*/
@property (copy)        DispatchBlock       completeBlock;
/*! Block that starts network task or perorms general task*/
@property (copy)        DispatchBlock       executeBlock;
/*! Set to YES if task is cancelled. Check it in your tasks if possible to break task execution*/
@property (assign)      BOOL                isCancelled;
/*! YES if this is network task*/
@property (readonly)    BOOL                isNetwork;
/*! YES if task started. No if tasks that is in queue.*/
@property (assign)      BOOL                isStarted;
@end



/*! @interface DispatchTools
 *  @brief Singletone class that handle asyncronys tasks.
 */
@interface DispatchTools : NSObject 
{
    /*!Array with all tasks.*/
    NSMutableArray      *_tasks;
    /*!Queue that is used to syncronize acess to _tasks*/
    dispatch_queue_t     _tasks_queue;
    /*!Queue that is used to perform general taks.*/
    dispatch_queue_t     _tasks_worker;
    /*!Semaphore used to limit number of network tasks*/
    dispatch_semaphore_t _networkSemaphore;
}

/*! @returns singletone instance of DispathcTools */
+(DispatchTools *) Instance;

/*! Execute block on main thread.
 *  @param block block to execute at main thread
 */
+(void) doOnMainThread:(dispatch_block_t)block;

/*! Called by tasks when they are finished.
 *  @param task task that was finished.
 */
-(void) finishTask:(DispatchTask *)task;

/*! Set maximun number of network tasks. Call this function before adding any network task.
 *  @param val - maximum number of concurrent network tasks.
 */
-(void) setMaxNetworkTasks:(int) val;

/*! Adds task in queue.
    @param task task to add in queue.
 */
-(void) addTask:(DispatchTask *)task;
/*! Cancel all tasks.*/
-(void) cancelAllTasks;

/*! Executes task at main thread
 @param task task to execute at main thread.
 */
-(void) addGeneralTaskToMainThread:(DispatchTask *)task;

@end
