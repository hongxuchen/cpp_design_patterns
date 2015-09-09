#ifndef ABS_FACTORY_H 
#define ABS_FACTORY_H 

#include "abs_char.hh"
#include "abs_num.hh"
#include <memory>

class AbsFactory {
 public:
  AbsFactory() {}
  virtual ~AbsFactory() {}
  virtual std::shared_ptr<AbsChar> createChar() = 0;
  virtual std::shared_ptr<AbsNum> createNum() = 0;
};

#endif
