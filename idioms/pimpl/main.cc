#include "my_class.hpp"
#include <iostream>

int main(void) {
  {
    MyClass o1("o1");
    o1.run();
    o1.setValue("o1_s");
    o1.run();
  }
  std::cout << '\n';
  {
    /// MyClass &&temp = MyClass("o2");
    /// MyClass o2(std::move(temp)); // &&
    /// MyClass o2(temp); // const &
    MyClass o2(MyClass("o2"));  // elide
    o2.run();
    o2.setValue("o2_s");
    o2.run();
  }
  std::cout << '\n';
  {
    std::string str("o3");
    MyClass o3(str);
    o3.run();
    o3.setValue("o3_s");
    o3.run();
    o3 = MyClass("o4");
    o3.run();
  }
  return 0;
}
