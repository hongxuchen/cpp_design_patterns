#ifndef TARGET_HPP
#define TARGET_HPP

class Target {
 public:
  Target() = default;
  virtual ~Target() = default;
  virtual void Request() = 0;
};

#endif
