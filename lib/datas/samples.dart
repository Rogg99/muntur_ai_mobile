// File to store sample objects for testing and development
import 'package:munturai/core/utils/date_time_utils.dart';

import '../model/Comment.dart';
import '../model/discussion.dart';
import '../model/message.dart';
import '../model/garage.dart';
import '../model/Info.dart';
import '../model/user.dart';
import '../model/service.dart';
import '../model/abonnement.dart';
import '../model/Notification.dart';
import 'dart:io';

// sample Network Images
String manImage = 'https://media.istockphoto.com/id/1644238002/photo/business-confidence-and-portrait-black-man-with-smile-in-office-startup-ceo-or-owner-at-hr.jpg?s=612x612&w=0&k=20&c=qv73OrrnOSfjzQuJiLOywdO2Ly7jsEmG6JhDXY1Qjc4=';
String womanImage = 'https://images.pexels.com/photos/2535859/pexels-photo-2535859.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500';
String garageImage = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9jBfg6eABiMtyWasyigmnrS-3bYKflpUFwg&s';

// Sample User
User sampleUser = User(
  id: '1',
  nom: "Doe",
  prenom: "John",
  email: "johndoe@example.com",
  telephone: "+1234567890",
  sexe : "Homme",
  date_naissance : "1990-01-01",
  password : "none",
  photo : manImage,
  type : "user",
  ville : "Douala",
  pays : "CAMEROUN"
);

// Sample Garage
Garage sampleGarage = Garage(
  id: '1',
  nom: "AutoFix Garage",
  description: "Your trusted car repair service.",
  ville: "Douala",
  pays: "CAMEROUN",
  photo: garageImage,
);

// Sample Notification
Notification sampleNotification = Notification(
  id: '1',
  title: "Welcome to Munturai!",
  text: "Thank you for joining Munturai. Start exploring now! This is a sample notification to get you started.",
  time: DateTime.now().millisecondsSinceEpoch~/1000,
  url: "https://www.google.com"
);

// Sample Discussion
Discussion sampleDiscussion = Discussion(
  id: '1',
  last_message : "none",
  last_date : DateTime.now().subtract(Duration(days: 70)).format("YYYY-MM-DD HH:mm"),
  last_writer : "none",
  title : "none",
  photo : "none",
  type : "none"
);

Discussion sampleForum = Discussion(
    id: '2',
    last_message : "Hello everyone! Here are some tips for auto repair...",
    last_date : DateTime.now().subtract(Duration(days: 70,seconds: 5)).format("YYYY-MM-DD HH:mm"),
    last_writer : "1",
    title : "Auto Repair Tips",
    photo : "https://www.inrs.fr/.imaging/mte/inrs-fr-theme/editorialGrandeImageMobile/dam/inrs/img/metiers-secteurs/commerce-reparation-auto/garage-sommaire/jcr:content/garage-sommaire.jpg",
    type : "Forum"
);

