#ifndef LOWER_CHAR_H 
#define LOWER_CHAR_H 

#include "abs_char.hh"
#include <stdio.h>

class LowerChar : public AbsChar {
 public:
  LowerChar() {}
  virtual ~LowerChar() {}
  void printChar() override { printf("hello lower!\n"); }
};

#endif
