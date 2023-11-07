#ifndef INDIAN_BUILDER_HPP
#define INDIAN_BUILDER_HPP

#include "meal_builder.hh"

class IndianMealBuilder final : public MealBuilder {
 public:
  IndianMealBuilder() = default;
  ~IndianMealBuilder() override = default;

  void buildStarter() override { meal_.setMealItem("FriedOnion"); }
  void buildMainCourse() override { meal_.setMealItem("CheeseCurry"); }
  void buildDessert() override { meal_.setMealItem("SweetBalls"); }
};

#endif
