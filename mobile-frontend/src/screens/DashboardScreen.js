import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { responsiveFontSize, responsiveHeight, responsiveWidth } from '../utils/responsive';
import { Icon } from '@rneui/themed';

const DashboardScreen = () => {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Credit Dashboard</Text>
      </View>
      
      <View style={styles.scoreContainer}>
        <Text style={styles.scoreLabel}>Your BlockScore</Text>
        <Text style={styles.scoreValue}>750</Text>
        <View style={styles.scoreBar}>
          <View style={[styles.scoreProgress, { width: '75%' }]} />
        </View>
        <Text style={styles.scoreDescription}>Excellent</Text>
      </View>
      
      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <Icon name="trending-up" type="material" color="#4CAF50" size={responsiveFontSize(3)} />
          <Text style={styles.statTitle}>Credit Growth</Text>
          <Text style={styles.statValue}>+15%</Text>
        </View>
        <View style={styles.statCard}>
          <Icon name="history" type="material" color="#2196F3" size={responsiveFontSize(3)} />
          <Text style={styles.statTitle}>History Length</Text>
          <Text style={styles.statValue}>5 years</Text>
        </View>
        <View style={styles.statCard}>
          <Icon name="account-balance" type="material" color="#FF9800" size={responsiveFontSize(3)} />
          <Text style={styles.statTitle}>Active Loans</Text>
          <Text style={styles.statValue}>2</Text>
        </View>
      </View>
      
      <View style={styles.actionsContainer}>
        <TouchableOpacity style={styles.actionButton}>
          <Text style={styles.actionButtonText}>Calculate Loan</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}>
          <Text style={styles.actionButtonText}>View History</Text>
        </TouchableOpacity>
      </View>
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
  scoreContainer: {
    alignItems: 'center',
    backgroundColor: 'white',
    margin: responsiveWidth(4),
    padding: responsiveHeight(3),
    borderRadius: 10,
    elevation: 3,
  },
  scoreLabel: {
    fontSize: responsiveFontSize(2),
    color: '#757575',
  },
  scoreValue: {
    fontSize: responsiveFontSize(5),
    fontWeight: 'bold',
    color: '#3f51b5',
    marginVertical: responsiveHeight(1),
  },
  scoreBar: {
    width: '100%',
    height: responsiveHeight(1.5),
    backgroundColor: '#e0e0e0',
    borderRadius: 10,
    marginVertical: responsiveHeight(1),
  },
  scoreProgress: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 10,
  },
  scoreDescription: {
    fontSize: responsiveFontSize(1.8),
    color: '#4CAF50',
    fontWeight: 'bold',
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginHorizontal: responsiveWidth(4),
  },
  statCard: {
    backgroundColor: 'white',
    padding: responsiveHeight(2),
    borderRadius: 10,
    alignItems: 'center',
    width: responsiveWidth(28),
    elevation: 2,
  },
  statTitle: {
    fontSize: responsiveFontSize(1.5),
    color: '#757575',
    marginTop: responsiveHeight(1),
  },
  statValue: {
    fontSize: responsiveFontSize(1.8),
    fontWeight: 'bold',
    color: '#212121',
  },
  actionsContainer: {
    marginHorizontal: responsiveWidth(4),
    marginVertical: responsiveHeight(3),
  },
  actionButton: {
    backgroundColor: '#3f51b5',
    padding: responsiveHeight(2),
    borderRadius: 5,
    alignItems: 'center',
    marginBottom: responsiveHeight(1.5),
  },
  actionButtonText: {
    color: 'white',
    fontSize: responsiveFontSize(2),
    fontWeight: 'bold',
  },
});

export default DashboardScreen;
