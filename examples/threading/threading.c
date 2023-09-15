#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    
    struct thread_data* fargs = (struct thread_data *) thread_param;
    int ms_obtain = fargs->wait_to_obtain_ms;
    int ms_release = fargs->wait_to_release_ms;
    fargs->thread_complete_success = true;

    // wait before obtaining mutex
    usleep(ms_obtain);
    
    int rc = pthread_mutex_lock(fargs->p_mutex);
    if (rc != 0) {
        ERROR_LOG("Failed to obtain mutex!");
        fargs->thread_complete_success = false;
    }
    else {
        // wait before releasing (fake processing)
        usleep(ms_release);

        rc = pthread_mutex_unlock(fargs->p_mutex);
        if (rc != 0) {
            ERROR_LOG("Failed to release mutex!");
            fargs->thread_complete_success = false;
        }
    }
    
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
    */

    struct thread_data* thread_param = (struct thread_data *)malloc(sizeof(struct thread_data));

    thread_param->p_mutex = mutex;
    thread_param->wait_to_obtain_ms = wait_to_obtain_ms;
    thread_param->wait_to_release_ms = wait_to_release_ms;

/*
    if (pthread_mutex_init(thread_param->p_mutex, NULL) != 0) {
        ERROR_LOG("Failed to init mutex!");
        return false;
    }
    */

    int rc = pthread_create(thread, NULL, &threadfunc, thread_param);

    if (rc != 0) {
        ERROR_LOG("Failed to create thread!");
        return false;
    }

    //pthread_join(*thread, (void**)&thread_param);

    //pthread_mutex_destroy(thread_param->p_mutex);

    thread_param->thread_complete_success = true;


    return thread_param->thread_complete_success;
}

