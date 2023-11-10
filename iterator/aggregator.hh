#ifndef AGGREGATOR_HPP
#define AGGREGATOR_HPP

#include <vector>

template <typename Item>
class Aggregator {
 public:
  using ValueType = Item;
  void PushBack(Item const& item) { data_.push_back(item); }
  Item& operator[](std::size_t index) { return data_[index]; }
  std::size_t Size() { return data_.size(); }

 private:
  std::vector<ValueType> data_;
};

#endif
