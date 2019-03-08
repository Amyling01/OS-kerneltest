#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <asm/nmi.h>
#include <linux/kprobes.h>
#include <asm/traps.h>
#include <linux/delay.h>

static int cpu_num =0;
static int time_out=5;
static int cpu_status=1;

module_param(cpu_num, int, 0644);
module_param(time_out, int, 0644);
module_param(cpu_status, int, 0644);

int my_nmi_handler(void)
{
	int i;
	for (i = 0; i < 6000; i++)
        {
            udelay(1000);
        }
	dump_stack();
	printk("register my nmi handler on cpu%d: dump kernel stack.\n",cpu_num);
	return 0;
}

static int register_nmi_handler_init (void)
{
	int ret;
	ret=register_nmi_handler(cpu_num,my_nmi_handler);
	if (ret != 0)
	{
		printk("register nmi handler failed!\n");
		return -1;
	}

	printk("register nmi handler on cpu:%d,timeout:%d,nmistatus:%d.",cpu_num,time_out,cpu_status);

	nmi_set_timeout(cpu_num,time_out);
	nmi_set_active_state(cpu_num,cpu_status);
	
	return 0;  
}

static void register_nmi_handler_exit (void)
{
	nmi_set_active_state(cpu_num,0);
	printk("nmi watchdog test end!\n");
}

module_init(register_nmi_handler_init);
module_exit(register_nmi_handler_exit);
MODULE_LICENSE("GPL");


