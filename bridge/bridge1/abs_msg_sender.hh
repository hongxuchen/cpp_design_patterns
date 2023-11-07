#ifndef ABSMSGSENDER_H
#define ABSMSGSENDER_H

#include "abs_msg_impl.hh"

class AbsMsgSender {

 public:
  virtual ~AbsMsgSender() = default;

  virtual void sendMessage() = 0;
  virtual void setMessage(AbsMessageImpl* impl) = 0;

 protected:
  AbsMsgSender() {}
};

#endif
