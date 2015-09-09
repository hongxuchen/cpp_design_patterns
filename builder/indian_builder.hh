#ifndef INDIAN_BUILDER_HPP
#define INDIAN_BUILDER_HPP

#include "meal_builder.hh"

class IndianMealBuilder final : public MealBuilder {
 public:
  IndianMealBuilder() {}
  ~IndianMealBuilder() {}

  virtual void buildStarter() override { meal_.setMealItem("FriedOnion"); }
  virtual void buildMainCourse() override { meal_.setMealItem("CheeseCurry"); }
  virtual void buildDessert() override { meal_.setMealItem("SweetBalls"); }
};


#endif
