// Job

enum jobstate { JOB_S_UNUSED, JOB_S_EMBRYO };

struct job {
  char commandName[32];   
  int jid;
  enum jobstate state;
};