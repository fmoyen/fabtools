#include <stdlib.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

extern pthread_attr_t pthread_attr_default;
pthread_mutex_t lock;
long lmsize = 102400;
unsigned long long ll;
long syscalls = 300;

void sighand(int sig)
{
        unsigned long i;
        switch(sig){
           case SIGDANGER:{ /* handle sigdanger */
                printf("Received sigdanger - System low on paging space!!\n");
                exit(1);
           }
           default:
                printf("Received unknown signal\n");
        }
}

int *tab;
typedef struct {
    pthread_t t_id;
    char* buf;
    pthread_mutex_t lock;
    long long ll;
    long long oll;
} mstruct ;

/* ==========================================================================
 * new_thread();
 */
void* new_thread(void* arg0)
{
    long csyscalls = syscalls;
    mstruct *ms = (mstruct*) arg0;
    long i,j;
    long lsizebuf = lmsize;
    char* buf = ms->buf;
    pid_t t;
    char* mybuf;

    if ((mybuf = malloc(lsizebuf)) == NULL)
    {
	perror ("malloc");
	exit(2);
    }
    while (1) {
	
	for (i=0;i<1000;i++) {
		memcpy(mybuf, buf, lsizebuf); 
	}
        pthread_mutex_lock(&ms->lock);
        ms->ll++;
        pthread_mutex_unlock(&ms->lock);
	
   }
   pthread_exit((void *) 0);
}

/* ==========================================================================
 * usage();
 */
void usage(char* argv0)
{
    fprintf(stderr,"%s [-m size] [-p count]\n", argv0);
    fprintf(stderr,"	-m : memory allocated per thread (default 1024000 bytes)\n");
    fprintf(stderr,"	-c : number of threads (default 8)\n");
    fprintf(stderr,"	-t : iteration delay in seconds (default 5 sec)\n");
    errno = 0;
}

main(int argc, char **argv)
{
        int rval;
        struct timeval starttime, endtime;
        pthread_t *thread_id;
        long *t_id;
        long count = 8; /* (long) sysconf (_SC_NPROCESSORS_ONLN);*/
	long  delay=5;
        int debug = 0;
        long i;
	long long ll;
	mstruct* mstab;

        char word[256];

    /* Getopt variables. */
    extern int optind, opterr;
    extern char *optarg;
    char scale[10];

        /* Shut timer off */

        while ((word[0] = getopt(argc, argv, "m:c:t:?")) != (char)EOF) {
                switch (word[0]) {
                case 'm':
			sscanf(optarg, "%ld%s", &lmsize, scale);
			switch (scale[0]) {
                                case 'm': ; case 'M' : lmsize*=1024L*1024L; break;
                                case 'k': ; case 'K' : lmsize*=1024L; break;
                                case 'g': ; case 'G' : lmsize*=1024L*1024L*1024L; break;
                                default :;
                        }
                        break;
                case 't':
                        delay = atol(optarg); 
			if (delay == 0) {
				usage(argv[0]);
                        	return(-1);
			}
                        break;
                case 'c':
                        count = atol(optarg); 
                        break;
                case '?':
                        usage(argv[0]);
                        return(0);
                default:
                        usage(argv[0]);
                        return(-1);
                }
        }

        ll = 0;

	signal(SIGDANGER,sighand);

	if ((tab = malloc (count*lmsize*sizeof(char))) == NULL ||
            (thread_id = malloc (count*sizeof(pthread_t))) == NULL ||
            (mstab = malloc (count*sizeof(mstruct))) == NULL ||
            (t_id = malloc (count*sizeof(int))) == NULL) {
		perror ("malloc");
		exit (2);
	}
        pthread_mutex_init(&lock, NULL);

        for (i = 0; i < count; i++) {
                mstab[i].t_id=i;
                mstab[i].ll=0;
                mstab[i].oll=0;
                mstab[i].buf=(char*) ((long)tab+(long)(i*sizeof(char)));
        	pthread_mutex_init(&mstab[i].lock, NULL);
                if ((rval = pthread_create(&thread_id[i], NULL, new_thread, (char*) &mstab[i]))) {
                        printf("Bad pthread create routine (%d)\n", rval);
                        exit(1);
                }
        }
	while (1)
	{
		sleep (delay);
		ll = 0;
        	for (i = 0; i < count; i++) {
			pthread_mutex_lock(&mstab[i].lock);
			if (mstab[i].oll > mstab[i].ll)
			{
				ll += ~0 - mstab[i].oll + mstab[i].ll;
				mstab[i].oll = mstab[i].ll;
			} else {
				ll += mstab[i].ll - mstab[i].oll;
				mstab[i].oll = mstab[i].ll;
			}
			pthread_mutex_unlock(&mstab[i].lock);
		}
		printf ("%lld\n", ll);
	}
        return 0;
}

