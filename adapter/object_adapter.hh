#ifndef OBJECT_ADAPTER_HPP
#define OBJECT_ADAPTER_HPP

#include <iostream>
#include <memory>

#include "adaptee.hh"
#include "target.hh"

// composition
class ObjectAdapter final : public Target {
 public:
  ObjectAdapter(std::shared_ptr<Adaptee> adaptee) { adaptee_ = adaptee; }
  /// ObjectAdapter(Adaptee *adaptee) = delete;

  ObjectAdapter() : adaptee_(std::make_shared<Adaptee>()) {}
  ~ObjectAdapter() override = default;
  void Request() override {
    adaptee_->SpecificRequest();
    std::cout << __PRETTY_FUNCTION__ << "\n";
  }

 private:
  std::shared_ptr<Adaptee> adaptee_;
};

#endif
