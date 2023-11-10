#include "worker.hh"
#include <iostream>
#include "observer.hh"

void Worker::Update() {
  std::cout << "[" << name_ << "]: received the msg: " << observer_->Msg()
            << '\n';
}
