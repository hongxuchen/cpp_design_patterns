#include <iostream>
using namespace std;

class Customer {
 public:
  Customer(const char* fn, const char* ln) : firstname_(fn), lastname_(ln) {}
  void print() const { cout << firstname_ << ' ' << lastname_; }

 private:
  const char* firstname_, *lastname_;
};

template <class Base>
class PhoneContact : public Base {
 public:
  PhoneContact(const char* fn, const char* ln, const char* pn)
      : Base(fn, ln), phone_(pn) {}
  void print() const {
    Base::print();
    cout << ' ' << phone_;
  }

 private:
  const char* phone_;
};

template <class Base>
class EmailContact : public Base {
 public:
  EmailContact(const char* fn, const char* ln, const char* e)
      : Base(fn, ln), email_(e) {}
  void print() const {
    Base::print();
    cout << ' ' << email_;
  }

 private:
  const char* email_;
};

int main() {
  Customer c1("Teddy", "Bear");
  c1.print();
  cout << endl;
  PhoneContact<Customer> c2("Rick", "Racoon", "050-998877");
  c2.print();
  cout << endl;
  EmailContact<Customer> c3("Dick", "Deer", "dick@deer.com");
  c3.print();
  cout << endl;
  // The following composition isn't legal because there
  // is no constructor that takes all four arguments.
  // EmailContact<PhoneContact<Customer> >
  // c4("Eddy","Eagle","049-554433","eddy@eagle.org");
  // c4.print(); cout << endl;
  return 0;
}
