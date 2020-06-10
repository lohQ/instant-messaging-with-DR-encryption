import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/chatroom.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/repositories/local_message_repo.dart';
import 'package:sqflite/sqflite.dart';

class LocalChatroomRepo {
  static Database database;
  static String tableName = "CachedChatrooms";

  static init(Database db) async {
    database = db;
  }

  static Future<void> createTableIfNotExists() async {
    final fields = "oppId TEXT PRIMARY KEY, displayName TEXT, photoUrl TEXT, docId TEXT, joined INTEGER";
    await database.execute(
      "CREATE TABLE IF NOT EXISTS $tableName($fields)"
    );
    print("table $tableName created");
  }

  static Future<List<Chatroom>> loadCachedChatrooms() async {
    final chatroomsMap = await database.query(tableName);
    final chatrooms = List.generate(chatroomsMap.length, (i)=>Chatroom.fromMap(chatroomsMap[i]));
    print("locally there is ${chatrooms.length} chatrooms");
    return chatrooms;
  }

  // must load from cache to keep track of 'joined'
  static Future<Chatroom> loadCachedChatroomFromPayloadChatroom(Chatroom chatroom) async {
    final cachedChatroomMap = await database.query(tableName, where: 'oppId = ?', whereArgs: [chatroom.oppUid]);
    if(cachedChatroomMap.length == 0){
      print("payloadChatroom not exists in cache");
      return chatroom;
    }
    final cachedChatroom = Chatroom.fromMap(cachedChatroomMap.first);
    chatroom.joined = cachedChatroom.joined;
    print("payloadChatroom exists in cache, joined = ${chatroom.joined}");
    return chatroom;
    // don't have to update anything here -- FirestoreChatroomBloc will handle it
  }

  static Future<void> cacheChatroom(Chatroom chatroom) async {
    await database.insert(tableName, chatroom.toJson());
    print("chatroom cached");
  }

  static Future<void> updateChatroom(Chatroom chatroom) async {
    await database.update(tableName, chatroom.toJson(), where: 'oppId = ?', whereArgs: [chatroom.oppUid]);
  }

  static Future<void> deleteChatroom(String oppId) async {
    await database.delete(tableName, where: 'oppId = ?', whereArgs: [oppId]);
    await LocalMessageRepo.deleteTable(oppId);
  }

}
