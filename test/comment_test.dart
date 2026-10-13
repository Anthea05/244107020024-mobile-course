import 'package:flutter_test/flutter_test.dart';

import '../lib/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman jika field hilang atau null', () {
    final comment = Comment.fromJson({'id': 101});
    expect(comment.id, 101);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('Comment.fromJson aman jika tipe data numeric keliru string/null', () {
    final comment = Comment.fromJson({'postId': null, 'name': null});
    expect(comment.postId, 0);
    expect(comment.name, '');
  });
}
