import React from 'react';
import { StyleSheet, ScrollView, View, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import Colors from '../constants/Colors';
import { Text } from '../components/ThemedText';
import { View as ThemedView } from '../components/ThemedView';
import { useColorScheme } from '../hooks/useColorScheme';

// Dummy data - would come from API in real app
const USAGE_DATA = {
  today: {
    timeSpent: 45, // minutes
    contentViewed: 17,
    platforms: {
      twitter: 25,
      instagram: 15,
      youtube: 5
    }
  },
  weekly: {
    timeSpent: 315, // minutes
    contentViewed: 124,
    timeByDay: [35, 42, 50, 38, 55, 45, 50], // last 7 days
    savedByDay: [2, 5, 3, 1, 4, 3, 2]
  },
  monthly: {
    timeSpent: 1260, // minutes
    contentViewed: 487,
    timeByWeek: [280, 320, 350, 310]
  },
  insights: [
    {
      title: "Most Active Time",
      value: "8-10 AM",
      icon: "clock"
    },
    {
      title: "Most Viewed Platform",
      value: "Twitter",
      icon: "twitter"
    },
    {
      title: "Time Saved vs. Traditional Apps",
      value: "4.2 hrs/week",
      icon: "trending-down"
    }
  ]
};

// Component for displaying bar charts
const BarChart = ({ data, maxValue, color }) => {
  return (
    <View style={styles.chartContainer}>
      {data.map((value, index) => (
        <View key={index} style={styles.barContainer}>
          <View 
            style={[
              styles.bar, 
              { 
                height: Math.max((value / maxValue) * 100, 5),
                backgroundColor: color 
              }
            ]} 
          />
          <Text style={styles.barLabel}>{['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]}</Text>
        </View>
      ))}
    </View>
  );
};

// Component for insight card
const InsightCard = ({ title, value, icon, color }) => {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme];
  
  return (
    <View style={[styles.insightCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
      <View style={[styles.insightIconContainer, { backgroundColor: color + '20' }]}>
        <Feather name={icon} size={20} color={color} />
      </View>
      <View style={styles.insightContent}>
        <Text style={styles.insightTitle}>{title}</Text>
        <Text style={styles.insightValue}>{value}</Text>
      </View>
    </View>
  );
};

export default function AnalyticsScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme];
  
  return (
    <ThemedView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Today's Summary</Text>
          <View style={[styles.summaryCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.summaryItem}>
              <Feather name="clock" size={24} color={colors.tint} style={styles.summaryIcon} />
              <View>
                <Text style={styles.summaryValue}>{USAGE_DATA.today.timeSpent} min</Text>
                <Text style={styles.summaryLabel}>Time Spent</Text>
              </View>
            </View>
            <View style={[styles.divider, { backgroundColor: colors.separator }]} />
            <View style={styles.summaryItem}>
              <Feather name="eye" size={24} color={colors.tint} style={styles.summaryIcon} />
              <View>
                <Text style={styles.summaryValue}>{USAGE_DATA.today.contentViewed}</Text>
                <Text style={styles.summaryLabel}>Content Viewed</Text>
              </View>
            </View>
          </View>
        </View>
        
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Weekly Activity</Text>
            <TouchableOpacity onPress={() => {/* Show detailed view */}}>
              <Text style={[styles.sectionAction, { color: colors.tint }]}>See Details</Text>
            </TouchableOpacity>
          </View>
          
          <Text style={styles.chartTitle}>Time Spent (minutes)</Text>
          <BarChart 
            data={USAGE_DATA.weekly.timeByDay} 
            maxValue={Math.max(...USAGE_DATA.weekly.timeByDay)} 
            color={colors.tint} 
          />
          
          <Text style={styles.chartTitle}>Content Saved</Text>
          <BarChart 
            data={USAGE_DATA.weekly.savedByDay} 
            maxValue={Math.max(...USAGE_DATA.weekly.savedByDay)} 
            color={colors.accent} 
          />
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Platform Breakdown</Text>
          <View style={[styles.platformCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            {Object.entries(USAGE_DATA.today.platforms).map(([platform, minutes]) => (
              <View key={platform} style={styles.platformItem}>
                <View style={styles.platformInfo}>
                  <Feather name={platform === 'twitter' ? 'twitter' : platform === 'instagram' ? 'instagram' : 'youtube'} size={16} color={colors.text} />
                  <Text style={styles.platformName}>{platform.charAt(0).toUpperCase() + platform.slice(1)}</Text>
                </View>
                <View style={styles.platformBarContainer}>
                  <View 
                    style={[
                      styles.platformBar, 
                      { 
                        width: `${(minutes / USAGE_DATA.today.timeSpent) * 100}%`,
                        backgroundColor: platform === 'twitter' ? '#1DA1F2' : platform === 'instagram' ? '#C13584' : '#FF0000'
                      }
                    ]} 
                  />
                </View>
                <Text style={styles.platformTime}>{minutes} min</Text>
              </View>
            ))}
          </View>
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Insights</Text>
          <View style={styles.insightsGrid}>
            {USAGE_DATA.insights.map((insight, index) => (
              <InsightCard 
                key={index}
                title={insight.title}
                value={insight.value}
                icon={insight.icon}
                color={index === 0 ? '#4CAF50' : index === 1 ? '#1DA1F2' : '#FF9800'}
              />
            ))}
          </View>
        </View>
        
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>This Month</Text>
            <TouchableOpacity>
              <Text style={[styles.sectionAction, { color: colors.tint }]}>Full Report</Text>
            </TouchableOpacity>
          </View>
          <View style={[styles.monthCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.monthStats}>
              <View style={styles.monthStat}>
                <Text style={styles.monthStatValue}>{Math.floor(USAGE_DATA.monthly.timeSpent / 60)}</Text>
                <Text style={styles.monthStatLabel}>Hours Spent</Text>
              </View>
              <View style={styles.monthStat}>
                <Text style={styles.monthStatValue}>{USAGE_DATA.monthly.contentViewed}</Text>
                <Text style={styles.monthStatLabel}>Posts Viewed</Text>
              </View>
              <View style={styles.monthStat}>
                <Text style={styles.monthStatValue}>21</Text>
                <Text style={styles.monthStatLabel}>Content Saved</Text>
              </View>
            </View>
          </View>
        </View>
        
        <View style={styles.spacer} />
      </ScrollView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  section: {
    marginTop: 24,
    paddingHorizontal: 16,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  sectionAction: {
    fontSize: 14,
    fontWeight: '500',
  },
  summaryCard: {
    flexDirection: 'row',
    borderRadius: 12,
    borderWidth: 1,
    padding: 16,
  },
  summaryItem: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  summaryIcon: {
    marginRight: 12,
  },
  summaryValue: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 4,
  },
  summaryLabel: {
    fontSize: 14,
    opacity: 0.7,
  },
  divider: {
    width: 1,
    marginHorizontal: 16,
  },
  chartTitle: {
    fontSize: 14,
    fontWeight: '500',
    marginTop: 16,
    marginBottom: 8,
  },
  chartContainer: {
    height: 120,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginBottom: 16,
  },
  barContainer: {
    flex: 1,
    alignItems: 'center',
  },
  bar: {
    width: 8,
    borderRadius: 4,
    marginBottom: 4,
  },
  barLabel: {
    fontSize: 12,
  },
  platformCard: {
    borderRadius: 12,
    borderWidth: 1,
    padding: 16,
  },
  platformItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  platformInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    width: 100,
  },
  platformName: {
    marginLeft: 8,
    fontSize: 14,
  },
  platformBarContainer: {
    flex: 1,
    height: 8,
    backgroundColor: 'rgba(0,0,0,0.1)',
    borderRadius: 4,
    marginHorizontal: 12,
  },
  platformBar: {
    height: 8,
    borderRadius: 4,
  },
  platformTime: {
    width: 50,
    fontSize: 12,
    textAlign: 'right',
  },
  insightsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  insightCard: {
    width: '48%',
    borderRadius: 12,
    borderWidth: 1,
    padding: 16,
    marginBottom: 16,
  },
  insightIconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  insightContent: {
  },
  insightTitle: {
    fontSize: 12,
    opacity: 0.7,
    marginBottom: 4,
  },
  insightValue: {
    fontSize: 16,
    fontWeight: '600',
  },
  monthCard: {
    borderRadius: 12,
    borderWidth: 1,
    padding: 16,
  },
  monthStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  monthStat: {
    alignItems: 'center',
  },
  monthStatValue: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 4,
  },
  monthStatLabel: {
    fontSize: 12,
    opacity: 0.7,
  },
  spacer: {
    height: 40,
  },
});