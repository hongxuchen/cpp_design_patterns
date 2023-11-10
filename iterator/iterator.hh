#ifndef ITERATOR_HPP
#define ITERATOR_HPP

#include <cassert>

template <typename Container>
class MyIterator {
  Container& aggr_;
  std::size_t cur_{0u};

  using ValueType = typename Container::ValueType;

 public:
  MyIterator(Container& a) : aggr_(a) {}
  void First() { cur_ = 0U; }
  bool IsDone() { return (cur_ >= aggr_.Size()); }
  void operator++() {
    if (cur_ < aggr_.Size()) cur_++;
  }
  ValueType& operator*() {
    assert(cur_ < aggr_.Size());
    return aggr_[cur_];
  }
};

#endif
