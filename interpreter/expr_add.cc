#include "expr_add.hh"
#include "ctx.hh"

#include <cstdlib>
#include <cstdio>

void AddExpr::Interpret(Context& context) {
  ExprTy data = context.Data();
  data += add_;
  context.SetData(data);
}
