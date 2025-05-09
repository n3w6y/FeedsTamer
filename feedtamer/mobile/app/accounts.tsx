import React, { useState } from 'react';
import { StyleSheet, FlatList, View, TouchableOpacity, Image, TextInput } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { router } from 'expo-router';

import Colors from '../constants/Colors';
import { Text } from '../components/ThemedText';
import { View as ThemedView } from '../components/ThemedView';
import { useColorScheme } from '../hooks/useColorScheme';

// Dummy data - in real app this would come from the API
const ACCOUNTS = [
  {
    id: '1',
    username: 'nytimes',
    displayName: 'The New York Times',
    platform: 'twitter',
    profilePicture: 'https://pbs.twimg.com/profile_images/1098244578472280064/gjkVMelR_400x400.png',
    description: 'Breaking news, investigations, and opinion from the New York Times',
    category: 'News'
  },
  {
    id: '2',
    username: 'natgeo',
    displayName: 'National Geographic',
    platform: 'instagram',
    profilePicture: 'https://pbs.twimg.com/profile_images/1317444042491125768/C16xV2Lx_400x400.jpg',
    description: 'Experience the world through the eyes of National Geographic photographers',
    category: 'Photography'
  },
  {
    id: '3',
    username: 'mkbhd',
    displayName: 'Marques Brownlee',
    platform: 'youtube',
    profilePicture: 'https://pbs.twimg.com/profile_images/1468001914302390278/B_Xv_8gu_400x400.jpg',
    description: 'Quality Tech Videos | YouTuber | Geek | Consumer Electronics',
    category: 'Technology'
  },
  {
    id: '4',
    username: 'fastcompany',
    displayName: 'Fast Company',
    platform: 'twitter',
    profilePicture: 'https://pbs.twimg.com/profile_images/1671204333203464194/XOxQvSV5_400x400.jpg',
    description: 'Progressive business media brand, with a focus on innovation in technology, leadership, and design',
    category: 'Business'
  },
  {
    id: '5',
    username: 'tim_cook',
    displayName: 'Tim Cook',
    platform: 'twitter',
    profilePicture: 'https://pbs.twimg.com/profile_images/1146860463292776449/U4xmnyoo_400x400.png',
    description: 'CEO of Apple',
    category: 'Technology'
  },
];

// Map platform to icon
const getPlatformIcon = (platform: string) => {
  switch (platform) {
    case 'twitter':
      return 'twitter';
    case 'instagram':
      return 'instagram';
    case 'youtube':
      return 'youtube';
    default:
      return 'link';
  }
};

export default function AccountsScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme];
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');

  // Filter accounts based on search query and active category
  const filteredAccounts = ACCOUNTS.filter(account => {
    const matchesSearch = account.displayName.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          account.username.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = activeCategory === 'All' || account.category === activeCategory;
    return matchesSearch && matchesCategory;
  });

  // Extract unique categories from accounts
  const categories = ['All', ...new Set(ACCOUNTS.map(account => account.category))];

  const renderAccountItem = ({ item }) => (
    <TouchableOpacity 
      style={[styles.accountCard, { borderColor: colors.cardBorder }]}
      onPress={() => {
        // In a real app, this would navigate to account detail screen
        router.push(`/account/${item.id}`);
      }}
    >
      <Image source={{ uri: item.profilePicture }} style={styles.profilePicture} />
      <View style={styles.accountInfo}>
        <View style={styles.accountHeader}>
          <Text style={styles.displayName}>{item.displayName}</Text>
          <Feather name={getPlatformIcon(item.platform)} size={16} color={colors.accent} />
        </View>
        <Text style={styles.username}>@{item.username}</Text>
        <Text numberOfLines={2} style={styles.description}>{item.description}</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <ThemedView style={styles.container}>
      <View style={styles.searchContainer}>
        <Feather name="search" size={20} color={colors.text} style={styles.searchIcon} />
        <TextInput
          style={[styles.searchInput, { color: colors.text, borderColor: colors.separator }]}
          placeholder="Search accounts..."
          placeholderTextColor={colors.inactive}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      <View style={styles.categoriesContainer}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={categories}
          keyExtractor={(item) => item}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={[
                styles.categoryChip,
                { 
                  backgroundColor: activeCategory === item ? colors.tint : colors.secondaryButton,
                }
              ]}
              onPress={() => setActiveCategory(item)}
            >
              <Text 
                style={[
                  styles.categoryText, 
                  { color: activeCategory === item ? '#fff' : colors.text }
                ]}
              >
                {item}
              </Text>
            </TouchableOpacity>
          )}
          contentContainerStyle={styles.categoriesList}
        />
      </View>

      <FlatList
        data={filteredAccounts}
        keyExtractor={(item) => item.id}
        renderItem={renderAccountItem}
        contentContainerStyle={styles.accountsList}
        showsVerticalScrollIndicator={false}
      />

      <TouchableOpacity 
        style={[styles.addButton, { backgroundColor: colors.primaryButton }]}
        onPress={() => {
          // In a real app, this would open add account flow
          router.push('/add-account');
        }}
      >
        <Feather name="plus" size={24} color="#fff" />
      </TouchableOpacity>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 10,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    height: 40,
    borderBottomWidth: 1,
    paddingVertical: 8,
    paddingHorizontal: 12,
  },
  categoriesContainer: {
    marginBottom: 16,
  },
  categoriesList: {
    paddingHorizontal: 16,
  },
  categoryChip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 8,
  },
  categoryText: {
    fontSize: 14,
    fontWeight: '500',
  },
  accountsList: {
    paddingHorizontal: 16,
    paddingBottom: 80, // Space for FAB
  },
  accountCard: {
    flexDirection: 'row',
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    marginBottom: 12,
  },
  profilePicture: {
    width: 50,
    height: 50,
    borderRadius: 25,
    marginRight: 12,
  },
  accountInfo: {
    flex: 1,
  },
  accountHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  displayName: {
    fontSize: 16,
    fontWeight: '600',
  },
  username: {
    fontSize: 14,
    marginBottom: 4,
    opacity: 0.7,
  },
  description: {
    fontSize: 14,
    opacity: 0.9,
  },
  addButton: {
    position: 'absolute',
    bottom: 24,
    right: 24,
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
});