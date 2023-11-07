#include <memory>

#include "managers.hh"
#include "request.hh"

int main() {
  std::unique_ptr<Manager> common = std::make_unique<CommonManager>("Manager");
  std::unique_ptr<Manager> major = std::make_unique<MajorDomo>("Major");
  std::unique_ptr<Manager> const general =
      std::make_unique<GeneralManager>("General");
  common->setSuccessor(major.get());
  major->setSuccessor(general.get());
  Request req;

  req.setNum(999);
  common->getRequest(req);

  req.setNum(4999);
  common->getRequest(req);

  req.setNum(6999);
  common->getRequest(req);

  return 0;
}
