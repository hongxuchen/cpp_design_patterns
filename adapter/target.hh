#ifndef TARGET_HPP
#define TARGET_HPP

/// an "interface", which defines a `Request` method
class Target {
 public:
  Target() = default;
  virtual ~Target() = default;
  virtual void Request() = 0;
};

#endif
