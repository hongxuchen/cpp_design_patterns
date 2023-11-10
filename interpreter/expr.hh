#ifndef EXPRESSION_HPP
#define EXPRESSION_HPP

#include "ctx.hh"

class Expr {
 public:
  virtual ~Expr() = default;

  virtual void Interpret(Context& context) = 0;

 protected:
  Expr() {}
};

#endif
