#ifndef POLY_FIT_H
#define POLY_FIT_H

#include <vector>
#include <cassert>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/lu.hpp>

namespace lsq_test {
  template<typename T> std::vector<T> fit_poly_coeffs(const std::vector<T>& x,
                                                      const std::vector<T>& y,
                                                      int degree) {
    using namespace boost::numeric::ublas;

    assert(x.size() == y.size());

    degree++;

    // construct system of equations
    int n = x.size();
    matrix<T> vandermonde_matrix(n, degree);
    matrix<T> Y(n, 1);

    for (int i = 0; i < n; i++)
      Y(i, 0) = y[i];
    for (int row = 0; row < n; row++) {
      T val = 1.0f;
      for (int col = 0; col < degree; col++) {
        vandermonde_matrix(row, col) = val;
        val *= x[row];
      }
    }

    matrix<T> vandermonde_transposed(trans(vandermonde_matrix));
    matrix<T> vandermonde_product(prec_prod(vandermonde_transposed, vandermonde_matrix));
    matrix<T> solved_coeffs(prec_prod(vandermonde_transposed, Y));

    // solve equations
    permutation_matrix<int> perm(vandermonde_product.size1());
    const int singular = lu_factorize(vandermonde_product, perm);
    assert(singular == 0);
    lu_substitute(vandermonde_product, perm, solved_coeffs);

    return std::vector<T>(solved_coeffs.data().begin(), solved_coeffs.data().end());
  }

  template<typename T> std::vector<T> eval_polynomial(const std::vector<T>& coeffs,
                                                      const std::vector<T>& x) {
    std::vector<T> result(x.size());
    for (unsigned int i = 0; i < x.size(); i++) {
      T x_tmp = 1;
      T y_tmp = 0;
      for (unsigned int j = 0; j < coeffs.size(); j++) {
        y_tmp += coeffs[j] * x_tmp;
        x_tmp *= x[i];
      }
      result[i] = y_tmp;
    }
    return result;
  }
}

#endif // POLY_FIT_H
