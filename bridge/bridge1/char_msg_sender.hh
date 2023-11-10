#ifndef CHARMESSAGESENDER_H
#define CHARMESSAGESENDER_H

#include "abs_msg_sender.hh"

class CharMessageSender : public AbsMsgSender {
 public:
  CharMessageSender() = default;

  ~CharMessageSender() override = default;

  void SendMessage() override {
    if (impl_ != nullptr) {
      impl_->SendMessage();
    }
  }

  void SetMessage(MsgTy impl) override { impl_ = impl; }

 protected:
  MsgTy impl_{nullptr};
};

#endif
