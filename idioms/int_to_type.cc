#include <iostream>
#include <array>

template <int I>
struct Int2Type {
  enum {
    value = I
  };
};

template <class T, unsigned int N>
class Array : public std::array<T, N> {
  enum AlgoType {
    NOOP,
    INSERTION_SORT,
    QUICK_SORT
  };
  static const int algo =
      (N == 0) ? NOOP : (N == 1) ? NOOP : (N < 50) ? INSERTION_SORT
                                                   : QUICK_SORT;
  void sort(Int2Type<NOOP>) { std::cout << "NOOP\n"; }
  void sort(Int2Type<INSERTION_SORT>) { std::cout << "INSERTION_SORT\n"; }
  void sort(Int2Type<QUICK_SORT>) { std::cout << "QUICK_SORT\n"; }

 public:
  void sort() { sort(Int2Type<algo>()); }
};
int main(void) {
  Array<int, 1> a;
  a.sort();
  Array<int, 400> b;
  b.sort();
  Array<int, 30> c;
  c.sort();
}
