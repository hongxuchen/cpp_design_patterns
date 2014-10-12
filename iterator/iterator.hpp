#ifndef ITERATOR_HPP
#define ITERATOR_HPP

#include <cassert>

template <typename Container>
class MyIterator {
  Container& aggr_;
  std::size_t cur_;

  using value_type = typename Container::value_type;

 public:
  MyIterator(Container& a) : aggr_(a), cur_(0u) {}
  void first() { cur_ = 0u; }
  bool isDone() { return (cur_ >= aggr_.size()); }
  void operator++() {
    if (cur_ < aggr_.size()) cur_++;
  }
  value_type& operator*() {
    assert(cur_ < aggr_.size());
    return aggr_[cur_];
  }
};

#endif
