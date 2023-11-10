#include "circle.hh"
#include "d1.hh"
#include "d2.hh"

int main() {
  DrawingAPI1 dap1;
  DrawingAPI2 dap2;
  CircleShape circle1(1, 2, 3, &dap1);
  CircleShape circle2(5, 7, 11, &dap2);
  circle1.ResizeByPercentage(2.5);
  circle2.ResizeByPercentage(2.5);
  circle1.Draw();
  circle2.Draw();
  return 0;
}
