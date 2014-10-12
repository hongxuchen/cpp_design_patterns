#include <cstring>
#include <algorithm>
#include <iostream>

class StringRep {
  friend class String;
  friend std::ostream &operator<<(std::ostream &out, StringRep const &str) {
    out << "[" << str.data_ << ", " << str.count_ << "]";
    return out;
  }

 public:
  StringRep(const char *s) : count_(1) {
    strcpy(data_ = new char[strlen(s) + 1], s);
  }

  ~StringRep() { delete[] data_; }

 private:
  unsigned count_;
  char *data_;
};

class String {
 public:
  String() : rep_(new StringRep("")) {
    std::cout << "empty ctor: " << *rep_ << "\n";
  }
  String(const String &s) : rep_(s.rep_) {
    rep_->count_++;
    std::cout << "String ctor: " << *rep_ << "\n";
  }
  String(const char *s) : rep_(new StringRep(s)) {
    std::cout << "char ctor:" << *rep_ << "\n";
  }
  String &operator=(const String &s) {
    std::cout << "before assign: " << *s.rep_ << " to " << *rep_ << "\n";
    String(s).swap(*this);  // copy-and-swap idiom
    std::cout << "after assign: " << *s.rep_ << " , " << *rep_ << "\n";
    return *this;
  }
  ~String() {  // StringRep deleted only when the last handle goes out of scope.
    if (rep_ && --rep_->count_ <= 0) {
      std::cout << "dtor: " << *rep_ << "\n";
      delete rep_;
    }
  }

 private:
  void swap(String &s) throw() { std::swap(this->rep_, s.rep_); }

  StringRep *rep_;
};
int main() {

  std::cout << "*** init String a with empty\n";
  String a;
  std::cout << "\n*** assign a to \"A\"\n";
  a = "A";

  std::cout << "\n*** init String b with \"B\"\n";
  String b = "B";

  std::cout << "\n*** b->a\n";
  a = b;

  std::cout << "\n*** init c with a\n";
  String c(a);

  std::cout << "\n*** init d with \"D\"\n";
  String d("D");

  return 0;
}
