#ifndef SINGLETON_HPP
#define SINGLETON_HPP

#include <iostream>

class Single {
  static Single single;
  Single() {}

 public:
  void dump() { std::cout << "hello\n"; }
  static Single &getInstance() {
    static Single single;
    return single;
  }
};

#endif
