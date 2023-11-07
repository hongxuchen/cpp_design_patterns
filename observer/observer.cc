#include "observer.hh"

void Observer::notify() {
  for (const auto& observer : observers_) observer->update();
}
