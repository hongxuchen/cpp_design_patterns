#ifndef COMPOSITE_HPP
#define COMPOSITE_HPP

#include <vector>
#include <memory>

class Component;
typedef std::shared_ptr<Component> ComponentPtr;

class Component {
 public:
  virtual void operate() = 0;
  virtual void add(ComponentPtr);
  virtual void remove(ComponentPtr);
  virtual ComponentPtr getChild(std::size_t index);

  virtual ~Component() = default;

 protected:
  Component() = default;
};

class Leaf final : public Component {
 public:
  virtual void operate() override;
};

class Composite final : public Component {
 public:
  virtual void operate() override;
  virtual void add(ComponentPtr) override;
  virtual void remove(ComponentPtr) override;
  virtual ComponentPtr getChild(std::size_t index) override;

 private:
  std::vector<ComponentPtr> comVect_;
};

#endif
