#include "observer.hpp"

void Observer::notify() {
  for (auto observer : observers_) observer->update();
}
