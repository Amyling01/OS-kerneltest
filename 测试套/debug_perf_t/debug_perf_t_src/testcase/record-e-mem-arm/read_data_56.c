#include<stdio.h>
#include<stdlib.h>

static int read_data=1;

int func(int n)
{
    int planck=1;
    if(n>1)
    {
        return func(n-1)+planck;
    }
    else if(n==1)
    {

        return read_data;
    }
}


int read_test_1(void)
{
    int read_1;
   return func(1);
}
int read_test_2(void)
{
    int read_2;
    return read_test_1();
}
int read_test_3(void)
{
   int read_3;
   return read_test_2();
}
int read_test_4(void)
{
    int read_4;
    return read_test_3();
}

int main(int argc,char **argv)
{
    int arg=0;
    int ret=0;
    arg=atoi(argv[1]);
    //ret=func(arg);
    ret=read_test_4();
    printf("THE func exce return is %d\n",ret);
    return 0;
}
