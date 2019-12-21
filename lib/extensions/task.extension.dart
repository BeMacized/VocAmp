import 'package:dartz/dartz.dart';
import 'package:voc_amp/models/utils/failure.dart';

extension TaskX<T extends Either<Object, U>, U> on Task<T> {
  Task<Either<Failure, U>> mapLeftToFailure() {
    return this.map(
      (either) => either.leftMap((obj) {
        try {
          return obj as Failure;
        } catch (e) {
          if (obj is Error)
            print('$obj ${obj.stackTrace}');
          else
            print(obj);
          rethrow;
        }
      }),
    );
  }
}
