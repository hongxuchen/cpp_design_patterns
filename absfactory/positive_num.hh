#ifndef _POSITIVENUMPRINTER_H
#define _POSITIVENUMPRINTER_H

#include <cstdio>

#include "abs_num.hh"

class PositiveNum : public AbsNum {
 public:
  PositiveNum() = default;
  ~PositiveNum() override = default;
  void PrintNum() override { printf("+1.0000\n"); }
};

#endif  // _POSITIVENUMPRINTER_H
