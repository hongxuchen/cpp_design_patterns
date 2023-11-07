#include "datetimeprinter.hh"

DateTimePrinter::DateTimePrinter() : tp_(TimePrinter()), dp_(DatePrinter()) {}

void DateTimePrinter::print() {
  DatePrinter::printDate();
  TimePrinter::printTime();
}
