#include <iostream>
#include <memory>
/// #include "boost/type_index.hh"

#include "ctx.hh"
#include "expr.hh"
#include "expr_add.hh"
#include "expr_mul.hh"

/// using boost::typeindex::type_id_with_cvr;

int main() {
  Context context(15);
  auto aexpr = std::shared_ptr<Expr>(std::make_shared<AddExpr>(1));
  auto mexpr = std::shared_ptr<Expr>(std::make_shared<MulExpr>(2));
  aexpr->interpret(context);
  mexpr->interpret(context);
  /// assert(type_id_with_cvr<decltype(aexpr)>() ==
  ///        type_id_with_cvr<decltype(mexpr)>());

  std::cout << "result: " << context.data() << '\n';

  return 0;
}
