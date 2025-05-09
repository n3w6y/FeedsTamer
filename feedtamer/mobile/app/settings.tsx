import React, { useState } from 'react';
import { StyleSheet, ScrollView, View, Switch, TouchableOpacity, Alert } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { router } from 'expo-router';

import Colors from '../constants/Colors';
import { Text } from '../components/ThemedText';
import { View as ThemedView } from '../components/ThemedView';
import { useColorScheme } from '../hooks/useColorScheme';

// Settings sections data
const SETTINGS_SECTIONS = [
  {
    title: 'Account',
    items: [
      { key: 'profile', label: 'Profile', icon: 'user', type: 'link' },
      { key: 'subscription', label: 'Subscription', icon: 'star', type: 'link' },
      { key: 'platforms', label: 'Connected Platforms', icon: 'link', type: 'link' }
    ]
  },
  {
    title: 'Feed Preferences',
    items: [
      { key: 'view', label: 'Default View', icon: 'grid', type: 'link', value: 'Unified' },
      { key: 'showRead', label: 'Show Read Content', icon: 'eye', type: 'toggle', value: false },
      { key: 'order', label: 'Content Order', icon: 'list', type: 'link', value: 'Chronological' }
    ]
  },
  {
    title: 'Attention Management',
    items: [
      { key: 'timeLimit', label: 'Daily Time Limit', icon: 'clock', type: 'link', value: '1 hour' },
      { key: 'reminders', label: 'Break Reminders', icon: 'bell', type: 'toggle', value: true },
      { key: 'reminderInterval', label: 'Reminder Interval', icon: 'repeat', type: 'link', value: '20 min' }
    ]
  },
  {
    title: 'Appearance',
    items: [
      { key: 'theme', label: 'Theme', icon: 'moon', type: 'link', value: 'System' },
      { key: 'textSize', label: 'Text Size', icon: 'type', type: 'link', value: 'Medium' }
    ]
  },
  {
    title: 'Notifications',
    items: [
      { key: 'notificationsEnabled', label: 'Enable Notifications', icon: 'bell', type: 'toggle', value: true },
      { key: 'newContent', label: 'New Content', icon: 'file-text', type: 'toggle', value: true },
      { key: 'activityReport', label: 'Weekly Activity Report', icon: 'bar-chart-2', type: 'toggle', value: true }
    ]
  },
  {
    title: 'Storage & Data',
    items: [
      { key: 'cache', label: 'Clear Cache', icon: 'trash-2', type: 'action' },
      { key: 'dataUsage', label: 'Data Usage', icon: 'bar-chart', type: 'link' }
    ]
  },
  {
    title: 'About',
    items: [
      { key: 'about', label: 'About Feedtamer', icon: 'info', type: 'link' },
      { key: 'privacy', label: 'Privacy Policy', icon: 'shield', type: 'link' },
      { key: 'terms', label: 'Terms of Service', icon: 'file', type: 'link' },
      { key: 'feedback', label: 'Send Feedback', icon: 'message-square', type: 'link' }
    ]
  }
];

