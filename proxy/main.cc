#include "const_passwd_proxy.hh"

#include <iostream>
#include <memory>

int main(void) {
  std::shared_ptr<PasswordProxy> proxy = std::make_shared<ConstPasswdProxy>();

  bool verify = proxy->verify("abc");
  std::cout << "result: " << verify << '\n';

  verify = proxy->verify("1234");
  std::cout << "result: " << verify << '\n';

  return 0;
}
