#include "abs_msg_sender.hh"
#include "bye_msg_impl.hh"
#include "char_msg_sender.hh"
#include "hello_msg_impl.hh"

int main() {
  CharMessageSender char_msg_sender;
  AbsMsgSender *sender = &char_msg_sender;

  HelloMessageImpl hello;
  ByeMessageImpl bye;

  sender->setMessage(&hello);
  sender->sendMessage();
  sender->setMessage(&bye);
  sender->sendMessage();

  return 0;
}
