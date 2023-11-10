#include "expr_mul.hh"
#include "ctx.hh"

#include <cstdlib>
#include <cstdio>

void MulExpr::Interpret(Context& context) {
  ExprTy data = context.Data();
  data *= mul_;
  context.SetData(data);
}
