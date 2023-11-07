#include "expr_add.hh"
#include "ctx.hh"

#include <cstdlib>
#include <cstdio>

void AddExpr::interpret(Context& context) {
  ExprTy data = context.data();
  data += add_;
  context.setData(data);
}
