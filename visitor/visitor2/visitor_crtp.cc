#include <iostream>
#include <vector>
using namespace std;

struct Bird;
struct Bear;

struct Visitor {
  virtual void Visit(Bird* bird) = 0;
  virtual void Visit(Bear* bear) = 0;
};

template <typename Derived>
struct Animal {
  void Accept(Visitor* v) { v->Visit(static_cast<Derived*>(this)); }
};

struct Bird : public Animal<Bird> {};

struct Bear : public Animal<Bear> {};

struct PrintVisitor : public Visitor {
  void Visit(Bird*) override {
    cout << "[print] bird!" << '\n';
  };
  void Visit(Bear*) override {
    cout << "[print] bear!" << '\n';
  };
};

struct DumpVisitor : public Visitor {
  void Visit(Bird*) override {
    cout << "[dump] bird!" << '\n';
  };
  void Visit(Bear*) override {
    cout << "[dump] bear!" << '\n';
  };
};

int main() {
  Bear bear;
  Bird bird;

  PrintVisitor v1;
  DumpVisitor v2;

  std::vector<Visitor*> const visitors{&v1, &v2};

  for (auto&& visitor : visitors) {
    bear.Accept(visitor);
    bird.Accept(visitor);
  }

  return 0;
}
