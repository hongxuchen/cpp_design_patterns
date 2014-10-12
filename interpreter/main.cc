#include <iostream>
#include <memory>
/// #include "boost/type_index.hpp"

#include "ctx.hpp"
#include "expr_mul.hpp"
#include "expr_add.hpp"

/// using boost::typeindex::type_id_with_cvr;

int main(void) {
  Context context(15);
  auto aexpr = std::shared_ptr<Expr>(std::make_shared<AddExpr>(1));
  auto mexpr = std::shared_ptr<Expr>(std::make_shared<MulExpr>(2));
  aexpr->interpret(context);
  mexpr->interpret(context);
  /// assert(type_id_with_cvr<decltype(aexpr)>() ==
  ///        type_id_with_cvr<decltype(mexpr)>());

  std::cout << "result: " << context.data() << std::endl;

  return 0;
}
