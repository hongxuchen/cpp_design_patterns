#ifndef WOKER_HPP
#define WOKER_HPP

#include <string>

class Observer;
class Worker {
 public:
  Worker(std::string const& strName, Observer* strSub)
      : name_(strName), observer_(strSub) {}

  void update();

 private:
  std::string name_;
  Observer* observer_;
};

#endif
