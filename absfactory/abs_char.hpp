#ifndef ABS_CHAR_H 
#define ABS_CHAR_H 

class AbsChar {
 public:
  AbsChar() {}
  virtual ~AbsChar() {}
  virtual void printChar() = 0;
};

#endif
