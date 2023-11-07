#ifndef CIRCLE_HPP
#define CIRCLE_HPP

#include "drawing.hh"
#include "shape.hh"

class CircleShape : public Shape {
 public:
  CircleShape(double x, double y, double radius, DrawingAPI *drawingAPI)
      : m_x(x), m_y(y), m_radius(radius), m_drawingAPI(drawingAPI) {}
  void draw() override { m_drawingAPI->drawCircle(m_x, m_y, m_radius); }
  void resizeByPercentage(double pct) override { m_radius *= pct; }

 private:
  double m_x, m_y, m_radius;
  DrawingAPI *m_drawingAPI;
};

#endif
