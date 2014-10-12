#include <iostream>

class Base1 {
 public:
  virtual int open() = 0;
};

class Base2 {
 public:
  virtual int open() = 0;
};

class Derived {
  class Base1_Impl;
  friend class Base1_Impl;
  class Base1_Impl : public Base1 {
   public:
    Base1_Impl(Derived* p) : parent_(p) {}
    int open() override { return parent_->base1_open(); }

   private:
    Derived* parent_;
  } base1_obj;

  class Base2_Impl;
  friend class Base2_Impl;
  class Base2_Impl : public Base2 {
   public:
    Base2_Impl(Derived* p) : parent_(p) {}
    int open() override { return parent_->base2_open(); }

   private:
    Derived* parent_;
  } base2_obj;

  int base1_open() { return 1; }
  int base2_open() { return 2; }

 public:
  Derived() : base1_obj(this), base2_obj(this) {}
  operator Base1&() { return base1_obj; }
  operator Base2&() { return base2_obj; }
};

int base1_open(Base1& b1) { return b1.open(); }
int base2_open(Base2& b2) { return b2.open(); }

int main(void) {
  Derived d;
  std::cout << base1_open(d) << std::endl;
  std::cout << base2_open(d) << std::endl;
  return 0;
}
