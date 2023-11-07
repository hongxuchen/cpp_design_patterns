#ifndef DRAWING_HPP
#define DRAWING_HPP

class DrawingAPI {
 public:
  virtual void drawCircle(double x, double y, double radius) = 0;
  virtual ~DrawingAPI() = default;
};


#endif
