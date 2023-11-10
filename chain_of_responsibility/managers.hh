#ifndef MANAGERS_HPP
#define MANAGERS_HPP

#include <string>

#include "request.hh"

class Manager {
 public:
  Manager(std::string const& name) : name(name) {}
  void SetSuccessor(Manager* mgr) { this->mgr = mgr; }
  virtual void GetRequest(Request const& request) = 0;
  virtual ~Manager() = default;

 protected:
  Manager* mgr;
  std::string name;
};

class CommonManager : public Manager {
 public:
  CommonManager(std::string const& name) : Manager(name) {}
  void GetRequest(Request const& request) override;
};

class MajorDomo : public Manager {
 public:
  MajorDomo(std::string const& name) : Manager(name) {}
  void GetRequest(Request const& request) override;
};

class GeneralManager : public Manager {
 public:
  GeneralManager(const std::string& name) : Manager(name) {}
  void GetRequest(Request const& request) override;
  ~GeneralManager() override = default;
};

#endif
