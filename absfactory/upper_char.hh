#ifndef _UPPERPRINTER_H
#define _UPPERPRINTER_H

#include "abs_char.hh"
#include <stdio.h>

class UpperChar : public AbsChar {
 public:
  UpperChar() {}
  ~UpperChar() {}
  virtual void printChar() override { printf("HELLO UPPER!\n"); }
};

#endif  // _UPPERPRINTER_H
