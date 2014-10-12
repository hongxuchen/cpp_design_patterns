#ifndef D2_HPP
#define D2_HPP

#include <iostream>
#include "drawing.hpp"

class DrawingAPI2 final : public DrawingAPI {
 public:
  void drawCircle(double x, double y, double radius) override {
    std::cout << "API2.circle at " << x << ':' << y << ' ' << radius
              << std::endl;
  }
};

#endif
