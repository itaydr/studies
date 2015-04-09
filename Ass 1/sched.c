#define DEFAULT 1
#define FRR 2
#define FCFS 3
#define CFS 4

#if SCHEDFLAG == DEFAULT
#define XX 1
#elif SCHEDFLAG == FRR
#define XX 2
#elif SCHEDFLAG == FCFS
#define XX 3
#elif SCHEDFLAG == CFS
#define XX 4
#endif