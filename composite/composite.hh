#ifndef COMPOSITE_HPP
#define COMPOSITE_HPP

#include <vector>
#include <memory>

class Component;
using ComponentPtr = std::shared_ptr<Component>;

class Component {
 public:
  virtual void Operate() = 0;
  virtual void Add(ComponentPtr);
  virtual void Remove(ComponentPtr);
  virtual ComponentPtr GetChild(std::size_t index);

  virtual ~Component() = default;

 protected:
  Component() = default;
};

class Leaf final : public Component {
 public:
  void Operate() override;
};

class Composite final : public Component {
 public:
  void Operate() override;
  void Add(ComponentPtr) override;
  void Remove(ComponentPtr) override;
  ComponentPtr GetChild(std::size_t index) override;

 private:
  std::vector<ComponentPtr> comVect_;
};

#endif
