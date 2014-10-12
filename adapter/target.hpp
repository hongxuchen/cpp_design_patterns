#ifndef TARGET_HPP
#define TARGET_HPP

class Target {
 public:
  Target() {}
  virtual ~Target() {}
  virtual void Request() = 0;
};

#endif
