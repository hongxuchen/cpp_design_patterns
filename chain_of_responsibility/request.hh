#ifndef REQUEST_HPP
#define REQUEST_HPP

enum MaxMount { kCommon = 1000, kMajor = 5000 };

class Request {
  int num_;

 public:
  void SetNum(int num) { num_ = num; }
  int Num() const { return num_; }
};

#endif
