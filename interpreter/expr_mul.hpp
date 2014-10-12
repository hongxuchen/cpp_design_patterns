#ifndef EXPR_MUL_HPP
#define EXPR_MUL_HPP

#include "expr.hpp"
#include "ctx.hpp"

class MulExpr final : public Expr {
 public:
  MulExpr(ExprTy mul) : mul_(mul) {}
  virtual void interpret(Context& context) override;

 private:
  int mul_;
};

#endif
