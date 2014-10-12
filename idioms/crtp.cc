template <typename Derived>
class Base {
 public:
  static Derived& getInstance() {}

 protected:
  static Derived* d;

 private:
  Base() {}
  Base(Base const&) = delete;
  Base& operator=(Base const&) = delete;
};

template <typename Derived>
Derived* Base<Derived>::d = nullptr;

class A: public Base<A>{
  
}
