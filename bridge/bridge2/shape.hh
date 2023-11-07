#ifndef SHAPE_HPP
#define SHAPE_HPP

class Shape {
 public:
  virtual ~Shape() = default;
  virtual void draw() = 0;
  virtual void resizeByPercentage(double pct) = 0;
};

#endif
