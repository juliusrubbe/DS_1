import pandas as pd
import time
import os
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn import metrics
from sklearn.model_selection import train_test_split
import math
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.feature_selection import RFE
import matplotlib.pylab as plt
import matplotlib


def make_export_data():
	'''
	Data-Preprocessing
	'''
	data = pd.read_csv("data_prepared_and_ready_numeric_2.csv", sep=";")
	dummy_vars = data[["population_density", "no_rooms_range", "newly_const", "balcony", "has_kitchen", "cellar", "lift", "garden", "category_rent"  ]]
	numerical_vars = data.drop(["population_density", "no_rooms_range", "newly_const", "balcony", "has_kitchen", "cellar", "lift", "garden", "category_rent"  ], axis=1)
	#build dummies for categorial vars
	categorial_list = ["population_density", "no_rooms_range"]
	for var in categorial_list:
		new_dummies = pd.get_dummies(dummy_vars[var],prefix=var)
		dummy_vars = dummy_vars.join(pd.DataFrame(new_dummies), how='outer')
		del dummy_vars[var]

	scale = StandardScaler()  
	cols = numerical_vars.columns
	numerical_vars = scale.fit_transform(numerical_vars)
	numerical_vars = pd.DataFrame(data=numerical_vars, columns=cols)
	numerical_vars.reset_index(drop=True, inplace=True)
	dummy_vars.reset_index(drop=True, inplace=True)
	#merge both types of variables
	export_data = dummy_vars.join(numerical_vars, how='outer')
	return export_data


def KNN_Feature_Implementation(export_data):
	'''
	Optimize KNN Algorithm for the prediction by finding optimal K.
	'''
	Y = export_data[["category_rent"]]
	X = export_data.drop(["category_rent"], axis=1)
	#Y_encoded = to_categorical(Y)
	x_train, x_test, y_train, y_test =    train_test_split(X, Y, test_size= .2, random_state=32)
	
	n_neighbors = list(range(3, 200 ,2))

	results = {}
	highestAccuracy = {"accuracy": 0, "k": ""}
	program_starts = time.time()

	for k in n_neighbors:
	
		clf1=KNeighborsClassifier(n_neighbors = k)

		#Train the model using the training sets y_pred=clf.predict(X_test)
		clf1.fit(x_train,y_train.values.ravel())

		y_pred1=clf1.predict(x_test)
	
		now = time.time()
		results[metrics.accuracy_score(y_test, y_pred1)] = k
		print("It has been {0} seconds since the loop started".format(now - program_starts))    
		print("k = ", k)
		print("Accuracy:",metrics.accuracy_score(y_test, y_pred1))

	print("Max Accuracy:", max(results), "with k equals: ", results[max(results)])

	highestAccuracy = {"accuracy": max(results), "k": results[max(results)]}
	
	#do it for best K again
	clf1=KNeighborsClassifier(n_neighbors = results[max(results)])
	
	#Train the model using the training sets y_pred=clf.predict(X_test)
	clf1.fit(x_train,y_train.values.ravel())
	
	y_pred1=clf1.predict(x_test)
		
	results[metrics.accuracy_score(y_test, y_pred1)] = results[max(results)]
	print("It has been {0} seconds since the loop started".format(now - program_starts))    
	print("k = ", results[max(results)])
	print("Accuracy:",metrics.accuracy_score(y_test, y_pred1))
	
	return results, highestAccuracy, x_train, y_train


def Feature_Importance(export_data, x_train, y_train):
	'''
	Get the feature importance calculated by the algorithm
	'''
	reg = LassoCV()
	reg.fit(x_train, y_train)
	print("Best alpha using built-in LassoCV: %f" % reg.alpha_)
	print("Best score using built-in LassoCV: %f" %reg.score(x_train,y_train))
	coef = pd.Series(reg.coef_, index = x_train.columns)

	print("Lasso picked " + str(sum(coef != 0)) + " variables and eliminated the other " +  str(sum(coef == 0)) + " variables")

	imp_coef = coef.sort_values()
	matplotlib.rcParams['figure.figsize'] = (20.0, 20.0)
	imp_coef.plot(kind = "barh")
	plt.title("Feature importance using Lasso Model")

	ax = imp_coef.plot(kind = "barh")
	fig = ax.get_figure()
	fig.savefig('feature_importance.pdf')
	fig.savefig('feature_importance.png')
	
	return fig

def plot_k_variation(results):
	'''
	create a plot to visualize the influence of k
	'''
	x = list(results.keys())
	x = list(range(3,99,2))
	acc = list()
	for k in results.keys():
	    acc.append(results[k])
	plt.figure()
	plt.plot(x, acc, color='blue')
	plt.ylabel('accuracy')
	plt.xlabel("k value")
	#plt.xticks([5,10,15,20,10,12,14,16,18,20])
	plt.grid()
	plt.show()

def main():
	export_data = make_export_data()
	KNN_Feature_Implementation(export_data)
	plot_k_variation(KNN_Feature_Implementation(make_export_data())[0])
	
if __name__ == "__main__":
	main()
	

