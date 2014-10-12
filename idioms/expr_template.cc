#include <vector>
#include <iostream>
#include <cassert>
#include <algorithm>
#include <iterator>

template <typename E>
// A CRTP base class for Vecs with a size and indexing:
class VecExpression {
 public:
  typedef std::vector<double> container_type;
  typedef container_type::size_type size_type;
  typedef container_type::value_type value_type;
  typedef container_type::reference reference;
  typedef container_type::iterator iterator;

  size_type size() const { return static_cast<E const&>(*this).size(); }
  value_type operator[](size_type i) const {
    return static_cast<E const&>(*this)[i];
  }

  operator E&() { return static_cast<E&>(*this); }
  operator E const&() const { return static_cast<const E&>(*this); }
};

// The actual Vec class:
class Vec : public VecExpression<Vec> {
  container_type _data;

 public:
  iterator begin() { return _data.begin(); }
  iterator end() { return _data.end(); }
  reference operator[](size_type i) { return _data[i]; }
  value_type operator[](size_type i) const { return _data[i]; }
  size_type size() const { return _data.size(); }

  Vec(size_type n) : _data(n) {}  // Construct a given size:

  // Construct from any VecExpression:
  template <typename E>
  Vec(VecExpression<E> const& vec) {
    E const& v = vec;
    _data.resize(v.size());
    for (size_type i = 0; i != v.size(); ++i) {
      _data[i] = v[i];
    }
  }
};

template <typename E1, typename E2>
class VecDifference : public VecExpression<VecDifference<E1, E2> > {
  E1 const& _u;
  E2 const& _v;

 public:
  typedef Vec::size_type size_type;
  typedef Vec::value_type value_type;
  VecDifference(VecExpression<E1> const& u, VecExpression<E2> const& v)
      : _u(u), _v(v) {
    assert(u.size() == v.size());
  }
  size_type size() const { return _v.size(); }
  value_type operator[](Vec::size_type i) const { return _u[i] - _v[i]; }
};

template <typename E>
class VecScaled : public VecExpression<VecScaled<E> > {
  double _alpha;
  E const& _v;

 public:
  VecScaled(double alpha, VecExpression<E> const& v) : _alpha(alpha), _v(v) {}
  Vec::size_type size() const { return _v.size(); }
  Vec::value_type operator[](Vec::size_type i) const { return _alpha * _v[i]; }
};

// Now we can overload operators:

template <typename E1, typename E2>
VecDifference<E1, E2> const operator-(VecExpression<E1> const& u,
                                      VecExpression<E2> const& v) {
  return VecDifference<E1, E2>(u, v);
}

template <typename E>
VecScaled<E> const operator*(double alpha, VecExpression<E> const& v) {
  return VecScaled<E>(alpha, v);
}

double f1(double d) { return d * d; }
double f2(double d) { return 2 * d; }

int main(void) {
  Vec b(10), c(10);
  double alpha = 2.0;
  std::for_each(b.begin(), b.end(), [&](double d) { return d * d; });
  std::for_each(c.begin(), c.end(), [&](double d) { return 2 * d; });
  Vec bc = b - c;
  Vec x = alpha * bc;
  std::copy(x.begin(), x.end(),
            std::ostream_iterator<Vec::value_type>(std::cout, "\n"));
  return 0;
}
