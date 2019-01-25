#include <iostream>
#include "poly_fit.hpp"
#include <vector>

template<typename T> void print_vec(std::vector<T>);
template<typename T> std::vector<T> add_constant(std::vector<T>, int);
template<typename T> std::vector<T> lsq_test::fit_poly_coeffs(const std::vector<T>& x,
                                                              const std::vector<T>& y,
                                                              int degree);
template<typename T> std::vector<T> eval_polynomial(const std::vector<T>& coeffs,
                                                    const std::vector<T>& x);

int main() {
  // Coefficients were: 0.5, 7, 2, 0.3, -4.1, 0.7 
  std::vector<double> x({0, 1, 2, 3, 4, 5, 6, 7, 8, 9});
  std::vector<double> y({0.5, 6.4, -18.3, -114.4, -253.1, -252, 308.9, 2171.2, 6482.1, 14878.4});

  std::cout << "x: ";
  print_vec(x);
  //y = add_constant(y, 5);
  std::cout << "y: ";
  print_vec(y);

  int degree = 5;
  std::vector<double> coeffs = lsq_test::fit_poly_coeffs(x, y, degree);

  std::cout << "Coefficients were: 0.5, 7, 2, 0.3, -4.1, 0.7" << std::endl;
  std::cout << "Fitted Coefficients: ";
  print_vec(coeffs);
  std::cout << "Computed y values: ";
  std::vector<double> y_comp = lsq_test::eval_polynomial(coeffs, x);
  print_vec(y_comp);

  return 0;
}

template<typename T>
void print_vec(std::vector<T> vec) {
  for (auto val : vec)
    std::cout << val << " ";
  std::cout << std::endl;
}

template<typename T>
std::vector<T> add_constant(std::vector<T> vec, int offset) {
  for (unsigned int i = 0; i < vec.size(); i++)
    vec[i] += offset;
  return vec;
}
