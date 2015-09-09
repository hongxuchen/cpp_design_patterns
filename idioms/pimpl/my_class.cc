#include "my_class.hh"
#include <iostream>
#include <assert.h>

#define LOG_THIS std::cout << __PRETTY_FUNCTION__ << '\t' << this << '\n'
#define LOG_VAR \
  std::cout << __PRETTY_FUNCTION__ << '\t' << var_ << '\t' << this << '\n'

struct MyClassImp {
  explicit MyClassImp(std::string const &var) : var_(var) { LOG_THIS; }
  explicit MyClassImp(std::string &&var) : var_(std::move(var)) { LOG_THIS; }
  ~MyClassImp() { LOG_THIS; }
  void run() { LOG_VAR; }
  std::string var_;
};

MyClass::MyClass(std::string const &var)
    : pimpl_(std::make_unique<MyClassImp>(var)) {
  LOG_THIS;
}

MyClass::MyClass(std::string &&var)
    : pimpl_(std::make_unique<MyClassImp>(std::move(var))) {
  LOG_THIS;
}
MyClass::MyClass(MyClass &&rhs) : pimpl_(std::move(rhs.pimpl_)) { LOG_THIS; }
MyClass &MyClass::operator=(MyClass &&rhs) {
  assert(this != &rhs);
  pimpl_ = std::move(rhs.pimpl_);
  return *this;
}
MyClass::~MyClass() {}

void MyClass::run() { pimpl_->run(); }

void MyClass::setValue(std::string const &var) { pimpl_->var_ = var; }
std::string MyClass::getValue() { return pimpl_->var_; }
