#ifndef BYEMESSAGEIMPL_H
#define BYEMESSAGEIMPL_H

#include <cstdio>

#include "abs_msg_impl.hh"

class ByeMessageImpl final : public AbsMessageImpl {
 public:
  ByeMessageImpl() = default;
  ~ByeMessageImpl() override = default;

  void SendMessage() override { printf("Goodbye\n"); }
};

#endif
