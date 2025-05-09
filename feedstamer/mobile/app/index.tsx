import React, { useState, useCallback } from 'react';
import { StyleSheet, FlatList, TouchableOpacity, View, Image, RefreshControl, Pressable } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { useFocusEffect } from 'expo-router';

import Colors from '../constants/Colors';
import { Text } from '../components/ThemedText';
import { View as ThemedView } from '../components/ThemedView';
import { useColorScheme } from '../hooks/useColorScheme';

// Dummy data - would come from API in real app
const CONTENT_DATA = [
  {
    id: '1',
    platform: 'twitter',
    account: {
      id: '1',
      username: 'nytimes',
      displayName: 'The New York Times',
      profilePicture: 'https://pbs.twimg.com/profile_images/1098244578472280064/gjkVMelR_400x400.png',
    },
    contentType: 'tweet',
    text: 'Breaking News: Scientists have discovered a new method to reduce digital distraction by 40% through focused content delivery.',
    mediaUrls: [],
    publishedAt: '2023-05-08T09:30:00Z',
    engagementStats: {
      likes: 1250,
      comments: 328,
      shares: 512
    }
  },
  {
    id: '2',
    platform: 'instagram',
    account: {
      id: '2',
      username: 'natgeo',
      displayName: 'National Geographic',
      profilePicture: 'https://pbs.twimg.com/profile_images/1317444042491125768/C16xV2Lx_400x400.jpg',
    },
    contentType: 'photo',
    text: 'The northern lights captured over Iceland last night. This stunning natural phenomenon is the result of solar particles colliding with gases in Earth's atmosphere.',
    mediaUrls: ['https://images.unsplash.com/photo-1579033461380-adb47c3eb938?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bm9ydGhlcm4lMjBsaWdodHN8ZW58MHx8MHx8&w=1000&q=80'],
    publishedAt: '2023-05-07T18:45:00Z',
    engagementStats: {
      likes: 45200,
      comments: 872
    }
  },
  {
    id: '3',
    platform: 'youtube',
    account: {
      id: '3',
      username: 'mkbhd',
      displayName: 'Marques Brownlee',
      profilePicture: 'https://pbs.twimg.com/profile_images/1468001914302390278/B_Xv_8gu_400x400.jpg',
    },
    contentType: 'video',
    text: 'The future of mobile tech - what to expect in the next 5 years',
    mediaUrls: ['https://i.ytimg.com/vi/rcSGaQ-T2v4/maxresdefault.jpg'],
    publishedAt: '2023-05-06T15:00:00Z',
    engagementStats: {
      likes: 254000,
      comments: 8720,
      views: 2100000
    }
  },
  {
    id: '4',
    platform: 'twitter',
    account: {
      id: '5',
      username: 'tim_cook',
      displayName: 'Tim Cook',
      profilePicture: 'https://pbs.twimg.com/profile_images/1146860463292776449/U4xmnyoo_400x400.png',
    },
    contentType: 'tweet',
    text: 'Excited to announce that Apple is investing another $1 billion in American manufacturing. Creating jobs and opportunities across the country.',
    mediaUrls: [],
    publishedAt: '2023-05-07T20:15:00Z',
    engagementStats: {
      likes: 24800,
      comments: 1832,
      shares: 4521
    }
  }
];

// Get platform-specific icon
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

// Format date
const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  const now = new Date();
  const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
  
  if (diffInHours < 1) {
    return 'Just now';
  } else if (diffInHours < 24) {
    return `${diffInHours}h ago`;
  } else {
    return `${Math.floor(diffInHours / 24)}d ago`;
  }
};

