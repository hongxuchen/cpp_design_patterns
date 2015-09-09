#include "const_passwd_proxy.hh"
char const* CONST_PASSWD = "1234";

bool ConstPasswdProxy::verify(std::string const& passwd) {
  return passwd == CONST_PASSWD;
}
