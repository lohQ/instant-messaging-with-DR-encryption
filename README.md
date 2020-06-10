# instant-messaging-with-DoubleRatchet-encryption

A chat app that combined firebase backend (authentication, firestore, cloud functions and cloud messaging) with virgil security e3kit double encryption functionality. 

** only for android ** 

# Flaws

1. Only basic UI. 
2. Double ratchet encryption still prone to error if user uninstall app. 
3. Some weird initialization (UserRepo, LocalMessageRepo, LocalChatroomRepo). 
4. Cross module dependencies (UserRepo in login module used in all other places...)

# Setup

1. For firebase, create a firebase project and setup the SHA1 key for google sign in. (Optional: Deploy the sendPushNotifs function to enable push notification)
2. For virgil cloud, create a virgil project and deploy the getVirgilJwt function. 
3. Run the project. 

# Structure

Three major modules: login, chatroom_list, and messaging. 
1. Login module handles 
    - authentication with google sign in
    - cache user locally
2. Chatroom_list module handles
    - initializing eThree
    - interacting with firebase
    - caching all chatrooms locally
    - => so to allow viewing available user list, creating chatroom, viewing existing chatroom list, and deleting chatroom
3. Messaging module handles
   - interacting with firebase
   - caching all messages locally
   - => so to allow viewing previous messages, sending (encrypt) and receiving (decrypt) message
4. Extra module: push notification
   - read payload and redirects to target chatroom when notification is clicked (onMessage, onResume)
   - currently nothing configured for onLaunch 
 
