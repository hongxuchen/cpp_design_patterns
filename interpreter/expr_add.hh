#ifndef EXPR_ADD_HPP
#define EXPR_ADD_HPP

#include "expr.hh"
#include "ctx.hh"

class AddExpr final : public Expr {
 public:
  AddExpr(ExprTy add) : add_(add) {}
  virtual void interpret(Context& context) override;

 private:
  ExprTy add_;
};

#endif
