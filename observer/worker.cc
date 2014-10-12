#include "worker.hpp"
#include <iostream>
#include "observer.hpp"

void Worker::update() {
  std::cout << "[" << name_ << "]: received the msg: " << observer_->msg()
            << '\n';
}
