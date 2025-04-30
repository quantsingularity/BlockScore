import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { responsiveFontSize, responsiveHeight, responsiveWidth } from '../utils/responsive';
import { LineChart } from 'react-native-chart-kit';

const CreditHistoryScreen = () => {
  // Sample data for the chart
  const data = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        data: [680, 700, 710, 695, 730, 750],
        color: (opacity = 1) => `rgba(63, 81, 181, ${opacity})`,
        strokeWidth: 2
      }
    ],
    legend: ['Credit Score']
  };

  const chartConfig = {
    backgroundGradientFrom: '#ffffff',
    backgroundGradientTo: '#ffffff',
    decimalPlaces: 0,
    color: (opacity = 1) => `rgba(63, 81, 181, ${opacity})`,
    labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
    style: {
      borderRadius: 16
    },
    propsForDots: {
      r: '6',
      strokeWidth: '2',
      stroke: '#3f51b5'
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Credit History</Text>
      </View>
      
      <View style={styles.chartContainer}>
        <Text style={styles.chartTitle}>Score Trend</Text>
        <LineChart
          data={data}
          width={responsiveWidth(90)}
          height={responsiveHeight(30)}
          chartConfig={chartConfig}
          bezier
          style={styles.chart}
        />
      </View>
      
      <View style={styles.historyContainer}>
        <Text style={styles.sectionTitle}>Recent Activities</Text>
        
        <View style={styles.historyItem}>
          <View style={styles.historyDate}>
            <Text style={styles.dateText}>APR</Text>
            <Text style={styles.dateNumber}>15</Text>
          </View>
          <View style={styles.historyContent}>
            <Text style={styles.historyTitle}>Loan Payment</Text>
            <Text style={styles.historyDescription}>On-time payment recorded</Text>
          </View>
          <View style={styles.historyScore}>
            <Text style={styles.scoreChange}>+5</Text>
          </View>
        </View>
        
        <View style={styles.historyItem}>
          <View style={styles.historyDate}>
            <Text style={styles.dateText}>MAR</Text>
            <Text style={styles.dateNumber}>22</Text>
          </View>
          <View style={styles.historyContent}>
            <Text style={styles.historyTitle}>Credit Inquiry</Text>
            <Text style={styles.historyDescription}>Mortgage pre-approval</Text>
          </View>
          <View style={styles.historyScore}>
            <Text style={[styles.scoreChange, styles.negative]}>-2</Text>
          </View>
        </View>
        
        <View style={styles.historyItem}>
          <View style={styles.historyDate}>
            <Text style={styles.dateText}>MAR</Text>
            <Text style={styles.dateNumber}>10</Text>
          </View>
          <View style={styles.historyContent}>
            <Text style={styles.historyTitle}>Credit Card Payment</Text>
            <Text style={styles.historyDescription}>Paid in full</Text>
          </View>
          <View style={styles.historyScore}>
            <Text style={styles.scoreChange}>+3</Text>
          </View>
        </View>
        
        <View style={styles.historyItem}>
          <View style={styles.historyDate}>
            <Text style={styles.dateText}>FEB</Text>
            <Text style={styles.dateNumber}>28</Text>
          </View>
          <View style={styles.historyContent}>
            <Text style={styles.historyTitle}>Loan Payment</Text>
            <Text style={styles.historyDescription}>On-time payment recorded</Text>
          </View>
          <View style={styles.historyScore}>
            <Text style={styles.scoreChange}>+5</Text>
          </View>
        </View>
      </View>
      
      <TouchableOpacity style={styles.actionButton}>
        <Text style={styles.actionButtonText}>View Full History</Text>
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
  chartContainer: {
    backgroundColor: 'white',
    margin: responsiveWidth(4),
    padding: responsiveHeight(2),
    borderRadius: 10,
    alignItems: 'center',
    elevation: 3,
  },
  chartTitle: {
    fontSize: responsiveFontSize(2),
    fontWeight: 'bold',
    marginBottom: responsiveHeight(1),
  },
  chart: {
    marginVertical: responsiveHeight(1),
    borderRadius: 10,
  },
  historyContainer: {
    backgroundColor: 'white',
    margin: responsiveWidth(4),
    padding: responsiveHeight(2),
    borderRadius: 10,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: responsiveFontSize(2),
    fontWeight: 'bold',
    marginBottom: responsiveHeight(2),
  },
  historyItem: {
    flexDirection: 'row',
    paddingVertical: responsiveHeight(1.5),
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  historyDate: {
    width: responsiveWidth(12),
    alignItems: 'center',
    justifyContent: 'center',
  },
  dateText: {
    fontSize: responsiveFontSize(1.4),
    color: '#757575',
  },
  dateNumber: {
    fontSize: responsiveFontSize(1.8),
    fontWeight: 'bold',
  },
  historyContent: {
    flex: 1,
    paddingHorizontal: responsiveWidth(2),
  },
  historyTitle: {
    fontSize: responsiveFontSize(1.8),
    fontWeight: 'bold',
  },
  historyDescription: {
    fontSize: responsiveFontSize(1.5),
    color: '#757575',
  },
  historyScore: {
    width: responsiveWidth(10),
    alignItems: 'center',
    justifyContent: 'center',
  },
  scoreChange: {
    fontSize: responsiveFontSize(1.8),
    fontWeight: 'bold',
    color: '#4CAF50',
  },
  negative: {
    color: '#F44336',
  },
  actionButton: {
    backgroundColor: '#3f51b5',
    padding: responsiveHeight(2),
    borderRadius: 5,
    alignItems: 'center',
    marginHorizontal: responsiveWidth(4),
    marginBottom: responsiveHeight(3),
  },
  actionButtonText: {
    color: 'white',
    fontSize: responsiveFontSize(2),
    fontWeight: 'bold',
  },
});

export default CreditHistoryScreen;
