#include "const_passwd_proxy.hh"
#include <string>
char const* const_passwd = "1234";

bool ConstPasswdProxy::Verify(std::string const& passwd) {
  return passwd == const_passwd;
}
