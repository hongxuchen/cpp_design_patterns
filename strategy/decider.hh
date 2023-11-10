#ifndef DECIDER_HPP
#define DECIDER_HPP

#include <cassert>
#include "op.hh"

class Decider {
  Operator* op_;

 public:
  Decider() = default;
  void SetOp(Operator* op) { op_ = op; }
  void Transform(unsigned seed) {
    assert(op_ != nullptr);
    op_->Transform(seed);
  }
};

#endif