export default function FeedsScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme];
  
  const [content, setContent] = useState(CONTENT_DATA);
  const [refreshing, setRefreshing] = useState(false);
  const [filterPlatform, setFilterPlatform] = useState<string | null>(null);
  const [savedContent, setSavedContent] = useState<string[]>([]);
  
  // Filter content based on selected platform
  const filteredContent = filterPlatform 
    ? content.filter(item => item.platform === filterPlatform)
    : content;
    
  const onRefresh = useCallback(() => {
    setRefreshing(true);
    
    // Simulate API call
    setTimeout(() => {
      // In a real app, this would fetch new content
      setRefreshing(false);
    }, 1500);
  }, []);
  
  // Reset filter when screen gains focus
  useFocusEffect(
    useCallback(() => {
      setFilterPlatform(null);
    }, [])
  );
  
  // Toggle save state for content
  const toggleSaveContent = (contentId: string) => {
    if (savedContent.includes(contentId)) {
      setSavedContent(savedContent.filter(id => id !== contentId));
    } else {
      setSavedContent([...savedContent, contentId]);
    }
  };
  
  const renderContentItem = ({ item }) => {
    const isSaved = savedContent.includes(item.id);
    
    return (
      <View style={[styles.contentCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
        <View style={styles.contentHeader}>
          <View style={styles.accountInfo}>
            <Image source={{ uri: item.account.profilePicture }} style={styles.profilePicture} />
            <View>
              <Text style={styles.displayName}>{item.account.displayName}</Text>
              <View style={styles.usernameContainer}>
                <Text style={[styles.username, { color: colors.text }]}>@{item.account.username}</Text>
                <Feather name={getPlatformIcon(item.platform)} size={14} color={colors.text} style={styles.platformIcon} />
              </View>
            </View>
          </View>
          <Text style={[styles.timestamp, { color: colors.text }]}>{formatDate(item.publishedAt)}</Text>
        </View>
        
        <Text style={styles.contentText}>{item.text}</Text>
        
        {item.mediaUrls.length > 0 && (
          <Image 
            source={{ uri: item.mediaUrls[0] }} 
            style={styles.mediaImage}
            resizeMode="cover"
          />
        )}
        
        <View style={styles.contentFooter}>
          <View style={styles.engagementStats}>
            {item.engagementStats.likes && (
              <View style={styles.statItem}>
                <Feather name="heart" size={14} color={colors.text} style={styles.statIcon} />
                <Text style={[styles.statText, { color: colors.text }]}>{(item.engagementStats.likes / 1000).toFixed(1)}k</Text>
              </View>
            )}
            {item.engagementStats.comments && (
              <View style={styles.statItem}>
                <Feather name="message-circle" size={14} color={colors.text} style={styles.statIcon} />
                <Text style={[styles.statText, { color: colors.text }]}>{(item.engagementStats.comments / 1000).toFixed(1)}k</Text>
              </View>
            )}
            {item.engagementStats.shares && (
              <View style={styles.statItem}>
                <Feather name="repeat" size={14} color={colors.text} style={styles.statIcon} />
                <Text style={[styles.statText, { color: colors.text }]}>{(item.engagementStats.shares / 1000).toFixed(1)}k</Text>
              </View>
            )}
            {item.engagementStats.views && (
              <View style={styles.statItem}>
                <Feather name="eye" size={14} color={colors.text} style={styles.statIcon} />
                <Text style={[styles.statText, { color: colors.text }]}>{(item.engagementStats.views / 1000000).toFixed(1)}M</Text>
              </View>
            )}
          </View>
          
          <View style={styles.actionButtons}>
            <TouchableOpacity 
              style={[styles.actionButton, { backgroundColor: colors.secondaryButton }]}
              onPress={() => {
                // In a real app, this would open the content in the native app or web
                console.log('Open content', item.id);
              }}
            >
              <Feather name="external-link" size={16} color={colors.text} />
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.actionButton, { 
                backgroundColor: isSaved ? colors.tint : colors.secondaryButton 
              }]}
              onPress={() => toggleSaveContent(item.id)}
            >
              <Feather 
                name="bookmark" 
                size={16} 
                color={isSaved ? '#fff' : colors.text} 
              />
            </TouchableOpacity>
          </View>
        </View>
      </View>
    );
  };
  
  return (
    <ThemedView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Your Feeds</Text>
        <View style={styles.filterButtons}>
          <Pressable
            style={[
              styles.filterButton, 
              { 
                backgroundColor: filterPlatform === null ? colors.tint : colors.secondaryButton,
                borderColor: colors.cardBorder
              }
            ]}
            onPress={() => setFilterPlatform(null)}
          >
            <Text style={{ color: filterPlatform === null ? '#fff' : colors.text }}>All</Text>
          </Pressable>
          <Pressable
            style={[
              styles.filterButton, 
              { 
                backgroundColor: filterPlatform === 'twitter' ? colors.tint : colors.secondaryButton,
                borderColor: colors.cardBorder
              }
            ]}
            onPress={() => setFilterPlatform('twitter')}
          >
            <Feather name="twitter" size={16} color={filterPlatform === 'twitter' ? '#fff' : colors.text} />
          </Pressable>
          <Pressable
            style={[
              styles.filterButton, 
              { 
                backgroundColor: filterPlatform === 'instagram' ? colors.tint : colors.secondaryButton,
                borderColor: colors.cardBorder
              }
            ]}
            onPress={() => setFilterPlatform('instagram')}
          >
            <Feather name="instagram" size={16} color={filterPlatform === 'instagram' ? '#fff' : colors.text} />
          </Pressable>
          <Pressable
            style={[
              styles.filterButton, 
              { 
                backgroundColor: filterPlatform === 'youtube' ? colors.tint : colors.secondaryButton,
                borderColor: colors.cardBorder
              }
            ]}
            onPress={() => setFilterPlatform('youtube')}
          >
            <Feather name="youtube" size={16} color={filterPlatform === 'youtube' ? '#fff' : colors.text} />
          </Pressable>
        </View>
      </View>
      
      <FlatList
        data={filteredContent}
        renderItem={renderContentItem}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.contentList}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.tint}
            colors={[colors.tint]}
          />
        }
        showsVerticalScrollIndicator={false}
      />
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 10,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 16,
  },
  filterButtons: {
    flexDirection: 'row',
    marginBottom: 10,
  },
  filterButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 8,
    borderWidth: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  contentList: {
    paddingHorizontal: 16,
    paddingBottom: 20,
  },
  contentCard: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
  },
  contentHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  accountInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  profilePicture: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
  },
  displayName: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  usernameContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  username: {
    fontSize: 14,
    opacity: 0.7,
  },
  platformIcon: {
    marginLeft: 6,
    opacity: 0.7,
  },
  timestamp: {
    fontSize: 12,
    opacity: 0.7,
  },
  contentText: {
    fontSize: 16,
    lineHeight: 22,
    marginBottom: 12,
  },
  mediaImage: {
    height: 200,
    width: '100%',
    borderRadius: 8,
    marginBottom: 12,
  },
  contentFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  engagementStats: {
    flexDirection: 'row',
  },
  statItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 16,
  },
  statIcon: {
    marginRight: 4,
    opacity: 0.7,
  },
  statText: {
    fontSize: 12,
    opacity: 0.7,
  },
  actionButtons: {
    flexDirection: 'row',
  },
  actionButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 8,
  },
});