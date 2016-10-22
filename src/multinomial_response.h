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

using namespace sgl;

class MultinomialResponse : public elements < MultinomialResponse > {

private:

	vector const linear_predictors;

public:
	MultinomialResponse(sgl::vector const& linear_predictors) :
		linear_predictors(linear_predictors) {}

	//Needed so that we can use fields
	MultinomialResponse() :
			linear_predictors(null_vector) {}

	MultinomialResponse const& operator=(MultinomialResponse const& s) {
		const_cast < vector & > ( this->linear_predictors ) = s.linear_predictors;

		return * this;
	}

	rList as_rList() const {

		rList list;

		vector prob = exp(linear_predictors) * (1 / sum(exp(linear_predictors)));
		natural class_index = linear_predictors.index_max() + 1;

		list.attach(linear_predictors, "link");
		list.attach(prob, "response");
		list.attach(class_index, "classes");

		return list;

	}

};

#endif /* MSGL_MULTINOMIAL_RESPONSE_H_ */
