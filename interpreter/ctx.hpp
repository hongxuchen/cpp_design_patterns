#ifndef CONTEXT_HPP
#define CONTEXT_HPP

#include <string>

using ExprTy = int;

class Context {
 public:
  Context(int num) : data_(num) {}
  ExprTy data() { return data_; }
  void setData(ExprTy d) { data_ = d; }

 private:
  ExprTy data_;
};

#endif
