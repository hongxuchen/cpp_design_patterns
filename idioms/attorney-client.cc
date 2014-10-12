#include <cstdio>

class Base {
 private:
  virtual void Func(int x) = 0;
  friend class Attorney;

 public:
  virtual ~Base() {}
};

class Derived : public Base {
 private:
  virtual void Func(int) { printf("Derived::Func\n"); }

 public:
  ~Derived() {}
};

class Attorney {
 private:
  static void callFunc(Base& b, int x) { return b.Func(x); }
  friend int main(void);
};

int main(void) {
  Derived d;
  Attorney::callFunc(d, 10);
}
