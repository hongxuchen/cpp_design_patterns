#ifndef _HELLOMESSAGEIMPL_H
#define _HELLOMESSAGEIMPL_H

#include "abs_msg_impl.hh"
#include <stdio.h>

class HelloMessageImpl final : public AbsMessageImpl {

 public:
  HelloMessageImpl() {}
  virtual ~HelloMessageImpl() {}

  virtual void sendMessage() { printf("Hello\n"); }
};

#endif
