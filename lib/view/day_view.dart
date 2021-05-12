import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/friend.dart';
import 'package:sea_mates/model/friend_list_model.dart';

class DayView extends StatelessWidget {
  const DayView(this.date);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Day ${DateFormat.yMd().format(date)}'),
        ),
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Available Friends",
                  style: Theme.of(context).textTheme.headline6,
                ),
                Divider(
                  height: 10,
                  thickness: 2,
                )
              ],
            ),
          ),
          Consumer<FriendListModel>(
            builder: (context, model, child) {
              return FutureBuilder(
                  future: model.fetchAvailableFriends(date),
                  builder: (context, AsyncSnapshot<List<Friend>?> snapshot) {
                    if (snapshot.hasData) {
                      var friends = snapshot.data;
                      if (friends == null) {
                        return SliverToBoxAdapter(
                            child: Center(
                                child: Text('Not available in local mode')));
                      } else if (friends.isEmpty) {
                        return SliverToBoxAdapter(
                            child: Center(child: Text('No friends available')));
                      } else {
                        return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, int index) {
                            var friend = friends[index];
                            return Card(
                              child: ListTile(
                                title: Text(friend.user.name),
                                subtitle: Text(
                                    '${friend.user.username}\n${friend.user.email}'),
                                isThreeLine: true,
                              ),
                            );
                          }, childCount: friends.length),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                          child: Center(
                              child: Text(
                                  'Error loading friends! Please, try again!')));
                    } else {
                      return SliverFillRemaining(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ));
                    }
                  });
            },
          )
        ]));
  }
}
