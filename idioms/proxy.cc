#include <type_traits>
#include <utility>
#include <iostream>
#include <vector>

template <typename Type>
class ptr_scope_manager {
 private:
  std::vector<Type> ptrs;

 public:
  template <typename T = Type, typename... Args>
  auto create(Args&&... args)
      -> typename std::enable_if<!std::is_constructible<T, Args...>::value,
                                 T*>::type {
    std::cout << "push_back" << std::endl;
    ptrs.push_back(T{std::forward<Args>(args)...});
    return &ptrs.back();
  }

  template <typename T = Type, typename... Args>
  auto create(Args&&... args)
      -> typename std::enable_if<std::is_constructible<T, Args...>::value,
                                 T*>::type {
    std::cout << "emplace_back" << std::endl;
    ptrs.emplace_back(std::forward<Args>(args)...);
    return &ptrs.back();
  }
};

class public_ctor {
  int i;

 public:
  public_ctor(int i) : i(i) {}  // public
};

class private_ctor {
  friend class ptr_scope_manager<private_ctor>;
  int i;

 private:
  private_ctor(int i) : i(i) {}  // private
};

class non_friendly_private_ctor {
  int i;

 private:
  non_friendly_private_ctor(int i) : i(i) {}  // private
};

int main() {
  ptr_scope_manager<public_ctor> public_manager;
  ptr_scope_manager<private_ctor> private_manager;
  ptr_scope_manager<non_friendly_private_ctor> non_friendly_private_manager;

  public_manager.create(3);

  private_manager.create(3);

  // non_friendly_private_manager.create(3); raises error
}
