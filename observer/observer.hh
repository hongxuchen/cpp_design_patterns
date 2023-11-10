#ifndef MANAGER_HPP
#define MANAGER_HPP

#include <vector>
#include <memory>

#include "worker.hh"

class Observer {
  using WorkerPtr = std::shared_ptr<Worker>;
  using Workers = std::vector<WorkerPtr>;
  std::string msg_;

 public:
  void SetMsg(std::string const& msg) { msg_ = msg; }
  std::string& Msg() { return msg_; }
  void Add(const WorkerPtr& ob) { observers_.push_back(ob); }
  void Remove(std::size_t add_index) {
    if (add_index < observers_.size())
      observers_.erase(observers_.begin() + add_index);
  }
  void Notify();

 private:
  Workers observers_;
};

#endif