export default function SettingsScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme];
  const [settings, setSettings] = useState(SETTINGS_SECTIONS);

  // Handle toggle switches
  const handleToggle = (sectionIndex, itemIndex, newValue) => {
    const updatedSettings = [...settings];
    updatedSettings[sectionIndex].items[itemIndex].value = newValue;
    setSettings(updatedSettings);
    
    // In a real app, this would save to backend/storage
    console.log(`Changed ${updatedSettings[sectionIndex].items[itemIndex].key} to ${newValue}`);
  };

  // Handle tapping on action items
  const handleAction = (item) => {
    switch (item.key) {
      case 'cache':
        Alert.alert(
          'Clear Cache',
          'This will clear all cached content. Continue?',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Clear', style: 'destructive', onPress: () => console.log('Cache cleared') }
          ]
        );
        break;
      case 'logout':
        Alert.alert(
          'Log Out',
          'Are you sure you want to log out?',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Log Out', style: 'destructive', onPress: () => console.log('Logged out') }
          ]
        );
        break;
      default:
        break;
    }
  };

  const renderSettingItem = (item, sectionIndex, itemIndex) => {
    return (
      <TouchableOpacity
        key={item.key}
        style={[styles.settingItem, { borderBottomColor: colors.separator }]}
        onPress={() => {
          if (item.type === 'action') {
            handleAction(item);
          } else if (item.type === 'link') {
            // In a real app, this would navigate to the specific setting screen
            router.push(`/settings/${item.key}`);
          }
        }}
      >
        <View style={styles.settingItemLeft}>
          <View style={[styles.iconContainer, { backgroundColor: colors.secondaryButton }]}>
            <Feather name={item.icon} size={18} color={colors.tint} />
          </View>
          <Text style={styles.settingLabel}>{item.label}</Text>
        </View>
        
        <View style={styles.settingItemRight}>
          {item.type === 'toggle' ? (
            <Switch
              trackColor={{ false: colors.inactive, true: colors.tint }}
              thumbColor="#fff"
              ios_backgroundColor={colors.inactive}
              onValueChange={(newValue) => handleToggle(sectionIndex, itemIndex, newValue)}
              value={item.value}
            />
          ) : item.type === 'link' && item.value ? (
            <View style={styles.valueContainer}>
              <Text style={[styles.valueText, { color: colors.text }]}>{item.value}</Text>
              <Feather name="chevron-right" size={20} color={colors.inactive} style={styles.chevron} />
            </View>
          ) : (
            <Feather name="chevron-right" size={20} color={colors.inactive} />
          )}
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <ThemedView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.userSection}>
          <View style={[styles.avatar, { backgroundColor: colors.secondaryButton }]}>
            <Text style={[styles.avatarText, { color: colors.text }]}>JD</Text>
          </View>
          <View style={styles.userInfo}>
            <Text style={styles.userName}>John Doe</Text>
            <Text style={[styles.userEmail, { color: colors.text }]}>john.doe@example.com</Text>
          </View>
          <TouchableOpacity 
            style={[styles.editButton, { backgroundColor: colors.secondaryButton }]}
            onPress={() => router.push('/settings/profile')}
          >
            <Feather name="edit-2" size={16} color={colors.text} />
          </TouchableOpacity>
        </View>

        <View style={[styles.premiumBanner, { backgroundColor: colors.accent }]}>
          <View style={styles.premiumInfo}>
            <Feather name="star" size={20} color="#fff" style={styles.premiumIcon} />
            <View>
              <Text style={styles.premiumTitle}>Free Plan</Text>
              <Text style={styles.premiumSubtitle}>Upgrade to Premium for more features</Text>
            </View>
          </View>
          <TouchableOpacity 
            style={styles.upgradeButton}
            onPress={() => router.push('/subscription')}
          >
            <Text style={styles.upgradeText}>Upgrade</Text>
          </TouchableOpacity>
        </View>

        {settings.map((section, sectionIndex) => (
          <View key={section.title} style={styles.section}>
            <Text style={[styles.sectionTitle, { color: colors.tint }]}>{section.title}</Text>
            <View style={[styles.sectionContent, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              {section.items.map((item, itemIndex) => renderSettingItem(item, sectionIndex, itemIndex))}
            </View>
          </View>
        ))}

        <TouchableOpacity
          style={[styles.logoutButton, { borderColor: colors.error }]}
          onPress={() => handleAction({ key: 'logout' })}
        >
          <Feather name="log-out" size={18} color={colors.error} style={styles.logoutIcon} />
          <Text style={[styles.logoutText, { color: colors.error }]}>Log Out</Text>
        </TouchableOpacity>

        <Text style={[styles.versionText, { color: colors.inactive }]}>Version 1.0.0</Text>
      </ScrollView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  userSection: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    marginBottom: 8,
  },
  avatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 24,
    fontWeight: '600',
  },
  userInfo: {
    marginLeft: 12,
    flex: 1,
  },
  userName: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  userEmail: {
    fontSize: 14,
    opacity: 0.7,
  },
  editButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
  },
  premiumBanner: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginHorizontal: 16,
    padding: 16,
    borderRadius: 12,
    marginBottom: 24,
  },
  premiumInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  premiumIcon: {
    marginRight: 12,
  },
  premiumTitle: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  premiumSubtitle: {
    color: '#fff',
    fontSize: 12,
    opacity: 0.9,
  },
  upgradeButton: {
    backgroundColor: '#fff',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  upgradeText: {
    color: '#16425B',
    fontWeight: '600',
  },
  section: {
    marginBottom: 24,
    paddingHorizontal: 16,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
    marginLeft: 4,
  },
  sectionContent: {
    borderRadius: 12,
    overflow: 'hidden',
    borderWidth: 1,
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
  },
  settingItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconContainer: {
    width: 32,
    height: 32,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  settingLabel: {
    fontSize: 16,
  },
  settingItemRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  valueContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  valueText: {
    fontSize: 14,
    opacity: 0.7,
    marginRight: 4,
  },
  chevron: {
    marginLeft: 4,
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 16,
    marginTop: 8,
    marginBottom: 16,
    paddingVertical: 12,
    borderRadius: 12,
    borderWidth: 1,
  },
  logoutIcon: {
    marginRight: 8,
  },
  logoutText: {
    fontSize: 16,
    fontWeight: '600',
  },
  versionText: {
    textAlign: 'center',
    marginBottom: 40,
    fontSize: 12,
  },
});