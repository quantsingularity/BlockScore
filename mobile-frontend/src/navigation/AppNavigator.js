import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';

import DashboardScreen from '../screens/DashboardScreen';
import CreditHistoryScreen from '../screens/CreditHistoryScreen';
import LoanCalculatorScreen from '../screens/LoanCalculatorScreen';

const Stack = createNativeStackNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Dashboard">
        {/* Define screens here - Temporarily using Dashboard as initial for dev */}
        {/* <Stack.Screen name="Home" component={HomeScreen} options={{ title: 'BlockScore Home' }} /> */}
        <Stack.Screen
          name="Dashboard"
          component={DashboardScreen}
          options={{headerShown: false}} // Hide header for custom header in screen
        />
        <Stack.Screen
          name="CreditHistory"
          component={CreditHistoryScreen}
          options={{headerShown: false}} // Hide header for custom header in screen
        />
        <Stack.Screen
          name="LoanCalculator"
          component={LoanCalculatorScreen}
          options={{headerShown: false}} // Hide header for custom header in screen
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
