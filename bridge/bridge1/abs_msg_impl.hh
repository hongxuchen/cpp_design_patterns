#ifndef ABSMESSAGEIMPL_H
#define ABSMESSAGEIMPL_H

class AbsMessageImpl {

 public:
  virtual ~AbsMessageImpl() = default;
  virtual void sendMessage() = 0;

 protected:
  AbsMessageImpl() {}
};

#endif
