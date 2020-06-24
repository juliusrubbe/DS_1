'''
Dieses Skript führt den boosting decision tree, GradientBoostingClassifier aus und optimiert zusätzlich die Settings des Modells.
'''
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.inspection import permutation_importance
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingClassifier
from sklearn import metrics
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from numpy import array
from numpy import argmax



def make_export_data():
	'''
	Datenaufbereitung
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



def boostedDecisionTree_Feature_Implementation(export_data):
	'''
	Optimize Gradient Boosted Decision Tree Algorithm for the prediction.
	'''


	# Splitting Data into dependent (Y) and independent (X) variables.
	Y = export_data[["category_rent"]]
	X = export_data.drop(["category_rent"], axis=1)

	# Splitting Data into Testing and Training Data.
	x_train, x_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state=32)


	# Range of values to be used for each Setting of the gradient-boosting-algorithm.
	rate_learning_list = [0.1] #, 0.25, 0.5
	max_depth_list = [6] #4, 5, 6, 7, 8
	n_estimators_list = [10] # 20, 100, 
	max_features_list = [13] # 3, 7, 

	# A list to save all the results and one to count the number of models.
	count_model = 0
	all_results = {}
	highestAccuracy = {"accuracy": 0, "algorith": ""}


	# Looping through all values for each setting and saving the results.
	for learning_rate in rate_learning_list:
		for max_depth in max_depth_list:
			for max_features in max_features_list:
				for n_estimators in n_estimators_list:
					# Save characteristics (settings) of model.
					all_results[count_model] = {"name":count_model, "learning_rate":learning_rate, "max_depth":max_depth, "max_features":max_features, "n_estimators":n_estimators}
					# Define characteristics (settings) of model.
					all_results[count_model]["gb_clf"] = GradientBoostingClassifier(n_estimators=n_estimators, learning_rate=learning_rate, max_features=max_features, max_depth=max_depth, random_state=32)
					# Build model with traing data.
					all_results[count_model]["gb_clf"].fit(x_train,y_train.values.ravel())
					# Test model on testing (validation) Dataset and save results.
					all_results[count_model]["accuracy_training"] = all_results[count_model]["gb_clf"].score(x_train, y_train)
					all_results[count_model]["accuracy_validation"] = all_results[count_model]["gb_clf"].score(x_test, y_test)
					print("Progress", count_model," of 135 models build") # Progress bar during model optimization.
					# Check if model is the best for further investigation.
					if all_results[count_model]["accuracy_validation"] > highestAccuracy["accuracy"]:
						highestAccuracy["accuracy"] = all_results[count_model]["accuracy_validation"]
						highestAccuracy["algorith"] = all_results[count_model]
					count_model += 1
	return all_results, highestAccuracy, x_train, x_test, y_train, y_test


def boostedDecisionTree_Feature_Importance(all_results, highestAccuracy, export_data, x_train, x_test, y_train, y_test):
	'''
	Check performance and feature importance of optimal Boosted Gradient Decsion Tree Model.
	'''
	text_file = open("Output.txt", "w")
	# Show distribution of dependent variable in data set.
	text_file.write(str(export_data['category_rent'].value_counts()))
	# Show information about all models.
	text_file.write(str(all_results))
	# show result of each model.
	for key in all_results:
		text_file.write(str(str(all_results[key]["name"]) + " " + str(all_results[key]["accuracy_validation"]) + ";"))

	# Show the information of the best model
	text_file.write("The best model has the following specifications:")
	text_file.write(str("learning_rate = " + str(highestAccuracy["algorith"]["learning_rate"]) + ", max_depth = " + str(highestAccuracy["algorith"]["max_depth"]) + ", max_features = " + str(highestAccuracy["algorith"]["max_features"]) + ", n_estimators = " + str(highestAccuracy["algorith"]["n_estimators"])))
	text_file.write(str("Accuracy (training) = " + str(highestAccuracy["algorith"]["accuracy_training"])))
	text_file.write("Accuracy (validation) = " + str(highestAccuracy["algorith"]["accuracy_validation"]))

	# Show confusion matrix and classification report of model.
	prediction = highestAccuracy["algorith"]["gb_clf"].predict(x_test)
	text_file.write("Confusion Matrix:")
	text_file.write(str(confusion_matrix(y_test, prediction)))
	text_file.write("Classification Report")
	text_file.write(str(classification_report(y_test, prediction)))
	

	# Check feature importance.
	# Source of Code: https://scikit-learn.org/stable/auto_examples/ensemble/plot_gradient_boosting_regression.html
	


	# Check feature importance of best model.
	feature_importance = highestAccuracy["algorith"]["gb_clf"].feature_importances_
	sorted_idx = np.argsort(feature_importance)


	# Check the cumulated feature importance of demographic Data.
	list_demographisch = ["Bevoelkerung_m","Bevoelkerung_w","LON","LAT","Siedlungsdichte_Schluessel","Arbeitslosenquote","Arbeitslose","AvgAge_total","AvgAge_female","AvgAge_male","BIP","BIP_pro_Einwohner","BIP_pro_Erwerbstaetige","Einkommen_proKopf","Einkommen_total","Arbeitslosenquote_bl","AvgAge_male_bl","BIP_pro_Einwohner_bl","newlyConst","balcony","hasKitchen","cellar","lift","garden","Siedlungsdichte_Name"]
	counter = 0
	for i, n in enumerate(np.array(export_data.columns)[sorted_idx]):
		if n in list_demographisch:
			counter += feature_importance[sorted_idx][i]
	text_file.write(str(counter))
	text_file.close()
	
	# Build plot to show feature importance. 
	pos = np.arange(sorted_idx.shape[0]) + .5
	fig = plt.figure(figsize=(12, 6))
	plt.subplot(1, 2, 1)
	plt.barh(pos, feature_importance[sorted_idx], align='center')
	plt.yticks(pos, np.array(export_data.columns)[sorted_idx])
	plt.title('Feature Importance (MDI)')
	result = permutation_importance(highestAccuracy["algorith"]["gb_clf"], x_test, y_test, n_repeats=5, random_state=42, n_jobs=2)
	sorted_idx = result.importances_mean.argsort()
	plt.subplot(1, 2, 2)
	plt.boxplot(result.importances[sorted_idx].T,vert=False, labels=np.array(export_data.columns)[sorted_idx])
	plt.title("Importance (test set)")
	fig.tight_layout()
	plt.savefig('feature_importance.png')


def boostedDecisionTree(export_data):
	'''
	Build Gradient Boosted Decision Tree Model with optimization. 
	'''
	# Optimize model.
	all_results, highestAccuracy, x_train, x_test, y_train, y_test = boostedDecisionTree_Feature_Implementation(export_data)
	# Check results and feature importance of best model.
	boostedDecisionTree_Feature_Importance(all_results, highestAccuracy, export_data, x_train, x_test, y_train, y_test)




def main():
	export_data = make_export_data()
	boostedDecisionTree(export_data)

if __name__ == "__main__":
    main()


