#include <iostream>

class EmptyClass {};

struct AnInt : public EmptyClass {
  int data;
};

class AnotherEmpty : public EmptyClass {};

void dumpSize(void) {
  std::cout << sizeof(EmptyClass) << std::endl;
  std::cout << sizeof(AnInt) << std::endl;
  std::cout << sizeof(AnotherEmpty) << std::endl;
}

///-------------------------------------------
class E1 {};
class E2 {};
template <typename Base1, typename Base2, typename Member>
struct BaseOptimization : Base1, Base2 {
  Member member;
  BaseOptimization() {}
  BaseOptimization(Base1 const& b1, Base2 const& b2, Member const& mem)
      : Base1(b1), Base2(b2), member(mem) {}
  Base1* first() { return this; }
  Base2* second() { return this; }
};

class Foo {
  BaseOptimization<E1, E2, int> data;
};  // sizeof(Foo) = 4

int main(void) { return 0; }
