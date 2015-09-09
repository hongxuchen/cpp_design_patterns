#ifndef CHARMESSAGESENDER_H
#define CHARMESSAGESENDER_H

#include "abs_msg_sender.hh"

class CharMessageSender : public AbsMsgSender {

 public:
  CharMessageSender() : _impl(nullptr) {}

  ~CharMessageSender() {}

  void sendMessage() {
    if (_impl) _impl->sendMessage();
  }

  void setMessage(AbsMessageImpl* impl) { _impl = impl; }

 protected:
  AbsMessageImpl* _impl;
};

#endif
