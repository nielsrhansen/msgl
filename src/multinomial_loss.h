/*
 Routines for multinomial sparse group lasso regression.
 Intended for use with R.
 Copyright (C) 2012 Martin Vincent

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

#ifndef MULTINOMIAL_LOSS_HPP_
#define MULTINOMIAL_LOSS_HPP_

template<typename T>
class MultinomialLoss {

public:

	const sgl::natural n_samples;
	const sgl::natural n_responses; //number of classes

private:

	sgl::natural_vector const& Y;
	sgl::vector const& W; //weights - vector of length n_samples

	sgl::matrix prob; //probabilities: n_samples x n_responses

public:

	typedef sgl::hessian_full<false> hessian_type; //general hessian - non constant

	typedef sgl::DataPackage_3< sgl::MatrixData<T>,
			sgl::GroupData,
			sgl::Data<sgl::vector, 'W'> > data_type;

	mutable sgl::matrix_field hessian_matrices;

	mutable bool hessians_computed;


	MultinomialLoss() :
            n_samples(0), n_responses(0), Y(sgl::null_natural_vector), W(sgl::null_vector), prob(n_samples, n_responses), hessian_matrices(), hessians_computed(false) {
	}

	MultinomialLoss(data_type const& data) :
			n_samples(data.get_A().n_samples),
			n_responses(data.get_B().n_groups),
			Y(data.get_B().grouping),
			W(data.get_C().data),
			prob(n_samples, n_responses), hessian_matrices(n_samples), hessians_computed(false) {

		set_lp_zero();
	}

	//template<typename T>
	void set_lp(sgl::matrix const& link);
	void set_lp_zero();

	const sgl::matrix gradients() const {

		sgl::matrix grad(trans(prob));

		for (sgl::natural i = 0; i < n_samples; ++i) {
			grad(Y(i), i) -= 1;
			grad.col(i) *= W(i);
		}

		return grad;
	}

	void compute_hessians() const {

		if (hessians_computed) {
			return;
		}

		for(sgl::natural i = 0; i < n_samples; ++i) {
			hessian_matrices(i) = W(i) * (diagmat(prob.row(i)) - trans(prob.row(i)) * prob.row(i));
		}

		hessians_computed = true;
	}

    const sgl::matrix& hessians(sgl::natural i) const {
		return  hessian_matrices(i);
	}

	const sgl::matrix& probabilities() const {
		return prob;
	}

	const sgl::numeric sum_values() const {

		sgl::numeric val = 0;

		for (sgl::natural i = 0; i < n_samples; ++i) {
			val += -W(i) * log(prob(i, Y(i)));
		}

		return (val);

	}

};

// linp n_samples x n_responses the linear predictors
template<typename T>
void MultinomialLoss<T>::set_lp(sgl::matrix const& linp) {

	prob = trunc_exp(linp);

	for (sgl::natural i = 0; i < n_samples; ++i) {
		prob.row(i) *= 1 / as_scalar(sum(prob.row(i), 1));
	}

	ASSERT_IS_FINITE(prob);
	hessians_computed = false;
}

template<typename T>
void MultinomialLoss<T>::set_lp_zero() {

	prob.fill(1 / static_cast<sgl::numeric>(n_responses));
	hessians_computed = false;
}


typedef sgl::ObjectiveFunctionType < sgl::GenralizedLinearLossDense < MultinomialLoss < sgl::matrix > > ,
		MultinomialLoss < sgl::matrix >::data_type > multinomial;

typedef sgl::ObjectiveFunctionType <
		sgl::GenralizedLinearLossSparse < MultinomialLoss < sgl::sparse_matrix > > ,
		MultinomialLoss < sgl::sparse_matrix >::data_type > multinomial_spx;


#endif /* MULTINOMIAL_LOSS_HPP_ */
