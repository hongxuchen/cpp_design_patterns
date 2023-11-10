#ifndef SINGLETON_HPP
#define SINGLETON_HPP

#include <iostream>

class Single {
  static Single single;
  Single() {}

 public:
  static void Dump() { std::cout << "hello\n"; }
  static Single &GetInstance() {
    static Single single;
    return single;
  }
};

#endif
