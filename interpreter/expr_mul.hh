#ifndef EXPR_MUL_HPP
#define EXPR_MUL_HPP

#include "expr.hh"
#include "ctx.hh"

class MulExpr final : public Expr {
 public:
  MulExpr(ExprTy mul) : mul_(mul) {}
  void Interpret(Context& context) override;

 private:
  int mul_;
};

#endif
