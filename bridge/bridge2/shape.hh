#ifndef SHAPE_HPP
#define SHAPE_HPP

class Shape {
 public:
  virtual ~Shape() = default;
  virtual void Draw() = 0;
  virtual void ResizeByPercentage(double pct) = 0;
};

#endif
