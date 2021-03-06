#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/user.h>

int main(int argc, char **argv)
{
    pid_t child;
    long ptrace_ret;

    if(argc != 2) 
    {
        printf("Usage: %s <pid to be traced>\n", argv[0]);
        exit(1);
    }

    child = atoi(argv[1]);
    ptrace_ret = ptrace(PTRACE_SEIZE, child, NULL, PTRACE_O_TRACECLONE);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_SEIZE process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_SEIZE CLONE PASS\n");
    ptrace_ret = ptrace(PTRACE_KILL, child, NULL, NULL);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_KILL error %d \n", errno);
        exit(1);
    }
    printf("ptrace PTRACE_KILL PASS\n");

    exit(0);
}
