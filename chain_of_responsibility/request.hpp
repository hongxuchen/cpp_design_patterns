#ifndef REQUEST_HPP
#define REQUEST_HPP

enum MaxMount { Common = 1000, Major = 5000 };

class Request {
  int num_;

 public:
  void setNum(int num) { num_ = num; }
  int num() const { return num_; }
};

#endif
