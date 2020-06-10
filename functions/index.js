const functions = require('firebase-functions');
const admin = require('firebase-admin');
// admin.initializeApp();
admin.initializeApp({credential: admin.credential.applicationDefault()});

exports.sendPushNotifs = functions.firestore.document('chatrooms/{documentId}')
    .onUpdate((change, context)=>{
        console.log("-----------sendPushNofifs triggered-----------");
        const prevMessages = change.before.data().messages;
        const newMessages = change.after.data().messages;
        if(newMessages.length <= prevMessages.length){
          console.log("not add message update, sendPushNotifs terminated");
          return null;
        }

        // get receiver uid
        const participants = change.after.data().participants;
        const senderId = newMessages[newMessages.length-1].authorId;
        var receiverId;
        for(i = 0; i < 2; i++){     //always 2 participants per chatroom
          if(participants[i] !== senderId){
            receiverId = participants[i]; break;
          }
        }

        // get receiver fcm token
        return admin.firestore().collection('users').doc(receiverId).get()
          .then(doc => {
            if (!doc.exists) {
              console.log('Receiver does not exist, sendPushNotifs terminated');
              return null;
            }else{
              const receiverToken = doc.data().fcmToken;
              if(receiverToken === null){
                console.log("Receiver does not have fcmToken, sendPushNotifs terminated");
                return null;
              }
              console.log(`Receiver's fcmToken is ${receiverToken}`);

              // get chatroom details
              return admin.firestore().collection('users').doc(senderId)
              .get().then(doc => {
                if (!doc.exists) {
                  console.log('Sender does not exist, sendPushNotifs terminated');
                  return null;
                }else{
                  const senderName = doc.data().displayName;
                  const senderPhotoUrl = doc.data().photoUrl;
                  const payload = {
                    notification: {
                      title: `${senderName} sent a new message to you`,
                      body: "tap here to check it out!"
                    },
                    data: {
                      click_action: "FLUTTER_NOTIFICATION_CLICK",
                      oppId: senderId,
                      displayName: senderName,
                      photoUrl: senderPhotoUrl, 
                      docId: context.params.documentId
                    }
                  };
                  console.log("sending push notification: ", payload);
                  return admin.messaging().sendToDevice(receiverToken, payload)
                    .then(response => {
                      console.log("successfully sent message: ", response);
                      return null;
                    })
                    .catch(error => {
                      console.log("error sending message: ", error);
                    });
                }
              });
            }
          });
    });


