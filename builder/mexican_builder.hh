#ifndef MEXICAN_BUILDER_HPP
#define MEXICAN_BUILDER_HPP

#include "meal_builder.hh"

class MexicanMealBuilder final : public MealBuilder {
 public:
  virtual void buildStarter() override { meal_.setMealItem("ChipsNSalsa"); }
  virtual void buildMainCourse() override {
    meal_.setMealItem("RiceTacoBeans");
  }
  virtual void buildDessert() override { meal_.setMealItem("FriedIcecream"); }
};

#endif
