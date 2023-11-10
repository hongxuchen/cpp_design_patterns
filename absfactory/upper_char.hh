#ifndef _UPPERPRINTER_H
#define _UPPERPRINTER_H

#include <cstdio>

#include "abs_char.hh"

class UpperChar : public AbsChar {
 public:
  UpperChar() = default;
  ~UpperChar() override = default;
   void PrintChar() override { printf("HELLO UPPER!\n"); }
};

#endif  // _UPPERPRINTER_H
