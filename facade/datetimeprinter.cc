#include "datetimeprinter.hh"
#include <iostream>

DateTimePrinter::DateTimePrinter() : tp_(TimePrinter()), dp_(DatePrinter()) {}

void DateTimePrinter::print() {
  dp_.printDate();
  tp_.printTime();
}
