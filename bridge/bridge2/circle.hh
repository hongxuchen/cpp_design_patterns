#ifndef CIRCLE_HPP
#define CIRCLE_HPP

#include "drawing.hh"
#include "shape.hh"

class CircleShape : public Shape {
 public:
  CircleShape(double x, double y, double radius, DrawingAPI *drawing_api)
      : m_x_(x), m_y_(y), m_radius_(radius), m_drawingAPI_(drawing_api) {}
  void Draw() override { m_drawingAPI_->DrawCircle(m_x_, m_y_, m_radius_); }
  void ResizeByPercentage(double pct) override { m_radius_ *= pct; }

 private:
  double m_x_, m_y_, m_radius_;
  DrawingAPI *m_drawingAPI_;
};

#endif
