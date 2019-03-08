#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

/* For each probe you need to allocate a kprobe structure */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
static struct kprobe kp = {
	.symbol_name	= "_do_fork",
};
static struct kprobe kp2 = {
        .symbol_name    = "_do_fork",
};
static struct kprobe kp3 = {
        .symbol_name    = "_do_fork",
};
#else
static struct kprobe kp = {
        .symbol_name    = "do_fork",
};
static struct kprobe kp2 = {
        .symbol_name    = "do_fork",
};
static struct kprobe kp3 = {
        .symbol_name    = "do_fork",
};
#endif

/* kprobe pre_handler: called just before the probed instruction is executed */
static int handler_pre(struct kprobe *p, struct pt_regs *regs)
{
	printk(KERN_DEBUG "pre_handler\n");
	return 0;
}
/* kprobe post_handler: called after the probed instruction is executed */
static void handler_post(struct kprobe *p, struct pt_regs *regs,
				unsigned long flags)
{
	printk(KERN_DEBUG "post_handler\n");
}
/*
 * fault_handler: this is called if an exception is generated for any
 * instruction within the pre- or post-handler, or when Kprobes
 * single-steps the probed instruction.
 */
static int handler_fault(struct kprobe *p, struct pt_regs *regs, int trapnr)
{
	printk(KERN_DEBUG "fault_handler: p->addr = 0x%p, trap #%d\n",
		p->addr, trapnr);
	/* Return 0 because we don't handle the fault. */
	return 0;
}
static int __init kprobe_init(void)
{
	int ret;
	kp.pre_handler = handler_pre;
	kp.post_handler = handler_post;
	kp.fault_handler = handler_fault;

	ret=register_kprobe(&kp);
	if (ret < 0) {
                printk(KERN_DEBUG "register_probes failed\n");
                return -1;
        }

	ret=register_kprobe(&kp2);
	if (ret < 0) {
       		unregister_kprobe(&kp);
	        printk(KERN_DEBUG "register_probes2 failed\n");
                return -1;
        }

	ret=register_kprobe(&kp3);
	if (ret < 0) {
		unregister_kprobe(&kp);
                unregister_kprobe(&kp2);
		printk(KERN_DEBUG "register_probes3 failed\n");
                return -1;
        }
	return 0;
}

static void __exit kprobe_exit(void)
{
	unregister_kprobe(&kp);
	unregister_kprobe(&kp2);
	unregister_kprobe(&kp3);
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");
