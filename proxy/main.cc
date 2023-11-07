#include <iostream>
#include <memory>

#include "const_passwd_proxy.hh"
#include "passwd_proxy.hh"

int main() {
  std::shared_ptr<PasswordProxy> const proxy = std::make_shared<ConstPasswdProxy>();

  bool verify = proxy->verify("abc");
  std::cout << "result: " << verify << '\n';

  verify = proxy->verify("1234");
  std::cout << "result: " << verify << '\n';

  return 0;
}
