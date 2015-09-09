#include "observer.hh"

void Observer::notify() {
  for (auto observer : observers_) observer->update();
}
