#ifndef _HELLOMESSAGEIMPL_H
#define _HELLOMESSAGEIMPL_H

#include <cstdio>

#include "abs_msg_impl.hh"

class HelloMessageImpl final : public AbsMessageImpl {
 public:
  HelloMessageImpl() = default;
  ~HelloMessageImpl() override = default;

  void sendMessage() override { printf("Hello\n"); }
};

#endif
