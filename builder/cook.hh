#ifndef COOK_HPP
#define COOK_HPP

#include "meal_builder.hh"

class MultiCuisineCook {
 public:
  MultiCuisineCook() = default;
  ~MultiCuisineCook() = default;

  void setMealBuilder(MealBuilder* mealBuilder) { builder_ = mealBuilder; }

  Meal const& getMeal() { return builder_->getMeal(); }

  void createMeal() {
    builder_->buildStarter();
    builder_->buildMainCourse();
    builder_->buildDessert();
  }

 private:
  MealBuilder* builder_{};
};

#endif
