#include <iostream>

template <typename T>
class Foo;

template <typename T>
std::ostream& operator<<(std::ostream& os, const Foo<T>& b);

template <typename T>
class Foo {
  T value;

 public:
  Foo(const T& t) { value = t; }
  friend std::ostream& operator<<(std::ostream& os, const Foo<T>& b);
};

template <typename T>
std::ostream& operator<<(std::ostream& os, const Foo<T>& b) {
  return os << b.value;
}

int main(void) {
  Foo<int> foo(2);
  std::cout << foo << std::endl;
}
