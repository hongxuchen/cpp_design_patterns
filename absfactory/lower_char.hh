#ifndef LOWER_CHAR_H
#define LOWER_CHAR_H

#include <cstdio>

#include "abs_char.hh"

class LowerChar : public AbsChar {
 public:
  LowerChar() = default;
  ~LowerChar() override = default;
  void PrintChar() override { printf("hello lower!\n"); }
};

#endif
