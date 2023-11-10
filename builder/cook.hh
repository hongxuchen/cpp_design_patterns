#ifndef COOK_HPP
#define COOK_HPP

#include "meal_builder.hh"

class MultiCuisineCook {
 public:
  MultiCuisineCook() = default;
  ~MultiCuisineCook() = default;

  void SetMealBuilder(MealBuilder* meal_builder) { builder_ = meal_builder; }

  Meal const& GetMeal() { return builder_->GetMeal(); }

  void CreateMeal() {
    builder_->BuildStarter();
    builder_->BuildMainCourse();
    builder_->BuildDessert();
  }

 private:
  MealBuilder* builder_{};
};

#endif
