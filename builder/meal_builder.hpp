#ifndef BUILDER_HPP
#define BUILDER_HPP

#include "meal.hpp"

class MealBuilder {
 public:
  virtual ~MealBuilder() = default;
  Meal const& getMeal() { return meal_; }

  virtual void buildStarter() = 0;
  virtual void buildMainCourse() = 0;
  virtual void buildDessert() = 0;

 protected:
  MealBuilder() {}

  Meal meal_;
};

#endif
