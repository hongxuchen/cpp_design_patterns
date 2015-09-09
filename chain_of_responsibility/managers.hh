#ifndef MANAGERS_HPP
#define MANAGERS_HPP

#include <string>
#include <memory>

#include "request.hh"

class Manager {
 public:
  Manager(std::string const& name) { name_ = name; }
  void setSuccessor(Manager* mgr) { mgr_ = mgr; }
  virtual void getRequest(Request const& request) = 0;
  virtual ~Manager() {}

 protected:
  Manager* mgr_;
  std::string name_;
};

class CommonManager : public Manager {
 public:
  CommonManager(std::string const& name) : Manager(name) {}
  virtual void getRequest(Request const& request) override;
};

class MajorDomo : public Manager {
 public:
  MajorDomo(std::string const& name) : Manager(name) {}
  virtual void getRequest(Request const& request) override;
};

class GeneralManager : public Manager {
 public:
  GeneralManager(std::string name) : Manager(name) {}
  virtual void getRequest(Request const& request) override;
  virtual ~GeneralManager() {}
};

#endif
