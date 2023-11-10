#ifndef ABSMSGSENDER_H
#define ABSMSGSENDER_H

#include <memory>

#include "abs_msg_impl.hh"

using MsgTy = std::shared_ptr<AbsMessageImpl>;

class AbsMsgSender {
 public:
  virtual ~AbsMsgSender() = default;

  virtual void SendMessage() = 0;
  virtual void SetMessage(MsgTy impl) = 0;

 protected:
  AbsMsgSender() {}
};

#endif
