importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

  /*Update with yours config*/
const firebaseConfig = {
  apiKey: 'AIzaSyAwjBDDegCJ5PbFGKasjcZm13DZrnuCNFA',
  appId: '1:630064020417:web:11ce8a1fabe6136cc3cd40',
  messagingSenderId: '630064020417',
  projectId: 'statera-0',
  authDomain: 'statera-0.firebaseapp.com',
  storageBucket: 'statera-0.appspot.com',
};
firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

/*messaging.onMessage((payload) => {
console.log('Message received. ', payload);*/
messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };

  self.registration.showNotification(notificationTitle,
    notificationOptions);
});