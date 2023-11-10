#include <memory>

#include "managers.hh"
#include "request.hh"

int main() {
  std::unique_ptr<Manager> common = std::make_unique<CommonManager>("Manager");
  std::unique_ptr<Manager> major = std::make_unique<MajorDomo>("Major");
  std::unique_ptr<Manager> const general =
      std::make_unique<GeneralManager>("General");
  common->SetSuccessor(major.get());
  major->SetSuccessor(general.get());
  Request req;

  req.SetNum(999);
  common->GetRequest(req);

  req.SetNum(4999);
  common->GetRequest(req);

  req.SetNum(6999);
  common->GetRequest(req);

  return 0;
}
