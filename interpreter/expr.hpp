#ifndef EXPRESSION_HPP
#define EXPRESSION_HPP

#include "ctx.hpp"

class Expr {
 public:
  virtual ~Expr() {}

  virtual void interpret(Context& context) = 0;

 protected:
  Expr() {}
};

#endif
