"""
Utility used by the Network class to actually train.
Source code from https://github.com/harvitronix/neural-network-genetic-algorithm

"""
from keras.datasets import mnist, cifar10
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.utils.np_utils import to_categorical
from keras.callbacks import EarlyStopping
from sklearn.model_selection import train_test_split
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import LabelEncoder, OneHotEncoder

# Helper: Early stopping.
early_stopper = EarlyStopping(patience=5)

def get_immo():
    """Retrieve the prepared immo dataset and process the data."""
    # Set defaults.
    nb_classes = 9
    batch_size = 128
    input_shape = (30,)

    # convert class vectors to binary class matrices
    data = pd.read_csv("data_prepared_and_ready_numeric.csv", sep=";")
    del data["LON"]
    del data["LAT"]
    del data["baseRent"]
    del data["baseRentRange"]
    del data["rent_per_m2"]
    del data["Siedlungsdichte_Schluessel"]
    del data["livingSpaceRange"]
    dummy_vars = data[["Siedlungsdichte_Name", "noRoomsRange", "newlyConst", "balcony", "hasKitchen", "cellar", "lift",     "garden", "category_rent"  ]]
    numerical_vars = data.drop(["Siedlungsdichte_Name", "noRoomsRange", "newlyConst", "balcony", "hasKitchen", "cellar", "lift", "garden", "category_rent"  ], axis=1)
#build dummies for categorial vars
    categorial_list = ["Siedlungsdichte_Name", "noRoomsRange"]
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

    Y = export_data[["category_rent"]]
    X = export_data.drop(["category_rent"], axis=1)
    X = X.astype('float32')
    Y_encoded = to_categorical(Y)
    x_train, x_test, y_train, y_test =    train_test_split(X, Y_encoded, test_size=0.2, random_state=32)

    return (nb_classes, batch_size, input_shape, x_train, x_test, y_train, y_test)

def compile_model(network, nb_classes, input_shape):
    """Compile a sequential model.

    Args:
        network (dict): the parameters of the network

    Returns:
        a compiled network.

    """
    # Get our network parameters.
    nb_layers = network['nb_layers']
    nb_neurons = network['nb_neurons']
    activation = network['activation']
    optimizer = network['optimizer']

    model = Sequential()

    # Add each layer.
    for i in range(nb_layers):

        # Need input shape for first layer.
        if i == 0:
            model.add(Dense(nb_neurons, activation=activation, input_shape=input_shape))
        else:
            model.add(Dense(nb_neurons, activation=activation))

        model.add(Dropout(0.2))  # hard-coded dropout

    # Output layer.
    model.add(Dense(nb_classes, activation='softmax'))

    model.compile(loss='categorical_crossentropy', optimizer=optimizer,
                  metrics=['accuracy'])

    return model

def train_and_score(network, dataset):
    """Train the model, return test loss.

    Args:
        network (dict): the parameters of the network
        dataset (str): Dataset to use for training/evaluating

    """
    if dataset == 'cifar10':
        nb_classes, batch_size, input_shape, x_train, \
            x_test, y_train, y_test = get_cifar10()
    elif dataset == 'mnist':
        nb_classes, batch_size, input_shape, x_train, \
            x_test, y_train, y_test = get_mnist()
    else:
        nb_classes, batch_size, input_shape, x_train, \
            x_test, y_train, y_test = get_immo()

    model = compile_model(network, nb_classes, input_shape)

    model.fit(x_train, y_train,
              batch_size=batch_size,
              epochs=10000,  # using early stopping, so no real limit
              verbose=0,
              validation_data=(x_test, y_test),
              callbacks=[early_stopper])

    score = model.evaluate(x_test, y_test, verbose=0)

    return score[1]  # 1 is accuracy. 0 is loss.
