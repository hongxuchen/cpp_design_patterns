#ifndef BUILDER_HPP
#define BUILDER_HPP

#include "meal.hh"

class MealBuilder {
 public:
  virtual ~MealBuilder() = default;
  Meal const& GetMeal() { return meal; }

  virtual void BuildStarter() = 0;
  virtual void BuildMainCourse() = 0;
  virtual void BuildDessert() = 0;

 protected:
  MealBuilder() {}

  Meal meal;
};

#endif