// 5 Sample Messages for one Forum Discussion between 3 users
List<UIMessage> sampleMessages = [
  UIMessage(
    id: '1',
    disc_id: '1',
    emetteur: '1',
    emetteurName: 'John Doe',
    emetteurPhoto: manImage,
    contenu: "Hello! I need help with my car.",
    answerTo : "none",
    mediaName : "none",
    mediaSize : "none",
    announced : "no",
    media : "none",
    state : 'sent',
    date_envoi : DateTime.now().subtract(Duration(seconds: 5000)).format("YYYY-MM-DD HH:mm"),
  ),
  UIMessage(
    id: '2',
    disc_id: '1',
    emetteur: '2',
    emetteurName: 'Jane Smith',
    emetteurPhoto: womanImage,
    contenu: "Sure, what seems to be the problem?",
    answerTo : "1",
    mediaName : "none",
    mediaSize : "none",
    announced : "no",
    media : "none",
    state : 'sent',
    date_envoi : DateTime.now().subtract(Duration(seconds: 4000)).format("YYYY-MM-DD HH:mm"),
  ),
  UIMessage(
    id: '3',
    disc_id: '1',
    emetteur: '3',
    emetteurName: 'Mike Johnson',
    emetteurPhoto: garageImage,
    contenu: "I can help too! What's the issue?",
    answerTo : "2",
    mediaName : "none",
    mediaSize : "none",
    announced : "no",
    media : "none",
    state : 'sent',
    date_envoi : DateTime.now().subtract(Duration(seconds: 3000)).format("YYYY-MM-DD HH:mm"),
  ),
  UIMessage(
    id: '4',
    disc_id: '1',
    emetteur: '1',
    emetteurName: 'John Doe',
    emetteurPhoto: manImage,
    contenu: "My car won't start. Any ideas?",
    answerTo : "3",
    mediaName : "none",
    mediaSize : "none",
    announced : "no",
    media : "none",
    state : 'sent',
    date_envoi : DateTime.now().subtract(Duration(seconds: 2000)).format("YYYY-MM-DD HH:mm"),
  ),
  UIMessage(
    id: '5',
    disc_id: '1',
    emetteur: '2',
    emetteurName: 'Jane Smith',
    emetteurPhoto: womanImage,
    contenu: "Have you checked the battery?",
    answerTo : "4",
    mediaName : "none",
    mediaSize : "none",
    announced : "no",
    media : "none",
    state : 'sent',
    date_envoi : DateTime.now().subtract(Duration(seconds: 1000)).format("YYYY-MM-DD HH:mm"),
  )
];

// Sample Info
Info sampleInfo = Info(
  id: '1',
  title: "How to Change a Tire",
  contenu: "Changing a tire is easy if you follow these steps...",
  image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxj6URgQPGsRTEVmc-OGECeq0Zx03Ie94DCQ&s",
  time: DateTime.now().millisecondsSinceEpoch~/1000 - 86400,
  likes: 10,
  liked: false,
);

// Sample of 5 comments for an Info
List<Comment> sampleComments = [
  Comment(
    id: 'c1',
    contenu: "Thanks for the helpful guide on changing a tire.",
    info : '1',
    userId : '1',
    userName : 'John Doe',
    userPhoto : manImage,
    replyTo : 'none',
    lineal : 'none',
    replyUserName : 'none',
    time: DateTime.now().millisecondsSinceEpoch~/1000 - 7200,
    likes: 2,
    liked: false,
  ),
  Comment(
    id: 'c2',
    contenu: "Great tips! I was able to change my tire easily.",
    info : '1',
    userId : '2',
    userName : 'Jane Smith',
    userPhoto : womanImage,
    replyTo : 'none',
    lineal : 'none',
    replyUserName : 'none',
    time: DateTime.now().millisecondsSinceEpoch~/1000 - 3600,
    likes: 3,
    liked: false,
  ),
  Comment(
    id: 'c3',
    contenu: "I had trouble loosening the lug nuts, any advice?",
    info : '1',
    userId : '3',
    userName : 'Mike Johnson',
    userPhoto : garageImage,
    replyTo : 'none',
    lineal : 'none',
    replyUserName : 'none',
    time: DateTime.now().millisecondsSinceEpoch~/1000 - 1800,
    likes: 1,
    liked: false,
  ),
  // replies
  Comment(
    id: 'c4',
    contenu: "You might need a breaker bar for stubborn lug nuts.",
    info : '1',
    userId : '1',
    userName : 'John Doe',
    userPhoto : manImage,
    replyTo : 'c3',
    lineal : 'none',
    replyUserName : 'Mike Johnson',
    time: DateTime.now().millisecondsSinceEpoch~/1000 - 900,
    likes: 0,
    liked: false,
  ),
  Comment(
    id: 'c5',
    contenu: "Also, make sure the car is on a flat surface before jacking it up.",
    info : '1',
    userId : '2',
    userName : 'Jane Smith',
    userPhoto : womanImage,
    replyTo : 'c3',
    lineal : 'none',
    replyUserName : 'Mike Johnson',
    time: DateTime.now().millisecondsSinceEpoch~/1000 - 600,
    likes: 0,
    liked: false,
  )
];