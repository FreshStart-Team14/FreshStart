import PushNotification from 'react-native-push-notification';

export const configurePushNotifications = () => {
  // Configure the notification channel
  PushNotification.createChannel(
    {
      channelId: 'smoking-reminder',
      channelName: 'Smoking Reminder',
      channelDescription: 'Daily reminder to log non-smoking day',
      soundName: 'default',
      importance: 4,
      vibrate: true,
    },
    (created) => console.log(`Channel created: ${created}`)
  );

  // Configure notifications
  PushNotification.configure({
    onRegister: function (token) {
      console.log('TOKEN:', token);
    },
    onNotification: function (notification) {
      console.log('NOTIFICATION:', notification);
    },
    permissions: {
      alert: true,
      badge: true,
      sound: true,
    },
    popInitialNotification: true,
    requestPermissions: true,
  });
};

export const scheduleDailyReminder = () => {
  // Cancel any existing notifications
  PushNotification.cancelAllLocalNotifications();

  // Schedule new notification
  PushNotification.localNotificationSchedule({
    channelId: 'smoking-reminder',
    title: 'Daily Smoking Log Reminder',
    message: "You haven't marked your non-smoked day yet. Have you really smoked today?",
    date: getNextNotificationDate(), // Set to 9 PM
    repeatType: 'day', // Repeat daily
    allowWhileIdle: true, // Deliver notification even when app is in background
  });
};

const getNextNotificationDate = () => {
  const now = new Date();
  const scheduledTime = new Date(now);
  
  scheduledTime.setHours(21, 0, 0, 0); // Set to 9 PM

  // If it's already past 9 PM, schedule for tomorrow
  if (now.getHours() >= 21) {
    scheduledTime.setDate(scheduledTime.getDate() + 1);
  }

  return scheduledTime;
}; 