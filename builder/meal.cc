#include "meal.hpp"
#include <iostream>

void Meal::serveMeal() {
  std::size_t i = 0;
  while (!mean_.empty()) {
    std::cout << " Serve item " << ++i << ":" << mean_.front() << std::endl;
    mean_.pop();
  }
}
