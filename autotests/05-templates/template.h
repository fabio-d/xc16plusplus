#pragma once

template <typename T>
class FourElementsArray
{
	public:
		FourElementsArray(const T &e0, const T &e1, const T &e2, const T &e3)
		{
			e[0] = e0;
			e[1] = e1;
			e[2] = e2;
			e[3] = e3;
		}

		const T &readAt(unsigned int idx) const
		{
			return e[idx];
		}

		static T staticField;

	private:
		T e[4];
};

template<typename T>
T FourElementsArray<T>::staticField = 0;

template<typename T>
T templMin(T a, T b)
{
	return a < b ? a : b;
}
