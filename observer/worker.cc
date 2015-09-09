#include "worker.hh"
#include <iostream>
#include "observer.hh"

void Worker::update() {
  std::cout << "[" << name_ << "]: received the msg: " << observer_->msg()
            << '\n';
}
