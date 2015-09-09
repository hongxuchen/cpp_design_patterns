#ifndef DECIDER_HPP
#define DECIDER_HPP

#include <cassert>
#include "op.hh"

class Decider {
  Operator* op_;

 public:
  Decider() = default;
  void setOp(Operator* op) { op_ = op; }
  void transform(unsigned seed) {
    assert(op_ != nullptr);
    op_->transform(seed);
  }
};

#endif
