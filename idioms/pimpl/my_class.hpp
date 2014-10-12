#ifndef MYCLASS_HPP
#define MYCLASS_HPP

#include <string>
#include <memory>

struct MyClassImp;
class MyClass {
 public:
  explicit MyClass(std::string const &var);
  explicit MyClass(std::string &&var);
  MyClass(MyClass const &) = delete;
  MyClass(MyClass &&);
  MyClass &operator=(MyClass const &) = delete;
  MyClass &operator=(MyClass &&);
  ~MyClass();

  void run();
  void setValue(std::string const &var);
  std::string getValue();

 private:
  std::unique_ptr<MyClassImp> pimpl_;
};

#endif
