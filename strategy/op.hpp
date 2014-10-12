#ifndef OP_HPP
#define OP_HPP

class Operator {
 public:
  virtual void transform(unsigned seed) = 0;
};

#endif
