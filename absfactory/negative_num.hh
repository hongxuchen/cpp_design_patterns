#ifndef NAGATIVE_NUM_H 
#define NAGATIVE_NUM_H 

#include "abs_num.hh"
#include <stdio.h>

class NegativeNum : public AbsNum {

 public:
  NegativeNum() {}
  virtual ~NegativeNum() {}
  virtual void printNum() override { printf("-1.0000\n"); }
};

#endif
