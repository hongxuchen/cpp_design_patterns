#ifndef NAGATIVE_NUM_H
#define NAGATIVE_NUM_H

#include <cstdio>

#include "abs_num.hh"

class NegativeNum : public AbsNum {
 public:
  NegativeNum() = default;
  ~NegativeNum() override = default;
  void PrintNum() override { printf("-1.0000\n"); }
};

#endif
