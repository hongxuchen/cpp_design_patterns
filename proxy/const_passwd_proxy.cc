#include "const_passwd_proxy.hpp"
char const* CONST_PASSWD = "1234";

bool ConstPasswdProxy::verify(std::string const& passwd) {
  return passwd == CONST_PASSWD;
}
