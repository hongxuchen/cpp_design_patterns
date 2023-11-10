#ifndef _HELLOMESSAGEIMPL_H
#define _HELLOMESSAGEIMPL_H

#include <cstdio>

#include "abs_msg_impl.hh"

class HelloMessageImpl : public AbsMessageImpl {
 public:
  HelloMessageImpl() = default;
  ~HelloMessageImpl() override = default;

  void SendMessage() override { printf("Hello\n"); }
};

#endif
