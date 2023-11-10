#ifndef D1_HPP
#define D1_HPP

#include <iostream>

#include "drawing.hh"

class DrawingAPI1 final : public DrawingAPI {
 public:
  void DrawCircle(double x, double y, double radius) override {
    std::cout << "API1.circle at " << x << ':' << y << ' ' << radius << '\n';
  }
};

#endif
