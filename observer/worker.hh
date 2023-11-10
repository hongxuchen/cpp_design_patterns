#ifndef WOKER_HPP
#define WOKER_HPP

#include <string>
#include <utility>

class Observer;
class Worker {
 public:
  Worker(std::string  str_name, Observer* str_sub)
      : name_(std::move(str_name)), observer_(str_sub) {}

  void Update();

 private:
  std::string name_;
  Observer* observer_;
};

#endif
