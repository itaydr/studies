// Job

enum jobstate { JOB_S_UNUSED, JOB_S_EMBRYO };

struct job {
  char *commandName;   
  int jid;
  enum jobstate state;
};