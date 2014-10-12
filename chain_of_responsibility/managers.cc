#include "managers.hpp"
#include <iostream>

void CommonManager::getRequest(Request const& request) {
  if (request.num() >= 0 && request.num() < MaxMount::Common) {
    std::cout << name_ << " handle: " << request.num() << '\n';
  } else {
    mgr_->getRequest(request);
  }
}

void MajorDomo::getRequest(Request const& request) {
  if (request.num() <= MaxMount::Major) {
    std::cout << name_ << " handle: " << request.num() << '\n';
  } else {
    mgr_->getRequest(request);
  }
}

void GeneralManager::getRequest(Request const& request) {
  std::cout << name_ << " handle: " << request.num() << '\n';
}
