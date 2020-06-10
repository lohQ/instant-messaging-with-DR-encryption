import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:e3kit/e3kit.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:instant_messaging_with_dr_encryption/login/repositories/user_repo.dart';

part 'ethree_init_event.dart';
part 'ethree_init_state.dart';

/* TODO: debug
	Attribute application@label value=(instant_messaging_with_dr_encryption) from AndroidManifest.xml:10:9-61
	is also present at [com.virgilsecurity:pythia-android:0.3.5] AndroidManifest.xml:46:9-41 value=(@string/app_name).
	Suggestion: add 'tools:replace="android:label"' to <application> element at AndroidManifest.xml:8:5-33:19 to override.
  ** Seems like a problem with the e3kit plugin
 */

class EthreeInitBloc extends Bloc<EthreeInitEvent, EthreeInitState> {

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future _tokenCallback() async {
    final HttpsCallable callable = CloudFunctions.instance
      .getHttpsCallable(functionName: 'getVirgilJwt');
    final data = (await callable.call()).data;
    print("retrieved Json Web Token from server");
    return data["token"];
  }

  Future<Either<String,EThree>> initEthree() async {
    print("initializing eThree...");
    final identity = (UserRepo.getInstance().getCurrentUser()).uid;
    final eThree = await EThree.init(identity, _tokenCallback);
    final isSignedIn = await eThree.hasLocalPrivateKey();
    if(isSignedIn){
      print("already signed in");
    }else{
      try{
        await eThree.findUsers([identity]);
        try{
          await eThree.restorePrivateKey("password");
          print("signed in");
        }catch (e){
          // the source of errors, try not to reach this block...
          print(e);
          print("failed to restore private key, attempting re-register...");
          try{
            // TODO: debug 'No private key on device. You should call register() of retrievePrivateKey().'
            await eThree.resetPrivateKeyBackup(); print("resetted private key");
            await eThree.unregister(); print("unregistered");
            await eThree.register(); print("registered");
            await eThree.backupPrivateKey("password"); print("backed up private key");
            print("re-registered");
          } on PlatformException catch (e) {
            return Left(e.message);
          }
        }
      } on PlatformException catch (e){
        // new user
        if(e.message.contains("Card for one or more of provided identities was not found")){
          await eThree.register();
          await eThree.backupPrivateKey("password");
          print("registered");
        }
      }
    }
    return Right(eThree);
  }

  Stream<EthreeInitState> initEThreeStream() async* {
    yield EthreeInitInProgress();
    final eThreeEither = await initEthree();
    yield* eThreeEither.fold(
      (error) async* {
        yield EthreeInitFailed(error);
      },
      (eThree) async* {
        yield EthreeInitCompleted(eThree);
      }
    );
  }

  @override
  EthreeInitState get initialState => EthreeInitInitial();

  @override
  Stream<EthreeInitState> mapEventToState(
    EthreeInitEvent event,
  ) async* {

    if(event is EthreeStartInitEvent){
      // assert user is authenticated before this
      final connectivityResult = await Connectivity().checkConnectivity();
      if(connectivityResult != ConnectivityResult.none){
        yield* initEThreeStream();
      }else{
        // subscibe to connectivity stream and init eThree once connected
        _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          (connectivityResult) async {
            if(connectivityResult != ConnectivityResult.none){
              add(EthreeInitWithConnectivityEvent());
              _connectivitySubscription.cancel();
            }
          },
        );
      }

    } else if (event is EthreeInitWithConnectivityEvent) {
        yield* initEThreeStream();

    } else if (event is EthreeLogoutEvent) {
      if(state is EthreeInitCompleted){
        await (state as EthreeInitCompleted).eThree.cleanUp();
      }
      yield EthreeInitInitial();
    }
  }

  @override
  Future<void> close(){
    _connectivitySubscription?.cancel();
    return super.close();
  }

}
