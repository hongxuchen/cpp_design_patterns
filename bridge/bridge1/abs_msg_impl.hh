#ifndef ABSMESSAGEIMPL_H
#define ABSMESSAGEIMPL_H

class AbsMessageImpl {

 public:
  virtual ~AbsMessageImpl() = default;
  virtual void SendMessage() = 0;

 protected:
  AbsMessageImpl() {}
};

#endif
