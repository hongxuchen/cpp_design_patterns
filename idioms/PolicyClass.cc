#include <iostream>
#include <string>

template <typename language_policy>
struct HelloWorld {
  void Run() { std::cout << language_policy::Message() << std::endl; }
};

struct English {
  static std::string Message() { return "Hello, World!"; }
};

struct German {
  static std::string Message() { return "Hallo Welt!"; }
};

int main() {
  typedef HelloWorld<English> EnglishMsgTy;
  typedef HelloWorld<German> GermanyMsgTy;

  EnglishMsgTy engMsg;
  engMsg.Run();

  GermanyMsgTy deMsg;
  deMsg.Run();
}
