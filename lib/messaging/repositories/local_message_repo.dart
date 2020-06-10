import 'package:sqflite/sqflite.dart';

import 'package:instant_messaging_with_dr_encryption/messaging/models/message.dart';

class LocalMessageRepo {
  static Database database;

  static init(Database db) async {
    database = db;
  }

  static String _oppIdToTableName(String oppId){
    return "Chatroom_$oppId";
  }

  static Future<void> createTableIfNotExists(String oppId) async {
    final tableName = _oppIdToTableName(oppId);
    final tableFields = "id INTEGER, value TEXT, outgoing INTEGER, timestamp TEXT, delivered INTEGER";
    await database.execute(
      "CREATE TABLE IF NOT EXISTS $tableName($tableFields)"
    );
    print("table $tableName created");
  }

  static Future<void> saveMessage(String oppId, LocalMessage message) async {
    final tableName = _oppIdToTableName(oppId);
    await database.insert(tableName, message.toJson());
    print("message saved");
  }

  static Future<List<LocalMessage>> loadMessages(String oppId) async {
    final tableName = _oppIdToTableName(oppId);
    final messagesMap = await database.query(tableName);
    final messages = List.generate(
      messagesMap.length,
      (i)=>LocalMessage.fromJson(messagesMap[i])
    );
    print("messages loaded from $tableName");
    return messages;
  }

  static Future<void> markAllAsDelivered(String oppId) async {
    final tableName = _oppIdToTableName(oppId);
    await database.update(tableName, {"delivered": 1});
  }

  static Future<void> deleteTable(String oppId) async {
    final tableName = _oppIdToTableName(oppId);
    try{
      await database.delete(tableName);
    } on DatabaseException catch (e){
      if(e.isNoSuchTableError()){
        return;
      }else if(e.isDatabaseClosedError()){
        throw(e);
      }else{
        throw(e);
      }
    }
    print("table deleted");
  }

  // static Future<void> cacheUnsentMessage(String oppId, Message message) async {}

  // static Future<List<Message>> getUnsentMessages(String oppId) async {}

}