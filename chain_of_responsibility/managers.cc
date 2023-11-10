#include "managers.hh"
#include "request.hh"

#include <iostream>

void CommonManager::GetRequest(Request const& request) {
  if (request.Num() >= 0 && request.Num() < MaxMount::kCommon) {
    std::cout << name << " handle: " << request.Num() << '\n';
  } else {
    mgr->GetRequest(request);
  }
}

void MajorDomo::GetRequest(Request const& request) {
  if (request.Num() <= MaxMount::kMajor) {
    std::cout << name << " handle: " << request.Num() << '\n';
  } else {
    mgr->GetRequest(request);
  }
}

void GeneralManager::GetRequest(Request const& request) {
  std::cout << name << " handle: " << request.Num() << '\n';
}
