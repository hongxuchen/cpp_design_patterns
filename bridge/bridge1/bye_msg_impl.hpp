#ifndef BYEMESSAGEIMPL_H
#define BYEMESSAGEIMPL_H

#include "abs_msg_impl.hpp"
#include <stdio.h>

class ByeMessageImpl final : public AbsMessageImpl {

 public:
  ByeMessageImpl() {}
  virtual ~ByeMessageImpl() {}

  virtual void sendMessage() { printf("Goodbye\n"); }
};

#endif
