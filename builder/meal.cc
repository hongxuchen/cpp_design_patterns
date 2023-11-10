#include "meal.hh"

#include <cstddef>
#include <iostream>

void Meal::ServeMeal() {
  std::size_t i = 0;
  while (!mean_.empty()) {
    std::cout << " Serve item " << ++i << ":" << mean_.front() << '\n';
    mean_.pop();
  }
}
