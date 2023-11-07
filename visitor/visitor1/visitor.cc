#include <iostream>
#include <vector>
using namespace std;

struct Bird;
struct Bear;

struct Visitor {
  virtual void Visit(Bird*) = 0;
  virtual void Visit(Bear*) = 0;
};

struct Animal {
  virtual void Accept(Visitor* v) = 0;
};

struct Bird : public Animal {
  void Accept(Visitor* v) override;
};

struct Bear : public Animal {
  void Accept(Visitor* v) override;
};

struct PrintVisitor : public Visitor {
  void Visit(Bird*) override { cout << "That's a bird!" << '\n'; };
  void Visit(Bear*) override { cout << "That's a bear!" << '\n'; };
};

struct DumpVisitor : public Visitor {
  void Visit(Bird*) override { cout << "bird!" << '\n'; };
  void Visit(Bear*) override { cout << "bear!" << '\n'; };
};

void Bird::Accept(Visitor* v) { v->Visit(this); }
void Bear::Accept(Visitor* v) { v->Visit(this); }

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
}
