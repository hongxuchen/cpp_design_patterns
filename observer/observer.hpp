#ifndef MANAGER_HPP
#define MANAGER_HPP

#include "worker.hpp"
#include <vector>
#include <memory>

class Observer {
  typedef std::shared_ptr<Worker> WorkerPtr;
  typedef std::vector<WorkerPtr> Workers;
  std::string msg_;

 public:
  void setMsg(std::string const& msg) { msg_ = msg; }
  std::string& msg() { return msg_; }
  void add(WorkerPtr ob) { observers_.push_back(ob); }
  void remove(std::size_t addIndex) {
    if (addIndex < observers_.size())
      observers_.erase(observers_.begin() + addIndex);
  }
  void notify();

 private:
  Workers observers_;
};

#endif
