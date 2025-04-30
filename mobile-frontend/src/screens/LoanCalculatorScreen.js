import React from 'react';
import { View, Text, StyleSheet, ScrollView, TextInput, TouchableOpacity } from 'react-native';
import { responsiveFontSize, responsiveHeight, responsiveWidth } from '../utils/responsive';
import { Slider } from '@rneui/themed';

const LoanCalculatorScreen = () => {
  const [loanAmount, setLoanAmount] = React.useState(10000);
  const [loanTerm, setLoanTerm] = React.useState(36);
  const [interestRate, setInterestRate] = React.useState(5.5);
  
  // Calculate monthly payment
  const calculateMonthlyPayment = () => {
    const principal = loanAmount;
    const monthlyRate = interestRate / 100 / 12;
    const numberOfPayments = loanTerm;
    
    const monthlyPayment = principal * monthlyRate * Math.pow(1 + monthlyRate, numberOfPayments) / 
                          (Math.pow(1 + monthlyRate, numberOfPayments) - 1);
    
    return isNaN(monthlyPayment) ? 0 : monthlyPayment.toFixed(2);
  };
  
  // Calculate total payment
  const calculateTotalPayment = () => {
    const monthlyPayment = calculateMonthlyPayment();
    return (monthlyPayment * loanTerm).toFixed(2);
  };
  
  // Calculate total interest
  const calculateTotalInterest = () => {
    const totalPayment = calculateTotalPayment();
    return (totalPayment - loanAmount).toFixed(2);
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Loan Calculator</Text>
      </View>
      
      <View style={styles.calculatorContainer}>
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Loan Amount</Text>
          <View style={styles.inputContainer}>
            <Text style={styles.currencySymbol}>$</Text>
            <TextInput
              style={styles.input}
              keyboardType="numeric"
              value={loanAmount.toString()}
              onChangeText={(text) => setLoanAmount(text ? parseFloat(text) : 0)}
            />
          </View>
          <Slider
            value={loanAmount}
            onValueChange={value => setLoanAmount(value)}
            minimumValue={1000}
            maximumValue={100000}
            step={1000}
            thumbStyle={styles.thumbStyle}
            trackStyle={styles.trackStyle}
            minimumTrackTintColor="#3f51b5"
          />
          <View style={styles.sliderLabels}>
            <Text style={styles.sliderLabel}>$1,000</Text>
            <Text style={styles.sliderLabel}>$100,000</Text>
          </View>
        </View>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Loan Term (months)</Text>
          <View style={styles.inputContainer}>
            <TextInput
              style={styles.input}
              keyboardType="numeric"
              value={loanTerm.toString()}
              onChangeText={(text) => setLoanTerm(text ? parseInt(text) : 0)}
            />
          </View>
          <Slider
            value={loanTerm}
            onValueChange={value => setLoanTerm(value)}
            minimumValue={12}
            maximumValue={84}
            step={12}
            thumbStyle={styles.thumbStyle}
            trackStyle={styles.trackStyle}
            minimumTrackTintColor="#3f51b5"
          />
          <View style={styles.sliderLabels}>
            <Text style={styles.sliderLabel}>12 mo</Text>
            <Text style={styles.sliderLabel}>84 mo</Text>
          </View>
        </View>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Interest Rate (%)</Text>
          <View style={styles.inputContainer}>
            <TextInput
              style={styles.input}
              keyboardType="numeric"
              value={interestRate.toString()}
              onChangeText={(text) => setInterestRate(text ? parseFloat(text) : 0)}
            />
            <Text style={styles.percentSymbol}>%</Text>
          </View>
          <Slider
            value={interestRate}
            onValueChange={value => setInterestRate(value)}
            minimumValue={1}
            maximumValue={20}
            step={0.1}
            thumbStyle={styles.thumbStyle}
            trackStyle={styles.trackStyle}
            minimumTrackTintColor="#3f51b5"
          />
          <View style={styles.sliderLabels}>
            <Text style={styles.sliderLabel}>1%</Text>
            <Text style={styles.sliderLabel}>20%</Text>
          </View>
        </View>
      </View>
      
      <View style={styles.resultsContainer}>
        <Text style={styles.resultsTitle}>Loan Summary</Text>
        
        <View style={styles.resultRow}>
          <Text style={styles.resultLabel}>Monthly Payment:</Text>
          <Text style={styles.resultValue}>${calculateMonthlyPayment()}</Text>
        </View>
        
        <View style={styles.resultRow}>
          <Text style={styles.resultLabel}>Total Payment:</Text>
          <Text style={styles.resultValue}>${calculateTotalPayment()}</Text>
        </View>
        
        <View style={styles.resultRow}>
          <Text style={styles.resultLabel}>Total Interest:</Text>
          <Text style={styles.resultValue}>${calculateTotalInterest()}</Text>
        </View>
      </View>
      
      <TouchableOpacity style={styles.actionButton}>
        <Text style={styles.actionButtonText}>Apply for Loan</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: responsiveHeight(2),
    backgroundColor: '#3f51b5',
  },
  headerTitle: {
    fontSize: responsiveFontSize(2.5),
    fontWeight: 'bold',
    color: 'white',
  },
  calculatorContainer: {
    backgroundColor: 'white',
    margin: responsiveWidth(4),
    padding: responsiveHeight(2),
    borderRadius: 10,
    elevation: 3,
  },
  inputGroup: {
    marginBottom: responsiveHeight(2.5),
  },
  inputLabel: {
    fontSize: responsiveFontSize(1.8),
    fontWeight: 'bold',
    marginBottom: responsiveHeight(1),
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 5,
    marginBottom: responsiveHeight(1),
  },
  currencySymbol: {
    paddingHorizontal: responsiveWidth(2),
    fontSize: responsiveFontSize(2),
    color: '#757575',
  },
  percentSymbol: {
    paddingHorizontal: responsiveWidth(2),
    fontSize: responsiveFontSize(2),
    color: '#757575',
  },
  input: {
    flex: 1,
    padding: responsiveHeight(1.5),
    fontSize: responsiveFontSize(2),
  },
  thumbStyle: {
    height: responsiveHeight(2.5),
    width: responsiveHeight(2.5),
    backgroundColor: '#3f51b5',
  },
  trackStyle: {
    height: responsiveHeight(0.8),
    borderRadius: 5,
  },
  sliderLabels: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: responsiveHeight(0.5),
  },
  sliderLabel: {
    fontSize: responsiveFontSize(1.4),
    color: '#757575',
  },
  resultsContainer: {
    backgroundColor: 'white',
    margin: responsiveWidth(4),
    padding: responsiveHeight(2),
    borderRadius: 10,
    elevation: 3,
  },
  resultsTitle: {
    fontSize: responsiveFontSize(2),
    fontWeight: 'bold',
    marginBottom: responsiveHeight(2),
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: responsiveHeight(1),
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  resultLabel: {
    fontSize: responsiveFontSize(1.8),
    color: '#212121',
  },
  resultValue: {
    fontSize: responsiveFontSize(1.8),
    fontWeight: 'bold',
    color: '#3f51b5',
  },
  actionButton: {
    backgroundColor: '#3f51b5',
    padding: responsiveHeight(2),
    borderRadius: 5,
    alignItems: 'center',
    marginHorizontal: responsiveWidth(4),
    marginVertical: responsiveHeight(3),
  },
  actionButtonText: {
    color: 'white',
    fontSize: responsiveFontSize(2),
    fontWeight: 'bold',
  },
});

export default LoanCalculatorScreen;
