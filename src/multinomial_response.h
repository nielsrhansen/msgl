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

#ifndef MSGL_MULTINOMIAL_RESPONSE_H_
#define MSGL_MULTINOMIAL_RESPONSE_H_

class PredictedClass {};
class LP {};
class Probabilities {};

class MultinomialResponse {

public:

	sgl::natural const n_classes;

	sgl::natural const predicted_class; // 1 based, i.e first classes has number 1 (not 0)
	sgl::vector const linear_predictors;
	sgl::vector const probabilities;

	MultinomialResponse(sgl::vector const& linear_predictors) :
			n_classes(linear_predictors.n_elem), predicted_class(argmax(linear_predictors)+1), linear_predictors(
					linear_predictors), probabilities(exp(linear_predictors) * (1/ sum(exp(linear_predictors)))) {
	}

	//Needed so that we can use fields
	MultinomialResponse() :
			n_classes(0), predicted_class(0), linear_predictors(), probabilities() {
	}

	MultinomialResponse const& operator=(MultinomialResponse const& s)
	{
		const_cast<sgl::natural&>(this->n_classes) = s.n_classes;
		const_cast<sgl::natural&>(this->predicted_class) = s.predicted_class;
		const_cast<sgl::vector&>(this->linear_predictors) = s.linear_predictors;
		const_cast<sgl::vector&>(this->probabilities) = s.probabilities;

		return *this;
	}

    sgl::natural const& get(PredictedClass) const {
        return predicted_class;
    }

    sgl::vector const& get(LP) const {
        return linear_predictors;
    }

    sgl::vector const& get(Probabilities) const {
        return probabilities;
    }

    template<typename T>
    static rList simplify(T const& responses) {

        rList list;

        list.attach(sgl::simplifier<sgl::vector, LP>::simplify(responses), "link");
        list.attach(sgl::simplifier<sgl::vector, Probabilities>::simplify(responses), "response");
        list.attach(sgl::simplifier<sgl::natural, PredictedClass>::simplify(responses), "classes");

        return list;
    }

};





#endif /* MSGL_MULTINOMIAL_RESPONSE_H_ */
