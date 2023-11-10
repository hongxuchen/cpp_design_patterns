#include "datetimeprinter.hh"

DateTimePrinter::DateTimePrinter() : tp_(TimePrinter()), dp_(DatePrinter()) {}

void DateTimePrinter::Print() {
  DatePrinter::PrintDate();
  TimePrinter::PrintTime();
}
