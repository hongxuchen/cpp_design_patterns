#ifndef _POSITIVENUMPRINTER_H
#define _POSITIVENUMPRINTER_H

#include "abs_num.hh"
#include <stdio.h>

class PositiveNum : public AbsNum {

 public:
  PositiveNum() {}
  virtual ~PositiveNum() {}
  virtual void printNum() override { printf("+1.0000\n"); }
};

#endif  // _POSITIVENUMPRINTER_H
