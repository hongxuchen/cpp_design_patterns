#ifndef D2_HPP
#define D2_HPP

#include <iostream>

#include "drawing.hh"

class DrawingAPI2 final : public DrawingAPI {
 public:
  void DrawCircle(double x, double y, double radius) override {
    std::cout << "API2.circle at " << x << ':' << y << ' ' << radius << '\n';
  }
};

#endif
