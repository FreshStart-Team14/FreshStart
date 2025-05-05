import { configurePushNotifications, scheduleDailyReminder } from './src/utils/notifications';

// ... existing code ...

useEffect(() => {
  configurePushNotifications();
  scheduleDailyReminder();
}, []);

// ... existing code ... 