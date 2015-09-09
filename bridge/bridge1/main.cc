#include "char_msg_sender.hh"
#include "hello_msg_impl.hh"
#include "bye_msg_impl.hh"

int main(void) {
  CharMessageSender charMsgSender;
  AbsMsgSender *sender = &charMsgSender;

  HelloMessageImpl hello;
  ByeMessageImpl bye;

  sender->setMessage(&hello);
  sender->sendMessage();
  sender->setMessage(&bye);
  sender->sendMessage();

  return 0;
}
