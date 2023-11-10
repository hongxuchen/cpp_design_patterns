#ifndef ADAPTEE_HPP
#define ADAPTEE_HPP

#include <cstdio>
#include <iostream>
class Adaptee {
 protected:
  volatile int i = 0;
  double j = 1.1;

 public:
  int getI() { return i; }

  int getJ() { return j; }

  Adaptee() = delete;
  Adaptee(int i, double j) : i(i), j(j) {}
  ~Adaptee() = default;
  void SpecificRequest() { std::cout << "i=" << i << ", j=" << j << '\n'; }
};

#endif
