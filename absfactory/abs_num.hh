#ifndef ABS_NUM_H 
#define ABS_NUM_H 

class AbsNum {
 public:
  AbsNum() = default;
  virtual ~AbsNum() = default;
  virtual void PrintNum() = 0;
};

#endif
