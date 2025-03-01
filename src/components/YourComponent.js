import PushNotification from 'react-native-push-notification';

// In your non-smoking day button handler
const handleNonSmokedDay = () => {
  // ... existing code ...
  
  // Cancel today's notification since user has logged their status
  PushNotification.cancelAllLocalNotifications();
  // Reschedule for tomorrow
  scheduleDailyReminder();
  
  // ... existing code ...
}; 