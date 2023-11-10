#ifndef ABS_CHAR_H 
#define ABS_CHAR_H 

class AbsChar {
 public:
  AbsChar() = default;
  virtual ~AbsChar() = default;
  virtual void PrintChar() = 0;
};

#endif
