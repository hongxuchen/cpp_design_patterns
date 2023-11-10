#ifndef OBJECT_ADAPTER_HPP
#define OBJECT_ADAPTER_HPP

#include <iostream>
#include <utility>

#include "adaptee.hh"
#include "target.hh"

/// a adapter solution, by making `Adaptee` a member
class ObjectAdapter final : public Target {
 public:
  // wrap `Adaptee` into ObjectAdapter
  ObjectAdapter(Adaptee&& adaptee) : adaptee_(std::move(adaptee)){};

  // or initialize with a default Adaptee (totally encapsulate it)
  ObjectAdapter(int i, double j) : adaptee_(Adaptee(i, j)) {}

  ~ObjectAdapter() override = default;

  void Request() override {
    adaptee_.SpecificRequest();
    // cannot directly get i/j of adaptee_
    std::cout << __PRETTY_FUNCTION__ << " => (" << adaptee_.getI() << ", "
              << adaptee_.getJ() << ")\n";
  }

 private:
  Adaptee adaptee_;
};

#endif
