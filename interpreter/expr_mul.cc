#include "expr_mul.hpp"

#include <iostream>
#include <cstdlib>
#include <cstdio>

void MulExpr::interpret(Context& context) {
  ExprTy data = context.data();
  data *= mul_;
  context.setData(data);
}
