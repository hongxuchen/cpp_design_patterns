#ifndef MEXICAN_BUILDER_HPP
#define MEXICAN_BUILDER_HPP

#include "meal_builder.hh"

class MexicanMealBuilder final : public MealBuilder {
 public:
  void BuildStarter() override { meal.SetMealItem("ChipsNSalsa"); }
  void BuildMainCourse() override {
    meal.SetMealItem("RiceTacoBeans");
  }
  void BuildDessert() override { meal.SetMealItem("FriedIcecream"); }
};

#endif
