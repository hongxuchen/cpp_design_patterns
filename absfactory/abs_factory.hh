#ifndef ABS_FACTORY_H 
#define ABS_FACTORY_H 

#include "abs_char.hh"
#include "abs_num.hh"
#include <memory>

class AbsFactory {
 public:
  AbsFactory() = default;
  virtual ~AbsFactory() = default;
  virtual std::unique_ptr<AbsChar> CreateChar() = 0;
  virtual std::unique_ptr<AbsNum> CreateNum() = 0;
};

#endif
