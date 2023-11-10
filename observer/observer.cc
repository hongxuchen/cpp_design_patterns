#include "observer.hh"

void Observer::Notify() {
  for (const auto& observer : observers_) observer->Update();
}
